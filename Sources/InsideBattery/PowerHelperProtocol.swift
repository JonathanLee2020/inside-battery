import Foundation

enum PowerHelperIdentity {
    static let service = "com.insidebattery.power-helper"
    static let plist = service + ".plist"

    static func requirement(hash: String) throws -> String {
        guard hash.count == 40, hash.allSatisfy({ $0.isHexDigit && $0.isASCII }) else {
            throw PowerModeController.PowerError.message("Invalid helper signature hash. Rebuild the app.")
        }
        return "cdhash H\"\(hash)\""
    }
}

@objc protocol PowerHelperProtocol {
    func setPowerMode(_ mode: Int, profile: String, reply: @escaping (String?) -> Void)
}
