import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';

/// Firebase configuration for different flavors
class FirebaseConfig {
  // Private constructor
  FirebaseConfig._();

  /// Initializes Firebase for the current flavor
  static Future<void> initializeFirebase() async {
    FirebaseOptions options;

    if (F.isAdminApp) {
      options = const FirebaseOptions(
        apiKey: "AIzaSyBj3GzZS3aEUhv4wzXuv6u6knRariQIzO4",
        appId: "1:1072924359809:android:020850bdbfd3d9f9a6a180",
        messagingSenderId: "1072924359809",
        projectId: "astroapp-87ecd",
        storageBucket: "astroapp-87ecd.firebasestorage.app",
      );
    } else {
      options = const FirebaseOptions(
        apiKey: "AIzaSyBj3GzZS3aEUhv4wzXuv6u6knRariQIzO4",
        appId: "1:1072924359809:android:868b2405fe0f4b93a6a180",
        messagingSenderId: "1072924359809",
        projectId: "astroapp-87ecd",
        storageBucket: "astroapp-87ecd.firebasestorage.app",
      );
    }

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        // Initialize Firebase with the appropriate options for the current flavor
        await Firebase.initializeApp(options: options);
        debugPrint('Firebase initialized for ${F.title}');
      } else {
        // Firebase is already initialized
        debugPrint('Firebase was already initialized');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }
} 