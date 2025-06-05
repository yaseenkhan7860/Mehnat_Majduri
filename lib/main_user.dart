import 'package:flutter/material.dart';
import 'package:astro/app.dart';
import 'package:astro/flavors.dart';
import 'package:astro/config/flavor_config.dart';
import 'package:astro/config/firebase_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app flavor
  F.appFlavor = Flavor.user;
  
  // Initialize User app flavor config
  FlavorConfig(
    flavor: Flavor.user,
    name: F.title,
    primaryColor: const Color(0xFFFFB74D),  // Primary orange
    secondaryColor: const Color(0xFFFF9800), // Secondary orange
    // Use a basic theme here, the real theme will be set in App
    theme: ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFFB74D),
        secondary: Color(0xFFFF9800),
      ),
    ),
    baseUrl: "https://api.astro.com/user",
  );
  
  // Initialize Firebase for this flavor
  await FirebaseConfig.initializeFirebase();
  
  runApp(const App(flavor: 'user'));
} 