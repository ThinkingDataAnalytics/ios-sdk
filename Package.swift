// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThinkingSDK",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ThinkingSDK",
            targets: ["ThinkingSDK"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ThinkingDataAnalytics/thinkingdatacore-ios-sdk.git",
            exact: "1.3.6"
        )
    ],
    targets: [
        .target(
            name: "ThinkingSDK",
            dependencies: [
                .product(name: "ThinkingDataCore", package: "thinkingdatacore-ios-sdk")
            ],
            path: "ThinkingSDK",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")],
            // Keep quoted imports (`#import "Foo.h"`) working after nesting
            // public headers under include/ThinkingSDK/.
            cSettings: [
                .headerSearchPath("include/ThinkingSDK")
            ],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedLibrary("z"),
            ]
        )
    ]
)
