# DJSwift

DJSwift is a smart internet radio service with an Apple-platform app and a Swift server.

The first milestone is a curated station prototype:

- `App/`: XcodeGen-backed SwiftUI app for iOS 27+ and macOS 27+.
- `Server/`: Vapor server for station metadata, manifests, and the future creator API.
- `docs/`: product, architecture, and planning notes.

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

Run the server locally:

```sh
cd Server
swift run DJSwiftServer serve --hostname 127.0.0.1 --port 8080
```

Set `DATABASE_URL` when PostgreSQL-backed features are added. The current bootstrap keeps the server usable without a database so the homepage and health endpoint can run before migrations exist.

## Rights

Copyright (c) 2026 Gale W. All rights reserved.

