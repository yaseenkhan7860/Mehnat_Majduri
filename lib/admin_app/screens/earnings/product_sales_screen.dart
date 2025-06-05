import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:astro/admin_app/widgets/admin_base_screen.dart';
import 'package:astro/admin_app/widgets/admin_stat_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductSalesScreen extends StatefulWidget {
  const ProductSalesScreen({super.key});

  @override
  State<ProductSalesScreen> createState() => _ProductSalesScreenState();
}

class _ProductSalesScreenState extends AdminBaseScreen<ProductSalesScreen> {
  List<Map<String, dynamic>> _sales = [];
  
  final DateFormat _dateFormat = DateFormat('MMM d, y');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹');
  
  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  int get tabCount => 1; // This screen doesn't use tabs, but we need to provide a value

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
                AdminStatCard(
                  title: 'Total Sales',
                  value: _currencyFormat.format(125000),
                  color: Colors.green,
                ),
                SizedBox(width: 8.w),
                AdminStatCard(
                  title: 'Orders',
                  value: '42',
                  color: Colors.blue,
                ),
                SizedBox(width: 8.w),
                AdminStatCard(
                  title: 'Avg. Order',
                  value: _currencyFormat.format(2976),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Main content
          Expanded(
            child: buildPlaceholderContent(
              icon: Icons.shopping_cart,
              title: 'Product Sales Analytics Coming Soon',
              subtitle: 'This section will display product sales data and analytics',
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
} 