import 'package:flutter/material.dart';

import '../../../../models/warehouse_model.dart';

class UtilizationChart extends StatelessWidget {
  final Warehouse warehouse;

  const UtilizationChart({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final utilizationPercentage = warehouse.capacity.totalArea > 0
        ? (warehouse.capacity.currentUtilization / warehouse.capacity.totalArea) * 100
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.analytics_rounded, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Utilization Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Main Utilization Gauge
        _buildUtilizationGauge(utilizationPercentage.toDouble(), theme),
        const SizedBox(height: 20),

        // Zone Utilization
        _buildZoneUtilization(theme),
        const SizedBox(height: 16),

        // Capacity Details
        _buildCapacityDetails(theme),
      ],
    );
  }

  Widget _buildUtilizationGauge(double percentage, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  color: _getUtilizationColor(percentage),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Utilized',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${warehouse.capacity.currentUtilization.toStringAsFixed(0)} / ${warehouse.capacity.totalArea.toStringAsFixed(0)} m²',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneUtilization(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zone Utilization',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...warehouse.zones.take(5).map((zone) {
          final zonePercentage = zone.capacity > 0 ? (zone.currentUtilization / zone.capacity) * 100 : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    zone.zoneName,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: zonePercentage / 100,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    color: _getUtilizationColor(zonePercentage.toDouble()),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${zonePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getUtilizationColor(zonePercentage.toDouble()),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (warehouse.zones.length > 5)
          Text(
            '+ ${warehouse.zones.length - 5} more zones',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildCapacityDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capacity Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildCapacityItem('Total Area', '${warehouse.capacity.totalArea.toStringAsFixed(0)} m²', theme),
          _buildCapacityItem('Usable Area', '${warehouse.capacity.usableArea.toStringAsFixed(0)} m²', theme),
          _buildCapacityItem('Storage Capacity', '${warehouse.capacity.storageCapacity.toStringAsFixed(0)} m³', theme),
          _buildCapacityItem('Pallet Positions', warehouse.capacity.palletPositions.toString(), theme),
          _buildCapacityItem('Zones', warehouse.zones.length.toString(), theme),
        ],
      ),
    );
  }

  Widget _buildCapacityItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUtilizationColor(double percentage) {
    if (percentage < 70) return Colors.green;
    if (percentage < 85) return Colors.orange;
    return Colors.red;
  }
}