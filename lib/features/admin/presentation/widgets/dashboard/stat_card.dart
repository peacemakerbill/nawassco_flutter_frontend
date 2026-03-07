import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isMobile;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: isMobile ? 20 : 24),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend.startsWith('+')
                        ? AdminColors.success
                        : trend.startsWith('-')
                        ? AdminColors.error
                        : AdminColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AdminColors.textSecondary,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}