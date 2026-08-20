// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "macbook-keepawake",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "macbook-keepawake", targets: ["LidKeepAwakeApp"]),
        .executable(name: "LidKeepAwakeTests", targets: ["LidKeepAwakeTests"])
    ],
    targets: [
        .target(
            name: "Shared",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "LidKeepAwakeApp",
            dependencies: ["Shared"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "LidKeepAwakeTests",
            dependencies: ["Shared"],
            path: "Tests"
        )
    ]
)
