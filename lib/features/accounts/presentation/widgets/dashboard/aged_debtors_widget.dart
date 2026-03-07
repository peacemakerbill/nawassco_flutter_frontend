import 'package:flutter/material.dart';

class AgedDebtorsWidget extends StatelessWidget {
  const AgedDebtorsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final debtData = [
      {
        'period': 'Current',
        'amount': 'KES 1,245,680',
        'count': '1,842 accounts',
        'percentage': 68.6,
        'color': Colors.green,
        'icon': Icons.check_circle
      },
      {
        'period': '1-30 Days',
        'amount': 'KES 285,420',
        'count': '156 accounts',
        'percentage': 15.7,
        'color': Colors.blue,
        'icon': Icons.schedule
      },
      {
        'period': '31-60 Days',
        'amount': 'KES 148,950',
        'count': '42 accounts',
        'percentage': 8.2,
        'color': Colors.orange,
        'icon': Icons.warning_amber
      },
      {
        'period': '61-90 Days',
        'amount': 'KES 89,670',
        'count': '18 accounts',
        'percentage': 4.9,
        'color': Colors.red,
        'icon': Icons.error_outline
      },
      {
        'period': '90+ Days',
        'amount': 'KES 45,230',
        'count': '8 accounts',
        'percentage': 2.5,
        'color': Colors.purple,
        'icon': Icons.dangerous
      },
    ];

    final totalAmount = 'KES 1,814,950';
    final collectionEfficiency = 94.2;
    const targetEfficiency = 95.0;

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
                    Icon(Icons.analytics, color: Color(0xFF0D47A1), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Aged Debtors Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
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
                  child: Text(
                    'Total: $totalAmount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bars for each debt period
            ...debtData.map((data) => _buildDebtProgressRow(data)),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Efficiency metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collection Efficiency',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$collectionEfficiency%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: collectionEfficiency >= targetEfficiency
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ $targetEfficiency%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: collectionEfficiency / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          collectionEfficiency >= targetEfficiency
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${collectionEfficiency.toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtProgressRow(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'],
              color: data['color'],
              size: 18,
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
                    Text(
                      data['period'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      data['amount'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['count'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${data['percentage']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: data['percentage'] / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(data['color']),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}