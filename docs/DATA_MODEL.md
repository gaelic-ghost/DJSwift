# DJSwift Data Model

This document defines DJSwift's durable product vocabulary, identity rules, relationships, and implementation order. The repository roadmap remains in [`../ROADMAP.md`](../ROADMAP.md), and broader product intent remains in [`PROJECT_PLAN.md`](PROJECT_PLAN.md).

## Modeling Strategy

DJSwift models a station as a programmed stream, not as a playlist. Programs and schedule rules describe intent. A generated manifest is the immutable, time-bounded playback plan produced from that intent. Music stays with an authorized playback provider; DJSwift stores provider references rather than copyrighted music files.

The model is deliberately layered:

- `DJSwiftDomain` owns portable product concepts and deterministic behavior.
- `DJSwiftAPI` projects the subset of those concepts needed across HTTP.
- `DJSwiftServer` owns Fluent records, migrations, and database queries.
- SwiftUI and the future Leaf web app consume application/API projections; neither owns database models.

Domain, transport, and persistence types may have similar fields, but they are not interchangeable. Mappings between them remain explicit so a database migration or public API change does not silently redefine product behavior.

## Identity Rules

- Durable entities use UUID primary keys. Relationships use those UUIDs.
- A `Station.slug` is a stable, unique public routing identifier, not the station's database identity.
- Provider catalog identifiers are namespaced by provider and optional market. They are not DJSwift entity IDs.
- Manifest revisions increase within a station. A manifest also has its own UUID so clients can distinguish independently generated plans.
- User-editable names, titles, and descriptions are never identifiers.

## Model Groups

### Implemented Foundation

These portable domain types exist in `Packages/DJSwiftCore/Sources/DJSwiftDomain/`:

- `Station`: internal UUID, public slug, name, and tagline.
- `Program`: a named programming block owned by one station.
- `ScheduleRule`: a recurring local-time placement for a program, including time zone, weekdays, start minute, duration, and priority.
- `StationManifest`: one revisioned, generated plan for a station and validity window.
- `ManifestItem`: one time-positioned playable item in a manifest.
- `TrackReference`: an Apple Music or Spotify catalog reference.
- `AudioAssetReference`: a DJSwift-owned non-music audio reference.
- `ManifestSource`: the explicit distinction between provider music and an owned audio asset.

PostgreSQL currently persists only `StationRecord`. That is intentional: domain types establish vocabulary before migrations are added, while tables are added only with a feature that reads and writes them.

### Next Persistence Slice

The scheduling-engine slice should add these tables together because their constraints are meaningful only as a unit:

- `programs`, belonging to `stations`
- `schedule_rules`, belonging to `programs`
- `manifests`, belonging to `stations`
- `manifest_items`, belonging to `manifests`
- `track_references`, referenced by track manifest items

Manifest generation should write a manifest and all of its items in one transaction. Published manifest rows are immutable; a refresh creates a new revision rather than editing the plan a listener may already be using.

### Asset Slice

The asset-upload feature should add:

- `audio_assets`: storage key, media type, byte size, duration, checksum, transcript, source, rights state, and lifecycle state
- `voice_tracks`: a creator recording associated with a station, program, or scheduled slot

The database stores an object-storage key, not an expiring S3 URL. HTTP responses may contain a delivery URL produced at request time. Deleting an asset requires an explicit lifecycle operation coordinating PostgreSQL and object storage; it must not be hidden inside a model callback.

### Creator And Publishing Slice

Creator functionality should add:

- `users`
- `creator_profiles`
- `station_memberships`
- `station_drafts`
- published station revisions or an equivalent auditable publish record
- `subscriptions` and entitlement records only when billing is implemented

Drafts and published stations remain distinct. Agent suggestions modify a draft or produce a proposed diff; they never mutate a published station without explicit approval.

### Agent And Listening Slice

Add these only with their concrete features:

- `agent_sessions` and proposed/applied change records
- `generated_segments` with source text, provider/model, approval, rights, disclosure, and revocation metadata
- `listening_sessions` only when synchronized listening or server-visible session state is required

Private listening history and recommendation inputs stay on device unless a separately designed, consented server feature requires them.

