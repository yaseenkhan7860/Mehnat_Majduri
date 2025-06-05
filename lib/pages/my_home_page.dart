import 'package:flutter/material.dart';
import '../flavors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(F.title)),
      body: Center(
        child: Text(
          'Hello ${F.title}',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
