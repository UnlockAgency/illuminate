// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "Auth", targets: ["Auth"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "Auth", dependencies: []),
        .testTarget(name: "AuthTests", dependencies: ["Auth"]),
    ],
    swiftLanguageVersions: [ .v5 ]
)
