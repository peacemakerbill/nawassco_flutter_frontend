import 'package:flutter/material.dart';

class DeliveryTrackingWidget extends StatelessWidget {
  const DeliveryTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveries = [
      {
        'orderNumber': 'ORD-2024-0456',
        'destination': 'Nakuru East Depot',
        'status': 'In Transit',
        'estimatedArrival': 'Today, 14:00',
        'items': 'Water Pipes (6") - 50 units',
        'driver': 'John Mwangi',
      },
      {
        'orderNumber': 'ORD-2024-0457',
        'destination': 'Bahati Water Works',
        'status': 'Scheduled',
        'estimatedArrival': 'Tomorrow, 09:00',
        'items': 'Valve Assemblies - 20 units',
        'driver': 'Peter Kamau',
      },
      {
        'orderNumber': 'ORD-2024-0455',
        'destination': 'Molo Treatment Plant',
        'status': 'Delivered',
        'estimatedArrival': 'Completed',
        'items': 'Meter Parts - 100 units',
        'driver': 'James Ochieng',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFF0066A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Delivery Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...deliveries.map((delivery) => _buildDeliveryItem(delivery)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryItem(Map<String, dynamic> delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          return isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066A1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping, color: Color(0xFF0066A1), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery['orderNumber'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(delivery['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            delivery['status'],
                            style: TextStyle(
                              color: _getStatusColor(delivery['status']),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                delivery['items'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'To: ${delivery['destination']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Driver: ${delivery['driver']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                delivery['estimatedArrival'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
              : Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066A1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping, color: Color(0xFF0066A1), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery['orderNumber'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delivery['items'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'To: ${delivery['destination']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            'Driver: ${delivery['driver']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    delivery['estimatedArrival'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      delivery['status'],
                      style: TextStyle(
                        color: _getStatusColor(delivery['status']),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'in transit' => Colors.orange,
      'scheduled' => Color(0xFF0066A1),
      'delivered' => Colors.green,
      'delayed' => Colors.red,
      _ => Colors.grey,
    };
  }
}