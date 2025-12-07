<div align="center">

# Online Certificate Classroom (Mobile)

Flutter client for the "Xay dung he thong quan ly lop hoc chung chi truc tuyen" project. Shares the same Laravel/MySQL backend with the web app: [Online-Certificate-Classroom-Web](https://github.com/MinhQuun/Online-Certificate-Classroom-Web).

![Flutter](https://img.shields.io/badge/Flutter-3.7%2B-blue)
![Dart](https://img.shields.io/badge/Dart-3.7%2B-blueviolet)
![State](https://img.shields.io/badge/State-Provider%20%2B%20ChangeNotifier-green)
![Media](https://img.shields.io/badge/Media-Video%20%2F%20PDF-orange)
![API](https://img.shields.io/badge/API-Laravel%20Sanctum-red)

</div>

---

## Overview
- Native-feel mobile experience for browsing courses/combos, managing cart, checking out, and learning on the go.
- Reuses the shared `/api/v1/student/...` contract from the Laravel backend (tokens via Sanctum).
- Emphasis on quick access to enrolled lessons, progress tracking, and order history.

## Architecture & Stack

| Layer | Technology |
| --- | --- |
| UI | Flutter 3.7+, Material 3 theme, custom widgets (buttons, text fields, snackbars) |
| State | Provider + ChangeNotifier (scoped per feature, shared session controller) |
| Networking | Custom `ApiClient` (http), token injection via `ApiClient.setGlobalTokenProvider` |
| Media | `video_player` + `chewie`, `flutter_pdfview`, `url_launcher` |
| Storage | SharedPreferences for auth token |
| Routing | Centralized `AppRouter` + named routes |

## Key Features

**Student**
- Auth: login/register, persisted token, splash redirect when already signed in.
- Catalog: browse courses/combos, banners, course detail, chapters/lessons, mini-test info, promotions.
- Cart & checkout: add/remove courses or combos, multi-select remove, checkout preview and confirmation, payment methods (QR OCC, bank transfer, Visa/Master), invoice code display.
- Learning: enrolled list, resume last lesson, lesson player (video/PDF/external link), mark progress.
- Orders: history with status filters and per-order detail.
- Profile: basic profile and logout.

## Repository Map

| Path | Description |
| --- | --- |
| `lib/main.dart` | App entry; multi-provider setup, theme, router |
| `lib/core/config/app_config.dart` | App name, API base URL, portal URL helpers |
| `lib/core/network/api_client.dart` | HTTP client, token handling, error normalization |
| `lib/core/routing/app_router.dart` | Routes and navigation |
| `lib/core/theme/app_theme.dart` | Colors, gradients, typography |
| `lib/features/*/data` | API/repository/model per domain (auth, courses, cart, lessons, orders, profile, enrolled) |
| `lib/features/*/presentation` | Controllers + pages per domain |
| `lib/shared/controllers/student_session_controller.dart` | Cross-feature session, cart/enrollment state |
| `lib/shared/widgets` | Common UI components (button, text field, loading, error) |
| `assets/` | Images, banners, combos, lottie animations |

## Prerequisites
- Flutter SDK >= 3.7.2, Dart >= 3.7
- Android Studio / VS Code with device emulator (or Xcode for iOS build)
- Backend Laravel API running (same as web). Default base: `https://onlcertificateclassroom.online/api/v1`

## Configuration
Run backend locally and point the app to it:
1) Find your LAN IP (e.g., `192.168.x.x`).
2) Update `lib/core/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'http://<local-ip>:8000/api/v1';
   ```
3) Restart the app so the new base URL is picked up.

## Setup & Run
```bash
flutter pub get
flutter run   # pick simulator/device
```
- Clean cache: `flutter clean`
- Web debug (if enabled): `flutter run -d chrome`

## Build Releases
- Android APK: `flutter build apk --release`
- Android App Bundle: `flutter build appbundle --release`
- iOS: `flutter build ios --release` (configure signing in Xcode)

## Testing & Quality
- Static analysis: `flutter analyze`
- Unit/Widget tests (when added): `flutter test`

## API Contract Notes
- Uses `/api/v1/student/...` with Bearer token (Sanctum). Keep responses stable with the web backend.
- Payment methods surfaced in UI: qr, bank, visa (mirrors backend options).

## Related
- Web client + backend: https://github.com/MinhQuun/Online-Certificate-Classroom-Web
- Database: shared MySQL schema managed in the web repo (see `database/Online_Certificate_Classroom.sql` there).
