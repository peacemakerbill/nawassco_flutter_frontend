import 'package:flutter/material.dart';

import '../../../models/consultancy_model.dart';

class StatusChip extends StatelessWidget {
  final ConsultancyStatus status;
  final bool showIcon;

  const StatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              status.statusIcon,
              size: 14,
              color: status.statusColor,
            ),
          if (showIcon) const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}