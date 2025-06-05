import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionSalesScreen extends StatefulWidget {
  const SubscriptionSalesScreen({super.key});

  @override
  State<SubscriptionSalesScreen> createState() => _SubscriptionSalesScreenState();
}

class _SubscriptionSalesScreenState extends State<SubscriptionSalesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _subscriptions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final DateFormat _dateFormat = DateFormat('MMM d, y');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹');
  
  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

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
                _buildStatCard('Total Revenue', _currencyFormat.format(75000), Colors.green),
                SizedBox(width: 8.w),
                _buildStatCard('Subscribers', '28', Colors.blue),
                SizedBox(width: 8.w),
                _buildStatCard('Avg. Subscription', _currencyFormat.format(2678), Colors.orange),
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
                    Icons.card_membership,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Subscription Analytics Coming Soon',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This section will display subscription data and analytics',
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
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: _startDate,
            end: _endDate,
          ),
        );
        
        if (picked != null) {
          setState(() {
            _startDate = picked.start;
            _endDate = picked.end;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, size: 18.sp),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: color.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 