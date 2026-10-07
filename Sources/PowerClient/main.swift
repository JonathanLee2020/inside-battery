import Foundation
import Darwin

final class Reply: @unchecked Sendable {
    let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var finished = false
    private var failure: PowerModeController.PowerError?
    func finish(_ error: String?, connectionFailure: Bool = false) {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return }
        finished = true
        if let error {
            failure = connectionFailure ? .helperUnavailable(error) : .message(error)
        }
        semaphore.signal()
    }
    func result() -> PowerModeController.PowerError? { lock.lock(); defer { lock.unlock() }; return failure }
}

// Top-level Swift 6 code is main-actor isolated. XPC invokes callbacks on its
// own queues, so create them in a nonisolated function instead of inheriting
// the main actor and crashing at the callback's executor check.
enum PowerClient {
nonisolated static func run() throws {
    let args = CommandLine.arguments
    guard args.count == 3, let value = Int(args[1]), let mode = PowerMode(rawValue: value),
          let profile = PowerProfile(rawValue: args[2]) else {
        throw PowerModeController.PowerError.message("Usage: InsideBatteryPowerClient 0|1|2 'Battery Power'|'AC Power'")
    }
    let path = URL(fileURLWithPath: args[0]).deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("Resources/PowerHelperHash.txt")
    let hash = try String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    let connection = NSXPCConnection(machServiceName: PowerHelperIdentity.service, options: .privileged)
    connection.setCodeSigningRequirement(try PowerHelperIdentity.requirement(hash: hash))
    connection.remoteObjectInterface = NSXPCInterface(with: PowerHelperProtocol.self)
    let result = Reply()
    connection.invalidationHandler = { result.finish("Quick switching could not connect to the registered helper. Choose Repair Quick Power Switching, then approve it in Login Items if macOS asks.", connectionFailure: true) }
    connection.interruptionHandler = { result.finish("The power helper disconnected. Choose Repair Quick Power Switching if it continues.", connectionFailure: true) }
    connection.activate()
    defer { connection.invalidate() }
    guard let proxy = connection.remoteObjectProxyWithErrorHandler({ result.finish("\($0.localizedDescription) Choose Repair Quick Power Switching to register this build's helper.", connectionFailure: true) }) as? PowerHelperProtocol else {
        throw PowerModeController.PowerError.helperUnavailable("Could not connect to the power helper. Choose Repair Quick Power Switching.")
    }
    proxy.setPowerMode(mode.rawValue, profile: profile.rawValue) { result.finish($0) }
    guard result.semaphore.wait(timeout: .now() + 15) == .success else {
        throw PowerModeController.PowerError.helperUnavailable("Power helper did not respond within 15 seconds. Choose Repair Quick Power Switching and check its approval in Login Items.")
    }
    if let error = result.result() { throw error }
}
}

do {
    try PowerClient.run()
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    if case PowerModeController.PowerError.helperUnavailable = error { exit(2) }
    exit(1)
}
