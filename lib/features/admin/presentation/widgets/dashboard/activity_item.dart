import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class ActivityItem extends StatelessWidget {
  final Map<String, String> activity;
  final bool isMobile;

  const ActivityItem({
    super.key,
    required this.activity,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AdminColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AdminColors.textPrimary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                if (activity['user'] != null ||
                    activity['amount'] != null ||
                    activity['type'] != null ||
                    activity['zone'] != null)
                  Text(
                    activity['user'] ??
                        activity['amount'] ??
                        activity['type'] ??
                        activity['zone'] ??
                        '',
                    style: TextStyle(
                      color: AdminColors.textSecondary,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: TextStyle(
              color: AdminColors.textLight,
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}