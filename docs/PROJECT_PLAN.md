# DJSwift Project Plan

## Product Shape

DJSwift is a smart internet radio service for Apple-platform listeners and station creators. The first version is a curated app with a small number of Gale-owned stations. Later versions add paid user-created stations, shareable listening links, agent-assisted station building, generated radio elements, and personalized station suggestions.

The app targets macOS 27+ and iOS 27+ so the client can take advantage of new Apple media and intelligence frameworks as they stabilize. The server should stay Swift-first, use an OpenAPI contract as the main app/server boundary, and keep station scheduling and data modeling portable enough to work across first-party app, web homepage, and ChatGPT app surfaces.

## Product Principles

- Playback happens on the listener device through authorized first-party playback surfaces whenever possible.
- The server owns station identity, schedules, programs, creator accounts, manifests, generated audio assets, and shareable station state.
- The app owns user playback, MusicKit or Spotify authorization, local listening context, private recommendations, recording, and privacy-sensitive AI work when Apple frameworks make that viable.
- The OpenAPI contract is the shared API boundary. Generated OpenAPI types should not become the persistence model, SwiftUI state model, or station engine internals by default.
- Station-building features should start deterministic and inspectable before adding agents or generated content.
- Generated audio and personalized recommendations must be explicit about source, consent, licensing, and whether processing happens on-device, in private cloud compute, on the DJSwift server, or through a third-party API.

## Initial Architecture

### Repository Layout

Proposed first repo shape:

```text
DJSwift/
  App/
    DJSwiftApp/                 # SwiftUI app for iOS and macOS
    DJSwiftClient/              # Generated OpenAPI client plus app-facing wrappers
    DJSwiftPlayback/            # MusicKit and Spotify playback adapters
    DJSwiftRecording/           # Voice-track recording and import workflow
  Server/
    DJSwiftServer/              # Vapor or Hummingbird server executable
    DJSwiftDomain/              # Station, schedule, manifest, and policy logic
    DJSwiftPersistence/         # Fluent models, migrations, and repositories
    DJSwiftWeb/                 # Leaf or other homepage rendering if using Vapor
  Shared/
    DJSwiftTypes/               # Hand-authored domain value types shared where useful
    DJSwiftOpenAPI/             # openapi.yaml and generator config
  docs/
    PROJECT_PLAN.md
    ARCHITECTURE.md
    DATA_MODEL.md
    ROADMAP.md
```

This can start smaller, but the boundaries should be preserved early: playback, station domain logic, persistence, API transport, and generated client code should not be mixed into one app or server target.

### Server Framework Direction

Vapor is the conservative first choice if the near-term server includes Fluent, PostgreSQL, authentication, and a Leaf-powered homepage. It gives the shortest path to app API plus web presence.

Hummingbird remains a strong option if the homepage is static or minimal and the project values a lighter server core. Hummingbird can integrate with Fluent through `hummingbird-fluent`, so choosing Hummingbird does not force abandoning Fluent, but Leaf and the broader Vapor ecosystem make Vapor simpler for the first public-facing service.

Recommended decision: start with Vapor unless a first milestone proves the server should be mostly API-only and very lightweight.

### API Contract

Use Swift OpenAPI Generator as the app/server contract source.

Contract ownership:

- `Shared/DJSwiftOpenAPI/openapi.yaml` is the canonical API surface.
- Server routes are implemented against the same operation names and schemas.
- App code uses generated client types behind small app-facing services.
- Domain models map to API DTOs explicitly at API boundaries.
- Persistence models map to domain models explicitly at repository boundaries.

Early API groups:

- `stations`: list curated stations, fetch station details, fetch public station by share slug.
- `manifests`: fetch the current playable manifest for a station and listener context.
- `programs`: list shows, episodes, blocks, and breaks within a station.
- `creator`: create and edit draft stations, schedules, segments, voice tracks, jingles, and rules.
- `accounts`: auth, subscription status, creator entitlements, and station ownership.
- `assets`: upload or register voice tracks, generated audio, show art, station art, and intro/outro beds.
- `agent`: start a station-building session, propose schedule changes, explain a station plan, and commit approved edits.
- `weather`: request station-weather insert copy or audio metadata for a location and time window.

## Core Data Model

Start with a model that treats a station as a programmed stream, not just a playlist.

Primary entities:

