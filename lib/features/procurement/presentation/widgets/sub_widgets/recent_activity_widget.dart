import 'package:flutter/material.dart';

class RecentActivityWidget extends StatelessWidget {
  final Function(String)? onNavigate;

  const RecentActivityWidget({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'type': 'tender',
        'title': 'New Tender Published',
        'description': 'Water Meter Supply Tender #TM-2024-015',
        'time': '2 hours ago',
        'icon': Icons.assignment,
        'color': Colors.blue,
        'route': '/procurement/tenders',
      },
      {
        'type': 'po',
        'title': 'PO #10234 Approved',
        'description': 'Purchase order for pipe fittings - KES 2.4M',
        'time': '5 hours ago',
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'route': '/procurement/purchase-orders',
      },
      {
        'type': 'contract',
        'title': 'Contract Renewed',
        'description': 'Maintenance services contract extended',
        'time': '1 day ago',
        'icon': Icons.feed,
        'color': Colors.orange,
        'route': '/procurement/contracts',
      },
      {
        'type': 'bid',
        'title': 'Bid Evaluation Complete',
        'description': 'Tender #TM-2024-012 evaluation finalized',
        'time': '2 days ago',
        'icon': Icons.assessment,
        'color': Colors.purple,
        'route': '/procurement/bid-evaluation',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF0D47A1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (onNavigate != null) {
                      onNavigate!('/procurement/reports');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
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
    return GestureDetector(
      onTap: () {
        if (onNavigate != null) {
          onNavigate!(activity['route'] as String);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
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
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}