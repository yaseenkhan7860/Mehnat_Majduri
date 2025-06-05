import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? color;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: color ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
} 