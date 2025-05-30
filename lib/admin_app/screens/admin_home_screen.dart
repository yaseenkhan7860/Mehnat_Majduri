import 'package:flutter/material.dart';
import 'package:astro/shared/screens/home_screen.dart';
import 'package:astro/admin_app/screens/user_management_screen.dart';
import 'package:astro/admin_app/screens/create_instructor_screen.dart';
import 'package:astro/admin_app/screens/admin_logs_screen.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';

class AdminHomeScreen extends SharedHomeScreen {
  const AdminHomeScreen({super.key});

  @override
  Widget buildBody(BuildContext context) {
    // Create an instance of the audit service
    final auditService = AdminAuditService();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAdminCard(context, 'Users', '1,245', Icons.person),
              _buildAdminCard(context, 'Experts', '58', Icons.school),
              _buildAdminCard(context, 'Courses', '210', Icons.book),
              _buildAdminCard(context, 'Revenue', '\$24,530', Icons.money),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context, 
            'Manage Users', 
            Icons.people,
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_user_management',
                {'screen': 'UserManagementScreen'},
              );
            },
          ),
          _buildActionButton(
            context, 
            'Create Instructor Account', 
            Icons.person_add,
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CreateInstructorScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_create_instructor',
                {'screen': 'CreateInstructorScreen'},
              );
            },
          ),
          _buildActionButton(
            context, 
            'View Audit Logs', 
            Icons.history,
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AdminLogsScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_audit_logs',
                {'screen': 'AdminLogsScreen'},
              );
            },
          ),
          _buildActionButton(
            context, 
            'System Settings', 
            Icons.settings,
            () {
              // Navigate to system settings screen
              
              // Log admin action
              auditService.logAdminAction(
                'view_system_settings',
                {'screen': 'SystemSettingsScreen'},
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildDrawer(BuildContext context) {
    final auditService = AdminAuditService();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile screen
              
              // Log admin action
              auditService.logAdminAction(
                'view_profile',
                {'screen': 'ProfileScreen'},
              );
            },
          ),
          // Admin-specific menu items
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_user_management',
                {'screen': 'UserManagementScreen'},
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Create Instructor'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CreateInstructorScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_create_instructor',
                {'screen': 'CreateInstructorScreen'},
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit Logs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AdminLogsScreen()),
              );
              
              // Log admin action
              auditService.logAdminAction(
                'view_audit_logs',
                {'screen': 'AdminLogsScreen'},
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
              
              // Log admin action
              auditService.logAdminAction(
                'view_settings',
                {'screen': 'SettingsScreen'},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Astro Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const Text(
            'admin@email.com',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
} 