- `User`: listener or creator account.
- `CreatorProfile`: public-facing station creator identity and billing entitlement.
- `Station`: owned radio brand with name, description, image, visibility, content policy, playback providers, and share slug.
- `StationMembership`: collaborator or friend access for private stations.
- `Program`: recurring show or programming block on a station.
- `ScheduleRule`: recurrence, time zone, date range, target daypart, fallback rules, and priority.
- `Manifest`: generated playable plan for a station over a time window.
- `ManifestItem`: one scheduled item in a manifest, such as song, break, weather report, jingle, voice track, legal ID, station promo, or fallback.
- `TrackReference`: provider-specific reference to Apple Music, Spotify, or a manually curated catalog item.
- `AudioAsset`: uploaded or generated non-music audio, with duration, format, transcript, source, and usage rights.
- `VoiceTrack`: creator-recorded audio tied to a station, program, segment, or scheduled slot.
- `GeneratedSegment`: generated copy and optional audio for weather, IDs, promos, or jingles.
- `ListeningSession`: listener playback context, station, manifest, provider, started-at time, and local state needed for listen-along behavior.
- `StationDraft`: editable builder state for agent-assisted station creation before publishing.
- `AgentSession`: conversation state, proposed changes, applied changes, and audit trail.
- `Subscription`: paid creator plan, station limits, storage limits, generated-audio quota, and sharing features.

Important modeling choices:

- A manifest item should reference music by provider ID rather than host copyrighted music.
- Music playback provider, market, availability, and authorization should be part of manifest resolution because Apple Music and Spotify catalogs can differ by user and region.
- Generated weather reports, station IDs, and jingles are first-class scheduled items so they can be previewed, regenerated, audited, and replaced.
- Drafts and published stations should be distinct so the agent can make proposed changes without mutating the live station until approved.

## App Architecture

The Apple app should use SwiftUI with explicit service injection. Keep generated networking, playback provider SDKs, recording, and local AI features behind narrow app-facing protocols.

Initial app surfaces:

- `Now Playing`: station identity, current item, upcoming items, playback provider state, and listen-along timing.
- `Station Guide`: curated station list, public shared stations, creator-owned stations, and program schedule.
- `Station Builder`: draft station editor with schedule blocks, provider choice, audio assets, voice tracks, and agent suggestions.
- `Recorder`: voice-track capture, trimming metadata, transcript, and upload queue.
- `Settings`: Apple Music and Spotify authorization, account, subscription, privacy, and diagnostics.

Core client services:

- `StationService`: reads station metadata and schedules.
- `ManifestService`: fetches and refreshes playable manifests.
- `PlaybackCoordinator`: chooses MusicKit or Spotify playback adapter and keeps provider state out of views.
- `RecordingService`: records, validates, and uploads voice tracks.
- `StationBuilderService`: owns draft station edits and agent proposal application.
- `RecommendationService`: uses local listening history, MusicKit or Spotify history where permitted, and future Apple music-understanding APIs.
- `WeatherInsertService`: requests or generates weather copy/audio for schedule slots.

## Playback Provider Plan

### MusicKit / Apple Music

Use MusicKit as the primary Apple-platform playback path. The app should request authorization, check subscription and catalog availability, and play catalog references on device. The server should store Apple Music catalog IDs and scheduling metadata, not Apple Music audio.

Potential advantages:

- Deep Apple-platform integration.
- Strong fit for on-device personalization.
- Better alignment with macOS and iOS target platforms.

Unknowns to verify during OS 27 beta:

- Exact Music Understanding API availability, permissions, and whether it can analyze user-library or playback history data for this use case.
- Whether any new framework can meaningfully score or explain station fit without sending listening data to the server.

### Spotify

Use Spotify as a secondary playback provider if SDK and policy constraints fit. Spotify's iOS SDK controls playback through the Spotify app, and the Web API exposes metadata, playback control, recently played tracks, top items, queue, playlist, search, and recommendation-style surfaces.

Important constraints:

- Some Spotify playback flows require the Spotify app and user authorization.
- Spotify Web API playback control has account and policy limitations, including Premium requirements for some flows.
- macOS support may need a different integration path than iOS App Remote.

## Agent Plan

The agent should start as a station-planning assistant, not an autonomous publisher.

Initial in-app agent capabilities:

- Ask about desired station identity, genre, mood, dayparts, and reference artists.
- Generate a draft station structure with programs, recurrence rules, break density, station IDs, and voice-track prompts.
- Suggest music seeds using explicit user-approved provider data.
- Produce editable weather-report copy for scheduled slots.
- Explain why a manifest item or schedule block was selected.
- Propose changes as diffs against `StationDraft`.
- Commit only after user approval.

ChatGPT app archetype:

- Use an interactive decoupled app: tools return structured station data, and a widget renders the station plan, schedule, and proposed edits.
- Keep mutating tools explicit, idempotent where possible, and approval-oriented.
- First tools should likely be `search` and `fetch` for public station docs plus dedicated draft tools such as `create_station_draft`, `propose_schedule`, `propose_jingles`, and `commit_station_changes`.

## Generated Audio Roadmap

Milestone order:

1. Creator-recorded voice tracks.
2. Text-only generated copy for station IDs, weather inserts, break prompts, and show descriptions.
3. Generated audio from approved text using a generic voice.
4. Custom voice support only after consent, rights, storage, revocation, and disclosure policies are designed.
5. Optional integration with Gale's speech service if it is safer, better controlled, or more private than a third-party speech API.

Every generated audio asset should record:

- source text
- generation provider
- model or voice identifier
- creator approval state
- allowed stations and contexts
- generated timestamp
- duration and file format
- transcript
- disclosure or labeling requirement

