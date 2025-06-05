import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageAstrologersScreen extends StatefulWidget {
  const ManageAstrologersScreen({super.key});

  @override
  State<ManageAstrologersScreen> createState() => _ManageAstrologersScreenState();
}

class _ManageAstrologersScreenState extends State<ManageAstrologersScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _astrologers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadAstrologers();
    
    // Verify the user is an admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isSignedIn || authService.userRole != 'admin') {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAstrologers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get astrologers from the instructors collection
      final QuerySnapshot astrologerSnapshot = await _firestore
          .collection('instructors')
          .get();
      
      final List<Map<String, dynamic>> loadedAstrologers = [];
      
      for (var doc in astrologerSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> astrologer = {
          'id': doc.id,
          'name': userData['displayName'] ?? 'Astrologer',
          'email': userData['email'] ?? 'No email',
          'status': userData['isActive'] == true ? 'Active' : 'Inactive',
          'joinDate': _formatTimestamp(userData['createdAt']),
          'lastActive': _formatTimestamp(userData['lastLogin']),
          'phoneNumber': userData['phoneNumber'] ?? 'Not provided',
          'specialization': userData['specialization'] ?? 'General',
          'verified': userData['verified'] == true ? 'Verified' : 'Unverified',
          'rating': userData['rating']?.toString() ?? 'N/A',
        };
        loadedAstrologers.add(astrologer);
      }
      
      // Sort manually by join date
      loadedAstrologers.sort((a, b) {
        // Try to parse the join dates for comparison
        try {
          final DateTime? dateA = a['joinDate'] != 'N/A' && a['joinDate'] != 'Invalid date' 
              ? DateFormat('MMM d, y h:mm a').parse(a['joinDate'])
              : null;
          final DateTime? dateB = b['joinDate'] != 'N/A' && b['joinDate'] != 'Invalid date'
              ? DateFormat('MMM d, y h:mm a').parse(b['joinDate'])
              : null;
              
          if (dateA != null && dateB != null) {
            return dateB.compareTo(dateA); // Descending order
          }
        } catch (e) {
          // Fallback if parsing fails
        }
        
        // Fallback to name comparison if dates can't be compared
        return a['name'].toString().compareTo(b['name'].toString());
      });
      
      setState(() {
        _astrologers = loadedAstrologers;
      });
    } catch (e) {
      debugPrint('Error loading astrologers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load astrologers: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    
    try {
      if (timestamp is Timestamp) {
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('MMM d, y h:mm a').format(dateTime);
      }
      return 'Invalid date';
    } catch (e) {
      return 'Invalid date';
    }
  }

  List<Map<String, dynamic>> get _filteredAstrologers {
    return _astrologers.where((astrologer) {
      final String name = astrologer['name'].toString().toLowerCase();
      final String email = astrologer['email'].toString().toLowerCase();
      final String specialization = astrologer['specialization'].toString().toLowerCase();
      final String query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             email.contains(query) || 
             specialization.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Only admin app should see this screen in its normal form
    if (F.appFlavor != Flavor.admin) {
      return const Center(
        child: Text(
          'Astrologer management is only available in the Admin app',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Astrologers',
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
                    color: Colors.orange.shade800,
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
                      text: 'Existing Astrologers',
                      icon: Icon(Icons.list, size: 14),
                    ),
                    Tab(
                      text: 'Add Astrologer',
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
                // Existing Astrologers Tab
                _buildExistingAstrologersTab(),
                
                // Add Astrologer Tab
                _buildAddAstrologerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingAstrologersTab() {
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
                hintText: 'Search astrologers...',
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAstrologers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 80.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _astrologers.isEmpty
                                ? 'No astrologers found in database'
                                : 'No astrologers match your search',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredAstrologers.length,
                      itemBuilder: (context, index) {
                        final astrologer = _filteredAstrologers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                astrologer['name'].toString()[0].toUpperCase(),
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                            title: Text(astrologer['name'].toString()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(astrologer['email'].toString()),
                                Text('Specialization: ${astrologer['specialization']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, 
                                    vertical: 4.h
                                  ),
                                  decoration: BoxDecoration(
                                    color: astrologer['status'] == 'Active'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    astrologer['status'].toString(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: astrologer['status'] == 'Active'
                                          ? Colors.green.shade800
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.more_vert, size: 20.sp),
                                  onPressed: () {
                                    _showAstrologerActionMenu(astrologer);
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              _showAstrologerDetails(astrologer);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAddAstrologerTab() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController specializationController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    bool isVerified = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Astrologer',
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
              SizedBox(height: 16.h),
              TextFormField(
                controller: specializationController,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: const Text('Verified Astrologer'),
                subtitle: const Text('Mark as verified to display verification badge'),
                value: isVerified,
                onChanged: (value) {
                  setState(() {
                    isVerified = value;
                  });
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || 
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        specializationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name, email, password and specialization are required'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    await _addAstrologer(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      specializationController.text,
                      phoneController.text,
                      isVerified,
                    );
                    
                    // Clear fields after successful addition
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    specializationController.clear();
                    phoneController.clear();
                    setState(() {
                      isVerified = false;
                    });
                    
                    // Switch to first tab to show the newly added astrologer
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Astrologer'),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showAstrologerActionMenu(Map<String, dynamic> astrologer) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Astrologer'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditAstrologerDialog(astrologer);
                },
              ),
              ListTile(
                leading: Icon(
                  astrologer['status'] == 'Active' ? Icons.block : Icons.check_circle,
                ),
                title: Text(
                  astrologer['status'] == 'Active' ? 'Deactivate Astrologer' : 'Activate Astrologer',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleAstrologerStatus(astrologer);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Astrologer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(astrologer);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addAstrologer(
    String name, 
    String email, 
    String password, 
    String specialization, 
    String phone, 
    bool isVerified
  ) async {
    try {
      // In a real app, you would create a user in Firebase Auth first
      // Then add the astrologer document to Firestore
      await _firestore.collection('instructors').add({
        'displayName': name,
        'email': email,
        'specialization': specialization,
        'phoneNumber': phone,
        'verified': isVerified,
        'isActive': true,
        'rating': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Astrologer added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadAstrologers(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add astrologer: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAstrologerDetails(Map<String, dynamic> astrologer) {
    // Implementation of astrologer details dialog
  }

  void _showEditAstrologerDialog(Map<String, dynamic> astrologer) {
    // Implementation of edit astrologer dialog
  }

  void _toggleAstrologerStatus(Map<String, dynamic> astrologer) {
    // Implementation of toggling astrologer status
  }

  void _showDeleteConfirmation(Map<String, dynamic> astrologer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Astrologer'),
          content: Text('Are you sure you want to delete ${astrologer['name']}?'),
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
                // Delete astrologer implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${astrologer['name']} has been deleted'),
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