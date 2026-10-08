import Foundation
import IOKit.ps

@MainActor
final class BatteryMonitor {
    typealias Handler = (BatteryState) -> Void
    typealias SourceFactory = (IOPowerSourceCallbackType, UnsafeMutableRawPointer) -> CFRunLoopSource?

    private var notificationSource: CFRunLoopSource?
    private var powerModeObserver: NSObjectProtocol?
    private let handler: Handler
    private let sourceFactory: SourceFactory

    init(
        sourceFactory: @escaping SourceFactory = { callback, context in
            IOPSNotificationCreateRunLoopSource(callback, context)?.takeRetainedValue()
        },
        handler: @escaping Handler
    ) {
        self.sourceFactory = sourceFactory
        self.handler = handler
    }

    func start() throws {
        guard notificationSource == nil else { return }
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let source = sourceFactory({ context in
            guard let context else { return }
            // This source is scheduled only on the main run loop.
            MainActor.assumeIsolated {
                Unmanaged<BatteryMonitor>.fromOpaque(context).takeUnretainedValue().refresh()
            }
        }, context) else {
            throw MonitorError.notificationRegistrationFailed
        }
        notificationSource = source
        // Common modes keep updates working while the menu is open or being tracked.
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        powerModeObserver = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        refresh()
    }

    func stop() {
        guard let source = notificationSource else { return }
        CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        CFRunLoopSourceInvalidate(source)
        notificationSource = nil
        if let observer = powerModeObserver {
            NotificationCenter.default.removeObserver(observer)
            powerModeObserver = nil
        }
    }

    func refresh() {
        handler(Self.readState())
    }

    static func readState() -> BatteryState {
        guard
            let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef]
        else {
            return .unavailable
        }

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue()
                    as? [String: Any] else { continue }

            let type = description[kIOPSTypeKey] as? String
            guard type == kIOPSInternalBatteryType else { continue }

            let adapter = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any]
            return state(from: description, lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
                         adapterDetails: adapter)
        }

        return .unavailable
    }

    nonisolated static func state(from description: [String: Any], lowPowerMode: Bool = false, adapterDetails: [String: Any]? = nil) -> BatteryState {
        let current = description[kIOPSCurrentCapacityKey] as? Int ?? 0
        let maximum = description[kIOPSMaxCapacityKey] as? Int ?? 100
        let percentage = maximum > 0 ? Int((Double(current) / Double(maximum) * 100).rounded()) : current
        let charging = description[kIOPSIsChargingKey] as? Bool ?? false
        let externalPower = description[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
        let watts = adapterDetails?[kIOPSPowerAdapterWattsKey] as? Int
        let minutes = description[kIOPSTimeToFullChargeKey] as? Int
        return BatteryState(percentage: percentage, isCharging: charging, isExternalPowerConnected: externalPower,
                            isLowPowerMode: lowPowerMode, chargerCapacityWatts: watts,
                            minutesUntilFull: minutes)
    }

    enum MonitorError: LocalizedError {
        case notificationRegistrationFailed

        var errorDescription: String? {
            "Could not subscribe to macOS battery-change notifications."
        }
    }
}
