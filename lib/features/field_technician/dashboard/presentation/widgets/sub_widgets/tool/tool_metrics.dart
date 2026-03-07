import 'package:flutter/material.dart';

class ToolMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const ToolMetricsWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final statusCounts = metrics['statusCounts'] as List? ?? [];
    final typeCounts = metrics['typeCounts'] as List? ?? [];
    final totalCosts = metrics['totalCosts'] as List? ?? [];
    final maintenanceAlerts = metrics['maintenanceAlerts'] as List? ?? [];
    final calibrationAlerts = metrics['calibrationAlerts'] as List? ?? [];

    final totalCost = totalCosts.isNotEmpty ? totalCosts[0] : {};
    final totalPurchaseCost = (totalCost['totalPurchaseCost'] as num?)?.toDouble() ?? 0;
    final totalMaintenanceCost = (totalCost['totalMaintenanceCost'] as num?)?.toDouble() ?? 0;
    final totalTools = (totalCost['totalTools'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tool Metrics Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Tools', totalTools.toString(), Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Total Value', 'KES ${totalPurchaseCost.toStringAsFixed(0)}', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Maintenance Cost', 'KES ${totalMaintenanceCost.toStringAsFixed(0)}', Colors.orange)),
            ],
          ),

          const SizedBox(height: 16),

          // Alerts
          if (maintenanceAlerts.isNotEmpty || calibrationAlerts.isNotEmpty) ...[
            Row(
              children: [
                if (maintenanceAlerts.isNotEmpty)
                  Expanded(
                    child: _buildAlertCard(
                      'Maintenance Due',
                      maintenanceAlerts.length,
                      Colors.orange,
                      Icons.build_circle,
                    ),
                  ),
                if (maintenanceAlerts.isNotEmpty && calibrationAlerts.isNotEmpty)
                  const SizedBox(width: 12),
                if (calibrationAlerts.isNotEmpty)
                  Expanded(
                    child: _buildAlertCard(
                      'Calibration Due',
                      calibrationAlerts.length,
                      Colors.red,
                      Icons.science,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Status Distribution
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusCounts.map((status) {
                final count = (status['count'] as num).toInt();
                final statusName = status['_id'] as String;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildStatusChip(statusName, count),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildAlertCard(String title, int count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, int count) {
    Color getColorForStatus(String status) {
      switch (status) {
        case 'available': return Colors.green;
        case 'in_use': return Colors.blue;
        case 'under_maintenance': return Colors.orange;
        case 'reserved': return Colors.purple;
        case 'out_of_service': return Colors.red;
        default: return Colors.grey;
      }
    }

    final color = getColorForStatus(status);
    final displayName = status.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)).join(' ');

    return Chip(
      label: Text('$displayName: $count'),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }
}