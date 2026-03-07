import 'package:flutter/material.dart';

import '../../../../models/field_technician.dart';

class TechnicianStatsCard extends StatelessWidget {
  final List<FieldTechnician> technicians;

  const TechnicianStatsCard({super.key, required this.technicians});

  int get totalTechnicians => technicians.length;

  int get activeTechnicians => technicians.where((t) => t.isActive).length;

  int get availableTechnicians => technicians
      .where((t) => t.currentStatus == TechnicianStatus.available)
      .length;

  double get averagePerformance => technicians.isEmpty
      ? 0
      : technicians.map((t) => t.performanceScore).reduce((a, b) => a + b) /
          technicians.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildStatItems(theme, true),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: _buildStatItems(theme, false),
        ),
      ),
    );
  }

  List<Widget> _buildStatItems(ThemeData theme, bool isHorizontal) {
    return [
      _buildStatItem(
        'Total Technicians',
        totalTechnicians.toString(),
        Icons.people_alt_rounded,
        theme.colorScheme.primary,
        isHorizontal,
      ),
      if (isHorizontal) const SizedBox(width: 12) else const Spacer(),
      _buildStatItem(
        'Active',
        activeTechnicians.toString(),
        Icons.check_circle_rounded,
        Colors.green,
        isHorizontal,
      ),
      if (isHorizontal) const SizedBox(width: 12) else const Spacer(),
      _buildStatItem(
        'Available',
        availableTechnicians.toString(),
        Icons.person_rounded,
        Colors.blue,
        isHorizontal,
      ),
      if (isHorizontal) const SizedBox(width: 12) else const Spacer(),
      _buildStatItem(
        'Avg Performance',
        '${averagePerformance.toStringAsFixed(1)}%',
        Icons.analytics_rounded,
        Colors.orange,
        isHorizontal,
      ),
    ];
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color,
      bool isHorizontal) {
    if (isHorizontal) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
