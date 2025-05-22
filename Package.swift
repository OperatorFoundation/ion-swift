// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ion",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Ion",
            targets: ["Ion"]),
    ],
    dependencies: [
        .package(url: "https://github.com/blanu/Swift-BigInt", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Transmission", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Ion",
            dependencies: [
              .product(name: "BigNumber", package: "Swift-BigInt"),

              "Datable",
              "SwiftHexTools",
              "Transmission",
            ]),
        .testTarget(
            name: "IonTests",
            dependencies: ["Ion"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
