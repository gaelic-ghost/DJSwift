import Foundation

public enum PlaybackProvider: String, CaseIterable, Hashable, Sendable {
    case appleMusic
    case spotify
}

public struct TrackReference: Hashable, Sendable {
    public let provider: PlaybackProvider
    public let catalogID: String
    public let market: String?

    public init(provider: PlaybackProvider, catalogID: String, market: String? = nil) {
        self.provider = provider
        self.catalogID = catalogID
        self.market = market
    }
}

public struct AudioAssetReference: Hashable, Sendable {
    public let assetID: UUID
    public let mediaURL: URL

    public init(assetID: UUID, mediaURL: URL) {
        self.assetID = assetID
        self.mediaURL = mediaURL
    }
}

public enum ManifestSource: Hashable, Sendable {
    case track(TrackReference)
    case audioAsset(AudioAssetReference)
}
