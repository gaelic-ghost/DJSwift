# Contributing to DJSwift

## Setup

Install XcodeGen, SwiftFormat, PostgreSQL 18, Redis, and Just with Homebrew, then run:

```sh
just setup
```

This installs the repository Git hooks, verifies the Homebrew services, creates `djswift_development` and `djswift_test` idempotently, regenerates `DJSwift.xcodeproj`, and lists the root workspace.

## Formatting

The root `.swiftformat` is exported from Gale's SwiftFormat for Xcode settings, and `.swift-version` locks its version-sensitive behavior to Swift 6.2. Run `just format` to format every tracked Swift file and `just format-check` to verify the tree.

The required pre-commit hook formats staged Swift blobs and then reruns SwiftFormat in lint mode. It preserves unstaged changes and blocks commits when SwiftFormat or the repository configuration is unavailable. Run `just install-hooks` if the local hook path needs to be restored.

## Source of truth

Open `DJSwift.xcworkspace`. Edit `project.yml`, `Apps/**/target.yml`, `.xcconfig` files, package manifests, and source files. Run `just align` after Xcode graph changes. Never hand-edit `project.pbxproj`.

## Server

The default host-run development configuration is:

```text
DATABASE_URL=postgres://YOUR_MACOS_USERNAME@127.0.0.1/djswift_development?tlsmode=disable
REDIS_URL=redis://127.0.0.1:6379/0
REDIS_KEY_NAMESPACE=djswift:development
```

Run `just server-migrate`, then `just server-run`. Run `just server-test` for isolated database-backed and Redis-backed tests. The test harness rejects a database URL that does not name `djswift_test` and generates a unique Redis namespace; it never flushes Redis.

## AWS boundary

S3 asset storage is disabled unless both `AWS_REGION` and `AWS_S3_ASSET_BUCKET` are set. Soto uses its default temporary credential chain. Do not use or persist root credentials, and do not provision AWS resources from this development workflow.
