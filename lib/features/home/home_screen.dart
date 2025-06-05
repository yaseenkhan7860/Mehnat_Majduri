import 'package:flutter/material.dart';
import 'package:astro/config/flavor_config.dart';
import 'package:astro/admin_app/screens/admin_home_screen.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/features/courses/screens/course_creator_screen.dart';
import 'package:astro/features/courses/screens/course_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(FlavorConfig.instance.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildBody() {
    if (FlavorConfig.isUser()) {
      return const UserHomeContent();
    } else if (FlavorConfig.isAdmin()) {
      return const AdminHomeContent();
    } else {
      return const Center(
        child: Text('Unknown flavor'),
      );
    }
  }
  
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: FlavorConfig.instance.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _getFlavorIcon(),
                    color: FlavorConfig.instance.primaryColor,
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  FlavorConfig.instance.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                  ),
                ),
                Text(
                  'example@email.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          ..._buildMenuItems(context),
        ],
      ),
    );
  }
  
  List<Widget> _buildMenuItems(BuildContext context) {
    final List<Widget> menuItems = [
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Profile'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to profile screen
        },
      ),
    ];
    
    // Add flavor-specific menu items
    if (FlavorConfig.isUser()) {
      // Check user role to show appropriate menu items
      // In a real app, you would get this from a user service
      final bool isInstructor = false; // Placeholder, would be determined dynamically
      
      if (isInstructor) {
        menuItems.add(
          ListTile(
            leading: const Icon(Icons.create),
            title: const Text('Create Course'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CourseCreatorScreen()),
              );
            },
          ),
        );
        menuItems.add(
          ListTile(
            leading: const Icon(Icons.insights),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to analytics screen
            },
          ),
        );
      } else {
        menuItems.add(
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Browse Courses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CourseListScreen()),
              );
            },
          ),
        );
        menuItems.add(
          ListTile(
            leading: const Icon(Icons.play_lesson),
            title: const Text('My Learning'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to my learning screen
            },
          ),
        );
      }
    } else if (FlavorConfig.isAdmin()) {
      menuItems.add(
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('User Management'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
      );
      menuItems.add(
        ListTile(
          leading: const Icon(Icons.content_paste),
          title: const Text('Content Review'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to content review screen
          },
        ),
      );
    }
    
    // Add settings menu item for all flavors
    menuItems.add(const Divider());
    menuItems.add(
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to settings screen
        },
      ),
    );
    
    return menuItems;
  }
  
  IconData _getFlavorIcon() {
    if (FlavorConfig.isUser()) {
      return Icons.person;
    } else if (FlavorConfig.isAdmin()) {
      return Icons.admin_panel_settings;
    }
    return Icons.error;
  }
}

class UserHomeContent extends StatelessWidget {
  const UserHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Astro User App',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeatureCard(
            context,
            'Find Courses',
            'Browse our catalog of courses',
            Icons.school,
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CourseListScreen()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            'My Learning',
            'Continue your enrolled courses',
            Icons.play_lesson,
            () {
              // Navigate to my learning screen
            },
          ),
          _buildFeatureCard(
            context,
            'Connect with Experts',
            'Get personalized guidance',
            Icons.people,
            () {
              // Navigate to experts list screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24.sp),
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        subtitle: Text(description, style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
        onTap: onTap,
      ),
    );
  }
}

class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAdminCard(context, 'Users', '1,245', Icons.person),
              _buildAdminCard(context, 'Experts', '58', Icons.school),
              _buildAdminCard(context, 'Courses', '210', Icons.book),
              _buildAdminCard(context, 'Revenue', '\$24,530', Icons.money),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildActionButton(
            context, 
            'Manage Users', 
            Icons.people,
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
              );
            },
          ),
          _buildActionButton(
            context, 
            'Review Content', 
            Icons.content_paste,
            () {
              // Navigate to content review screen
            },
          ),
          _buildActionButton(
            context, 
            'System Settings', 
            Icons.settings,
            () {
              // Navigate to system settings screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24.sp),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }
} 