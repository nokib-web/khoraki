# Khoraki Architecture & Feature Pattern

This codebase follows **Clean Architecture** with a **Feature-First** modular organization.

## Directory Layout

```
lib/
  core/
    constants/       # App constants (colors, strings, firestore paths)
    theme/           # Material 3 design system and themes
    utils/           # Utility functions (date formatting, currency formatting)
    widgets/         # Shared reusable UI widgets (primary_button, loading_indicator, app_text_field)
    services/        # Low-level service wrappers (firestore_service, auth_service, notification_service)
    router/          # Central navigation using GoRouter
  features/
    <feature_name>/
      data/
        models/       # Data transfer objects with toJson / fromJson
        repositories/ # Repository implementations (talks to core/services)
      domain/
        entities/     # Core business objects
        repositories/ # Abstract repository interfaces
      presentation/
        providers/    # Riverpod state providers and notifiers
        screens/      # Feature screens/pages
        widgets/      # Feature-specific UI widgets
  main.dart
```

## Architectural Rules

1. **Presentation Layer**: 
   - Presentation (Screens & Widgets) **NEVER** accesses `FirestoreService`, `AuthService`, or raw APIs directly.
   - It only interacts with Riverpod providers in `presentation/providers/`, which consume domain repository interfaces.

2. **Domain Layer**:
   - Contains pure business logic, entities, and abstract repository contracts.
   - Depends on nothing outside the domain.

3. **Data Layer**:
   - Implements abstract repository interfaces defined in `domain/repositories/`.
   - Maps raw API data/documents into domain entities.
   - Interacts with core services (`FirestoreService`, `AuthService`, etc.).

4. **Consistency**:
   - Every single feature added to `lib/features/` **MUST** follow this exact layer separation without exception.
