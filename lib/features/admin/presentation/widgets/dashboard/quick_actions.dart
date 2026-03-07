import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  final Function(String) navigateTo;
  final bool isMobile;
  final bool isTablet;

  const QuickActionsSection({
    super.key,
    required this.navigateTo,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'User Management',
        'icon': Icons.people,
        'route': '/admin/users',
        'color': AdminColors.primary,
      },
      {
        'title': 'Billing & Revenue',
        'icon': Icons.receipt_long,
        'route': '/admin/controller',
        'color': AdminColors.success,
      },
      {
        'title': 'Water Operations',
        'icon': Icons.water_drop,
        'route': '/admin/operations',
        'color': AdminColors.info,
      },
      {
        'title': 'Service Requests',
        'icon': Icons.support_agent,
        'route': '/admin/services',
        'color': AdminColors.warning,
      },
    ];

    final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
    final childAspectRatio = isMobile ? 1.3 : (isTablet ? 1.2 : 1.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: childAspectRatio,
          children: actions.map((action) {
            return QuickActionCard(
              title: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: () => navigateTo(action['route'] as String),
              isMobile: isMobile,
            );
          }).toList(),
        ),
      ],
    );
  }
}