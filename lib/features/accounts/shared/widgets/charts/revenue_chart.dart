import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final Map<String, double> revenueData;
  final String title;

  const RevenueChart({
    super.key,
    required this.revenueData,
    required this.title,
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildChartContent(),
            ),
            const SizedBox(height: 16),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    if (revenueData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No data available'),
          ],
        ),
      );
    }

    // For demo purposes, we'll show a placeholder
    // In a real app, you would integrate with a charting library like charts_flutter
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.blue),
          SizedBox(height: 8),
          Text('Revenue Chart'),
          Text('Bar chart showing revenue trends',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final entries = revenueData.entries.toList();
    if (entries.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: _getColorForIndex(entries.indexOf(entry)),
            ),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              'KES ${entry.value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}