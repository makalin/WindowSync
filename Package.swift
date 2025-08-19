// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WindowSync",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "WindowSync",
            targets: ["WindowSync"]
        ),
        .library(
            name: "WindowSyncCore",
            targets: ["WindowSyncCore"]
        )
    ],
    dependencies: [
        // Dependencies go here
    ],
    targets: [
        .executableTarget(
            name: "WindowSync",
            dependencies: ["WindowSyncCore"],
            path: "WindowSync"
        ),
        .target(
            name: "WindowSyncCore",
            dependencies: [],
            path: "WindowSyncCore"
        ),
        .testTarget(
            name: "WindowSyncTests",
            dependencies: ["WindowSyncCore"],
            path: "Tests"
        )
    ]
)
