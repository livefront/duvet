// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "Duvet",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Duvet", targets: ["Duvet"]),
    ],
    targets: [
        .target(name: "Duvet", dependencies: [], path: "Duvet"),
    ]
)
