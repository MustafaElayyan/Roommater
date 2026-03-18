# Roommater

A Flutter application for finding and listing roommates, built for Android-first with a cross-platform ready feature-first architecture.

---

## Architecture

Roommater uses a **feature-first clean architecture** powered by [Riverpod](https://riverpod.dev/) for state management and [go_router](https://pub.dev/packages/go_router) for navigation.

### `lib/` Directory Tree

```
lib/
├── main.dart                          # App entry point: ProviderScope + App widget
│
├── app/                               # Bootstrap & global wiring
│   ├── app.dart                       # Root MaterialApp.router with theme & router config
│   └── router/
│       ├── app_router.dart            # GoRouter provider with all route definitions
│       └── app_routes.dart            # Route path constants
│
├── core/                              # Cross-cutting concerns shared by multiple features
│   ├── constants/
│   │   └── app_constants.dart         # App-wide compile-time constants (collection names, etc.)
│   ├── errors/
│   │   ├── app_exception.dart         # Typed exceptions thrown by data-layer datasources
│   │   └── failure.dart               # Sealed domain-layer failure types
│   ├── local/
│   │   └── local_store.dart           # In-memory app data used by local datasources
│   ├── theme/
│   │   ├── app_colors.dart            # Brand colour palette constants
│   │   └── app_theme.dart             # Light and dark ThemeData definitions
│   └── utils/
│       └── app_utils.dart             # Shared utility functions (email validation, etc.)
│
├── features/                          # One sub-folder per product domain
│   │
│   ├── auth/                          # User authentication (sign-in, sign-up, sign-out)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       ├── sign_out_usecase.dart
│   │   │       └── sign_up_usecase.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   │           └── auth_form_field.dart
│   │
│   ├── onboarding/                    # First-launch carousel explaining the app value proposition
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── onboarding_page_entity.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── onboarding_controller.dart
│   │       └── screens/
│   │           └── onboarding_screen.dart
│   │
│   ├── home/                          # Main shell with bottom navigation tabs
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── home_controller.dart
│   │       └── screens/
│   │           └── home_screen.dart
│   │
│   ├── roommate_listing/              # Browse, search, and create roommate/room listings
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── listing_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── listing_model.dart
│   │   │   └── repositories/
│   │   │       └── listing_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── listing_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── listing_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_listing_usecase.dart
│   │   │       └── get_listings_usecase.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── listing_controller.dart
│   │       ├── screens/
│   │       │   ├── listing_detail_screen.dart
│   │       │   └── listing_screen.dart
│   │       └── widgets/
│   │           └── listing_card.dart
│   │
│   ├── chat/                          # Real-time messaging between matched users
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── chat_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── chat_model.dart
│   │   │   │   └── message_model.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── chat_entity.dart
│   │   │   │   └── message_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_chats_usecase.dart
│   │   │       └── send_message_usecase.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── chat_controller.dart
│   │       ├── screens/
│   │       │   ├── chat_list_screen.dart
│   │       │   └── chat_room_screen.dart
│   │       └── widgets/
│   │           └── message_bubble.dart
│   │
│   ├── profile/                       # View and edit the current user's public profile
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_profile_usecase.dart
│   │   │       └── update_profile_usecase.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── profile_controller.dart
│   │       ├── screens/
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │           └── profile_header.dart
│   │
│   └── settings/                      # Toggle dark mode, notifications, and locale
│       ├── data/
│       │   ├── models/
│       │   │   └── settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── settings_entity.dart
│       │   └── repositories/
│       │       └── settings_repository.dart
│       └── presentation/
│           ├── controllers/
│           │   └── settings_controller.dart
│           └── screens/
│               └── settings_screen.dart
│
└── shared/                            # Reusable UI components and extensions not tied to a feature
    ├── extensions/
    │   └── context_extensions.dart    # BuildContext helpers (theme, screenSize, showSnackBar)
    └── widgets/
        ├── app_button.dart            # Full-width branded ElevatedButton with loading state
        ├── app_text_field.dart        # Themed TextFormField with obscure-text toggle
        └── loading_indicator.dart     # Centred CircularProgressIndicator
```

---

### Folder Responsibilities

| Path | Responsibility |
|---|---|
| `lib/app/` | Bootstraps the app: mounts the root `App` widget, wires `ProviderScope`, and configures `GoRouter`. |
| `lib/core/` | Houses cross-cutting concerns (theme, constants, error types, local store primitives, and utilities) consumed by multiple features. |
| `lib/features/<name>/presentation/` | Contains Riverpod controllers, screens (pages), and feature-scoped widgets — no business logic. |
| `lib/features/<name>/domain/` | Pure Dart: entities, abstract repository interfaces, and use-case classes that hold business rules. |
| `lib/features/<name>/data/` | Implements repository interfaces with local datasources and converts map/auth data to domain models. |
| `lib/shared/` | Generic, feature-agnostic UI components (`AppButton`, `AppTextField`, `LoadingIndicator`) and `BuildContext` extensions. |
| **auth** | Handles local email/password sign-in and sign-up; exposes auth-state stream. |
| **onboarding** | Renders a first-launch carousel from static page data; navigates to auth choice when dismissed. |
| **home** | Provides the bottom-navigation shell that composes the listings, chats, and profile tabs. |
| **roommate_listing** | Enables users to browse paginated listings and publish new listings with photos. |
| **chat** | Delivers live local messaging between two users with stream updates. |
| **profile** | Reads and writes a user's public profile record. |
| **settings** | Manages in-app preferences (dark mode, notifications, locale) with an easily swappable storage backend. |

---

### Architecture Rationale

**Why feature-first for Roommater?**

- **Parallel development** — each of the 3 developers can own one or more features (`auth`, `chat`, `roommate_listing`) without touching the same files, minimising merge conflicts.
- **Clean separation** — the domain layer contains zero Flutter or backend imports, making business rules independently unit-testable.
- **Riverpod DI** — every datasource, repository, and use-case is exposed as an overridable `Provider`, enabling widget-test-level mocking with `ProviderScope(overrides: [...])` without a separate DI framework.
- **Local-first execution** — data and auth flows are stubbed in-memory so the app can run without external services.
- **go_router** — declarative URL-based routing ensures deep-link support (required for sharing listing URLs) and simplifies guarded navigation for authenticated routes.
- **Scalability** — adding a new feature (e.g. `roommate_matching`) requires only a new `lib/features/roommate_matching/` subtree with no changes to existing features.

---

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run the app:
   ```bash
   flutter run
   ```

---

## Firebase removal notes

- All backend SDK usage was removed from the app code and dependencies.
- Auth, profile, listings, and chat now run on in-memory local stubs so the UI stays functional.
- This fallback keeps development unblocked while avoiding runtime failures from missing remote configuration files.
