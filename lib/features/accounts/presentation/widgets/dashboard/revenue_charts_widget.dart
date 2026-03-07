import 'package:flutter/material.dart';

class RevenueChartsWidget extends StatelessWidget {
  const RevenueChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        if (screenWidth < 768) {
          return Column(
            children: [
              _buildRevenueChart(),
              const SizedBox(height: 16),
              _buildRevenueBreakdown(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildRevenueChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildRevenueBreakdown(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRevenueChart() {
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
            const Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF0D47A1), size: 22),
                SizedBox(width: 8),
                Text(
                  'Revenue Trend - Last 6 Months',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D47A1).withOpacity(0.02),
                    const Color(0xFF0D47A1).withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 52,
                        color: Color(0xFF0D47A1)),
                    SizedBox(height: 12),
                    Text(
                      'Interactive Revenue Chart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Monthly revenue trends with comparisons',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                _ChartLegend('Current Month', Colors.blue, Icons.circle),
                _ChartLegend('Previous Month', Colors.grey, Icons.circle),
                _ChartLegend('Target', Colors.orange, Icons.flag),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final breakdown = [
      {
        'category': 'Water Sales',
        'amount': 'KES 2.8M',
        'percentage': 65,
        'color': Colors.blue,
        'icon': Icons.water_drop
      },
      {
        'category': 'Sewerage',
        'amount': 'KES 850K',
        'percentage': 20,
        'color': Colors.green,
        'icon': Icons.engineering
      },
      {
        'category': 'Connection Fees',
        'amount': 'KES 350K',
        'percentage': 8,
        'color': Colors.orange,
        'icon': Icons.plumbing
      },
      {
        'category': 'Penalties',
        'amount': 'KES 200K',
        'percentage': 5,
        'color': Colors.red,
        'icon': Icons.gavel
      },
      {
        'category': 'Other Income',
        'amount': 'KES 100K',
        'percentage': 2,
        'color': Colors.purple,
        'icon': Icons.more_horiz
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
            const Row(
              children: [
                Icon(Icons.pie_chart, color: Color(0xFF0D47A1), size: 22),
                SizedBox(width: 8),
                Text(
                  'Revenue Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...breakdown.map((item) => _buildBreakdownItem(item)),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'KES 4.3M',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'],
              color: item['color'],
              size: 20,
            ),
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
                        item['category'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item['amount'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: item['percentage'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(item['color']),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item['percentage']}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
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

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ChartLegend(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}