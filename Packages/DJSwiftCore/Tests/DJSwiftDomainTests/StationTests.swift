import DJSwiftDomain
import Foundation
import Testing

@Test func curatedStationKeepsIdentitySeparateFromItsSlug() {
    #expect(Station.gaelicGhostOne.id.uuidString == "75BC1F76-62DF-4DE5-B9EF-8D15F50DE741")
    #expect(Station.gaelicGhostOne.slug == "gaelic-ghost-one")
}

@Test func scheduleRuleCapturesLocalRecurringTime() {
    let program = Program(
        id: UUID(),
        stationID: Station.gaelicGhostOne.id,
        name: "Night Signal",
        summary: "Late-night electronic programming."
    )
    let rule = ScheduleRule(
        id: UUID(),
        programID: program.id,
        timeZoneIdentifier: "America/New_York",
        weekdays: [.friday, .saturday],
        startMinuteOfDay: 22 * 60,
        durationMinutes: 120
    )

    #expect(rule.weekdays == [.friday, .saturday])
    #expect(rule.startMinuteOfDay == 1_320)
}

@Test func manifestSourceDistinguishesCatalogTracksFromOwnedAudio() {
    let track = ManifestSource.track(.init(provider: .appleMusic, catalogID: "catalog-track-id"))
    let asset = ManifestSource.audioAsset(.init(
        assetID: UUID(),
        mediaURL: URL(string: "https://assets.example.test/station-id.mp3")!
    ))

    #expect(track != asset)
}
