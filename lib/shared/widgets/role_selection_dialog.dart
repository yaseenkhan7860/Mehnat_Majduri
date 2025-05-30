import 'package:flutter/material.dart';

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
          const Text(
            'Please select how you want to use Astro:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildRoleOption(
            UserRole.user,
            'Student',
            'Learn from courses and connect with experts',
            Icons.person,
          ),
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
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
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
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
              ),
          ],
        ),
      ),
    );
  }
} 