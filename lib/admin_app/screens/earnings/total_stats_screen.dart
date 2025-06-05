import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalStatsScreen extends StatefulWidget {
  const TotalStatsScreen({super.key});

  @override
  State<TotalStatsScreen> createState() => _TotalStatsScreenState();
}

class _TotalStatsScreenState extends State<TotalStatsScreen> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹');
  final List<String> _timeRanges = ['Last 7 days', 'Last 30 days', 'Last 90 days', 'This year', 'All time'];
  String _selectedTimeRange = 'Last 30 days';

  @override
  void initState() {
    super.initState();
    
    // Verify the user is an admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isSignedIn || authService.userRole != 'admin') {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Date range selector
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateRangeSelector(),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () {
                    // Export functionality
                  },
                  icon: Icon(Icons.download, size: 18.sp),
                  label: Text('Export', style: TextStyle(fontSize: 13.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                _buildStatCard('Total Revenue', _currencyFormat.format(200000), Colors.green),
                SizedBox(width: 8.w),
                _buildStatCard('Total Orders', '70', Colors.blue),
                SizedBox(width: 8.w),
                _buildStatCard('Avg. Order', _currencyFormat.format(2857), Colors.orange),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Total Stats Analytics Coming Soon',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This section will display comprehensive analytics',
                    style: TextStyle(
                      fontSize: 14.sp,
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
  
  Widget _buildDateRangeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButton<String>(
        value: _selectedTimeRange,
        icon: Icon(Icons.arrow_drop_down, size: 18.sp),
        elevation: 16,
        style: TextStyle(color: Colors.black87, fontSize: 13.sp),
        underline: Container(height: 0),
        isExpanded: true,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedTimeRange = newValue;
            });
          }
        },
        items: _timeRanges.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp),
                SizedBox(width: 8.w),
                Text(value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 32,
              color: color.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
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
} 