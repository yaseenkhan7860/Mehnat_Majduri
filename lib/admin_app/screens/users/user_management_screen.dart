import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';
import 'package:astro/admin_app/widgets/admin_base_screen.dart';
import 'package:astro/admin_app/widgets/admin_stat_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  final AdminAuditService _auditService = AdminAuditService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch users from Firestore
      final usersSnapshot = await _firestore.collection('users').get();
      
      setState(() {
        _users = usersSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['displayName'] ?? 'Unknown User',
            'email': data['email'] ?? 'No Email',
            'status': data['isActive'] == true ? 'Active' : 'Inactive',
            'joinDate': data['createdAt'] != null 
                ? DateFormat('MMM d, y').format((data['createdAt'] as Timestamp).toDate())
                : 'Unknown',
            'photoUrl': data['photoUrl'],
          };
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Students',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar at top with improved styling
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  indicator: BoxDecoration(
                    color: Colors.purple.shade800,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  splashBorderRadius: BorderRadius.circular(18.r),
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 13.sp,
                  ),
                  padding: EdgeInsets.all(3.w),
                  tabs: const [
                    Tab(
                      text: 'Existing Students',
                      icon: Icon(Icons.list, size: 14),
                    ),
                    Tab(
                      text: 'Add Student',
                      icon: Icon(Icons.person_add, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Add a divider
          Divider(height: 1, color: Colors.grey.shade300),
          
          // Main content with TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Existing Students Tab
                _buildExistingUsersTab(),
                
                // Add Student Tab
                _buildAddUserTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingUsersTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(12.w),
          child: Container(
            height: 50.h,
            width: double.infinity,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                hintStyle: TextStyle(fontSize: 13.sp),
                prefixIcon: Icon(Icons.search, size: 18.sp),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18.sp),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              ),
            ),
          ),
        ),
          
        // Main content
        Expanded(
          child: _buildUserList(),
        ),
      ],
    );
  }

  Widget _buildAddUserTab() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Student',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || 
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All fields are required'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    await _addUser(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                    );
                    
                    // Clear fields after successful addition
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    
                    // Switch to first tab to show the newly added user
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Student'),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter users based on search query
    final filteredUsers = _users.where((user) {
      return user['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return filteredUsers.isEmpty
        ? Center(
            child: Text(
              _searchQuery.isEmpty ? 'No students found' : 'No students match your search',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        : ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    backgroundImage: user['photoUrl'] != null ? NetworkImage(user['photoUrl']) : null,
                    child: user['photoUrl'] == null ? Text(
                      user['name'].toString()[0].toUpperCase(),
                      style: TextStyle(color: Colors.purple.shade800),
                    ) : null,
                  ),
                  title: Text(user['name'].toString()),
                  subtitle: Text(user['email'].toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w, 
                          vertical: 4.h
                        ),
                        decoration: BoxDecoration(
                          color: user['status'] == 'Active'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          user['status'].toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: user['status'] == 'Active'
                                ? Colors.green.shade800
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, size: 20.sp),
                        onPressed: () {
                          _showUserActionMenu(user);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showUserDetails(user);
                  },
                ),
              );
            },
          );
  }

  void _showUserActionMenu(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Student'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditUserDialog(user);
                },
              ),
              ListTile(
                leading: Icon(
                  user['status'] == 'Active' ? Icons.block : Icons.check_circle,
                ),
                title: Text(
                  user['status'] == 'Active' ? 'Deactivate Student' : 'Activate Student',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleUserStatus(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Student', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(user);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addUser(String name, String email, String password) async {
    try {
      // In a real app, you would create a user in Firebase Auth first
      // Then add the user document to Firestore
      await _firestore.collection('users').add({
        'displayName': name,
        'email': email,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadUsers(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add student: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    // Implementation of user details dialog
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // Implementation of edit user dialog
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    // Implementation of toggling user status
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text('Are you sure you want to delete ${user['name']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Delete user implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user['name']} has been deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 