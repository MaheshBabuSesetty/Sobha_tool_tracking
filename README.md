# Power Tool Tracking

Enterprise-grade Flutter application for construction site power tool management with complete offline support.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Environment Setup](#environment-setup)
- [Flavor Configuration](#flavor-configuration)
- [Build Commands](#build-commands)
- [Android Setup](#android-setup)
- [iOS Setup](#ios-setup)
- [Firebase Setup](#firebase-setup)
- [Running Tests](#running-tests)
- [Code Generation](#code-generation)
- [Release Guide](#release-guide)

---

## Architecture Overview

This project follows **Clean Architecture** with **SOLID principles**:

```
Presentation  →  Domain  ←  Data
    BLoC           Entities     Repositories (impl)
    Pages          UseCases     Data Sources
    Widgets        Repositories Models / DTOs
    Routes         (abstract)   Local DB (Drift)
                                Remote API (Dio)
```

**State Management:** flutter_bloc + bloc_concurrency  
**Offline-First:** All operations write to Drift local DB first, then sync  
**DI:** GetIt service locator  
**Navigation:** GoRouter with auth guards  

---

## Project Structure

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── constants/           # API, app, storage constants
│   ├── dependency_injection/# GetIt service locator
│   ├── errors/              # Failures + exceptions
│   ├── extensions/          # Dart/Flutter extensions
│   ├── network/             # Dio + interceptors
│   ├── services/            # Firebase, connectivity, security
│   ├── storage/             # Secure storage, SharedPreferences
│   ├── theme/               # Material 3 theming
│   └── utils/               # Logger, validators, Result type
│
├── data/                    # Data layer
│   ├── database/            # Drift DB, tables, DAOs
│   ├── datasources/         # Remote (Dio) + Local (Drift)
│   ├── mappers/             # Model ↔ Entity conversions
│   ├── models/              # JSON-serializable DTOs
│   └── repositories/        # Repository implementations
│
├── domain/                  # Business logic (pure Dart)
│   ├── entities/            # Core domain models
│   ├── repositories/        # Abstract repository contracts
│   └── usecases/            # Single-responsibility use cases
│
├── flavors/                 # Environment configuration
│   └── environment_config.dart
│
├── presentation/            # UI layer
│   ├── blocs/               # BLoC state management
│   ├── pages/               # Screen-level widgets
│   ├── routes/              # GoRouter configuration
│   └── widgets/             # Reusable components
│
├── main_dev.dart            # DEV entry point
├── main_uat.dart            # UAT entry point
└── main_prod.dart           # PROD entry point
```

---

## Environment Setup

### Prerequisites

- Flutter SDK ≥ 3.22.0
- Dart ≥ 3.3.0
- Xcode 15+ (iOS)
- Android Studio / JDK 17 (Android)
- Firebase CLI (`npm install -g firebase-tools`)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/power-tool-tracking.git
cd power_tool_tracking

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Set up environment files (copy examples and fill in values)
cp .env.example .env.dev
cp .env.example .env.uat
cp .env.example .env.prod
```

### Environment Files

| File | Purpose |
|------|---------|
| `.env.dev` | Development API + Firebase |
| `.env.uat` | UAT API + Firebase |
| `.env.prod` | Production API + Firebase |
| `.env.example` | Template (committed to git) |

---

## Flavor Configuration

| Flavor | Bundle ID | App Name |
|--------|-----------|----------|
| `dev` | `com.company.powertracking.dev` | PowerTrack Dev |
| `uat` | `com.company.powertracking.uat` | PowerTrack UAT |
| `prod` | `com.company.powertracking` | Power Tool Tracking |

---

## Build Commands

### Run

```bash
# DEV
flutter run --flavor dev -t lib/main_dev.dart

# UAT
flutter run --flavor uat -t lib/main_uat.dart

# PROD
flutter run --flavor prod -t lib/main_prod.dart
```

### APK Builds

```bash
# DEV debug APK
flutter build apk --flavor dev -t lib/main_dev.dart --debug

# UAT release APK
flutter build apk --flavor uat -t lib/main_uat.dart --release

# PROD release APK
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

### App Bundle (Play Store)

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

### iOS IPA

```bash
# DEV
flutter build ipa --flavor Dev -t lib/main_dev.dart

# UAT
flutter build ipa --flavor UAT -t lib/main_uat.dart

# PROD
flutter build ipa --flavor Prod -t lib/main_prod.dart
```

---

## Android Setup

### Signing Configuration

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore android/keystore/power_tool_tracking.jks \
     -alias powertracking -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Copy `android/key.properties.example` → `android/key.properties`
3. Fill in your keystore path and credentials

### Firebase (Android)

Place flavor-specific `google-services.json` files:
```
android/app/src/dev/google-services.json
android/app/src/uat/google-services.json
android/app/src/prod/google-services.json
```

---

## iOS Setup

### Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. The project has 3 schemes: **Dev**, **UAT**, **Prod**
3. Each scheme maps to build configurations:
   - `Debug-Dev` / `Release-Dev`
   - `Debug-UAT` / `Release-UAT`  
   - `Debug-Prod` / `Release-Prod`

### xcconfig Files

Located in `ios/config/`:
- `dev.xcconfig` — DEV bundle ID and API URL
- `uat.xcconfig` — UAT bundle ID and API URL
- `prod.xcconfig` — PROD bundle ID and API URL

### Firebase (iOS)

Place flavor-specific `GoogleService-Info.plist` files:
```
ios/Runner/Dev/GoogleService-Info.plist
ios/Runner/UAT/GoogleService-Info.plist
ios/Runner/Prod/GoogleService-Info.plist
```

### Info.plist Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Used to scan tool QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to attach tool photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to track tool locations on site</string>
<key>NSMicrophoneUsageDescription</key>
<string>Required for voice notes</string>
```

---

## Firebase Setup

1. Create 3 Firebase projects: `power-tool-tracking-dev`, `-uat`, `-prod`
2. Add Android & iOS apps to each project
3. Download and place config files per the flavor setup above
4. Enable: Analytics, Crashlytics, Cloud Messaging, Remote Config

---

## Running Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests with coverage
flutter test --coverage

# Integration tests (requires device/emulator)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --flavor dev -t lib/main_dev.dart
```

---

## Code Generation

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

Generated files (gitignored):
- `*.g.dart` — Drift DAOs, json_serializable
- `*.freezed.dart` — Freezed union types

---

## Release Guide

### Android Release Checklist

- [ ] Update `versionCode` and `versionName` in `android/app/build.gradle`
- [ ] Verify `key.properties` points to the correct keystore
- [ ] Place production `google-services.json` under `src/prod/`
- [ ] Run: `flutter build appbundle --flavor prod -t lib/main_prod.dart --release`
- [ ] Upload to Google Play Console → Internal Testing → Production

### iOS Release Checklist

- [ ] Bump version in `pubspec.yaml`
- [ ] Run `flutter pub get` and `cd ios && pod install`
- [ ] Archive via Xcode: Product → Archive → Distribute App
- [ ] Select scheme **Prod**
- [ ] Upload to App Store Connect

### Release Notes Template

```
Version X.X.X — Power Tool Tracking

NEW FEATURES:
• ...

IMPROVEMENTS:
• ...

BUG FIXES:
• ...
```

---

## Security Notes

- JWT tokens stored in `flutter_secure_storage` (Keychain / Keystore)
- SSL pinning configured via `ApiConstants.sslPins`
- Root/Jailbreak detection via `SecurityService`
- Screenshot prevention on sensitive screens
- All `.env.*` files excluded from git (see `.gitignore`)
- Firebase config files excluded from git

---

## Offline-First Architecture

```
User Action
    ↓
Repository (Offline-First)
    ├── Save to Drift (local DB) immediately
    ├── If online → Sync to server
    └── If offline → Queue in sync_queue table
            ↓
        Background Sync (every N minutes)
            ↓
        Process sync_queue → POST to server
            ↓
        Mark as synced / retry on failure
```

---

## Contributing

1. Branch from `develop`
2. Run `dart run build_runner build` after model changes
3. Run `flutter test` before pushing
4. Submit PR against `develop`

---

*Generated with enterprise Flutter architecture standards.*
