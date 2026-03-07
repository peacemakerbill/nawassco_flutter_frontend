import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/strategic_plan_model.dart';
import '../../../../providers/strategic_plan_provider.dart';

class InitiativeTimelineWidget extends ConsumerWidget {
  final StrategicPlan plan;

  const InitiativeTimelineWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initiatives = plan.strategicInitiatives;

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
                    'Strategic Initiatives',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (plan.status == PlanStatus.active)
                  IconButton(
                    onPressed: () =>
                        _showAddInitiativeDialog(context, ref, plan.id),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Initiative',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Timeline and progress of key initiatives',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (initiatives.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.timeline, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No strategic initiatives defined yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Initiatives are the actionable projects that drive goal achievement',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Timeline Header
                  _buildTimelineHeader(),

                  const SizedBox(height: 20),

                  // Initiatives List
                  ...initiatives.map((initiative) {
                    return _buildInitiativeCard(
                        context, ref, initiative, plan.id);
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineHeader() {
    final months = _getTimelineMonths();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Month labels
          Row(
            children: months.map((month) {
              return Expanded(
                child: Text(
                  month,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Timeline bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitiativeCard(BuildContext context, WidgetRef ref,
      StrategicInitiative initiative, String planId) {
    final now = DateTime.now();
    final totalDays =
        initiative.endDate.difference(initiative.startDate).inDays;
    final elapsedDays = now.difference(initiative.startDate).inDays;
    final progress = elapsedDays / totalDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                    color: _getStatusColor(initiative.status)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(initiative.status),
                    size: 20,
                    color: _getStatusColor(initiative.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        initiative.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        initiative.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
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
                    ],
                    onSelected: (value) {
                      if (value == 'update_progress') {
                        _showUpdateInitiativeDialog(
                            context, ref, planId, initiative);
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress and Timeline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${initiative.progress.toStringAsFixed(1)}%',
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
                        color: _getStatusColor(initiative.status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        initiative.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(initiative.status),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                LinearProgressIndicator(
                  value: initiative.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: _getStatusColor(initiative.status),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),

                const SizedBox(height: 16),

                // Timeline Visualization
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Elapsed time
                    Container(
                      height: 6,
                      width: progress.clamp(0, 1) *
                          (MediaQuery.of(context).size.width - 64),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Progress indicator
                    Positioned(
                      left: (initiative.progress / 100).clamp(0, 1) *
                              (MediaQuery.of(context).size.width - 64) -
                          6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getStatusColor(initiative.status),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Start and end markers
                    Positioned(
                      left: 0,
                      top: -4,
                      child: Column(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _formatDateShort(initiative.startDate),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      right: 0,
                      top: -4,
                      child: Column(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'End',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _formatDateShort(initiative.endDate),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Budget and Owner
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.attach_money,
                      'Budget: \$${initiative.budget.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildDetailItem(
                      Icons.person,
                      'Owner: ${initiative.ownerName}',
                      Colors.blue,
                    ),
                    const Spacer(),
                    _buildDetailItem(
                      Icons.calendar_today,
                      '${_calculateDaysRemaining(initiative.endDate)} days left',
                      Colors.orange,
                    ),
                  ],
                ),

                if (initiative.milestones.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  // Milestones
                  Text(
                    'Key Milestones',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: initiative.milestones.map((milestone) {
                      return Chip(
                        label: Text(milestone['name'] ?? ''),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(color: Colors.blue),
                      );
                    }).toList(),
                  ),
                ],
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

  Color _getStatusColor(InitiativeStatus status) {
    switch (status) {
      case InitiativeStatus.planning:
        return Colors.grey;
      case InitiativeStatus.execution:
        return Colors.blue;
      case InitiativeStatus.monitoring:
        return Colors.orange;
      case InitiativeStatus.completed:
        return Colors.green;
      case InitiativeStatus.delayed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(InitiativeStatus status) {
    switch (status) {
      case InitiativeStatus.planning:
        return Icons.list_alt;
      case InitiativeStatus.execution:
        return Icons.play_arrow;
      case InitiativeStatus.monitoring:
        return Icons.monitor;
      case InitiativeStatus.completed:
        return Icons.check_circle;
      case InitiativeStatus.delayed:
        return Icons.schedule;
      default:
        return Icons.work;
    }
  }

  List<String> _getTimelineMonths() {
    final months = <String>[];
    final now = DateTime.now();

    for (int i = -3; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add(_getMonthAbbreviation(date.month));
    }

    return months;
  }

  String _getMonthAbbreviation(int month) {
    const abbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return abbreviations[month - 1];
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  int _calculateDaysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  void _showAddInitiativeDialog(
      BuildContext context, WidgetRef ref, String planId) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        final budgetController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Strategic Initiative'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Initiative Title',
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
                TextFormField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
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

                final initiative = StrategicInitiative(
                  id: '',
                  initiativeNumber: 'I${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text,
                  description: descriptionController.text,
                  goalId: '',
                  progress: 0,
                  status: InitiativeStatus.planning,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 180)),
                  ownerId: '',
                  ownerName: '',
                  budget: double.tryParse(budgetController.text) ?? 0,
                  spent: 0,
                  phases: [],
                  resources: [],
                  milestones: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await ref
                    .read(strategicPlanProvider.notifier)
                    .addStrategicInitiative(planId, initiative);
                Navigator.pop(context);
              },
              child: const Text('Add Initiative'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateInitiativeDialog(BuildContext context, WidgetRef ref,
      String planId, StrategicInitiative initiative) {
    double progress = initiative.progress;
    InitiativeStatus status = initiative.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Initiative Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    initiative.title,
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
                              status = InitiativeStatus.completed;
                            } else if (value >= 80) {
                              status = InitiativeStatus.monitoring;
                            } else if (value > 0) {
                              status = InitiativeStatus.execution;
                            } else {
                              status = InitiativeStatus.planning;
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status Selector
                  DropdownButtonFormField<InitiativeStatus>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: InitiativeStatus.values.map((status) {
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

                  const SizedBox(height: 20),

                  // Budget Update
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Amount Spent',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
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
                        .updateInitiativeProgress(
                          planId,
                          initiative.initiativeNumber,
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
