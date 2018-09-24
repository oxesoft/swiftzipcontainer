// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ZipContainer",
    products: [
        .library(
            name: "ZipContainer",
            targets: ["ZipContainer"]),
    ],
    targets: [
        .target(name: "ZipContainer")
    ]
)
