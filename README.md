# Roommater

A Flutter application for finding and listing roommates, built for Android-first with a cross-platform ready feature-first architecture.

---

## Architecture

Roommater uses a **feature-first clean architecture** powered by [Riverpod](https://riverpod.dev/) for state management and [go_router](https://pub.dev/packages/go_router) for navigation.

### `lib/` Directory Tree

```
lib/
├── main.dart                          # App entry point: Firebase init + ProviderScope + App widget
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
│   ├── firebase/
│   │   └── firebase_providers.dart    # Riverpod providers for FirebaseAuth, Firestore, Storage
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
| `lib/core/` | Houses cross-cutting concerns (theme, constants, error types, Firebase provider wrappers, and utilities) consumed by multiple features. |
| `lib/features/<name>/presentation/` | Contains Riverpod controllers, screens (pages), and feature-scoped widgets — no business logic. |
| `lib/features/<name>/domain/` | Pure Dart: entities, abstract repository interfaces, and use-case classes that hold business rules. |
| `lib/features/<name>/data/` | Implements repository interfaces with Firebase datasources and converts Firestore/Auth data to domain models. |
| `lib/shared/` | Generic, feature-agnostic UI components (`AppButton`, `AppTextField`, `LoadingIndicator`) and `BuildContext` extensions. |
| **auth** | Handles email/password sign-in and sign-up via Firebase Auth; exposes auth-state stream. |
| **onboarding** | Renders a first-launch carousel from static page data; navigates to auth choice when dismissed. |
| **home** | Provides the bottom-navigation shell that composes the listings, chats, and profile tabs. |
| **roommate_listing** | Enables users to browse paginated Firestore listings and publish new listings with photos. |
| **chat** | Delivers real-time Firestore messaging between two users with live message streams. |
| **profile** | Reads and writes a user's public profile document in Firestore, including avatar upload. |
| **settings** | Manages in-app preferences (dark mode, notifications, locale) with an easily swappable storage backend. |

---

### Architecture Rationale

**Why feature-first for Roommater?**

- **Parallel development** — each of the 3 developers can own one or more features (`auth`, `chat`, `roommate_listing`) without touching the same files, minimising merge conflicts.
- **Clean separation** — the domain layer contains zero Flutter or Firebase imports, making business rules independently unit-testable.
- **Riverpod DI** — every datasource, repository, and use-case is exposed as an overridable `Provider`, enabling widget-test-level mocking with `ProviderScope(overrides: [...])` without a separate DI framework.
- **Firebase-ready without hardcoded secrets** — `google-services.json` / `GoogleService-Info.plist` are consumed by the native build system; Dart code only calls `Firebase.initializeApp()` with no API keys.
- **go_router** — declarative URL-based routing ensures deep-link support (required for sharing listing URLs) and simplifies guarded navigation for authenticated routes.
- **Scalability** — adding a new feature (e.g. `roommate_matching`) requires only a new `lib/features/roommate_matching/` subtree with no changes to existing features.

---

## Getting Started

### 1) Install Flutter dependencies

```bash
flutter pub get
```

### 2) Add Firebase config files

- Android: place `google-services.json` in `android/app/`
- iOS: place `GoogleService-Info.plist` in `ios/Runner/`

### 3) Create `android/local.properties` (required)

The Android build reads `flutter.sdk` from `android/local.properties`.
That file is machine-specific and intentionally not committed.

Copy the example file and edit absolute paths:

```bash
cp android/local.properties.example android/local.properties
```

Then set:

```properties
flutter.sdk=/absolute/path/to/flutter
sdk.dir=/absolute/path/to/android/sdk
```

Path examples by OS:

- **macOS/Linux** `flutter.sdk=/Users/<you>/development/flutter` or `/home/<you>/flutter`
- **Windows** `flutter.sdk=C:\\src\\flutter` and `sdk.dir=C:\\Users\\<you>\\AppData\\Local\\Android\\Sdk`

### 4) Java/JDK requirement for Gradle

- This repo currently uses Gradle **7.6.3** (`android/gradle/wrapper/gradle-wrapper.properties`), which works with JDK 11–19.
- If you are on a project/branch using Gradle **8.4**, use **JDK 17** (recommended).

Check Java:

```bash
java -version
```

If needed, point Gradle to JDK 17:

```bash
export JAVA_HOME=/path/to/jdk-17
```

### 5) Run from a fresh clone

```bash
flutter doctor -v
flutter pub get
flutter clean
flutter pub get
flutter run
```

If no device is detected:

```bash
flutter devices
flutter emulators
flutter emulators --launch <emulator_id>
```

### Common Android troubleshooting

- **`android/local.properties is missing`**: create it from `android/local.properties.example`.
- **`flutter.sdk not set in local.properties`**: verify `flutter.sdk` points to your Flutter SDK root.
- **`SDK location not found`**: verify `sdk.dir` points to your Android SDK directory.
- **Google Services plugin errors**: confirm `android/app/google-services.json` exists and package name matches.
- **Gradle/JDK mismatch**: use JDK 17 when building with Gradle 8.x.
