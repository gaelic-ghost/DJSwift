import DJSwiftDomain
import Fluent

struct CreateStation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(StationRecord.schema)
            .id()
            .field("slug", .string, .required)
            .field("name", .string, .required)
            .field("tagline", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "slug")
            .create()

        let station = Station.gaelicGhostOne
        try await StationRecord(
            id: Station.gaelicGhostOneID,
            slug: station.slug,
            name: station.name,
            tagline: station.tagline,
        ).create(on: database)
    }

    func revert(on database: any Database) async throws {
        try await database.schema(StationRecord.schema).delete()
    }
}
