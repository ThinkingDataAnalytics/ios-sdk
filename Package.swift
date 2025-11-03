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
            url: "http://10.27.249.150:8888/thinking-analytics/data-collector/client-sdk/thinkingdatacore-ios-sdk.git",
            branch: "dev"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ThinkingSDK",
            dependencies: [
                .product(name: "ThinkingDataCore", package: "thinkingdatacore-ios-sdk")
            ],
            path: "ThinkingSDK",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        )
    ]
)

