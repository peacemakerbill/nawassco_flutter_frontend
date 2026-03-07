import 'package:flutter/material.dart';
import '../../../../../../models/performance/development_plan.model.dart';

class DevelopmentPlanView extends StatelessWidget {
  final List<DevelopmentPlan> developmentPlans;
  final bool showActions;

  const DevelopmentPlanView({
    super.key,
    required this.developmentPlans,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    if (developmentPlans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Development Plans',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Development plans will be created after performance reviews',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: developmentPlans.length,
      itemBuilder: (context, index) {
        final plan = developmentPlans[index];
        return _buildDevelopmentPlanCard(plan, index);
      },
    );
  }

  Widget _buildDevelopmentPlanCard(DevelopmentPlan plan, int index) {
    final isOverdue = plan.timeline.isBefore(DateTime.now());
    final daysRemaining = plan.timeline.difference(DateTime.now()).inDays;
    final status = isOverdue ? 'Overdue' : daysRemaining <= 7 ? 'Urgent' : 'On Track';
    final statusColor = isOverdue ? Colors.red : daysRemaining <= 7 ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.developmentArea,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.actionPlan,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700]!,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.assignment,
              label: 'Resources',
              value: plan.resources,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Timeline',
              value: _formatDate(plan.timeline),
            ),
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Edit action
                      },
                      child: const Text('Edit Plan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark as complete action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Complete'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0) {
      return 'In ${difference.inDays} days (${date.day}/${date.month}/${date.year})';
    } else {
      return '${difference.inDays.abs()} days ago (${date.day}/${date.month}/${date.year})';
    }
  }
}