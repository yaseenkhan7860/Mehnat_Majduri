# Theme Integration

This document explains how the themes have been integrated throughout the Astro application.

## Theme Structure

The app themes are defined in `lib/core/theme/app_themes.dart` with three main themes:

1. **User App Theme (Lite Orange)**
   - Primary color: `Color(0xFFFFB74D)` (Light orange)
   - Background color: `Color(0xFFFFF3E0)` (Cream)
   - Text on primary: Black

2. **Admin App Theme (Lite Purple & White)**
   - Primary color: `Color(0xFFE1BEE7)` (Light purple)
   - Secondary color: `Color(0xFF7B1FA2)` (Deep purple)
   - Background color: White
   - Text on primary: Black

3. **Instructor App Theme (Deeper Orange)**
   - Primary color: `Color(0xFFFF9800)` (Deep orange)
   - Secondary color: `Color(0xFFF57C00)` (Darker orange)
   - Background color: `Color(0xFFFFF8E1)` (Light cream)
   - Text on primary: White

## Theme Integration

The themes are integrated in the following key files:

### Main Entry Points

- `lib/main_user.dart`: Configures the user app theme
- `lib/main_admin.dart`: Configures the admin app theme
- `lib/main_instructor.dart`: Configures the instructor app theme

### App Containers

- `lib/app.dart`: Main app container that applies the theme from FlavorConfig
- `lib/admin_app/admin_app.dart`: Admin app container with admin theme

### Screens with Theme Integration

- `lib/user_app/screens/user_home_screen.dart`: Uses theme colors for UI elements
- `lib/user_app/screens/instructor_home_screen.dart`: Uses instructor theme colors
- `lib/shared/screens/email_verification_screen.dart`: Uses theme colors for icons and buttons

## Using Themes in Widgets

When creating or modifying widgets, follow these guidelines:

1. **Access theme colors**:
   ```dart
   final theme = Theme.of(context);
   final primaryColor = theme.colorScheme.primary;
   ```

2. **Use theme properties instead of hardcoded colors**:
   ```dart
   // Instead of:
   color: Colors.orange,
   
   // Use:
   color: Theme.of(context).colorScheme.primary,
   ```

3. **Use theme-based components**:
   ```dart
   // Button with theme colors
   ElevatedButton(
     // The style will automatically use the theme colors
     child: Text('Button'),
     onPressed: () {},
   )
   ```

4. **For custom components, respect the theme**:
   ```dart
   Container(
     decoration: BoxDecoration(
       color: Theme.of(context).cardTheme.color,
       borderRadius: BorderRadius.circular(
         Theme.of(context).cardTheme.shape?.borderRadius?.resolve(TextDirection.ltr)?.topLeft.x ?? 8
       ),
     ),
   )
   ```

## App Icons

The app icons have been configured to match the theme colors:

- User App: Orange-themed icon
- Admin App: Purple-themed icon

The icons are generated using the `flutter_launcher_icons` package. See `APP_ICONS_README.md` for more details. 