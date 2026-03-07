import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserStatusChip extends StatelessWidget {
  final String status;
  final bool isActive;

  const UserStatusChip({
    super.key,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (status.toLowerCase()) {
        case 'active':
          return AdminColors.success;
        case 'inactive':
          return AdminColors.error;
        case 'pending':
          return AdminColors.warning;
        case 'verified':
          return AdminColors.info;
        default:
          return AdminColors.textSecondary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getColor().withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}