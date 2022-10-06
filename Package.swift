// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Illuminate",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "IlluminateAuth", targets: ["IlluminateAuth"]),
        .library(name: "IlluminateRouting", targets: ["IlluminateRouting"]),
        .library(name: "IlluminateCoordination", targets: ["IlluminateCoordination"]),
        .library(name: "IlluminateCodable", targets: ["IlluminateCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/e-sites/Dysprosium.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0")),
    ],
    targets: [
        .target(name: "IlluminateAuth", dependencies: [], path: "Sources/Auth"),
        .target(name: "IlluminateRouting", dependencies: [], path: "Sources/Routing"),
        .target(name: "IlluminateCoordination", dependencies: [ "Dysprosium" ], path: "Sources/Coordination"),
        .target(name: "IlluminateCodable", dependencies: [ ], path: "Sources/Codable"),
        .testTarget(name: "CodableTests", dependencies: [
            .byName(name: "Nimble"),
            .byName(name: "IlluminateCodable")
        ], path: "Tests/CodableTests"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
