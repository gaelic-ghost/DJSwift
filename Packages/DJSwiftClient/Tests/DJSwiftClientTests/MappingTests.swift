import DJSwiftAPI
import DJSwiftClient
import DJSwiftDomain
import Testing

@Test func mapsStationAcrossTransportBoundary() {
    let transport = Components.Schemas.Station(domain: .bootstrap)
    #expect(transport.domain == .bootstrap)
}
