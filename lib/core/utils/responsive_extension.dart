import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Utility methods for responsive sizing using ScreenUtil
class Responsive {
  /// Convert width based on design size
  static double w(num width) => width.w;
  
  /// Convert height based on design size
  static double h(num height) => height.h;
  
  /// Convert font size based on design size
  static double sp(num fontSize) => fontSize.sp;
  
  /// Convert radius based on design size
  static double r(num radius) => radius.r;
  
  /// Get screen width
  static double get screenWidth => ScreenUtil().screenWidth;
  
  /// Get screen height
  static double get screenHeight => ScreenUtil().screenHeight;
  
  /// Get responsive padding
  static EdgeInsets padding({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (all > 0) {
      return EdgeInsets.all(all.r);
    } else if (horizontal > 0 || vertical > 0) {
      return EdgeInsets.symmetric(
        horizontal: horizontal > 0 ? horizontal.w : 0,
        vertical: vertical > 0 ? vertical.h : 0,
      );
    } else {
      return EdgeInsets.only(
        left: left > 0 ? left.w : 0,
        top: top > 0 ? top.h : 0,
        right: right > 0 ? right.w : 0,
        bottom: bottom > 0 ? bottom.h : 0,
      );
    }
  }
  
  /// Get responsive margin
  static EdgeInsets margin({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (all > 0) {
      return EdgeInsets.all(all.r);
    } else if (horizontal > 0 || vertical > 0) {
      return EdgeInsets.symmetric(
        horizontal: horizontal > 0 ? horizontal.w : 0,
        vertical: vertical > 0 ? vertical.h : 0,
      );
    } else {
      return EdgeInsets.only(
        left: left > 0 ? left.w : 0,
        top: top > 0 ? top.h : 0,
        right: right > 0 ? right.w : 0,
        bottom: bottom > 0 ? bottom.h : 0,
      );
    }
  }
}

/// Extension for responsive widgets
extension ResponsiveWidgetExtension on Widget {
  /// Add responsive padding to widget
  Widget withPadding({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: Responsive.padding(
        all: all,
        horizontal: horizontal,
        vertical: vertical,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
  
  /// Add responsive margin to widget
  Widget withMargin({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: Responsive.margin(
        all: all,
        horizontal: horizontal,
        vertical: vertical,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}