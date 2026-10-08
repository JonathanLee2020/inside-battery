import Foundation
import ServiceManagement

enum PowerHelperRegistration {
    // Create the service in this nonisolated context: Service Management's
    // unregister completion runs on a background dispatch queue.
    static func replace() async throws -> SMAppService.Status {
        let service = SMAppService.daemon(plistName: PowerHelperIdentity.plist)
        if service.status != .notRegistered && service.status != .notFound {
            // Apple's completion fires only after the old process is reaped;
            // the synchronous unregister API explicitly does not wait for that.
            try await service.unregister()
        }
        do {
            try service.register()
        } catch {
            guard service.status == .requiresApproval else { throw error }
        }
        return service.status
    }

    static func statusDescription(_ status: SMAppService.Status) -> String {
        switch status {
        case .enabled: "Enabled"
        case .requiresApproval: "Requires macOS approval in Login Items & Extensions"
        case .notRegistered: "Not registered"
        case .notFound: "Helper not found"
        @unknown default: "Unknown"
        }
    }
}
