# DJSwift repository guidance

Read `CONTRIBUTING.md` for setup, validation, testing, and local service commands.

- `project.yml` and `Apps/**/target.yml` own Xcode project data. Never hand-edit generated `.pbxproj` files.
- `Apps/` owns thin platform app and test targets. `Packages/` owns shared domain, API, client, and Vapor server code.
- Open `DJSwift.xcworkspace` and run `just align` after changing XcodeGen specifications or package registration.
- SwiftFormat is mandatory. Keep `.swiftformat`, `.swift-version`, and `.githooks/pre-commit` active; run `just format-check` before validation or landing.
- Keep generated OpenAPI build-plugin output out of source control; edit `Packages/DJSwiftAPI/Sources/DJSwiftAPI/openapi.yaml`.
- Never run server tests against `djswift_development` or a non-test Redis namespace.
- Do not add AWS credentials to this repository. Soto uses temporary credentials supplied by the local profile or deployed workload role.
- AWS provisioning and IAM mutation are outside Phases 1–5 and require a separate explicit deployment task.
