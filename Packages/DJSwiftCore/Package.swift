// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DJSwiftCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DJSwiftDomain", targets: ["DJSwiftDomain"]),
        .library(name: "DJSwiftUI", targets: ["DJSwiftUI"]),
    ],
    targets: [
        .target(name: "DJSwiftDomain"),
        .target(name: "DJSwiftUI", dependencies: ["DJSwiftDomain"]),
        .testTarget(name: "DJSwiftDomainTests", dependencies: ["DJSwiftDomain"]),
    ],
    swiftLanguageModes: [.v6]
)
