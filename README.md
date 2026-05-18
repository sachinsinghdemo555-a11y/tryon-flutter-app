# 💎 Jewellery TryOn — Flutter App

A virtual jewellery try-on app powered by **Gemini AI**. Select a piece of jewellery, take or upload a selfie, and Gemini generates a photorealistic image of you wearing it.

---

## Features

- 8 pre-defined jewellery products (necklaces, earrings, rings, bangles, etc.)
- **Custom product upload** — photograph any piece of jewellery and try it on
- Camera + gallery support for user photo selection
- Gemini 2.0 Flash image generation (multi-image input → image output)
- Before/After comparison view on the result screen
- Pinch-to-zoom on the generated image
- Clean, elegant deep-purple & gold UI theme

---

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── constants/
│   └── app_constants.dart            # API key, colours, config
├── models/
│   └── jewellery_product.dart        # Product model + catalogue
├── services/
│   └── gemini_service.dart           # Gemini REST API integration
└── screens/
    ├── home_screen.dart              # Welcome / landing screen
    ├── product_selection_screen.dart # Jewellery catalogue grid
    ├── tryon_screen.dart             # User photo capture + generate
    └── result_screen.dart           # Generated image + compare
```

---

## Setup Instructions

### 1 — Prerequisites

- Flutter SDK ≥ 3.2.0 installed
- Android Studio / Xcode set up for your target platform
- A physical device or emulator with camera support

### 2 — Create the Flutter project

```bash
flutter create jewellery_tryon
cd jewellery_tryon
```

### 3 — Replace project files

Copy **all files from this folder** into the newly created project,
overwriting where prompted:

- `pubspec.yaml`
- Everything inside `lib/`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

### 4 — Install dependencies

```bash
flutter pub get
```

### 5 — Android extra step — file_paths.xml

Create `android/app/src/main/res/xml/file_paths.xml` with:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
</paths>
```

### 6 — Run the app

```bash
flutter run
```

---

## Gemini API Details

| Setting | Value |
|---|---|
| Model | `gemini-2.0-flash-exp` |
| Endpoint | `generateContent` |
| Input | User photo + optional product image (base64) |
| Output | `responseModalities: ["IMAGE", "TEXT"]` |
| Timeout | 90 seconds |

> **Security note:** The API key is stored in `lib/constants/app_constants.dart`.
> Do **not** commit this file to a public repository.
> For production, load the key from environment variables or a secure vault.

### Troubleshooting

| Symptom | Fix |
|---|---|
| "No image returned" | The model returned text only — try with a clearer, well-lit selfie |
| HTTP 400 | Image too large — ensure photos are ≤ 4 MB (the app resizes to 1024 px max) |
| HTTP 429 | API quota exceeded — wait and retry |
| Timeout | Check your internet connection; generation can take up to 30 s |

---

## Permissions

### Android
`CAMERA`, `READ_MEDIA_IMAGES` (API 33+), `READ_EXTERNAL_STORAGE` (API ≤ 32), `INTERNET`

### iOS
`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`

---

## Extending the App

- **More products:** Add entries to `JewelleryProduct.predefinedProducts` in `jewellery_product.dart`
- **Save to gallery:** Add the `gal` package and call `Gal.putImageBytes(bytes)` in `result_screen.dart`
- **Share image:** Add the `share_plus` package and use `Share.shareXFiles`
- **History:** Persist generated images locally using `path_provider` + `sqflite`
