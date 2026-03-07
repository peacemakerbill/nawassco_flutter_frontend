import 'package:flutter/material.dart';

import '../../../models/meter_reading_model.dart';

class ReadingStatsCard extends StatelessWidget {
  final List<MeterReading> readings;

  const ReadingStatsCard({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    final totalReadings = readings.length;
    final pendingReadings =
        readings.where((r) => r.readingStatus == ReadingStatus.pending).length;
    final verifiedReadings =
        readings.where((r) => r.readingStatus == ReadingStatus.verified).length;
    final processedReadings =
        readings.where((r) => r.readingStatus == ReadingStatus.processed).length;
    final totalConsumption = readings.fold(
        0.0, (sum, reading) => sum + reading.consumption);

    final stats = [
      {
        'label': 'Total Readings',
        'value': totalReadings.toString(),
        'icon': Icons.list_alt,
        'color': Colors.blue,
      },
      {
        'label': 'Pending',
        'value': pendingReadings.toString(),
        'icon': Icons.pending,
        'color': Colors.orange,
      },
      {
        'label': 'Verified',
        'value': verifiedReadings.toString(),
        'icon': Icons.verified,
        'color': Colors.green,
      },
      {
        'label': 'Processed',
        'value': processedReadings.toString(),
        'icon': Icons.check_circle,
        'color': Colors.blueAccent,
      },
      {
        'label': 'Total Consumption',
        'value': '${totalConsumption.toStringAsFixed(2)} m³',
        'icon': Icons.water_drop,
        'color': Colors.cyan,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats.map((stat) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat['color'] as Color? ?? Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'] as IconData? ?? Icons.info,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['value'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}