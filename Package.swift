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
            checksum: "55e87251a8affdf0bb81dc2b33070c53fb0c8149c3661d00ffdb2402749d7f23"
        )
    ]
)

