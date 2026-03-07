import 'package:flutter/material.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'type': 'receive',
        'title': 'Stock Received',
        'description': '250 units of 4-inch PVC pipes from Supplier A',
        'time': '10:30 AM',
        'icon': Icons.inventory_2,
        'color': Colors.green,
      },
      {
        'type': 'issue',
        'title': 'Stock Issued',
        'description': '45 water meters to Maintenance Team',
        'time': '9:15 AM',
        'icon': Icons.exit_to_app,
        'color': Colors.blue,
      },
      {
        'type': 'order',
        'title': 'PO Created',
        'description': 'Purchase order #PO-2024-0012 for valves',
        'time': 'Yesterday',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
      },
      {
        'type': 'alert',
        'title': 'Low Stock Alert',
        'description': '6-inch PVC pipes below minimum stock level',
        'time': '8:45 AM',
        'icon': Icons.warning,
        'color': Colors.red,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF1E3A8A), size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity['icon'], color: activity['color'], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity['time'],
                  style: TextStyle(
                    color: activity['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}