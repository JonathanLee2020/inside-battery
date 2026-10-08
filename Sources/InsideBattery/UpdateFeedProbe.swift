import Foundation
import Sparkle

/// Information-only diagnostic: never downloads or installs an update.
@MainActor
final class UpdateFeedProbe: NSObject, SPUUpdaterDelegate {
    private var loaded = false
    private var completed = false
    private var failure: Error?

    func run() -> Int32 {
        let controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: self, userDriverDelegate: nil)
        do { try controller.updater.start() }
        catch { print("FAIL: \(error.localizedDescription)"); return 1 }
        controller.updater.checkForUpdateInformation()
        let deadline = Date().addingTimeInterval(20)
        while !completed && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
        guard completed, loaded else {
            print("FAIL: \(failure?.localizedDescription ?? "No verified feed response before timeout")")
            return 1
        }
        print("PASS: Sparkle downloaded and parsed the signed feed; no installation attempted")
        return 0
    }

    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        loaded = true
        for item in appcast.items {
            print("Feed item: \(item.displayVersionString), helper=\(item.propertiesDictionary["insidebattery:helperHash"] ?? "missing")")
        }
    }

    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: Error?) {
        failure = error
        completed = true
    }
}
