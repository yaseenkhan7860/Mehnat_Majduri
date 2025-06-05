import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';

class AdminAuthGuard extends StatelessWidget {
  final Widget child;

  const AdminAuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    
    // Check if user is signed in and is an admin
    if (!auth.isSignedIn || auth.userRole != 'admin') {
      // Redirect to login page
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/'));
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
} 