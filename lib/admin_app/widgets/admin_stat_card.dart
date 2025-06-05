import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData? icon;
  final bool isLarge;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isLarge ? ScreenUtil().setHeight(16) : ScreenUtil().setHeight(12),
          horizontal: ScreenUtil().setWidth(16),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ScreenUtil().radius(8)),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: icon != null && isLarge
            ? _buildLargeCardWithIcon()
            : _buildStandardCard(),
      ),
    );
  }

  Widget _buildStandardCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(12),
            color: color.withOpacity(0.8),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? ScreenUtil().setSp(18) : ScreenUtil().setSp(16),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeCardWithIcon() {
    return Row(
      children: [
        Icon(
          icon,
          size: ScreenUtil().setSp(32),
          color: color.withOpacity(0.7),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13),
                  color: color.withOpacity(0.8),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(18),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 