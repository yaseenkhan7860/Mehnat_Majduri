# Astro App

A Flutter application with multiple flavors for different user types: User, Instructor, and Admin.

## Setup

1. Make sure you have Flutter installed and set up on your machine.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.

## Firebase Configuration

### Android

Place the appropriate `google-services.json` files in the following directories:

- User App: `android/app/src/user/google-services.json`
- Instructor App: `android/app/src/instructor/google-services.json`
- Admin App: `android/app/src/admin/google-services.json`

### iOS

Place the appropriate `GoogleService-Info.plist` files in the following directories:

- User App: `ios/Flutter/user/GoogleService-Info.plist`
- Instructor App: `ios/Flutter/instructor/GoogleService-Info.plist`
- Admin App: `ios/Flutter/admin/GoogleService-Info.plist`

## Running the App

### User App

```bash
flutter run --flavor user --dart-define=FLAVOR=user -t lib/main.dart
```

### Instructor App

```bash
flutter run --flavor instructor --dart-define=FLAVOR=instructor -t lib/main.dart
```

### Admin App

For development:
```bash
flutter run --flavor admin --dart-define=FLAVOR=admin -t lib/main.dart
```

For web deployment:
```bash
flutter build web --dart-define=FLAVOR=admin
```

## Features

### User App
- Browse courses
- Book consultations
- View learning materials
- Track progress

### Instructor App
- Manage courses
- Schedule live sessions
- View earnings
- Interact with students

### Admin App
- User management
- Course management
- Instructor management
- Analytics dashboard
- Payment reports
