# QBYT

QBYT is a focused Flutter website launcher. A user saves an HTTP or HTTPS
address and the app opens it in an embedded browser on supported platforms.

On later launches, QBYT restores the saved website automatically. Its edge
menu provides reload, change-address, and forget-address actions. When an
address is changed, the previous address remains available until the new page
loads successfully, allowing recovery from an invalid or unavailable site.

## Features

- HTTP and HTTPS address validation and normalization
- Persistent current and previous website addresses
- Embedded WebView on Android and iOS
- External-browser fallback on unsupported platforms
- Loading, timeout, offline, HTTP-error, and retry states
- Origin-aware camera, microphone, and location permission requests
- English (`en_US`) and Malay (`ms_MY`) interface text
- Unit, widget, and WebView integration tests

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
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

The native WebView integration suite requires a supported device or emulator:

```bash
flutter test integration_test/website_webview_test.dart
```

## Architecture

The website feature follows Clean Architecture with this dependency direction:

```text
presentation -> domain <- data
```

```text
lib/
├── core/                     Shared DI, routing, theme, and UI foundations
└── features/website/
    ├── domain/               Address rules, repository contract, and use cases
    ├── data/                 SharedPreferences datasource and repository
    └── presentation/         Cubits, screens, widgets, routes, helpers, and i18n
```

State is managed with `flutter_bloc`. Dependencies are registered with GetIt
and Injectable. Repository operations return `Either<Failure, T>` using
`dartz`, and navigation uses `go_router`.

After changing an Injectable annotation or constructor, regenerate
`lib/core/di/injection.config.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Hot reload

Flutter hot reload preserves existing state objects. After changing fields in a
Cubit state class, use a full restart if the running app behaves unexpectedly.
This is a development-time hot-reload limitation and does not affect release
builds.
