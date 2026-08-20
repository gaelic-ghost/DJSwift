// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DJSwiftServer",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "DJSwiftServer", targets: ["DJSwiftServer"]),
    ],
    dependencies: [
        .package(path: "../DJSwiftAPI"),
        .package(path: "../DJSwiftCore"),
        .package(url: "https://github.com/vapor/vapor", from: "4.122.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.13.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.12.0"),
        .package(url: "https://github.com/vapor/redis", from: "4.14.0"),
        .package(url: "https://github.com/vapor/swift-openapi-vapor", from: "1.1.0"),
        .package(url: "https://github.com/soto-project/soto", from: "7.15.0"),
    ],
    targets: [
        .executableTarget(
            name: "DJSwiftServer",
            dependencies: [
                .product(name: "DJSwiftAPI", package: "DJSwiftAPI"),
                .product(name: "DJSwiftDomain", package: "DJSwiftCore"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Redis", package: "redis"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "Vapor", package: "vapor"),
            ],
        ),
        .testTarget(
            name: "DJSwiftServerTests",
            dependencies: [
                .target(name: "DJSwiftServer"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
