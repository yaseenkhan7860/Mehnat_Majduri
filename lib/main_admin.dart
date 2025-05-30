import 'package:flutter/material.dart';
import 'package:astro/app.dart';
import 'package:astro/flavors.dart';
import 'package:astro/config/flavor_config.dart' as config;
import 'package:astro/core/theme/app_themes.dart';
import 'package:astro/config/firebase_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app flavor
  F.appFlavor = Flavor.admin;
  
  // Initialize Admin app flavor config
  config.FlavorConfig(
    flavor: config.Flavor.admin,
    name: F.title,
    primaryColor: Colors.purple,
    secondaryColor: Colors.deepPurple,
    theme: AppThemes.getAdminTheme(),
    baseUrl: "https://api.astro.com/admin",
  );
  
  // Initialize Firebase for this flavor
  await FirebaseConfig.initializeFirebase();
  
  runApp(const App());
} 