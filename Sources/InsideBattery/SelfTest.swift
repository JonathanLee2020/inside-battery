import AppKit
import IOKit.ps

enum SelfTest {
    @MainActor
    static func run() -> Int32 {
        let levelLabel = BatteryState(percentage: 73, isCharging: false).accessibilityLabel
        let chargingLabel = BatteryState(percentage: 73, isCharging: true).accessibilityLabel
        var checks = [
            (BatteryState(percentage: -2, isCharging: false).percentage == 0, "clamps values below zero"),
            (BatteryState(percentage: 105, isCharging: false).percentage == 100, "clamps values above 100"),
            (levelLabel == "Battery 73 percent", "describes battery level (got: \(levelLabel))"),
            (chargingLabel == "Battery 73 percent, charging", "describes charging state (got: \(chargingLabel))"),
            (BatteryState.unavailable.accessibilityLabel == "Battery unavailable", "describes an unavailable battery")
        ]
        func allowsHelperUpdate(_ installed: String, _ published: String?, active: Bool = true) -> Bool {
            do {
                try AppUpdater.validateHelperUpdate(installedHash: installed, publishedHash: published, helperActive: active)
                return true
            } catch { return false }
        }
        let updateHash = String(repeating: "a", count: 40)
        checks += [
            (allowsHelperUpdate(updateHash + "\n", updateHash), "UI-only updates preserve the registered helper pair"),
            (!allowsHelperUpdate(updateHash, String(repeating: "b", count: 40)), "updates cannot silently replace a different registered helper"),
            (!allowsHelperUpdate(updateHash, nil), "updates require helper compatibility metadata when a helper is registered"),
            (!allowsHelperUpdate("", ""), "empty matching hashes cannot bypass helper compatibility checks"),
            (!allowsHelperUpdate("invalid", "invalid"), "malformed matching hashes cannot bypass helper compatibility checks"),
            (allowsHelperUpdate(updateHash, nil, active: false), "apps without a registered helper can install an update")
        ]
        for (minutes, expected) in [
            (1, "1 minute until fully charged"),
            (45, "45 minutes until fully charged"),
            (60, "1 hour until fully charged"),
            (61, "1 hour and 1 minute until fully charged"),
            (125, "2 hours and 5 minutes until fully charged"),
            (0, "Less than a minute until fully charged"),
            (-1, "Calculating time until fully charged…"),
            (-2, "Charging estimate unavailable")
        ] {
            let state = BatteryState(percentage: 73, isCharging: true, minutesUntilFull: minutes)
            checks.append((state.timeUntilFullLabel == expected, "formats charging estimate: \(minutes)"))
        }
        let timedCharge = BatteryMonitor.state(from: [
            kIOPSCurrentCapacityKey: 73, kIOPSMaxCapacityKey: 100,
            kIOPSIsChargingKey: true, kIOPSTimeToFullChargeKey: 80
        ])
        checks += [
            (timedCharge.minutesUntilFull == 80, "reads native charging estimate in minutes"),
            (timedCharge.withHighPowerMode(true).minutesUntilFull == 80, "mode update preserves charging estimate"),
            (BatteryState(percentage: 73, isCharging: true).timeUntilFullLabel == "Charging estimate unavailable", "missing estimate is not reported as zero"),
            (BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, minutesUntilFull: 80).timeUntilFullLabel == nil, "paused charging hides stale estimate"),
            (BatteryState(percentage: 73, isCharging: false, minutesUntilFull: 80).minutesUntilFull == nil, "unplugging clears estimate"),
            (BatteryState(percentage: 100, isCharging: true, minutesUntilFull: 80).timeUntilFullLabel == nil, "full battery hides estimate"),
            (BatteryState(percentage: 73, isCharging: true, isPresent: false, minutesUntilFull: 80).minutesUntilFull == nil, "absent battery clears estimate")
        ]
        // Sample the composited pixels, not just the symbol source: the previous
        // source-atop tint painted a solid square across the circle underneath.
        for mode in PowerMode.allCases {
            let icon = BatteryMenu.modeImage(mode, selected: true)
            if let data = icon.tiffRepresentation, let bitmap = NSBitmapImageRep(data: data),
               let corner = bitmap.colorAt(x: 0, y: 0),
               let rim = bitmap.colorAt(x: bitmap.pixelsWide / 8, y: bitmap.pixelsHigh / 2)?.usingColorSpace(.sRGB) {
                checks.append((corner.alphaComponent < 0.1, "selected \(mode.title) icon has transparent corners"))
                let expectedHue: Bool = switch mode {
                case .automatic: rim.blueComponent > rim.redComponent + 0.3
                case .low: rim.redComponent > 0.7 && rim.greenComponent > 0.5 && rim.blueComponent < 0.4
                case .high: rim.blueComponent - rim.greenComponent > 0.2 && rim.redComponent - rim.greenComponent > 0.1
                }
                checks.append((expectedHue, "selected \(mode.title) circle uses its energy-mode color"))
                if mode == .automatic, let center = bitmap.colorAt(x: bitmap.pixelsWide / 2, y: bitmap.pixelsHigh / 2)?.usingColorSpace(.sRGB) {
                    checks.append((center.redComponent > 0.9 && center.greenComponent > 0.9 && center.blueComponent > 0.9,
                                   "selected Automatic icon retains a white battery rather than a blue square"))
                }
            } else { checks.append((false, "selected \(mode.title) icon rasterizes for pixel verification")) }
        }
        do {
            let apps = try NativeEnergy.parse([
                "bundle_identifiers": ["com.apple.WebKit.WebContent", "com.apple.Safari", "com.example.Editor"],
                "responsible_bundle_identifiers": ["com.apple.Safari", "com.apple.Safari", ""],
                "display_names": ["Safari", "Safari", "Editor"]
            ])
            let systemOnly = try NativeEnergy.parse([
                "bundle_identifiers": ["com.apple.WindowServer"],
                "responsible_bundle_identifiers": [""],
                "display_names": [""]
            ])
            let mixedCoalitions = try NativeEnergy.parse([
                "bundle_identifiers": ["com.apple.WindowServer", "com.apple.Safari", "com.example.background"],
                "responsible_bundle_identifiers": ["", "com.apple.Safari", ""],
                "display_names": ["", "Safari", " \n "]
            ])
            checks += [
                (systemOnly.isEmpty, "unnamed native system coalitions are not displayed as significant-energy apps"),
                (mixedCoalitions == [EnergyApp(bundleIdentifier: "com.apple.Safari", name: "Safari")], "unnamed coalitions do not discard named apps in the same response"),
                ((try? NativeEnergy.parse(["bundle_identifiers": ["invalid;openTab:CPU"], "responsible_bundle_identifiers": [""], "display_names": ["Named App"]])) == nil, "named energy apps with invalid identities still fail validation"),
                (apps.count == 2, "native energy coalitions deduplicate responsible apps"),
                (apps.first == EnergyApp(bundleIdentifier: "com.apple.Safari", name: "Safari"), "browser helpers are attributed to their native responsible app"),
                (apps.last?.bundleIdentifier == "com.example.Editor", "native energy falls back to the supplied app ID when responsible ID is absent"),
                (try NativeEnergy.parse(["bundle_identifiers": [String](), "responsible_bundle_identifiers": [String](), "display_names": [String]()]).isEmpty, "a valid empty native response means no significant-energy apps"),
                ((try? NativeEnergy.parse([:])) == nil, "a missing native response is not treated as no significant-energy apps"),
                ((try? NativeEnergy.parse(["bundle_identifiers": ["com.apple.Safari"], "responsible_bundle_identifiers": [String](), "display_names": ["Safari"]])) == nil, "native energy rejects mismatched parallel arrays"),
                (!NativeEnergy.validIdentifier("com.apple.Safari;openTab:CPU"), "native app selection rejects injected command separators"),
                (try NativeEnergy.selectionCommand(for: apps[0]) == "openTab:Power;bundle-id:com.apple.Safari", "native app selection targets the Energy tab and exact responsible bundle")
            ]
            let event = try NativeEnergy.selectionEvent(for: apps[0])
            checks += [
                (event.eventClass == 0x61657674 && event.eventID == 0x72617070, "Activity Monitor selection uses native reopen event"),
                (event.paramDescriptor(forKeyword: 0x64697473)?.stringValue == "openTab:Power;bundle-id:com.apple.Safari", "native reopen event carries the same selection parameter as Control Center")
            ]
            let item = NSMenuItem(title: apps[0].name, action: nil, keyEquivalent: "")
            item.representedObject = apps[0]
            checks.append(((item.representedObject as? EnergyApp) == apps[0], "energy menu preserves selected app identity through AppKit"))
        } catch {
            checks.append((false, "native energy fixture tests: \(error.localizedDescription)"))
        }

