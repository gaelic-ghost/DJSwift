// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DJSwiftClient",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DJSwiftClient", targets: ["DJSwiftClient"]),
    ],
    dependencies: [
        .package(path: "../DJSwiftAPI"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
    ],
    targets: [
        .target(
            name: "DJSwiftClient",
            dependencies: [
                .product(name: "DJSwiftAPI", package: "DJSwiftAPI"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
