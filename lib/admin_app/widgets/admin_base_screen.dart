import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AdminBaseScreen<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TabController tabController;
  
  /// Number of tabs to create
  int get tabCount;
  
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabCount, vsync: this);
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
    
    // Verify the user is an admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyAdminAuth();
    });
    
    // Call optional init method for subclasses
    onInit();
  }
  
  /// Called after initState, can be overridden by subclasses
  void onInit() {}
  
  /// Verify that the current user is an admin
  void verifyAdminAuth() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isSignedIn || authService.userRole != 'admin') {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }
  
  /// Build a standard search bar
  Widget buildSearchBar({String hintText = 'Search...'}) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
      child: Container(
        height: ScreenUtil().setHeight(40),
        width: double.infinity,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: ScreenUtil().setSp(13)),
            prefixIcon: Icon(Icons.search, size: ScreenUtil().setSp(18)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().radius(8)),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: ScreenUtil().setSp(18)),
                    onPressed: () {
                      searchController.clear();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
  
  /// Build a standard tab bar
  Widget buildTabBar({required List<Tab> tabs}) {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(50),
      child: TabBar(
        controller: tabController,
        labelColor: Colors.purple.shade800,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.purple.shade800,
        labelStyle: TextStyle(fontSize: ScreenUtil().setSp(12)),
        tabs: tabs,
      ),
    );
  }
  
  /// Build a placeholder content for screens under development
  Widget buildPlaceholderContent({
    required String title,
    required IconData icon,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ScreenUtil().setSp(80),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: ScreenUtil().setHeight(16)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: ScreenUtil().setHeight(8)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 