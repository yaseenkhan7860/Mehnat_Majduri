import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum UserRole {
  user,
  instructor,
}

class RoleSelectionDialog extends StatefulWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionDialog({
    super.key,
    required this.onRoleSelected,
  });

  static Future<UserRole?> show(BuildContext context) async {
    return showDialog<UserRole>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RoleSelectionDialog(
          onRoleSelected: (role) {
            Navigator.of(context).pop(role);
          },
        );
      },
    );
  }

  @override
  State<RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Your Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please select how you want to use Astro:',
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 20.h),
          _buildRoleOption(
            UserRole.user,
            'Student',
            'Learn from courses and connect with experts',
            Icons.person,
          ),
          SizedBox(height: 12.h),
          _buildRoleOption(
            UserRole.instructor,
            'Instructor',
            'Create courses and teach students',
            Icons.school,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _selectedRole == null
              ? null
              : () => widget.onRoleSelected(_selectedRole!),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(
    UserRole role,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
} 