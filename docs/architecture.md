# Architecture

Feature-first clean architecture. Each feature lives in its own folder with three sub-layers:

```
lib/
├── core/                 cross-cutting stuff (theme, router, utils, shared widgets)
└── features/<feature>/
    ├── domain/           pure Dart — entities, repository interfaces, use cases
    ├── data/             repository implementations, DTOs, Firebase calls
    └── presentation/     Riverpod providers, screens, widgets
```

The dependency direction is `presentation → domain ← data`. Domain has zero Flutter imports, which means business logic is unit-testable without spinning up a widget or a Firebase emulator.

## Layers in more detail

**Domain** is pure Dart. Entities (`AppUser`, `Quiz`, `Question`, `Assignment`, `QuizResponse`, `Review`, `SeverityBand`), repository interfaces (`AuthRepository`, `QuizRepository`, `ResponseRepository`), and use cases (`ScoreResponse`). Errors come back as `Result<T, Failure>` values rather than thrown exceptions, so the type system forces callers to handle failures at compile time.

**Data** has two implementations per repository: a Firebase one for production and an in-memory one for offline mode and tests. The in-memory repos are seeded with a demo doctor, a demo patient, and a couple of assignments so the app boots and runs without any backend config. Mapping between Firestore documents and domain entities lives in `*_dto.dart` files; nothing else in the codebase touches a `DocumentSnapshot` directly.

**Presentation** uses Riverpod for state management. Provider types: repository providers that construct the right implementation, stream providers that expose live data, and `Notifier`-based controllers that wrap imperative actions (sign in, submit form) and expose loading/error state.

Routing is `go_router` with named routes. Screens don't hard-code path strings.

## Why Riverpod over the alternatives

Riverpod gives compile-time safety (no `BuildContext` needed to read providers), easy substitution in tests (override providers in the `ProviderScope`), and clean separation between repository construction and UI state. Provider and Bloc were both options. Provider is simpler but has the `BuildContext` coupling issue. Bloc is fine but more boilerplate than this project needs.

`go_router` over Navigator 1.0 because declarative routing + deep links are worth having from the start. AutoRoute was also considered but `go_router` is the official Flutter team package and less magic.

The `Result<T, Failure>` type instead of try/catch across boundaries because it forces the caller to acknowledge errors at the type level. Stack traces stay clean because failures are values, not thrown exceptions.

In-memory fallback repos instead of mocking everything in tests because it lets the whole app run end-to-end without a backend. Useful for demos and for user testing sessions where you don't want to depend on network.

## Adding a new feature

1. Create `features/<name>/` with `domain/`, `data/`, `presentation/` subfolders
2. Define entities in `domain/entities/` (pure Dart, extend `Equatable`)
3. Define the repository interface in `domain/repositories/`
4. Write two implementations in `data/` — Firebase and in-memory
5. Wire Riverpod providers in `presentation/providers/`
6. Build screens that consume those providers
7. Register routes in `core/router/route_names.dart` and `app_router.dart`
8. Unit test any scoring/validation logic; widget test non-trivial widgets

## Known gaps

Things I haven't gotten around to yet:

**No server-side scoring.** The auto-score is computed client-side at submit and stored in the response document. A Cloud Function should recompute it on the server to prevent tampering.

**No audit log.** Doctor edits to scores aren't versioned. A `reviewHistory` sub-collection would make that possible.

**No push notifications.** Doctors see real-time updates on the dashboard but don't get a notification when a patient submits. Firebase Cloud Messaging would handle this.

**One doctor per patient.** `AppUser.doctorId` is a single string. Clinics with rotating cover would need `doctorIds[]` and a receptionist role.
