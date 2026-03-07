import 'package:flutter/material.dart';

import '../../../models/water_meter.model.dart';

class WaterMeterCardWidget extends StatelessWidget {
  final WaterMeter waterMeter;
  final VoidCallback onTap;

  const WaterMeterCardWidget({
    super.key,
    required this.waterMeter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: waterMeter.hasActiveAlerts
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meter Icon and Status
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: waterMeter.status.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_damage,
                      color: waterMeter.status.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Meter Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                waterMeter.meterNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: waterMeter.status.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                waterMeter.status.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: waterMeter.status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          waterMeter.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          waterMeter.location.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Metrics Row
              Row(
                children: [
                  // Type
                  _buildMetricItem(
                    icon: Icons.category,
                    label: 'Type',
                    value: waterMeter.type.displayName,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),

                  // Technology
                  _buildMetricItem(
                    icon: Icons.engineering,
                    label: 'Technology',
                    value: waterMeter.technology.displayName,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),

                  // Connectivity
                  _buildMetricItem(
                    icon: waterMeter.connectivity.icon,
                    label: 'Connectivity',
                    value: waterMeter.connectivity.displayName,
                    color: waterMeter.connectivity.color,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Service Region
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        waterMeter.serviceRegion.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  // Alerts and Battery
                  Row(
                    children: [
                      if (waterMeter.hasActiveAlerts)
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${waterMeter.activeAlerts.length} alert(s)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      if (waterMeter.battery != null)
                        Row(
                          children: [
                            Icon(
                              _getBatteryIcon(waterMeter.battery!.status),
                              size: 14,
                              color:
                                  _getBatteryColor(waterMeter.battery!.status),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${waterMeter.battery!.voltage}V',
                              style: TextStyle(
                                fontSize: 11,
                                color: _getBatteryColor(
                                    waterMeter.battery!.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),

              // Last Communication
              if (waterMeter.lastCommunication != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last seen: ${_formatTimeAgo(waterMeter.lastCommunication!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getBatteryIcon(String status) {
    switch (status) {
      case 'healthy':
        return Icons.battery_full;
      case 'low':
        return Icons.battery_alert;
      case 'critical':
        return Icons.battery_alert;
      case 'replaced':
        return Icons.battery_charging_full;
      default:
        return Icons.battery_std;
    }
  }

  Color _getBatteryColor(String status) {
    switch (status) {
      case 'healthy':
        return Colors.green;
      case 'low':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      case 'replaced':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
