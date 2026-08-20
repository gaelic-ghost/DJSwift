import Foundation
import DJSwiftAPI
import Testing

@Test func stationTransportRoundTrips() throws {
    let id = UUID()
    let station = Components.Schemas.Station(
        id: id.uuidString,
        slug: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first."
    )
    #expect(station.id == id.uuidString)
    #expect(station.slug == "gaelic-ghost-one")
}
