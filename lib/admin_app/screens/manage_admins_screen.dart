import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:intl/intl.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _admins = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    _loadAdmins();
    
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

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get admins from the admins collection
      final QuerySnapshot adminSnapshot = await _firestore
          .collection('admins')
          .get();
      
      final List<Map<String, dynamic>> loadedAdmins = [];
      final currentUser = _auth.currentUser;
      
      for (var doc in adminSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final String email = userData['email'] ?? 'No email';
        final Map<String, dynamic> admin = {
          'id': doc.id,
          'name': userData['displayName'] ?? 'Admin User',
          'email': email,
          'status': userData['isActive'] == true ? 'Active' : 'Inactive',
          'role': userData['role'] == 'superadmin' ? 'Super Admin' : 'Admin',
          'isCurrent': currentUser?.email == email,
          'lastLogin': _formatTimestamp(userData['lastLogin']),
        };
        loadedAdmins.add(admin);
      }
      
      // If no admins found in database, add default admin
      if (loadedAdmins.isEmpty) {
        loadedAdmins.add({
          'id': 'default',
          'name': 'Admin User',
          'email': 'astroapp.admin@astroapp.com',
          'status': 'Active',
          'role': 'Super Admin',
          'isCurrent': currentUser?.email == 'astroapp.admin@astroapp.com',
          'lastLogin': DateFormat('MMM d, y h:mm a').format(DateTime.now()),
        });
      }
      
      setState(() {
        _admins = loadedAdmins;
      });
    } catch (e) {
      debugPrint('Error loading admins: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load admins: ${e.toString()}'),
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

  List<Map<String, dynamic>> get _filteredAdmins {
    return _admins.where((admin) {
      return admin['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          admin['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          admin['role'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Only admin app should see this screen in its normal form
    if (F.appFlavor != Flavor.admin) {
      return const Center(
        child: Text(
          'Admin management is only available in the Admin app',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Material(
      child: Column(
        children: [
          // Tab bar at top with improved styling
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  indicator: BoxDecoration(
                    color: Colors.purple.shade800,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  splashBorderRadius: BorderRadius.circular(18),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.all(3),
                  tabs: const [
                    Tab(
                      text: 'Existing Admins',
                      icon: Icon(Icons.list, size: 14),
                    ),
                    Tab(
                      text: 'Add Admin',
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
                // Existing Admins Tab
                _buildExistingAdminsTab(),
                
                // Add Admin Tab
                _buildAddAdminTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExistingAdminsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: 40,
            width: double.infinity,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search admins...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAdmins.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 70,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No admins found in database',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredAdmins.length,
                      itemBuilder: (context, index) {
                        final admin = _filteredAdmins[index];
                        final bool isCurrent = admin['isCurrent'] == true;
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: InkWell(
                            onTap: () {
                              _showAdminDetails(admin);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with avatar and name
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: admin['role'] == 'Super Admin' 
                                            ? Colors.red.shade100 
                                            : Colors.purple.shade100,
                                        child: Icon(
                                          Icons.admin_panel_settings,
                                          size: 16,
                                          color: admin['role'] == 'Super Admin' 
                                              ? Colors.red 
                                              : Colors.purple,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  admin['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                if (isCurrent)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.shade100,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Text(
                                                      'Current',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: admin['role'] == 'Super Admin'
                                                        ? Colors.red.withOpacity(0.2)
                                                        : Colors.purple.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    admin['role'],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: admin['role'] == 'Super Admin'
                                                          ? Colors.red.shade800
                                                          : Colors.purple.shade800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              admin['email'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Last login: ${admin['lastLogin']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (!isCurrent) ...[
                                    const SizedBox(height: 8),
                                    const Divider(height: 1),
                                    const SizedBox(height: 6),
                                    
                                    // Action buttons row
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.edit,
                                            label: 'Edit',
                                            color: Colors.orange,
                                            onPressed: () {
                                              _showEditAdminDialog(admin);
                                            },
                                          ),
                                          const SizedBox(width: 6),
                                          _buildActionButton(
                                            icon: Icons.delete,
                                            label: 'Delete',
                                            color: Colors.red,
                                            onPressed: () {
                                              _confirmDeleteAdmin(admin);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: const Size(0, 28),
      ),
    );
  }
  
  void _showAdminDetails(Map<String, dynamic> admin) {
    // Generate mock login history for demo purposes
    final List<Map<String, String>> loginHistory = List.generate(
      5,
      (index) {
        final date = DateTime.now().subtract(Duration(days: index));
        return {
          'date': DateFormat('MMM d, y').format(date),
          'time': DateFormat('h:mm a').format(date),
          'device': index % 2 == 0 ? 'Mobile App' : 'Web Browser',
          'ip': '192.168.${index + 1}.${(index * 50) + 1}',
        };
      },
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(admin['name']),
            const SizedBox(width: 8),
            if (admin['role'] == 'Super Admin')
              Icon(Icons.shield, size: 20, color: Colors.red.shade700),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Account Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _detailRow('Email', admin['email']),
              _detailRow('Role', admin['role']),
              _detailRow('Status', admin['status']),
              const Divider(),
              
              const Text(
                'Recent Login History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _detailRow('Last Login', admin['lastLogin']),
              ...loginHistory.map((login) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.login, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${login['date']} at ${login['time']} via ${login['device']} (${login['ip']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddAdminTab() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isSuperAdmin = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Admin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Super Admin Privileges'),
                subtitle: const Text('Can manage other admins and has full access'),
                value: isSuperAdmin,
                onChanged: (value) {
                  setState(() {
                    isSuperAdmin = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
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
                    
                    await _addAdmin(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      isSuperAdmin,
                    );
                    
                    // Clear fields after successful addition
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    
                    // Switch to first tab to show the newly added admin
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Admin'),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showAdminActionMenu(Map<String, dynamic> admin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Admin'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditAdminDialog(admin);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Admin', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteAdmin(admin);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final TextEditingController nameController = TextEditingController(text: admin['name']);
    final TextEditingController emailController = TextEditingController(text: admin['email']);
    bool isSuperAdmin = admin['role'] == 'Super Admin';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Admin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: false, // Email can't be changed
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Super Admin Privileges'),
                      value: isSuperAdmin,
                      onChanged: (value) {
                        setState(() {
                          isSuperAdmin = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name is required'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    await _updateAdmin(
                      admin['id'],
                      nameController.text,
                      isSuperAdmin,
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDeleteAdmin(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${admin['name']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAdmin(admin);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAdmin(String name, String email, String password, bool isSuperAdmin) async {
    try {
      // In a real app, you would create a user in Firebase Auth first
      // Then add the admin document to Firestore
      await _firestore.collection('admins').add({
        'displayName': name,
        'email': email,
        'role': isSuperAdmin ? 'superadmin' : 'admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadAdmins(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add admin: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateAdmin(String id, String name, bool isSuperAdmin) async {
    try {
      await _firestore.collection('admins').doc(id).update({
        'displayName': name,
        'role': isSuperAdmin ? 'superadmin' : 'admin',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadAdmins(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update admin: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAdmin(Map<String, dynamic> admin) async {
    try {
      await _firestore.collection('admins').doc(admin['id']).delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadAdmins(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete admin: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 