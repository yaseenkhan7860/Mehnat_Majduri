import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'flavors.dart';
import 'user_app.dart';
import 'instructor_app.dart';
import 'admin_app.dart';
import 'services/user_auth_service.dart';
import 'services/instructor_auth_service.dart';
import 'services/admin_auth_service.dart';

const appFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'user');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure Flutter engine to handle GPU buffer allocation errors
  // This helps with E/gralloc4 and E/GraphicBufferAllocator errors
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Precompile shaders to reduce jank
  await _preloadShaders();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      // For Android, use the Play Integrity provider
      androidProvider: AndroidProvider.playIntegrity,
      // For iOS, use the device check provider
      appleProvider: AppleProvider.deviceCheck,
      // For testing purposes only, you can use debug provider
      // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase if it fails
  }
  
  // Create auth services
  final userAuthService = UserAuthService();
  final instructorAuthService = InstructorAuthService();
  final adminAuthService = AdminAuthService();
  
  // Wait for initialization of the appropriate auth service based on flavor
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
    orElse: () => Flavor.user,
  );
  
  switch (F.appFlavor) {
    case Flavor.user:
      await userAuthService.waitForInitialization();
      break;
    case Flavor.instructor:
      await instructorAuthService.waitForInitialization();
      break;
    case Flavor.admin:
      await adminAuthService.waitForInitialization();
      break;
  }

  // Select app based on flavor
  switch (F.appFlavor) {
    case Flavor.user:
      runApp(
        ChangeNotifierProvider.value(
          value: userAuthService,
          child: const UserApp(),
        ),
      );
      break;
    case Flavor.instructor:
      runApp(
        ChangeNotifierProvider.value(
          value: instructorAuthService,
          child: const InstructorApp(),
        ),
      );
      break;
    case Flavor.admin:
      runApp(
        ChangeNotifierProvider.value(
          value: adminAuthService,
          child: const AdminApp(),
        ),
      );
      break;
  }
}

// Preload shaders to reduce jank and help with GPU compatibility
Future<void> _preloadShaders() async {
  // Create a simple picture to warm up the GPU
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final paint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
  
  canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
  final picture = recorder.endRecording();
  
  // Warm up the GPU with a simple image
  ui.Image image = await picture.toImage(100, 100);
  image.dispose();
}
