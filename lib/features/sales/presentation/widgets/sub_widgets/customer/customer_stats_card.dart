import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class CustomerStatsCard extends ConsumerWidget {
  const CustomerStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(customerProvider).stats;

    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 768;
    final crossAxisCount = isMobile ? 2 : 4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatItem(
                  context,
                  'Total Customers',
                  stats.total.toString(),
                  Icons.people_outlined,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Active Customers',
                  stats.active.toString(),
                  Icons.check_circle_outlined,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'New This Month',
                  stats.newThisMonth.toString(),
                  Icons.trending_up_outlined,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Total Balance',
                  'KES 0',
                  Icons.account_balance_wallet_outlined,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isMobile) ...[
              Text(
                'Distribution by Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  children: _buildTypeDistribution(stats.byType),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Distribution by Segment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  children: _buildSegmentDistribution(stats.bySegment),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeDistribution(Map<CustomerType, int> byType) {
    final total = byType.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return [const SizedBox()];

    final colors = {
      CustomerType.residential: const Color(0xFF2196F3),
      CustomerType.commercial: const Color(0xFF4CAF50),
      CustomerType.industrial: const Color(0xFFFF9800),
      CustomerType.institutional: const Color(0xFF9C27B0),
      CustomerType.government: const Color(0xFFF44336),
    };

    return byType.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return Expanded(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors[entry.key]!.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key.displayName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSegmentDistribution(Map<CustomerSegment, int> bySegment) {
    final total = bySegment.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return [const SizedBox()];

    final colors = {
      CustomerSegment.premium: const Color(0xFFFFD700),
      CustomerSegment.standard: const Color(0xFF4CAF50),
      CustomerSegment.economy: const Color(0xFF2196F3),
      CustomerSegment.corporate: const Color(0xFF9C27B0),
      CustomerSegment.government: const Color(0xFFF44336),
    };

    return bySegment.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return Expanded(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors[entry.key]!.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key.displayName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      );
    }).toList();
  }
}
