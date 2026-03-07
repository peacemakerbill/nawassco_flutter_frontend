import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/outage_provider.dart';

class OutageStatsWidget extends ConsumerWidget {
  const OutageStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outageState = ref.watch(outageProvider);

    if (outageState.stats.isEmpty) {
      return Container();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Outage Overview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Outages',
                  outageState.stats['totalOutages']?.toString() ?? '0',
                  Icons.water_damage,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active',
                  outageState.outages
                      .where((o) => ['REPORTED', 'CONFIRMED', 'IN_PROGRESS']
                          .contains(o.status.toString().split('.').last))
                      .length
                      .toString(),
                  Icons.warning,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Affected',
                  outageState.stats['totalCustomersAffected']?.toString() ??
                      '0',
                  Icons.people,
                  Colors.red,
                ),
                _buildStatItem(
                  'Resolved Today',
                  '3', // This should come from stats
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
}
