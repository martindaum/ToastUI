// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ToastUI",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ToastUI",
            targets: ["ToastUI"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ToastUI",
            dependencies: [])
    ]
)
