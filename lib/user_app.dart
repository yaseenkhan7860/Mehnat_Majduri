import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavors.dart';
import 'utils/background_worker.dart';
import 'services/user_auth_service.dart';
import 'screens/user/login_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/interests_screen.dart';
import 'screens/user/home_screen.dart';

// LoadingScreen with Lottie animation
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

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
                'Loading your personalized experience...',
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

// SplashScreen widget with app logo and animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo with animation
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  'Astro App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AuthWrapper to handle authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Attempt silent authentication when the wrapper initializes
    // Delay to show splash screen for a minimum time
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Create a timer to ensure splash screen shows for at least 2 seconds
    final minimumSplashDuration = Future.delayed(const Duration(seconds: 2));
    
    // Get auth service
    final userAuthService = Provider.of<UserAuthService>(context, listen: false);
    bool success = false;
    
    try {
      // Try silent sign-in - always attempt to sign in
      success = await userAuthService.userSilentSignIn();
      print('User silent sign-in result: $success');
      
      // If successful, preload user data for faster screen transition
      if (success) {
        try {
          await userAuthService.getUserProfileData();
        } catch (e) {
          print('Error preloading user data: $e');
        }
      }
    } catch (e) {
      print('Silent authentication error: $e');
    }
    
    // Wait for minimum splash duration to complete
    await minimumSplashDuration;
    
    // Mark initialization as complete
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAuthService = Provider.of<UserAuthService>(context);
    
    // If still initializing, show splash screen
    if (_isInitializing) {
      return const SplashScreen();
    }
    
    // Check if user is authenticated
    if (!userAuthService.isAuthenticated) {
      // Show login screen if not authenticated
      return const UserLoginScreen();
    }
    
    // User is authenticated, go straight to home screen
        return const UserHomeScreen();
  }
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: F.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/interests':
            return MaterialPageRoute(builder: (_) => const UserInterestsScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const UserHomeScreen());
          default:
            return MaterialPageRoute(builder: (_) => const AuthWrapper());
        }
      },
    );
  }
}