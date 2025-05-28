import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

enum UserType {
  user,
  instructor,
  admin,
  unknown,
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  UserType _userType = UserType.unknown;
  static const String _userTypeKey = 'user_type';
  
  // Add a completer to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  User? get currentUser => _user;
  UserType get userType => _userType;
  bool get isAuthenticated => _user != null;
  bool get isUser => _userType == UserType.user;
  bool get isInstructor => _userType == UserType.instructor;
  bool get isAdmin => _userType == UserType.admin;
  
  // Silent sign-in method that attempts to authenticate without UI
  Future<bool> silentSignIn() async {
    try {
      // Check if user is already signed in
      if (_user != null) {
        return true;
      }
      
      // Try to get cached credentials or token
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('auth_email');
      final password = prefs.getString('auth_password');
      
      // If we have cached credentials, try to sign in
      if (email != null && password != null) {
        try {
          await signInWithEmailPassword(email, password);
          return true;
        } catch (e) {
          print('Silent sign-in failed: $e');
          // Clear invalid credentials
          await prefs.remove('auth_email');
          await prefs.remove('auth_password');
        }
      }
      
      // If email/password failed, try Google Sign-In silently
      try {
        final googleAccount = await _googleSignIn.signInSilently();
        if (googleAccount != null) {
          final googleAuth = await googleAccount.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _auth.signInWithCredential(credential);
          return true;
        }
      } catch (e) {
        print('Silent Google sign-in failed: $e');
      }
      
      return false;
    } catch (e) {
      print('Silent sign-in error: $e');
      return false;
    }
  }
  
  AuthService() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    try {
      // Get the current user first
      _user = _auth.currentUser;
      
      // Check if there's a stored user type in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedUserType = prefs.getString(_userTypeKey);
      
      // Set user type from SharedPreferences if available
      if (storedUserType != null) {
        switch (storedUserType) {
          case 'user':
            _userType = UserType.user;
            break;
          case 'instructor':
            _userType = UserType.instructor;
            break;
          case 'admin':
            _userType = UserType.admin;
            break;
          default:
            _userType = UserType.unknown;
        }
      }
      
      // If we have a user but no stored type, determine it from Firestore
      if (_user != null && storedUserType == null) {
        await _determineUserType();
      }
      
      // Mark initialization as complete
      _isInitialized = true;
      notifyListeners();
      
      // Set up listener for future auth state changes
      _auth.authStateChanges().listen((User? user) async {
        _user = user;
        if (user != null) {
          await _determineUserType();
        } else {
          _userType = UserType.unknown;
          // Clear user type from SharedPreferences when logged out
          await prefs.remove(_userTypeKey);
        }
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing auth: $e');
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
  
  // Determine if the authenticated user is a regular user, instructor, or admin
  Future<void> _determineUserType() async {
    if (_user == null) {
      _userType = UserType.unknown;
      notifyListeners();
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is an admin
      final adminDoc = await _firestore.collection('admins').doc(_user!.uid).get();
      if (adminDoc.exists) {
        _userType = UserType.admin;
        await prefs.setString(_userTypeKey, 'admin');
        notifyListeners();
        return;
      }
      
      // Check if user is an instructor
      final instructorDoc = await _firestore.collection('instructors').doc(_user!.uid).get();
      if (instructorDoc.exists) {
        _userType = UserType.instructor;
        await prefs.setString(_userTypeKey, 'instructor');
        notifyListeners();
        return;
      }
      
      // If not admin or instructor, check if user exists in users collection
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        _userType = UserType.user;
        await prefs.setString(_userTypeKey, 'user');
      } else {
        // If user authenticated but not in any collection, create a new user
        if (_user!.email != null) {
          await _firestore.collection('users').doc(_user!.uid).set({
            'email': _user!.email,
            'displayName': _user!.displayName ?? '',
            'phoneNumber': _user!.phoneNumber ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
          _userType = UserType.user;
          await prefs.setString(_userTypeKey, 'user');
        } else {
          _userType = UserType.unknown;
          await prefs.remove(_userTypeKey);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error determining user type: $e');
      _userType = UserType.unknown;
      notifyListeners();
    }
  }
  
  // User sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password, String name) async {
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
      
      _userType = UserType.user;
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing up with email and password: $e');
      rethrow;
    }
  }
  
  // User sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store credentials for silent sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_email', email);
      await prefs.setString('auth_password', password);
      
      // Update last login timestamp
      if (credential.user != null) {
        // Check if user is an instructor first
        final instructorDoc = await _firestore.collection('instructors').doc(credential.user!.uid).get();
        if (instructorDoc.exists) {
          await _firestore.collection('instructors').doc(credential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          _userType = UserType.instructor;
        } else {
          // If not instructor, update user document
          await _firestore.collection('users').doc(credential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          _userType = UserType.user;
        }
      }
      
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in with email and password: $e');
      rethrow;
    }
  }
  
  // Instructor sign in (no sign up, only existing instructors can sign in)
  Future<UserCredential> instructorSignIn(String email, String password) async {
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
      
      // Update last login timestamp
      await _firestore.collection('instructors').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      _userType = UserType.instructor;
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in as instructor: $e');
      rethrow;
    }
  }
  
  // Google Sign In for users
  Future<UserCredential> signInWithGoogle() async {
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
      
      _userType = UserType.user;
      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Phone number authentication for users
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }
  
  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user already exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create new user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'phoneNumber': userCredential.user!.phoneNumber,
          'displayName': userCredential.user!.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'phone',
        });
      } else {
        // Update last login timestamp
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      _userType = UserType.user;
      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Error signing in with phone credential: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user data first
      _user = null;
      _userType = UserType.unknown;
      
      // Then sign out from providers
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      
      // Notify listeners after everything is complete
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Check if email exists (for password reset)
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking if email exists: $e');
      return false;
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
  
  // Admin sign in (no sign up, only existing admins can sign in)
  Future<UserCredential> adminSignIn(String email, String password) async {
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
      
      // Update last login timestamp
      await _firestore.collection('admins').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      _userType = UserType.admin;
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in as admin: $e');
      rethrow;
    }
  }
  
  // Admin method to create an instructor account with auto-generated password
  Future<Map<String, dynamic>> createInstructorAccount({
    required String email, 
    required String name,
    required String specialization,
  }) async {
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
  
  // Helper method to generate a random password
  String _generateRandomPassword(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final Random random = Random.secure();
    return String.fromCharCodes(
      List.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
} 