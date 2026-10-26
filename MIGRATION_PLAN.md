# UpcomingMovies CFA Migration Plan

## Status

**Continuing migration.** This plan is a delivery checklist, not evidence that
the migration is complete. The prior route-only pilot is recorded as failed in
`MIGRATION_BEHAVIOUR_CONTRACT.md` and cannot be used as a case-study precedent.

## Preservation boundary

The upstream UIKit interface remains in place while its implementation moves.
This migration must preserve the established layouts, storyboards, navigation,
copy, artwork, accessibility, stored data and error behaviour. Replacing a
UIKit screen with SwiftUI is a separate route decision after behaviour is
characterised; it is not a shortcut for showing a new CFA folder map.

## Visible destination

The Xcode navigator will transition to the following structure. A temporary
compatibility boundary is named explicitly so that it cannot be mistaken for
the completed composition root.

```text
UpcomingMovies
├── 1 - View
│   └── Views
│       └── Upcoming Movies
│           ├── UIKit controller, view model, navigation and presentation files
│           └── Cells
│       ├── Search
│       └── Account
├── 2 - AppModel
│   ├── Features
│   │   ├── Upcoming Movies
│   │   │   └── UpcomingMoviesFeature.swift
│   │   └── Search
│   │       └── SearchMoviesFeature.swift
│   │   └── Account
│   │       └── AccountFeature.swift
│   └── Legacy Dependency Composition
│       ├── UpcomingMoviesAssembly.swift
│       ├── SearchMoviesAssembly.swift
│       └── AccountAssembly.swift
├── Legacy UIKit Routes
│   ├── Search
│   ├── Account
│   └── Remaining movie-detail routes
└── App resources and shared infrastructure
```

`Legacy Dependency Composition` is transitional. It documents the remaining
Swinject boundary while the route still uses UIKit composition. It will be
replaced by `AppModel.live()` only after the three tab features are available
and their dependencies can be constructed without changing product behaviour.

## Tab ownership map

| Tab | Current root screen | Target feature | Transitional presentation owner | Named verification needed |
| --- | --- | --- | --- | --- |
| Upcoming Movies | `UpcomingMoviesViewController` | `UpcomingMoviesFeature` | `UpcomingMoviesViewModel` and UIKit controller | `UpcomingMoviesFeatureTests`, `UpcomingMoviesViewModelTests` |
| Search | `SearchMoviesViewController` | `SearchMoviesFeature` | dedicated Search UIKit view model | feature and view-model tests |
| Account | `AccountViewController` | `AccountFeature` | dedicated Account UIKit view model | feature and view-model tests |

## First complete route: Upcoming Movies

The first route moves as one visible slice:

```text
UpcomingMoviesViewController
  → UpcomingMoviesViewModel
  → UpcomingMoviesFeature
  → MovieUseCase / MovieRepository
  → MovieRemoteDataSource / MovieClient
```

The completed first-route checkpoint requires all of the following:

1. The controller, view model, navigation and presentation files appear under
   `1 - View/Views/Upcoming Movies` in Xcode.
2. `UpcomingMoviesFeature` appears under
   `2 - AppModel/Features/Upcoming Movies` in Xcode.
3. The compatibility assembly appears under the explicitly named transitional
   composition boundary, not under `DependencyInjection/Scenes`.
4. The `UpcomingMovies` build and test targets pass after this movement.
5. A manual regression confirms initial loading, refresh, prefetch, failure and
   retry against the behaviour contract.

Meeting that checkpoint is **not** the full application migration. Search,
Account, nested movie routes, shared infrastructure, the remaining concurrency
inventory, a true AppModel composition root and final navigator review remain.

### Current checkpoint evidence — 26 October 2026

- Completed: the full Upcoming Movies UIKit presentation route now lives at
  `UpcomingMovies/1 - View/Views/Upcoming Movies` on disk and in the Xcode
  navigator.
- Completed: `UpcomingMoviesFeature` now lives at
  `UpcomingMovies/2 - AppModel/Features/Upcoming Movies` on disk and in the
  navigator.
