import Foundation

struct StationSummary: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let tagline: String
    let previewItems: [PreviewItem]

    static let bootstrap = StationSummary(
        id: "gaelic-ghost-one",
        name: "Gaelic Ghost One",
        tagline: "Curated radio first. Creator-hosted stations next.",
        previewItems: [
            PreviewItem(symbolName: "dot.radiowaves.left.and.right", title: "Curated station manifest", detail: "Server-owned schedules and device-side playback."),
            PreviewItem(symbolName: "music.note.list", title: "Provider-backed music", detail: "MusicKit first, Spotify once policy and platform support are pinned down."),
            PreviewItem(symbolName: "wand.and.sparkles", title: "Station builder agent", detail: "Drafts, proposals, weather inserts, and jingles after the baseline stream works.")
        ]
    )
}

struct PreviewItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let symbolName: String
    let title: String
    let detail: String
}

