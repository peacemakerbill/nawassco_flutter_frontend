// lib/features/work_orders/presentation/widgets/work_order_stats.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/work_order_provider.dart';

class WorkOrderStats extends ConsumerWidget {
  const WorkOrderStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrderState = ref.watch(workOrderProvider);
    final workOrders = workOrderState.workOrders;

    final total = workOrders.length;
    final completed =
        workOrders.where((wo) => wo.status.displayName == 'Completed').length;
    final inProgress =
        workOrders.where((wo) => wo.status.displayName == 'In Progress').length;
    final overdue = workOrders.where((wo) => wo.isOverdue).length;
    final highPriority = workOrders
        .where((wo) =>
            wo.priority.displayName == 'High' ||
            wo.priority.displayName == 'Urgent')
        .length;

    final completionRate = total > 0 ? (completed / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final stats = [
                _buildStatItem('Total', total, Icons.assignment, Colors.blue),
                _buildStatItem(
                    'Completed', completed, Icons.check_circle, Colors.green),
                _buildStatItem(
                    'In Progress', inProgress, Icons.play_arrow, Colors.orange),
                _buildStatItem('Overdue', overdue, Icons.warning, Colors.red),
                _buildStatItem('High Priority', highPriority,
                    Icons.priority_high, Colors.purple),
              ];

              return isWide
                  ? Row(
                      children: stats
                          .expand((stat) => [stat, const SizedBox(width: 16)])
                          .take(stats.length * 2 - 1)
                          .toList(),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stats,
                    );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: completionRate / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[200],
                              color: _getCompletionColor(completionRate),
                            ),
                          ),
                          Text(
                            '$completionRate%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Completion Rate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildMetricRow(
                        'Avg. Time',
                        '${_calculateAverageTime(workOrders)}',
                        Icons.access_time),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                        'Urgent Today',
                        '${_calculateUrgentToday(workOrders)}',
                        Icons.priority_high),
                    const SizedBox(height: 8),
                    _buildMetricRow('Due Today',
                        '${_calculateDueToday(workOrders)}', Icons.today),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int rate) {
    if (rate < 40) return Colors.red;
    if (rate < 70) return Colors.orange;
    return Colors.green;
  }

  String _calculateAverageTime(List<WorkOrder> workOrders) {
    if (workOrders.isEmpty) return '0h 0m';

    final totalMinutes =
        workOrders.fold<int>(0, (sum, wo) => sum + wo.estimatedDuration);
    final averageMinutes = totalMinutes ~/ workOrders.length;

    final hours = averageMinutes ~/ 60;
    final minutes = averageMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  int _calculateUrgentToday(List<WorkOrder> workOrders) {
    final now = DateTime.now();
    return workOrders.where((wo) {
      final isUrgent = wo.priority.displayName == 'Urgent' ||
          wo.priority.displayName == 'High';
      final isToday = wo.scheduledDate.day == now.day &&
          wo.scheduledDate.month == now.month &&
          wo.scheduledDate.year == now.year;
      return isUrgent && isToday;
    }).length;
  }

  int _calculateDueToday(List<WorkOrder> workOrders) {
    final now = DateTime.now();
    return workOrders.where((wo) {
      return wo.scheduledDate.day == now.day &&
          wo.scheduledDate.month == now.month &&
          wo.scheduledDate.year == now.year;
    }).length;
  }
}
