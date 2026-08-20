// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DJSwiftCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DJSwiftDomain", targets: ["DJSwiftDomain"]),
        .library(name: "DJSwiftUI", targets: ["DJSwiftUI"]),
    ],
    dependencies: [
        .package(path: "../DJSwiftAPI"),
    ],
    targets: [
        .target(
            name: "DJSwiftDomain",
            dependencies: [
                .product(name: "DJSwiftAPI", package: "DJSwiftAPI"),
            ]
        ),
        .target(
            name: "DJSwiftUI",
            dependencies: [
                .target(name: "DJSwiftDomain"),
            ]
        ),
        .testTarget(
            name: "DJSwiftDomainTests",
            dependencies: [
                .target(name: "DJSwiftDomain"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
