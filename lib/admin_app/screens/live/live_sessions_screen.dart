import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:astro/core/utils/responsive_extension.dart';


class LiveSessionsScreen extends StatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  State<LiveSessionsScreen> createState() => _LiveSessionsScreenState();
}

class _LiveSessionsScreenState extends State<LiveSessionsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _sessions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController = TabController(length: 3, vsync: this);

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
            height: ScreenUtil().setHeight(40),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple.shade800,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple.shade800,
              labelStyle: TextStyle(fontSize: ScreenUtil().setSp(12)),
              tabs: const [
                Tab(
                  icon: Icon(Icons.schedule, size: 18),
                  text: 'Upcoming',
                ),
                Tab(
                  icon: Icon(Icons.live_tv, size: 18),
                  text: 'Live Now',
                ),
                Tab(
                  icon: Icon(Icons.history, size: 18),
                  text: 'Past Sessions',
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            child: Container(
              height: ScreenUtil().setHeight(40),
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search live sessions...',
                  hintStyle: TextStyle(fontSize: ScreenUtil().setSp(13)),
                  prefixIcon: Icon(Icons.search, size: ScreenUtil().setSp(18)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().radius(8)),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: ScreenUtil().setSp(18)),
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
                // Upcoming Tab
                _buildPlaceholderContent('Upcoming Sessions', Icons.schedule),
                
                // Live Now Tab
                _buildPlaceholderContent('Live Sessions', Icons.live_tv),
                
                // Past Sessions Tab
                _buildPlaceholderContent('Past Sessions', Icons.history),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderContent(String title, IconData icon) {
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
            '$title Coming Soon',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(8)),
          Text(
            'This section will allow you to manage $title',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
} 