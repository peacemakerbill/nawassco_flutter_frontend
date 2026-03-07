import 'package:flutter/material.dart';

class SupplierKPIWidget extends StatelessWidget {
  const SupplierKPIWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = [
      {
        'title': 'Active Tenders',
        'value': '8',
        'change': '+2',
        'isPositive': true,
        'icon': Icons.assignment,
        'color': Color(0xFF0066A1),
        'trend': 'this month',
      },
      {
        'title': 'Pending POs',
        'value': '3',
        'change': '-1',
        'isPositive': true,
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
        'trend': 'vs last week',
      },
      {
        'title': 'Total Revenue',
        'value': 'KES 2.4M',
        'change': '+15.2%',
        'isPositive': true,
        'icon': Icons.attach_money,
        'color': Colors.green,
        'trend': 'this quarter',
      },
      {
        'title': 'Pending Invoices',
        'value': '5',
        'change': '+2',
        'isPositive': false,
        'icon': Icons.receipt,
        'color': Colors.red,
        'trend': 'needs attention',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;

        if (screenWidth < 600) {
          crossAxisCount = 2;
        } else if (screenWidth < 900) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 4;
        }

        final childAspectRatio = screenWidth < 600 ? 1.4 : 1.1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _buildKPICard(kpis[index]),
        );
      },
    );
  }

  Widget _buildKPICard(Map<String, dynamic> kpi) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kpi['color'].withOpacity(0.05),
            kpi['color'].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kpi['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kpi['color'].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(kpi['icon'], color: kpi['color'], size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kpi['isPositive']
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kpi['isPositive']
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kpi['isPositive'] ? Icons.arrow_upward : Icons.arrow_downward,
                        color: kpi['isPositive'] ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          kpi['change'],
                          style: TextStyle(
                            color: kpi['isPositive'] ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                kpi['value'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0066A1),
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                kpi['title'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                kpi['trend'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}