- Completed: its Swinject registration now lives at
  `UpcomingMovies/2 - AppModel/Legacy Dependency Composition`; this is an
  explicit transitional boundary, not an AppModel claim.
- Verified: `project.pbxproj` passes `plutil -lint`; the moved Swift files pass
  `swiftc -parse`; and the repository diff has no whitespace errors.
- Outstanding: the post-move Simulator build and 308-test suite must run in a
  normal Terminal/Xcode environment because this Codex execution environment
  cannot connect to CoreSimulator. Manual regression is also still outstanding.

## Concurrency inventory checkpoint

The raw starting scan found 542 callback or legacy-concurrency candidates across
the app and its local frameworks. That is a discovery count, not a resolved
inventory. Before any completion claim, each in-scope primitive must record its
owner, ordering/lifetime/error guarantee, replacement or retention decision,
and verification evidence.

## Search route checkpoint — in progress

- Completed: the entire Search UIKit presentation route, including its embedded
  search-options and search-results screens, now appears at
  `UpcomingMovies/1 - View/Views/Search` in Xcode.
- Completed: `SearchMoviesFeature` now appears at
  `UpcomingMovies/2 - AppModel/Features/Search`. It owns callback-to-async
  conversion for movie searches, recent searches, genres and visited movies.
  Equivalent in-flight reads share one task. Distinct search-history writes run
  sequentially, preserving their input order.
- Completed: `SearchMoviesResultViewModel` and `SearchOptionsViewModel` retain
  their own task handles and publish the same existing UIKit bindable states.
  The controllers, layout, navigation and user-visible copy are unchanged.
- Completed: the obsolete Search interactor protocols and test doubles were
  removed. Search tests now construct `SearchMoviesFeature` with lower-level
  use-case test doubles, matching the production dependency boundary.
- Verified so far: source parsing, Xcode project plist validation and a
  whitespace review. A full typecheck/build/test run and manual Search
  regression remain required before this checkpoint can be accepted.

## Completion language

Use **“Continuing migration: <next checkpoint>”** until the CFA completion gate
has evidence for the final navigator map, every tab-owner mapping, primitive
inventory, post-change build/tests and manual architecture review. A build,
source parse or one converted callback does not justify “migration complete.”

## Account root checkpoint — in progress

- Completed: the Account tab's root UIKit controller, view model, coordinator
  and presentation protocol now appear at
  `UpcomingMovies/1 - View/Views/Account` in Xcode.
- Completed: `AccountFeature` now appears at
  `UpcomingMovies/2 - AppModel/Features/Account`. It owns the current-user
  capability directly through `AuthenticationHandlerProtocol`; the obsolete
  Account interactor boundary has been removed.
- Completed: its transitional Swinject registration now lives at
  `UpcomingMovies/2 - AppModel/Legacy Dependency Composition/AccountAssembly.swift`.
  `AccountFeatureTests` exercises the actual feature boundary.
- Verified so far: Account source parsing, Xcode project plist validation and
  a whitespace review. A full typecheck/build/test run and manual Account
  regression remain required before this checkpoint can be accepted.
- Remaining Account scope: sign-in, authentication, profile, saved-movie and
  custom-list routes are separate nested migration slices. They remain in the
  legacy route area until their ownership and behaviour are migrated visibly.

### Sign-in sub-route checkpoint — in progress

- Completed: Sign In's UIKit controller, coordinator, protocol and view model
  now appear at `1 - View/Views/Account/Sign In` in Xcode.
- Completed: `SignInFeature` appears at
  `2 - AppModel/Features/Account/Sign In`. It owns authorization-URL and
  sign-in work, shares equivalent in-flight requests, and bridges the legacy
  completion handlers into `async` operations. The view model retains a task
  handle for each user action and keeps the established bindable UI state.
- Completed: the legacy interactor protocol and its test double are removed;
  `SignInFeatureTests` exercises the real feature boundary. Its Swinject
  registration is visible in the transitional composition boundary.
- Verified so far: source parsing, project plist validation, expected source
  placement and a whitespace review. Build, tests and manual sign-in
  regression remain required before this sub-route checkpoint can be accepted.
