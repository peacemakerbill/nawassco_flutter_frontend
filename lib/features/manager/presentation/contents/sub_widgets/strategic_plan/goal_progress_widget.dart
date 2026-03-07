import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/strategic_plan_model.dart';
import '../../../../providers/strategic_plan_provider.dart';

class GoalProgressWidget extends ConsumerWidget {
  final StrategicPlan plan;

  const GoalProgressWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(strategicPlanProvider.notifier);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Strategic Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (plan.status == PlanStatus.active ||
                    plan.status == PlanStatus.underReview)
                  IconButton(
                    onPressed: () => _showAddGoalDialog(context, ref, plan.id),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Goal',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (plan.strategicGoals.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.flag, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No strategic goals defined yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: plan.strategicGoals.map((goal) {
                  return _buildGoalItem(context, ref, goal, plan.id);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(
      BuildContext context, WidgetRef ref, StrategicGoal goal, String planId) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(goal.status).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(goal.status).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(goal.status),
                    size: 20,
                    color: _getStatusColor(goal.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (plan.status == PlanStatus.active)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'update_progress',
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, size: 18),
                            SizedBox(width: 8),
                            Text('Update Progress'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'update_progress') {
                        _showUpdateProgressDialog(context, ref, planId, goal);
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.progress.toStringAsFixed(1)}% Complete',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(goal.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(goal.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: goal.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: _getStatusColor(goal.status),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                _buildDetailItem(
                  Icons.category,
                  goal.category,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildDetailItem(
                  Icons.priority_high,
                  'Priority ${goal.priority}',
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildDetailItem(
                  Icons.person,
                  goal.ownerName,
                  Colors.green,
                ),
                const Spacer(),
                _buildDetailItem(
                  Icons.calendar_today,
                  '${_formatDate(goal.endDate)}',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return Colors.grey;
      case GoalStatus.inProgress:
        return Colors.blue;
      case GoalStatus.atRisk:
        return Colors.orange;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.delayed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return Icons.access_time;
      case GoalStatus.inProgress:
        return Icons.play_arrow;
      case GoalStatus.atRisk:
        return Icons.warning;
      case GoalStatus.completed:
        return Icons.check_circle;
      case GoalStatus.delayed:
        return Icons.schedule;
      default:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inDays < 0) {
      return '${difference.inDays.abs()}d overdue';
    } else {
      return 'Due today';
    }
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref, String planId) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        final categoryController = TextEditingController();
        final priorityController = TextEditingController(text: '1');

        return AlertDialog(
          title: const Text('Add Strategic Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: priorityController,
                        decoration: const InputDecoration(
                          labelText: 'Priority (1-10)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
                  return;
                }

                final goal = StrategicGoal(
                  id: '',
                  goalNumber: 'G${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  priority: int.tryParse(priorityController.text) ?? 1,
                  progress: 0,
                  status: GoalStatus.notStarted,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 180)),
                  ownerId: '',
                  ownerName: '',
                  dependencies: [],
                  metrics: {},
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await ref
                    .read(strategicPlanProvider.notifier)
                    .addStrategicGoal(planId, goal);
                Navigator.pop(context);
              },
              child: const Text('Add Goal'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateProgressDialog(
      BuildContext context, WidgetRef ref, String planId, StrategicGoal goal) {
    double progress = goal.progress;
    GoalStatus status = goal.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Goal Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Progress Slider
                  Column(
                    children: [
                      Text(
                        'Progress: ${progress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: progress,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: progress.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            progress = value;
                            // Auto-update status based on progress
                            if (value >= 100) {
                              status = GoalStatus.completed;
                            } else if (value > 0) {
                              status = GoalStatus.inProgress;
                            } else {
                              status = GoalStatus.notStarted;
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status Selector
                  DropdownButtonFormField<GoalStatus>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: GoalStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(strategicPlanProvider.notifier)
                        .updateGoalProgress(
                          planId,
                          goal.goalNumber,
                          progress,
                          status,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
