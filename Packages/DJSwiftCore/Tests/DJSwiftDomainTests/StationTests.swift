import Testing
@testable import DJSwiftDomain

@Test func domainStationAliasUsesTheGeneratedRepresentation() {
    let station: Station = .gaelicGhostOne

    #expect(station.id == Station.gaelicGhostOneID.uuidString)
    #expect(station.slug == "gaelic-ghost-one")
}

@Test func domainWeekdayAccessorsUseGeneratedIntegerCases() {
    #expect(Weekday.sunday == ._1)
    #expect(Weekday.saturday == ._7)
}
