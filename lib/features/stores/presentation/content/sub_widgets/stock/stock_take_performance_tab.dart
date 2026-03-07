import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../providers/stock_take_provider.dart';

class StockTakePerformanceTab extends ConsumerWidget {
  const StockTakePerformanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTakeState = ref.watch(stockTakeProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockTakeProvider.notifier).getStockTakePerformance();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Performance Summary
          _buildPerformanceSummary(stockTakeState),
          const SizedBox(height: 24),

          // Charts
          _buildPerformanceCharts(stockTakeState),
          const SizedBox(height: 24),

          // Recommendations
          _buildRecommendations(stockTakeState),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(StockTakeState state) {
    final performance = state.performance;
    if (performance == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = performance['summary'] ?? {};
    final performanceData = performance['performance'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
              children: [
                _PerformanceCard(
                  title: 'Total Stock Takes',
                  value: '${summary['totalStockTakes'] ?? 0}',
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
                _PerformanceCard(
                  title: 'Total Items Counted',
                  value: '${summary['totalItemsCounted'] ?? 0}',
                  icon: Icons.checklist,
                  color: Colors.green,
                ),
                _PerformanceCard(
                  title: 'Overall Variance',
                  value: '${(summary['overallVariancePercentage'] ?? 0).toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: _getVarianceColor(summary['overallVariancePercentage'] ?? 0),
                ),
                _PerformanceCard(
                  title: 'Counting Accuracy',
                  value: '${(100 - (summary['overallVariancePercentage'] ?? 0)).toStringAsFixed(1)}%',
                  icon: Icons.track_changes,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCharts(StockTakeState state) {
    final performance = state.performance;
    if (performance == null || performance['performance'] == null) {
      return Container();
    }

    final performanceData = performance['performance'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance by Stock Take Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: _createBarGroups(performanceData),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final stockTakeType = performanceData[groupIndex]['stockTakeType'] ?? 'Unknown';
                    final type = _getStockTakeTypeText(stockTakeType);
                    final value = rod.toY.toStringAsFixed(1);
                    final seriesName = rodIndex == 0 ? 'Variance %' : 'Time (min)';
                    return BarTooltipItem(
                      '$type\n$seriesName: $value',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < performanceData.length) {
                        final type = performanceData[index]['stockTakeType'] ?? 'Unknown';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getStockTakeTypeText(type),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxYValue(performanceData),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(List performanceData) {
    return List.generate(performanceData.length, (index) {
      final item = performanceData[index];
      final variance = (item['averageVariancePercentage'] ?? 0).toDouble();
      final countingTime = ((item['averageCountingTime'] ?? 0) / 1000 / 60).toDouble(); // Convert to minutes
      final stockTakeType = item['stockTakeType'] ?? 'Unknown';
      final color = _getStockTakeTypeColor(stockTakeType);

      return BarChartGroupData(
        x: index,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: variance,
            color: color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: countingTime,
            color: color.withOpacity(0.7),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0, 1],
      );
    });
  }

  double _getMaxYValue(List performanceData) {
    double maxValue = 0;
    for (var item in performanceData) {
      final variance = (item['averageVariancePercentage'] ?? 0).toDouble();
      final countingTime = ((item['averageCountingTime'] ?? 0) / 1000 / 60).toDouble();
      maxValue = [maxValue, variance, countingTime].reduce((a, b) => a > b ? a : b);
    }
    return maxValue * 1.2; // Add 20% padding
  }

  Widget _buildChartLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Variance %', Colors.blue),
        _buildLegendItem('Counting Time (min)', Colors.blue.withOpacity(0.7)),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecommendations(StockTakeState state) {
    final performance = state.performance;
    if (performance == null) return Container();

    final performanceData = performance['performance'] as List? ?? [];
    final highVarianceTypes = performanceData.where((item) =>
    (item['averageVariancePercentage'] ?? 0) > 5
    ).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (highVarianceTypes.isEmpty)
              const Text(
                'Great job! All stock take types are within acceptable variance limits.',
                style: TextStyle(color: Colors.green),
              ),
            ...highVarianceTypes.map((type) => _RecommendationItem(type: type)),
          ],
        ),
      ),
    );
  }

  // Helper methods moved to the main class
  String _getStockTakeTypeText(String type) {
    switch (type) {
      case 'cycle_count': return 'Cycle Count';
      case 'spot_check': return 'Spot Check';
      case 'full_count': return 'Full Count';
      case 'annual': return 'Annual Count';
      case 'quarterly': return 'Quarterly Count';
      case 'monthly': return 'Monthly Count';
      default: return type;
    }
  }

  Color _getVarianceColor(double variance) {
    if (variance <= 2) return Colors.green;
    if (variance <= 5) return Colors.orange;
    return Colors.red;
  }

  Color _getStockTakeTypeColor(String? type) {
    switch (type) {
      case 'annual': return Colors.purple;
      case 'quarterly': return Colors.blue;
      case 'monthly': return Colors.green;
      case 'cycle_count': return Colors.orange;
      case 'spot_check': return Colors.teal;
      case 'full_count': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PerformanceCard({
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
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
          ],
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final Map<String, dynamic> type;

  const _RecommendationItem({required this.type});

  @override
  Widget build(BuildContext context) {
    final variance = type['averageVariancePercentage'] ?? 0;
    final stockTakeType = type['stockTakeType'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStockTakeTypeText(stockTakeType),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'High variance detected: ${variance.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRecommendation(stockTakeType),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStockTakeTypeText(String type) {
    switch (type) {
      case 'cycle_count': return 'Cycle Count';
      case 'spot_check': return 'Spot Check';
      case 'full_count': return 'Full Count';
      case 'annual': return 'Annual Count';
      case 'quarterly': return 'Quarterly Count';
      case 'monthly': return 'Monthly Count';
      default: return type;
    }
  }

  String _getRecommendation(String type) {
    switch (type) {
      case 'cycle_count':
        return 'Recommendation: Increase frequency of cycle counts in high-variance areas.';
      case 'spot_check':
        return 'Recommendation: Expand spot check coverage to include more items.';
      case 'full_count':
        return 'Recommendation: Improve counting procedures and team training.';
      default:
        return 'Recommendation: Review counting processes and consider additional training.';
    }
  }
}