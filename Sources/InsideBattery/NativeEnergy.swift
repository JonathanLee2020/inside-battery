import AppKit
import Darwin

struct EnergyApp: Equatable, Sendable {
    let bundleIdentifier: String
    let name: String
}

enum NativeEnergy {
    // Experimental ABI observed in macOS 26.2's Control Center:
    // NSDictionary *systemstats_get_top_coalitions(uint64_t seconds,
    //     uint64_t count, double minimumScore). The return is autoreleased.
    private typealias Query = @convention(c) (UInt64, UInt64, Double) -> Unmanaged<CFDictionary>?
    private final class Library: @unchecked Sendable {
        let query: Query?
        let lock = NSLock()
        init() {
            // Keep this cache image loaded for the lifetime of the process.
            guard let handle = dlopen("/usr/lib/libsystemstats.dylib", RTLD_NOW | RTLD_LOCAL),
                  let symbol = dlsym(handle, "systemstats_get_top_coalitions") else { query = nil; return }
            query = unsafeBitCast(symbol, to: Query.self)
        }
    }
    private static let library = Library()

    static func read() throws -> [EnergyApp] {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        // Never guess a private function's ABI on an unverified OS release.
        guard version.majorVersion == 26 && version.minorVersion == 2 else {
            throw EnergyError.unavailable("Native energy integration has been checked only on macOS 26.2. It is disabled on this macOS version.")
        }
        guard let query = library.query else {
            throw EnergyError.unavailable("macOS's native energy-query interface is unavailable.")
        }
        library.lock.lock()
        defer { library.lock.unlock() }
        return try autoreleasepool {
            // Control Center defaults: 120-second window, 5 results, minimum
            // cumulative score = seconds × 500. Read overrides without writing.
            let preferences = UserDefaults(suiteName: "com.apple.controlcenter")
            let interval = (preferences?.object(forKey: "BatteryPowerScoreInterval") as? NSNumber)?.uint64Value ?? 120
            let minimum = (preferences?.object(forKey: "BatteryPowerScoreMax") as? NSNumber)?.doubleValue ?? Double(interval) * 500
            guard interval > 0 && interval <= 3600, minimum.isFinite && minimum >= 0 else {
                throw EnergyError.unavailable("Control Center's energy-query settings are invalid.")
            }
            guard let response = query(interval, 5, minimum) else {
                throw EnergyError.unavailable("macOS returned no energy data. Access may be restricted, or the experimental interface may have changed.")
            }
            return try parse(response.takeUnretainedValue() as NSDictionary)
        }
    }

    static func validIdentifier(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.count <= 255 && value.contains(".")
            && value.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || "._-".contains($0)) }
    }

    static func parse(_ response: NSDictionary) throws -> [EnergyApp] {
        guard let identifiers = response["bundle_identifiers"] as? [String],
              let responsible = response["responsible_bundle_identifiers"] as? [String],
              let names = response["display_names"] as? [String],
              identifiers.count == responsible.count, identifiers.count == names.count else {
            throw EnergyError.unavailable("The native energy response has an unexpected format.")
        }
        var seen = Set<String>()
        var apps: [EnergyApp] = []
        for index in identifiers.indices {
            // Coalitions group helpers under their responsible application.
            let identifier = validIdentifier(responsible[index]) ? responsible[index] : identifiers[index]
            guard validIdentifier(identifier), !names[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw EnergyError.unavailable("The native energy response contains an invalid app identity.")
            }
            if seen.insert(identifier).inserted {
                apps.append(EnergyApp(bundleIdentifier: identifier, name: names[index]))
            }
        }
        return apps
    }

    static func selectionCommand(for app: EnergyApp) throws -> String {
        guard validIdentifier(app.bundleIdentifier) else {
            throw EnergyError.unavailable("The selected app has an invalid bundle identifier.")
        }
        return "openTab:Power;bundle-id:" + app.bundleIdentifier
    }

    @MainActor
    static func selectionEvent(for app: EnergyApp) throws -> NSAppleEventDescriptor {
        // Control Center uses a reopen-application event with a 'dits' parameter,
        // not AppleScript/UI scripting, a fake file, or a new app process.
        let event = NSAppleEventDescriptor(eventClass: 0x61657674, eventID: 0x72617070,
            targetDescriptor: .null(), returnID: 0, transactionID: 0)
        event.setParam(NSAppleEventDescriptor(string: try selectionCommand(for: app)), forKeyword: 0x64697473)
        return event
    }

    enum EnergyError: LocalizedError {
        case unavailable(String)
        var errorDescription: String? {
            switch self { case .unavailable(let message): message }
        }
    }
}
