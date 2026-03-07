import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../providers/maintenance_schedule_provider.dart';

class MetricsDashboard extends ConsumerStatefulWidget {
  final Map<String, dynamic> metrics;

  const MetricsDashboard({super.key, required this.metrics});

  @override
  ConsumerState<MetricsDashboard> createState() => _MetricsDashboardState();
}

class _MetricsDashboardState extends ConsumerState<MetricsDashboard> {
  @override
  Widget build(BuildContext context) {
    final metrics = widget.metrics;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Maintenance Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              _buildRefreshButton(),
            ],
          ),
          const SizedBox(height: 16),

          // Charts Section
          _buildChartsSection(metrics),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () =>
          ref.read(maintenanceScheduleProvider.notifier).loadMetrics(),
      tooltip: 'Refresh Metrics',
    );
  }

  Widget _buildChartsSection(Map<String, dynamic> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStatusDistributionChart(metrics)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTargetTypeChart(metrics)),
                ],
              )
            : Column(
                children: [
                  _buildStatusDistributionChart(metrics),
                  const SizedBox(height: 16),
                  _buildTargetTypeChart(metrics),
                ],
              );
      },
    );
  }

  Widget _buildStatusDistributionChart(Map<String, dynamic> metrics) {
    final statusCounts = _parseStatusCounts(metrics['statusCounts']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maintenance Status Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: statusCounts.isNotEmpty
                  ? SfCircularChart(
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: statusCounts,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                          ),
                        )
                      ],
                    )
                  : _buildNoDataPlaceholder('No status data available'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTypeChart(Map<String, dynamic> metrics) {
    final targetTypeCounts =
        _parseTargetTypeCounts(metrics['targetTypeCounts']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maintenance by Target Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: targetTypeCounts.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                          dataSource: targetTypeCounts,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: Colors.blue,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        )
                      ],
                    )
                  : _buildNoDataPlaceholder('No target type data available'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Data parsing methods to convert backend metrics to chart data
  List<ChartData> _parseStatusCounts(List<dynamic>? statusCounts) {
    if (statusCounts == null) return [];

    final List<ChartData> data = [];

    for (final item in statusCounts) {
      final status = item['_id']?.toString() ?? '';
      final count = (item['count'] as num?)?.toDouble() ?? 0.0;

      if (count > 0) {
        final color = _getStatusColor(status);
        final displayName = _getStatusDisplayName(status);
        data.add(ChartData(displayName, count, color));
      }
    }

    return data;
  }

  List<ChartData> _parseTargetTypeCounts(List<dynamic>? targetTypeCounts) {
    if (targetTypeCounts == null) return [];

    final List<ChartData> data = [];

    for (final item in targetTypeCounts) {
      final targetType = item['_id']?.toString() ?? '';
      final count = (item['count'] as num?)?.toDouble() ?? 0.0;

      if (count > 0) {
        final color = _getTargetTypeColor(targetType);
        final displayName = _getTargetTypeDisplayName(targetType);
        data.add(ChartData(displayName, count, color));
      }
    }

    return data;
  }

  // Helper methods for status and target type mapping
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.grey;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'scheduled':
        return 'Scheduled';
      case 'overdue':
        return 'Overdue';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getTargetTypeColor(String targetType) {
    switch (targetType) {
      case 'vehicle':
        return Colors.blue;
      case 'tool':
        return Colors.orange;
      case 'equipment':
        return Colors.green;
      case 'infrastructure':
        return Colors.purple;
      case 'facility':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getTargetTypeDisplayName(String targetType) {
    switch (targetType) {
      case 'vehicle':
        return 'Vehicles';
      case 'tool':
        return 'Tools';
      case 'equipment':
        return 'Equipment';
      case 'infrastructure':
        return 'Infrastructure';
      case 'facility':
        return 'Facilities';
      default:
        return targetType;
    }
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
