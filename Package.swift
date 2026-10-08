// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "InsideBattery",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "InsideBattery", targets: ["InsideBattery"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0")
    ],
    targets: [
        .executableTarget(
            name: "InsideBattery",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement"),
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        ),
        .testTarget(
            name: "InsideBatteryTests",
            dependencies: ["InsideBattery"]
        )
    ]
)
