import Foundation
import Darwin

final class PowerService: NSObject, PowerHelperProtocol {
    private let lock = NSLock()

    func checkConnection(reply: @escaping () -> Void) { reply() }

    func setPowerMode(_ value: Int, profile: String, reply: @escaping (String?) -> Void) {
        guard let mode = PowerMode(rawValue: value), let source = PowerProfile(rawValue: profile) else {
            reply("Invalid power mode or power source.")
            return
        }
        lock.lock()
        defer { lock.unlock() }
        do { try PowerModeController.apply(mode, profile: source); reply(nil) }
        catch { reply(error.localizedDescription) }
    }
}

final class ListenerDelegate: NSObject, NSXPCListenerDelegate {
    let service = PowerService()
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        // Only the active desktop user may switch modes; signature checks are also
        // enforced by NSXPCListener for every message, not by a reusable PID.
        var console = stat()
        guard stat("/dev/console", &console) == 0, console.st_uid != 0,
              connection.effectiveUserIdentifier == console.st_uid else { return false }
        connection.exportedInterface = NSXPCInterface(with: PowerHelperProtocol.self)
        connection.exportedObject = service
        connection.activate()
        return true
    }
}

do {
    guard let hash = Bundle.main.object(forInfoDictionaryKey: "InsideBatteryClientHash") as? String else {
        throw PowerModeController.PowerError.message("The helper has no embedded client signature hash.")
    }
    if CommandLine.arguments.contains("--print-client-requirement") {
        print(try PowerHelperIdentity.requirement(hash: hash))
        exit(0)
    }
    guard geteuid() == 0 else { throw PowerModeController.PowerError.message("Run this helper through macOS Service Management, not directly.") }
    let listener = NSXPCListener(machServiceName: PowerHelperIdentity.service)
    listener.setConnectionCodeSigningRequirement(try PowerHelperIdentity.requirement(hash: hash))
    let delegate = ListenerDelegate()
    listener.delegate = delegate
    listener.activate()
    withExtendedLifetime(delegate) { RunLoop.current.run() }
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    exit(1)
}
