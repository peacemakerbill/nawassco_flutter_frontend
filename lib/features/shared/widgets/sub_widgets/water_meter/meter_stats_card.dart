import 'package:flutter/material.dart';

import '../../../models/water_meter.model.dart';

class MeterStatsCard extends StatelessWidget {
  final WaterMeterStats stats;

  const MeterStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Meter Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            // Key Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    value: stats.totalMeters.toString(),
                    label: 'Total Meters',
                    icon: Icons.water_damage,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    value: stats.activeMeters.toString(),
                    label: 'Active',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    value: stats.faultyMeters.toString(),
                    label: 'Faulty',
                    icon: Icons.error,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    value: stats.onlineMeters.toString(),
                    label: 'Online',
                    icon: Icons.wifi,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Distribution
            const Text(
              'Distribution',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Type Distribution
            _buildDistributionSection(
              title: 'By Type',
              data: stats.typeDistribution,
              getColor: (type) {
                switch (type) {
                  case MeterType.smart:
                    return Colors.blue;
                  case MeterType.digital:
                    return Colors.green;
                  case MeterType.mechanical:
                    return Colors.orange;
                  case MeterType.ultrasonic:
                    return Colors.purple;
                  case MeterType.electromagnetic:
                    return Colors.red;
                  default:
                    return Colors.grey;
                }
              },
            ),
            const SizedBox(height: 12),

            // Technology Distribution
            _buildDistributionSection(
              title: 'By Technology',
              data: stats.technologyDistribution,
              getColor: (tech) {
                switch (tech) {
                  case MeterTechnology.ami:
                    return Colors.green;
                  case MeterTechnology.amr:
                    return Colors.blue;
                  case MeterTechnology.manual:
                    return Colors.orange;
                  default:
                    return Colors.grey;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionSection<T>({
    required String title,
    required Map<T, int> data,
    required Color Function(T) getColor,
  }) {
    final total = data.values.fold(0, (sum, value) => sum + value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        ...data.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total * 100) : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getDisplayName(entry.key),
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getDisplayName(dynamic value) {
    if (value is MeterType) {
      return value.displayName;
    } else if (value is MeterTechnology) {
      return value.displayName;
    } else if (value is NakuruServiceRegion) {
      return value.displayName;
    }
    return value.toString();
  }
}
