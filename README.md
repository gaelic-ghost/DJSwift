# DJSwift

DJSwift is a smart internet radio service with native Apple-platform apps and a Swift server.

The first milestone is a curated station prototype:

- `Apps/`: separate XcodeGen-backed SwiftUI targets for iOS 27+ and macOS 27+.
- `Packages/DJSwiftCore`: portable station domain models and shared SwiftUI.
- `Packages/DJSwiftAPI`: the generated OpenAPI client, server, and transport types.
- `Packages/DJSwiftClient`: app-facing API services and transport/domain mappings.
- `Packages/DJSwiftServer`: Vapor, Fluent/PostgreSQL, Redis, and Soto-backed server boundaries.
- `docs/`: product, architecture, and planning notes.

The supported Apple entry point is `DJSwift.xcworkspace`. The decided architecture, completed modernization work, and AWS deployment runway are recorded in [`ROADMAP.md`](ROADMAP.md). Product intent remains in [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md).

## Development

Install XcodeGen, Just, PostgreSQL 18, and Redis with Homebrew. Start PostgreSQL and Redis, then prepare the databases and generated workspace:

```sh
just setup
```

Open `DJSwift.xcworkspace` for app development. After changing XcodeGen specifications or `.xcconfig` files, regenerate and inspect the workspace with:

```sh
just align
```

Run all Swift package tests, or the service integration tests alone:

```sh
just package-test
just server-test
```

Migrate and run the server locally:

```sh
just server-migrate
just server-run
```

The server uses `DATABASE_URL`, `REDIS_URL`, and `REDIS_KEY_NAMESPACE`, with safe Homebrew defaults for macOS. Tests require the dedicated `djswift_test` database and a test-prefixed Redis namespace. Copy `.env.example` only as a reference; never commit a populated `.env` file.

S3 asset storage is implemented behind a narrow Soto protocol but remains disabled until `AWS_REGION` and `AWS_S3_ASSET_BUCKET` are both set. Live AWS verification and IAM provisioning are deliberately deferred until temporary non-root access and the Phase 6 deployment resources exist.

## Rights

Copyright (c) 2026 Gale W. All rights reserved.
