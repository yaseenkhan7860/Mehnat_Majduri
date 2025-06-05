import 'package:flutter/material.dart';
import 'package:astro/app.dart';
import 'package:astro/flavors.dart';
import 'package:astro/config/flavor_config.dart';
import 'package:astro/config/firebase_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app flavor
  F.appFlavor = Flavor.instructor;
  
  // Initialize Instructor app flavor config
  FlavorConfig(
    flavor: Flavor.instructor,
    name: F.title,
    primaryColor: const Color(0xFFFF9800),     // Deep orange
    secondaryColor: const Color(0xFFF57C00),   // Darker orange
    // Use a basic theme here, the real theme will be set in App
    theme: ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF9800),
        secondary: Color(0xFFF57C00),
      ),
    ),
    baseUrl: "https://api.astro.com/instructor",
  );
  
  // Initialize Firebase for this flavor
  await FirebaseConfig.initializeFirebase();
  
  runApp(const App(flavor: 'instructor'));
} 