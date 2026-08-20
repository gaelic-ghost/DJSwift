@testable import DJSwiftServer
import DJSwiftAPI
import Fluent
import Foundation
import Testing
import VaporTesting

@Suite("DJSwift server", .serialized)
struct DJSwiftServerTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        var configured = false
        do {
            try await configure(app)
            configured = true
            try await app.autoMigrate()
            try await StationRecord.query(on: app.db).delete()
            try await test(app)
            try await StationRecord.query(on: app.db).delete()
        } catch {
            if configured {
                try? await StationRecord.query(on: app.db).delete()
            }
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test func healthUsesGeneratedContract() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "health") { response async throws in
                #expect(response.status == .ok)
                let health = try response.content.decode(Components.Schemas.Health.self)
                #expect(health.service == "DJSwiftServer")
            }
        }
    }

    @Test func listsAndFindsPersistedStations() async throws {
        try await withApp { app in
            try await StationRecord(
                slug: "gaelic-ghost-one",
                name: "Gaelic Ghost One",
                tagline: "Curated radio first."
            ).create(on: app.db)

            try await app.testing().test(.GET, "api/v1/stations") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(Components.Schemas.StationList.self)
                #expect(body.stations.map(\.id) == ["gaelic-ghost-one"])
            }

            try await app.testing().test(.GET, "api/v1/stations/gaelic-ghost-one") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(Components.Schemas.Station.self)
                #expect(body.name == "Gaelic Ghost One")
            }
        }
    }

    @Test func cachesManifestInsideTestNamespace() async throws {
        try await withApp { app in
            try await StationRecord(
                slug: "gaelic-ghost-one",
                name: "Gaelic Ghost One",
                tagline: "Curated radio first."
            ).create(on: app.db)

            try await app.testing().test(.GET, "api/v1/stations/gaelic-ghost-one/manifest") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(Components.Schemas.StationManifest.self)
                #expect(body.revision == 1)
            }
        }
    }

    @Test func assetStorageConfigurationFailsClosed() throws {
        let error = AssetStorageError.incompleteConfiguration
        #expect(error.description.contains("AWS_REGION"))
        #expect(error.description.contains("AWS_S3_ASSET_BUCKET"))
    }
}
