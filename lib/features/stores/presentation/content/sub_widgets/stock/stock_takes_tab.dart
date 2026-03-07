import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/stock/stock_take_model.dart';
import '../../../../providers/stock_take_provider.dart';
import 'count_item_dialog.dart';
import 'stock_take_details_dialog.dart';


class StockTakesTab extends ConsumerWidget {
  const StockTakesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTakeState = ref.watch(stockTakeProvider);
    final authState = ref.watch(authProvider);

    if (stockTakeState.isLoading && stockTakeState.stockTakes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stockTakeState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading stock takes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              stockTakeState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(stockTakeProvider.notifier).getStockTakes(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (stockTakeState.stockTakes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No stock takes found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(
              'Create your first stock take to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockTakeProvider.notifier).getStockTakes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stockTakeState.stockTakes.length,
        itemBuilder: (context, index) {
          final stockTake = stockTakeState.stockTakes[index];
          return _StockTakeCard(stockTake: stockTake, authState: authState);
        },
      ),
    );
  }
}

class _StockTakeCard extends ConsumerWidget {
  final StockTake stockTake;
  final AuthState authState;

  const _StockTakeCard({
    required this.stockTake,
    required this.authState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _StockTakeTypeChip(stockTakeType: stockTake.stockTakeType),
                const Spacer(),
                _StatusChip(status: stockTake.status),
                const SizedBox(width: 8),
                _CountingStatusChip(countingStatus: stockTake.countingStatus),
              ],
            ),
            const SizedBox(height: 12),

            // Stock Take Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stockTake.stockTakeNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stockTake.warehouse} • ${stockTake.zones.length} zones',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stockTake.completionPercentage.toStringAsFixed(1)}% Complete',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${stockTake.countedItemsCount}/${stockTake.totalItems} items',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress and Variance
            _buildProgressSection(),
            const SizedBox(height: 12),

            // Dates and Team
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team: ${stockTake.countingTeam.length} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Variance: KES ${stockTake.totalVarianceValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: stockTake.totalVarianceValue >= 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(stockTake.stockTakeDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            if (_shouldShowActions(stockTake))
              Row(
                children: [
                  if (stockTake.canStart && (authState.isAdmin || authState.isStoreManager))
                    OutlinedButton(
                      onPressed: () => _startStockTake(ref, stockTake.id),
                      child: const Text('Start Counting'),
                    ),
                  const SizedBox(width: 8),
                  if (stockTake.countingStatus == 'in_progress')
                    ElevatedButton(
                      onPressed: () => _showCountItemDialog(context, ref, stockTake.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Count Item', style: TextStyle(color: Colors.white)),
                    ),
                  const SizedBox(width: 8),
                  if (stockTake.canCompleteCounting)
                    ElevatedButton(
                      onPressed: () => _completeCounting(ref, stockTake.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Complete Counting', style: TextStyle(color: Colors.white)),
                    ),
                  const SizedBox(width: 8),
                  if (stockTake.canApprove && (authState.isAdmin || authState.isStoreManager))
                    ElevatedButton(
                      onPressed: () => _approveStockTake(ref, stockTake.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Approve', style: TextStyle(color: Colors.white)),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showDetailsDialog(context, stockTake),
                    tooltip: 'View Details',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: stockTake.completionPercentage / 100,
          backgroundColor: Colors.grey[200],
          color: _getProgressColor(stockTake.completionPercentage),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: ${stockTake.completionPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Variance: ${stockTake.variancePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: stockTake.variancePercentage > 2 ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 50) return Colors.red;
    if (percentage < 80) return Colors.orange;
    return Colors.green;
  }

  bool _shouldShowActions(StockTake stockTake) {
    return stockTake.canStart ||
        stockTake.countingStatus == 'in_progress' ||
        stockTake.canCompleteCounting ||
        stockTake.canApprove;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startStockTake(WidgetRef ref, String stockTakeId) {
    ref.read(stockTakeProvider.notifier).startStockTake(stockTakeId);
  }

  void _showCountItemDialog(BuildContext context, WidgetRef ref, String stockTakeId) {
    showDialog(
      context: context,
      builder: (context) => CountItemDialog(
        stockTakeId: stockTakeId,
        onItemCounted: () {
          ref.read(stockTakeProvider.notifier).getStockTakes();
        },
      ),
    );
  }

  void _completeCounting(WidgetRef ref, String stockTakeId) {
    ref.read(stockTakeProvider.notifier).completeCounting(stockTakeId);
  }

  void _approveStockTake(WidgetRef ref, String stockTakeId) {
    ref.read(stockTakeProvider.notifier).approveStockTake(
      stockTakeId,
      ref.read(authProvider).user?['_id'] ?? '',
    );
  }

  void _showDetailsDialog(BuildContext context, StockTake stockTake) {
    showDialog(
      context: context,
      builder: (context) => StockTakeDetailsDialog(stockTake: stockTake),
    );
  }
}

class _StockTakeTypeChip extends StatelessWidget {
  final String stockTakeType;

  const _StockTakeTypeChip({required this.stockTakeType});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStockTakeTypeInfo(stockTakeType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStockTakeTypeInfo(String type) {
    switch (type) {
      case 'annual':
        return (Colors.purple, 'Annual Count');
      case 'quarterly':
        return (Colors.blue, 'Quarterly Count');
      case 'monthly':
        return (Colors.green, 'Monthly Count');
      case 'cycle_count':
        return (Colors.orange, 'Cycle Count');
      case 'spot_check':
        return (Colors.teal, 'Spot Check');
      case 'full_count':
        return (Colors.red, 'Full Count');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(String status) {
    switch (status) {
      case 'planned':
        return (Colors.grey, 'Planned');
      case 'in_progress':
        return (Colors.blue, 'In Progress');
      case 'counting_completed':
        return (Colors.orange, 'Counting Completed');
      case 'under_review':
        return (Colors.purple, 'Under Review');
      case 'adjusted':
        return (Colors.teal, 'Adjusted');
      case 'completed':
        return (Colors.green, 'Completed');
      case 'cancelled':
        return (Colors.red, 'Cancelled');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}

class _CountingStatusChip extends StatelessWidget {
  final String countingStatus;

  const _CountingStatusChip({required this.countingStatus});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getCountingStatusInfo(countingStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getCountingStatusInfo(String status) {
    switch (status) {
      case 'not_started':
        return (Colors.grey, 'Not Started');
      case 'in_progress':
        return (Colors.blue, 'Counting');
      case 'completed':
        return (Colors.green, 'Counted');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}