import Foundation

public struct StationManifest: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let stationID: Station.ID
    public let revision: Int
    public let generatedAt: Date
    public let validFrom: Date
    public let validThrough: Date
    public let items: [ManifestItem]

    public init(
        id: UUID,
        stationID: Station.ID,
        revision: Int,
        generatedAt: Date,
        validFrom: Date,
        validThrough: Date,
        items: [ManifestItem]
    ) {
        self.id = id
        self.stationID = stationID
        self.revision = revision
        self.generatedAt = generatedAt
        self.validFrom = validFrom
        self.validThrough = validThrough
        self.items = items
    }
}

public struct ManifestItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let startsAt: Date
    public let durationSeconds: Int?
    public let source: ManifestSource

    public init(
        id: UUID,
        title: String,
        startsAt: Date,
        durationSeconds: Int?,
        source: ManifestSource
    ) {
        self.id = id
        self.title = title
        self.startsAt = startsAt
        self.durationSeconds = durationSeconds
        self.source = source
    }
}
