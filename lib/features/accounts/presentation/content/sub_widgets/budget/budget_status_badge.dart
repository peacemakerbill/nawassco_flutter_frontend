import 'package:flutter/material.dart';
import '../../../../models/budget_model.dart';

class BudgetStatusBadge extends StatelessWidget {
  final BudgetStatus status;
  final bool compact;
  final bool showIcon;

  const BudgetStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _getStatusProperties(status);

    if (compact) {
      return Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon)
                Icon(
                  icon,
                  color: color,
                  size: 12,
                ),
              if (showIcon) const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(icon, color: color, size: 14),
          if (showIcon) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getStatusProperties(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.draft:
        return (Colors.blue, 'Draft', Icons.edit);
      case BudgetStatus.under_review:
        return (Colors.orange, 'Under Review', Icons.hourglass_empty);
      case BudgetStatus.approved:
        return (Colors.green, 'Approved', Icons.check_circle);
      case BudgetStatus.rejected:
        return (Colors.red, 'Rejected', Icons.cancel);
      case BudgetStatus.closed:
        return (Colors.grey, 'Closed', Icons.lock);
    }
  }
}