import DJSwiftAPI
import Foundation

public typealias Station = Components.Schemas.Station
public typealias StationList = Components.Schemas.StationList

public extension Station {
    static let gaelicGhostOneID = UUID(uuidString: "75bc1f76-62df-4de5-b9ef-8d15f50de741")!

    static let gaelicGhostOne = Self(
        id: gaelicGhostOneID.uuidString,
        slug: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first. Creator-hosted stations next.",
    )
}
