import 'package:flutter/material.dart';

import '../../../utils/service_catalog/service_constants.dart';

class ServiceStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final int totalServices;
  final int activeServices;

  const ServiceStatsWidget({
    super.key,
    required this.stats,
    required this.totalServices,
    required this.activeServices,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.1),
            theme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Service Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overview Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard(
                context: context,
                label: 'Total Services',
                value: totalServices.toString(),
                icon: Icons.grid_view,
                color: Colors.blue,
              ),
              _buildStatCard(
                context: context,
                label: 'Active Services',
                value: activeServices.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                context: context,
                label: 'Categories',
                value: (stats['byCategory']?.length ?? 0).toString(),
                icon: Icons.category,
                color: Colors.purple,
              ),
              _buildStatCard(
                context: context,
                label: 'Avg Price',
                value: ServiceConstants.formatCurrency(
                  (stats['pricing']?['avgPrice'] ?? 0).toDouble(),
                ),
                icon: Icons.monetization_on,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category Breakdown
          if (stats['byCategory'] != null && (stats['byCategory'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services by Category',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...(stats['byCategory'] as List).map((category) {
                  return _buildCategoryBar(
                    context: context,
                    category: category['_id'] ?? 'Unknown',
                    count: category['count'] ?? 0,
                    active: category['active'] ?? 0,
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar({
    required BuildContext context,
    required String category,
    required int count,
    required int active,
  }) {
    final percentage = count > 0 ? (active / count) * 100 : 0;
    final displayName = category.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$active/$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: percentage * 2, // Assuming max count is 50 for 100% width
                decoration: BoxDecoration(
                  color: percentage > 80 ? Colors.green : percentage > 50 ? Colors.orange : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}