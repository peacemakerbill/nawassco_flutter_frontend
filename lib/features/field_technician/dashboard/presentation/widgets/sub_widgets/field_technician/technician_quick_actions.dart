import 'package:flutter/material.dart';

import '../../../../models/field_technician.dart';

class TechnicianQuickActions extends StatelessWidget {
  final FieldTechnician technician;

  const TechnicianQuickActions({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    final actions = [
      _QuickAction(
        icon: Icons.assignment_rounded,
        label: 'Work Orders',
        color: Colors.blue,
        onTap: () {
          // Navigate to work orders
        },
      ),
      _QuickAction(
        icon: Icons.map_rounded,
        label: 'Service Area',
        color: Colors.green,
        onTap: () {
          // Navigate to map
        },
      ),
      _QuickAction(
        icon: Icons.analytics_rounded,
        label: 'Reports',
        color: Colors.orange,
        onTap: () {
          // Navigate to reports
        },
      ),
      _QuickAction(
        icon: Icons.handyman_rounded,
        label: 'Tools',
        color: Colors.purple,
        onTap: () {
          // Navigate to tools
        },
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: actions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => actions[index],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}