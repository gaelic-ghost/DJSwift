# Apps guidance

This directory inherits the repository-root `AGENTS.md`.

- Keep platform entry points, resources, entitlements, and Apple-framework adapters in their target directories.
- Put reusable domain, view, and service behavior in the appropriate package under `Packages/`.
- Regenerate the root project with `just align`; never edit generated project data in Xcode.
