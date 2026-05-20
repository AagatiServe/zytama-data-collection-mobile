# Zytama Data — Claude Code Guide

## Project Overview
Flutter app for field agents to collect product data (barcode scan + 3 photos) and upload it to the Zytama backend.

## Architecture
Clean Architecture with BLoC state management.

```
lib/
├── core/
│   ├── constants/        # AppColors, AppConstants, ApiConstants
│   ├── di/               # GetIt injection container (injection_container.dart)
│   ├── errors/           # Failure types
│   ├── network/          # Dio-based ApiClient
│   └── utils/            # DialogUtils
├── features/
│   ├── auth/
│   │   ├── data/         # AuthRemoteDataSource, AuthRepositoryImpl (SharedPreferences)
│   │   ├── domain/       # UserEntity, AuthRepository, LoginUseCase
│   │   └── presentation/ # AuthBloc + LoginScreen, SplashScreen, PrivacyPolicyScreen
│   └── product/
│       ├── data/         # ProductRemoteDataSource, ProductRepositoryImpl
│       ├── domain/       # CheckBarcodeUseCase, UploadProductUseCase
│       └── presentation/ # ProductBloc + DashboardScreen, BarcodeScannerScreen,
│                         #   ProductReviewScreen, NotificationScreen
└── main.dart             # App entry, MultiBlocProvider
```

## Key Flows

### Login
`SplashScreen` → `CheckAuthStatus` event → reads token from SharedPreferences → navigate to `DashboardScreen` or `LoginScreen`.

### Product Collection
1. `DashboardScreen` auto-opens `BarcodeScannerScreen` on mount.
2. Scanned barcode triggers `BarcodeScanned` → backend check (`CheckBarcodeUseCase`).
3. If new: capture 3 images in sequence (product → ingredients → nutrition) via `_CaptureGuideSheet` bottom sheet.
4. `ProductReviewScreen` shows previews; agent can retake any photo before submitting.
5. Submit → `UploadProductUseCase` → success dialog → loop back to scanner.

### Logout
`LogoutRequested` event → `authRepository.logout()` calls `prefs.clear()` (clears ALL SharedPreferences) → `AuthUnauthenticated` state → navigate back to `LoginScreen`.

## State Management
- `AuthBloc`: handles `CheckAuthStatus`, `LoginRequested`, `LogoutRequested`.
- `ProductBloc`: drives the full scan/capture/upload state machine.
- Both provided globally in `main.dart` via `MultiBlocProvider`.

## Responsiveness
- **Login screen**: `LayoutBuilder` constrains form to 480 px max width; centered on tablets.
- **Dashboard**: hero height = 60% of screen; ring size clamped between 160–240 px.
- **Barcode scanner**: scan frame = 65% of screen width, clamped 200–300 px.
- **Product review**: image height = 55% of screen width, clamped 160–260 px; submit bar respects `MediaQuery.paddingOf(context).bottom`.

## Dependencies (key)
| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC state management |
| `get_it` | Service locator / DI |
| `shared_preferences` | Token + user data persistence |
| `dio` | HTTP client |
| `mobile_scanner` | Barcode scanning |
| `image_picker` | Camera capture |
| `google_fonts` | Work Sans font |
| `url_launcher` | Open web portal links |

## Colors
All colors defined in `AppColors` (`lib/core/constants/app_colors.dart`).
- Primary: `#0C6170` (midnight teal)
- Secondary: `#37BEB0` (blue-green)
- Dashboard gradient: `dashTeal → dashTealMid → dashTealEnd`

## Conventions
- Screens are broken into private widget classes (prefixed `_`) within the same file.
- `prefs.clear()` is used on logout to wipe all stored data.
- All image captures use `ImageSource.camera` with `imageQuality: 85`.
