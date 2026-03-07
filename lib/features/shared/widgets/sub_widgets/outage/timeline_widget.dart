import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class TimelineWidget extends StatelessWidget {
  final Outage outage;

  const TimelineWidget({super.key, required this.outage});

  @override
  Widget build(BuildContext context) {
    final events = _getTimelineEvents();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...events.map((event) => _buildTimelineItem(event)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: event['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: event['color'].withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  event['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  event['time'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTimelineEvents() {
    return [
      {
        'title': 'Outage Reported',
        'description': 'Outage reported by ${outage.reportedBy}',
        'time': _formatDateTime(outage.createdAt),
        'color': Colors.orange,
      },
      if (outage.actualStart != null)
        {
          'title': 'Work Started',
          'description': 'Repair work began on site',
          'time': _formatDateTime(outage.actualStart!),
          'color': Colors.blue,
        },
      ...outage.customerUpdates.map((update) {
        return {
          'title': 'Customer Update',
          'description': update.message,
          'time': _formatDateTime(update.timestamp),
          'color': Colors.green,
        };
      }).toList(),
      if (outage.actualEnd != null)
        {
          'title': 'Work Completed',
          'description': 'Repair work completed successfully',
          'time': _formatDateTime(outage.actualEnd!),
          'color': Colors.teal,
        },
    ];
  }

  String _formatDateTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
  }
}
