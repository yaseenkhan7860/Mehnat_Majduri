import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:astro/admin_app/widgets/admin_base_screen.dart';
import 'package:astro/admin_app/widgets/admin_stat_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends AdminBaseScreen<ManageProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  
  @override
  int get tabCount => 2;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Tab bar at top
          buildTabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.list, size: 18),
                text: 'All Products',
              ),
              Tab(
                icon: Icon(Icons.add_box, size: 18),
                text: 'Add Product',
              ),
            ],
          ),
          
          // Main content with TabBarView
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // All Products Tab
                _buildAllProductsTab(),
                
                // Add Product Tab
                _buildAddProductTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllProductsTab() {
    return buildPlaceholderContent(
      icon: Icons.shopping_bag,
      title: 'Product Management Coming Soon',
      subtitle: 'This section will allow you to manage all products',
    );
  }
  
  Widget _buildAddProductTab() {
    return buildPlaceholderContent(
      icon: Icons.add_shopping_cart,
      title: 'Add Product Coming Soon',
      subtitle: 'This section will allow you to add new products',
    );
  }
} 