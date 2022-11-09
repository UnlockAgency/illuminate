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
        .library(name: "IlluminateCache", targets: ["IlluminateCache"]),
        .library(name: "IlluminateCodable", targets: ["IlluminateCodable"]),
        .library(name: "IlluminateCombine", targets: ["IlluminateCombine"]),
        .library(name: "IlluminateCoordination", targets: ["IlluminateCoordination"]),
        .library(name: "IlluminateFoundation", targets: ["IlluminateFoundation"]),
        .library(name: "IlluminateRouting", targets: ["IlluminateRouting"]),
        .library(name: "IlluminateSecurity", targets: ["IlluminateSecurity"]),
        .library(name: "IlluminateUI_Assets", targets: ["IlluminateUI_Assets"]),
        .library(name: "IlluminateUI_Helpers", targets: ["IlluminateUI_Helpers"]),
        .library(name: "IlluminateUI_Module", targets: ["IlluminateUI_Module"]),
        .library(name: "IlluminateSupport", targets: ["IlluminateSupport"]),
        .library(name: "IlluminateInjection", targets: ["IlluminateInjection"]),
        .library(name: "IlluminateKeychain", targets: ["IlluminateKeychain"]),
        .library(name: "IlluminatePermissions", targets: ["IlluminatePermissions"]),
        .library(name: "IlluminateNotifications", targets: ["IlluminateNotifications"]),
        .library(name: "IlluminateBackgroundProcess", targets: ["IlluminateBackgroundProcess"]),
    ],
    dependencies: [
        .package(url: "https://github.com/e-sites/Dysprosium.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", .upToNextMajor(from: "0.1.3")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.4")),
        .package(url: "https://github.com/Swinject/Swinject.git", .upToNextMajor(from: "2.8.2")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "4.2.2")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        .target(name: "IlluminateAuth", dependencies: [], path: "Sources/Auth"),
        .target(name: "IlluminateCache", dependencies: [], path: "Sources/Cache"),
        .target(name: "IlluminateCodable", dependencies: [], path: "Sources/Codable"),
        .target(name: "IlluminateCombine", dependencies: [], path: "Sources/Combine"),
        .target(name: "IlluminateCoordination", dependencies: [ "Dysprosium" ], path: "Sources/Coordination"),
        .target(name: "IlluminateFoundation", dependencies: [], path: "Sources/Foundation"),
        .target(name: "IlluminateRouting", dependencies: [], path: "Sources/Routing"),
        .target(name: "IlluminateSecurity", dependencies: [], path: "Sources/Security"),
        .target(name: "IlluminateUI_Helpers", dependencies: [
            .byName(name: "IlluminateFoundation"),
            .byName(name: "IlluminateCombine"),
            .byName(name: "Dysprosium"),
            .product(name: "Introspect", package: "SwiftUI-Introspect")
        ], path: "Sources/UI/Helpers"),
        .target(name: "IlluminateUI_Assets", path: "Sources/UI/Assets"),
        .target(name: "IlluminateUI_Module", dependencies: [ "IlluminateUI_Assets" ], path: "Sources/UI/Module"),
        .target(name: "IlluminateSupport", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ], path: "Sources/Support"),
        .target(name: "IlluminateInjection", dependencies: [
            .byName(name: "Swinject"),
        ], path: "Sources/Injection"),
        .target(name: "IlluminateKeychain", dependencies: [
            .byName(name: "KeychainAccess"),
            .byName(name: "IlluminateInjection"),
        ], path: "Sources/Keychain"),
        .target(name: "IlluminatePermissions", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ], path: "Sources/Permissions"),
        .target(name: "IlluminateNotifications", dependencies: [
            .byName(name: "IlluminateInjection"),
            .byName(name: "IlluminateFoundation"),
            .byName(name: "IlluminateSupport"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
        ], path: "Sources/Notifications"),
        .target(name: "IlluminateBackgroundProcess", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ], path: "Sources/BackgroundProcess"),
        
        // ---
        
        .testTarget(name: "CodableTests", dependencies: [
            .byName(name: "Nimble"),
            .byName(name: "IlluminateCodable")
        ], path: "Tests/CodableTests"),
        .testTarget(name: "InjectionTests", dependencies: [
            .byName(name: "Nimble"),
            .byName(name: "Swinject"),
            .byName(name: "IlluminateInjection")
        ], path: "Tests/InjectionTests"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
