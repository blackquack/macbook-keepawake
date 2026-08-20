// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LidKeepAwake",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LidKeepAwake", targets: ["LidKeepAwakeApp"]),
        .executable(name: "LidKeepAwakeHelper", targets: ["LidKeepAwakeHelper"]),
        .executable(name: "LidKeepAwakeTests", targets: ["LidKeepAwakeTests"])
    ],
    targets: [
        .target(name: "Shared"),
        .executableTarget(
            name: "LidKeepAwakeApp",
            dependencies: ["Shared"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "LidKeepAwakeHelper",
            dependencies: ["Shared"],
            linkerSettings: [
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
