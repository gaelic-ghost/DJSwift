import Foundation

public struct Station: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let slug: String
    public let name: String
    public let tagline: String

    public init(id: UUID, slug: String, name: String, tagline: String) {
        self.id = id
        self.slug = slug
        self.name = name
        self.tagline = tagline
    }

    public static let gaelicGhostOne = Station(
        id: UUID(uuidString: "75bc1f76-62df-4de5-b9ef-8d15f50de741")!,
        slug: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first. Creator-hosted stations next."
    )
}
