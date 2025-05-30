import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Get the initial verification status
    _isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    
    if (!_isEmailVerified) {
      // Start periodic timer to check verification status
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    // Reload the user to get the latest emailVerified status
    await FirebaseAuth.instance.currentUser?.reload();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      setState(() {
        _isEmailVerified = true;
      });
      _timer?.cancel();
      
      // Navigate to home after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  Future<void> _sendVerificationEmail() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      await authService.sendEmailVerification();
      
      setState(() {
        _canResendEmail = false;
        _cooldownSeconds = 60; // 1 minute cooldown
      });
      
      _cooldownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            if (_cooldownSeconds > 0) {
              _cooldownSeconds--;
            } else {
              _canResendEmail = true;
              timer.cancel();
            }
          });
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmailVerified) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Verified!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Redirecting to home...'),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'We\'ve sent a verification email to ${FirebaseAuth.instance.currentUser?.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your inbox and click the verification link to activate your account.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _canResendEmail ? _sendVerificationEmail : null,
              child: _canResendEmail
                  ? const Text('Resend Verification Email')
                  : Text('Resend in $_cooldownSeconds seconds'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _checkEmailVerified();
              },
              child: const Text('I\'ve verified my email'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                await Provider.of<AuthService>(context, listen: false).signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('Cancel and Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
} 