import 'package:flutter/material.dart';

import '../../../../models/maintenance_schedule.dart';

class MaintenanceScheduleCard extends StatelessWidget {
  final MaintenanceSchedule schedule;
  final VoidCallback onTap;

  const MaintenanceScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Priority Indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: schedule.priority.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.scheduleNumber,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: schedule.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(schedule.status.icon,
                            size: 12, color: schedule.status.color),
                        const SizedBox(width: 4),
                        Text(
                          schedule.status.displayName,
                          style: TextStyle(
                            color: schedule.status.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Details Row
              Row(
                children: [
                  // Target Type
                  Row(
                    children: [
                      Icon(schedule.targetType.icon,
                          size: 16, color: schedule.targetType.color),
                      const SizedBox(width: 4),
                      Text(schedule.targetType.displayName),
                    ],
                  ),
                  const Spacer(),
                  // Schedule Type
                  Row(
                    children: [
                      Icon(schedule.scheduleType.icon,
                          size: 16, color: schedule.scheduleType.color),
                      const SizedBox(width: 4),
                      Text(schedule.scheduleType.displayName),
                    ],
                  ),
                  const Spacer(),
                  // Frequency
                  Row(
                    children: [
                      Icon(schedule.frequency.icon,
                          size: 16, color: schedule.frequency.color),
                      const SizedBox(width: 4),
                      Text(schedule.frequency.displayName),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress and Due Date
              Row(
                children: [
                  // Progress
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress: ${schedule.completionRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: schedule.completionRate / 100,
                          backgroundColor: Colors.grey[200],
                          color: _getProgressColor(schedule.completionRate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Due Date
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: schedule.dueStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text(
                            schedule.dueStatus,
                            style: TextStyle(
                              color: schedule.dueStatusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${schedule.daysUntilDue.abs()}d',
                            style: TextStyle(
                              color: schedule.dueStatusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Assigned Technicians
              if (schedule.assignedTo.isNotEmpty) ...[
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    ...schedule.assignedTo
                        .take(3)
                        .map((tech) => Chip(
                              label: Text(tech),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                    if (schedule.assignedTo.length > 3)
                      Chip(
                        label: Text('+${schedule.assignedTo.length - 3}'),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }
}
