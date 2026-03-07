import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/consultancy_model.dart';

class ConsultancyStatsChart extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ConsultancyStatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final statusCounts = (stats['statusCounts'] as List?) ?? [];
    final totalConsultancies = stats['totalConsultancies'] ?? 0;

    if (statusCounts.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No statistics available'),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            child: PieChart(
              PieChartData(
                sections: statusCounts.map((item) {
                  final status = ConsultancyStatus.values.firstWhere(
                        (e) => describeEnum(e).toLowerCase() == item['status'],
                    orElse: () => ConsultancyStatus.PROPOSAL,
                  );
                  final count = item['count'] ?? 0;
                  final percentage = totalConsultancies > 0
                      ? (count / totalConsultancies)
                      : 0;

                  return PieChartSectionData(
                    value: count.toDouble(),
                    color: status.statusColor,
                    title: '${(percentage * 100).toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),

          // Legend
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: statusCounts.length,
              itemBuilder: (context, index) {
                final item = statusCounts[index];
                final status = ConsultancyStatus.values.firstWhere(
                      (e) => describeEnum(e).toLowerCase() == item['status'],
                  orElse: () => ConsultancyStatus.PROPOSAL,
                );
                final count = item['count'] ?? 0;
                final percentage = totalConsultancies > 0
                    ? (count / totalConsultancies) * 100
                    : 0;

                return ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    status.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        count.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}