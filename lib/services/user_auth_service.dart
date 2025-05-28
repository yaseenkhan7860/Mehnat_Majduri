import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isInitialized = false;
  
  User? get currentUser => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  
  UserAuthService() {
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
      print('Error initializing user auth: $e');
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
  Future<bool> userSilentSignIn() async {
    try {
      // Check if user is already signed in with Firebase
      if (_user != null) {
        try {
          // Try to get a fresh ID token to verify the session is still valid
          await _user!.getIdToken(true);
          
          // Verify that the user is actually a regular user
          final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
          if (userDoc.exists) {
            print('User already signed in and validated: ${_user!.email}');
            
            // Update last login timestamp
            await _firestore.collection('users').doc(_user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
            
            return true;
          } else {
            // If not a user, sign out
            print('User document not found, signing out');
            await _auth.signOut();
            _user = null;
            notifyListeners();
            return false;
          }
        } catch (e) {
          // Token refresh failed, user session might be expired
          print('Token refresh failed: $e');
          // Don't sign out immediately, try other auth methods first
        }
      }
      
      // Try to get cached credentials or token
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_auth_email');
      final password = prefs.getString('user_auth_password');
      
      // Try email/password auth if we have credentials
      if (email != null && password != null) {
        try {
          print('Attempting silent sign-in for user: $email');
          await userSignInWithEmailPassword(email, password);
          
          // Force remember login to be true to maintain persistence
          await prefs.setBool('user_remember_login', true);
          
          return true;
        } catch (e) {
          print('Silent user sign-in failed: $e');
          // Don't clear credentials on failure - they might be valid but network is down
        }
      }
      
      // If email/password failed, try Google Sign-In silently
      final isGoogleAuth = prefs.getBool('user_google_auth') ?? false;
      if (isGoogleAuth) {
        try {
          print('Attempting silent Google sign-in');
          final googleAccount = await _googleSignIn.signInSilently();
          if (googleAccount != null) {
            print('Silent Google sign-in successful for: ${googleAccount.email}');
            final googleAuth = await googleAccount.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            
            // Sign in with Firebase
            final userCredential = await _auth.signInWithCredential(credential);
            
            // Verify that the user document exists
            final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
            if (userDoc.exists) {
              // Update last login timestamp
              await _firestore.collection('users').doc(userCredential.user!.uid).update({
                'lastLogin': FieldValue.serverTimestamp(),
              });
            }
            
            // Ensure remember login is true
            await prefs.setBool('user_remember_login', true);
            
            return true;
          }
        } catch (e) {
          print('Silent Google sign-in failed: $e');
        }
      }
      
      // Try to restore from persistent storage as last resort
      try {
        // Firebase has its own persistence mechanism that might work
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          _user = currentUser;
          
          // Verify user document exists
          final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
          if (userDoc.exists) {
            print('Restored user session from Firebase persistence: ${currentUser.email}');
            
            // Update last login timestamp
            await _firestore.collection('users').doc(currentUser.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
            
            notifyListeners();
            return true;
          }
        }
      } catch (e) {
        print('Error restoring from persistent storage: $e');
      }
      
      return false;
    } catch (e) {
      print('Silent sign-in error: $e');
      return false;
    }
  }
  
  // User sign up with email and password
  Future<UserCredential> userSignUpWithEmailPassword(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing up with email and password: $e');
      rethrow;
    }
  }
  
  // User sign in with email and password
  Future<UserCredential> userSignInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify that the user is not an instructor or admin
      final adminDoc = await _firestore.collection('admins').doc(credential.user!.uid).get();
      final instructorDoc = await _firestore.collection('instructors').doc(credential.user!.uid).get();
      
      if (adminDoc.exists || instructorDoc.exists) {
        // If admin or instructor, sign out and throw an error
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'wrong-account-type',
          message: 'This account is not a regular user account.',
        );
      }
      
      // Store credentials for silent sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_auth_email', email);
      await prefs.setString('user_auth_password', password);
      await prefs.setBool('user_remember_login', true);
      
      // Update last login timestamp
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in with email and password: $e');
      rethrow;
    }
  }
  
  // Google Sign In for users
  Future<UserCredential> userSignInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign in was cancelled',
        );
      }
      
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Verify that the user is not an instructor or admin
      final adminDoc = await _firestore.collection('admins').doc(userCredential.user!.uid).get();
      final instructorDoc = await _firestore.collection('instructors').doc(userCredential.user!.uid).get();
      
      if (adminDoc.exists || instructorDoc.exists) {
        // If admin or instructor, sign out and throw an error
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'wrong-account-type',
          message: 'This Google account is associated with an admin or instructor account.',
        );
      }
      
      // Check if user already exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create new user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName ?? '',
          'photoURL': userCredential.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'google',
        });
      } else {
        // Update last login timestamp
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> userSignOut() async {
    try {
      // Save the email before signing out
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_auth_email');
      
      // Clear user data first
      _user = null;
      
      // Then sign out from providers
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      
      // Clear stored password but keep the email for future logins
      await prefs.remove('user_auth_password');
      if (email != null) {
        await prefs.setString('user_auth_email', email);
      }
      
      // Notify listeners after everything is complete
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Check if email exists (for password reset)
  Future<bool> userCheckEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking if email exists: $e');
      return false;
    }
  }
  
  // Send password reset email
  Future<void> userSendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
  
  // Get the last used email address for login
  Future<String?> getLastUsedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_auth_email');
    } catch (e) {
      print('Error getting last used email: $e');
      return null;
    }
  }
  
  // Update user interests
  Future<void> updateUserInterests(List<String> interests) async {
    try {
      if (_user == null) {
        throw Exception('User not authenticated');
      }
      
      // Update user interests in Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        'interests': interests,
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      print('Error updating user interests: $e');
      rethrow;
    }
  }
  
  // Get user profile data
  Future<Map<String, dynamic>> getUserProfileData() async {
    try {
      if (_user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }
      
      // Return user data as a Map
      return userDoc.data() as Map<String, dynamic>;
      
    } catch (e) {
      print('Error getting user profile data: $e');
      rethrow;
    }
  }
  
  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      if (_user == null) {
        throw Exception('User not authenticated');
      }
      
      // Add a timestamp to the update
      profileData['updatedAt'] = FieldValue.serverTimestamp();
      
      // Update user data in Firestore
      await _firestore.collection('users').doc(_user!.uid).update(profileData);
      
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
} 