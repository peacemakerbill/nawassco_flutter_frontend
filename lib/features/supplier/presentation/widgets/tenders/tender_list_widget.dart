import 'package:flutter/material.dart';

class TenderListWidget extends StatelessWidget {
  const TenderListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tenders = [
      {
        'id': 'TDR-2024-001',
        'title': 'Water Pipe Supply - 6 inch HDPE',
        'description': 'Supply of high-density polyethylene pipes for water distribution network',
        'deadline': '2024-03-15',
        'value': 'KES 2,500,000',
        'category': 'Pipes & Fittings',
        'status': 'Open',
        'documents': 5,
      },
      {
        'id': 'TDR-2024-002',
        'title': 'Water Meter Supply - Digital Smart Meters',
        'description': 'Supply and installation of digital smart water meters',
        'deadline': '2024-03-20',
        'value': 'KES 1,800,000',
        'category': 'Meters',
        'status': 'Open',
        'documents': 3,
      },
      {
        'id': 'TDR-2024-003',
        'title': 'Valve Replacement Parts',
        'description': 'Supply of gate valves and replacement parts for existing infrastructure',
        'deadline': '2024-03-10',
        'value': 'KES 850,000',
        'category': 'Valves',
        'status': 'Closing Soon',
        'documents': 4,
      },
      {
        'id': 'TDR-2024-004',
        'title': 'Water Treatment Chemicals',
        'description': 'Supply of chlorine and other water treatment chemicals',
        'deadline': '2024-02-28',
        'value': 'KES 1,200,000',
        'category': 'Chemicals',
        'status': 'Closed',
        'documents': 2,
      },
    ];

    return ListView.builder(
      itemCount: tenders.length,
      itemBuilder: (context, index) => _buildTenderCard(tenders[index]),
    );
  }

  Widget _buildTenderCard(Map<String, dynamic> tender) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tender['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066A1),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tender['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tender['status'],
                    style: TextStyle(
                      color: _getStatusColor(tender['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tender['description'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return isMobile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTenderDetail(Icons.category, tender['category']),
                    const SizedBox(height: 8),
                    _buildTenderDetail(Icons.attach_money, tender['value']),
                    const SizedBox(height: 8),
                    _buildTenderDetail(Icons.today, 'Deadline: ${tender['deadline']}'),
                    const SizedBox(height: 8),
                    _buildTenderDetail(Icons.description, '${tender['documents']} docs'),
                  ],
                )
                    : Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildTenderDetail(Icons.category, tender['category']),
                    _buildTenderDetail(Icons.attach_money, tender['value']),
                    _buildTenderDetail(Icons.today, 'Deadline: ${tender['deadline']}'),
                    _buildTenderDetail(Icons.description, '${tender['documents']} docs'),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 400;
                return isMobile
                    ? Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066A1),
                        side: const BorderSide(color: Color(0xFF0066A1)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                      label: const Text('Apply Now', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066A1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066A1),
                          side: const BorderSide(color: Color(0xFF0066A1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                        label: const Text('Apply Now', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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