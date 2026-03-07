import 'package:flutter/material.dart';

class KPIMetricsGrid extends StatelessWidget {
  final Function(String) onNavigate;

  const KPIMetricsGrid({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {
        'label': 'Water Production',
        'value': '18,240 m³',
        'change': '+1.2%',
        'icon': Icons.water_drop,
        'color': Color(0xFF0066CC),
        'route': '/manager/water-supply',
      },
      {
        'label': 'Revenue Collection',
        'value': 'KES 12.4M',
        'change': '+5.1%',
        'icon': Icons.attach_money,
        'color': Color(0xFF00B894),
        'route': '/manager/commercial',
      },
      {
        'label': 'System Efficiency',
        'value': '78.5%',
        'change': '-0.8%',
        'icon': Icons.analytics,
        'color': Color(0xFF6C5CE7),
        'route': '/manager/nrw',
      },
      {
        'label': 'Customer Satisfaction',
        'value': '92%',
        'change': '+2.1%',
        'icon': Icons.thumb_up,
        'color': Color(0xFFFD79A8),
        'route': '/manager/customer-service',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else if (screenWidth < 900) {
      // Tablet
      crossAxisCount = 2;
      childAspectRatio = 1.8;
    } else if (screenWidth < 1200) {
      // Small desktop
      crossAxisCount = 4;
      childAspectRatio = 1.0;
    } else {
      // Large desktop
      crossAxisCount = 4;
      childAspectRatio = 1.1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(metric);
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return GestureDetector(
      onTap: () => onNavigate(metric['route']),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        color: metric['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(metric['icon'], color: metric['color'], size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: metric['change'].startsWith('+')
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metric['change'],
                        style: TextStyle(
                          color: metric['change'].startsWith('+')
                              ? Colors.green
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric['value'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}