import Foundation

struct BatteryState: Equatable, Sendable {
    let percentage: Int
    let isCharging: Bool
    let isExternalPowerConnected: Bool
    let isPresent: Bool
    let isLowPowerMode: Bool
    let isHighPowerMode: Bool

    init(percentage: Int, isCharging: Bool, isPresent: Bool = true, isExternalPowerConnected: Bool = false, isLowPowerMode: Bool = false, isHighPowerMode: Bool = false) {
        self.percentage = min(max(percentage, 0), 100)
        self.isCharging = isCharging
        self.isExternalPowerConnected = isExternalPowerConnected || isCharging
        self.isPresent = isPresent
        self.isLowPowerMode = isLowPowerMode
        self.isHighPowerMode = isHighPowerMode && !isLowPowerMode
    }

    func withHighPowerMode(_ enabled: Bool) -> BatteryState {
        BatteryState(percentage: percentage, isCharging: isCharging, isPresent: isPresent,
                     isExternalPowerConnected: isExternalPowerConnected, isLowPowerMode: isLowPowerMode,
                     isHighPowerMode: enabled)
    }

    static let unavailable = BatteryState(percentage: 0, isCharging: false, isPresent: false)

    var accessibilityLabel: String {
        guard isPresent else { return "Battery unavailable" }
        let status = isCharging ? ", charging" : (isExternalPowerConnected ? ", plugged in, not charging" : "")
        return "Battery \(percentage) percent" + status + (isLowPowerMode ? ", Low Power Mode" : isHighPowerMode ? ", High Power Mode" : "")
    }
}
