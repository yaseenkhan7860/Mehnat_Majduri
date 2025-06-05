import 'package:flutter/material.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/admin_app/screens/admin_login_screen.dart';
import 'package:astro/admin_app/screens/admin_home_screen.dart';
import 'package:astro/admin_app/screens/users/user_management_screen.dart';
import 'package:astro/admin_app/screens/manage_admins_screen.dart';
import 'package:astro/admin_app/screens/manage_astrologers_screen.dart';
import 'package:astro/admin_app/widgets/admin_scaffold.dart';
import 'package:astro/admin_app/screens/products/manage_products_screen.dart';
import 'package:astro/admin_app/screens/courses/all_courses_screen.dart';
import 'package:astro/admin_app/screens/courses/manage_courses_screen.dart';
import 'package:astro/admin_app/screens/homepage/news_screen.dart';
import 'package:astro/admin_app/screens/homepage/banner_screen.dart';
import 'package:astro/admin_app/screens/homepage/kundali_review_screen.dart';
import 'package:astro/admin_app/screens/homepage/horoscope_review_screen.dart';
import 'package:astro/admin_app/screens/live/live_sessions_screen.dart';
import 'package:astro/admin_app/screens/live/manage_recordings_screen.dart';
import 'package:astro/admin_app/screens/earnings/product_sales_screen.dart';
import 'package:astro/admin_app/screens/earnings/subscription_sales_screen.dart';
import 'package:astro/admin_app/screens/earnings/total_stats_screen.dart';
import 'package:astro/admin_app/screens/community/community_room_screen.dart';
import 'package:astro/admin_app/screens/community/user_chats_screen.dart';
import 'package:astro/core/theme/app_themes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Astro Admin',
          theme: AppThemes.getAdminTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => _buildAuthWrapper(),
            '/admin_home': (context) => const AdminScaffold(
              currentIndex: 0,
              body: AdminHomeScreen(),
            ),
            '/manage_customers': (context) => const AdminScaffold(
              currentIndex: 1,
              body: UserManagementScreen(),
            ),
            '/manage_astrologers': (context) => const AdminScaffold(
              currentIndex: 2,
              body: ManageAstrologersScreen(),
            ),
            '/manage_admins': (context) => const AdminScaffold(
              currentIndex: 3,
              body: ManageAdminsScreen(),
            ),
            // Product Management
            '/manage_products': (context) => const AdminScaffold(
              currentIndex: 5,
              body: ManageProductsScreen(),
            ),
            // Course Management
            '/all_courses': (context) => const AdminScaffold(
              currentIndex: 6,
              body: AllCoursesScreen(),
            ),
            '/manage_courses': (context) => const AdminScaffold(
              currentIndex: 7,
              body: ManageCoursesScreen(),
            ),
            // Home Page Management
            '/news': (context) => const AdminScaffold(
              currentIndex: 8,
              body: NewsScreen(),
            ),
            '/banner': (context) => const AdminScaffold(
              currentIndex: 9,
              body: BannerScreen(),
            ),
            '/kundali_review': (context) => const AdminScaffold(
              currentIndex: 10,
              body: KundaliReviewScreen(),
            ),
            '/horoscope_review': (context) => const AdminScaffold(
              currentIndex: 11,
              body: HoroscopeReviewScreen(),
            ),
            // Live Management
            '/live_sessions': (context) => const AdminScaffold(
              currentIndex: 12,
              body: LiveSessionsScreen(),
            ),
            '/manage_recordings': (context) => const AdminScaffold(
              currentIndex: 13,
              body: ManageRecordingsScreen(),
            ),
            // Earnings
            '/product_sales': (context) => const AdminScaffold(
              currentIndex: 14,
              body: ProductSalesScreen(),
            ),
            '/subscription_sales': (context) => const AdminScaffold(
              currentIndex: 15,
              body: SubscriptionSalesScreen(),
            ),
            '/total_stats': (context) => const AdminScaffold(
              currentIndex: 16,
              body: TotalStatsScreen(),
            ),
            // Community
            '/community_room': (context) => const AdminScaffold(
              currentIndex: 17,
              body: CommunityRoomScreen(),
            ),
            '/user_chats': (context) => const AdminScaffold(
              currentIndex: 18,
              body: UserChatsScreen(),
            ),
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const AdminLoginScreen(),
            );
          },
        );
      },
    );
  }
  
  Widget _buildAuthWrapper() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;
              if (user == null) {
                return const AdminLoginScreen();
              }
              // If user is signed in, check if they are an admin
              if (authService.isSignedIn && authService.userRole == 'admin') {
                return const AdminScaffold(
                  currentIndex: 0,
                  body: AdminHomeScreen(),
                );
              } else {
                // Not an admin, show login screen
                return const AdminLoginScreen();
              }
            }
            // Show loading indicator while checking auth state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
} 