## Weather Report Plan

Weather inserts should be modeled as scheduled segment types. The first version can generate concise text copy from WeatherKit data and let the station manifest place that copy into defined slots. Later versions can render generated speech or mix weather copy with station beds.

Weather data should be cached by location and forecast window to avoid unnecessary API calls. The station should store location intent, not private listener location, unless a listener explicitly chooses local weather.

## Monetization Plan

Free tier:

- Listen to Gale-curated stations.
- Follow public shared stations.
- Basic station preview if creation is enabled.

Paid creator tier:

- Create hosted stations.
- Share private or unlisted station links.
- Store voice tracks and generated station assets.
- Use station-builder agent features.
- Generate weather inserts, station IDs, and jingles within quota.

Later tier knobs:

- number of stations
- storage
- generated audio minutes
- collaborators
- private listeners
- custom domain or branded station pages

## Open Questions

- Is Vapor's homepage and Fluent-first convenience more valuable than Hummingbird's lighter server core for the first milestone?
- Should `Shared/DJSwiftTypes` be a separate Swift package immediately, or should shared domain types live inside one Swift package workspace until cross-target pressure is real?
- What is the minimum useful listen-along model: synchronized station schedule only, or shared session state with presence?
- How much creator web UI is needed before the native Station Builder exists?
- Which music provider should be mandatory for milestone 1?
- What data can legally and practically be used from Apple Music or Spotify history for recommendations?
- What does OS 27's Music Understanding framework expose, and does it require on-device-only processing?
- Is there an official Apple server-side AI surface relevant to Swift server work, or should server AI start with OpenAI and local Apple Silicon experiments?

## Milestones

### Milestone 0: Research And Contract Spike

- Verify OS 27 beta APIs for MusicKit, Music Understanding, Foundation Models, and WeatherKit.
- Verify Spotify iOS and macOS playback options and policy constraints.
- Choose Vapor or Hummingbird for the first server.
- Draft `openapi.yaml` for stations, manifests, and assets.
- Draft `DATA_MODEL.md` with entity definitions and relationships.

### Milestone 1: Curated Station Prototype

- Build a server endpoint for station list and current manifest.
- Build a native app that lists stations and renders a current manifest.
- Implement one playback provider.
- Use static Gale-curated station data.
- Add basic server health check and diagnostics.

### Milestone 2: Scheduling Engine

- Implement programs, schedule rules, manifest generation, fallbacks, and time-zone behavior.
- Add tests for daypart scheduling, recurrence, breaks, and provider availability fallback.
- Add station artwork and program metadata.

### Milestone 3: Voice Tracks And Assets

- Add audio asset upload and metadata.
- Add in-app voice-track recording.
- Schedule voice tracks into manifests.
- Add basic moderation and rights metadata.

### Milestone 4: Creator Drafts

- Add account and paid creator model.
- Add draft stations, publish flow, share slugs, and private/unlisted visibility.
- Add Station Builder app surface.

### Milestone 5: Agent-Assisted Builder

- Add in-app agent session model.
- Generate station drafts and schedule proposals.
- Add approval flow before committing changes.
- Add ChatGPT app prototype against the same station-builder API.

### Milestone 6: Weather And Generated Audio

- Add WeatherKit-backed weather insert copy.
- Add generated text for station IDs and promos.
- Add generated speech for approved text.
- Add custom voice support only after consent and rights model is complete.

## Technical Risks

- Music-provider policy and SDK limits may shape the product more than the local architecture.
- OS 27 APIs are future-facing and must be treated as beta-gated until verified against Xcode beta docs and actual build behavior.
- Generated audio and custom voices carry consent, disclosure, storage, and revocation requirements.
- Shared listening with provider playback can drift unless manifests include timing, fallback, and provider availability rules.
- Generated OpenAPI types can become too sticky if they leak into database and UI layers.
- User-created public stations could become a moderation, rights, and abuse surface early.

## Research Sources Checked On 2026-06-23

- Apple MusicKit documentation: https://developer.apple.com/documentation/musickit
- Apple WeatherKit documentation: https://developer.apple.com/documentation/weatherkit
- Apple Foundation Models documentation: https://developer.apple.com/documentation/foundationmodels
- Swift OpenAPI Generator: https://github.com/apple/swift-openapi-generator
- Swift OpenAPI Runtime: https://github.com/apple/swift-openapi-runtime
- Swift OpenAPI URLSession transport: https://github.com/apple/swift-openapi-urlsession
- Vapor documentation: https://docs.vapor.codes/
- Hummingbird documentation: https://docs.hummingbird.codes/
- Hummingbird Fluent: https://github.com/hummingbird-project/hummingbird-fluent
- Spotify iOS SDK documentation: https://developer.spotify.com/documentation/ios
- Spotify Web API documentation: https://developer.spotify.com/documentation/web-api
- OpenAI Apps SDK documentation: https://developers.openai.com/apps-sdk

