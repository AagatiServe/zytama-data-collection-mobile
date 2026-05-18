# Zytama Data — Developer Guide

> **Last updated:** May 2026  
> **Flutter SDK:** `>=3.4.0 <4.0.0`  
> **Status:** Mock / Demo mode — all API calls are simulated locally

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack & Dependencies](#2-tech-stack--dependencies)
3. [Architecture](#3-architecture)
4. [Folder Structure](#4-folder-structure)
5. [File-by-File Reference](#5-file-by-file-reference)
6. [App Flow & Navigation](#6-app-flow--navigation)
7. [BLoC Reference — Auth](#7-bloc-reference--auth)
8. [BLoC Reference — Product](#8-bloc-reference--product)
9. [API Endpoints](#9-api-endpoints)
10. [Switching from Mock to Real API](#10-switching-from-mock-to-real-api)
11. [Dependency Injection](#11-dependency-injection)
12. [How to Run](#12-how-to-run)
13. [Demo Credentials](#13-demo-credentials)
14. [Adding a New Feature — Checklist](#14-adding-a-new-feature--checklist)

---

## 1. Project Overview

**Zytama Data** is a Flutter mobile application for field agents to collect product data. The agent:

1. Logs in with their credentials.
2. Scans a product barcode using the device camera.
3. Checks if the product already exists in the database.
4. If new — photographs the **product**, **ingredients label**, and **nutrition facts** label.
5. Reviews all captured data on a summary screen.
6. Submits everything to the server as a multipart upload.

---

## 2. Tech Stack & Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | State management (BLoC pattern) |
| `dio` | ^5.8.0+1 | HTTP client (not active in mock mode) |
| `shared_preferences` | ^2.3.2 | Persist auth token, user name/email |
| `get_it` | ^8.0.3 | Service locator / dependency injection |
| `image_picker` | ^1.1.2 | Open device camera and capture photos |
| `mobile_scanner` | ^5.2.3 | Barcode scanning via live camera feed |
| `google_fonts` | ^8.0.2 | Work Sans font throughout the app |
| `permission_handler` | ^11.4.0 | Camera & storage permission requests |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 3. Architecture

The project follows **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  BLoC · Screens · Widgets               │
├─────────────────────────────────────────┤
│             Domain Layer                │
│  Entities · Repositories (abstract)    │
│  Use Cases                             │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  Models · Remote DataSources            │
│  Repository Implementations            │
└─────────────────────────────────────────┘
```

### Key principles followed

- **Dependency Rule** — outer layers depend on inner layers, never the reverse.
- **Repository Pattern** — the domain layer defines abstract repository interfaces; the data layer implements them.
- **BLoC** — all business logic lives in BLoC classes. Screens only dispatch events and render states.
- **GetIt (Service Locator)** — all dependencies are registered once at startup in `injection_container.dart`.
- **Mock-first** — DataSource implementations are mocked; replace them with real Dio calls when the API is ready.

---

## 4. Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # Base URL, endpoint paths, timeouts
│   │   └── app_constants.dart       # SharedPreferences keys
│   ├── di/
│   │   └── injection_container.dart # GetIt registrations — all DI here
│   ├── errors/
│   │   └── failures.dart            # Failure base class + subtypes
│   ├── network/
│   │   └── api_client.dart          # Dio client + auth interceptor
│   └── utils/
│       └── dialog_utils.dart        # Reusable alert/info/error dialogs
│
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart     # Login API (mocked)
│   │   └── product_remote_datasource.dart  # Barcode check + upload (mocked)
│   ├── models/
│   │   ├── auth_model.dart          # JSON ↔ auth response
│   │   └── product_model.dart       # JSON ↔ check & upload responses
│   └── repositories/
│       ├── auth_repository_impl.dart    # Implements AuthRepository
│       └── product_repository_impl.dart # Implements ProductRepository
│
├── domain/
│   ├── entities/
│   │   └── user_entity.dart         # Pure user object (no JSON)
│   ├── repositories/
│   │   ├── auth_repository.dart     # Abstract auth contract
│   │   └── product_repository.dart  # Abstract product contract
│   └── usecases/
│       ├── login_usecase.dart           # Calls AuthRepository.login
│       ├── check_barcode_usecase.dart   # Calls ProductRepository.checkBarcodeExists
│       └── upload_product_usecase.dart  # Calls ProductRepository.uploadProduct
│
├── presentation/
│   ├── bloc/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart       # Auth state machine
│   │   │   ├── auth_event.dart      # Auth events (part of auth_bloc)
│   │   │   └── auth_state.dart      # Auth states (part of auth_bloc)
│   │   └── product/
│   │       ├── product_bloc.dart    # Product capture state machine
│   │       ├── product_event.dart   # Product events (part of product_bloc)
│   │       └── product_state.dart   # Product states (part of product_bloc)
│   ├── screens/
│   │   ├── splash_screen.dart           # Logo + auth check
│   │   ├── login_screen.dart            # Glass-card login UI
│   │   ├── dashboard_screen.dart        # User card + scan FAB + step dialogs
│   │   ├── barcode_scanner_screen.dart  # Live camera barcode scanner
│   │   └── product_review_screen.dart   # Review images + zoom + submit
│   └── widgets/
│       ├── custom_button.dart       # Reusable ElevatedButton with loading state
│       ├── custom_text_field.dart   # Reusable TextFormField with focus/action
│       └── loading_overlay.dart     # Full-screen semi-transparent loader
│
└── main.dart                        # App entry point, DI init, theme, providers
```

---

## 5. File-by-File Reference

### `main.dart`
- Calls `di.init()` before `runApp`.
- Wraps the app in `MultiBlocProvider` providing `AuthBloc` and `ProductBloc` globally.
- Sets theme: `ColorScheme.fromSeed(seedColor: Color(0xFF0d631b))` + Work Sans font.
- Entry screen: `SplashScreen`.

---

### `core/constants/api_constants.dart`
```dart
baseUrl          = 'https://api.zytama.com/v1'   // ← change this for production
loginEndpoint    = '/auth/login'
checkBarcodeEndpoint = '/products/check'
uploadProductEndpoint = '/products/upload'
connectTimeoutMs = 30000
receiveTimeoutMs = 30000
```

---

### `core/constants/app_constants.dart`
```dart
tokenKey    = 'auth_token'    // SharedPreferences key for JWT
userNameKey = 'user_name'     // SharedPreferences key for display name
userEmailKey = 'user_email'   // SharedPreferences key for email
```

---

### `core/di/injection_container.dart`
Single function `init()` called once at startup. Registration order matters:

```
SharedPreferences → DataSources → Repositories → UseCases → BLoCs
```

- DataSources and Repositories: `registerLazySingleton` (created once, reused).
- BLoCs: `registerFactory` (new instance per `BlocProvider`).

> **When real API is ready:** inject `ApiClient` into the DataSource constructors here.

---

### `core/network/api_client.dart`
Wraps `Dio` with:
- Base URL and timeouts from `ApiConstants`.
- `_AuthInterceptor` — reads `auth_token` from `SharedPreferences` and adds `Authorization: Bearer <token>` header to every request.

> Not used in mock mode but fully ready to activate.

---

### `core/errors/failures.dart`
Base class and subtypes for typed error handling:
- `ServerFailure` — API returned an error response.
- `NetworkFailure` — no connectivity.
- `CacheFailure` — local storage issue.
- `AuthFailure` — token missing or expired.

---

### `core/utils/dialog_utils.dart`
Three static methods, all return `Future<void>`:
- `showSuccessDialog(context, message)` — green check icon.
- `showErrorDialog(context, message)` — red error icon.
- `showInfoDialog(context, message)` — orange info icon.

---

### `data/models/auth_model.dart`
```dart
AuthModel { token, email, name }
// factory AuthModel.fromJson(Map<String, dynamic>)
```

---

### `data/models/product_model.dart`
```dart
ProductCheckModel { exists, message? }
UploadResponseModel { success, message, productId? }
// both have factory .fromJson constructors
```

---

### `data/datasources/auth_remote_datasource.dart`
**Current:** Mock — accepts any email, password must be `123456`. Derives display name from the email prefix.

**To activate real API:** replace `AuthRemoteDataSourceImpl` body with a Dio call:
```dart
final response = await apiClient.post(ApiConstants.loginEndpoint,
    data: {'email': email, 'password': password});
return AuthModel.fromJson(response.data);
```

---

### `data/datasources/product_remote_datasource.dart`
**Current:** Mock —
- `checkBarcode`: returns `exists: true` only for barcodes `000000000000` and `123456789012`.
- `uploadProduct`: waits 2 seconds and returns success.

**To activate real API:** replace with Dio calls using `FormData` / `MultipartFile` for the images.

---

### `data/repositories/auth_repository_impl.dart`
Implements `AuthRepository`:
- `login()` — calls datasource, saves token + name + email to `SharedPreferences`.
- `isLoggedIn()` — checks if token exists in prefs.
- `getStoredUser()` — reads token/name/email from prefs and returns `UserEntity`.
- `logout()` — removes all three keys from prefs.

---

### `data/repositories/product_repository_impl.dart`
Implements `ProductRepository`:
- `checkBarcodeExists(barcode)` — delegates to datasource, returns `bool`.
- `uploadProduct(barcode, productImage, ingredientsImage, nutritionImage)` — delegates to datasource, returns the success message string.

---

### `domain/entities/user_entity.dart`
```dart
UserEntity { email, name, token }
```
Pure Dart object — no JSON, no Flutter imports.

---

### `domain/repositories/auth_repository.dart`
Abstract contract:
```dart
Future<UserEntity> login(String email, String password)
Future<bool> isLoggedIn()
Future<UserEntity?> getStoredUser()
Future<void> logout()
```

---

### `domain/repositories/product_repository.dart`
Abstract contract:
```dart
Future<bool> checkBarcodeExists(String barcode)
Future<String> uploadProduct({barcode, productImage, ingredientsImage, nutritionImage})
```

---

### `domain/usecases/login_usecase.dart`
`call(email, password)` → `repository.login(email, password)`

### `domain/usecases/check_barcode_usecase.dart`
`call(barcode)` → `repository.checkBarcodeExists(barcode)`

### `domain/usecases/upload_product_usecase.dart`
`call({barcode, productImage, ingredientsImage, nutritionImage})` → `repository.uploadProduct(...)`

---

### `presentation/screens/splash_screen.dart`
- Shows animated logo (fade + scale) for 1.8 seconds.
- Dispatches `CheckAuthStatus` to `AuthBloc`.
- `BlocListener`: navigates to `DashboardScreen` if authenticated, `LoginScreen` if not.

---

### `presentation/screens/login_screen.dart`
- **Design:** Glassmorphism card on a green gradient background (matches provided HTML spec).
- **Font:** Work Sans via `google_fonts`.
- **Fields:** Email (any) + Password (`123456` for demo).
- **Structure:** `BlocListener` for navigation/errors. Only the submit button uses `BlocBuilder` — the form fields are never inside a builder to prevent focus/keyboard loss.
- **Extras:** Remember me checkbox, pulsing "System Online" status pill, Help FAB.

---

### `presentation/screens/dashboard_screen.dart`
- **User card** — shows avatar initial, name, email, total scan count (local `int _scanCount`).
- **Step dialogs** — drives the 4-step capture flow via `BlocListener<ProductBloc>`.
- **Idle view** — lists all 4 steps with icons when no scan is in progress.
- **FAB** — "Scan Product" button, disabled while a scan is in progress.
- Auto-opens the barcode scanner on first mount via `addPostFrameCallback`.

---

### `presentation/screens/barcode_scanner_screen.dart`
- Uses `MobileScannerController` from `mobile_scanner`.
- Returns the scanned barcode string to the caller via `Navigator.pop(barcode)`.
- Torch toggle + camera flip buttons in the AppBar.
- Scan frame overlay with corner accents and instruction text.
- Prevents double-scan with `_hasScanned` flag.

---

### `presentation/screens/product_review_screen.dart`
Received from `DashboardScreen` via constructor:
```dart
ProductReviewScreen({
  barcode,
  initialProductImage,
  initialIngredientsImage,
  initialNutritionImage,
  onSuccess,   // VoidCallback — dashboard increments _scanCount
})
```

**Features:**
- **Barcode card** — displays scanned barcode in monospace.
- **3 image cards** — Product / Ingredients / Nutrition, each 200px tall.
- **Tap image** → fullscreen `InteractiveViewer` (pinch 0.5× – 6×) with gradient label + close button.
- **Replace** → opens camera, updates local state immediately.
- **Submit button** — sticky bottom bar, dispatches `SubmitProduct` event.
- `BlocListener` handles `ProductUploadSuccess` (calls `onSuccess`, shows dialog, pops) and `ProductError` (snackbar).

---

### `presentation/widgets/custom_button.dart`
```dart
CustomButton({ onPressed, label, isLoading, icon? })
```
Full-width `ElevatedButton`, shows `CircularProgressIndicator` when `isLoading: true`.

### `presentation/widgets/custom_text_field.dart`
```dart
CustomTextField({ controller, label, obscureText, keyboardType,
                  textInputAction, focusNode, suffixIcon,
                  validator, onFieldSubmitted })
```
Thin wrapper around `TextFormField` with consistent border styling.

### `presentation/widgets/loading_overlay.dart`
```dart
LoadingOverlay({ child, isLoading, message? })
```
`Stack` that renders a semi-transparent dark overlay with a spinner on top of `child` when `isLoading` is true.

---

## 6. App Flow & Navigation

```
main()
  └─ di.init()
  └─ runApp(App)
        └─ SplashScreen
              ├─ AuthAuthenticated ──→ DashboardScreen
              └─ AuthUnauthenticated ─→ LoginScreen
                                              │
                                    LoginRequested event
                                              │
                                    AuthAuthenticated ──→ DashboardScreen
```

### Product capture flow (inside DashboardScreen)

```
[FAB tapped]
    └─ push BarcodeScannerScreen
          └─ barcode scanned → pop(barcode)
    └─ BarcodeScanned event
          ├─ ProductExists   → "Already exists" dialog → reset → scanner
          └─ ProductNotExists
                └─ Step 1 dialog → camera → ProductImageCaptured
                      └─ CapturingIngredientsImage
                            └─ Step 2 dialog → camera → IngredientsImageCaptured
                                  └─ CapturingNutritionImage
                                        └─ Step 3 dialog → camera → NutritionImageCaptured
                                              └─ ReadyToReview
                                                    └─ push ProductReviewScreen
                                                          └─ SubmitProduct event
                                                                └─ ProductUploading
                                                                └─ ProductUploadSuccess
                                                                      └─ onSuccess() + dialog + pop
```

### Navigation Stack Rules
- `SplashScreen → LoginScreen`: `pushReplacement` (splash removed).
- `LoginScreen → DashboardScreen`: `pushReplacement` (login removed).
- `DashboardScreen → LoginScreen (logout)`: `pushAndRemoveUntil` (full stack cleared).
- `DashboardScreen → BarcodeScannerScreen`: `push` (scanner sits on top, returns barcode via pop).
- `DashboardScreen → ProductReviewScreen`: `push` (review sits on top, pops after submit).

---

## 7. BLoC Reference — Auth

**File:** `lib/presentation/bloc/auth/`

### Events

| Event | Fields | Trigger |
|---|---|---|
| `CheckAuthStatus` | — | SplashScreen on mount |
| `LoginRequested` | `email`, `password` | Login button tap |
| `LogoutRequested` | — | Dashboard AppBar logout icon |

### States

| State | Fields | Meaning |
|---|---|---|
| `AuthInitial` | — | App just started |
| `AuthLoading` | — | Async operation in progress |
| `AuthAuthenticated` | `user: UserEntity` | Valid session exists |
| `AuthUnauthenticated` | — | No token / logged out |
| `AuthError` | `message: String` | Login failed |

---

## 8. BLoC Reference — Product

**File:** `lib/presentation/bloc/product/`

### Events

| Event | Fields | Trigger |
|---|---|---|
| `ScanBarcodeRequested` | — | FAB tap / auto on dashboard mount |
| `BarcodeScanned` | `barcode` | Scanner returns result |
| `ProductImageCaptured` | `image: File` | Camera closes after product photo |
| `IngredientsImageCaptured` | `image: File` | Camera closes after ingredients photo |
| `NutritionImageCaptured` | `image: File` | Camera closes after nutrition photo |
| `SubmitProduct` | `productImage`, `ingredientsImage`, `nutritionImage` | Submit button on review screen |
| `ResetProduct` | — | After success / error / back navigation |

### States

| State | Fields | Meaning |
|---|---|---|
| `ProductInitial` | — | Idle, ready to scan |
| `ProductScanning` | — | Scanner screen is open |
| `ProductChecking` | `barcode` | API call in progress |
| `ProductExists` | `barcode` | Barcode found in DB |
| `ProductNotExists` | `barcode` | New product — start capture |
| `CapturingIngredientsImage` | `barcode`, `productImage` | Product photo done, awaiting ingredients |
| `CapturingNutritionImage` | `barcode`, `productImage`, `ingredientsImage` | Ingredients done, awaiting nutrition |
| `ReadyToReview` | `barcode`, `productImage`, `ingredientsImage`, `nutritionImage` | All images captured |
| `ProductUploading` | — | Multipart upload in progress |
| `ProductUploadSuccess` | `message` | Upload complete |
| `ProductError` | `message` | Any error in the flow |

---

## 9. API Endpoints

All endpoints are under `https://api.zytama.com/v1` (configurable in `api_constants.dart`).

### POST `/auth/login`
**Request:**
```json
{ "email": "string", "password": "string" }
```
**Response:**
```json
{ "token": "string", "email": "string", "name": "string" }
```

---

### GET `/products/check/{barcode}`
**Response:**
```json
{ "exists": true, "message": "string (optional)" }
```

---

### POST `/products/upload`
**Content-Type:** `multipart/form-data`

| Field | Type | Description |
|---|---|---|
| `barcode` | String | Scanned barcode value |
| `product_image` | File | JPEG photo of the product |
| `ingredients_image` | File | JPEG photo of the ingredients label |
| `nutrition_image` | File | JPEG photo of the nutrition facts |

**Response:**
```json
{ "success": true, "message": "string", "product_id": "string (optional)" }
```

---

## 10. Switching from Mock to Real API

The app is currently in **mock mode**. To connect to a real backend:

### Step 1 — Update the base URL
`lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://your-real-api.com/v1';
```

### Step 2 — Replace Auth DataSource
`lib/data/datasources/auth_remote_datasource.dart`:
```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSourceImpl(this.apiClient);   // ← restore constructor

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    }
  }
}
```

### Step 3 — Replace Product DataSource
`lib/data/datasources/product_remote_datasource.dart`:
```dart
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  ProductRemoteDataSourceImpl(this.apiClient);  // ← restore constructor

  @override
  Future<ProductCheckModel> checkBarcode(String barcode) async {
    final response = await apiClient.get('${ApiConstants.checkBarcodeEndpoint}/$barcode');
    return ProductCheckModel.fromJson(response.data);
  }

  @override
  Future<UploadResponseModel> uploadProduct({...}) async {
    final formData = FormData.fromMap({
      'barcode': barcode,
      'product_image': await MultipartFile.fromFile(productImage.path, filename: 'product.jpg'),
      'ingredients_image': await MultipartFile.fromFile(ingredientsImage.path, filename: 'ingredients.jpg'),
      'nutrition_image': await MultipartFile.fromFile(nutritionImage.path, filename: 'nutrition.jpg'),
    });
    final response = await apiClient.postMultipart(ApiConstants.uploadProductEndpoint, formData);
    return UploadResponseModel.fromJson(response.data);
  }
}
```

### Step 4 — Update DI to inject ApiClient
`lib/core/di/injection_container.dart`:
```dart
// Add ApiClient registration back
sl.registerLazySingleton<ApiClient>(() => ApiClient());

// Pass it to datasources
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
);
sl.registerLazySingleton<ProductRemoteDataSource>(
  () => ProductRemoteDataSourceImpl(sl<ApiClient>()),
);
```

---

## 11. Dependency Injection

All registrations are in `lib/core/di/injection_container.dart`. The `sl` variable is the global `GetIt` instance.

```dart
// Access a registered dependency anywhere:
final authBloc = sl<AuthBloc>();

// In BlocProvider (already done in main.dart):
BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())
```

**Registration types used:**
- `registerLazySingleton` — created once on first access, same instance forever.
- `registerFactory` — creates a **new** instance every time it's called. Used for BLoCs so each screen tree gets a fresh one.

---

## 12. How to Run

```bash
# 1. Clone the repository
git clone <repo-url>
cd zytama_data

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Build release APK
flutter build apk --release

# 5. Build release iOS
flutter build ipa
```

### Android permissions (already configured)
In `android/app/src/main/AndroidManifest.xml`:
- `android:windowSoftInputMode="adjustResize"` — keyboard pushes content up correctly.
- Camera permission is handled at runtime by `permission_handler` via `mobile_scanner` and `image_picker`.

---

## 13. Demo Credentials

| Field | Value |
|---|---|
| Email | Any valid email format (e.g. `agent@zytama.com`) |
| Password | `123456` |

**Mock barcode behaviour:**
| Barcode | Result |
|---|---|
| `000000000000` | Product Already Exists dialog |
| `123456789012` | Product Already Exists dialog |
| Any other barcode | Proceeds through all 4 capture steps |

---

## 14. Adding a New Feature — Checklist

When adding a new feature (e.g. "Edit existing product"):

- [ ] **Domain** — add abstract method to the relevant repository interface.
- [ ] **Domain** — create a new UseCase class in `domain/usecases/`.
- [ ] **Data** — add method to the DataSource abstract class + implement in `Impl`.
- [ ] **Data** — implement the new method in the repository `Impl`.
- [ ] **DI** — register the new UseCase in `injection_container.dart`.
- [ ] **BLoC** — add new Event(s) and State(s) in the `part` files.
- [ ] **BLoC** — add `on<NewEvent>(_handler)` in the BLoC constructor.
- [ ] **Presentation** — add `BlocListener` or `BlocBuilder` handler in the relevant screen.
- [ ] **Run** `flutter analyze` — must show **No issues found**.

---

## Color Reference (Brand)

| Token | Hex | Usage |
|---|---|---|
| Primary | `#0d631b` | Buttons, icons, FAB |
| On Surface Variant | `#40493d` | Labels, secondary text |
| Outline | `#707a6c` | Input borders |
| Outline Variant | `#bfcaba` | Placeholder text |
| On Surface | `#071e27` | Primary text |
| Error | `#ba1a1a` | Validation errors |
| Surface | `#f3faff` | Background |
| Secondary Fixed Dim | `#bdcabe` | Gradient end colour |

---

*Generated for Zytama Data v1.0.0 — for internal developer use only.*
