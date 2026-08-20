import DJSwiftAPI
import Testing

@Test func stationTransportRoundTrips() throws {
    let station = Components.Schemas.Station(
        id: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first."
    )
    #expect(station.id == "gaelic-ghost-one")
}
