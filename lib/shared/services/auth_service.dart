import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:astro/shared/services/user_service.dart';
import 'package:astro/shared/widgets/role_selection_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;
  String? _userRole;

  // Get current user
  User? get currentUser => _user;
  
  // Get user role
  String? get userRole => _userRole;
  
  // Is user signed in
  bool get isSignedIn => _user != null;
  
  // Check if user is admin
  bool get isAdmin => _userRole == 'admin';
  
  // Check if user is instructor
  bool get isInstructor => _userRole == 'instructor';
  
  // Check if user is regular user
  bool get isRegularUser => _userRole == 'user';
  
  // Constructor
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        try {
          // Fetch and store user role using Firestore
          await _fetchUserRole();
          
          // Store user ID securely
          await _storage.write(key: 'user_id', value: user.uid);
          
          // Store user role securely
          if (_userRole != null) {
            await _storage.write(key: 'user_role', value: _userRole);
          }
        } catch (e) {
          debugPrint('Error during auth state change: $e');
          // Set default role to prevent crashes
          _userRole = F.appFlavor == Flavor.admin ? 'admin' : 'user';
        }
      } else {
        _userRole = null;
        // Clear stored values on sign out
        await _storage.delete(key: 'user_id');
        await _storage.delete(key: 'user_role');
      }
      notifyListeners();
    });
    
    // Try to restore role from secure storage on app start
    _restoreUserRole();
  }
  
  // Restore user role from secure storage
  Future<void> _restoreUserRole() async {
    if (_user != null && _userRole == null) {
      _userRole = await _storage.read(key: 'user_role');
      notifyListeners();
    }
  }

  // Fetch user role using Cloud Function
  Future<void> _fetchUserRole() async {
    try {
      // For admin app, always set admin role
      if (F.appFlavor == Flavor.admin) {
        _userRole = 'admin';
        // Ensure admin record exists in Firestore
        await _userService.setUserRole(_user!, 'admin');
        return;
      }

      // For user app, get role from Firestore
      _userRole = await _userService.getUserRole(_user!.uid);
      debugPrint('Fetched user role: $_userRole for ${_user!.email}');
      
      // If role is not set, set default based on app flavor and email
      if (_userRole == null) {
        // For user app, default to 'user' role
        _userRole = 'user';
        // Save role to Firestore
        await _userService.setUserRole(_user!, _userRole!);
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      await signOut();
      rethrow;
    }
    notifyListeners();
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

  // Sign in with Google
  Future<UserCredential> signInWithGoogle({BuildContext? context}) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser && context != null) {
        // Show role selection dialog for new users
        final selectedRole = await RoleSelectionDialog.show(context);
        
        if (selectedRole != null) {
          String role;
          switch (selectedRole) {
            case UserRole.user:
              role = 'user';
              break;
            case UserRole.instructor:
              role = 'instructor';
              break;
          }
          
          // Set user role using Cloud Function
          await _setUserRoleWithFunction(userCredential.user!.uid, role);
          
          // For the user app flavor, we don't need to verify role since both user and instructor roles are valid
          if (F.appFlavor == Flavor.admin) {
            await _verifyUserRole(userCredential.user);
          }
        } else {
          // User cancelled role selection, sign out
          await signOut();
          throw Exception('Role selection cancelled');
        }
      } else {
        // Verify user role matches the app flavor (only for admin)
        if (F.appFlavor == Flavor.admin) {
          await _verifyUserRole(userCredential.user);
        }
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Validate password strength
      if (!_isStrongPassword(password)) {
        throw Exception(
          'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character'
        );
      }
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      // Set user role based on app flavor
      await _setUserRole(userCredential.user);
      
      return userCredential;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }
  
  // Create instructor account (admin only)
  Future<void> createInstructorAccount(String email, String password, String name) async {
    if (_userRole != 'admin') {
      throw Exception('Only administrators can create instructor accounts');
    }
    
    try {
      // Validate password strength
      if (!_isStrongPassword(password)) {
        throw Exception(
          'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character'
        );
      }
      
      // Create the user account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create instructor document in Firestore
      await _userService.setUserRole(
        userCredential.user!,
        'instructor',
        displayName: name,
      );
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      debugPrint('Instructor account created successfully for $email');
    } catch (e) {
      debugPrint('Create instructor error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _userRole = null;
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_role');
  }

  // Verify user role matches the app flavor
  Future<void> _verifyUserRole(User? user) async {
    if (user == null) return;
    
    try {
      // For admin app, only allow admin role
      if (F.appFlavor == Flavor.admin) {
        final role = await _userService.getUserRole(user.uid);
        debugPrint('Admin app - User role: $role for ${user.email}');
        
        if (role != 'admin') {
          await signOut();
          throw Exception('Please use the user app to sign in. This app is for administrators only.');
        }
        
        _userRole = 'admin';
        // Ensure admin record exists in Firestore
        await _userService.setUserRole(user, 'admin');
        notifyListeners();
        return;
      }
      
      // For user app, check role
      final role = await _userService.getUserRole(user.uid);
      debugPrint('User app - User role: $role for ${user.email}');
      
      // For user app, allow both user and instructor roles
      if (role == 'admin') {
        await signOut();
        throw Exception('Please use the admin app to sign in as an administrator.');
      }
      
      if (role == 'instructor') {
        _userRole = 'instructor';
        // Ensure instructor record exists in Firestore
        await _userService.setUserRole(user, 'instructor');
        notifyListeners();
        return;
      }
      
      if (role == 'user' || role == null) {
        _userRole = 'user';
        // If role is null, set it to user
        if (role == null) {
          await _userService.setUserRole(user, 'user');
        }
        notifyListeners();
        return;
      }
      
      // If we get here, the role is invalid
      await signOut();
      throw Exception('Invalid user role. Please contact support.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Please use')) {
        // Rethrow our custom exceptions
        rethrow;
      }
      debugPrint('Error verifying user role: $e');
      await signOut();
      throw Exception('Error verifying user role: $e');
    }
  }

  // Set user role based on app flavor
  Future<void> _setUserRole(User? user) async {
    if (user == null) return;
    
    String role;
    switch (F.appFlavor) {
      case Flavor.user:
        // Default to 'user' role for email/password registration
        role = 'user';
        break;
      case Flavor.admin:
        role = 'admin';
        break;
      case Flavor.instructor:
        role = 'instructor';
        break;
    }
    
    // Set user role using Cloud Function
    await _setUserRoleWithFunction(user.uid, role);
    _userRole = role;
    
    // Store role in secure storage
    await _storage.write(key: 'user_role', value: role);
    
    notifyListeners();
  }
  
  // Set user role using Cloud Function
  Future<void> _setUserRoleWithFunction(String uid, String role) async {
    try {
      // Skip the Cloud Function call and use Firestore directly
      User? currentUser = await _auth.currentUser;
      if (currentUser != null) {
        // Check if this user already exists in another collection
        if (role == 'user') {
          // Check if user exists in instructors collection
          final instructorDoc = await FirebaseFirestore.instance
              .collection('instructors')
              .doc(uid)
              .get();
          
          if (instructorDoc.exists) {
            debugPrint('User exists in instructors collection, not saving to users collection');
            return;
          }
        } else if (role == 'instructor') {
          // Check if user exists in users collection
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          
          if (userDoc.exists) {
            debugPrint('User exists in users collection, removing from users collection');
            // Remove from users collection if they are now an instructor
            await FirebaseFirestore.instance.collection('users').doc(uid).delete();
          }
        }
        
        // Save user data in the appropriate collection
        await _userService.setUserRole(currentUser, role);
      } else {
        debugPrint('Error: No current user found when setting role');
      }
    } catch (e) {
      debugPrint('Error setting user role: $e');
      // No fallback needed since we're already using Firestore directly
    }
  }
  
  // Send email verification
  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await _user!.sendEmailVerification();
    }
  }
  
  // Check if password is strong enough
  bool _isStrongPassword(String password) {
    // Password must be at least 8 characters long
    if (password.length < 8) {
      return false;
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }
} 