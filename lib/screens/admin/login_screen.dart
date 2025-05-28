import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_auth_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_input_field.dart';
import 'create_first_admin_screen.dart';

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
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  bool _noAdminExists = false;
  bool _rememberMe = true; // Default to true

  @override
  void initState() {
    super.initState();
    _checkIfAdminExists();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('admin_remember_login') ?? true;
    });
  }

  Future<void> _checkIfAdminExists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if any admin exists in Firestore
      final adminAuthService = Provider.of<AdminAuthService>(context, listen: false);
      final adminData = await adminAuthService.getAdminProfileData();
      
      setState(() {
        _noAdminExists = adminData == null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final adminAuthService = Provider.of<AdminAuthService>(context, listen: false);
      await adminAuthService.adminSignInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Save remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_remember_login', _rememberMe);
      
      if (!_rememberMe) {
        // If not remembering login, schedule credential removal for app close
        Future.delayed(const Duration(seconds: 1), () async {
          if (!_rememberMe) {
            final currentPrefs = await SharedPreferences.getInstance();
            await currentPrefs.setBool('admin_remember_login', false);
          }
        });
      }
      
      // Navigation will be handled by AdminAuthWrapper
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_noAdminExists) {
      return const CreateFirstAdminScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Admin Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to access admin dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthInputField(
                        controller: _emailController,
                        labelText: 'Admin Email',
                        hintText: 'Enter your admin email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthInputField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: !_isPasswordVisible,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signIn(),
                      ),
                      const SizedBox(height: 16),
                      // Remember Me checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? true;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      AuthButton(
                        text: 'Sign In as Admin',
                        onPressed: _signIn,
                        isLoading: _isLoading,
                        backgroundColor: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 