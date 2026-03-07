import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ManagementMetricsSection extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const ManagementMetricsSection({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.only(top: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Row(
              children: [
                // Approval Status Chart
                _buildApprovalStatusChart(),

                const SizedBox(width: 16),

                // Technician Performance
                _buildTechnicianPerformance(),

                const SizedBox(width: 16),

                // Monthly Trends
                _buildMonthlyTrends(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatusChart() {
    final dataSource = (metrics['approvalStatusCounts'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];

    if (dataSource.isEmpty) {
      return _buildEmptyChartCard('Approval Status Distribution');
    }

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Approval Status Distribution',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SfCircularChart(
                  series: <CircularSeries>[
                    DoughnutSeries<Map<String, dynamic>, String>(
                      dataSource: dataSource,
                      xValueMapper: (data, _) => data['_id'] ?? 'Unknown',
                      yValueMapper: (data, _) => (data['count'] as num?)?.toDouble() ?? 0,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianPerformance() {
    final techPerformance = (metrics['technicianPerformance'] as List<dynamic>?) ?? [];

    if (techPerformance.isEmpty) {
      return _buildEmptyChartCard('Top Technicians by Performance');
    }

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Technicians by Performance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: techPerformance.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    final tech = techPerformance[index];
                    if (tech == null || tech is! Map<String, dynamic>) {
                      return const SizedBox();
                    }

                    final technicianName = tech['technicianName']?.toString() ?? 'Unknown';
                    final reportCount = tech['reportCount']?.toString() ?? '0';
                    final avgSatisfaction = ((tech['averageSatisfaction'] as num?)?.toDouble() ?? 0).toStringAsFixed(1);
                    final avgQuality = ((tech['averageQuality'] as num?)?.toDouble() ?? 0).toStringAsFixed(1);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(technicianName),
                      subtitle: Text('$reportCount reports • $avgSatisfaction/5 rating'),
                      trailing: Chip(
                        label: Text('$avgQuality/5'),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.green),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyTrends() {
    final monthlyStats = (metrics['monthlyStats'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];

    if (monthlyStats.isEmpty) {
      return _buildEmptyChartCard('Monthly Report Trends');
    }

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Report Trends',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  primaryYAxis: const NumericAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: monthlyStats,
                      xValueMapper: (data, _) {
                        final id = data['_id'];
                        if (id is Map<String, dynamic>) {
                          final month = id['month']?.toString().padLeft(2, '0') ?? '';
                          final year = id['year']?.toString() ?? '';
                          return '$month/$year';
                        }
                        return 'Unknown';
                      },
                      yValueMapper: (data, _) => (data['count'] as num?)?.toDouble() ?? 0,
                      color: Colors.blue,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChartCard(String title) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'No data available',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}