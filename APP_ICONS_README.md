# App Icons and Themes Setup

This document explains how the app icons and themes are set up for the different flavors of the Astro app.

## App Icons

The app icons for each flavor are stored in:
- User App: `assets/images/user/user_app.jpg`
- Admin App: `assets/images/admin/admin_app.jpg`

### How App Icons Were Generated

The app icons were generated using the `flutter_launcher_icons` package with the following configuration files:
- `flutter_icons_user.yaml`: Configuration for the user app icon
- `flutter_icons_admin.yaml`: Configuration for the admin app icon

To regenerate the icons, run:
```bash
flutter pub run flutter_launcher_icons -f flutter_icons_user.yaml
flutter pub run flutter_launcher_icons -f flutter_icons_admin.yaml
```

## Themes

The app themes are defined in `lib/core/theme/app_themes.dart`:

### User App Theme (Lite Orange)
- Primary color: `Color(0xFFFFB74D)` (Light orange)
- Secondary color: `Color(0xFFFF9800)` (Orange)
- Background color: `Color(0xFFFFF3E0)` (Cream)
- Text on primary: Black
- Card style: White cards with soft shadows and rounded corners

### Admin App Theme (Lite Purple & White)
- Primary color: `Color(0xFFE1BEE7)` (Light purple)
- Secondary color: `Color(0xFF7B1FA2)` (Deep purple)
- Background color: White
- Text on primary: Black
- Card style: White cards with subtle purple borders and shadow effects

### Instructor App Theme (Deeper Orange)
- Primary color: `Color(0xFFFF9800)` (Deep orange)
- Secondary color: `Color(0xFFF57C00)` (Darker orange)
- Background color: `Color(0xFFFFF8E1)` (Light cream)
- Text on primary: White
- Card style: White cards with soft shadows and rounded corners

## Running the App with Different Flavors

To run the app with different flavors, use the following commands:

### User App
```bash
flutter run --flavor user -t lib/main_user.dart
```

### Admin App
```bash
flutter run --flavor admin -t lib/main_admin.dart
```

### Instructor App
```bash
flutter run --flavor instructor -t lib/main_instructor.dart
```

## Building the App for Release

To build the app for release with different flavors, use the following commands:

### Android
```bash
flutter build apk --flavor user -t lib/main_user.dart
flutter build apk --flavor admin -t lib/main_admin.dart
flutter build apk --flavor instructor -t lib/main_instructor.dart
```

### iOS
```bash
flutter build ios --flavor user -t lib/main_user.dart
flutter build ios --flavor admin -t lib/main_admin.dart
flutter build ios --flavor instructor -t lib/main_instructor.dart
``` 