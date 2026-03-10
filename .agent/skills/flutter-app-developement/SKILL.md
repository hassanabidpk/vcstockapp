---
name: flutter-app-developement
description: "Use this skill whenever the user wants to create, edit, debug, build, or export a Flutter app for iOS and Android. Triggers include: any mention of 'Flutter', 'Dart', 'mobile app', 'cross-platform app', '.dart', 'pubspec.yaml', 'widget', 'APK', 'IPA', or requests to build iOS/Android apps. Also use when generating screens, widgets, navigation flows, state management, platform-specific code (Swift/Kotlin channels), or debugging Flutter layout/state issues. Use this skill for full end-to-end app creation, editing existing Flutter projects, generating individual widgets or screens, writing integration/unit/widget tests, and preparing builds for release. If the user asks for a 'mobile app', 'phone app', or 'native app' without specifying a framework, suggest Flutter and use this skill. Do NOT use for web-only React/HTML apps, pure native iOS (SwiftUI) or Android (Jetpack Compose) projects, or backend-only services."
---

# Flutter App Development (iOS & Android)

Full end-to-end Flutter skill for creating, editing, debugging, building, and exporting cross-platform mobile apps for iOS and Android. Covers project scaffolding, Riverpod state management, GoRouter navigation, platform-specific Swift/Kotlin code, widget/unit/integration testing, and release builds (APK/AAB/IPA). Triggers on any mention of Flutter, Dart, mobile app, cross-platform app, widgets, pubspec.yaml, APK, IPA, or requests to build phone/native apps.

## Overview

This skill enables full end-to-end Flutter app development: scaffolding new projects, writing idiomatic Dart, managing state, handling navigation, writing tests, and preparing builds. Output is source code plus build instructions the user can run locally.

## Quick Reference

| Task | Approach |
|------|----------|
| New app from scratch | Scaffold project structure, write all source files, provide build instructions |
| New screen/widget | Generate Dart file(s) with proper imports, integrate into navigation |
| Edit existing project | Read uploaded files, make targeted edits, preserve existing patterns |
| Debug/fix issues | Analyze error output, apply fix, explain root cause |
| Prepare release build | Generate build instructions for APK/AAB (Android) and IPA (iOS) |

---

## Project Structure

Choose structure based on project complexity:

### Small projects (≤5 screens)
```
lib/
├── main.dart
├── app.dart                  # MaterialApp + router config
├── models/                   # Data classes
├── providers/                # Riverpod providers
├── screens/                  # One file per screen
├── widgets/                  # Shared/reusable widgets
└── services/                 # API clients, local storage, etc.
```

### Medium-to-large projects (>5 screens)
```
lib/
├── main.dart
├── app.dart
├── core/                     # Shared utilities, theme, constants
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── extensions/
├── features/                 # Feature-first grouping
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── home/
│   └── settings/
├── shared/                   # Cross-feature widgets and services
│   ├── widgets/
│   └── services/
└── routing/                  # GoRouter configuration
    └── app_router.dart
```

Always explain to the user which structure you chose and why.

---

## State Management — Riverpod (Default)

Use **Riverpod** as the default state management solution. If the user explicitly requests Bloc or Provider, accommodate that — but default to Riverpod with code generation.

### Setup

In `pubspec.yaml`:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
```

### Wrapping the app
```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

### Provider patterns

Use the `@riverpod` annotation style (code generation) for new projects. This produces cleaner, type-safe code.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_provider.g.dart';

// Simple state
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

// Async data fetching
@riverpod
Future<User> currentUser(Ref ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchCurrentUser();
}
```

After writing providers, remind the user to run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Consuming providers in widgets
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Key Riverpod rules
- Always use `ref.watch()` inside `build()` for reactive rebuilds
- Use `ref.read()` inside callbacks (onPressed, onTap) — never inside `build()`
- Use `ref.listen()` for side effects (showing snackbars, navigation)
- Prefer `AsyncValue.when()` over manual null/loading checks
- Use `autodispose` (the default with code generation) unless state must survive screen disposal

---

## Navigation — GoRouter

Use **GoRouter** as the default routing solution.

### Setup

```yaml
dependencies:
  go_router: ^14.0.0
```

### Router configuration
```dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          name: 'details',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailsScreen(id: id);
          },
        ),
      ],
    ),
  ],
);
```

### Integrating with MaterialApp
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
```

### Navigation patterns
```dart
// Navigate by name (preferred — resilient to path changes)
context.goNamed('details', pathParameters: {'id': '42'});

// Navigate by path
context.go('/details/42');

// Push (adds to stack, enables back button)
context.pushNamed('details', pathParameters: {'id': '42'});

// Pop
context.pop();
```

### Route guards and redirects
```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = /* check auth state */;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/';
    return null; // no redirect
  },
  // ...
);
```

### Shell routes (persistent bottom nav, sidebars)
```dart
ShellRoute(
  builder: (context, state, child) {
    return ScaffoldWithBottomNav(child: child);
  },
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
),
```

---

## Platform-Specific Code

### Platform checks
```dart
import 'dart:io' show Platform;

if (Platform.isIOS) { /* iOS-specific behavior */ }
if (Platform.isAndroid) { /* Android-specific behavior */ }
```

### Method Channels (calling native Swift/Kotlin)

**Dart side:**
```dart
const platform = MethodChannel('com.example.app/native');

Future<String> getNativeData() async {
  try {
    final result = await platform.invokeMethod<String>('getData');
    return result ?? '';
  } on PlatformException catch (e) {
    return 'Error: ${e.message}';
  }
}
```

