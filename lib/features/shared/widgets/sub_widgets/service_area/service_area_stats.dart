import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_area_model.dart';
import '../../../providers/service_area_provider.dart';

class ServiceAreaStats extends ConsumerWidget {
  const ServiceAreaStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceAreaProvider);
    final stats = state.totalStats;
    final typeStats = state.typeStats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Area Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(serviceAreaProvider.notifier).loadStats(),
                  icon: const Icon(Icons.refresh),
                  iconSize: 20,
                  tooltip: 'Refresh stats',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Total Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(
                  context,
                  Icons.location_city,
                  'Total Areas',
                  '${stats['totalAreas'] ?? 0}',
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  Icons.people,
                  'Total Population',
                  '${stats['totalPopulation']?.toStringAsFixed(0) ?? 0}',
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  Icons.home,
                  'Total Households',
                  '${stats['totalHouseholds']?.toStringAsFixed(0) ?? 0}',
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  Icons.plumbing,
                  'Total Water Mains',
                  '${stats['totalWaterMains']?.toStringAsFixed(0) ?? 0} km',
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Type Distribution
            Text(
              'Distribution by Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...AreaType.values.map((type) {
              final count = typeStats[type] ?? 0;
              final total = stats['totalAreas'] ?? 1;
              final percentage = total > 0 ? (count / total * 100) : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(type.icon, size: 16, color: type.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: type.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
