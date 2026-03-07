import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/meter_reading_model.dart';

class MeterReadingCard extends StatelessWidget {
  final MeterReading reading;
  final VoidCallback onTap;

  const MeterReadingCard({
    super.key,
    required this.reading,
    required this.onTap,
  });

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.pending:
        return Colors.orange;
      case ReadingStatus.verified:
        return Colors.green;
      case ReadingStatus.rejected:
        return Colors.red;
      case ReadingStatus.processed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.pending:
        return Icons.pending;
      case ReadingStatus.verified:
        return Icons.verified;
      case ReadingStatus.rejected:
        return Icons.cancel;
      case ReadingStatus.processed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.speed,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reading.meterNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (reading.readerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reader: ${reading.readerName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reading.readingStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(reading.readingStatus),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(reading.readingStatus),
                          size: 16,
                          color: _getStatusColor(reading.readingStatus),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reading.readingStatus.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(reading.readingStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reading Details
              Row(
                children: [
                  // Current Reading
                  _buildDetailColumn(
                    'Current Reading',
                    '${reading.currentReading.toStringAsFixed(2)} m³',
                    Icons.water_drop,
                    Colors.blue,
                  ),

                  const SizedBox(width: 24),

                  // Consumption
                  _buildDetailColumn(
                    'Consumption',
                    '${reading.consumption.toStringAsFixed(2)} m³',
                    Icons.arrow_upward,
                    Colors.green,
                  ),

                  const SizedBox(width: 24),

                  // Previous Reading
                  if (reading.previousReading != null)
                    _buildDetailColumn(
                      'Previous',
                      '${reading.previousReading!.toStringAsFixed(2)} m³',
                      Icons.history,
                      Colors.grey,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(reading.readingDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.code,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reading.readingMethod.name} • ${reading.readingType.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bill Indicator
                  if (reading.billGenerated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bill Generated',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}