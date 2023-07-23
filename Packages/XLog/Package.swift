// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XLog",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "XLog",
            targets: ["XLog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "XLog",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        )
    ]
)
