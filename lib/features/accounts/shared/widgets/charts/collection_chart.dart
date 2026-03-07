import 'package:flutter/material.dart';

class CollectionChart extends StatelessWidget {
  final Map<String, double> collectionData;
  final double targetEfficiency;
  final String title;

  const CollectionChart({
    super.key,
    required this.collectionData,
    required this.targetEfficiency,
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
            _buildEfficiencyIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    if (collectionData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No collection data available'),
          ],
        ),
      );
    }

    // For demo purposes, we'll show a placeholder
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 48, color: Colors.green),
          SizedBox(height: 8),
          Text('Collection Efficiency Chart'),
          Text('Line chart showing collection performance',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEfficiencyIndicator() {
    final currentEfficiency = _calculateCurrentEfficiency();
    final isMeetingTarget = currentEfficiency >= targetEfficiency;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMeetingTarget ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMeetingTarget ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMeetingTarget ? Icons.check_circle : Icons.warning,
            color: isMeetingTarget ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collection Efficiency: ${(currentEfficiency * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMeetingTarget ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  'Target: ${(targetEfficiency * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: currentEfficiency,
            backgroundColor: Colors.grey[300],
            color: isMeetingTarget ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  double _calculateCurrentEfficiency() {
    if (collectionData.isEmpty) return 0.0;

    // Simple calculation for demo purposes
    // In real app, this would be based on actual collection data
    final values = collectionData.values.toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    return average / 100; // Assuming values are percentages
  }
}