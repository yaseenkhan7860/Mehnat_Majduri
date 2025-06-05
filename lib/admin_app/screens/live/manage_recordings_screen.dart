import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageRecordingsScreen extends StatefulWidget {
  const ManageRecordingsScreen({super.key});

  @override
  State<ManageRecordingsScreen> createState() => _ManageRecordingsScreenState();
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _recordings = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final List<String> _categories = [
    'All', 'Astrology', 'Tarot', 'Numerology', 'Vastu', 'Meditation', 'Other'
  ];
  
  String _selectedCategory = 'All';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            child: Container(
              height: ScreenUtil().setHeight(40),
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search recordings...',
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
          
          // Filter by category
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
            child: Container(
              height: ScreenUtil().setHeight(40),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((category) => _buildFilterChip(category)).toList(),
              ),
            ),
          ),
          
          // Header with add button
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recordings',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add recording functionality
                  },
                  icon: Icon(Icons.add, size: ScreenUtil().setSp(18)),
                  label: Text('Add Recording', style: TextStyle(fontSize: ScreenUtil().setSp(13))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(12), 
                      vertical: ScreenUtil().setHeight(8)
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    size: ScreenUtil().setSp(80),
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(16)),
                  Text(
                    'Recording Management Coming Soon',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  Text(
                    'This section will allow you to manage session recordings',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String category) {
    final bool isSelected = _selectedCategory == category;
    
    return Padding(
      padding: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(12),
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.purple.shade700,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(4), 
          vertical: 0
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      ),
    );
  }
} 