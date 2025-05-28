import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavors.dart';
import 'utils/background_worker.dart';
import 'services/instructor_auth_service.dart';
import 'screens/instructor/profile_screen.dart';
import 'screens/instructor/login_screen.dart';

// LoadingScreen with Lottie animation
class InstructorLoadingScreen extends StatelessWidget {
  const InstructorLoadingScreen({super.key});

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
                'Loading your instructor dashboard...',
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

// InstructorBottomNavBar widget
class InstructorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const InstructorBottomNavBar({
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
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv),
          label: 'Live',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
      ],
    );
  }
}

// Override the TopNavBar to customize the profile navigation for instructors
class InstructorTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const InstructorTopNavBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _navigateToProfile(BuildContext context) {
    // Navigate to instructor profile instead of user profile
    Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructorProfileScreen()));
  }
  
  // Custom implementation for instructor app - shows earnings page instead of subscription
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // Earnings button instead of subscription
        TextButton.icon(
          icon: const Icon(Icons.payments, color: Colors.white),
          label: const Text('Earnings', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Navigate to earnings page
            _showEarningsDialog(context);
          },
        ),
        // Profile button
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            // Navigate to instructor profile
            _navigateToProfile(context);
          },
        ),
        ...(actions ?? []),
      ],
    );
  }
  
  void _showEarningsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Earnings Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEarningItem('This Month', '\$1,250.00'),
              const Divider(),
              _buildEarningItem('Previous Month', '\$980.50'),
              const Divider(),
              _buildEarningItem('Total Earnings', '\$8,456.75'),
              const Divider(),
              _buildEarningItem('Pending Payout', '\$1,250.00'),
              const SizedBox(height: 20),
              const Text(
                'Next payout scheduled for June 1, 2023',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
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
                // Navigate to detailed earnings page
              },
              child: const Text('View Details'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildEarningItem(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class InstructorApp extends StatelessWidget {
  const InstructorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instructor App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      home: const InstructorAuthWrapper(),
    );
  }
}

class InstructorAuthWrapper extends StatefulWidget {
  const InstructorAuthWrapper({super.key});

  @override
  State<InstructorAuthWrapper> createState() => _InstructorAuthWrapperState();
}

class _InstructorAuthWrapperState extends State<InstructorAuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Attempt silent authentication when the wrapper initializes
    _attemptSilentAuth();
  }

  Future<void> _attemptSilentAuth() async {
    // Get auth service
    final instructorAuthService = Provider.of<InstructorAuthService>(context, listen: false);
    try {
      // Try silent sign-in
      final success = await instructorAuthService.instructorSilentSignIn();
      print('Instructor silent sign-in result: $success');
      
      // Check if we should remember login
      final prefs = await SharedPreferences.getInstance();
      final shouldRemember = prefs.getBool('instructor_remember_login') ?? false;
      
      if (!success && !shouldRemember) {
        // Clear any stored credentials if we shouldn't remember login
        await prefs.remove('instructor_auth_email');
        await prefs.remove('instructor_auth_password');
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
    final instructorAuthService = Provider.of<InstructorAuthService>(context);
    
    // If still initializing, show loading screen
    if (_isInitializing) {
      return const InstructorLoadingScreen();
    }
    
    // Check if user is authenticated
    if (!instructorAuthService.isAuthenticated) {
      // Show login screen if not authenticated
      return const InstructorLoginScreen();
    }
    
    // After initialization, show instructor home page if authenticated
    return const InstructorHomePage();
  }
}

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  bool _isLoading = false;
  String _result = '';
  int _currentIndex = 0;

  // Example of a function that uses background processing for analytics
  Future<void> _generateAnalyticsReport() async {
    setState(() {
      _isLoading = true;
      _result = 'Generating analytics report...';
    });

    try {
      // Generate sample data for analytics
      final List<int> analyticsData = List.generate(500, (index) => index * 2);
      
      // Process analytics in background isolate
      final result = await BackgroundWorker.compute(
        _processAnalyticsData, 
        analyticsData
      );
      
      setState(() {
        _result = 'Analytics complete!\nProcessed ${result.length} data points\nAverage: ${result['average']}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error generating analytics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // This function runs in a separate isolate
  static Map<String, dynamic> _processAnalyticsData(List<int> data) {
    // Simulate complex analytics processing
    int sum = 0;
    List<int> processedData = [];
    
    for (int i = 0; i < data.length; i++) {
      // Simulate complex calculations
      int value = 0;
      for (int j = 0; j < 5000; j++) {
        value += (data[i] * j) % 100;
      }
      sum += value;
      processedData.add(value);
    }
    
    return {
      'data': processedData,
      'average': sum / data.length,
    };
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InstructorTopNavBar(
        title: 'Instructor App',
      ),
      body: _buildBody(),
      bottomNavigationBar: InstructorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    // Return different content based on selected tab
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCoursesContent();
      case 2:
        return _buildLiveContent();
      case 3:
        return _buildChatContent();
      case 4:
        return _buildProductsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to the Instructor App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Manage your courses and live sessions here'),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentIndex = 1); // Navigate to Courses tab
            },
            child: const Text('My Courses'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentIndex = 2); // Navigate to Schedule tab
            },
            child: const Text('Schedule Live Session'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('View Earnings'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _generateAnalyticsReport,
            child: const Text('Generate Analytics Report'),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Text(_result),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'My Courses',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Manage your courses here'),
        ],
      ),
    );
  }

  Widget _buildLiveContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv, size: 64, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Live Sessions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Manage your live streaming sessions'),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Chat with your students'),
        ],
      ),
    );
  }

  Widget _buildProductsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 64, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Products',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Manage your learning materials and products'),
        ],
      ),
    );
  }
} 