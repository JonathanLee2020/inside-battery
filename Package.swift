// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "InsideBattery",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "InsideBattery", targets: ["InsideBattery"])
    ],
    targets: [
        .executableTarget(
            name: "InsideBattery",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "InsideBatteryTests",
            dependencies: ["InsideBattery"]
        )
    ]
)
