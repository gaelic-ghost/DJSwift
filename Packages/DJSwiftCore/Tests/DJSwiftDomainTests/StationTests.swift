@testable import DJSwiftDomain
import Testing

@Test func `domain station alias uses the generated representation`() {
    let station: Station = .gaelicGhostOne

    #expect(station.id == Station.gaelicGhostOneID.uuidString)
    #expect(station.slug == "gaelic-ghost-one")
}

@Test func `domain weekday accessors use generated integer cases`() {
    #expect(Weekday.sunday == ._1)
    #expect(Weekday.saturday == ._7)
}
