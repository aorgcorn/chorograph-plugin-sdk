// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChorographPluginSDK",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "ChorographPluginSDK",
            type: .dynamic,
            targets: ["ChorographPluginSDK"]
        ),
    ],
    targets: [
        .target(
            name: "ChorographPluginSDK",
            path: "Sources/ChorographPluginSDK"
        ),
    ]
)
