import 'package:flutter/material.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final isAstroAppEmail = email.toLowerCase().endsWith('@astroapp.com');

    try {
      // First authenticate with Firebase to get access to Firestore
      final authService = Provider.of<AuthService>(context, listen: false);
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );
      
      // Check if this is an instructor email (domain-based check)
      if (isAstroAppEmail) {
        debugPrint('Astroapp.com domain detected, treating as instructor');
        
        // Ensure this user exists in the instructors collection
        await _ensureInstructorAccount(userCredential.user!);
        
        if (mounted) {
          debugPrint('Logged in as instructor (domain-based), navigating to instructor home');
          Navigator.of(context).pushReplacementNamed('/instructor_home');
          return;
        }
      } else {
        // For non-astroapp emails, check if this user is an instructor or a regular user
        final isInstructor = await _checkIfInstructor(email);
        
        // Try to get user by UID first (more reliable)
        bool isUser = await _checkIfUserByUid(userCredential.user!.uid);
        
        // If not found by UID, try by email as fallback
        if (!isUser) {
          isUser = await _checkIfUser(email);
        }
        
        // If still not found, create a new user entry
        if (!isUser && !isInstructor) {
          debugPrint('User not found in any collection, creating new user entry');
          await _createUserEntry(userCredential.user!);
          isUser = true;
        }
        
        debugPrint('Login check - Email: $email, isInstructor: $isInstructor, isUser: $isUser');
        
        if (isInstructor && !isUser) {
          // This is an instructor account - navigate to instructor home
          debugPrint('Detected instructor account, redirecting to instructor home');
          
          // Make sure Firebase knows this is an instructor
          try {
            await FirebaseFirestore.instance.collection('instructors').doc(userCredential.user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('Error updating instructor lastLogin: $e');
            // Continue with navigation even if update fails
          }
          
          if (mounted) {
            debugPrint('Logged in as instructor, navigating to instructor home');
            Navigator.of(context).pushReplacementNamed('/instructor_home');
            return;
          }
        } else if (isUser) {
          // This is a user account - navigate to user home
          debugPrint('Detected user account, redirecting to user home');
          
          // Make sure Firebase knows this is a user
          try {
            await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('Error updating user lastLogin: $e');
            // Continue with navigation even if update fails
          }
          
          if (mounted) {
            debugPrint('Logged in as user, navigating to user home');
            Navigator.of(context).pushReplacementNamed('/home');
            return;
          }
        } else {
          // Neither instructor nor user - something is wrong
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = "Account not found. Please register first.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      // Start Google sign-in flow
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() {
          _isGoogleLoading = false;
        });
        return; // User cancelled the sign-in flow
      }
      
      final email = googleUser.email;
      final isAstroAppEmail = email.toLowerCase().endsWith('@astroapp.com');
      
      // Get authentication credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Check if this is an instructor email (domain-based check)
      if (isAstroAppEmail) {
        debugPrint('Astroapp.com domain detected via Google, treating as instructor');
        
        // Ensure this user exists in the instructors collection
        await _ensureInstructorAccount(userCredential.user!);
        
        if (mounted) {
          debugPrint('Logged in as instructor via Google (domain-based), navigating to instructor home');
          Navigator.of(context).pushReplacementNamed('/instructor_home');
          return;
        }
      } else {
        // Check account type
        final isInstructor = await _checkIfInstructor(email);
        final isUser = await _checkIfUser(email);
        
        debugPrint('Google login check - Email: $email, isInstructor: $isInstructor, isUser: $isUser');
        
        if (isInstructor && !isUser) {
          // This is an instructor account - navigate to instructor home
          debugPrint('Detected instructor account via Google, redirecting to instructor home');
          
          // Make sure Firebase knows this is an instructor
          try {
            await FirebaseFirestore.instance.collection('instructors').doc(userCredential.user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('Error updating instructor lastLogin: $e');
            // Continue with navigation even if update fails
          }
          
          if (mounted) {
            debugPrint('Logged in as instructor via Google, navigating to instructor home');
            Navigator.of(context).pushReplacementNamed('/instructor_home');
            return;
          }
        } else if (isUser) {
          // This is a user account - navigate to user home
          debugPrint('Detected user account via Google, redirecting to user home');
          
          // Make sure Firebase knows this is a user
          try {
            await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('Error updating user lastLogin: $e');
            // Continue with navigation even if update fails
          }
          
          if (mounted) {
            debugPrint('Logged in as user via Google, navigating to user home');
            Navigator.of(context).pushReplacementNamed('/home');
            return;
          }
        } else {
          // Neither instructor nor user - something is wrong
          await FirebaseAuth.instance.signOut();
          await _googleSignIn.signOut();
          setState(() {
            _errorMessage = "Account not found. Please register first.";
            _isGoogleLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }
  
  // Helper method to ensure user exists in the instructors collection
  Future<void> _ensureInstructorAccount(User user) async {
    try {
      // Check if user already exists in instructors collection
      final docSnapshot = await FirebaseFirestore.instance
          .collection('instructors')
          .doc(user.uid)
          .get();
      
      if (!docSnapshot.exists) {
        // Create new instructor document
        await FirebaseFirestore.instance.collection('instructors').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Instructor',
          'photoURL': user.photoURL,
          'isActive': true,
          'role': 'instructor',
          'isInstructor': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        debugPrint('Created new instructor account for ${user.email}');
      } else {
        // Update existing instructor document
        await FirebaseFirestore.instance.collection('instructors').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'role': 'instructor',
          'isInstructor': true,
        });
        debugPrint('Updated existing instructor account for ${user.email}');
      }
      
      // Check if user exists in users collection and remove if found
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
                                                                                                    
      if (userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        debugPrint('Removed user entry for instructor ${user.email}');
      }
    } catch (e) {
      debugPrint('Error ensuring instructor account: $e');
      // Continue with login even if this fails
    }
  }
  
  // Helper method to check if an email belongs to a user
  Future<bool> _checkIfUser(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking user by email: $e');
      return false;
    }
  }
  
  // Helper method to check if a user exists by UID
  Future<bool> _checkIfUserByUid(String uid) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      return docSnapshot.exists;
    } catch (e) {
      debugPrint('Error checking user by UID: $e');
      return false;
    }
  }
  
  // Helper method to create a new user entry
  Future<void> _createUserEntry(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'role': 'user',
        'isActive': true,
        'isUser': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      debugPrint('Created new user entry for ${user.email}');
    } catch (e) {
      debugPrint('Error creating user entry: $e');
      // Continue with login even if this fails
    }
  }
  
  // Helper method to check if an email belongs to an instructor
  Future<bool> _checkIfInstructor(String email) async {
    // If it's an astroapp.com email, automatically consider it an instructor
    if (email.toLowerCase().endsWith('@astroapp.com')) {
      return true;
    }
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('instructors')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking instructor: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Login',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Student Access',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: theme.colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : const Text('Login', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            icon: _isGoogleLoading 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/icons/google_logo.svg',
                                    height: 24,
                                    width: 24,
                                  ),
                            label: const Text('Sign in with Google', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/register');
                            },
                            child: const Text("Don't have an account? Register"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/user/user_app.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Astro Learning',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 