import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // Get current user
  User? get currentUser => _user;
  
  // Is user signed in
  bool get isSignedIn => _user != null;
  
  // Constructor
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify user role matches the app flavor
      await _verifyUserRole(userCredential.user);
      
      return userCredential;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Set user role based on app flavor
      await _setUserRole(userCredential.user);
      
      return userCredential;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verify that the user's role matches the app flavor
  Future<void> _verifyUserRole(User? user) async {
    if (user == null) return;
    
    // Get the user's claims from Firebase Auth
    final idTokenResult = await user.getIdTokenResult();
    final claims = idTokenResult.claims;
    
    // Check if the user has the correct role for this app flavor
    switch (F.appFlavor) {
      case Flavor.user:
        if (claims?['role'] != 'user') {
          await signOut();
          throw Exception('You do not have permission to access the User app.');
        }
        break;
      case Flavor.admin:
        if (claims?['role'] != 'admin') {
          await signOut();
          throw Exception('You do not have permission to access the Admin app.');
        }
        break;
    }
  }

  // Set user role based on app flavor
  Future<void> _setUserRole(User? user) async {
    if (user == null) return;
    
    // This would typically be handled by a Cloud Function in Firebase
    // that sets custom claims on user creation. This is a simplified example.
    // In a real app, you would have a backend endpoint to set roles.
    
    String role;
    switch (F.appFlavor) {
      case Flavor.user:
        role = 'user';
        break;
      case Flavor.admin:
        role = 'admin';
        break;
    }
    
    // In a real app, call a backend endpoint to set custom claims
    debugPrint('Setting user role to $role for ${user.uid}');
    
    // For demonstration purposes - normally this would be done in a Cloud Function
    // await FirebaseFunctions.instance.httpsCallable('setUserRole').call({
    //   'uid': user.uid,
    //   'role': role,
    // });
  }
} 