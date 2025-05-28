import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'create_instructor_screen.dart';

class ManageInstructorsScreen extends StatefulWidget {
  const ManageInstructorsScreen({super.key});

  @override
  State<ManageInstructorsScreen> createState() => _ManageInstructorsScreenState();
}

class _ManageInstructorsScreenState extends State<ManageInstructorsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _instructors = [];
  
  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }
  
  Future<void> _loadInstructors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('instructors').get();
      
      final instructors = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? '',
          'specialization': data['specialization'] ?? '',
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
          'lastLogin': data['lastLogin'],
        };
      }).toList();
      
      setState(() {
        _instructors = instructors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading instructors: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _toggleInstructorStatus(String uid, bool currentStatus) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('instructors').doc(uid).update({
        'isActive': !currentStatus,
      });
      
      // Refresh the list
      await _loadInstructors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating instructor status: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _viewInstructorCredentials(String uid) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserUid = authService.currentUser?.uid;
      
      if (currentUserUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to view credentials')),
        );
        return;
      }
      
      final firestore = FirebaseFirestore.instance;
      final credentialDoc = await firestore
          .collection('admins')
          .doc(currentUserUid)
          .collection('instructor_accounts')
          .doc(uid)
          .get();
      
      if (!credentialDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credentials not found for this instructor')),
        );
        return;
      }
      
      final data = credentialDoc.data()!;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Instructor Credentials'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${data['displayName'] ?? 'N/A'}'),
              Text('Email: ${data['email'] ?? 'N/A'}'),
              Text('Password: ${data['password'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text(
                'Note: Please keep this information secure and share it only with the instructor.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving credentials: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Instructors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstructors,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInstructorScreen()),
          ).then((_) => _loadInstructors()); // Refresh after returning
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInstructors,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _instructors.isEmpty
                  ? const Center(
                      child: Text('No instructors found. Add your first instructor!'),
                    )
                  : ListView.builder(
                      itemCount: _instructors.length,
                      itemBuilder: (context, index) {
                        final instructor = _instructors[index];
                        final isActive = instructor['isActive'] ?? true;
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive ? Colors.green : Colors.grey,
                              child: Text(
                                instructor['displayName'].toString().isNotEmpty
                                    ? instructor['displayName'][0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(instructor['displayName'] ?? 'No Name'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(instructor['email'] ?? 'No Email'),
                                Text('Specialization: ${instructor['specialization'] ?? 'N/A'}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.password),
                                  tooltip: 'View Credentials',
                                  onPressed: () => _viewInstructorCredentials(instructor['uid']),
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (value) => _toggleInstructorStatus(instructor['uid'], isActive),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
} 