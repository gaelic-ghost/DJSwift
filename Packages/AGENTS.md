# Packages guidance

This directory inherits the repository-root `AGENTS.md`.

- `DJSwiftAPI` owns the one OpenAPI contract and generated Codable/client/server types; `DJSwiftCore` owns the required `DJSwiftDomain` zero-storage alias/behavior facade and shared UI; `DJSwiftClient` owns the generated client facade; `DJSwiftServer` owns Vapor, Fluent, Redis, and Soto adapters.
- Keep dependency flow acyclic. Product code consumes generated model values through `DJSwiftDomain`; do not add handwritten copies, conversion-only mappings, custom `Codable`, separate JSON Schema model files, or checked-in generated Swift output.
- OpenAPI `date-time` fields represent absolute instants and must generate as `Foundation.Date`; time-zone identifiers stay strings and durations stay integer intervals.
- Use SwiftPM for package builds and tests. Do not commit `.build`, `.swiftpm`, credentials, or machine-local dependency paths.
