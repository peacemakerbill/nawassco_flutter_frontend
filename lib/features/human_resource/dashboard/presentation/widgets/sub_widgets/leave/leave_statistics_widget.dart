import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../providers/leave_provider.dart';

class LeaveStatisticsWidget extends ConsumerWidget {
  const LeaveStatisticsWidget({super.key});

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(leaveProvider).statistics;

    if (statistics == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final chartData = statistics.leaveTypeStats.map((stat) {
      return {
        'type': stat.leaveType.split('_').map((word) {
          return word[0].toUpperCase() + word.substring(1);
        }).join(' '),
        'count': stat.count,
      };
    }).toList();

    final departmentData = statistics.departmentStats.map((stat) {
      return {
        'department': stat.department,
        'count': stat.count,
      };
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            children: [
              _buildStatCard(
                'Total Applications',
                statistics.totalApplications.toString(),
                const Color(0xFF3B82F6),
                Icons.list_alt,
              ),
              _buildStatCard(
                'Pending Reviews',
                statistics.pendingApplications.toString(),
                const Color(0xFFF59E0B),
                Icons.pending,
              ),
              _buildStatCard(
                'Approved This Month',
                statistics.approvedThisMonth.toString(),
                const Color(0xFF10B981),
                Icons.check_circle,
              ),
              _buildStatCard(
                'Approval Rate',
                statistics.formattedApprovalRate,
                const Color(0xFF8B5CF6),
                Icons.trending_up,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Leave Type Distribution
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leave Type Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        DoughnutSeries<Map<String, dynamic>, String>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data['type'],
                          yValueMapper: (data, _) => data['count'],
                          dataLabelMapper: (data, _) =>
                              '${data['type']}\n${data['count']}',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(fontSize: 12),
                          ),
                          radius: '70%',
                          innerRadius: '60%',
                        ),
                      ],
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Department Statistics
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Applications by Department',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      primaryYAxis: const NumericAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      series: <BarSeries<Map<String, dynamic>, String>>[
                        BarSeries<Map<String, dynamic>, String>(
                          dataSource: departmentData,
                          xValueMapper: (Map<String, dynamic> data, _) =>
                              data['department'] as String,
                          yValueMapper: (Map<String, dynamic> data, _) =>
                              data['count'] as int,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                          ),
                          color: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
