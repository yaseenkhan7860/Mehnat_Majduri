import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Utility class for responsive sizes and spacing
class AppSizes {
  // Font sizes
  static double get fontXS => 10.sp;
  static double get fontS => 12.sp;
  static double get fontM => 14.sp;
  static double get fontL => 16.sp;
  static double get fontXL => 18.sp;
  static double get font2XL => 20.sp;
  static double get font3XL => 24.sp;
  static double get font4XL => 32.sp;
  
  // Icon sizes
  static double get iconXS => 16.sp;
  static double get iconS => 20.sp;
  static double get iconM => 24.sp;
  static double get iconL => 32.sp;
  static double get iconXL => 40.sp;
  
  // Spacing
  static double get spacingXS => 4.w;
  static double get spacingS => 8.w;
  static double get spacingM => 16.w;
  static double get spacingL => 24.w;
  static double get spacingXL => 32.w;
  static double get spacing2XL => 40.w;
  static double get spacing3XL => 48.w;
  
  // Border radius
  static double get borderRadiusXS => 4.r;
  static double get borderRadiusS => 8.r;
  static double get borderRadiusM => 12.r;
  static double get borderRadiusL => 16.r;
  static double get borderRadiusXL => 24.r;
  static double get borderRadius2XL => 32.r;
  
  // Button sizes
  static double get buttonHeightS => 32.h;
  static double get buttonHeightM => 40.h;
  static double get buttonHeightL => 48.h;
  static double get buttonHeightXL => 56.h;
  
  // Input sizes
  static double get inputHeightS => 32.h;
  static double get inputHeightM => 40.h;
  static double get inputHeightL => 48.h;
  static double get inputHeightXL => 56.h;
  
  // Avatar sizes
  static double get avatarXS => 24.w;
  static double get avatarS => 32.w;
  static double get avatarM => 40.w;
  static double get avatarL => 48.w;
  static double get avatarXL => 64.w;
  static double get avatar2XL => 80.w;
  
  // Card padding
  static EdgeInsets get cardPaddingS => EdgeInsets.all(8.w);
  static EdgeInsets get cardPaddingM => EdgeInsets.all(16.w);
  static EdgeInsets get cardPaddingL => EdgeInsets.all(24.w);
  
  // Screen padding
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  static EdgeInsets get screenPaddingHorizontal => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get screenPaddingVertical => EdgeInsets.symmetric(vertical: 16.h);
  
  // Bottom navigation bar
  static double get bottomNavHeight => 60.h;
  static double get bottomNavWithPaddingHeight => 76.h;
  
  // App bar
  static double get appBarHeight => 56.h;
  
  // Divider
  static double get dividerHeight => 1.h;
  static double get dividerThickness => 1.w;
} 