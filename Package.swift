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
            url: "https://github.com/Authing/authing-ios-sdk-v3/releases/download/1.0.1/Authing.xcframework.zip",
            checksum: "16552b2d9e4eeeaf50a672ee338bd2785a31bcfcf0bf7539c1f24b2ef73255f4"
        )
    ]
)

