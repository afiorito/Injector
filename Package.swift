// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Injector",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
    ],
    products: [
        .library(
            name: "Injector",
            targets: ["Injector"]
        ),
    ],
    targets: [
        .target(
            name: "Injector",
            dependencies: []
        ),
        .testTarget(
            name: "InjectorTests",
            dependencies: ["Injector"]
        ),
    ]
)
