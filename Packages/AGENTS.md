# Packages guidance

This directory inherits the repository-root `AGENTS.md`.

- `DJSwiftCore` owns domain and shared UI; `DJSwiftAPI` owns the OpenAPI contract; `DJSwiftClient` maps transport to domain; `DJSwiftServer` owns Vapor, Fluent, Redis, and Soto adapters.
- Keep dependency flow acyclic and keep generated transport types out of persistence and SwiftUI state.
- Use SwiftPM for package builds and tests. Do not commit `.build`, `.swiftpm`, credentials, or machine-local dependency paths.
