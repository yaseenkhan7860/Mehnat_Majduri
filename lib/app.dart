import 'package:flutter/material.dart';
import 'package:astro/config/flavor_config.dart' as flavor_config;
import 'package:astro/user_app/screens/user_login_screen.dart';
import 'package:astro/user_app/screens/user_register_screen.dart';
import 'package:astro/user_app/screens/user_home_screen.dart';
import 'package:astro/user_app/screens/user_profile_screen.dart';
import 'package:astro/user_app/screens/instructor_home_screen.dart';
import 'package:astro/user_app/screens/subscription_plans_screen.dart';
import 'package:astro/admin_app/screens/admin_login_screen.dart';
import 'package:astro/admin_app/screens/admin_home_screen.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/flavors.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class App extends StatefulWidget {
  final String flavor;

  const App({
    super.key,
    required this.flavor,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = flavor_config.FlavorConfig.instance;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
          lazy: false,
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Design size based on iPhone X
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: '${F.title} ${_packageInfo?.version ?? ''}',
            theme: config.theme,
            initialRoute: _getInitialRoute(),
            onGenerateRoute: _generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
  
  String _getInitialRoute() {
    switch (widget.flavor) {
      case 'admin':
        return '/admin_login';
      case 'user':
      default:
        return '/login';
    }
  }
  
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (widget.flavor) {
      case 'admin':
        return _generateAdminRoute(settings);
      case 'user':
      default:
        return _generateUserRoute(settings);
    }
  }

  Route<dynamic>? _generateAdminRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/admin_login':
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case '/admin_home':
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
    }
  }

  Route<dynamic>? _generateUserRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const UserLoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const UserRegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case '/instructor_home':
        return MaterialPageRoute(builder: (_) => const InstructorHomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case '/subscription_plans':
        return MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen());
      default:
        return MaterialPageRoute(builder: (_) => const UserLoginScreen());
    }
  }
}
