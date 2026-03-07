import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../../../../models/strategic_plan_model.dart';
import '../../../../providers/strategic_plan_provider.dart';
import 'goal_progress_widget.dart';
import 'initiative_timeline_widget.dart';
import 'performance_metrics_widget.dart';
import 'budget_allocation_widget.dart';
import 'risk_assessment_widget.dart';

class StrategicPlanDetails extends ConsumerWidget {
  final StrategicPlan plan;

  const StrategicPlanDetails({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(strategicPlanProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => provider.clearSelection(),
            ),
            actions: [
              if (plan.status == PlanStatus.draft)
                IconButton(
                  onPressed: () => provider.changeViewMode(ViewMode.edit),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Plan',
                ),
              if (plan.status == PlanStatus.draft)
                IconButton(
                  onPressed: () async {
                    await provider.submitForApproval(plan.id);
                  },
                  icon: const Icon(Icons.send),
                  tooltip: 'Submit for Approval',
                ),
              if (plan.status == PlanStatus.approved)
                IconButton(
                  onPressed: () async {
                    await provider.activateStrategicPlan(plan.id);
                  },
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Activate Plan',
                ),
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text('Export as PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  if (plan.status == PlanStatus.draft)
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
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      // Implement export functionality
                      break;
                    case 'share':
                      // Implement share functionality
                      break;
                    case 'delete':
                      _showDeleteDialog(context, ref, plan);
                      break;
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(plan.status).withValues(alpha: 0.8),
                      _getStatusColor(plan.status).withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          plan.status.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(plan.status),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Card
                  Card(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overview',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      plan.description,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    plan.fiscalYear,
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(plan.status),
                                    ),
                                  ),
                                  Text(
                                    plan.planningCycle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Vision & Mission
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildVisionMissionCard(
                                  'Vision',
                                  plan.visionStatement,
                                  Icons.visibility,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildVisionMissionCard(
                                  'Mission',
                                  plan.missionStatement,
                                  Icons.flag,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Timeline
                          _buildTimelineSection(),

                          const SizedBox(height: 24),

                          // Created By & Approved By
                          Row(
                            children: [
                              Expanded(
                                child: _buildPersonCard(
                                  'Created By',
                                  plan.createdByName,
                                  plan.createdAt,
                                  Icons.person_add,
                                  Colors.blue.shade100,
                                ),
                              ),
                              if (plan.approvedByName != null) ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPersonCard(
                                    'Approved By',
                                    plan.approvedByName!,
                                    plan.approvalDate!,
                                    Icons.verified,
                                    Colors.green.shade100,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Performance Metrics
                  PerformanceMetricsWidget(plan: plan),

                  const SizedBox(height: 24),

                  // Strategic Goals
                  GoalProgressWidget(plan: plan),

                  const SizedBox(height: 24),

                  // Budget Allocation
                  BudgetAllocationWidget(plan: plan),

                  const SizedBox(height: 24),

                  // Strategic Initiatives
                  InitiativeTimelineWidget(plan: plan),

                  const SizedBox(height: 24),

                  // Risk Assessment
                  RiskAssessmentWidget(plan: plan),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionMissionCard(
      String title, String content, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    final now = DateTime.now();
    final totalDays = plan.endDate.difference(plan.startDate).inDays;
    final elapsedDays = now.difference(plan.startDate).inDays;
    final progress = elapsedDays / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            // Timeline background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 8,
              width: MediaQuery.of(context as BuildContext).size.width *
                  progress.clamp(0, 1),
              decoration: BoxDecoration(
                color: _getStatusColor(plan.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Current position indicator
            Positioned(
              left: MediaQuery.of(context as BuildContext).size.width *
                      progress.clamp(0, 1) -
                  4,
              top: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getStatusColor(plan.status),
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(plan.startDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'End Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(plan.endDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonCard(
      String title, String name, DateTime date, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, StrategicPlan plan) {
    showDialog(
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
