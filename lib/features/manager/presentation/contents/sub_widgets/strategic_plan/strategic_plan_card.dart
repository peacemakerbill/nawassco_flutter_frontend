import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/strategic_plan_model.dart';
import '../../../../providers/strategic_plan_provider.dart';

class StrategicPlanCard extends ConsumerWidget {
  final StrategicPlan plan;
  final bool showActions;

  const StrategicPlanCard({
    super.key,
    required this.plan,
    this.showActions = true,
  });

  Color _getStatusColor(PlanStatus status) {
    switch (status) {
      case PlanStatus.draft:
        return Colors.grey;
      case PlanStatus.underReview:
        return Colors.orange;
      case PlanStatus.approved:
        return Colors.blue;
      case PlanStatus.active:
        return Colors.green;
      case PlanStatus.completed:
        return Colors.purple;
      case PlanStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PlanStatus status) {
    switch (status) {
      case PlanStatus.draft:
        return Icons.drafts;
      case PlanStatus.underReview:
        return Icons.hourglass_empty;
      case PlanStatus.approved:
        return Icons.verified;
      case PlanStatus.active:
        return Icons.play_arrow;
      case PlanStatus.completed:
        return Icons.check_circle;
      case PlanStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.drafts;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(strategicPlanProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(plan.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => provider.selectPlan(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.fiscalYear,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(plan.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _getStatusColor(plan.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(plan.status),
                          size: 14,
                          color: _getStatusColor(plan.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(plan.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                plan.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Progress and metrics
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Overall Progress',
                          '${plan.overallProgress.toStringAsFixed(1)}%',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricItem(
                          'Goals',
                          '${plan.completedGoals}/${plan.totalGoals}',
                          Icons.flag,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricItem(
                          'Budget',
                          '${plan.budgetUtilization.toStringAsFixed(1)}%',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: plan.overallProgress / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: _getStatusColor(plan.status),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer with dates and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'By ${plan.createdByName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showActions) ...[
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        if (plan.status == PlanStatus.draft)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (plan.status == PlanStatus.draft)
                          const PopupMenuItem(
                            value: 'submit',
                            child: Row(
                              children: [
                                Icon(Icons.send, size: 20),
                                SizedBox(width: 8),
                                Text('Submit for Approval'),
                              ],
                            ),
                          ),
                        if (plan.status == PlanStatus.approved)
                          const PopupMenuItem(
                            value: 'activate',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow, size: 20),
                                SizedBox(width: 8),
                                Text('Activate'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            provider.changeViewMode(ViewMode.edit);
                            break;
                          case 'submit':
                            await provider.submitForApproval(plan.id);
                            break;
                          case 'activate':
                            await provider.activateStrategicPlan(plan.id);
                            break;
                          case 'delete':
                            await _showDeleteDialog(context, ref, plan);
                            break;
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    StrategicPlan plan,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Strategic Plan'),
        content: Text(
          'Are you sure you want to delete "${plan.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(strategicPlanProvider.notifier)
                  .deleteStrategicPlan(plan.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
