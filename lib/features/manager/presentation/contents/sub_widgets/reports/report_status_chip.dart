import 'package:flutter/material.dart';

import '../../../../models/reports/management_report_model.dart';

class ReportStatusChip extends StatelessWidget {
  final ReportStatus status;
  final bool large;

  const ReportStatusChip({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(large ? 20 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: large ? 18 : 14,
            color: status.color,
          ),
          if (large) const SizedBox(width: 8),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: large ? 14 : 12,
              fontWeight: large ? FontWeight.w600 : FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
