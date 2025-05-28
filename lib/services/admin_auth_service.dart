import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class AdminAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isInitialized = false;
  
  User? get currentUser => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  
  AdminAuthService() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    try {
      // Get the current user first
      _user = _auth.currentUser;
      
      // Mark initialization as complete
      _isInitialized = true;
      notifyListeners();
      
      // Set up listener for future auth state changes
      _auth.authStateChanges().listen((User? user) async {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing admin auth: $e');
      _isInitialized = true;  // Mark as initialized even if there's an error
      notifyListeners();
    }
  }
  
  // Wait for initialization to complete
  Future<void> waitForInitialization() async {
    if (_isInitialized) return;
    
    // Poll until initialized
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  
  // Silent sign-in method that attempts to authenticate without UI
  Future<bool> adminSilentSignIn() async {
    try {
      // Check if user is already signed in
      if (_user != null) {
        // Verify that the user is an admin
        final adminDoc = await _firestore.collection('admins').doc(_user!.uid).get();
        if (adminDoc.exists) {
          print('Admin already signed in: ${_user!.email}');
          
          // Update last login timestamp
          await _firestore.collection('admins').doc(_user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          
          return true;
        } else {
          // If not an admin, sign out
          await _auth.signOut();
          _user = null;
          notifyListeners();
          return false;
        }
      }
      
      // Try to get cached credentials or token
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('admin_auth_email');
      final password = prefs.getString('admin_auth_password');
      
      // If we have cached credentials, try to sign in
      if (email != null && password != null) {
        try {
          print('Attempting silent sign-in for admin: $email');
          await adminSignInWithEmailPassword(email, password);
          return true;
        } catch (e) {
          print('Silent admin sign-in failed: $e');
          // Clear invalid credentials
          await prefs.remove('admin_auth_email');
          await prefs.remove('admin_auth_password');
        }
      }
      
      return false;
    } catch (e) {
      print('Silent admin sign-in error: $e');
      return false;
    }
  }
  
  // Admin sign in with email and password
  Future<UserCredential> adminSignInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify that the user is actually an admin
      final adminDoc = await _firestore.collection('admins').doc(credential.user!.uid).get();
      if (!adminDoc.exists) {
        // If not an admin, sign out and throw an error
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'This account does not have admin privileges.',
        );
      }
      
      // Store credentials for silent sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_auth_email', email);
      await prefs.setString('admin_auth_password', password);
      await prefs.setBool('admin_remember_login', true);
      
      // Update last login timestamp
      await _firestore.collection('admins').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in as admin: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> adminSignOut() async {
    try {
      // Clear user data first
      _user = null;
      
      // Then sign out
      await _auth.signOut();
      
      // Clear stored credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_auth_email');
      await prefs.remove('admin_auth_password');
      
      // Notify listeners after everything is complete
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Create first admin account (only if no admins exist)
  Future<UserCredential> adminCreateFirstAdmin(String email, String password, String name) async {
    try {
      // Check if any admins already exist
      final adminsQuery = await _firestore.collection('admins').limit(1).get();
      if (adminsQuery.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'admin-exists',
          message: 'An admin account already exists.',
        );
      }
      
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      
      // Create admin document in Firestore
      await _firestore.collection('admins').doc(credential.user!.uid).set({
        'email': email,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isRootAdmin': true,
      });
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error creating first admin account: $e');
      rethrow;
    }
  }
  
  // Admin method to create an instructor account with auto-generated password
  Future<Map<String, dynamic>> adminCreateInstructorAccount({
    required String email, 
    required String name,
    required String specialization,
  }) async {
    if (_user == null) {
      throw Exception('Admin must be authenticated to create instructor accounts');
    }
    
    try {
      // Generate a random password (8 characters)
      final password = _generateRandomPassword(8);
      
      // Create user account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Create instructor document in Firestore
      await _firestore.collection('instructors').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': name,
        'specialization': specialization,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
        'isActive': true,
        'createdBy': _auth.currentUser?.uid,
      });
      
      // Store the instructor credentials in the admin's instructor_accounts subcollection
      await _firestore.collection('admins').doc(_auth.currentUser!.uid)
          .collection('instructor_accounts').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': name,
        'password': password, // Store the generated password
        'specialization': specialization,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'uid': userCredential.user!.uid,
        'email': email,
        'password': password,
        'name': name,
      };
    } catch (e) {
      print('Error creating instructor account: $e');
      rethrow;
    }
  }
  
  // Get admin profile data
  Future<Map<String, dynamic>?> getAdminProfileData() async {
    if (_user == null) return null;
    
    try {
      final adminDoc = await _firestore.collection('admins').doc(_user!.uid).get();
      if (adminDoc.exists) {
        return adminDoc.data();
      }
      return null;
    } catch (e) {
      print('Error getting admin profile data: $e');
      return null;
    }
  }
  
  // Update admin profile data
  Future<void> adminUpdateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('admins').doc(_user!.uid).update(data);
      notifyListeners();
    } catch (e) {
      print('Error updating admin profile: $e');
      rethrow;
    }
  }
  
  // Helper method to generate a random password
  String _generateRandomPassword(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final Random random = Random.secure();
    return String.fromCharCodes(
      List.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
} 