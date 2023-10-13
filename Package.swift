// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWXCTestCase",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SWXCTestCase",
            targets: ["SWXCTestCase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SWXCTestCase",
            dependencies: [
                .product(name: "Swifter", package: "swifter")
            ]
        ),
        .testTarget(
            name: "SWXCTestCaseTests",
            dependencies: [
                "SWXCTestCase"
            ]),
    ]
)
