# Roommater

A Flutter application for finding and managing roommates, built with a feature-first clean architecture.  
The app uses **Firebase Authentication** and **Cloud Firestore** as its backend.

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | ≥ 3.4.3 | Mobile & web client |
| [Visual Studio Code](https://code.visualstudio.com/) | Latest | Recommended editor |
| [Android Studio / Android SDK](https://developer.android.com/studio) | Latest | Android emulator & SDK |
| JDK | 11 – 19 | Gradle builds (JDK 17 for Gradle 8.x) |
| [Firebase CLI](https://firebase.google.com/docs/cli) *(optional)* | Latest | Firebase deployment/emulator workflows |

Firebase project is already configured for this app: **roommater-9c830**.

---

## VS Code Setup

### 1) Install recommended extensions

```bash
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

### 2) Verify SDK paths

If VS Code does not auto-detect your Flutter SDK, set `dart.flutterSdkPath` in `.vscode/settings.json`.

### 3) Launch configurations

The repo includes pre-configured launch profiles in `.vscode/launch.json`:

| Name | Description |
|---|---|
| **Flutter: Android Emulator** | Run the Flutter app on an Android emulator |
| **Flutter: Chrome (Web)** | Run the Flutter app in Chrome |
| **Flutter: Debug (auto device)** | Run on whichever device is connected |

### 4) Build tasks

Available via **Terminal → Run Task…**:

- `flutter: pub get` – install Flutter dependencies
- `flutter: build` – build debug APK
- `flutter: analyze` – run Dart static analysis
- `flutter: test` – run Flutter tests

---

## Architecture

Roommater uses a feature-first clean architecture powered by [Riverpod](https://riverpod.dev/) and [go_router](https://pub.dev/packages/go_router).

Backend services are Firebase-native:
- **Firebase Auth** for sign-in/sign-up/sign-out and auth state
- **Cloud Firestore** for users, households, listings, chats/messages, and tasks

### `lib/` Directory Tree

```text
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app.dart
│   └── router/
│       ├── app_router.dart
│       └── app_routes.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   ├── network/
│   │   └── firestore_service.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   └── utils/
│       └── app_utils.dart
├── features/
│   ├── auth/
│   ├── chat/
│   ├── events/
│   ├── expenses/
│   ├── grocery/
│   ├── home/
│   ├── household/
│   ├── notifications/
│   ├── onboarding/
│   ├── profile/
│   ├── roommate_listing/
│   ├── settings/
│   └── tasks/
└── shared/
    ├── extensions/
    └── widgets/
```

---

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Firebase is pre-configured (`lib/firebase_options.dart` and `android/app/google-services.json`).
3. Run the app:
   ```bash
   flutter run
   ```

---

## Android setup notes

Create `android/local.properties` from the example:

```bash
cp android/local.properties.example android/local.properties
```

Then set absolute paths:

```properties
flutter.sdk=/absolute/path/to/flutter
sdk.dir=/absolute/path/to/android/sdk
```

---

## Troubleshooting

- **`android/local.properties is missing`**: create it from `android/local.properties.example`.
- **`flutter.sdk not set in local.properties`**: ensure `flutter.sdk` points to your Flutter SDK root.
- **`SDK location not found`**: ensure `sdk.dir` points to your Android SDK directory.
- **Gradle/JDK mismatch**: use JDK 17 when building with Gradle 8.x.
