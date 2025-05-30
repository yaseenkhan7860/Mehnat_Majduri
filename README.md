# Astro Flutter App

A Flutter application that serves three distinct roles: User, Instructor (Expert), and Admin, using Flutter Flavors.

## Project Structure

This project uses Flutter Flavors to create three separate apps from a single codebase:

- **User App**: For learners and consumers of content
- **Instructor App**: For experts who create courses and content
- **Admin App**: For platform administrators

## Getting Started

### Prerequisites

- Flutter SDK (3.8.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code

### Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run the app with the desired flavor

### Running the App

#### Using Command Line

To run a specific flavor:

```bash
# For User App
flutter run --flavor user -t lib/main_user.dart

# For Instructor App
flutter run --flavor instructor -t lib/main_instructor.dart

# For Admin App
flutter run --flavor admin -t lib/main_admin.dart
```

#### Using VS Code

This project includes VS Code launch configurations for each flavor. Open the Run and Debug panel and select one of the following:

- User App
- Instructor App
- Admin App

### Building the App

To build a specific flavor:

```bash
# For User App - Android
flutter build apk --flavor user -t lib/main_user.dart

# For Instructor App - Android
flutter build apk --flavor instructor -t lib/main_instructor.dart

# For Admin App - Android
flutter build apk --flavor admin -t lib/main_admin.dart

# For iOS, replace 'apk' with 'ios'
```

## Flavor Configuration

Each flavor has its own:
- App name
- Bundle ID / Application ID
- App icon (to be configured)
- Theme
- Backend configuration
