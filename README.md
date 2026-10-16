# Sandbox

Sandbox is a clean Flutter starter app with a simple login and menu flow.

## Features

- Username and password validation
- In-memory login session
- Starter menu with placeholder items
- Logout action
- Centralized `go_router` navigation
- Authenticated `StatefulShellRoute` with preserved tab navigation
- Role-aware bottom navigation (member and administrator)
- English and Malay JSON translations
- Persisted locale selection
- GetIt/Injectable dependency injection
- Bloc/Cubit state foundation
- Shared theme and reusable widgets
- Widget test for the complete flow

## Requirements

- Flutter 3.27 or newer
- Dart 3.6 or newer
- A platform toolchain for the device being targeted

## Getting started

```bash
flutter pub get
flutter run
```

## Quality checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Architecture

Each feature follows Clean Architecture with this dependency direction:

```text
presentation -> domain <- data
```

```text
lib/
├── bloc/                     Global Bloc observer
├── core/                     Shared DI, routing, theme, state, and UI foundations
└── features/
    ├── auth/
    │   ├── domain/           User entity, repository contract, and login use case
    │   ├── data/             Local datasource and repository implementation
    │   └── presentation/     Cubit, screen, routes, and feature i18n
    └── menu/
        ├── domain/           Menu entity, repository contract, and use case
        ├── data/             Local datasource and repository implementation
        └── presentation/     Cubit, screen, routes, and feature i18n
```

State is managed with `flutter_bloc`. Dependencies are registered with GetIt
and Injectable. Repository operations return `Either<Failure, T>` using
`dartz`, and navigation uses `go_router`.

Each feature owns its English and Malay JSON files under `presentation/i18n`.
When adding a feature, register its i18n directory in `translationDirectories`
inside `lib/core/localization/app_localizations.dart` and add that directory to
the Flutter assets in `pubspec.yaml`.

Light and dark themes share a Material 3 component system. The selected theme
and locale are persisted with SharedPreferences.

The application shell lives in `lib/core/widgets/app_shell.dart`. It wraps all
authenticated branches and preserves each tab's navigator stack. The starter
login assigns the administrator role to the username `admin`; other usernames
use the member navigation set. Replace this local role assignment when wiring a
real authentication API.

After changing injectable classes, regenerate the DI configuration:

```bash
dart run build_runner build --delete-conflicting-outputs
```
