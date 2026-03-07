import 'package:flutter/material.dart';

class RecentAlertsList extends StatelessWidget {
  final Function(String) onNavigate;

  const RecentAlertsList({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'type': 'Critical',
        'message': 'Low chlorine levels at Kaptembwo Reservoir',
        'time': '10 mins ago',
        'icon': Icons.warning,
        'route': '/manager/water-supply',
      },
      {
        'type': 'Warning',
        'message': 'High NRW detected in Zone 5 - requires investigation',
        'time': '1 hour ago',
        'icon': Icons.analytics,
        'route': '/manager/nrw',
      },
      {
        'type': 'Info',
        'message': 'Scheduled maintenance completed successfully',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
        'route': '/manager/projects',
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Color(0xFF0066CC), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Recent Alerts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigate('/manager/reports'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(alert)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    Color getAlertColor(String type) {
      return switch (type) {
        'Critical' => Colors.red,
        'Warning' => Colors.orange,
        _ => Colors.green,
      };
    }

    IconData getAlertIcon(String type) {
      return switch (type) {
        'Critical' => Icons.warning,
        'Warning' => Icons.info,
        _ => Icons.check_circle,
      };
    }

    return GestureDetector(
      onTap: () => onNavigate(alert['route']),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: getAlertColor(alert['type']).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: getAlertColor(alert['type']).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: getAlertColor(alert['type']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getAlertIcon(alert['type']),
                  color: getAlertColor(alert['type']),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['message'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert['time'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getAlertColor(alert['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert['type'],
                  style: TextStyle(
                    color: getAlertColor(alert['type']),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}