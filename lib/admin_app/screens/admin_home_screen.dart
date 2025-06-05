import 'package:flutter/material.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:astro/admin_app/widgets/admin_stat_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:astro/config/flavor_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:async';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _adminName = 'Admin User';
  String _adminEmail = '';
  String _lastLogin = '';
  bool _isLoading = true;
  
  int _totalUsers = 0;
  int _totalRevenue = 0;
  int _totalCourses = 0;
  int _totalSessions = 0;
  
  // Chart data
  List<ChartData> _userStatsData = [];
  List<ChartData> _callData = [];
  List<ChartData> _chatData = [];
  
  // Points to show per page
  final int _pointsPerPage = 12; // Show all months
  
  StreamSubscription? _statsSubscription;
  StreamSubscription? _requestsSubscription;
  
  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadUserStats();
    _generateYearlyData();
    _subscribeToLiveData();
    
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
    _statsSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }
  
  void _subscribeToLiveData() {
    // Subscribe to real-time stats updates
    _statsSubscription = _firestore
        .collection('statistics')
        .doc('dashboard')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _totalUsers = data['totalUsers'] ?? 0;
          _totalRevenue = data['totalRevenue'] ?? 0;
          _totalCourses = data['totalCourses'] ?? 0;
          _totalSessions = data['totalSessions'] ?? 0;
        });
      }
    });
    
    // Subscribe to real-time requests data
    _requestsSubscription = _firestore
        .collection('requests')
        .doc(DateTime.now().year.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;
        _updateRequestsData(data);
      } else {
        _generateInitialRequestsData();
      }
    });
  }
  
  void _updateRequestsData(Map<String, dynamic> data) {
    final currentYear = DateTime.now().year;
    
    // Clear existing data
    _callData = [];
    _chatData = [];
    
    // Generate data for Jan to Dec
    for (int month = 1; month <= 12; month++) {
      final date = DateTime(currentYear, month, 1);
      final monthLabel = DateFormat('MMM yyyy').format(date);
      final monthKey = month.toString().padLeft(2, '0');
      
      _callData.add(ChartData(
        label: monthLabel,
        value: data['calls_$monthKey'] ?? 0,
      ));
      
      _chatData.add(ChartData(
        label: monthLabel,
        value: data['chats_$monthKey'] ?? 0,
      ));
    }
    
    if (mounted) setState(() {});
  }
  
  void _generateInitialRequestsData() {
    final currentYear = DateTime.now().year;
    final Map<String, dynamic> initialData = {};
    
    // Generate initial data for the current year
    for (int month = 1; month <= 12; month++) {
      final monthKey = month.toString().padLeft(2, '0');
      initialData['calls_$monthKey'] = 0;
      initialData['chats_$monthKey'] = 0;
    }
    
    // Save initial data to Firestore
    _firestore
        .collection('requests')
        .doc(currentYear.toString())
        .set(initialData)
        .then((_) => _updateRequestsData(initialData));
  }
  
  Future<void> _downloadData() async {
    try {
      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Month', 'Calls', 'Chats'], // Header
      ];
      
      // Add data rows
      for (int i = 0; i < _callData.length; i++) {
        csvData.add([
          _callData[i].label,
          _callData[i].value,
          _chatData[i].value,
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'requests_${DateTime.now().year}.csv';
      final file = File('${directory.path}/$fileName');
      
      // Write to file
      await file.writeAsString(csv);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data downloaded to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download data')),
        );
      }
    }
  }
  
  void _generateYearlyData() {
    final random = Random();
    final currentYear = DateTime.now().year;
    
    // Clear existing data
    _userStatsData = [];
    _callData = [];
    _chatData = [];
    
    // Generate data for Jan to Dec of current year
    for (int month = 1; month <= 12; month++) {
      final date = DateTime(currentYear, month, 1);
      final monthLabel = DateFormat('MMM yyyy').format(date);
      
      // User stats - growing trend (multiples of 200)
      _userStatsData.add(ChartData(
        label: monthLabel,
        value: (random.nextInt(4) + 1) * 200 + month * 50,
      ));
      
      // Call data (multiples of 200)
      _callData.add(ChartData(
        label: monthLabel,
        value: (random.nextInt(2) + 1) * 200 + month * 20,
      ));
      
      // Chat data
      _chatData.add(ChartData(
        label: monthLabel,
        value: (random.nextInt(2) + 1) * 200 + month * 15,
      ));
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadUserStats() async {
    try {
      // Get count of users from Firestore
      final usersSnapshot = await _firestore.collection('users').count().get();
      final instructorsSnapshot = await _firestore.collection('instructors').count().get();
      final adminsSnapshot = await _firestore.collection('admins').count().get();
      
      if (mounted) {
        setState(() {
          _totalUsers = (usersSnapshot.count ?? 0) + (instructorsSnapshot.count ?? 0) + (adminsSnapshot.count ?? 0);
        });
      }
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    }
  }
  
  Future<void> _loadAdminData() async {
    if (mounted) {
    setState(() {
      _isLoading = true;
    });
    }
    
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Get admin email from Firebase Auth
        _adminEmail = currentUser.email ?? 'astroapp.admin@astroapp.com';
        
        // Get admin data from Firestore
        final adminDoc = await _firestore.collection('admins').doc(currentUser.uid).get();
        
        if (adminDoc.exists) {
          final adminData = adminDoc.data();
          if (adminData != null && mounted) {
            setState(() {
              _adminName = adminData['displayName'] ?? 'Admin User';
              
              // Format last login time if available
              if (adminData['lastLogin'] != null) {
                final Timestamp lastLogin = adminData['lastLogin'] as Timestamp;
                _lastLogin = lastLogin.toDate().toString().substring(0, 16);
              } else {
                _lastLogin = DateTime.now().toString().substring(0, 16);
              }
            });
          }
        } else {
          // Create admin document if it doesn't exist
          await _firestore.collection('admins').doc(currentUser.uid).set({
            'displayName': 'Admin User',
            'email': _adminEmail,
            'isActive': true,
            'lastLogin': FieldValue.serverTimestamp(),
          });
          
          debugPrint('Admin user created/updated in admins collection: ${currentUser.uid}');
        }
        
        // Update last login time
        await _firestore.collection('admins').doc(currentUser.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error loading admin data: $e');
    } finally {
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          SizedBox(height: 24.h),
          
          // Revenue stats at the top
          _buildStatCard(
            title: 'Total Revenue',
            value: _isLoading ? '...' : '₹${NumberFormat('#,###').format(_totalRevenue)}',
            icon: Icons.currency_rupee,
            color: Colors.green,
          ),
          SizedBox(height: 16.h),
          
          // Stats in a single column
          _buildStatCard(
            title: 'Total Users',
            value: _isLoading ? '...' : _totalUsers.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),
          
          // User Growth Chart
          _buildUserStatsCard(),
          SizedBox(height: 16.h),
          
          _buildStatCard(
            title: 'Active Courses',
            value: _isLoading ? '...' : _totalCourses.toString(),
            icon: Icons.school,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          
          _buildStatCard(
            title: 'Live Sessions',
            value: _isLoading ? '...' : _totalSessions.toString(),
            icon: Icons.live_tv,
            color: Colors.red,
          ),
          SizedBox(height: 24.h),
          
          // Monthly Request Report with stats
          _buildRequestReportCard(),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28.sp),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestReportCard() {
    // Calculate total calls and chats
    int totalCalls = _callData.fold(0, (sum, item) => sum + item.value);
    int totalChats = _chatData.fold(0, (sum, item) => sum + item.value);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Requests',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'January to December ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Stats for calls and chats in a column
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Total Calls',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        totalCalls.toString(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.chat, color: Colors.amber, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Total Chats',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        totalChats.toString(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Download button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _downloadData,
                  icon: Icon(Icons.download, size: 18.sp),
                  label: Text('Download Data'),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Chart with slide navigation
            SizedBox(
              height: 300.h,
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView(
                    children: [
                      _buildRequestChart(0, 5), // First 6 months (0-5)
                      _buildRequestChart(6, 11), // Last 6 months (6-11)
                    ],
                  ),
            ),
            
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserStatsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'January to December ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Download button for user growth data
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _downloadUserGrowthData,
                  icon: Icon(Icons.download, size: 18.sp),
                  label: Text('Download Data'),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Chart with slide navigation
            SizedBox(
              height: 300.h,
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView(
                    children: [
                      _buildUserStatsChart(0, 5), // First 6 months (0-5)
                      _buildUserStatsChart(6, 11), // Last 6 months (6-11)
                    ],
                  ),
            ),
            
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestChart(int startMonth, int endMonth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Filter data for the selected months range
        final filteredCallData = _callData.asMap()
            .entries
            .where((entry) => entry.key >= startMonth && entry.key <= endMonth)
            .map((entry) => entry.value)
            .toList();
            
        final filteredChatData = _chatData.asMap()
            .entries
            .where((entry) => entry.key >= startMonth && entry.key <= endMonth)
            .map((entry) => entry.value)
            .toList();
            
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1000, // Increased scale to 1000
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: const Color.fromRGBO(50, 50, 50, 0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final monthIndex = groupIndex + startMonth;
                  final data = rodIndex == 0 ? _callData[monthIndex] : _chatData[monthIndex];
                  final type = rodIndex == 0 ? 'Calls' : 'Chats';
                  return BarTooltipItem(
                    '$type: ${data.value}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final groupIndex = value.toInt();
                    final monthIndex = groupIndex + startMonth;
                    if (monthIndex >= _callData.length) return const SizedBox.shrink();
                    
                    final month = _callData[monthIndex].label.split(' ')[0];
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        month,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value % 200 != 0) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                if (value % 200 != 0) return FlLine(strokeWidth: 0);
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: filteredCallData.asMap().entries.map((entry) {
              final index = entry.key;
              final callData = entry.value;
              final chatData = filteredChatData[index];
              
              final width = constraints.maxWidth / (filteredCallData.length * 3);
              
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: callData.value.toDouble(),
                    color: Colors.green,
                    width: width,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(4.r),
                    ),
                  ),
                  BarChartRodData(
                    toY: chatData.value.toDouble(),
                    color: Colors.amber,
                    width: width,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(4.r),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 150),
        );
      },
    );
  }

  Widget _buildUserStatsChart(int startMonth, int endMonth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Filter data for the selected months range
        final filteredUserData = _userStatsData.asMap()
            .entries
            .where((entry) => entry.key >= startMonth && entry.key <= endMonth)
            .map((entry) => entry.value)
            .toList();
            
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1000, // Changed to match the requested scale
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: const Color.fromRGBO(50, 50, 50, 0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final monthIndex = groupIndex + startMonth;
                  return BarTooltipItem(
                    'Users: ${_userStatsData[monthIndex].value}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final groupIndex = value.toInt();
                    final monthIndex = groupIndex + startMonth;
                    if (monthIndex >= _userStatsData.length) return const SizedBox.shrink();
                    
                    final month = _userStatsData[monthIndex].label.split(' ')[0];
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        month,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // Show only 200, 400, 600, 800, 1000 on Y-axis
                    if (value % 200 != 0) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                // Show grid lines only at 200, 400, 600, 800, 1000
                if (value % 200 != 0) return FlLine(strokeWidth: 0);
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: filteredUserData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              
              final width = constraints.maxWidth / (filteredUserData.length * 2);
              
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.value.toDouble(),
                    color: Colors.blue,
                    width: width,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(4.r),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 150),
        );
      },
    );
  }
  
  // Add method to download user growth data
  Future<void> _downloadUserGrowthData() async {
    try {
      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Month', 'Users'], // Header
      ];
      
      // Add data rows
      for (int i = 0; i < _userStatsData.length; i++) {
        csvData.add([
          _userStatsData[i].label,
          _userStatsData[i].value,
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'user_growth_${DateTime.now().year}.csv';
      final file = File('${directory.path}/$fileName');
      
      // Write to file
      await file.writeAsString(csv);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User growth data downloaded to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download user growth data')),
        );
      }
    }
  }
  
  Widget _buildWelcomeCard() {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32.r,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName ?? 'Admin'}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Today is ${_getFormattedDate()}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}

class ChartData {
  final String label;
  final int value;
  
  ChartData({required this.label, required this.value});
} 