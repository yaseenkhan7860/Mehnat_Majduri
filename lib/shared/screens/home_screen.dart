import 'package:flutter/material.dart';
import 'package:astro/config/flavor_config.dart' as flavor_config;
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';

class SharedHomeScreen extends StatelessWidget {
  const SharedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(flavor_config.FlavorConfig.instance.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: buildBody(context),
      drawer: buildDrawer(context),
    );
  }

  Widget buildBody(BuildContext context) {
    // Override in subclasses
    return const Center(
      child: Text('Override this method in your app-specific home screen'),
    );
  }
  
  Widget buildDrawer(BuildContext context) {
    // Base drawer implementation
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: flavor_config.FlavorConfig.instance.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    getFlavorIcon(),
                    color: flavor_config.FlavorConfig.instance.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  flavor_config.FlavorConfig.instance.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'example@email.com',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
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
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
        ],
      ),
    );
  }
  
  IconData getFlavorIcon() {
    if (flavor_config.FlavorConfig.isUser()) {
      return Icons.person;
    } else if (flavor_config.FlavorConfig.isAdmin()) {
      return Icons.admin_panel_settings;
    }
    return Icons.error;
  }
} 