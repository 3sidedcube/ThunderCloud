// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThunderCloud",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ThunderCloud",
            targets: [
                "ThunderCloud"
            ]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/3sidedcube/ThunderBasics",
            branch: "release/v3.4.0"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderRequest",
            branch: "release/v3.4.0"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderTable",
            branch: "release/v2.4.0"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderCollection",
            branch: "release/v2.4.0"
        ),
        .package(
            url: "https://github.com/3sidedcube/Baymax",
            branch: "release/v2.4.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ThunderCloud",
            dependencies: [
                .target(name: "ThunderCloudSwift"),
                .target(name: "ThunderCloudObjC")
            ],
            path: "ThunderCloud"
        ),
        .target(
            name: "ThunderCloudSwift",
            dependencies: [
                .target(name: "ThunderCloudObjC"),
                "ThunderBasics",
                "ThunderRequest",
                "ThunderTable",
                "ThunderCollection",
                "Baymax"
            ],
            path: "ThunderCloudSwift"
        ),
        .target(
            name: "ThunderCloudObjC",
            path: "ThunderCloudObjC"
        ),
        .testTarget(
            name: "ThunderCloudTests",
            dependencies: ["ThunderCloudSwift"],
            path: "ThunderCloudTests"
        ),
    ]
)
