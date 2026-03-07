import 'package:flutter/material.dart';
import '../../../../models/maintenance_schedule.dart';

class MaintenanceUtils {
  static String formatDuration(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes min';
    } else if (hours == hours.round()) {
      return '${hours.round()} h';
    } else {
      return '${hours.toStringAsFixed(1)} h';
    }
  }

  static String formatCost(double cost) {
    if (cost < 1000) {
      return '\$${cost.toStringAsFixed(2)}';
    } else if (cost < 1000000) {
      return '\$${(cost / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${(cost / 1000000).toStringAsFixed(1)}M';
    }
  }

  static Color getStatusColor(MaintenanceStatus status) {
    return status.color;
  }

  static IconData getStatusIcon(MaintenanceStatus status) {
    return status.icon;
  }

  static String getDueStatusText(
      DateTime nextDueDate, MaintenanceStatus status) {
    final now = DateTime.now();
    final difference = nextDueDate.difference(now);

    if (status == MaintenanceStatus.completed) {
      return 'Completed';
    } else if (status == MaintenanceStatus.cancelled) {
      return 'Cancelled';
    } else if (difference.inDays < 0) {
      return 'Overdue by ${difference.inDays.abs()} days';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays <= 7) {
      return 'Due in ${difference.inDays} days';
    } else if (difference.inDays <= 30) {
      return 'Due in ${(difference.inDays / 7).ceil()} weeks';
    } else {
      return 'Due in ${(difference.inDays / 30).ceil()} months';
    }
  }
}

class MaintenanceStatusBadge extends StatelessWidget {
  final MaintenanceStatus status;
  final bool compact;

  const MaintenanceStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: compact ? 10 : 12,
            color: status.color,
          ),
          if (!compact) const SizedBox(width: 4),
          Text(
            compact ? status.displayName[0] : status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityIndicator extends StatelessWidget {
  final PriorityLevel priority;
  final double size;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.size = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: 24,
      decoration: BoxDecoration(
        color: priority.color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}
