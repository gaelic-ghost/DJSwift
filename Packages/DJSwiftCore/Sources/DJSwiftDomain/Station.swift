import Foundation

public struct Station: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let tagline: String

    public init(id: String, name: String, tagline: String) {
        self.id = id
        self.name = name
        self.tagline = tagline
    }

    public static let bootstrap = Station(
        id: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first. Creator-hosted stations next."
    )
}

public struct StationManifest: Hashable, Sendable {
    public let stationID: String
    public let revision: Int
    public let items: [ManifestItem]

    public init(stationID: String, revision: Int, items: [ManifestItem]) {
        self.stationID = stationID
        self.revision = revision
        self.items = items
    }
}

public struct ManifestItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let mediaURL: URL

    public init(id: String, title: String, mediaURL: URL) {
        self.id = id
        self.title = title
        self.mediaURL = mediaURL
    }
}
