# Todo App - Flutter Clean Architecture

A production-ready Flutter application following clean architecture principles with offline-first capabilities, comprehensive error handling, and scalable structure.

## Architecture Overview

This app follows a **layered clean architecture** with clear separation of concerns:

### Layers

1. **Presentation Layer** (`lib/features/*/presentation/`)
   - UI widgets and screens
   - State management (Riverpod)
   - Navigation (go_router)

2. **Domain Layer** (`lib/features/*/domain/`)
   - Business logic (pure Dart, testable)
   - Entities and Value Objects
   - Use Cases (Interactors)
   - Repository interfaces

3. **Data Layer** (`lib/features/*/data/`)
   - Repository implementations
   - Data Sources (Remote API, Local DB)
   - DTOs and Mappers

4. **Core Layer** (`lib/core/`)
   - Network client (Dio with interceptors)
   - Storage (Isar, Secure Storage)
   - Error handling
   - Utilities

## Features

- ✅ Clean Architecture (Domain, Data, Presentation)
- ✅ State Management with Riverpod
- ✅ Offline-first with Isar local database
- ✅ Network resilience (retry, error mapping)
- ✅ Secure token storage
- ✅ Error tracking (Sentry)
- ✅ Environment-based configuration
- ✅ Material 3 design
- ✅ Type-safe navigation (go_router)

## Setup

### Prerequisites

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (for freezed, json_serializable, etc.):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Set up environment files:
   - Copy `.env.dev`, `.env.stage`, `.env.prod` and fill in your configuration
   - Ensure these files are in the root directory

### Running the App

**Development:**
```bash
flutter run --dart-define=FLAVOR=dev
```

**Staging:**
```bash
flutter run --dart-define=FLAVOR=stage
```

**Production:**
```bash
flutter run --dart-define=FLAVOR=prod
```

## Project Structure

```
lib/
├── app/                    # App configuration
│   ├── app.dart           # Root widget
│   ├── bootstrap.dart     # Initialization
│   ├── router.dart        # Navigation
│   └── theme/             # Theme configuration
├── core/                   # Core functionality
│   ├── error/             # Error types and handling
│   ├── network/           # Dio client, interceptors
│   ├── storage/           # Isar, Secure Storage
│   └── util/              # Utilities, Result type
└── features/              # Feature modules
    ├── auth/              # Authentication feature
    │   ├── domain/        # Entities, Use Cases, Repos
    │   ├── data/          # DTOs, Data Sources, Repo Impl
    │   └── presentation/  # Screens, Widgets, Controllers
    └── feed/              # Feed feature
        └── ...
```

## Data Flow

1. **UI** triggers a **Use Case**
2. Use Case calls **Repository Interface**
3. **Repository Implementation** checks cache, then remote API
4. Response mapped `DTO → Entity` → returned to UI
5. State updated via Riverpod → UI rebuilds

## Testing

Run all tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## Code Generation

After modifying entities/DTOs with freezed or json_annotation, regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (auto-regenerate):
```bash
flutter pub run build_runner watch
```

## Building for Release

**Android:**
```bash
flutter build apk --release --dart-define=FLAVOR=prod
```

**iOS:**
```bash
flutter build ios --release --dart-define=FLAVOR=prod
```

**Web:**
```bash
flutter build web --release --dart-define=FLAVOR=prod
```

## Next Steps

- [ ] Complete AuthRepository provider setup
- [ ] Implement Feed feature with offline-first
- [ ] Add OpenTelemetry instrumentation
- [ ] Set up CI/CD pipeline
- [ ] Add localization files
- [ ] Implement feature flags
- [ ] Add comprehensive tests

## License

MIT


