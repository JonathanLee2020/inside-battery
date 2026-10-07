import AppKit

if CommandLine.arguments.contains("--print-energy-apps") {
    do {
        let apps = try NativeEnergy.read()
        if apps.isEmpty { print("No apps using significant energy") }
        for app in apps { print("\(app.name) [\(app.bundleIdentifier)]") }
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("Energy data unavailable: \(error.localizedDescription)\n".utf8))
        exit(1)
    }
}

if CommandLine.arguments.contains("--self-test") {
    exit(SelfTest.run())
}

if CommandLine.arguments.contains("--print-battery") {
    let state = BatteryMonitor.readState()
    print("percentage=\(state.percentage) charging=\(state.isCharging) externalPower=\(state.isExternalPowerConnected) lowPowerMode=\(state.isLowPowerMode) present=\(state.isPresent)")
    exit(state.isPresent ? 0 : 1)
}

if CommandLine.arguments.contains("--print-power-mode") {
    do {
        let preferences = try PowerModeController.readPreferences()
        for profile in [PowerProfile.battery, .adapter] {
            print("\(profile.title): \(preferences.mode(for: profile)?.title ?? "Unavailable")")
        }
        print("Unified mode command: \(PowerModeController.usesUnifiedMode)")
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
        exit(1)
    }
}

if CommandLine.arguments.contains("--watch-battery") {
    let start = Date()
    let monitor = BatteryMonitor { state in
        let elapsed = Date().timeIntervalSince(start)
        print(String(format: "%.3fs", elapsed), "percentage=\(state.percentage) charging=\(state.isCharging) externalPower=\(state.isExternalPowerConnected)")
        fflush(stdout)
    }
    do {
        try monitor.start()
        // A finite diagnostic session uses the exact same subscription as the menu-bar app.
        RunLoop.main.run(until: Date().addingTimeInterval(30))
        monitor.stop()
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
        exit(1)
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
