import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final IconData? icon;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.icon,
    this.small = false,
  });

  factory StatusBadge.fromAppraisalStatus(String statusValue, {bool small = false}) {
    final status = statusValue.toLowerCase().replaceAll('_', '');
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'draft':
        color = Colors.grey;
        icon = Icons.drafts;
        label = 'Draft';
        break;
      case 'underreview':
        color = Colors.orange;
        icon = Icons.reviews;
        label = 'Under Review';
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      case 'acknowledged':
        color = Colors.green;
        icon = Icons.verified;
        label = 'Acknowledged';
        break;
      case 'closed':
        color = Colors.purple;
        icon = Icons.archive;
        label = 'Closed';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = statusValue;
    }

    return StatusBadge(
      status: label,
      color: color,
      icon: icon,
      small: small,
    );
  }

  factory StatusBadge.performanceLevel(String level, {bool small = false}) {
    Color color;
    IconData icon;
    String label;

    switch (level.toLowerCase()) {
      case 'exceeds_expectations':
        color = Colors.green;
        icon = Icons.star;
        label = 'Exceeds Expectations';
        break;
      case 'meets_expectations':
        color = Colors.blue;
        icon = Icons.check_circle;
        label = 'Meets Expectations';
        break;
      case 'needs_improvement':
        color = Colors.orange;
        icon = Icons.warning;
        label = 'Needs Improvement';
        break;
      case 'unsatisfactory':
        color = Colors.red;
        icon = Icons.error;
        label = 'Unsatisfactory';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = level;
    }

    return StatusBadge(
      status: label,
      color: color,
      icon: icon,
      small: small,
    );
  }

  factory StatusBadge.potentialLevel(String level, {bool small = false}) {
    Color color;
    IconData icon;
    String label;

    switch (level.toLowerCase()) {
      case 'high_potential':
        color = Colors.purple;
        icon = Icons.rocket_launch;
        label = 'High Potential';
        break;
      case 'growth_potential':
        color = Colors.blue;
        icon = Icons.trending_up;
        label = 'Growth Potential';
        break;
      case 'steady_performer':
        color = Colors.green;
        icon = Icons.timeline;
        label = 'Steady Performer';
        break;
      case 'plateaued':
        color = Colors.grey;
        icon = Icons.pause_circle;
        label = 'Plateaued';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = level;
    }

    return StatusBadge(
      status: label,
      color: color,
      icon: icon,
      small: small,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = small
        ? TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: color,
    )
        : TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
    );

    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(small ? 10 : 16),
        border: Border.all(
          color: color ?? Colors.grey,
          width: small ? 0.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: small ? 10 : 14,
              color: color,
            ),
          if (icon != null) SizedBox(width: small ? 4 : 6),
          Text(
            status,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}