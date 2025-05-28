import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructorAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isInitialized = false;
  
  User? get currentUser => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  
  InstructorAuthService() {
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
      print('Error initializing instructor auth: $e');
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
  Future<bool> instructorSilentSignIn() async {
    try {
      // Check if user is already signed in
      if (_user != null) {
        // Verify that the user is an instructor
        final instructorDoc = await _firestore.collection('instructors').doc(_user!.uid).get();
        if (instructorDoc.exists) {
          print('Instructor already signed in: ${_user!.email}');
          
          // Update last login timestamp
          await _firestore.collection('instructors').doc(_user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          
          return true;
        } else {
          // If not an instructor, sign out
          await _auth.signOut();
          _user = null;
          notifyListeners();
          return false;
        }
      }
      
      // Try to get cached credentials or token
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('instructor_auth_email');
      final password = prefs.getString('instructor_auth_password');
      
      // If we have cached credentials, try to sign in
      if (email != null && password != null) {
        try {
          print('Attempting silent sign-in for instructor: $email');
          await instructorSignInWithEmailPassword(email, password);
          return true;
        } catch (e) {
          print('Silent instructor sign-in failed: $e');
          // Clear invalid credentials
          await prefs.remove('instructor_auth_email');
          await prefs.remove('instructor_auth_password');
        }
      }
      
      return false;
    } catch (e) {
      print('Silent instructor sign-in error: $e');
      return false;
    }
  }
  
  // Instructor sign in with email and password
  Future<UserCredential> instructorSignInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify that the user is actually an instructor
      final instructorDoc = await _firestore.collection('instructors').doc(credential.user!.uid).get();
      if (!instructorDoc.exists) {
        // If not an instructor, sign out and throw an error
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-instructor',
          message: 'This account does not have instructor privileges.',
        );
      }
      
      // Store credentials for silent sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('instructor_auth_email', email);
      await prefs.setString('instructor_auth_password', password);
      await prefs.setBool('instructor_remember_login', true);
      
      // Update last login timestamp
      await _firestore.collection('instructors').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in as instructor: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> instructorSignOut() async {
    try {
      // Clear user data first
      _user = null;
      
      // Then sign out
      await _auth.signOut();
      
      // Clear stored credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('instructor_auth_email');
      await prefs.remove('instructor_auth_password');
      
      // Notify listeners after everything is complete
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Get instructor profile data
  Future<Map<String, dynamic>?> getInstructorProfileData() async {
    if (_user == null) return null;
    
    try {
      final instructorDoc = await _firestore.collection('instructors').doc(_user!.uid).get();
      if (instructorDoc.exists) {
        return instructorDoc.data();
      }
      return null;
    } catch (e) {
      print('Error getting instructor profile data: $e');
      return null;
    }
  }
  
  // Update instructor profile data
  Future<void> instructorUpdateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('instructors').doc(_user!.uid).update(data);
      notifyListeners();
    } catch (e) {
      print('Error updating instructor profile: $e');
      rethrow;
    }
  }
  
  // Check if email exists (for password reset)
  Future<bool> instructorCheckEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking if email exists: $e');
      return false;
    }
  }
  
  // Send password reset email
  Future<void> instructorSendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
} 