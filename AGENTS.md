# Migration Instructions

## CFA workflow

CFA workflow: established-product maintenance.

This repository is a migration of the upstream UpcomingMovies product. Preserve
existing user-visible layout, navigation, copy, artwork, accessibility and data
behaviour unless a separate request explicitly authorises a product change.
Do not introduce CFA themes, starter branding, Settings content or other
new-product design defaults as part of the migration.

## Repository boundaries

- `origin` is the 3 Days of Swift Concurrency migration repository.
- `upstream` is `DeluxeAlonso/UpcomingMovies`; do not push to it.
- The baseline behaviour and required regression evidence are maintained in
  `MIGRATION_BEHAVIOUR_CONTRACT.md`.
- Working migration case-study evidence lives outside this repository and is
  not copied into source control automatically.

## Migration scope

Move one complete route at a time. Establish baseline build and test evidence
before replacing source behaviour. Record unavailable tooling, environment
constraints and unverified runtime paths honestly. Do not claim an unchanged
interface based only on source inspection.
