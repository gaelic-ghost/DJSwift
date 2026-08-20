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

        try await StationRecord(
            slug: "gaelic-ghost-one",
            name: "Gaelic Ghost One",
            tagline: "A bootstrap station placeholder for the first curated manifest."
        ).create(on: database)
    }

    func revert(on database: any Database) async throws {
        try await database.schema(StationRecord.schema).delete()
    }
}
