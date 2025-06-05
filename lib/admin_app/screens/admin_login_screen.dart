import 'package:flutter/material.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:astro/flavors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockUntil;

  // Predefined admin email
  static const String adminEmail = "astroapp.admin@astroapp.com";

  @override
  void initState() {
    super.initState();
    // Ensure we're in admin flavor
    if (!F.isAdminApp) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This app is for administrators only.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
    // Pre-fill admin email
    _emailController.text = adminEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLocked) {
      final now = DateTime.now();
      if (_lockUntil != null && now.isBefore(_lockUntil!)) {
        final remaining = _lockUntil!.difference(now).inSeconds;
        setState(() {
          _errorMessage = 'Too many failed attempts. Try again in $remaining seconds.';
        });
        return;
      } else {
        // Reset lock if time has passed
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First authenticate with Firebase
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if the user exists in admins collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user?.uid)
          .get();

      if (!adminDoc.exists) {
        // Create admin document if it doesn't exist
        await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).set({
          'displayName': 'Admin User',
          'email': userCredential.user!.email,
          'role': 'admin',
          'isAdmin': true,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        debugPrint('Created admin document for ${userCredential.user!.email}');
      } else {
        // Update last login time
        await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'role': 'admin',
          'isAdmin': true,
        });
        
        debugPrint('Updated admin document for ${userCredential.user!.email}');
      }

      // Force token refresh to ensure updated permissions
      await userCredential.user!.getIdToken(true);
      
      if (mounted) {
        _failedAttempts = 0;
        Navigator.of(context).pushReplacementNamed('/admin_home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No admin account found with this email';
            break;
          case 'wrong-password':
            _errorMessage = 'Invalid password';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many attempts. Please try again later';
            break;
          default:
            _errorMessage = 'Authentication failed';
        }
        _incrementFailedAttempts();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Not an admin account';
        _incrementFailedAttempts();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _incrementFailedAttempts() {
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _isLocked = true;
      // Lock for 30 seconds
      _lockUntil = DateTime.now().add(const Duration(seconds: 30));
      _errorMessage = 'Too many failed attempts. Try again in 30 seconds.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  _buildLogo(),
                  SizedBox(height: 40.h),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Secure Access for Administrators',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              prefixIcon: Icon(Icons.email, color: Colors.purple.shade800),
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
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.purple.shade800),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.purple.shade800,
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
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade800,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: const CircularProgressIndicator(color: Colors.white),
                                  )
                                : Text('Login', style: TextStyle(fontSize: 16.sp)),
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
          width: 120.w,
          height: 120.h,
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
              'assets/images/admin/admin_app.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Astro Admin Panel',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 