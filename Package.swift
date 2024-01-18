// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-mastodon-text",
    products: [
        .library(name: "MastodonText", targets: ["MastodonText"]),
    ],
    targets: [
        .target(name: "MastodonText"),
    ]
)
