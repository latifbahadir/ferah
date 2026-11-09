// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Ferah",
    defaultLocalization: "tr",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "FerahCore", targets: ["FerahCore"]),
        .executable(name: "ferah", targets: ["ferah"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
    ],
    targets: [
        .target(name: "FerahCore"),
        .executableTarget(
            name: "ferah",
            dependencies: [
                "FerahCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(name: "FerahCoreTests", dependencies: ["FerahCore"]),
    ]
)
