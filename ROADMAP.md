# DJSwift Roadmap

This roadmap records the decided repository architecture, modernization sequence, local development contract, and deployment runway for DJSwift. Product intent and feature detail remain in [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md).

## Status

- Current phase: Phases 1–5 implemented and validated locally; Phase 6 cloud/container deployment is next.
- Current product baseline: separate iOS and macOS apps, shared Swift packages, a generated OpenAPI contract, and a Vapor 4 service backed by PostgreSQL and Redis with an isolated Soto S3 boundary.
- Modernization strategy: this repository and its Git history were preserved while the noncanonical nested projects were replaced with the canonical root Xcode workspace shape.
- First deployment target: a low-cost, explicitly non-high-availability live-test environment after local behavior is proven.

## Locked Decisions

The following choices are decided. Revisit one only when new evidence changes its practical constraints.

### Repository And Workspace

- Keep one product repository.
- Use one root `DJSwift.xcworkspace` as the stable Xcode and `xcodebuild` entry point.
- Generate one root `DJSwift.xcodeproj` from root XcodeGen specifications. Never hand-edit `project.pbxproj`.
- Put Apple application and test targets under `Apps/`.
- Put shared, client, API, and server Swift packages under `Packages/`.
- Keep the Vapor service under `Packages/DJSwiftServer/`, not under `Apps/`. It is a SwiftPM executable rather than an Apple application bundle.
- Use root `Configurations/` plus shared and target-local `.xcconfig` layers.
- Support the canonical Debug, Staging, Release, AppStore, DirectDistribution, and AltStore configuration set.
- Migrate in place using a fresh bootstrap generated in a temporary empty directory as the reference scaffold. Do not start a new repository and do not attempt to align the current noncanonical `App/` project in place.

### Package Ownership

- `DJSwiftCore` owns platform-neutral station, program, schedule, manifest, and policy types and behavior.
- `DJSwiftAPI` owns the canonical OpenAPI document, generator configuration, and generated transport types.
- `DJSwiftClient` owns app-facing API services and explicit transport-to-domain mappings.
- `DJSwiftServer` owns Vapor startup, HTTP adapters, Fluent persistence, Redis integration, Soto integration, migrations, and server tests.
- Generated OpenAPI types are transport types. They do not become Fluent models, core domain models, or SwiftUI state models.
- Fluent models are persistence types. They map explicitly at the persistence boundary when their stored shape differs from the domain shape.
- Soto and server credentials never become client-package or Apple-app dependencies.
- Add another package, target, repository, service, manager, or coordinator only when a concrete ownership or testability problem requires it.

### Apple Applications

- Maintain separate iOS and macOS application entry points, resources, configurations, schemes, and test targets.
- Share reusable behavior through local package products rather than a second Xcode project or an ambiguous shared source folder.
- Keep MusicKit, recording, platform authorization, and platform-specific playback behavior out of server and portable domain targets.
- Preserve the current iOS 27 and macOS 27 product intent while those SDKs are beta-gated. Building those targets requires explicitly selecting an Xcode that supplies the corresponding SDK; automation must not hard-code an Xcode path.

### Server And Data

- Use stable Vapor 4. Vapor 5 remains an evaluation track until it has a stable release, stable documentation, and a viable migration path for the required ecosystem packages.
- Use Fluent with PostgreSQL as the primary durable persistence path.
- Use the official Vapor Redis integration for cache, sessions, rate-limit state, and other suitable ephemeral data.
- Add the official Redis-backed Vapor Queues driver when a real background-job use case arrives. Do not invent a queue directly on Redis commands.
- Keep the HTTP executable thin enough that application configuration and routes can be constructed and tested without launching a long-running process.
- Use Swift OpenAPI Generator as the app/server contract boundary.
- Start domain behavior deterministic and inspectable before introducing agent-driven decisions or generated content.

### AWS Integration

- Use Soto instead of the AWS SDK for Swift for application-level AWS API calls.
- Add only the Soto service products used by an implemented feature, such as `SotoS3` or `SotoSES`; do not add the umbrella dependency speculatively.
- Create one application-lifetime `AWSClient` during Vapor startup and shut it down with the application.
- Use local AWS profiles or temporary environment credentials for development.
- Use workload roles and temporary credentials in AWS. Never commit or bake AWS access keys into source, dotenv files, Compose configuration, images, or deployment manifests.
- Separate the ECS task execution role from the DJSwift application task role:
  - The execution role lets ECS pull images, publish logs, and retrieve referenced deployment secrets.
  - The application task role supplies only the AWS API permissions used by Soto inside DJSwift.
- Scope the application role to the concrete buckets, queues, topics, models, or other resources that exist at deployment time. Do not create the role before those resource names and required API operations are known.

