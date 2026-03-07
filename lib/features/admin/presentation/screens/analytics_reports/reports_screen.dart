import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
              'Reports Generation Content',
              style: TextStyle(fontSize: 18, color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}