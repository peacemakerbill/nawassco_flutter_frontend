import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Customer Complaints Content',
          style: TextStyle(fontSize: 18, color: AdminColors.textSecondary),
        ),
      ),
    );
  }
}