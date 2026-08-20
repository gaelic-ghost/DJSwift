# DJSwift

DJSwift is a smart internet radio service with native Apple-platform apps and a Swift server.

The first milestone is a curated station prototype:

- `App/`: current XcodeGen-backed SwiftUI bootstrap for iOS 27+ and macOS 27+.
- `Server/`: Vapor server for station metadata, manifests, and the future creator API.
- `docs/`: product, architecture, and planning notes.

The repository is preparing to migrate in place to one root Xcode workspace with native targets under `Apps/` and shared/client/server packages under `Packages/`. The decided architecture, implementation sequence, local service contract, and AWS deployment runway are recorded in [`ROADMAP.md`](ROADMAP.md). Product intent remains in [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md).

## Development

Generate the app project:

```sh
cd App
xcodegen generate
```

Build the server:

```sh
cd Server
swift build
```

Run the database-backed server tests:

```sh
scripts/test-server.sh
```

Run the server locally:

```sh
cd Server
swift run DJSwiftServer serve --hostname 127.0.0.1 --port 8080
```

The current server reads individual `DATABASE_*` values and defaults to the generated local Vapor credentials. The modernization replaces that with explicit `DATABASE_URL` and `REDIS_URL` contracts, dedicated development and test databases, and Homebrew PostgreSQL and Redis as the default macOS development services.

## Rights

Copyright (c) 2026 Gale W. All rights reserved.
