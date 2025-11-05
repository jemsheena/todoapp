# Architecture Documentation

This document provides a deep dive into the application architecture, data flow, and design decisions.

## Architecture Layers

### 1. Presentation Layer (`lib/features/*/presentation/`)

**Responsibility:** UI rendering, user interaction, state management

- **Screens:** Full-page widgets that compose smaller widgets
- **Widgets:** Reusable UI components
- **Controllers:** Riverpod StateNotifiers that manage feature-specific state
- **State:** Immutable state classes (often using freezed)

**Example Flow:**
```
User taps "Sign In" 
→ LoginScreen calls AuthController.signIn()
→ Controller updates state (isLoading: true)
→ Use Case executes
→ Controller receives result, updates state
→ UI rebuilds with new state
```

### 2. Domain Layer (`lib/features/*/domain/`)

**Responsibility:** Business logic, rules, and interfaces

- **Entities:** Core business objects (User, FeedItem, etc.)
- **Value Objects:** Immutable objects with validation (Email, Token)
- **Use Cases:** Single-purpose operations that orchestrate repository calls
- **Repository Interfaces:** Contracts for data access (no implementation details)

**Key Principles:**
- Pure Dart (no Flutter dependencies)
- Framework-agnostic
- Highly testable
- No side effects (except through repository interfaces)

### 3. Data Layer (`lib/features/*/data/`)

**Responsibility:** Data fetching, caching, and persistence

- **DTOs:** Data Transfer Objects matching API/DB schemas
- **Mappers:** Convert between DTOs and Domain entities
- **Data Sources:** 
  - Remote: HTTP/GraphQL API calls
  - Local: Database (Isar), Key-Value (SharedPreferences), Secure Storage
- **Repository Implementations:** Fulfill domain repository contracts

**Offline-First Strategy:**
1. Check local cache first
2. Return cached data immediately
3. Fetch from remote in background
4. Merge and update cache
5. Emit updated data to UI

### 4. Core Layer (`lib/core/`)

**Responsibility:** Cross-cutting concerns and infrastructure

- **Network:** Dio client with interceptors (auth, retry, logging)
- **Storage:** Isar DB, Secure Storage, SharedPreferences wrappers
- **Error Handling:** Failure types, error mappers, global handlers
- **Utilities:** Result type, validators, extensions

## Data Flow (Happy Path)

```
┌─────────┐
│   UI    │ User action triggers use case
└────┬────┘
     │
     ▼
┌─────────────┐
│ Use Case    │ Validates input, orchestrates
└────┬────────┘
     │
     ▼
┌─────────────┐
│ Repository  │ Interface (domain)
│ Interface   │
└────┬────────┘
     │
     ▼
┌─────────────┐
│ Repository  │ Implementation (data)
│   Impl      │
└────┬────────┘
     │
     ├──► Local DS ──► Cache/DB ──► Return immediately
     │
     └──► Remote DS ──► API ──► Merge & Update Cache
```

## Error Handling

All errors are mapped to domain `Failure` types:

- **ServerFailure:** HTTP 5xx, API errors
- **NetworkFailure:** No connection, timeouts
- **AuthFailure:** 401/403, token expired
- **CacheFailure:** Local storage errors
- **TimeoutFailure:** Request timeouts
- **UnknownFailure:** Unexpected errors

Use Cases return `Result<T>` which is `Either<Failure, T>`. Controllers handle failures and update state with error messages.

## State Management (Riverpod)

**Providers:**
- `Provider`: Read-only values, services
- `StateProvider`: Simple mutable state
- `StateNotifierProvider`: Complex state with logic (controllers)
- `FutureProvider`: Async data loading
- `StreamProvider`: Reactive streams

**Best Practices:**
- Keep providers focused and scoped
- Use `ref.read()` for one-time access (callbacks)
- Use `ref.watch()` for reactive updates (build methods)
- Avoid provider dependencies that create cycles

## Testing Strategy

### Unit Tests
- **Domain:** Use cases, entities, value objects (pure Dart)
- **Data:** Repository implementations, mappers, data sources (with mocks)

### Widget Tests
- Individual widgets with mocked providers
- Test user interactions and UI updates

### Integration Tests
- Full feature flows
- Real repositories with test databases/APIs

## Dependency Injection

Using Riverpod for DI:
- Providers defined at module level
- Override in tests with fake implementations
- Scoped providers for feature-specific dependencies

## Security

- **Tokens:** Stored in `FlutterSecureStorage` (encrypted)
- **TLS:** Pin certificates in production
- **API Keys:** Only via environment variables, never in code
- **Sensitive Data:** Never log in production

## Performance

- **Code Splitting:** Feature-based modules
- **Lazy Loading:** Routes loaded on demand
- **Image Caching:** Use `cached_network_image`
- **List Optimization:** `ListView.builder` for large lists
- **State Updates:** Minimize rebuilds with `select()`

## Future Enhancements

- [ ] Add BLoC as alternative state management
- [ ] Implement feature flags
- [ ] Add comprehensive analytics
- [ ] Set up OpenTelemetry tracing
- [ ] Add push notifications
- [ ] Implement background sync
- [ ] Add biometric authentication
- [ ] Set up A/B testing framework


