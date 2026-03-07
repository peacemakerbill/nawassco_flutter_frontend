import 'package:flutter/material.dart';

class ProcurementQuickActions extends StatelessWidget {
  final Function(String)? onNavigate;

  const ProcurementQuickActions({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Create Tender',
        'icon': Icons.add,
        'color': Colors.blue,
        'route': '/procurement/tenders',
      },
      {
        'title': 'Raise PO',
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'route': '/procurement/purchase-orders',
      },
      {
        'title': 'Add Supplier',
        'icon': Icons.business,
        'color': Colors.orange,
        'route': '/procurement/suppliers',
      },
      {
        'title': 'Generate Report',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'route': '/procurement/reports',
      },
      {
        'title': 'Manage Contracts',
        'icon': Icons.feed,
        'color': Colors.teal,
        'route': '/procurement/contracts',
      },
      {
        'title': 'Bid Evaluation',
        'icon': Icons.assessment,
        'color': Colors.indigo,
        'route': '/procurement/bid-evaluation',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: actions.map((action) {
            return _buildActionCard(
              action['title'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['route'] as String,
            );
          }).toList(),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 800) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _buildActionCard(String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (onNavigate != null) {
            onNavigate!(route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}