import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/employee_model.dart';

class EmploymentHistoryCard extends StatelessWidget {
  final EmploymentHistory history;

  const EmploymentHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    final duration = history.endDate.difference(history.startDate);
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                history.company,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${years > 0 ? '$years yrs ' : ''}$months mos',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            history.jobTitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${dateFormat.format(history.startDate)} - ${dateFormat.format(history.endDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (history.reasonForLeaving.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${history.reasonForLeaving}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}