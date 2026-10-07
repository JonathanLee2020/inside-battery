import Foundation
import Darwin

typealias Query = @convention(c) (Int, Int, Double) -> Unmanaged<CFDictionary>?
guard let library = dlopen("/usr/lib/libsystemstats.dylib", RTLD_NOW | RTLD_LOCAL),
      let symbol = dlsym(library, "systemstats_get_top_coalitions") else {
    print("Native energy query unavailable")
    exit(1)
}
let query = unsafeBitCast(symbol, to: Query.self)
// ABI verified against this Mac's Control Center and libsystemstats call sites.
if let result = query(120, 5, 120 * 500) {
    print(result.takeUnretainedValue())
} else {
    print("Native query returned nil (not an empty app list)")
    exit(1)
}
