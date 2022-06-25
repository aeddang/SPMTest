// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPMTest",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SPMTest",
            targets: ["SPMTest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.9.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SPMTest",
            dependencies: ["Kingfisher", "SQLite.swift"]
        ),
        .testTarget(
            name: "SPMTestTests",
            dependencies: ["SPMTest"]),
    ]
)
