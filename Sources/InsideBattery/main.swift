import AppKit
import ServiceManagement
import Sparkle

if CommandLine.arguments.contains("--probe-update-feed") {
    exit(UpdateFeedProbe().run())
}

if CommandLine.arguments.contains("--check-updater-configuration") {
    let controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    do {
        try controller.updater.start()
        print("PASS: Sparkle updater started; feed=\(controller.updater.feedURL?.absoluteString ?? "missing")")
        exit(0)
    } catch {
        FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
        exit(1)
    }
}

if CommandLine.arguments.contains("--print-helper-status") {
    let service = SMAppService.daemon(plistName: PowerHelperIdentity.plist)
    print(PowerHelperRegistration.statusDescription(service.status))
    exit(0)
}

if CommandLine.arguments.contains("--check-power-helper") {
    do {
        try PowerModeController.checkHelperConnection()
        print("PASS: authenticated power helper answered without changing power settings")
        exit(0)
    } catch {
        FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
        exit(1)
    }
}

if CommandLine.arguments.contains("--repair-power-helper") {
    Task {
        do {
            let status = try await PowerHelperRegistration.replace()
            print("Helper registration: \(PowerHelperRegistration.statusDescription(status))")
            if status == .requiresApproval {
                print("Approve Inside Battery in System Settings → General → Login Items & Extensions, then run --check-power-helper.")
                exit(2)
            }
            guard status == .enabled else {
                throw PowerModeController.PowerError.helperUnavailable("Helper registration did not enable the service.")
            }
            try await Task.detached { try PowerModeController.checkHelperConnection() }.value
            print("PASS: authenticated power helper answered without changing power settings")
            exit(0)
        } catch {
            FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
            exit(1)
        }
    }
    RunLoop.main.run()
}

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
    print("chargerCapacityWatts=\(state.chargerCapacityWatts.map(String.init) ?? "unavailable")")
    print("timeUntilFull=\(state.timeUntilFullLabel ?? "not charging")")
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
