import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppThemes {
  // User App Theme (Orange & White)
  static ThemeData getUserTheme() {
    // Check if ScreenUtil is initialized, if not return a basic theme
    try {
      // Try to access ScreenUtil functionality to see if it's initialized
      double test = 10.sp;
      // ScreenUtil is initialized, return the full theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFB74D),  // Primary orange
          secondary: Color(0xFFFF9800), // Secondary orange
          tertiary: Color(0xFFFFF3E0),  // Light background
          onPrimary: Colors.white,      // Text/icons on orange
          onSurface: Colors.black,      // Main text color
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: 56.h,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF9800),
          unselectedItemColor: Colors.grey.shade600,
          selectedIconTheme: IconThemeData(size: 24.sp),
          unselectedIconTheme: IconThemeData(size: 24.sp),
          selectedLabelStyle: TextStyle(fontSize: 12.sp),
          unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF9800),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          labelStyle: TextStyle(color: Colors.black87, fontSize: 14.sp),
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16.sp),
          bodyMedium: TextStyle(fontSize: 14.sp),
          bodySmall: TextStyle(fontSize: 12.sp),
        ),
        useMaterial3: true,
      );
    } catch (e) {
      // ScreenUtil is not initialized, return a basic theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFB74D),  // Primary orange
          secondary: Color(0xFFFF9800), // Secondary orange
          tertiary: Color(0xFFFFF3E0),  // Light background
          onPrimary: Colors.white,      // Text/icons on orange
          onSurface: Colors.black,      // Main text color
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
      );
    }
  }

  // Admin App Theme (Lite Purple & White)
  static ThemeData getAdminTheme() {
    // Check if ScreenUtil is initialized, if not return a basic theme
    try {
      // Try to access ScreenUtil functionality to see if it's initialized
      double test = 10.sp;
      // ScreenUtil is initialized, return the full theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE1BEE7),  // Light purple
          secondary: Color(0xFF7B1FA2), // Deep purple
          surface: Colors.white,        // Cards/dialogs
          onPrimary: Colors.black,      // Text/icons on purple
          onSurface: Colors.black,      // Main text color
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFE1BEE7),
          foregroundColor: Colors.black,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black),
          toolbarHeight: 56.h,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xFFE1BEE7),
          selectedIconTheme: IconThemeData(color: const Color(0xFF7B1FA2), size: 24.sp),
          unselectedIconTheme: IconThemeData(color: Colors.black, size: 24.sp),
          labelType: NavigationRailLabelType.selected,
          selectedLabelTextStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF7B1FA2)),
          unselectedLabelTextStyle: TextStyle(fontSize: 12.sp, color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE1BEE7),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF7B1FA2),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          labelStyle: TextStyle(color: Colors.black87, fontSize: 14.sp),
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16.sp),
          bodyMedium: TextStyle(fontSize: 14.sp),
          bodySmall: TextStyle(fontSize: 12.sp),
        ),
        useMaterial3: true,
      );
    } catch (e) {
      // ScreenUtil is not initialized, return a basic theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE1BEE7),  // Light purple
          secondary: Color(0xFF7B1FA2), // Deep purple
          surface: Colors.white,        // Cards/dialogs
          onPrimary: Colors.black,      // Text/icons on purple
          onSurface: Colors.black,      // Main text color
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE1BEE7),
          foregroundColor: Colors.black,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        useMaterial3: true,
      );
    }
  }
  
  // Instructor App Theme (Deeper Orange)
  static ThemeData getInstructorTheme() {
    // Check if ScreenUtil is initialized, if not return a basic theme
    try {
      // Try to access ScreenUtil functionality to see if it's initialized
      double test = 10.sp;
      // ScreenUtil is initialized, return the full theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF9800),     // Deep orange
          secondary: Color(0xFFF57C00),   // Darker orange
          tertiary: Color(0xFFFFF8E1),    // Light background
          onPrimary: Colors.white,        // Text/icons on orange
          onSurface: Colors.black,        // Main text color
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: 56.h,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFFFF9800),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedIconTheme: IconThemeData(size: 24.sp),
          unselectedIconTheme: IconThemeData(size: 24.sp),
          selectedLabelStyle: TextStyle(fontSize: 12.sp),
          unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFF57C00),
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          labelStyle: TextStyle(color: Colors.black87, fontSize: 14.sp),
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16.sp),
          bodyMedium: TextStyle(fontSize: 14.sp),
          bodySmall: TextStyle(fontSize: 12.sp),
        ),
        useMaterial3: true,
      );
    } catch (e) {
      // ScreenUtil is not initialized, return a basic theme
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF9800),     // Deep orange
          secondary: Color(0xFFF57C00),   // Darker orange
          tertiary: Color(0xFFFFF8E1),    // Light background
          onPrimary: Colors.white,        // Text/icons on orange
          onSurface: Colors.black,        // Main text color
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF9800),
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
      );
    }
  }
} 