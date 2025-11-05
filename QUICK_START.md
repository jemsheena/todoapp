# Quick Start Guide

Get up and running with the Todo App in minutes.

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Your IDE of choice (VS Code, Android Studio, IntelliJ)

## Initial Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code

The project uses code generation for:
- Freezed (immutable data classes)
- JSON serialization
- Riverpod providers (future)

Run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Tip:** Use `watch` mode during development for auto-generation:
```bash
flutter pub run build_runner watch
```

### 3. Configure Environment

Create environment files in the root directory:

**.env.dev** (for local development):
```env
ENVIRONMENT=dev
BASE_URL=http://localhost:3000/api
API_KEY=your-dev-api-key
SENTRY_DSN=
ENABLE_LOGGING=true
```

**.env.stage** and **.env.prod** follow the same format.

### 4. Run the App

**Development:**
```bash
flutter run --dart-define=FLAVOR=dev
```

**With a specific device:**
```bash
flutter run -d chrome --dart-define=FLAVOR=dev
```

## Project Structure Quick Reference

```
lib/
├── app/              # App initialization, routing, theme
├── core/             # Shared utilities, network, storage
└── features/         # Feature modules
    ├── auth/         # Authentication
    └── feed/         # Feed/Timeline
```

## Common Tasks

### Adding a New Feature

1. Create feature folder: `lib/features/my_feature/`
2. Add three layers:
   - `domain/` - entities, use cases, repository interfaces
   - `data/` - DTOs, data sources, repository implementations
   - `presentation/` - screens, widgets, controllers

3. Add route in `lib/app/router.dart`

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/auth/domain/use_cases/sign_in_use_case_test.dart

# With coverage
flutter test --coverage
```

### Building for Release

**Android APK:**
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

## Troubleshooting

### Code Generation Issues

If you see import errors for `.freezed.dart` or `.g.dart` files:
1. Run `flutter pub get`
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Environment File Not Found

Ensure `.env.dev`, `.env.stage`, or `.env.prod` exist in the project root.

### Build Errors

1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Check Flutter/Dart versions:
   ```bash
   flutter doctor
   ```

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture
- Check [README.md](README.md) for full documentation
- Review the auth feature as a reference implementation

## Getting Help

- Check existing TODOs in code (marked with `// TODO:`)
- Review error messages - they often point to missing setup
- Ensure all environment variables are set correctly


