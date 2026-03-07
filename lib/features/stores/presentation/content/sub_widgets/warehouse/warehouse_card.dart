import 'package:flutter/material.dart';
import '../../../../models/warehouse_model.dart';

class WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewUtilization;

  const WarehouseCard({
    super.key,
    required this.warehouse,
    required this.onTap,
    required this.onEdit,
    required this.onViewUtilization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(warehouse.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(warehouse.status),
                      color: _getStatusColor(warehouse.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse.warehouseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          warehouse.warehouseCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, size: 18),
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'utilization',
                        child: Row(
                          children: [
                            const Icon(Icons.analytics_rounded, size: 18),
                            const SizedBox(width: 8),
                            const Text('View Utilization'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'utilization') {
                        onViewUtilization();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${warehouse.address.city}, ${warehouse.address.country}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Capacity and Utilization
              _buildCapacityRow(theme),
              const SizedBox(height: 8),

              // Zones
              _buildZonesInfo(theme),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(warehouse.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      warehouse.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(warehouse.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Updated ${_formatDate(warehouse.updatedAt)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityRow(ThemeData theme) {
    final utilizationPercentage = warehouse.capacity.totalArea > 0
        ? (warehouse.capacity.currentUtilization / warehouse.capacity.totalArea) * 100
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity Utilization',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${utilizationPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getUtilizationColor(utilizationPercentage.toDouble()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: utilizationPercentage / 100,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          color: _getUtilizationColor(utilizationPercentage.toDouble()),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${warehouse.capacity.currentUtilization.toStringAsFixed(0)} / ${warehouse.capacity.totalArea.toStringAsFixed(0)} m²',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              '${warehouse.zones.length} zones',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZonesInfo(ThemeData theme) {
    final zoneTypes = warehouse.zones.map((zone) => zone.zoneType).toSet();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: zoneTypes.take(3).map((zoneType) {
        final count = warehouse.zones.where((z) => z.zoneType == zoneType).length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            '${_abbreviateZoneType(zoneType)}: $count',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL:
        return Colors.green;
      case WarehouseStatus.UNDER_MAINTENANCE:
        return Colors.orange;
      case WarehouseStatus.CLOSED:
        return Colors.red;
      case WarehouseStatus.UNDER_CONSTRUCTION:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL:
        return Icons.check_circle_rounded;
      case WarehouseStatus.UNDER_MAINTENANCE:
        return Icons.build_rounded;
      case WarehouseStatus.CLOSED:
        return Icons.close_rounded;
      case WarehouseStatus.UNDER_CONSTRUCTION:
        return Icons.construction_rounded;
    }
  }

  Color _getUtilizationColor(double percentage) {
    if (percentage < 70) return Colors.green;
    if (percentage < 85) return Colors.orange;
    return Colors.red;
  }

  String _abbreviateZoneType(ZoneType zoneType) {
    switch (zoneType) {
      case ZoneType.BULK_STORAGE:
        return 'Bulk';
      case ZoneType.RACK_STORAGE:
        return 'Rack';
      case ZoneType.COLD_STORAGE:
        return 'Cold';
      case ZoneType.HAZARDOUS:
        return 'Haz';
      case ZoneType.PICKING:
        return 'Pick';
      case ZoneType.RECEIVING:
        return 'Recv';
      case ZoneType.DISPATCH:
        return 'Disp';
      case ZoneType.QUARANTINE:
        return 'Quar';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}