## Relationship Summary

| Parent | Child | Relationship | Deletion rule |
| --- | --- | --- | --- |
| Station | Program | one-to-many | Restrict deletion once published history exists; archive instead |
| Program | ScheduleRule | one-to-many | Cascade only for an unpublished program |
| Station | Manifest | one-to-many | Retain published revisions according to an explicit retention policy |
| Manifest | ManifestItem | one-to-many, ordered by `startsAt` | Cascade with an unpublished/expired manifest cleanup operation |
| ManifestItem | TrackReference | optional reference | Restrict while a retained manifest refers to it |
| ManifestItem | AudioAsset | optional reference | Restrict while a retained manifest refers to it |
| User | CreatorProfile | one-to-zero-or-one | Archive or anonymize according to the account-deletion policy |
| Station | StationMembership | one-to-many | Cascade when an unpublished station is removed |
| StationDraft | Proposed change | one-to-many | Cascade with an abandoned draft after its audit-retention window |

Archive and retention behavior must be implemented as explicit application operations. Fluent relation callbacks must not silently delete published history or object-storage data.

## Scheduling Semantics

- A schedule rule expresses wall-clock intent in an IANA time zone, such as `America/New_York`.
- `startMinuteOfDay` is in the range `0...1439`; durations are positive whole minutes.
- Weekdays use the Calendar convention where Sunday is `1` and Saturday is `7`.
- Higher priority wins when eligible rules overlap. Equal-priority overlap must produce a deterministic conflict result, not depend on database ordering.
- Daylight-saving gaps and repeated times require explicit tested policy before the scheduling engine ships.
- Fallback programming is a first-class rule or policy, not an implicit "pick anything" branch.

These are domain invariants. The scheduling implementation must validate them before persistence and cover overlap, time-zone, and daylight-saving behavior with pure Swift tests.

## Manifest Semantics

- A manifest covers `[validFrom, validThrough)` and records when it was generated.
- Items are ordered by `startsAt`; equal timestamps are invalid unless a future overlay model explicitly permits them.
- Music items carry provider references and are played through an authorized client-side provider.
- DJSwift-owned audio items carry asset references and may resolve to short-lived delivery URLs.
- A listener may need a provider-specific fallback when a track is unavailable in their market. The fallback policy belongs to manifest resolution, not the SwiftUI view.
- Redis may cache a serialized manifest, but PostgreSQL or deterministic regeneration remains the source of truth.

## Current API Projection

The initial OpenAPI contract exposes station UUID and slug separately. Its manifest projection carries manifest identity and validity timestamps, and distinguishes a provider track from a DJSwift-owned audio asset. The contract is intentionally smaller than the eventual persistence model.

Public station routes continue to use the readable slug. Internal relations and response identities use UUIDs.

## Leaf And Web Application Boundary

Leaf is the planned server-rendered web surface. It begins as the public homepage and can grow into account, creator, and station-management workflows.

Leaf handlers should call the same application behavior used by OpenAPI handlers. Leaf view contexts are presentation types: they may format dates, navigation, and form errors, but must not become a second domain or persistence model. Interactive web behavior can be added progressively without moving ownership out of the server package.

## Migration Rules

- Add one migration per coherent schema change and register migrations in dependency order.
- Never edit an already-deployed migration to change live schema behavior; add a forward migration.
- Backfills must be explicit, bounded, and safe to rerun or safely fail with an actionable error.
- Use a transaction when several writes define one valid aggregate.
- Reverts are provided only when data can be restored safely. Destructive production rollback uses backup/restore and a reviewed runbook.
- Tests migrate only `djswift_test` and use an isolated Redis namespace.

## Deliberately Deferred Details

The following choices need feature evidence before becoming schema:

- exact MusicKit and Spotify availability/fallback fields
- schedule exception and holiday representation
- manifest retention duration
- authentication provider and credential tables
- subscription provider and entitlement history
- moderation, abuse-report, and public-discovery records
- generated-audio consent and revocation workflow
- shared-listening presence and synchronization state

Deferring these fields is not a gap in the foundation. Their owning entities, boundaries, and triggers are established without inventing storage that no behavior currently uses.
