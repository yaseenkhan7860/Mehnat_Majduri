# Admin App Architecture

This document outlines the architecture and reusable components of the Admin App.

## Reusable Components

### AdminBaseScreen

`AdminBaseScreen` is an abstract base class that provides common functionality for admin screens:

- Admin authentication verification
- Search controller with standard UI
- Tab controller with standard UI
- Loading state management
- Placeholder content for screens under development

#### Usage:

```dart
class MyAdminScreen extends StatefulWidget {
  const MyAdminScreen({super.key});

  @override
  State<MyAdminScreen> createState() => _MyAdminScreenState();
}

class _MyAdminScreenState extends AdminBaseScreen<MyAdminScreen> {
  @override
  int get tabCount => 2; // Number of tabs, or 1 if no tabs are used
  
  @override
  void onInit() {
    super.onInit();
    // Additional initialization code
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Tab bar (if needed)
          buildTabBar(
            tabs: const [
              Tab(text: 'Tab 1'),
              Tab(text: 'Tab 2'),
            ],
          ),
          
          // Search bar (if needed)
          buildSearchBar(hintText: 'Search...'),
          
          // Main content
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // Tab content
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### AdminStatCard

`AdminStatCard` is a reusable widget for displaying statistics in a consistent format.

#### Usage:

```dart
// Standard stat card
AdminStatCard(
  title: 'Total Sales',
  value: '$125,000',
  color: Colors.green,
),

// Stat card with icon
AdminStatCard(
  title: 'Total Revenue',
  value: '$200,000',
  color: Colors.green,
  icon: Icons.attach_money,
  isLarge: true,
),
```

## Directory Structure

- `/admin_app`
  - `/screens` - All admin screens organized by feature
    - `/users` - User management screens
    - `/products` - Product management screens
    - `/courses` - Course management screens
    - `/homepage` - Homepage management screens
    - `/live` - Live session management screens
    - `/earnings` - Earnings and analytics screens
    - `/community` - Community management screens
  - `/widgets` - Reusable widgets specific to the admin app
  - `/services` - Admin-specific services
  - `/models` - Admin-specific data models

## Best Practices

1. Use `AdminBaseScreen` for all new admin screens to ensure consistent behavior
2. Use `AdminStatCard` for displaying statistics
3. Organize screens by feature in appropriate subdirectories
4. Keep business logic in services, not in UI components
5. Verify admin authentication in all screens
6. Follow consistent UI patterns across all admin screens 