### Local Development And Testing

- Run Vapor directly on macOS for the default development loop.
- Use the Homebrew PostgreSQL and Redis services already installed on Gale's MacBook.
- Standardize application configuration around `DATABASE_URL` and `REDIS_URL`.
- Commit a safe dotenv template and ignore environment-specific dotenv files containing local credentials.
- Use separate `djswift_development` and `djswift_test` databases.
- Give tests a unique Redis key namespace. Never flush a shared Redis database as test cleanup.
- Run migrations explicitly and ensure tests cannot auto-revert the development database.
- Keep Docker Compose as the Linux/container parity and CI integration surface, not as a prerequisite for the normal macOS edit-build-test loop.
- Serialize SwiftPM, Xcode, package-manager, and container validation on the development machine.

### Containers And Deployment

- Maintain one hardened multi-stage production Dockerfile whose build context is the repository root so it can consume sibling local packages.
- Keep the application container stateless. Store durable records in PostgreSQL and durable assets in object storage.
- Expose distinct liveness and readiness behavior before using an orchestrator. Readiness must cover dependencies required to serve normal traffic.
- Run schema migration as an explicit one-shot release operation, not implicitly in every application replica.
- Do not ship a live `migrate --revert` service or expose PostgreSQL or Redis publicly.
- Use immutable image tags or digests for live deployment; `latest` is acceptable only for local development.

Deployment stages are decided as follows:

1. Local macOS: host-run Vapor with Homebrew PostgreSQL and Redis.
2. Container parity: Docker Compose for app, PostgreSQL, Redis, migrations, and integration checks.
3. Live test: one low-cost Lightsail Linux instance running Compose, a TLS reverse proxy, private database/cache networking, persistent volumes, and PostgreSQL backups to S3. This environment is intentionally non-HA.
4. Production default: ECS/Fargate with ECR, ALB/ACM, RDS PostgreSQL, a managed Redis-compatible cache, Secrets Manager or Parameter Store, CloudWatch, autoscaling, and rollback-enabled deployments.
5. Kubernetes option: use EKS only after Kubernetes portability, ecosystem tooling, or team operations become an explicit requirement that justifies its control-plane cost and complexity.

Docker Swarm is not part of the deployment plan. Compose remains the single-host model; ECS/Fargate is the default scaling path on AWS.

## Target Repository Shape

```text
DJSwift/
  DJSwift.xcworkspace/
  DJSwift.xcodeproj/
  project.yml
  Configurations/
  Apps/
    apps-shared.yml
    Apps-shared.xcconfig
    DJSwiftiOS/
    DJSwiftiOSTests/
    DJSwiftiOSUITests/
    DJSwiftmacOS/
    DJSwiftmacOSTests/
  Packages/
    packages-shared.yml
    DJSwiftCore/
    DJSwiftAPI/
    DJSwiftClient/
    DJSwiftServer/
  Deployment/
    Dockerfile
    compose.yaml
  scripts/
  docs/
  AGENTS.md
  CONTRIBUTING.md
  Justfile
```

The final generated bootstrap may add required canonical support files or test targets. The ownership boundaries above are the contract; incidental scaffold filenames may follow the current workspace tooling.

## Implementation Phases

### Phase 0: Land The Baseline And Prepare The Pivot

- [x] Review the current repository, package graph, toolchain, local services, and deployment files.
- [x] Decide migrate-versus-rebuild, target workspace shape, package ownership, server stack, local service contract, AWS SDK direction, and deployment runway.
- [x] Record those decisions in this roadmap and reconcile the product plan.
- [x] Land the current `build/add-test-action` branch on `main`.
- [x] Create `architecture/workspace-modernization` from the updated `main`.
- [x] Record baseline app generation, server build, and server test results before moving files.

Baseline evidence: the legacy XcodeGen project generated and listed successfully, the legacy Vapor package built, and its Docker-backed server suite passed all four tests before migration.

Exit condition: all pre-modernization history is reachable from `main`, the working tree is clean, and baseline failures are documented rather than silently carried forward.

### Phase 1: Install The Canonical Workspace

- [x] Generate a fresh DJSwift bootstrap in a temporary empty directory using the current workspace workflow.
- [x] Bring the root workspace, XcodeGen graph, configuration hierarchy, target fragments, package registry, Justfile, contributor documentation, and managed guidance into this repository.
- [x] Move the iOS and macOS application entry points and resources under their target directories.
- [x] Add the generated native unit and UI test surfaces.
- [x] Remove the obsolete nested `App/` project after equivalent source and configuration are proven in the root workspace.
- [x] Regenerate the root project and verify that generated project data matches its specifications.

Exit condition: `DJSwift.xcworkspace` is the only supported Apple-product entry point, and both native targets resolve from generated root project data.

