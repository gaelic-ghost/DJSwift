import DJSwiftAPI
import DJSwiftDomain
@testable import DJSwiftServer
import Fluent
import Foundation
import Testing
import VaporTesting

@Suite(.serialized)
struct DJSwiftServerTests {
    @Test func `health uses generated contract`() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "health") { response async throws in
                #expect(response.status == .ok)
                let health = try response.content.decode(Components.Schemas.Health.self)
                #expect(health.service == "DJSwiftServer")
            }
        }
    }

    @Test func `lists and finds persisted stations`() async throws {
        try await withApp { app in
            try await StationRecord(
                id: Station.gaelicGhostOneID,
                slug: "gaelic-ghost-one",
                name: "Gaelic Ghost One",
                tagline: "Curated radio first.",
            ).create(on: app.db)

            try await app.testing().test(.GET, "api/v1/stations") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(StationList.self)
                #expect(body.stations.map(\.id) == [Station.gaelicGhostOne.id])
                #expect(body.stations.map(\.slug) == ["gaelic-ghost-one"])
            }

            try await app.testing().test(.GET, "api/v1/stations/gaelic-ghost-one") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(Station.self)
                #expect(body.name == "Gaelic Ghost One")
            }
        }
    }

    @Test func `caches manifest inside test namespace`() async throws {
        try await withApp { app in
            try await StationRecord(
                id: Station.gaelicGhostOneID,
                slug: "gaelic-ghost-one",
                name: "Gaelic Ghost One",
                tagline: "Curated radio first.",
            ).create(on: app.db)

            try await app.testing().test(.GET, "api/v1/stations/gaelic-ghost-one/manifest") { response async throws in
                #expect(response.status == .ok)
                let body = try response.content.decode(StationManifest.self)
                #expect(body.revision == 1)
            }
        }
    }

    @Test func `asset storage configuration fails closed`() {
        let error = AssetStorageError.incompleteConfiguration
        #expect(error.description.contains("AWS_REGION"))
        #expect(error.description.contains("AWS_S3_ASSET_BUCKET"))
    }

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
}
