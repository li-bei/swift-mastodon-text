// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-mastodon-text",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(name: "MastodonText", targets: ["MastodonText"]),
    ],
    targets: [
        .target(name: "MastodonText", swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
    ]
)
