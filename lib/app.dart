import 'package:flutter/material.dart';
import 'package:astro/config/flavor_config.dart' as flavor_config;
import 'package:astro/user_app/screens/user_login_screen.dart';
import 'package:astro/user_app/screens/user_register_screen.dart';
import 'package:astro/user_app/screens/user_home_screen.dart';
import 'package:astro/admin_app/screens/admin_login_screen.dart';
import 'package:astro/admin_app/screens/admin_register_screen.dart';
import 'package:astro/admin_app/screens/admin_home_screen.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/flavors.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final config = flavor_config.FlavorConfig.instance;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: F.title,
        theme: config.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => _buildLoginScreen(),
          '/register': (context) => _buildRegisterScreen(),
          '/home': (context) => _buildHomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
  
  Widget _buildLoginScreen() {
    switch (F.appFlavor) {
      case Flavor.user:
        return const UserLoginScreen();
      case Flavor.admin:
        return const AdminLoginScreen();
    }
  }
  
  Widget _buildRegisterScreen() {
    switch (F.appFlavor) {
      case Flavor.user:
        return const UserRegisterScreen();
      case Flavor.admin:
        return const AdminRegisterScreen();
    }
  }
  
  Widget _buildHomeScreen() {
    switch (F.appFlavor) {
      case Flavor.user:
        return const UserHomeScreen();
      case Flavor.admin:
        return const AdminHomeScreen();
    }
  }
}
