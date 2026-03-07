import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final double? size;
  final bool showText;
  final bool dense;

  const StatusBadge({
    super.key,
    required this.status,
    this.size,
    this.showText = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    if (dense) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size ?? 10,
            height: size ?? 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 6),
            Text(
              statusText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.APPLIED:
      case ApplicationStatus.UNDER_REVIEW:
      case ApplicationStatus.SCREENING:
        return Colors.blue;
      case ApplicationStatus.SHORTLISTED:
      case ApplicationStatus.INTERVIEW_SCHEDULED:
      case ApplicationStatus.INTERVIEW_IN_PROGRESS:
        return Colors.orange;
      case ApplicationStatus.INTERVIEW_COMPLETED:
      case ApplicationStatus.TECHNICAL_ASSESSMENT:
      case ApplicationStatus.BACKGROUND_CHECK:
      case ApplicationStatus.REFERENCE_CHECK:
        return Colors.purple;
      case ApplicationStatus.SELECTED:
      case ApplicationStatus.OFFER_PENDING:
      case ApplicationStatus.OFFER_EXTENDED:
        return Colors.green;
      case ApplicationStatus.OFFER_ACCEPTED:
        return Colors.green.shade800;
      case ApplicationStatus.OFFER_DECLINED:
        return Colors.red;
      case ApplicationStatus.REJECTED:
        return Colors.red.shade800;
      case ApplicationStatus.WITHDRAWN:
        return Colors.grey;
      case ApplicationStatus.ON_HOLD:
        return Colors.amber;
      case ApplicationStatus.ARCHIVED:
        return Colors.grey.shade600;
      case ApplicationStatus.DRAFT:
        return Colors.grey.shade400;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    final statusName = status.name.toLowerCase();
    return statusName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
