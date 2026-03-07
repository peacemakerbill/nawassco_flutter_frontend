import 'package:flutter/material.dart';

import '../../../models/water_source_model.dart';

class WaterSourceCard extends StatelessWidget {
  final WaterSource waterSource;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const WaterSourceCard({
    Key? key,
    required this.waterSource,
    required this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        waterSource.status.color.withValues(alpha: 0.1),
                    child: Text(
                      waterSource.type.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waterSource.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          waterSource.type.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      waterSource.status.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: waterSource.status.color,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Location info
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      waterSource.location.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Capacity and quality indicators
              Row(
                children: [
                  // Capacity indicator
                  Expanded(
                    child: _buildIndicator(
                      icon: Icons.water_damage,
                      label: 'Capacity',
                      value:
                          '${waterSource.capacity.dailyYield.toStringAsFixed(0)} m³/day',
                      color: Colors.blue,
                      percentage: waterSource.capacity.utilizationRate / 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quality indicator
                  Expanded(
                    child: _buildIndicator(
                      icon: Icons.health_and_safety,
                      label: 'Quality',
                      value: waterSource.quality.qualityGrade.displayName,
                      color: waterSource.quality.qualityGrade.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Usage bar
              _buildUsageBar(context),
              const SizedBox(height: 8),
              // Footer with alerts and actions
              Row(
                children: [
                  // Active alerts
                  if (waterSource.monitoring.activeAlerts.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${waterSource.monitoring.activeAlerts.length} active alert(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  // Favorite button
                  if (onToggleFavorite != null)
                    IconButton(
                      icon: Icon(
                        waterSource.isFavorite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: waterSource.isFavorite == true
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: onToggleFavorite,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  // Actions for admin/manager
                  if (showActions && (onEdit != null || onDelete != null))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) onEdit!();
                        if (value == 'delete' && onDelete != null) onDelete!();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    double? percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (percentage != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageBar(BuildContext context) {
    final capacity = waterSource.capacity;
    final usagePercentage = capacity.dailyYield > 0
        ? capacity.currentUsage / capacity.dailyYield
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${usagePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: usagePercentage > 0.8 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: usagePercentage.toDouble(),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            usagePercentage > 0.8
                ? Colors.red
                : usagePercentage > 0.6
                    ? Colors.orange
                    : Colors.green,
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${capacity.currentUsage.toStringAsFixed(0)} m³ used',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${capacity.availableCapacity.toStringAsFixed(0)} m³ available',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
