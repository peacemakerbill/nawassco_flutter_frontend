import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/quote.model.dart';
import '../../../../providers/quote_provider.dart';

class QuoteStatsWidget extends ConsumerWidget {
  const QuoteStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);
    final stats = quoteState.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quote Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Cards - Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: constraints.maxWidth < 600 ? 2.5 : 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Total Quotes',
                      '${stats.total}',
                      Icons.description,
                      const Color(0xFF3B82F6),
                    ),
                    _buildStatCard(
                      'Total Value',
                      stats.totalAmountFormatted,
                      Icons.attach_money,
                      const Color(0xFF10B981),
                    ),
                    _buildStatCard(
                      'Average Quote',
                      stats.averageAmountFormatted,
                      Icons.bar_chart,
                      const Color(0xFF8B5CF6),
                    ),
                    _buildStatCard(
                      'Recent Quotes',
                      '${stats.recentCount}',
                      Icons.timeline,
                      const Color(0xFFF59E0B),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Status Distribution
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...QuoteStatus.values.map((status) {
                      final count = stats.byStatus[status] ?? 0;
                      final percentage =
                      stats.total > 0 ? (count / stats.total * 100) : 0;
                      return _buildStatusRow(
                          status, count, percentage.toDouble());
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Approval Distribution
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approval Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ApprovalStatus.values.map((status) {
                      final count = stats.byApprovalStatus[status] ?? 0;
                      final percentage =
                      stats.total > 0 ? (count / stats.total * 100) : 0;
                      return _buildApprovalRow(
                          status, count, percentage.toDouble());
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Form opening handled by parent
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Create New Quote'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(quoteProvider.notifier).refreshData();
                                },
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text('Refresh Stats'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Form opening handled by parent
                                  },
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('Create New Quote'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref.read(quoteProvider.notifier).refreshData();
                                  },
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text('Refresh Stats'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1E3A8A),
                                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(QuoteStatus status, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    status.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(status.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRow(
      ApprovalStatus status, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: status.color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 16, color: status.color),
                  const SizedBox(width: 6),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$count quotes',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}