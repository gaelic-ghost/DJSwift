import DJSwiftAPI
import Foundation
import Testing

@Test func `station transport round trips`() throws {
    let station = Components.Schemas.Station(
        id: UUID().uuidString,
        slug: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first. Creator-hosted stations next.",
    )
    let encoded = try JSONEncoder().encode(station)
    let decoded = try JSONDecoder().decode(Components.Schemas.Station.self, from: encoded)

    #expect(decoded == station)
}

@Test func `programming models round trip from the open API contract`() throws {
    let program = Components.Schemas.Program(
        id: UUID().uuidString,
        stationId: UUID().uuidString,
        name: "Night Signal",
        summary: "Late-night electronic programming.",
    )
    let rule = Components.Schemas.ScheduleRule(
        id: UUID().uuidString,
        programId: program.id,
        timeZoneIdentifier: "America/New_York",
        weekdays: [._6, ._7],
        startMinuteOfDay: 22 * 60,
        durationMinutes: 120,
        priority: 0,
    )

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let decodedProgram = try decoder.decode(
        Components.Schemas.Program.self,
        from: encoder.encode(program),
    )
    let decoded = try decoder.decode(
        Components.Schemas.ScheduleRule.self,
        from: encoder.encode(rule),
    )

    #expect(decodedProgram == program)
    #expect(decoded == rule)
    #expect(decoded.programId == program.id)
}

@Test func `weekday uses calendar integer values`() throws {
    #expect(Components.Schemas.Weekday._1.rawValue == 1)
    #expect(Components.Schemas.Weekday._7.rawValue == 7)
    #expect(try String(decoding: JSONEncoder().encode(Components.Schemas.Weekday._1), as: UTF8.self) == "1")
}

@Test func `playback sources use generated provider and reference types`() throws {
    let track = Components.Schemas.TrackReference(
        kind: .track,
        provider: Components.Schemas.PlaybackProvider.appleMusic,
        catalogId: "catalog-track-id",
        market: "US",
    )
    let audioAsset = Components.Schemas.AudioAssetReference(
        kind: .audioAsset,
        assetId: UUID().uuidString,
        mediaUrl: "https://assets.example.test/station-id.mp3",
    )

    let trackSource = Components.Schemas.ManifestSource.TrackReference(track)
    let assetSource = Components.Schemas.ManifestSource.AudioAssetReference(audioAsset)

    #expect(try JSONDecoder().decode(Components.Schemas.ManifestSource.self, from: JSONEncoder().encode(trackSource)) == trackSource)
    #expect(try JSONDecoder().decode(Components.Schemas.ManifestSource.self, from: JSONEncoder().encode(assetSource)) == assetSource)
}

@Test func `manifest temporal instants round trip as foundation dates`() throws {
    let generatedAt = Date(timeIntervalSince1970: 1_700_000_000)
    let source = Components.Schemas.ManifestSource.TrackReference(.init(
        kind: .track,
        provider: .spotify,
        catalogId: "spotify-track-id",
    ))
    let manifest = Components.Schemas.StationManifest(
        id: UUID().uuidString,
        stationId: UUID().uuidString,
        revision: 1,
        generatedAt: generatedAt,
        validFrom: generatedAt,
        validThrough: generatedAt.addingTimeInterval(60 * 60),
        items: [
            Components.Schemas.ManifestItem(
                id: UUID().uuidString,
                title: "Station ID",
                startsAt: generatedAt,
                durationSeconds: 15,
                source: source,
            ),
        ],
    )
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let decoded = try decoder.decode(Components.Schemas.StationManifest.self, from: encoder.encode(manifest))
    let decodedGeneratedAt: Date = decoded.generatedAt
    let decodedStartsAt: Date = try #require(decoded.items.first).startsAt

    #expect(decoded == manifest)
    #expect(decodedGeneratedAt == generatedAt)
    #expect(decodedStartsAt == generatedAt)
}
