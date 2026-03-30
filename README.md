# Roommater

A Flutter application for finding and listing roommates, built for Android-first with a cross-platform ready feature-first architecture. The backend is an **ASP.NET Core 8 Web API** with a **MySQL** database.

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | ≥ 3.4.3 | Mobile & web client |
| [.NET SDK](https://dotnet.microsoft.com/download) | 8.0 | Backend API |
| [MySQL](https://dev.mysql.com/downloads/) | 8.0+ | Database |
| [Visual Studio Code](https://code.visualstudio.com/) | Latest | Recommended editor |
| [Android Studio / Android SDK](https://developer.android.com/studio) | Latest | Android emulator & SDK |
| JDK | 11 – 19 | Gradle builds (JDK 17 for Gradle 8.x) |

---

## VS Code Setup

### 1) Install recommended extensions

Open the project in VS Code and accept the prompt to install recommended extensions, or run:

```
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-dotnettools.vscode-dotnet-runtime
```

### 2) Verify SDK paths

If VS Code does not auto-detect your Flutter SDK, open **Settings** (Ctrl+,) and set `dart.flutterSdkPath` to your Flutter install directory in `.vscode/settings.json`.

### 3) Launch configurations

The repo includes pre-configured launch profiles in `.vscode/launch.json`:

| Name | Description |
|---|---|
| **Flutter: Android Emulator** | Run the Flutter app on an Android emulator |
| **Flutter: Chrome (Web)** | Run the Flutter app in Chrome |
| **Flutter: Debug (auto device)** | Run on whichever device is connected |
| **.NET API** | Build and launch the ASP.NET Core backend |
| **Full Stack (API + Flutter)** | Launch both the API and Flutter app together |

Press **F5** or open the **Run and Debug** panel (Ctrl+Shift+D) to select a configuration.

### 4) Build tasks

Available via **Terminal → Run Task…** (Ctrl+Shift+B for default build):

- `flutter: pub get` – install Flutter dependencies
- `flutter: build` – build debug APK
- `flutter: analyze` – run Dart static analysis
- `flutter: test` – run Flutter tests
- `dotnet: restore API` – restore NuGet packages
- `dotnet: build API` – build the backend (default build task)
- `dotnet: run API` – start the API server
- `dotnet: ef update database` – apply EF Core migrations

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
│   ├── network/
│   │   └── api_client.dart            # HTTP client for the ASP.NET Core API
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
| `lib/core/` | Houses cross-cutting concerns (theme, constants, error types, HTTP API client, and utilities) consumed by multiple features. |
| `lib/features/<name>/presentation/` | Contains Riverpod controllers, screens (pages), and feature-scoped widgets — no business logic. |
| `lib/features/<name>/domain/` | Pure Dart: entities, abstract repository interfaces, and use-case classes that hold business rules. |
| `lib/features/<name>/data/` | Implements repository interfaces with API datasources and converts JSON responses to domain models. |
| `lib/shared/` | Generic, feature-agnostic UI components (`AppButton`, `AppTextField`, `LoadingIndicator`) and `BuildContext` extensions. |
| **auth** | Handles email/password sign-in and sign-up via the REST API; stores JWT for authenticated requests. |
| **onboarding** | Renders a first-launch carousel from static page data; navigates to auth choice when dismissed. |
| **home** | Provides the bottom-navigation shell that composes the listings, chats, and profile tabs. |
| **roommate_listing** | Enables users to browse paginated listings and publish new listings with photos. |
| **chat** | Delivers messaging between users via the API. |
| **profile** | Reads and writes a user's public profile, including avatar upload. |
| **settings** | Manages in-app preferences (dark mode, notifications, locale) with an easily swappable storage backend. |

---

### Architecture Rationale

**Why feature-first for Roommater?**

- **Parallel development** — each of the 3 developers can own one or more features (`auth`, `chat`, `roommate_listing`) without touching the same files, minimising merge conflicts.
- **Clean separation** — the domain layer contains zero Flutter or backend-specific imports, making business rules independently unit-testable.
- **Riverpod DI** — every datasource, repository, and use-case is exposed as an overridable `Provider`, enabling widget-test-level mocking with `ProviderScope(overrides: [...])` without a separate DI framework.
- **Configuration without hardcoded secrets** — sensitive configuration lives in `appsettings.json` (overridable via environment variables); Dart code accesses the API through a single `ApiClient` with JWT auth.
- **go_router** — declarative URL-based routing ensures deep-link support (required for sharing listing URLs) and simplifies guarded navigation for authenticated routes.
- **Scalability** — adding a new feature (e.g. `roommate_matching`) requires only a new `lib/features/roommate_matching/` subtree with no changes to existing features.

---

## Getting Started

### 1) Install Flutter dependencies

```bash
flutter pub get
```

### 2) Set up the backend API

The backend is an ASP.NET Core 8 Web API that uses MySQL. See [`Roommater.API/README.md`](Roommater.API/README.md) for full details.

**Quick start:**

```bash
# Restore .NET tools (EF Core CLI)
dotnet tool restore

# Restore NuGet packages
dotnet restore Roommater.API/Roommater.API.csproj

# Build
dotnet build Roommater.API/Roommater.API.csproj
```

Before running, create a MySQL database and user, then update the connection string:

```bash
# Option A: edit appsettings.json directly
# Option B: override via environment variable
ConnectionStrings__DefaultConnection="Server=localhost;Port=3306;Database=RoommaterDb;User=roommater_dev;Password=<your-password>;" \
dotnet run --project Roommater.API/Roommater.API.csproj
```

The API starts at `http://localhost:5073` with Swagger at `http://localhost:5073/swagger`.

### 3) Create `android/local.properties` (required for Android builds)

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
- **Gradle/JDK mismatch**: use JDK 17 when building with Gradle 8.x.
