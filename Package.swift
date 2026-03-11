// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChorographPluginSDK",
    platforms: [.macOS(.v14)],
    products: [
        // Must be .dynamic so the host app and plugin bundles share a single copy
        // of the SDK types at runtime. Without this each binary embeds its own
        // static copy and Swift type identity checks across the dlopen boundary
        // (e.g. `as? any ChorographPlugin`) always fail.
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
