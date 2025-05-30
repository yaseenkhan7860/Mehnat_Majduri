//changed one
import 'package:flutter/material.dart';
import 'package:astro/shared/screens/home_screen.dart';
import 'package:astro/user_app/screens/course_list_screen.dart';
import 'package:astro/user_app/screens/course_creator_screen.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/shared/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/user_app/screens/user_courses_screen.dart';
import 'package:astro/user_app/screens/user_live_screen.dart';
import 'package:astro/user_app/screens/user_chat_screen.dart';
import 'package:astro/user_app/screens/user_products_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeContent(),
    const UserCoursesScreen(),
    const UserLiveScreen(),
    const UserChatScreen(),
    const UserProductsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('User App'),
        actions: [
          // API settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Settings',
            onPressed: () {
              // Navigate to API settings
            },
          ),
          // Subscription button with improved UI
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.card_membership, size: 18),
              label: const Text('Subscription', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade800,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onPressed: () {
                // Navigate to subscription page
              },
            ),
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.school_outlined, Icons.school, 'Courses', 1),
              _buildNavItem(Icons.live_tv_outlined, Icons.live_tv, 'Live', 2),
              _buildNavItem(Icons.chat_outlined, Icons.chat, 'Chat', 3),
              _buildNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Products', 4),
            ],
          ),
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(_currentIndex == index ? selectedIcon : unselectedIcon),
      label: label,
    );
  }
}

// Keys for scrolling to sections
final _horoscopeKey = GlobalKey();
final _kundaliKey = GlobalKey();

class UserHomeContent extends StatelessWidget {
  const UserHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sloka of the day section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories, color: Colors.deepOrange, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Sloka of the Day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(thickness: 1),
                  const SizedBox(height: 12),
                  Text(
                    'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज । अहं त्वा सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः ॥',
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Abandoning all duties, take refuge in Me alone. I shall liberate you from all sins; do not grieve.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- Bhagavad Gita, Chapter 18, Verse 66',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Two feature cards side by side
          Row(
            children: [
              // Daily Horoscope Card - Left half
              Expanded(
                child: _buildFeatureCard(
                  'Daily Horoscope',
                  'Get your personalized daily predictions',
                  Icons.wb_sunny_rounded,
                  Colors.amber,
                  Colors.amber.shade50,
                  () {
                    // Scroll to horoscope section
                    Scrollable.ensureVisible(
                      _horoscopeKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Free Kundali Card - Right half
              Expanded(
                child: _buildFeatureCard(
                  'Free Kundali',
                  'Discover your celestial blueprint',
                  Icons.auto_graph,
                  Colors.red,
                  Colors.red.shade50,
                  () {
                    // Scroll to kundali section
                    Scrollable.ensureVisible(
                      _kundaliKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Daily horoscope details card with key for scrolling
          Card(
            key: _horoscopeKey,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sunny, color: Colors.amber, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Your Daily Horoscope',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(thickness: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Today is a great day to explore new ideas and connect with those who share your interests. Your intuition is particularly strong today.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to full horoscope
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text('Read Full Horoscope'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Kundali Card with key for scrolling
          Card(
            key: _kundaliKey,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.purple, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Your Kundali Chart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(thickness: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Discover your celestial blueprint with a personalized Kundali chart. Gain insights into your personality, relationships, career, and life path based on your birth details.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to Kundali view
                      },
                      icon: Icon(Icons.visibility),
                      label: Text('View Your Kundali'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, String description, IconData iconData, Color iconColor, Color backgroundColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 48,
                color: iconColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserHomeScreenShared extends SharedHomeScreen {
  const UserHomeScreenShared({super.key});

  @override
  Widget buildBody(BuildContext context) {
    // Use the AuthService to get the user's role
    final authService = Provider.of<AuthService>(context);
    final isInstructor = authService.isInstructor;
    
    // Show loading indicator while waiting for role
    if (authService.currentUser != null && authService.userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInstructor 
                ? 'Welcome to Astro Expert Platform' 
                : 'Welcome to Astro Learning',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Show different content based on user role
          if (isInstructor) ...[
            _buildStatCard(
              context,
              'Students',
              '120',
              Icons.people,
            ),
            _buildStatCard(
              context,
              'Courses',
              '8',
              Icons.book,
            ),
            _buildStatCard(
              context,
              'Earnings',
              '\$2,450',
              Icons.attach_money,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const CourseCreatorScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Course'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ] else ...[
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
        ],
      ),
    );
  }

  @override
  Widget buildDrawer(BuildContext context) {
    // Use the AuthService to get the user's role
    final authService = Provider.of<AuthService>(context);
    final isInstructor = authService.isInstructor;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, isInstructor),
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
          
          // Conditional menu items based on role
          if (isInstructor) ...[
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
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics screen
              },
            ),
          ] else ...[
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
            ListTile(
              leading: const Icon(Icons.play_lesson),
              title: const Text('My Learning'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to my learning screen
              },
            ),
          ],
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isInstructor) {
    final authService = Provider.of<AuthService>(context);
    
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              isInstructor ? Icons.school : Icons.person,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isInstructor ? 'Astro Expert' : 'Astro User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          Text(
            authService.currentUser?.email ?? 'example@email.com',
            style: const TextStyle(
              color: Colors.white70,
            ),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserCoursesScreen extends StatelessWidget {
  const UserCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
      child: Column(
        // ... existing code ...
      ),
    );
  }
} 