import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/auth_input_field.dart';
import '../../widgets/auth_button.dart';

class CreateInstructorScreen extends StatefulWidget {
  const CreateInstructorScreen({super.key});

  @override
  State<CreateInstructorScreen> createState() => _CreateInstructorScreenState();
}

class _CreateInstructorScreenState extends State<CreateInstructorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  Map<String, dynamic>? _createdInstructor;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
  
  Future<void> _createInstructorAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      _createdInstructor = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final instructorData = await authService.createInstructorAccount(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        specialization: _specializationController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
        _successMessage = 'Instructor account created successfully!';
        _createdInstructor = instructorData;
        
        // Clear form fields
        _nameController.clear();
        _emailController.clear();
        _specializationController.clear();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error creating instructor account: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Instructor Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create New Instructor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details to create a new instructor account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              
              // Success message
              if (_successMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _successMessage,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_createdInstructor != null) ...[
                        const SizedBox(height: 12),
                        Text('Name: ${_createdInstructor!['name']}'),
                        Text('Email: ${_createdInstructor!['email']}'),
                        Text('Password: ${_createdInstructor!['password']}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Please save this password. It will be needed for the instructor to log in.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              
              if (_errorMessage.isNotEmpty || _successMessage.isNotEmpty)
                const SizedBox(height: 24),
              
              // Name Field
              AuthInputField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter instructor\'s full name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructor\'s name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email Field
              AuthInputField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter instructor\'s email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructor\'s email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Specialization Field
              AuthInputField(
                controller: _specializationController,
                labelText: 'Specialization',
                hintText: 'Enter instructor\'s specialization',
                prefixIcon: const Icon(Icons.school_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructor\'s specialization';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Create Account Button
              AuthButton(
                text: 'Create Instructor Account',
                onPressed: _createInstructorAccount,
                isLoading: _isLoading,
                backgroundColor: Colors.orange,
              ),
              
              const SizedBox(height: 24),
              
              // Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Important Note',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A random password will be generated for the instructor. '
                      'Make sure to save it and share it securely with them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 