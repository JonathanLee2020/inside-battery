import Foundation

struct BatteryState: Equatable, Sendable {
    let percentage: Int
    let isCharging: Bool
    let isExternalPowerConnected: Bool
    let isPresent: Bool
    let isLowPowerMode: Bool
    let isHighPowerMode: Bool
    let chargerCapacityWatts: Int?
    let minutesUntilFull: Int?

    init(percentage: Int, isCharging: Bool, isPresent: Bool = true, isExternalPowerConnected: Bool = false, isLowPowerMode: Bool = false, isHighPowerMode: Bool = false, chargerCapacityWatts: Int? = nil, minutesUntilFull: Int? = nil) {
        self.percentage = min(max(percentage, 0), 100)
        self.isCharging = isCharging
        self.isExternalPowerConnected = isExternalPowerConnected || isCharging
        self.isPresent = isPresent
        self.isLowPowerMode = isLowPowerMode
        self.isHighPowerMode = isHighPowerMode && !isLowPowerMode
        self.chargerCapacityWatts = self.isExternalPowerConnected && isPresent
            ? chargerCapacityWatts.flatMap { $0 > 0 ? $0 : nil } : nil
        self.minutesUntilFull = isCharging && isPresent && self.percentage < 100
            ? minutesUntilFull.flatMap { $0 >= -1 ? $0 : nil } : nil
    }

    func withHighPowerMode(_ enabled: Bool) -> BatteryState {
        BatteryState(percentage: percentage, isCharging: isCharging, isPresent: isPresent,
                     isExternalPowerConnected: isExternalPowerConnected, isLowPowerMode: isLowPowerMode,
                     isHighPowerMode: enabled, chargerCapacityWatts: chargerCapacityWatts,
                     minutesUntilFull: minutesUntilFull)
    }

    var timeUntilFullLabel: String? {
        guard isPresent && isCharging && percentage < 100 else { return nil }
        guard let minutes = minutesUntilFull else { return "Charging estimate unavailable" }
        if minutes == -1 { return "Calculating time until fully charged…" }
        if minutes == 0 { return "Less than a minute until fully charged" }
        let hours = minutes / 60
        let remainder = minutes % 60
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours) " + (hours == 1 ? "hour" : "hours")) }
        if remainder > 0 { parts.append("\(remainder) " + (remainder == 1 ? "minute" : "minutes")) }
        return parts.joined(separator: " and ") + " until fully charged"
    }

    static let unavailable = BatteryState(percentage: 0, isCharging: false, isPresent: false)

    var accessibilityLabel: String {
        guard isPresent else { return "Battery unavailable" }
        let status = isCharging ? ", charging" : (isExternalPowerConnected ? ", plugged in, not charging" : "")
        return "Battery \(percentage) percent" + status + (isLowPowerMode ? ", Low Power Mode" : isHighPowerMode ? ", High Power Mode" : "")
    }
}
