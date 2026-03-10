# VC Stocks Mobile

Flutter mobile app for the VC Stocks portfolio tracker. Supports iOS and Android.

## Prerequisites

- Flutter SDK 3.41+
- Dart 3.11+
- Xcode (for iOS)
- Android Studio (for Android)
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Environment variables

Copy the example env file and set your API base URL:

```bash
cp .env.example .env
```

Edit `.env`:

```
API_BASE_URL=http://localhost:4000
```

For device testing, use your machine's local IP instead of `localhost` (e.g. `http://192.168.1.x:4000`).

### 3. Firebase setup (required for AI Chat)

The app uses Firebase AI Logic SDK (Gemini) for the AI Chat feature. Firebase config files are **not** checked into the repo for security. You must generate them for your own Firebase project.

#### a. Log in to Firebase

```bash
firebase login
```

#### b. Run FlutterFire configure

```bash
flutterfire configure --project=<your-firebase-project-id>
```

This generates three files (all gitignored):

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Dart config with API keys and app IDs |
| `android/app/google-services.json` | Android Firebase config |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config |

#### c. Enable required APIs

In the [Google Cloud Console](https://console.cloud.google.com/apis/library) for your project, enable:

- **Vertex AI in Firebase API** (`firebasevertexai.googleapis.com`)
- **Vertex AI API** (`aiplatform.googleapis.com`)

### 4. Generate code

Run build_runner to generate Riverpod/Freezed code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running

### Simulator/Emulator

```bash
flutter run
```

### Real device (release mode)

```bash
flutter run --release
```

> Debug builds crash when the debugger is disconnected. Use `--release` for standalone testing on a real device.

### Analyze

```bash
flutter analyze
```

## Project Structure

```
lib/
  core/           # Theme, constants, utilities
  features/
    auth/          # Login and authentication
    chat/          # AI Chat (Firebase AI + Gemini)
    dashboard/     # Portfolio dashboard, holdings, P/L chart
    explore/       # Stock/crypto search and discovery
    crypto_detail/ # Crypto detail page
    stock_detail/  # Stock detail with valuation
  models/          # Freezed data models
  routing/         # GoRouter configuration
  shared/          # Shared widgets (AppScaffold, etc.)
```
