import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isAuthenticating = false;
  bool _isSetupMode = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _checkIfSetupNeeded();
  }
  
  Future<void> _checkIfSetupNeeded() async {
    // Check if 2FA has been set up before
    final hasSetup2FA = await _storage.read(key: 'admin_2fa_setup');
    setState(() {
      _isSetupMode = hasSetup2FA != 'true';
    });
    
    if (!_isSetupMode) {
      // If already set up, start authentication immediately
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        setState(() {
          _errorMessage = 'Biometric authentication is not available on this device';
          _isAuthenticating = false;
        });
        return;
      }
      
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      String authMessage = 'Authenticate to access admin features';
      
      if (_isSetupMode) {
        authMessage = 'Set up biometric authentication for admin access';
      }
      
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: authMessage,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (didAuthenticate) {
        if (_isSetupMode) {
          // Mark 2FA as set up
          await _storage.write(key: 'admin_2fa_setup', value: 'true');
          setState(() {
            _isSetupMode = false;
          });
        }
        
        // Authentication successful, navigate to admin home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/admin_home');
        }
      } else {
        setState(() {
          _errorMessage = 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains(auth_error.notAvailable)) {
          _errorMessage = 'Biometric authentication is not available on this device';
        } else if (e.toString().contains(auth_error.notEnrolled)) {
          _errorMessage = 'No biometrics enrolled on this device';
        } else {
          _errorMessage = 'Authentication error: $e';
        }
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSetupMode ? 'Set Up Two-Factor Authentication' : 'Two-Factor Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              _isSetupMode ? Icons.security : Icons.fingerprint,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              _isSetupMode
                  ? 'Set Up Two-Factor Authentication'
                  : 'Authentication Required',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _isSetupMode
                  ? 'For enhanced security, admin accounts require biometric authentication. Please set up fingerprint or face recognition to continue.'
                  : 'Please authenticate using your fingerprint or face recognition to access admin features.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isAuthenticating ? null : _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: Text(_isSetupMode ? 'Set Up Now' : 'Authenticate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
} 