import 'package:flutter/material.dart';
import '../../../../models/strategic_plan_model.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final StrategicPlan plan;

  const PerformanceMetricsWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final metrics = plan.performance;

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
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Overall Progress
            _buildOverallProgress(),

            const SizedBox(height: 24),

            // Key Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMetricCard(
                  'Goals Achieved',
                  '${plan.completedGoals}/${plan.totalGoals}',
                  Icons.flag,
                  Colors.green,
                  _calculateGoalCompletionRate(),
                ),
                _buildMetricCard(
                  'KPI Performance',
                  '${(metrics['kpiPerformance'] ?? 0).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.blue,
                  (metrics['kpiPerformance'] ?? 0).toDouble() / 100,
                ),
                _buildMetricCard(
                  'Budget Utilization',
                  '${plan.budgetUtilization.toStringAsFixed(1)}%',
                  Icons.attach_money,
                  Colors.orange,
                  plan.budgetUtilization / 100,
                ),
                _buildMetricCard(
                  'Risk Exposure',
                  '${(metrics['riskExposure'] ?? 0).toStringAsFixed(1)}%',
                  Icons.warning,
                  Colors.red,
                  (metrics['riskExposure'] ?? 0).toDouble() / 100,
                  invert: true,
                ),
                if (_getCrossAxisCount(context) > 2) // Show more metrics on larger screens
                  _buildMetricCard(
                    'Timeline Adherence',
                    '${_calculateTimelineAdherence()}%',
                    Icons.schedule,
                    Colors.purple,
                    _calculateTimelineAdherence() / 100,
                  ),
                if (_getCrossAxisCount(context) > 2)
                  _buildMetricCard(
                    'Resource Efficiency',
                    '${_calculateResourceEfficiency()}%',
                    Icons.engineering,
                    Colors.teal,
                    _calculateResourceEfficiency() / 100,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = plan.overallProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _getProgressColor(progress),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final progressBarWidth = constraints.maxWidth;

            return Stack(
              children: [
                // Background
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // Progress Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  height: 16,
                  width: progress.clamp(0, 100) / 100 * progressBarWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getProgressColor(progress).withOpacity(0.8),
                        _getProgressColor(progress),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // Progress indicators
                Positioned(
                  left: progressBarWidth * 0.25 - 1,
                  child: _buildProgressIndicator(25, progress),
                ),
                Positioned(
                  left: progressBarWidth * 0.5 - 1,
                  child: _buildProgressIndicator(50, progress),
                ),
                Positioned(
                  left: progressBarWidth * 0.75 - 1,
                  child: _buildProgressIndicator(75, progress),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Quarter 1',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Mid Year',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Quarter 3',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'End',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int target, double progress) {
    final isReached = progress >= target;

    return Column(
      children: [
        Container(
          width: 2,
          height: 20,
          color: isReached
              ? _getProgressColor(progress)
              : Colors.grey.shade300,
        ),
        const SizedBox(height: 2),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isReached
                ? _getProgressColor(progress)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double progress, {bool invert = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            // Mini progress bar
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      height: 4,
                      width: progress.clamp(0, 1) * constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  invert ? 'Low' : 'High',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.blue;
    if (progress >= 40) return Colors.orange;
    if (progress >= 20) return Colors.amber;
    return Colors.red;
  }

  double _calculateGoalCompletionRate() {
    if (plan.totalGoals == 0) return 0;
    return (plan.completedGoals / plan.totalGoals) * 100;
  }

  double _calculateTimelineAdherence() {
    final now = DateTime.now();
    final totalDuration = plan.endDate.difference(plan.startDate).inDays;
    final elapsedDuration = now.difference(plan.startDate).inDays;

    if (totalDuration == 0) return 0;
    final expectedProgress = elapsedDuration / totalDuration * 100;
    final variance = (plan.overallProgress - expectedProgress).abs();

    return 100 - variance.clamp(0, 100);
  }

  double _calculateResourceEfficiency() {
    // Simplified calculation based on budget utilization vs progress
    final budgetUtilization = plan.budgetUtilization;
    final progress = plan.overallProgress;

    if (budgetUtilization == 0) return 100;
    return (progress / budgetUtilization * 100).clamp(0, 100);
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}