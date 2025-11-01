# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

Flutter/Dart monorepo using Pub workspaces (root `pubspec.yaml` has a `workspace:` list) with:
- Apps: `apps/polka_clients`, `apps/polka_masters`, `apps/polka_online`
- Packages: `packages/shared` (shared UI, data, and utilities) and `packages/calendar_view` (local calendar UI lib)

State management centers on `flutter_bloc` (Cubits) with feature-oriented folders. Networking uses `dio`, persistence via `flutter_secure_storage`, logging via `talker`. The `shared` package hosts common models, repositories, widgets, and features (auth, chats, onboarding, pagination, theme). `polka_masters` also depends on the local `calendar_view` package.

Lints are enabled via `analysis_options.yaml` including `flutter_lints`.

## Common Commands

Run all commands inside the relevant app/package directory unless noted. Workspace resolution lets you run dependency commands from the repo root.

### Install/Update dependencies

- From the root (resolves the entire workspace):
  ```bash
  flutter pub get
  ```
- From a specific app/package (if needed):
  ```bash
  (cd apps/polka_clients && flutter pub get)
  (cd apps/polka_masters && flutter pub get)
  (cd apps/polka_online && flutter pub get)
  (cd packages/shared && flutter pub get)
  (cd packages/calendar_view && flutter pub get)
  ```

### Run apps (development)

- Run on a connected simulator/device (replace <device_id> as needed):
  ```bash
  cd apps/polka_clients && flutter run -d <device_id>
  cd apps/polka_masters && flutter run -d <device_id>
  cd apps/polka_online  && flutter run -d <device_id>
  ```

### Build releases

- Android APK (debug/release):
  ```bash
  cd apps/polka_clients && flutter build apk --release
  cd apps/polka_masters && flutter build apk --release
  ```
- Android App Bundle (Play Store):
  ```bash
  cd apps/polka_clients && flutter build appbundle --release
  cd apps/polka_masters && flutter build appbundle --release
  ```
- iOS (requires Xcode setup):
  ```bash
  cd apps/polka_clients && flutter build ios --release
  cd apps/polka_masters && flutter build ios --release
  ```

### Analyze and format

- Static analysis (workspace or per package):
  ```bash
  flutter analyze
  ```
- Format code:
  ```bash
  dart format .
  ```

### Tests

- Run all tests in a package:
  ```bash
  cd apps/polka_online && flutter test
  ```
- Run a single test file:
  ```bash
  cd apps/polka_online && flutter test test/widget_test.dart
  ```
- Run tests matching a name:
  ```bash
  cd apps/polka_online && flutter test --plain-name "Counter increments"
  ```
- Collect coverage (where supported):
  ```bash
  cd apps/polka_online && flutter test --coverage
  ```

### Code generation (shared package)

`packages/shared` uses `freezed` and `build_runner`. When editing annotated models, run:
```bash
cd packages/shared && dart run build_runner build --delete-conflicting-outputs
```
For continuous generation during development:
```bash
cd packages/shared && dart run build_runner watch --delete-conflicting-outputs
```

## Architecture and structure

- Workspace layout
  - Root `pubspec.yaml` defines the workspace; dependencies can be resolved from the root. Apps depend on `packages/shared`; `polka_masters` also depends on `packages/calendar_view` via a local path.

- Apps
  - Each app in `apps/` follows a feature-first structure (e.g., `features/booking`, `features/calendar`, `features/auth`).
  - State is managed with Cubits (`flutter_bloc`), e.g., `.../controller/*_cubit.dart` with associated `*_state.dart`.
  - Data access is via repositories (e.g., `bookings_repo.dart`, `contacts_repo.dart`) using `dio` and WebSockets where applicable.
  - UI is composed of screens/pages and reusable widgets per feature, leveraging shared theme and components from `packages/shared`.

- Shared package (`packages/shared`)
  - Cross-cutting features: auth flow, chats (WebSocket), onboarding, pagination utilities, theming, common widgets, and bottom sheets.
  - Core infrastructure: `dio` factory/interceptors, secure storage, logging (`talker`), result/error types, and extensions.
  - Domain models under `lib/src/models/**` with typed entities for booking, schedule, master, service, etc.
  - Provides fonts and assets that apps reference in their `pubspec.yaml`.

- Calendar package (`packages/calendar_view`)
  - Local UI library for calendar views and event arrangements used by `polka_masters`.

## Notes

- Linting: enforced via `analysis_options.yaml` (root and packages). Use `flutter analyze` to check.
- Workspace resolution: sub-packages can specify `resolution: workspace`; running `flutter pub get` at the root is typically sufficient.
- When adding/changing `freezed` models or builders in `packages/shared`, run the code generation commands above to keep generated files up to date.
