import 'package:flutter/material.dart';

import '../../../../../models/employee_model.dart';

class QualificationCard extends StatelessWidget {
  final Qualification qualification;

  const QualificationCard({super.key, required this.qualification});

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(qualification.level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              color: levelColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qualification.field,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  qualification.institution,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        qualification.level.toString().split('.').last.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 10,
                          color: levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Year: ${qualification.yearCompleted}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(QualificationLevel level) {
    switch (level) {
      case QualificationLevel.high_school:
        return Colors.blue;
      case QualificationLevel.diploma:
        return Colors.green;
      case QualificationLevel.bachelors:
        return Colors.orange;
      case QualificationLevel.masters:
        return Colors.purple;
      case QualificationLevel.doctorate:
        return Colors.red;
      case QualificationLevel.professional:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}