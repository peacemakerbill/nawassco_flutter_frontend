import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/water_source_model.dart';
import '../../../providers/water_source_provider.dart';

class WaterSourceStats extends ConsumerWidget {
  const WaterSourceStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(waterSourceProvider).stats;
    final waterSources = ref.watch(waterSourceProvider).waterSources;

    if (waterSources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Source Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Quick stats row
            _buildQuickStats(context, waterSources),
            const SizedBox(height: 24),
            // Type distribution
            if (stats['byType'] != null)
              _buildTypeDistribution(context, stats['byType']),
            const SizedBox(height: 24),
            // Status distribution
            if (stats['byStatus'] != null)
              _buildStatusDistribution(context, stats['byStatus']),
            const SizedBox(height: 24),
            // Quality distribution
            if (stats['byQuality'] != null)
              _buildQualityDistribution(context, stats['byQuality']),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, List<WaterSource> sources) {
    final operationalCount = sources.where((s) => s.status == SourceStatus.OPERATIONAL).length;
    final totalCapacity = sources.fold<double>(0, (sum, source) => sum + source.capacity.dailyYield);
    final totalUsage = sources.fold<double>(0, (sum, source) => sum + source.capacity.currentUsage);
    final avgUtilization = sources.isNotEmpty
        ? sources.fold<double>(0, (sum, source) => sum + source.capacity.utilizationRate) / sources.length
        : 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Sources',
          '${sources.length}',
          Icons.water,
          Colors.blue,
        ),
        _buildStatCard(
          'Operational',
          '$operationalCount',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Capacity',
          '${totalCapacity.toStringAsFixed(0)} m³/day',
          Icons.water_damage,
          Colors.blueAccent,
        ),
        _buildStatCard(
          'Avg Utilization',
          '${avgUtilization.toStringAsFixed(1)}%',
          Icons.trending_up,
          avgUtilization > 80 ? Colors.orange : Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution(BuildContext context, List<dynamic> typeStats) {
    final total = typeStats.fold<int>(0, (sum, item) => sum + ((item['count'] as int?) ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution by Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...typeStats.map((item) {
          final type = WaterSourceType.values.firstWhere(
                (e) => e.value == item['_id'],
            orElse: () => WaterSourceType.WELL,
          );
          final count = item['count'] ?? 0;
          final percentage = total > 0 ? (count / total * 100) : 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    type.displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(type)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusDistribution(BuildContext context, List<dynamic> statusStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution by Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statusStats.map((item) {
            final status = SourceStatus.values.firstWhere(
                  (e) => e.value == item['_id'],
              orElse: () => SourceStatus.OPERATIONAL,
            );
            final count = item['count'] ?? 0;

            return Chip(
              label: Text('${status.displayName}: $count'),
              backgroundColor: status.color.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: status.color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQualityDistribution(BuildContext context, List<dynamic> qualityStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution by Quality',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: qualityStats.map((item) {
            final quality = QualityGrade.values.firstWhere(
                  (e) => e.value == item['_id'],
              orElse: () => QualityGrade.GOOD,
            );
            final count = item['count'] ?? 0;
            final avgPH = item['avgPH'] ?? 7.0;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: quality.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: quality.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quality.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: quality.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count sources',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg pH: ${avgPH.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getTypeColor(WaterSourceType type) {
    switch (type) {
      case WaterSourceType.BOREHOLE:
        return Colors.blue;
      case WaterSourceType.SURFACE_WATER:
        return Colors.lightBlue;
      case WaterSourceType.DAM:
        return Colors.indigo;
      case WaterSourceType.SPRING:
        return Colors.teal;
      case WaterSourceType.LAKE:
        return Colors.cyan;
      case WaterSourceType.RIVER:
        return Colors.lightBlueAccent;
      case WaterSourceType.WELL:
        return Colors.blueGrey;
    }
  }
}