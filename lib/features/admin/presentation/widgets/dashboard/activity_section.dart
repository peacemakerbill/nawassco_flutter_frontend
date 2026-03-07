import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';
import 'activity_item.dart';

class ActivitySection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const ActivitySection({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _buildRecentActivity(isMobile),
          SizedBox(height: 16),
          _buildWaterProduction(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildRecentActivity(isMobile),
          ),
          SizedBox(width: isTablet ? 16 : 24),
          Expanded(
            flex: 1,
            child: _buildWaterProduction(isMobile),
          ),
        ],
      );
    }
  }

  Widget _buildRecentActivity(bool isMobile) {
    final activities = [
      {'action': 'New user registration', 'time': '2 mins ago', 'user': 'John Doe'},
      {'action': 'Payment received', 'time': '15 mins ago', 'amount': 'KES 1,250'},
      {'action': 'Service request submitted', 'time': '1 hour ago', 'type': 'Leak Repair'},
      {'action': 'Meter reading updated', 'time': '2 hours ago', 'zone': 'Zone A'},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ...activities.map((activity) => ActivityItem(activity: activity, isMobile: isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterProduction(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Production',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Container(
              height: isMobile ? 150 : 200,
              decoration: BoxDecoration(
                border: Border.all(color: AdminColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: AdminColors.primary),
                    SizedBox(height: 8),
                    Text('Production Chart', style: TextStyle(color: AdminColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}