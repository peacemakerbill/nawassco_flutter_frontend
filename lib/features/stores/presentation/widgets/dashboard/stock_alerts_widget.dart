import 'package:flutter/material.dart';

class StockAlertsWidget extends StatelessWidget {
  const StockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'item': '6-inch PVC Pipes',
        'code': 'PIPE-006-PVC',
        'currentStock': 45,
        'minStock': 100,
        'status': 'Low Stock',
        'color': Colors.orange,
        'icon': Icons.warning,
      },
      {
        'item': 'Water Meters Digital',
        'code': 'MTR-DIG-001',
        'currentStock': 12,
        'minStock': 50,
        'status': 'Critical',
        'color': Colors.red,
        'icon': Icons.error,
      },
      {
        'item': 'Gate Valves 4-inch',
        'code': 'VALVE-004-GT',
        'currentStock': 8,
        'minStock': 25,
        'status': 'Critical',
        'color': Colors.red,
        'icon': Icons.error,
      },
      {
        'item': 'Pipe Joints 6-inch',
        'code': 'JOINT-006-PVC',
        'currentStock': 85,
        'minStock': 150,
        'status': 'Low Stock',
        'color': Colors.orange,
        'icon': Icons.warning,
      },
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Color(0xFF1E3A8A), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Stock Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '8 Items Need Attention',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map((alert) => _buildAlertItem(alert)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.inventory, size: 18),
                label: const Text('VIEW ALL STOCK ALERTS'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final percentage = (alert['currentStock'] / alert['minStock'] * 100).clamp(0, 100).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert['color'].withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alert['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(alert['icon'], color: alert['color'], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        alert['item'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: alert['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert['status'],
                        style: TextStyle(
                          color: alert['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert['code'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(alert['color']),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${alert['currentStock']}/${alert['minStock']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: alert['color'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}