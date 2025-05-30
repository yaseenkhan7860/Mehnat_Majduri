import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'flavors.dart';
import 'package:astro/config/flavor_config.dart' as config;
import 'package:astro/core/theme/app_themes.dart';
import 'package:astro/config/firebase_config.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app flavor to user by default
  F.appFlavor = Flavor.user;
  
  // Initialize Firebase for this flavor
  await FirebaseConfig.initializeFirebase();
  
  // Initialize User app flavor config
  config.FlavorConfig(
    flavor: config.Flavor.user,
    name: F.title,
    primaryColor: Colors.blue,
    secondaryColor: Colors.lightBlue,
    theme: AppThemes.getUserTheme(),
    baseUrl: "https://api.astro.com/user",
  );
  
  runApp(const App());
}
