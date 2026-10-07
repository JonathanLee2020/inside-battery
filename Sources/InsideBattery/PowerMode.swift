import Foundation

enum PowerMode: Int, CaseIterable, Sendable {
    case automatic = 0
    case low = 1
    case high = 2

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .low: "Low Power"
        case .high: "High Power"
        }
    }
}

enum PowerProfile: String, Sendable {
    case battery = "Battery Power"
    case adapter = "AC Power"

    var argument: String { self == .adapter ? "-c" : "-b" }
    var title: String { self == .adapter ? "On Power Adapter" : "On Battery" }
}

struct PowerPreferences: Sendable {
    let profiles: [PowerProfile: [String: Int]]

    init(output: String) {
        var profiles: [PowerProfile: [String: Int]] = [:]
        var profile: PowerProfile?
        for line in output.split(separator: "\n") {
            let text = line.trimmingCharacters(in: .whitespaces)
            if text.hasSuffix(":"), let next = PowerProfile(rawValue: String(text.dropLast())) {
                profile = next
                profiles[next] = [:]
            } else if let profile {
                let fields = text.split(whereSeparator: \.isWhitespace)
                if fields.count == 2, let value = Int(fields[1]) {
                    profiles[profile, default: [:]][String(fields[0])] = value
                }
            }
        }
        self.profiles = profiles
    }

    func mode(for profile: PowerProfile) -> PowerMode? {
        guard let settings = profiles[profile] else { return nil }
        if settings["highpowermode"] == 1 { return .high }
        if let value = settings["powermode"] ?? settings["lowpowermode"] {
            return PowerMode(rawValue: value)
        }
        return nil
    }
}

enum PowerModeController {
    // Older pmset versions expose separate boolean switches; newer ones accept powermode 0/1/2.
    static let usesUnifiedMode: Bool = {
        guard let binary = try? Data(contentsOf: URL(fileURLWithPath: "/usr/bin/pmset")) else { return false }
        return binary.range(of: Data("\0powermode\0".utf8)) != nil
    }()

    static func readPreferences() throws -> PowerPreferences {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "custom"]
        process.standardOutput = output
        process.standardError = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let text = String(decoding: data, as: UTF8.self)
        guard process.terminationStatus == 0 else { throw PowerError.message(text) }
        return PowerPreferences(output: text)
    }

    static func command(for mode: PowerMode, profile: PowerProfile, unified: Bool, highPowerAvailable: Bool = true) -> String {
        if unified { return "/usr/bin/pmset \(profile.argument) powermode \(mode.rawValue)" }
        switch mode {
        case .low: return "/usr/bin/pmset \(profile.argument) lowpowermode 1" + (highPowerAvailable ? " highpowermode 0" : "")
        case .automatic: return "/usr/bin/pmset \(profile.argument) lowpowermode 0" + (highPowerAvailable ? " highpowermode 0" : "")
        case .high: return "/usr/bin/pmset \(profile.argument) lowpowermode 0 highpowermode 1"
        }
    }

    static func set(_ mode: PowerMode, profile: PowerProfile) throws {
        let client = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/InsideBatteryPowerClient")
        guard FileManager.default.isExecutableFile(atPath: client.path) else {
            throw PowerError.message("The quick-switch helper is missing. Rebuild and install the complete app bundle.")
        }
        let process = Process()
        let output = Pipe()
        process.executableURL = client
        process.arguments = [String(mode.rawValue), profile.rawValue]
        process.standardOutput = output
        process.standardError = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            let detail = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            if process.terminationStatus == 2 || process.terminationReason == .uncaughtSignal {
                throw PowerError.helperUnavailable(detail.isEmpty
                    ? "The power client exited unexpectedly (status \(process.terminationStatus)). Choose Repair Quick Power Switching to register this build's helper."
                    : detail)
            }
            throw PowerError.message(detail.isEmpty ? "The power client exited with status \(process.terminationStatus)." : detail)
        }
        guard try readPreferences().mode(for: profile) == mode else {
            throw PowerError.message("The saved power mode did not match the requested mode. Open Battery Settings to check it.")
        }
    }

    // Called only by the authenticated root helper. No shell or arbitrary commands.
    static func apply(_ mode: PowerMode, profile: PowerProfile) throws {
        // All command content comes from closed enums, never user-provided shell text.
        let preferences = try readPreferences()
        let highPowerAvailable = preferences.profiles[profile]?["highpowermode"] != nil
        guard usesUnifiedMode || mode != .high || highPowerAvailable else {
            throw PowerError.message("High Power Mode is not supported on this Mac.")
        }
        let command = command(for: mode, profile: profile, unified: usesUnifiedMode, highPowerAvailable: highPowerAvailable)
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = Array(command.split(separator: " ").dropFirst()).map(String.init)
        process.standardOutput = output
        process.standardError = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw PowerError.message(String(decoding: data, as: UTF8.self)) }
        let observed = try readPreferences().mode(for: profile)
        guard observed == mode else {
            throw PowerError.message("macOS did not apply \(mode.title) for \(profile.title.lowercased()). This Mac or power source may not support that mode. Check Battery Settings.")
        }
    }

    enum PowerError: LocalizedError {
        case message(String)
        case helperUnavailable(String)
        var errorDescription: String? {
            switch self {
            case .message(let message), .helperUnavailable(let message): message
            }
        }
    }
}
