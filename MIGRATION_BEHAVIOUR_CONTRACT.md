# UpcomingMovies Migration Behaviour Contract

## Migration failure log — 26 October 2026

**Status: failed pilot; not a completed CFA migration.**

The work changed one callback route inside the existing legacy scene layout.
When Matthew Thomas opened the project, the Xcode navigator still presented the
same legacy `DependencyInjection`, `ViewComponents`, `Scenes`, `Storyboards`
and `Helpers` structure. That means the project did not visibly communicate CFA
feature ownership, and the work had not met the migration goal.

The earlier statement that the migration was complete was incorrect. Source
parsing and a pre-change test baseline are not evidence of a completed
architecture migration. This pilot must not be used as a CFA example, training
case, or precedent. Any restart must begin with an approved visible target
structure, feature-by-feature migration milestones, post-change test evidence,
and a final navigator review before completion can be claimed.

This contract describes observed and inferred product behaviour at upstream
baseline commit `d07c8853630c853d4d4cb8f3defb783bb664e48a`. A Simulator build
and the 308-test suite passed before the route change. The first scope is the
**Upcoming Movies** tab's list-loading route.

| ID | Plain-English requirement | Legacy evidence | Evidence status | Baseline | Replacement protection | Post-migration result | Manual regression | Difference and approval |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | When the Upcoming Movies screen first appears, it requests the current page of upcoming movies and presents an initial loading indicator. | `UpcomingMoviesViewController.viewDidLoad`; `UpcomingMoviesViewModel.getMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Focused ViewModel test plus pending normal-Terminal suite | Implemented; verification pending | Launch tab and observe initial load | None |
| BEH-002 | When the user pulls to refresh Upcoming Movies, the screen requests page one and ends the refresh control after reloading the collection. | `UpcomingMoviesViewController.setupRefreshControl`; `reloadCollectionView`; `UpcomingMoviesViewModel.refreshMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Owned request task; pending normal-Terminal suite | Implemented; verification pending | Pull to refresh with populated and failed responses | None |
| BEH-003 | When the existing list state permits prefetching, displaying further collection items requests the next movies page. | `UpcomingMoviesViewController.reloadCollectionView`; `CollectionViewDataSourcePrefetching` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Feature-level latest-request policy; pending normal-Terminal suite | Implemented; verification pending | Scroll through a multi-page result | A newer page-one refresh suppresses an older prefetch result so stale data cannot redraw the list. |
| BEH-004 | When movie loading fails, the screen presents the existing retry UI and retry requests the first page. | `UpcomingMoviesViewController.configureView`; `UpcomingMoviesViewModel.fetchMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Controlled failing-provider test plus pending normal-Terminal suite | Implemented; verification pending | Simulate failure and tap retry | A successful network response with no payload now reports `APIError.invalidData`; it no longer leaves the callback route unresolved. |

## Baseline limitations

The upstream project requires CocoaPods. Its dependencies were installed on
25 October 2026. A device build still requires the upstream project's private
Apple development profiles. A normal-Terminal Simulator workspace build passed
after the SwiftLint development dependency was updated; that establishes
compilation and linking. The `UpcomingMoviesTests` scheme then passed 308 tests
with zero failures. A manual app journey has not yet run.

The initial normal-Terminal workspace build reached the app target but stopped
in the SwiftLint script phase: locked SwiftLint 0.41.0 contained an x86_64-only
binary, while this Apple Silicon machine has no Rosetta translation. Updating
only that development dependency to SwiftLint 0.65.1 preserved linting and
allowed the Simulator build to pass. This was a tooling compatibility update,
not an application-behaviour change.

## Route inventory

The observed initial route is:

```text
UpcomingMoviesViewController
  → UpcomingMoviesViewModel
  → UpcomingMoviesFeature
  → MovieRepository
  → MovieRemoteDataSource
  → MovieClient / URLSession
```

`UpcomingMoviesFeature` now bridges the legacy use-case completion exactly once
through a checked throwing continuation. It coalesces duplicate page loads and
uses a latest-request-wins policy across different pages: a user-initiated
refresh is more current than an earlier prefetch, so the stale prefetch result
is cancelled before it can publish. The ViewModel owns the corresponding named
page tasks and deliberately ignores that cancellation rather than presenting it
as an error.

The `MovieRemoteDataSource` had a successful-response path with no payload
that returned without calling its completion. That would leave a continuation
suspended indefinitely, so this one in-scope error behaviour is now explicit:
the route returns `APIError.invalidData` and retains the existing retry UI.

The migrated route must still pass the normal-Terminal test suite and receive a
manual UIKit regression before it can claim behavioural equivalence.

## Current migration status

**Continuing migration: moving the complete Upcoming Movies route into the
visible CFA folder map, then re-running its build, tests and manual regression.**

See `MIGRATION_PLAN.md` for the tab ownership map, visible destination and
remaining completion checkpoints. No final migration claim is permitted until
the plan's explicit application-level completion evidence exists.
