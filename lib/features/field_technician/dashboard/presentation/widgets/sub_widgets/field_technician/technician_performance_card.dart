import 'package:flutter/material.dart';
import '../../../../models/field_technician.dart';

class TechnicianPerformanceCard extends StatelessWidget {
  final FieldTechnician technician;

  const TechnicianPerformanceCard({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: technician.performanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: technician.performanceColor),
                  ),
                  child: Text(
                    technician.performanceLevel,
                    style: TextStyle(
                      color: technician.performanceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Overall Performance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Performance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${technician.performanceScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: technician.performanceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: technician.performanceScore / 100,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  color: technician.performanceColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Performance Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.5 : 1.2,
              children: [
                _buildPerformanceMetric(
                  'Jobs Completed',
                  '${technician.jobsCompleted}',
                  Icons.assignment_turned_in_rounded,
                  Colors.green,
                ),
                _buildPerformanceMetric(
                  'On-Time Rate',
                  '${technician.onTimeCompletionRate.toStringAsFixed(1)}%',
                  Icons.timer_rounded,
                  Colors.blue,
                ),
                _buildPerformanceMetric(
                  'Customer Satisfaction',
                  '${technician.customerSatisfaction.toStringAsFixed(1)}%',
                  Icons.star_rounded,
                  Colors.orange,
                ),
                _buildPerformanceMetric(
                  'First-Time Fix Rate',
                  '${technician.firstTimeFixRate.toStringAsFixed(1)}%',
                  Icons.build_rounded,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