**iOS side (Swift) — `ios/Runner/AppDelegate.swift`:**
```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.example.app/native",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { (call, result) in
      if call.method == "getData" {
        result("Hello from iOS")
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Android side (Kotlin) — `android/app/src/main/kotlin/.../MainActivity.kt`:**
```kotlin
package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getData") {
                    result.success("Hello from Android")
                } else {
                    result.notImplemented()
                }
            }
    }
}
```

### Platform-specific UI patterns
- Use `CupertinoNavigationBar` / `CupertinoTabBar` on iOS when matching native feel
- Use `Material` widgets as the cross-platform default
- Use `Platform.isIOS` checks or the `flutter_platform_widgets` package for adaptive UI
- Respect platform conventions: iOS uses swipe-back, Android uses the system back button

### iOS-specific configuration
- Update `ios/Runner/Info.plist` for permissions (camera, location, photos, etc.)
- Set deployment target in `ios/Podfile` (default: `platform :ios, '13.0'` minimum)
- App icons: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Launch screen: `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

### Android-specific configuration
- Set `minSdkVersion` in `android/app/build.gradle` (recommend `21` minimum)
- Permissions in `android/app/src/main/AndroidManifest.xml`
- App icons: `android/app/src/main/res/mipmap-*/`
- Adaptive icons: `android/app/src/main/res/mipmap-anydpi-v26/`

---

## Theming

Always define a dedicated theme to avoid scattered styling:

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.dark,
  );
}
```

Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` throughout — never hardcode colors or text styles in widgets.

---

## Testing

### Unit tests
```dart
// test/counter_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Counter increments', () {
    final container = ProviderContainer();
    final counter = container.read(counterProvider.notifier);
    counter.increment();
    expect(container.read(counterProvider), 1);
  });
}
```

### Widget tests
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen shows title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    expect(find.text('Home'), findsOneWidget);
  });
}
```

### Integration tests
```dart
// integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    // ... interact and assert
  });
}
```

Always generate at least one widget test per screen and one unit test per provider/service.

---

## Common Packages

Recommend these well-maintained packages when relevant:

| Purpose | Package |
|---------|---------|
| HTTP client | `dio` or `http` |
| Local storage | `shared_preferences`, `hive` |
| Secure storage | `flutter_secure_storage` |
| JSON serialization | `json_serializable` + `json_annotation` |
| Freezed data classes | `freezed` + `freezed_annotation` |
| Image loading/caching | `cached_network_image` |
| Icons | `flutter_launcher_icons` |
| Splash screens | `flutter_native_splash` |
| Permissions | `permission_handler` |
| Responsive layout | `flutter_screenutil` or `LayoutBuilder` |

When adding packages, always specify version constraints in `pubspec.yaml` with caret syntax (e.g., `^2.5.0`).

---

## Build & Release Instructions

Always include these at the end of the output so the user can build locally.

### Development
```bash
# Get dependencies
flutter pub get

# Run code generation (if using Riverpod codegen, Freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device or emulator
flutter run
```

### Android release build
```bash
# Build APK (universal)
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output locations:
# APK:  build/app/outputs/flutter-apk/app-release.apk
# AAB:  build/app/outputs/bundle/release/app-release.aab
```

Before release, remind the user to:
- Set `applicationId` in `android/app/build.gradle`
- Configure signing in `android/app/build.gradle` with a keystore
- Update `versionCode` and `versionName`

### iOS release build
```bash
# Build IPA (requires macOS with Xcode)
flutter build ipa --release

# Output: build/ios/ipa/*.ipa
```

Before release, remind the user to:
- Set the Bundle Identifier in Xcode or `ios/Runner.xcodeproj`
- Configure signing with an Apple Developer account
- Set version and build number in `ios/Runner/Info.plist` or via `pubspec.yaml`

### Running tests
```bash
# Unit and widget tests
flutter test

# Integration tests (requires device/emulator)
flutter test integration_test/
```

---

## Critical Rules

- **Always use `const` constructors** where possible — improves performance and is enforced by `flutter_lints`
- **Never use `setState` in anything but the simplest throwaway widgets** — use Riverpod
- **Never hardcode strings** intended for display — extract to a constants file or use `intl`/`easy_localization` for i18n
- **Never hardcode colors or text styles** — use `Theme.of(context)`
- **Always handle async errors** — use `try/catch` or `AsyncValue.when(error:)`
- **Always dispose controllers** — `TextEditingController`, `ScrollController`, etc. in `dispose()`
- **Use `Key` wisely** — add keys to list items and conditionally swapped widgets
- **Prefer `SizedBox` over `Container`** when you only need width/height
- **Prefer `const SizedBox.shrink()`** over `Container()` for empty placeholders
- **Always provide build instructions** at the end of any project generation
- **Always use Material 3** (`useMaterial3: true`) unless the user requests otherwise
- **Target latest stable Flutter** — use Dart 3 features (records, patterns, sealed classes) when beneficial
- **Always add `analysis_options.yaml`** with recommended lints:
  ```yaml
  include: package:flutter_lints/flutter.yaml

  linter:
    rules:
      prefer_const_constructors: true
      prefer_const_declarations: true
      avoid_print: true
      require_trailing_commas: true
  ```

---

## Output Format

When generating a complete app, deliver:

1. **All source files** with clear file paths as comments at the top of each file
2. **`pubspec.yaml`** with all dependencies
3. **`analysis_options.yaml`**
4. **Platform config changes** (Info.plist entries, AndroidManifest permissions) if needed
5. **Build & run instructions** section at the end
6. A brief summary explaining the architecture decisions made

When generating a single widget or screen, deliver just the Dart file(s) with import statements and a note on where to integrate it in the project.