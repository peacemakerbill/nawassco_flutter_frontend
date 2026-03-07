import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class WaterQualityScreen extends StatelessWidget {
  const WaterQualityScreen({super.key});

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
              'Water Quality Monitoring Content',
              style: TextStyle(fontSize: 18, color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}