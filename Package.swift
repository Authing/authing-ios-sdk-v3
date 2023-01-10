// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Authing",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_14), .iOS(.v11), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Authing",
            targets: ["Authing"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "Authing",
            url: "https://github.com/Authing/authing-ios-sdk-v3/releases/download/1.0.0/Authing.xcframework.zip",
            checksum: "a5606e64d470eef06771fae771892e44de0e1dd589039411caaa600fc9ec8e57"
        )
    ]
)

