import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/stock/stock_movement_model.dart';
import '../../../../providers/stock_movement_provider.dart';

class MovementSummaryTab extends ConsumerWidget {
  const MovementSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementState = ref.watch(stockMovementProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockMovementProvider.notifier).getMovementSummary();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          _buildSummaryCards(movementState),
          const SizedBox(height: 24),

          // Charts
          _buildCharts(movementState),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(movementState),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(StockMovementState state) {
    final summary = state.movementSummary;
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          title: 'Total Movements',
          value: '${_getTotalMovements(summary)}',
          icon: Icons.move_to_inbox,
          color: Colors.blue,
        ),
        _SummaryCard(
          title: 'Total Quantity',
          value: '${_getTotalQuantity(summary)}',
          icon: Icons.inventory,
          color: Colors.green,
        ),
        _SummaryCard(
          title: 'Total Value',
          value: 'KES ${_getTotalValue(summary).toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
        _SummaryCard(
          title: 'Unique Items',
          value: '${_getUniqueItems(summary)}',
          icon: Icons.category,
          color: Colors.orange,
        ),
      ],
    );
  }

  int _getTotalMovements(dynamic summary) {
    if (summary is List) {
      int total = 0;
      for (var item in summary) {
        total += (item['totalMovements'] ?? 0) as int;
      }
      return total;
    } else if (summary is Map) {
      return summary['totalMovements'] ?? 0;
    }
    return 0;
  }

  int _getTotalQuantity(dynamic summary) {
    if (summary is List) {
      int total = 0;
      for (var item in summary) {
        total += (item['totalQuantity'] ?? 0) as int;
      }
      return total;
    } else if (summary is Map) {
      return summary['totalQuantity'] ?? 0;
    }
    return 0;
  }

  double _getTotalValue(dynamic summary) {
    if (summary is List) {
      double total = 0.0;
      for (var item in summary) {
        total += (item['totalValue'] ?? 0.0) as double;
      }
      return total;
    } else if (summary is Map) {
      return (summary['totalValue'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  int _getUniqueItems(dynamic summary) {
    if (summary is List) {
      int total = 0;
      for (var item in summary) {
        total += (item['uniqueItemsCount'] ?? 0) as int;
      }
      return total;
    } else if (summary is Map) {
      return summary['uniqueItemsCount'] ?? 0;
    }
    return 0;
  }

  Widget _buildCharts(StockMovementState state) {
    final summary = state.movementSummary;
    if (summary == null) {
      return Container();
    }

    // Handle both List and Map formats for summary data
    List<dynamic> chartData = [];
    if (summary is List) {
      chartData = summary as List;
    } else if (summary is Map) {
      // Convert map to list format for charting
      if (summary.containsKey('movementTypes')) {
        chartData = summary['movementTypes'] ?? [];
      } else {
        // If it's a flat map, create a single item list
        chartData = [summary];
      }
    }

    if (chartData.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Movement Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _createPieChartSections(chartData),
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              startDegreeOffset: 0,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(chartData),
      ],
    );
  }

  List<PieChartSectionData> _createPieChartSections(List<dynamic> chartData) {
    final totalValue = _getTotalValueFromChartData(chartData);

    return chartData.map((item) {
      final value = _getItemValue(item);
      final percentage = totalValue > 0 ? (value / totalValue * 100) : 0;
      final movementType = _getItemMovementType(item);

      return PieChartSectionData(
        color: _getMovementTypeColor(movementType),
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  double _getTotalValueFromChartData(List<dynamic> chartData) {
    double total = 0.0;
    for (var item in chartData) {
      total += _getItemValue(item);
    }
    return total;
  }

  double _getItemValue(dynamic item) {
    if (item is Map) {
      return (item['totalValue'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  String _getItemMovementType(dynamic item) {
    if (item is Map) {
      return item['movementType'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  Widget _buildLegend(List<dynamic> chartData) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: chartData.map((item) {
        final movementType = _getItemMovementType(item);
        final value = _getItemValue(item);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getMovementTypeColor(movementType),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_formatMovementType(movementType)}: KES ${value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatMovementType(String type) {
    switch (type) {
      case 'receipt':
        return 'Receipt';
      case 'issue':
        return 'Issue';
      case 'transfer':
        return 'Transfer';
      case 'return':
        return 'Return';
      case 'adjustment':
        return 'Adjustment';
      default:
        return 'Unknown';
    }
  }

  Color _getMovementTypeColor(String type) {
    switch (type) {
      case 'receipt':
        return Colors.green;
      case 'issue':
        return Colors.orange;
      case 'transfer':
        return Colors.blue;
      case 'return':
        return Colors.purple;
      case 'adjustment':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentActivity(StockMovementState state) {
    final recentMovements = state.movements.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...recentMovements
            .map((movement) => _RecentMovementItem(movement: movement)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
}

class _RecentMovementItem extends StatelessWidget {
  final StockMovement movement;

  const _RecentMovementItem({required this.movement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getMovementTypeColor(movement.movementType)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getMovementIcon(movement.movementType),
                size: 16,
                color: _getMovementTypeColor(movement.movementType),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement.movementNumber,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${movement.totalQuantity} items • KES ${movement.totalValue.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(movement.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatStatus(movement.status),
                style: TextStyle(
                  color: _getStatusColor(movement.status),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMovementTypeColor(String type) {
    switch (type) {
      case 'receipt':
        return Colors.green;
      case 'issue':
        return Colors.orange;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMovementIcon(String type) {
    switch (type) {
      case 'receipt':
        return Icons.input;
      case 'issue':
        return Icons.output;
      case 'transfer':
        return Icons.compare_arrows;
      default:
        return Icons.move_to_inbox;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }
}