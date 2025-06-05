import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityRoomScreen extends StatefulWidget {
  const CommunityRoomScreen({super.key});

  @override
  State<CommunityRoomScreen> createState() => _CommunityRoomScreenState();
}

class _CommunityRoomScreenState extends State<CommunityRoomScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _rooms = [];
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Tab bar at top
          Container(
            color: Colors.white,
            height: 40.h,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple.shade800,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple.shade800,
              labelStyle: TextStyle(fontSize: 12.sp),
              tabs: const [
                Tab(
                  icon: Icon(Icons.forum, size: 18),
                  text: 'Active Rooms',
                ),
                Tab(
                  icon: Icon(Icons.add_comment, size: 18),
                  text: 'Create Room',
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Container(
              height: 40.h,
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search community rooms...',
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
          
          // Main content with TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Rooms Tab
                _buildActiveRoomsTab(),
                
                // Create Room Tab
                _buildCreateRoomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveRoomsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Community Rooms Coming Soon',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This section will allow you to manage community rooms',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreateRoomTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Create Room Coming Soon',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This section will allow you to create new community rooms',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
} 