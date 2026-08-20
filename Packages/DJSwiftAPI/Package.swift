// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DJSwiftAPI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DJSwiftAPI", targets: ["DJSwiftAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
    ],
    targets: [
        .target(
            name: "DJSwiftAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ],
        ),
        .testTarget(name: "DJSwiftAPITests", dependencies: ["DJSwiftAPI"]),
    ],
    swiftLanguageModes: [.v6],
)
