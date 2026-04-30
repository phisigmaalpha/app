# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS simulator

# Build for production
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Architecture Overview

**SIGMA** is a Flutter multi-platform app (iOS, Android, macOS, Windows, Web, Linux) for the Phi Sigma Alpha fraternity member portal.

### Project Structure

```
lib/
├── main.dart                 # Entry point, routing, theme, locale setup
├── l10n/                     # Localization system
│   ├── app_localizations.dart    # Custom JSON-based i18n delegate
│   └── translations/{en,es}/     # JSON files per language per module
└── screens/
    ├── components/           # Reusable form fields (CustomEmailField, CustomPasswordField)
    ├── login/                # Authentication screen
    ├── password/             # Multi-step password reset flow
    │   ├── changePassword.dart   # Step controller (1: email, 2: code, 3: new password)
    │   └── widgets/              # Step-specific widgets
    └── language_selection_screen.dart
```

### State Management

Uses native Flutter `StatefulWidget` pattern with `TextEditingController` for forms. No external state management library. `SharedPreferences` stores persistent data:
- `language` - User locale preference (en/es)
- `first_time` - First launch flag

### Localization

Custom JSON-based system in `AppLocalizations`. Translation files are organized by module:
- `common.json` - App-wide strings
- `login.json` - Auth-related strings
- `passwords.json` - Password reset strings

Usage pattern:
```dart
final localizations = AppLocalizations.of(context);
Text(localizations?.email ?? 'Email')
```

### Navigation Flow

```
SplashScreen → [first_time?] → LanguageSelectionScreen → LoginScreen → MyHomePage
                    ↓
              LoginScreen (returning users)
```

### Form Validation Pattern

Forms use `GlobalKey<FormState>` with reusable components:
- Parent widget owns the `TextEditingController` and `GlobalKey<FormState>`
- Child widget wraps content in `Form(key: formKey, ...)` and receives controller
- Validation triggered via `formKey.currentState!.validate()`

### Color Scheme

- Primary (text/headers): `Color.fromRGBO(24, 41, 163, 1)` - Deep blue
- Accent (buttons/icons): `Color.fromRGBO(231, 182, 43, 1)` - Golden

## Current Status

Early prototype with authentication UI. No backend integration yet (mock login with `test@sigma.com` / `123`).
