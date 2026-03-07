import 'package:flutter/material.dart';

class TenderOpportunitiesWidget extends StatelessWidget {
  final Function(String) onNavigate;

  const TenderOpportunitiesWidget({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tenders = [
      {
        'id': 'TDR-2024-001',
        'title': 'Water Pipe Supply - 6 inch HDPE',
        'deadline': '2024-03-15',
        'status': 'Open',
        'value': 'KES 2.5M',
        'category': 'Pipes & Fittings',
      },
      {
        'id': 'TDR-2024-002',
        'title': 'Water Meter Supply - Digital Smart Meters',
        'deadline': '2024-03-20',
        'status': 'Open',
        'value': 'KES 1.8M',
        'category': 'Meters',
      },
      {
        'id': 'TDR-2024-003',
        'title': 'Valve Replacement Parts',
        'deadline': '2024-03-10',
        'status': 'Closing Soon',
        'value': 'KES 850K',
        'category': 'Valves',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment, color: Color(0xFF0066A1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Active Tender Opportunities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066A1),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigate('/supplier/tenders'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0066A1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tenders.map((tender) => _buildTenderItem(tender)),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderItem(Map<String, dynamic> tender) {
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
                    child: const Icon(Icons.assignment, color: Color(0xFF0066A1), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tender['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(tender['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tender['status'],
                            style: TextStyle(
                              color: _getStatusColor(tender['status']),
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildTenderDetail('ID: ${tender['id']}'),
                  _buildTenderDetail('Value: ${tender['value']}'),
                  _buildTenderDetail('Category: ${tender['category']}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Deadline: ${tender['deadline']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
                child: const Icon(Icons.assignment, color: Color(0xFF0066A1), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tender['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildTenderDetail('ID: ${tender['id']}'),
                        _buildTenderDetail('Value: ${tender['value']}'),
                        _buildTenderDetail('Category: ${tender['category']}'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tender['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tender['status'],
                      style: TextStyle(
                        color: _getStatusColor(tender['status']),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: ${tender['deadline']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  Widget _buildTenderDetail(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'open' => Color(0xFF0066A1),
      'closing soon' => Colors.orange,
      'closed' => Colors.red,
      _ => Colors.grey,
    };
  }
}