### Phase 2: Establish The Package Graph

- [x] Create `DJSwiftCore`, `DJSwiftAPI`, `DJSwiftClient`, and `DJSwiftServer` package manifests and initial products.
- [x] Move shared station bootstrap types into their correct domain/client owner.
- [x] Move the Vapor executable into `Packages/DJSwiftServer` while preserving health and station behavior through the generated contract.
- [x] Separate executable entry from testable application construction.
- [x] Adopt Swift 6 language mode and remove redundant upcoming-feature flags after compilation verifies they are no longer needed.
- [x] Register only consumed package products in the relevant XcodeGen targets.
- [x] Reserve the repository root as the Phase 6 Docker build context so every sibling local package will be resolvable.

Exit condition: dependencies flow toward core abstractions without cycles, both apps compile against deliberate package products, and the server builds and tests through SwiftPM.

### Phase 3: Define The API Contract

- [x] Add the first canonical OpenAPI document for health, station listing, station detail, and current manifest operations.
- [x] Configure generated client and Vapor server transport types.
- [x] Add explicit API-to-domain and domain-to-API mappings.
- [x] Replace handwritten duplicated station response shapes at the transport boundary.
- [x] Add contract and request/response tests.

Exit condition: iOS, macOS, and Vapor consume one checked-in API contract without sharing persistence or SwiftUI types.

### Phase 4: Modernize Persistence And Redis

- [x] Add safe `.env` and `.env.example` conventions around `DATABASE_URL` and `REDIS_URL`.
- [x] Add idempotent setup commands for the local development and test databases.
- [x] Replace the generated Todo model, migration, controller, and tests with the first real Station persistence slice.
- [x] Add Redis configuration and station-manifest caching with a 60-second TTL.
- [x] Defer Redis-backed queues until asset processing, generated audio, email, or another real background job requires them.
- [x] Isolate test database schema and Redis keys from development data.

Exit condition: a clean checkout can use the documented Homebrew services to migrate, test, run, and exercise one real station API slice without Docker.

### Phase 5: Introduce Soto At A Concrete Boundary

- [x] Choose S3 object storage for station artwork and non-music audio assets as the first AWS-backed capability.
- [x] Add only the `SotoS3` product.
- [x] Define a narrow `AssetStorage` application protocol around object writes.
- [x] Verify fail-closed configuration and actionable error reporting without persisting credentials or making a call as the root principal.
- [x] Record the exact `s3:PutObject` call and deployment-time resource ARN template required by the implementation.
- [x] Generate the least-privilege application policy template; defer Access Analyzer validation until the concrete Phase 6 bucket and temporary non-root identity exist.

Exit condition: the S3 capability compiles through Soto, remains replaceable in tests, fails closed when disabled or partly configured, and has a documented least-privilege permission surface. A live S3 call is a Phase 6 preflight because the only current CLI session is the account root principal.

### Phase 6: Container And Live-Test Deployment

- [ ] Consolidate the current Dockerfile into the root-context production image.
- [ ] Add Redis, health checks, private dependency networking, and safe local credentials to Compose.
- [ ] Remove the live revert surface and host-published database/cache ports from deployment configuration.
- [ ] Add a one-shot migration command and PostgreSQL backup/restore runbook.
- [ ] Build and test the Linux image on Apple silicon for the selected deployment architecture.
- [ ] Provision the Lightsail live-test host, DNS/TLS, storage, firewall, workload identity strategy, and backups.
- [ ] Deploy by immutable image identifier and verify rollback.

Exit condition: the public live-test endpoint survives application restart, restores its PostgreSQL backup in a rehearsal, and exposes neither credentials nor database/cache ports.

### Phase 7: Production Readiness

- [ ] Measure the live-test workload before selecting production task/database/cache sizes.
- [ ] Provision ECR, ECS/Fargate, ALB/ACM, RDS, managed cache, secrets, logging, and alarms through reviewed infrastructure as code.
- [ ] Create separate ECS execution and DJSwift application task roles.
- [ ] Enable rollback-aware deployments, migration gating, autoscaling, backup retention, and restore drills.
- [ ] Add Security Hub, IAM Access Analyzer, CloudTrail review, budgets, and cost anomaly detection to the account baseline as appropriate.
- [ ] Re-evaluate ECS versus EKS using concrete portability and operations requirements; do not adopt EKS solely for hypothetical scale.

Exit condition: production has least-privilege temporary credentials, managed durable data, rehearsed recovery, observable deployments, and a demonstrated scaling path.

## AWS Account Readiness Snapshot

Read-only checks performed on 2026-08-20 against the currently configured AWS CLI session in `us-east-2` found:

