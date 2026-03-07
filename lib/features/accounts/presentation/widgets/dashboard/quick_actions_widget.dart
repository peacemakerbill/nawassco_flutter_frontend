import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  final Function(String) onNavigate;

  const QuickActionsWidget({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Run Billing',
        'subtitle': 'Generate monthly invoices',
        'icon': Icons.receipt,
        'color': Colors.blue,
        'route': '/accounts/controller'
      },
      {
        'title': 'Post Payments',
        'subtitle': 'Record manual payments',
        'icon': Icons.payment,
        'color': Colors.green,
        'route': '/accounts/payments'
      },
      {
        'title': 'Debt Collection',
        'subtitle': 'Manage overdue accounts',
        'icon': Icons.money_off,
        'color': Colors.orange,
        'route': '/accounts/collections'
      },
      {
        'title': 'Generate Reports',
        'subtitle': 'Create financial reports',
        'icon': Icons.assessment,
        'color': Colors.purple,
        'route': '/accounts/reports'
      },
      {
        'title': 'Customer Accounts',
        'subtitle': 'Manage customer data',
        'icon': Icons.people,
        'color': Colors.teal,
        'route': '/accounts/customers'
      },
      {
        'title': 'System Admin',
        'subtitle': 'System configuration',
        'icon': Icons.settings,
        'color': Colors.grey,
        'route': '/accounts/admin'
      },
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bolt, color: Color(0xFF1E3A8A), size: 20),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Frequently used actions for daily operations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildResponsiveGrid(actions, context),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Map<String, dynamic>> actions, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;

        if (screenWidth < 600) {
          crossAxisCount = 2;
        } else if (screenWidth < 900) {
          crossAxisCount = 3;
        } else if (screenWidth < 1200) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 6;
        }

        final childAspectRatio = screenWidth < 600 ? 1.1 : 1.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => _buildActionCard(actions[index]),
        );
      },
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onNavigate(action['route']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  action['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  action['subtitle'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}