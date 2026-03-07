import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onNavigate;

  const QuickActionsGrid({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Water Supply',
        'icon': Icons.water_drop,
        'color': Color(0xFF0066CC),
        'route': '/manager/water-supply',
      },
      {
        'label': 'NRW Analysis',
        'icon': Icons.analytics,
        'color': Color(0xFF00B894),
        'route': '/manager/nrw',
      },
      {
        'label': 'Commercial',
        'icon': Icons.attach_money,
        'color': Color(0xFF00CEA6),
        'route': '/manager/commercial',
      },
      {
        'label': 'Customer Service',
        'icon': Icons.support_agent,
        'color': Color(0xFF6C5CE7),
        'route': '/manager/customer-service',
      },
      {
        'label': 'Projects',
        'icon': Icons.construction,
        'color': Color(0xFFA29BFE),
        'route': '/manager/projects',
      },
      {
        'label': 'GIS Network',
        'icon': Icons.map,
        'color': Color(0xFFFD79A8),
        'route': '/manager/gis',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;
    double iconSize;
    double fontSize;

    if (screenWidth < 480) {
      // Small mobile
      crossAxisCount = 3;
      childAspectRatio = 1.0;
      iconSize = 20;
      fontSize = 10;
    } else if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 3;
      childAspectRatio = 1.0;
      iconSize = 22;
      fontSize = 11;
    } else if (screenWidth < 900) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 1.2;
      iconSize = 24;
      fontSize = 12;
    } else if (screenWidth < 1200) {
      // Small desktop
      crossAxisCount = 6;
      childAspectRatio = 0.9;
      iconSize = 22;
      fontSize = 11;
    } else {
      // Large desktop
      crossAxisCount = 6;
      childAspectRatio = 1.0;
      iconSize = 24;
      fontSize = 12;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Color(0xFF0066CC), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildQuickActionItem(action, iconSize, fontSize);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(Map<String, dynamic> action, double iconSize, double fontSize) {
    return GestureDetector(
      onTap: () => onNavigate(action['route']),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: action['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: action['color'].withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(action['icon'], color: action['color'], size: iconSize),
              ),
              const SizedBox(height: 6),
              Text(
                action['label'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
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