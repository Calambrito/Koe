# Logo Setup Guide for Koe Music App

## 📁 Required Logo Files

Place your logo images in the `assets/logo/` directory:

1. **`app_icon.png`** - App launcher icon (1024x1024px recommended)
2. **`splash_logo.png`** - Splash screen logo (512x512px recommended)
3. **`app_logo.png`** - In-app logo (256x256px recommended)

## 🎯 Logo Requirements

### App Icon (`app_icon.png`)
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Style**: Square design that works well when scaled down
- **Background**: Transparent or solid color

### Splash Logo (`splash_logo.png`)
- **Size**: 512x512 pixels
- **Format**: PNG with transparency
- **Style**: Centered logo that looks good on dark background
- **Background**: Transparent (will be shown on dark background)

### In-App Logo (`app_logo.png`)
- **Size**: 256x256 pixels
- **Format**: PNG with transparency
- **Style**: Clean logo for use within the app
- **Background**: Transparent

## 🚀 Setup Commands

After placing your logo files in `assets/logo/`, run these commands:

```bash
# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Where Logos Appear

1. **App Icon**: Home screen, app drawer, settings
2. **Splash Screen**: Shows when app starts (before your custom splash page)
3. **In-App Logo**: Used in splash page and can be used anywhere in the app

## 🎨 Using the Logo in Code

```dart
import 'package:koe/core/widgets/app_logo.dart';

// In your widget
const AppLogo(
  width: 120,
  height: 120,
)
```

## 🔧 Customization

### Change Splash Screen Color
Edit `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#121212"  # Change this to your preferred color
```

### Change App Icon Name
Edit `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: "launcher_icon"  # Change this to your preferred name
```

## 📝 Notes

- The app will show a fallback gradient logo if the image files are missing
- Make sure your logo files are high quality and properly sized
- Test on different screen sizes to ensure logos look good
- The splash screen appears briefly before your custom splash page

## 🆘 Troubleshooting

If logos don't appear:
1. Check file paths are correct
2. Ensure image files are valid PNG format
3. Run `flutter clean` and rebuild
4. Check console for any error messages

