// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDynamite",
    products: [
        .library(
            name: "SwiftDynamite",
            targets: ["SwiftDynamite"]
        )
    ],
    targets: [
        .target(
            name: "SwiftDynamite",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"])
            ]
        ),
        .testTarget(
            name: "SwiftDynamiteTests",
            dependencies: ["SwiftDynamite"]
        ),
    ]
)
