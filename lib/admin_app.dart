import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavors.dart';
import 'services/admin_auth_service.dart';
import 'screens/admin/create_instructor_screen.dart';
import 'screens/admin/manage_instructors_screen.dart';
import 'screens/admin/profile_screen.dart';
import 'screens/admin/login_screen.dart';

// Admin TopNavBar
class AdminTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AdminTopNavBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _navigateToProfile(BuildContext context) {
    // Navigate to admin profile instead of user profile
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfileScreen()));
  }
  
  // Custom implementation for admin app - shows analytics instead of subscription
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // Analytics button instead of subscription
        TextButton.icon(
          icon: const Icon(Icons.analytics, color: Colors.white),
          label: const Text('Analytics', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Show analytics info
            _showAnalyticsDialog(context);
          },
        ),
        // Profile button
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            // Navigate to admin profile
            _navigateToProfile(context);
          },
        ),
        // Additional actions
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to system settings
          },
        ),
      ],
    );
  }
  
  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Platform Analytics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsItem('User Growth', '+15%', Colors.green),
              const Divider(),
              _buildAnalyticsItem('Course Enrollments', '+8%', Colors.green),
              const Divider(),
              _buildAnalyticsItem('Revenue', '+12%', Colors.green),
              const Divider(),
              _buildAnalyticsItem('Active Users', '-2%', Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Based on last 30 days of activity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to detailed analytics page
              },
              child: const Text('View Details'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildAnalyticsItem(String title, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            change,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      home: const AdminAuthWrapper(),
    );
  }
}

class AdminAuthWrapper extends StatefulWidget {
  const AdminAuthWrapper({super.key});

  @override
  State<AdminAuthWrapper> createState() => _AdminAuthWrapperState();
}

class _AdminAuthWrapperState extends State<AdminAuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Attempt silent authentication when the wrapper initializes
    _attemptSilentAuth();
  }

  Future<void> _attemptSilentAuth() async {
    // Get auth service
    final adminAuthService = Provider.of<AdminAuthService>(context, listen: false);
    try {
      // Try silent sign-in
      final success = await adminAuthService.adminSilentSignIn();
      print('Admin silent sign-in result: $success');
      
      // Check if we should remember login
      final prefs = await SharedPreferences.getInstance();
      final shouldRemember = prefs.getBool('admin_remember_login') ?? false;
      
      if (!success && !shouldRemember) {
        // Clear any stored credentials if we shouldn't remember login
        await prefs.remove('admin_auth_email');
        await prefs.remove('admin_auth_password');
      }
    } catch (e) {
      print('Silent authentication error: $e');
    } finally {
      // Mark initialization as complete regardless of auth result
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Provider.of<AdminAuthService>(context);
    
    // If still initializing, show loading screen
    if (_isInitializing) {
      return const AdminLoadingScreen();
    }
    
    // Check if user is authenticated
    if (!adminAuthService.isAuthenticated) {
      // Show login screen if not authenticated
      return const AdminLoginScreen();
    }
    
    // After initialization, show admin home page if authenticated
    return const AdminHomePage();
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminTopNavBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Instructor Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageInstructorsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Course Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    // Return different content based on selected tab
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildUsersContent();
      case 2:
        return _buildInstructorsContent();
      case 3:
        return _buildCoursesContent();
      case 4:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Total Users', '1,245', Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Active Courses', '87', Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Instructors', '32', Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Create Instructor Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateInstructorScreen()),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Activity ${index + 1}'),
                  subtitle: Text('Description of activity ${index + 1}'),
                  trailing: Text('${DateTime.now().day}/${DateTime.now().month}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    return const Center(
      child: Text('User Management', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildInstructorsContent() {
    return const Center(
      child: Text('Instructor Management', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildCoursesContent() {
    return const Center(
      child: Text('Course Management', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Loading Screen
class AdminLoadingScreen extends StatelessWidget {
  const AdminLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 32),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading admin dashboard...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AdminBottomNavBar widget
class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Instructors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
} 