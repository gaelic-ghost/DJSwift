import DJSwiftAPI
import DJSwiftClient
import DJSwiftDomain
import Testing

@Test func mapsStationAcrossTransportBoundary() throws {
    let transport = Components.Schemas.Station(domain: .gaelicGhostOne)
    #expect(try transport.domain() == .gaelicGhostOne)
}

@Test func rejectsMalformedStationIdentity() {
    let transport = Components.Schemas.Station(
        id: "not-a-uuid",
        slug: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first."
    )

    #expect(throws: DJSwiftClientMappingError.invalidStationID("not-a-uuid")) {
        try transport.domain()
    }
}
