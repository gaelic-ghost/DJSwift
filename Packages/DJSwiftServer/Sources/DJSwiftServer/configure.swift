import DJSwiftAPI
import Fluent
import FluentPostgresDriver
import Foundation
import OpenAPIVapor
import Redis
import SotoCore
import Vapor

func configure(_ app: Application) async throws {
    let settings = try ServerSettings.load(environment: app.environment)

    app.databases.use(try .postgres(url: settings.databaseURL), as: .psql)
    app.redis.configuration = try RedisConfiguration(url: settings.redisURL)
    app.migrations.add(CreateStation())

    let assetStorage = try configureAssetStorage(app)
    let handler = DJSwiftAPIHandler(
        application: app,
        redisNamespace: settings.redisNamespace,
        assetStorage: assetStorage
    )
    let transport = VaporTransport(routesBuilder: app)
    try handler.registerHandlers(on: transport)

    try routes(app)
}

struct ServerSettings: Sendable {
    let databaseURL: String
    let redisURL: String
    let redisNamespace: String

    static func load(environment: Environment) throws -> Self {
        let isTesting = environment == .testing
        let databaseName = isTesting ? "djswift_test" : "djswift_development"
        let localUser = Environment.get("PGUSER") ?? Environment.get("USER")
        guard let databaseURL = Environment.get("DATABASE_URL") ?? localUser.map({
            "postgres://\($0)@127.0.0.1/\(databaseName)?tlsmode=disable"
        }) else {
            throw Abort(
                .internalServerError,
                reason: "DJSwiftServer requires DATABASE_URL, or USER/PGUSER for its local Homebrew default."
            )
        }
        let redisURL = Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379/0"
        let namespace = Environment.get("REDIS_KEY_NAMESPACE")
            ?? (isTesting ? "djswift:test:\(UUID().uuidString)" : "djswift:development")

        if isTesting && !databaseURL.contains("djswift_test") {
            throw Abort(
                .internalServerError,
                reason: "DJSwiftServer refused to run tests because DATABASE_URL does not name djswift_test."
            )
        }
        if isTesting && !namespace.hasPrefix("djswift:test:") {
            throw Abort(
                .internalServerError,
                reason: "DJSwiftServer refused to run tests because REDIS_KEY_NAMESPACE is not test-scoped."
            )
        }

        return .init(databaseURL: databaseURL, redisURL: redisURL, redisNamespace: namespace)
    }
}
