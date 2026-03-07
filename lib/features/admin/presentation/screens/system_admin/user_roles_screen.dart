import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserRolesScreen extends StatelessWidget {
  const UserRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 24 : 16,
            vertical: constraints.maxWidth > 600 ? 24 : 16,
          ),
          child: const Center(
            child: Text(
              'User Roles Management Content',
              style: TextStyle(fontSize: 18, color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}