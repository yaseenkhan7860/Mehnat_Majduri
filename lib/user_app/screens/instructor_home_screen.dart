import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/user_app/screens/course_creator_screen.dart';
import 'package:astro/core/theme/app_themes.dart';
import 'package:astro/config/flavor_config.dart' as config;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  int _currentIndex = 0;
  
  // Screens for instructor navigation
  final List<Widget> _screens = [
    const InstructorDashboardScreen(),
    const InstructorSessionsScreen(),
    const InstructorChatsScreen(),
    const InstructorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Astro Instructor'),
        automaticallyImplyLeading: false,
        actions: [
          // Profile dropdown menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              // Handle menu item selection
              final authService = Provider.of<AuthService>(context, listen: false);
              switch (value) {
                case 'profile':
                  setState(() {
                    _currentIndex = 3; // Switch to profile tab
                  });
                  break;
                case 'settings':
                  // Navigate to settings page
                  break;
                case 'contact':
                  // Navigate to contact us page
                  break;
                case 'privacy':
                  // Navigate to privacy policy page
                  break;
                case 'logout':
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Instructor Profile'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'contact',
                child: ListTile(
                  leading: Icon(Icons.contact_support),
                  title: Text('Contact Us'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'privacy',
                child: ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy Policy'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildInstructorBottomNavBar(),
    );
  }
  
  Widget _buildInstructorBottomNavBar() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11.sp,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Sessions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashboard screen for instructors
class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructor Dashboard',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Instructor stats
          _buildStatCard('Students', '0', Icons.people),
          _buildStatCard('Sessions', '0', Icons.event),
          _buildStatCard('Earnings', '₹0', Icons.currency_rupee),
          
          SizedBox(height: 24.h),
          
          // Upcoming sessions
          Text(
            'Upcoming Sessions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  'No upcoming sessions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Schedule session button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to session scheduling screen
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const CourseCreatorScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade800,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build stat cards
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(icon, color: Colors.deepPurple.shade800, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Sessions screen for instructors
class InstructorSessionsScreen extends StatelessWidget {
  const InstructorSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sessions Screen - Coming Soon'),
    );
  }
}

// Chats screen for instructors
class InstructorChatsScreen extends StatelessWidget {
  const InstructorChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Chats Screen - Coming Soon'),
    );
  }
}

// Profile screen for instructors
class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen - Coming Soon'),
    );
  }
} 