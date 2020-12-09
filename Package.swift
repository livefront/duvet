// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Duvet",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "Duvet", targets: ["Duvet"]),
    ],
    targets: [
        .target(name: "Duvet", dependencies: [], path: "Duvet"),
    ]
)