        let pluggedIn = BatteryMonitor.state(from: [
            kIOPSCurrentCapacityKey: 73,
            kIOPSMaxCapacityKey: 100,
            kIOPSIsChargingKey: false,
            kIOPSPowerSourceStateKey: kIOPSACPowerValue
        ])
        let adapterReading = BatteryMonitor.state(from: [
            kIOPSCurrentCapacityKey: 73, kIOPSMaxCapacityKey: 100,
            kIOPSIsChargingKey: false, kIOPSPowerSourceStateKey: kIOPSACPowerValue
        ], adapterDetails: [kIOPSPowerAdapterWattsKey: 96])
        checks += [
            (adapterReading.chargerCapacityWatts == 96, "reads reported adapter capability in watts"),
            (adapterReading.withHighPowerMode(true).chargerCapacityWatts == 96, "power-mode refresh preserves charger capability"),
            (BatteryState(percentage: 73, isCharging: false, chargerCapacityWatts: 96).chargerCapacityWatts == nil,
             "unplugged state discards stale charger capacity"),
            (BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, chargerCapacityWatts: 0).chargerCapacityWatts == nil,
             "zero adapter rating remains unavailable instead of reporting 0 W")
        ]
        let unplugged = BatteryMonitor.state(from: [
            kIOPSCurrentCapacityKey: 73,
            kIOPSMaxCapacityKey: 100,
            kIOPSIsChargingKey: false,
            kIOPSPowerSourceStateKey: kIOPSBatteryPowerValue
        ])
        let appearance = NSAppearance(named: .aqua)
        let active = BatteryState(percentage: 73, isCharging: true)
        checks += [
            (pluggedIn.isExternalPowerConnected && !pluggedIn.isCharging, "detects AC power when charging is paused"),
            (!unplugged.isExternalPowerConnected, "detects battery power after unplugging"),
            (pluggedIn.accessibilityLabel == "Battery 73 percent, plugged in, not charging", "accurately describes plugged-in status"),
            (BatteryIcon.colors(for: pluggedIn, appearance: appearance).progress == BatteryIcon.colors(for: active, appearance: appearance).progress, "uses green for both active and paused charging"),
            (BatteryIcon.image(for: pluggedIn, appearance: appearance).tiffRepresentation != BatteryIcon.image(for: unplugged, appearance: appearance).tiffRepresentation, "renders plugged-in and unplugged states differently")
        ]

        let preferences = PowerPreferences(output: """
        Battery Power:
         lowpowermode 1
        AC Power:
         lowpowermode 2
        """)
        let legacy = PowerPreferences(output: """
        AC Power:
         lowpowermode 0
         highpowermode 1
        """)
        let unknown = PowerPreferences(output: "AC Power:\n powermode 99")
        let lowPowerBattery = BatteryState(percentage: 52, isCharging: false, isLowPowerMode: true)
        let lowPowerCharging = BatteryState(percentage: 52, isCharging: true, isLowPowerMode: true)
        let highPower = BatteryState(percentage: 52, isCharging: false, isHighPowerMode: true)
        let highCharging = BatteryState(percentage: 52, isCharging: true, isHighPowerMode: true)
        let highPlugged = BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, isHighPowerMode: true)
        let highFill = BatteryIcon.colors(for: highPower, appearance: appearance).progress.usingColorSpace(.sRGB)!
        let highLuminance = luminance(highFill)
        let highEmptyLuminance = luminance(BatteryIcon.colors(for: highPower, appearance: appearance).surface)
        checks += [
            (highFill.blueComponent - highFill.greenComponent >= 0.2 && highFill.redComponent - highFill.greenComponent >= 0.1, "lighter High Power fill remains visibly violet"),
            ((highLuminance + 0.05) / (highEmptyLuminance + 0.05) >= 1.4, "High Power charge fill remains distinct from the empty remainder"),
            (highPower.accessibilityLabel.contains("High Power Mode"), "announces High Power to VoiceOver"),
            (!BatteryState(percentage: 52, isCharging: false, isLowPowerMode: true, isHighPowerMode: true).isHighPowerMode, "Low Power takes precedence over stale High Power state"),
            (BatteryIcon.colors(for: highCharging, appearance: appearance).progress == highFill, "High Power retains its purple charge fill while charging"),
            ((try? PowerHelperIdentity.requirement(hash: String(repeating: "a", count: 40))) != nil, "accepts exact valid signature hash"),
            ((try? PowerHelperIdentity.requirement(hash: "a\" or true")) == nil, "rejects injected signature requirement"),
            (PowerMode(rawValue: 99) == nil && PowerProfile(rawValue: "-a") == nil, "rejects unknown helper inputs")
        ]
        checks += [
            (preferences.mode(for: .battery) == .low, "reads battery-specific Low Power preference"),
            (preferences.mode(for: .adapter) == .high, "reads adapter-specific High Power preference"),
            (legacy.mode(for: .adapter) == .high, "reads legacy High Power switch"),
            (unknown.mode(for: .adapter) == nil, "unknown mode is not misreported as Automatic"),
            (PowerModeController.command(for: .low, profile: .battery, unified: true) == "/usr/bin/pmset -b powermode 1", "Low Power command changes only battery profile"),
            (PowerModeController.command(for: .automatic, profile: .adapter, unified: true) == "/usr/bin/pmset -c powermode 0", "Automatic command changes only adapter profile"),
            (PowerModeController.command(for: .high, profile: .adapter, unified: true) == "/usr/bin/pmset -c powermode 2", "High Power command uses unified setting"),
            (PowerModeController.command(for: .automatic, profile: .battery, unified: false, highPowerAvailable: false) == "/usr/bin/pmset -b lowpowermode 0", "legacy Automatic avoids unsupported High Power switch"),
            (BatteryIcon.colors(for: lowPowerBattery, appearance: appearance).progress == .systemYellow, "Low Power uses system yellow"),
            (BatteryIcon.colors(for: lowPowerCharging, appearance: appearance).progress == .systemYellow, "Low Power yellow takes precedence over charging green"),
            (lowPowerBattery.accessibilityLabel.contains("Low Power Mode"), "announces Low Power Mode to VoiceOver")
        ]

        // Exercise the real subscription callback using a local run-loop event. No
        // fabricated system-wide power notifications or charger changes are needed.
        var simulatedSource: CFRunLoopSource?
        var updates = 0
        let monitor = BatteryMonitor(sourceFactory: { callback, context in
            var sourceContext = CFRunLoopSourceContext()
            sourceContext.info = context
            sourceContext.perform = callback
            let source = CFRunLoopSourceCreate(nil, 0, &sourceContext)
            simulatedSource = source
            return source
        }) { _ in updates += 1 }
        do {
            try monitor.start()
            checks.append((updates == 1, "publishes initial battery state immediately"))
            try monitor.start()
            checks.append((updates == 1, "start is idempotent"))
            CFRunLoopSourceSignal(simulatedSource!)
            CFRunLoopRunInMode(.defaultMode, 0.05, false)
            checks.append((updates == 2, "run-loop notification refreshes state without a polling timer"))
            monitor.stop()
            checks.append((!CFRunLoopSourceIsValid(simulatedSource!), "stop invalidates notification source"))
            CFRunLoopSourceSignal(simulatedSource!)
            CFRunLoopRunInMode(.defaultMode, 0.05, false)
            checks.append((updates == 2, "stopped monitor does not deliver events"))
            try monitor.start()
            checks.append((updates == 3, "monitor restarts with a fresh reading"))
            NotificationCenter.default.post(name: .NSProcessInfoPowerStateDidChange, object: nil)
            checks.append((updates == 4, "power-mode notification refreshes the icon immediately"))
            monitor.stop()
            NotificationCenter.default.post(name: .NSProcessInfoPowerStateDidChange, object: nil)
            checks.append((updates == 4, "stop removes the power-mode observer"))
        } catch {
            monitor.stop()
            checks.append((false, "notification lifecycle: \(error.localizedDescription)"))
        }

        let states = [0, 9, 20, 52, 73, 100].map { BatteryState(percentage: $0, isCharging: false) }
            + [BatteryState(percentage: 52, isCharging: true), pluggedIn, .unavailable,
               lowPowerBattery, lowPowerCharging, highPower, highCharging, highPlugged,
               BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, isLowPowerMode: true)]
        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = NSAppearance(named: name)
            checks.append((BatteryIcon.image(for: highPower, appearance: appearance).tiffRepresentation != BatteryIcon.image(for: BatteryState(percentage: 52, isCharging: false), appearance: appearance).tiffRepresentation, "High Power differs from Automatic: \(name.rawValue)"))
            checks.append((
                BatteryIcon.image(for: pluggedIn, appearance: appearance).tiffRepresentation
                    != BatteryIcon.image(for: active, appearance: appearance).tiffRepresentation,
                "plug and lightning icons differ at the same battery percentage: \(name.rawValue)"
            ))
            for state in states {
                let context = "\(name.rawValue), \(state.accessibilityLabel)"
                let image = BatteryIcon.image(for: state, appearance: appearance)
                checks.append((image.tiffRepresentation?.isEmpty == false, "renders icon: \(context)"))
                let palette = BatteryIcon.colors(for: state, appearance: appearance)
                let surface = luminance(palette.surface)
                let number = luminance(palette.number)
                let contrast = (max(surface, number) + 0.05) / (min(surface, number) + 0.05)
                checks.append((contrast >= 4.5, "number contrast >= 4.5:1: \(context) (got \(contrast))"))
                let progress = luminance(palette.progress)
                let fillContrast = (max(progress, number) + 0.05) / (min(progress, number) + 0.05)
                checks.append((fillContrast >= 4.5, "number contrast over charge fill >= 4.5:1: \(context) (got \(fillContrast))"))
            }
        }

        for (passed, description) in checks where !passed {
            FileHandle.standardError.write(Data("FAIL: \(description)\n".utf8))
            return 1
        }

        print("PASS: \(checks.count) Inside Battery self-checks")
        return 0
    }

    private static func luminance(_ color: NSColor) -> CGFloat {
        let rgb = color.usingColorSpace(.sRGB)!
        func linear(_ value: CGFloat) -> CGFloat {
            value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(rgb.redComponent)
            + 0.7152 * linear(rgb.greenComponent)
            + 0.0722 * linear(rgb.blueComponent)
    }
}
