import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../providers/vehicle_provider.dart';

class VehicleMetricsWidget extends ConsumerWidget {
  const VehicleMetricsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleProvider);
    final metrics = state.metrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricsOverview(metrics),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return _buildWideLayout(metrics);
              } else {
                return _buildMobileLayout(metrics);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(Map<String, dynamic> metrics) {
    final totalCosts = metrics['totalCosts'] is List &&
            (metrics['totalCosts'] as List).isNotEmpty
        ? (metrics['totalCosts'] as List).first
        : {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Fleet Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildMetricCard(
                  'Total Vehicles',
                  (totalCosts['totalVehicles'] ?? 0).toString(),
                  Icons.directions_car,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Maintenance Cost',
                  'KES ${(totalCosts['totalMaintenanceCost'] ?? 0).toStringAsFixed(2)}',
                  Icons.build,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Fuel Cost',
                  'KES ${(totalCosts['totalFuelCost'] ?? 0).toStringAsFixed(2)}',
                  Icons.local_gas_station,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(Map<String, dynamic> metrics) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatusChart(metrics),
              const SizedBox(height: 20),
              _buildTypeChart(metrics),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: _buildMaintenanceAlerts(metrics),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> metrics) {
    return Column(
      children: [
        _buildStatusChart(metrics),
        const SizedBox(height: 20),
        _buildTypeChart(metrics),
        const SizedBox(height: 20),
        _buildMaintenanceAlerts(metrics),
      ],
    );
  }

  Widget _buildStatusChart(Map<String, dynamic> metrics) {
    final statusCounts = metrics['statusCounts'] ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Status Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: statusCounts,
                    xValueMapper: (data, _) =>
                        _getStatusDisplayName(data['_id']),
                    yValueMapper: (data, _) => (data['count'] ?? 0).toDouble(),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    pointColorMapper: (data, _) => _getStatusColor(data['_id']),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChart(Map<String, dynamic> metrics) {
    final typeCounts = metrics['typeCounts'] ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Type Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries<Map<String, dynamic>, String>>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: typeCounts,
                    xValueMapper: (data, _) => _getTypeDisplayName(data['_id']),
                    yValueMapper: (data, _) => (data['count'] ?? 0).toDouble(),
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceAlerts(Map<String, dynamic> metrics) {
    final maintenanceAlerts = metrics['maintenanceAlerts'] ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Maintenance Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (maintenanceAlerts.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      maintenanceAlerts.length.toString(),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (maintenanceAlerts.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text('No maintenance alerts'),
                    Text('All vehicles are up to date',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            else
              ...maintenanceAlerts
                  .map((alert) => _buildAlertItem(alert))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['registrationNumber'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${alert['make']} ${alert['model']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (alert['nextServiceDate'] != null)
                  Text(
                    'Due: ${DateTime.parse(alert['nextServiceDate']).toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    return switch (status) {
      'available' => 'Available',
      'in_use' => 'In Use',
      'under_maintenance' => 'Maintenance',
      'out_of_service' => 'Out of Service',
      _ => status,
    };
  }

  String _getTypeDisplayName(String type) {
    return switch (type) {
      'pickup_truck' => 'Pickup',
      'van' => 'Van',
      'suv' => 'SUV',
      'motorcycle' => 'Motorcycle',
      'truck' => 'Truck',
      'special_equipment' => 'Equipment',
      _ => type,
    };
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'available' => Colors.green,
      'in_use' => Colors.blue,
      'under_maintenance' => Colors.orange,
      'out_of_service' => Colors.red,
      _ => Colors.grey,
    };
  }
}
