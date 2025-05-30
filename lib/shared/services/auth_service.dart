import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:astro/shared/services/user_service.dart';
import 'package:astro/shared/widgets/role_selection_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
        // Fetch and store user role using Cloud Function
        await _fetchUserRole();
        
        // Store user ID securely
        await _storage.write(key: 'user_id', value: user.uid);
        
        // Store user role securely
        if (_userRole != null) {
          await _storage.write(key: 'user_role', value: _userRole);
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
      final result = await _functions.httpsCallable('verifyUserRole').call();
      final data = result.data;
      _userRole = data['role'];
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      // Fallback to Firestore if Cloud Function fails
      _userRole = await _userService.getUserRole(_user!.uid);
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
      
      // Call the Cloud Function to create the instructor account
      final result = await _functions.httpsCallable('createInstructorAccount').call({
        'email': email,
        'password': password,
        'displayName': name,
      });
      
      if (!result.data['success']) {
        throw Exception('Failed to create instructor account');
      }
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

  // Verify that the user's role matches the app flavor
  Future<void> _verifyUserRole(User? user) async {
    if (user == null) return;
    
    try {
      // Fetch user role using Cloud Function
      await _fetchUserRole();
      
      // Check if the user has the correct role for this app flavor
      switch (F.appFlavor) {
        case Flavor.user:
          // Both user and instructor roles are valid for the user app
          if (_userRole != 'user' && _userRole != 'instructor') {
            await signOut();
            throw Exception('You do not have permission to access this app.');
          }
          break;
        case Flavor.admin:
          if (_userRole != 'admin') {
            await signOut();
            throw Exception('You do not have permission to access the Admin app.');
          }
          break;
      }
    } catch (e) {
      debugPrint('Error verifying user role: $e');
      rethrow;
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
      await _functions.httpsCallable('setUserRole').call({
        'uid': uid,
        'role': role,
      });
    } catch (e) {
      debugPrint('Error setting user role with function: $e');
      // Fallback to Firestore if Cloud Function fails
      await _userService.setUserRole(await _auth.currentUser!, role);
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