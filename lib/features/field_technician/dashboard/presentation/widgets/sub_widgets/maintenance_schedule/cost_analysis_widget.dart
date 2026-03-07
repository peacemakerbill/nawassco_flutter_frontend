import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/maintenance_schedule_provider.dart';

class CostAnalysisWidget extends ConsumerWidget {
  const CostAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceScheduleProvider);
    final costAnalysis = _getCostAnalysisData(state.metrics);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (costAnalysis.isEmpty)
              _buildNoCostData(),
            if (costAnalysis.isNotEmpty)
              _buildCostMetrics(costAnalysis),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCostData() {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.attach_money, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No cost data available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCostMetrics(Map<String, dynamic> costAnalysis) {
    final totalEstimated = costAnalysis['totalEstimatedCost'] ?? 0.0;
    final totalActual = costAnalysis['totalActualCost'] ?? 0.0;
    final averageVariance = costAnalysis['averageVariance'] ?? 0.0;

    return Column(
      children: [
        _buildCostMetricRow(
            'Total Estimated Cost', totalEstimated, Colors.blue),
        _buildCostMetricRow('Total Actual Cost', totalActual, Colors.green),
        _buildCostMetricRow(
          'Average Variance',
          averageVariance,
          averageVariance >= 0 ? Colors.red : Colors.green,
          showPositivePrefix: true,
        ),
        const SizedBox(height: 16),
        _buildVarianceIndicator(averageVariance),
      ],
    );
  }

  Widget _buildCostMetricRow(String label, double value, Color color,
      {bool showPositivePrefix = false}) {
    final formattedValue = value >= 0
        ? '\$${value.toStringAsFixed(2)}'
        : '-\$${value.abs().toStringAsFixed(2)}';

    final displayValue = showPositivePrefix && value > 0
        ? '+$formattedValue'
        : formattedValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceIndicator(double variance) {
    final isPositive = variance >= 0;
    final percentage = variance != 0
        ? (variance.abs() * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.red.withOpacity(0.1) : Colors.green
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPositive
                  ? 'Costs are $percentage% over budget on average'
                  : 'Costs are $percentage% under budget on average',
              style: TextStyle(
                color: isPositive ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCostAnalysisData(Map<String, dynamic> metrics) {
    final costAnalysis = metrics['costAnalysis'] ?? [];
    if (costAnalysis.isNotEmpty && costAnalysis[0] is Map) {
      return costAnalysis[0];
    }
    return {};
  }
}