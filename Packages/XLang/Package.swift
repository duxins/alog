// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XLang",
    platforms: [.iOS("16")],
    products: [
        .library(
            name: "XLang",
            targets: ["XLang"]),
    ],
    targets: [
        .target(
            name: "XLang")
    ]
)
