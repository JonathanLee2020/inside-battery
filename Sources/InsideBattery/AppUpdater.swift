import AppKit
import ServiceManagement
import Sparkle

@MainActor
final class AppUpdater: NSObject, SPUUpdaterDelegate {
    private(set) var controller: SPUStandardUpdaterController!
    private var observation: NSKeyValueObservation?
    private weak var menuItem: NSMenuItem?

    override init() {
        super.init()
        controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: self, userDriverDelegate: nil)
    }

    func start(menuItem: NSMenuItem) {
        self.menuItem = menuItem
        menuItem.target = controller
        menuItem.action = #selector(SPUStandardUpdaterController.checkForUpdates(_:))
        observation = controller.updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] updater, _ in
            MainActor.assumeIsolated { self?.menuItem?.isEnabled = updater.canCheckForUpdates }
        }
        controller.startUpdater()
    }

    func updater(_ updater: SPUUpdater, shouldProceedWithUpdate updateItem: SUAppcastItem, updateCheck: SPUUpdateCheck) throws {
        let service = SMAppService.daemon(plistName: PowerHelperIdentity.plist)
        let active = service.status == .enabled || service.status == .requiresApproval
        let installed = try String(contentsOf: Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/PowerHelperHash.txt"), encoding: .utf8)
        try Self.validateHelperUpdate(installedHash: installed,
                                     publishedHash: updateItem.propertiesDictionary["insidebattery:helperHash"] as? String,
                                     helperActive: active)
    }

    static func validateHelperUpdate(installedHash: String, publishedHash: String?, helperActive: Bool) throws {
        guard helperActive else { return }
        let installed = installedHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard installed.count == 40, installed.allSatisfy({ $0.isHexDigit }),
              let publishedHash, publishedHash == installed else {
            throw NSError(domain: "InsideBattery.Update", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "This update needs a power-helper upgrade.",
                NSLocalizedRecoverySuggestionErrorKey: "Install this version manually from GitHub or Homebrew to update the privileged helper. Your current app and power switching have not been changed."
            ])
        }
    }
}
