import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var monitor: BatteryMonitor?
    private var currentState = BatteryState.unavailable
    private var modeItems: [PowerMode: NSMenuItem] = [:]
    private var modeHeading: NSMenuItem?
    private var changingMode = false
    private var helperNeedsRepair = false
    private var configuringHelper = false
    private let powerHelper = SMAppService.daemon(plistName: PowerHelperIdentity.plist)
    private let appUpdater = AppUpdater()
    private var checkUpdatesItem: NSMenuItem?
    private var helperItem: NSMenuItem?
    private var activeMode: PowerMode?
    private var modeProfile: PowerProfile?
    private var modeRevision = 0
    private var batteryItem: NSMenuItem?
    private var energyHeading: NSMenuItem?
    private var energyRows: [NSMenuItem] = []
    private var energyRevision = 0
    private var energyTask: Task<Void, Never>?
    private var energyTimeoutTask: Task<Void, Never>?
    private let showTimeUntilFullKey = "showTimeUntilFull"
    private var showTimeUntilFull: Bool {
        UserDefaults.standard.object(forKey: showTimeUntilFullKey) as? Bool ?? true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMenu()
        if let checkUpdatesItem { appUpdater.start(menuItem: checkUpdatesItem) }
        monitor = BatteryMonitor { [weak self] state in
            self?.update(state)
        }
        do {
            try monitor?.start()
        } catch {
            NSAlert(error: error).runModal()
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor?.stop()
        energyTask?.cancel()
        energyTimeoutTask?.cancel()
    }

    private func configureMenu() {
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.toolTip = "Inside Battery"

        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        let batteryItem = NSMenuItem(title: "Battery unavailable", action: nil, keyEquivalent: "")
        self.batteryItem = batteryItem
        batteryItem.view = BatteryMenu.header(for: currentState, showTimeUntilFull: showTimeUntilFull)
        batteryItem.isEnabled = false
        menu.addItem(batteryItem)
        menu.addItem(.separator())

        let heading = NSMenuItem(title: "Energy Mode", action: nil, keyEquivalent: "")
        heading.attributedTitle = NSAttributedString(string: "Energy Mode", attributes: [.font: NSFont.systemFont(ofSize: 13, weight: .semibold)])
        heading.isEnabled = false
        modeHeading = heading
        menu.addItem(heading)
        for mode in [PowerMode.automatic, .low, .high] {
            let item = NSMenuItem(title: mode.title, action: #selector(selectPowerMode(_:)), keyEquivalent: "")
            item.target = self
            item.tag = mode.rawValue
            item.image = BatteryMenu.modeImage(mode, selected: false, appearance: statusItem.button?.effectiveAppearance)
            item.view = EnergyModeRow(item: item)
            if mode == .high { item.toolTip = "Available on Macs that support High Power Mode." }
            modeItems[mode] = item
            menu.addItem(item)
        }
        let helper = NSMenuItem(title: "Enable Quick Power Switching…", action: #selector(configurePowerHelper), keyEquivalent: "")
        helper.target = self
        helperItem = helper
        menu.addItem(helper)
        menu.addItem(.separator())

        let energyHeading = NSMenuItem(title: "Apps Using Significant Energy", action: nil, keyEquivalent: "")
        energyHeading.isEnabled = false
        energyHeading.toolTip = "Experimental: Apple's native energy list. Energy impact is not a battery percentage."
        self.energyHeading = energyHeading
        menu.addItem(energyHeading)
        addEnergyStatus("Open the menu to check", to: menu)
        menu.addItem(.separator())
        let settingsItem = NSMenuItem(title: "Battery Settings…", action: #selector(openBatterySettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let appMenu = NSMenu()
        let appItem = NSMenuItem(title: "Inside Battery", action: nil, keyEquivalent: "")
        appItem.submenu = appMenu
        menu.addItem(appItem)

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        appMenu.addItem(launchItem)

        let estimateItem = NSMenuItem(title: "Show Time Until Fully Charged", action: #selector(toggleTimeUntilFull(_:)), keyEquivalent: "")
        estimateItem.target = self
        estimateItem.state = showTimeUntilFull ? .on : .off
        appMenu.addItem(estimateItem)

        let updatesItem = NSMenuItem(title: "Check for Updates…", action: nil, keyEquivalent: "")
        updatesItem.isEnabled = false
        checkUpdatesItem = updatesItem
        appMenu.addItem(.separator())
        appMenu.addItem(updatesItem)

        let quitItem = NSMenuItem(title: "Quit Inside Battery", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(.separator())
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func update(_ state: BatteryState) {
        let profile: PowerProfile = state.isExternalPowerConnected ? .adapter : .battery
        if modeProfile != profile {
            activeMode = nil
            modeProfile = profile
        }
        display(state.withHighPowerMode(activeMode == .high))
        // Draw cable changes immediately. Reading preferences must not block the
        // IOKit callback or reintroduce the charger-response delay.
        modeRevision += 1
        let revision = modeRevision
        Task {
            let result = await Task.detached {
                Result { try PowerModeController.readPreferences().mode(for: profile) }
            }.value
            guard revision == modeRevision else { return }
            switch result {
            case .success(let mode): activeMode = mode
            case .failure: activeMode = nil // Unknown must not remain labelled High.
            }
            display(currentState.withHighPowerMode(activeMode == .high))
        }
    }

    private func display(_ state: BatteryState) {
        currentState = state
        let appearance = statusItem.button?.effectiveAppearance ?? NSApp.effectiveAppearance
        statusItem.button?.image = BatteryIcon.image(for: state, appearance: appearance)
        statusItem.button?.setAccessibilityLabel(state.accessibilityLabel)
        batteryItem?.title = state.accessibilityLabel
        batteryItem?.view = BatteryMenu.header(for: state, showTimeUntilFull: showTimeUntilFull)
        for (mode, item) in modeItems {
            item.image = BatteryMenu.modeImage(mode, selected: activeMode == mode, appearance: appearance)
            item.setAccessibilityValue(activeMode == mode ? "Selected" : "Not selected")
            (item.view as? EnergyModeRow)?.refresh()
        }
    }

    @objc private func toggleTimeUntilFull(_ sender: NSMenuItem) {
        let enabled = !showTimeUntilFull
        UserDefaults.standard.set(enabled, forKey: showTimeUntilFullKey)
        sender.state = enabled ? .on : .off
        display(currentState)
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        refreshEnergySection(menu)
        monitor?.refresh()
        refreshPowerModeSection()
    }

    private func refreshPowerModeSection() {
        switch powerHelper.status {
        case .enabled: helperItem?.title = "Repair Quick Power Switching…"
        case .requiresApproval: helperItem?.title = "Approve Quick Power Switching…"
        default: helperItem?.title = "Enable Quick Power Switching…"
        }
        helperItem?.isHidden = powerHelper.status == .enabled && !helperNeedsRepair && !configuringHelper
        helperItem?.isEnabled = !configuringHelper
        if configuringHelper { helperItem?.title = "Setting Up Quick Power Switching…" }
        let profile: PowerProfile = currentState.isExternalPowerConnected ? .adapter : .battery
        modeHeading?.toolTip = "Energy mode — \(profile.title)"
        do {
            let preferences = try PowerModeController.readPreferences()
            let selected = preferences.mode(for: profile)
            activeMode = selected
            modeProfile = profile
            display(currentState.withHighPowerMode(selected == .high))
            for (mode, item) in modeItems {
                item.state = .off
                item.image = BatteryMenu.modeImage(mode, selected: selected == mode, appearance: statusItem.button?.effectiveAppearance)
                item.setAccessibilityValue(selected == mode ? "Selected" : "Not selected")
                // Keep rows visually stable during a mode change. The action's
                // changingMode guard serializes requests without dimming them.
                item.isEnabled = !configuringHelper && !helperNeedsRepair && currentState.isPresent && powerHelper.status == .enabled
                    && (mode != .high || PowerModeController.usesUnifiedMode || preferences.profiles[profile]?["highpowermode"] != nil)
                (item.view as? EnergyModeRow)?.refresh()
            }
        } catch {
            modeHeading?.toolTip = error.localizedDescription
            for (mode, item) in modeItems { item.isEnabled = false; item.state = .off; item.image = BatteryMenu.modeImage(mode, selected: false, appearance: statusItem.button?.effectiveAppearance); item.setAccessibilityValue("Unavailable") }
            for item in modeItems.values { (item.view as? EnergyModeRow)?.refresh() }
        }
    }

    private func addEnergyStatus(_ text: String, to menu: NSMenu, detail: String? = nil) {
        // Status replaces the heading itself. An empty result is exactly one
        // visible row, not a heading plus a separate empty-state child.
        energyHeading?.title = text
        energyHeading?.toolTip = detail
        energyHeading?.isHidden = false
    }

    private func clearEnergyRows(_ menu: NSMenu) {
        for item in energyRows { menu.removeItem(item) }
        energyRows.removeAll()
        energyHeading?.title = "Apps Using Significant Energy"
        energyHeading?.isHidden = false
    }

    private func refreshEnergySection(_ menu: NSMenu) {
        // At most one native request at a time. No polling while the menu is closed.
        guard energyTask == nil else { return }
        clearEnergyRows(menu)
        addEnergyStatus("Checking…", to: menu)
        energyRevision += 1
        let revision = energyRevision
        energyTimeoutTask = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(10)) } catch { return }
            guard let self, revision == self.energyRevision, self.energyTask != nil else { return }
            self.clearEnergyRows(menu)
            self.addEnergyStatus("Energy data unavailable", to: menu,
                detail: "macOS's energy service did not respond within 10 seconds. The battery display is still active. Try reopening the menu later.")
        }
        energyTask = Task { [weak self] in
            let result = await Task.detached(priority: .utility) { Result { try NativeEnergy.read() } }.value
            guard let self, !Task.isCancelled, revision == self.energyRevision else { return }
            self.energyTimeoutTask?.cancel()
            self.energyTimeoutTask = nil
            self.clearEnergyRows(menu)
            switch result {
            case .success(let apps):
                if apps.isEmpty {
                    self.addEnergyStatus("No Apps Using Significant Energy", to: menu)
                }
                for app in apps {
                    let name = NSRunningApplication.runningApplications(withBundleIdentifier: app.bundleIdentifier).first?.localizedName ?? app.name
                    let item = NSMenuItem(title: name, action: #selector(self.openEnergyApp(_:)), keyEquivalent: "")
                    item.target = self
                    item.indentationLevel = 1
                    item.representedObject = app
                    item.toolTip = "Show \(app.name) in Activity Monitor's Energy tab"
                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
                        let icon = NSWorkspace.shared.icon(forFile: url.path)
                        icon.size = NSSize(width: 16, height: 16)
                        item.image = icon
                    }
                    if let heading = self.energyHeading {
                        menu.insertItem(item, at: menu.index(of: heading) + 1 + self.energyRows.count)
                        self.energyRows.append(item)
                    }
                }
            case .failure(let error):
                self.addEnergyStatus("Energy data unavailable", to: menu, detail: error.localizedDescription)
            }
            self.energyTask = nil
        }
    }

    @objc private func openEnergyApp(_ sender: NSMenuItem) {
        guard let app = sender.representedObject as? EnergyApp else { return }
        do {
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ActivityMonitor") else {
                throw NativeEnergy.EnergyError.unavailable("Activity Monitor could not be found in Applications → Utilities.")
            }
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            configuration.appleEvent = try NativeEnergy.selectionEvent(for: app)
            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
                if let error { Task { @MainActor in NSAlert(error: error).runModal() } }
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @objc private func selectPowerMode(_ sender: NSMenuItem) {
        guard let mode = PowerMode(rawValue: sender.tag), !changingMode else { return }
        // Re-read cable state when clicked; battery and adapter preferences are independent.
        monitor?.refresh()
        let profile: PowerProfile = currentState.isExternalPowerConnected ? .adapter : .battery
        changingMode = true
        refreshPowerModeSection()
        DispatchQueue.global(qos: .userInitiated).async {
            let result = Result { try PowerModeController.set(mode, profile: profile) }
            // Deliver completion during AppKit menu tracking, not only once
            // the user closes the menu and the default run loop resumes.
            RunLoop.main.perform(inModes: [.default, .eventTracking]) { [weak self] in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.changingMode = false
                    switch result {
                    case .success:
                        self.modeProfile = nil
                        self.monitor?.refresh()
                    case .failure(let error):
                        if case PowerModeController.PowerError.helperUnavailable = error {
                            self.helperNeedsRepair = true
                        }
                        self.statusItem.menu?.cancelTracking()
                        let alert = NSAlert(error: error)
                        alert.messageText = "Could not change power mode"
                        alert.runModal()
                    }
                    self.refreshPowerModeSection()
                }
            }
        }
    }

    @objc private func configurePowerHelper() {
        guard !configuringHelper else { return }
        guard powerHelper.status != .enabled || helperNeedsRepair else { return }
        if powerHelper.status == .requiresApproval && !helperNeedsRepair {
            SMAppService.openSystemSettingsLoginItems()
            return
        }
        let alert = NSAlert()
        alert.messageText = helperNeedsRepair ? "Repair quick power switching?" : "Enable quick power switching?"
        alert.informativeText = "Register the helper from this copy of Inside Battery. macOS may ask for approval in Login Items & Extensions. No password is saved."
        alert.addButton(withTitle: helperNeedsRepair ? "Repair" : "Enable")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        configuringHelper = true
        Task {
            defer { configuringHelper = false }
            do {
                let status = try await PowerHelperRegistration.replace()
                if status == .requiresApproval {
                    helperNeedsRepair = false
                    SMAppService.openSystemSettingsLoginItems()
                    return
                }
                guard status == .enabled else {
                    throw PowerModeController.PowerError.helperUnavailable("Helper registration ended in state: \(PowerHelperRegistration.statusDescription(status)).")
                }
                try await Task.detached { try PowerModeController.checkHelperConnection() }.value
                helperNeedsRepair = false
            } catch {
                helperNeedsRepair = true
                let alert = NSAlert(error: error)
                alert.messageText = "Quick switching setup did not complete"
                alert.runModal()
            }
        }
    }

    @objc private func openBatterySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension")!
        if !NSWorkspace.shared.open(url) {
            let alert = NSAlert()
            alert.messageText = "Could not open Battery Settings"
            alert.informativeText = "Open System Settings and select Battery in the sidebar."
            alert.runModal()
        }
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                sender.state = .off
            } else {
                try SMAppService.mainApp.register()
                sender.state = .on
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.messageText = "Could not change launch-at-login setting"
            alert.runModal()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