- AWS CLI and an authenticated session are available.
- The current CLI session resolves through STS as the AWS account root principal. It must not be used for DJSwift provisioning or normal administration.
- Root-account MFA is enabled.
- No root access keys are present.
- No local IAM Identity Center/SSO profile or discoverable Identity Center instance is configured.
- No active account-level IAM Access Analyzer was found in the configured region.
- Security Hub could not be confirmed as enabled; it is disabled in the configured region or the current identity lacks permission to inspect it.

These findings do not block repository modernization or local development. Before creating the first persistent AWS environment:

- [ ] Confirm the intended AWS account and region strategy.
- [ ] Configure IAM Identity Center for human access with temporary credentials, unless an existing organization-level identity provider owns that responsibility, and retire the current root-authenticated CLI path from normal use.
- [ ] Enable and review an account- or organization-level IAM Access Analyzer.
- [ ] Determine whether Security Hub is disabled or merely hidden from the current identity, then enable it in the deployment regions if it belongs in the account security baseline.
- [ ] Confirm CloudTrail, budgets, billing alerts, and cost anomaly detection.
- [ ] Create deployment roles only with the infrastructure that consumes them.

No DJSwift IAM role is required up front. The first role decision belongs to the first AWS deployment or Soto-backed feature, when concrete resources and permissions exist.

## Modernization Validation

Validation completed on 2026-08-20 with the configured stable Xcode 26.6 and local Homebrew services:

- The root XcodeGen graph generated successfully, and `xcodebuild -list` resolved the root workspace and its app/package schemes.
- The iOS and macOS app targets built with code signing disabled and package-plugin validation skipped for noninteractive validation.
- Both app builds correctly retained the locked iOS 27 and macOS 27 deployment targets; Xcode 26.6 emitted the expected warning because its selected SDK reports support through 26.5.99.
- `DJSwiftCore`, `DJSwiftAPI`, and `DJSwiftClient` each passed their SwiftPM tests.
- `DJSwiftServer` migrated `djswift_development`, created the bootstrap station, and passed all four PostgreSQL/Redis integration tests against isolated test state.
- Swift OpenAPI Generator successfully generated types, client, and server code from the checked-in contract.
- Soto S3 configuration and lifecycle code compiled without making an AWS request under the unsafe root-authenticated CLI session.

## Risks And Controls

- Local database tests could damage development data. Use dedicated databases and fail closed when test configuration is missing.
- Generated API types could leak into persistence or UI state. Keep explicit boundary mappings and dependency tests.
- Redis could become an undocumented source of truth. Restrict it to disposable or explicitly durable queue state with defined invalidation and recovery behavior.
- A single Lightsail host is not highly available. Treat it as disposable live-test infrastructure and rehearse restore before relying on its data.
- Compose can hide production assumptions. Preserve a stateless image, explicit configuration, health checks, one-shot migrations, and external service contracts.
- Kubernetes could consume budget and attention before product fit. Require a concrete EKS trigger before adding cluster manifests.
- AWS policies can overreach. Separate execution and application roles, scope `iam:PassRole`, validate policies, and refine them from observed CloudTrail activity.
- OS 27 APIs and SDKs are beta-gated. Keep availability boundaries explicit and verify against the selected Xcode beta before depending on them.

## Deferred Decisions And Triggers

- First playback provider: decide during the contract and playback spike after current MusicKit and Spotify policy verification.
- First Soto service: default candidate is S3, but add it only with the first implemented asset-storage use case.
- Redis versus a Redis-compatible managed production service: decide during production provisioning after Vapor integration and compatibility are verified.
- ECS versus EKS: remain on ECS unless Kubernetes portability, existing Kubernetes operations, or multi-service scheduling requirements become concrete.
- Package subdivision beyond the four named packages: split targets or packages only after compilation boundaries, dependency ownership, or test isolation demonstrate the need.
- Creator web UI framework: decide when the native Station Builder no longer covers the required creator workflow.

## Decision Log

### 2026-08-20: Canonical Workspace And Deployment Direction

DJSwift will migrate in place to the current root Xcode workspace bootstrap, place Apple targets under `Apps/`, place the Vapor executable and shared modules under `Packages/`, use Vapor 4 with PostgreSQL and Redis, use Soto for application AWS access, develop against Homebrew services, validate with Docker Compose, deploy the first live test to a small Lightsail Compose host, and prefer ECS/Fargate over Swarm or premature EKS for production scaling.

### 2026-08-20: Local Modernization Through The AWS Boundary

Phases 1–5 are implemented locally. S3 object writes are the first Soto capability and are isolated behind `AssetStorage`; live credential and policy validation moves to the Phase 6 preflight so no application work is performed with the account root principal. Docker and AWS provisioning remain intentionally outside this milestone.
