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
import 'package:astro/user_app/screens/user_profile_screen.dart';
import 'package:astro/core/theme/app_themes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const UserHomeContent(),
    const UserCoursesScreen(),
    const UserLiveScreen(),
    const UserChatScreen(),
    const UserProductsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/user/user_app.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'AstroApp',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Subscription icon button with notification dot
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                // Navigate to subscription plans page
                Navigator.of(context).pushNamed('/subscription_plans');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
          Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            size: 22.sp,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6.w,
                        right: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.w),
              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Profile dropdown menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.account_circle,
              color: Colors.deepOrange.shade400,
              size: 24.sp,
            ),
            onSelected: (value) async {
              // Handle menu item selection
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                  );
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
                  title: Text('Profile'),
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: Colors.deepOrange.shade600,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 9.sp,
            ),
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.school_outlined, Icons.school, 'Courses', 1),
              _buildNavItem(Icons.live_tv_outlined, Icons.live_tv, 'Live', 2),
              _buildNavItem(Icons.chat_outlined, Icons.chat, 'Chat', 3),
              _buildNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Products', 4),
            ],
            selectedIconTheme: IconThemeData(
              shadows: [
                Shadow(
                  color: Colors.deepOrange.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _currentIndex == index ? selectedIcon : unselectedIcon,
        size: 22.sp,
      ),
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
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 80.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sloka of the day section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories, color: Colors.deepOrange, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Sloka of the Day',
                        style: TextStyle(
                          fontSize: 16.sp,
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
          
          // Shortcut Options Label
          Text(
            'Shortcut Options',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Two feature cards side by side (Shortcut Options)
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
          
          // Banner Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: _HighlightsBannerCarousel(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // News and Articles section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest News & Articles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all news/articles
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildNewsCard(
                      'Understanding Planetary Transits',
                      'Learn how planetary movements affect your life',
                      'Dr. Sharma',
                      '10 min read',
                      Colors.indigo.shade100,
                      Icons.article,
                      Colors.indigo,
                    ),
                    const SizedBox(width: 16),
                    _buildNewsCard(
                      'Mercury Retrograde Explained',
                      'What it means for your communication',
                      'Astro Team',
                      '5 min video',
                      Colors.teal.shade100,
                      Icons.play_circle_filled,
                      Colors.teal,
                    ),
                    const SizedBox(width: 16),
                    _buildNewsCard(
                      'Full Moon Rituals',
                      'Harness the energy of the full moon',
                      'Maya Patel',
                      '8 min read',
                      Colors.purple.shade100,
                      Icons.article,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Section Headers
          Text(
            'Detailed Sections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
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
  
  Widget _buildNewsCard(String title, String description, String author, String duration, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Open news/article
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Divider(thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    author,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    
    // Show loading indicator while waiting for role
    if (authService.currentUser != null && authService.userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Astro Learning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
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

  @override
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
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
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('My Courses'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to courses screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
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

  Widget _buildDrawerHeader(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
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
            child: Text(
              user?.displayName?.isNotEmpty == true
                  ? user!.displayName![0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
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
    return const UserCoursesScreenContent();
  }
}

class UserCoursesScreenContent extends StatefulWidget {
  const UserCoursesScreenContent({super.key});

  @override
  State<UserCoursesScreenContent> createState() => _UserCoursesScreenContentState();
}

class _UserCoursesScreenContentState extends State<UserCoursesScreenContent> with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Featured', 'Astrology', 'Numerology', 'Tarot', 'Vastu'];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImprovedCategoryNavBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(_categories.length, (index) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Popular courses section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCoursesSectionTitle(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Course cards
                  _buildCourseCard(
                    title: 'Introduction to ${_categories[index]}',
                    instructor: 'Prof. Jane Smith',
                    duration: '8 hours',
                    level: 'Beginner',
                    image: 'https://via.placeholder.com/150/6A1B9A/FFFFFF?text=${_categories[index]}',
                  ),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                    title: 'Advanced ${_categories[index]} Techniques',
                    instructor: 'Dr. Michael Brown',
                    duration: '12 hours',
                    level: 'Intermediate',
                    image: 'https://via.placeholder.com/150/00796B/FFFFFF?text=${_categories[index]}',
                  ),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                    title: '${_categories[index]} Fundamentals',
                    instructor: 'Sarah Johnson',
                    duration: '6 hours',
                    level: 'Beginner',
                    image: 'https://via.placeholder.com/150/C62828/FFFFFF?text=${_categories[index]}',
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovedCategoryNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  String _getCoursesSectionTitle() {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'Popular Courses';
      case 1:
        return 'Astrology Courses';
      case 2:
        return 'Numerology Courses';
      case 3:
        return 'Tarot Courses';
      case 4:
        return 'Vastu Courses';
      default:
        return 'Popular Courses';
    }
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required String duration,
    required String level,
    required String image,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By $instructor',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(duration),
                        backgroundColor: Colors.blue.shade100,
                        labelStyle: TextStyle(color: Colors.blue.shade800),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(level),
                        backgroundColor: Colors.green.shade100,
                        labelStyle: TextStyle(color: Colors.green.shade800),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('View Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.bookmark_border, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightsBannerCarousel extends StatefulWidget {
  @override
  _HighlightsBannerCarouselState createState() => _HighlightsBannerCarouselState();
}

class _HighlightsBannerCarouselState extends State<_HighlightsBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Special Offer',
      'subtitle': 'Get 30% Off on Premium Consultations',
      'imageUrl': 'https://via.placeholder.com/600x300/6A1B9A/FFFFFF?text=Special+Offer',
      'gradientColors': [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
    },
    {
      'title': 'New Course',
      'subtitle': 'Learn Vedic Astrology Fundamentals',
      'imageUrl': 'https://via.placeholder.com/600x300/00796B/FFFFFF?text=New+Course',
      'gradientColors': [Colors.teal.shade400, Colors.teal.shade800],
    },
    {
      'title': 'Live Session',
      'subtitle': 'Join our weekly planetary transit discussion',
      'imageUrl': 'https://via.placeholder.com/600x300/C62828/FFFFFF?text=Live+Session',
      'gradientColors': [Colors.red.shade400, Colors.red.shade800],
    },
  ];
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image container
                        Image.network(
                          banner['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: banner['gradientColors'],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner['title'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner['subtitle'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }
} 