import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:astro/admin_app/admin_app.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/flavors.dart';
import 'package:astro/config/flavor_config.dart';
import 'package:astro/config/firebase_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app flavor FIRST
  F.appFlavor = Flavor.admin;
  
  // Initialize Admin app flavor config
  FlavorConfig(
    flavor: Flavor.admin,
    name: F.title,
    primaryColor: const Color(0xFFE1BEE7),  // Light purple
    secondaryColor: const Color(0xFF7B1FA2), // Deep purple
    // Use a basic theme here, the real theme will be set in AdminApp
    theme: ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE1BEE7),
        secondary: Color(0xFF7B1FA2),
      ),
    ),
    baseUrl: "https://api.astro.com/admin",
  );
  
  // Initialize Firebase
  await FirebaseConfig.initializeFirebase();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const AdminApp(),
    ),
  );
} 