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
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "IlluminateAuth", dependencies: [], path: "Sources/Auth"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
