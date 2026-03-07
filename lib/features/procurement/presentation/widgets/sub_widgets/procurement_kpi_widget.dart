import 'package:flutter/material.dart';

class ProcurementKPIWidget extends StatelessWidget {
  const ProcurementKPIWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Procurement Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _getChildAspectRatio(context),
          children: [
            _buildKPICard(
              'Active Tenders',
              '24',
              Icons.assignment,
              Colors.blue,
              '12 awaiting evaluation',
            ),
            _buildKPICard(
              'Pending POs',
              '8',
              Icons.shopping_cart,
              Colors.orange,
              'KES 12.4M total value',
            ),
            _buildKPICard(
              'Active Contracts',
              '18',
              Icons.feed,
              Colors.green,
              '5 expiring soon',
            ),
            _buildKPICard(
              'Monthly Spend',
              'KES 48.7M',
              Icons.attach_money,
              Colors.purple,
              '+12% from last month',
            ),
            _buildKPICard(
              'YTD Spend',
              'KES 245.3M',
              Icons.trending_up,
              Colors.teal,
              'On track with budget',
            ),
            _buildKPICard(
              'Suppliers',
              '156',
              Icons.business,
              Colors.indigo,
              '142 active suppliers',
            ),
            _buildKPICard(
              'Cost Savings',
              'KES 18.2M',
              Icons.savings,
              Colors.green,
              '7.4% savings rate',
            ),
            _buildKPICard(
              'On-time Delivery',
              '94%',
              Icons.local_shipping,
              Colors.blue,
              '+2% from last quarter',
            ),
          ],
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.2;
    if (width > 800) return 1.3;
    if (width > 600) return 1.4;
    return 1.6;
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}