import 'package:flutter/material.dart';

class QuotationHistoryWidget extends StatelessWidget {
  const QuotationHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final quotations = [
      {
        'id': 'QTN-2024-001',
        'tenderId': 'TDR-2024-001',
        'tenderTitle': 'Water Pipe Supply - 6 inch HDPE',
        'submittedDate': '2024-02-10',
        'amount': 'KES 2,450,000',
        'status': 'Under Review',
        'validity': '30 days',
      },
      {
        'id': 'QTN-2024-002',
        'tenderId': 'TDR-2024-003',
        'tenderTitle': 'Valve Replacement Parts',
        'submittedDate': '2024-02-05',
        'amount': 'KES 820,000',
        'status': 'Submitted',
        'validity': '45 days',
      },
      {
        'id': 'QTN-2024-003',
        'tenderId': 'TDR-2024-005',
        'tenderTitle': 'Water Treatment Chemicals',
        'submittedDate': '2024-01-28',
        'amount': 'KES 1,150,000',
        'status': 'Rejected',
        'validity': '30 days',
      },
      {
        'id': 'QTN-2024-004',
        'tenderId': 'TDR-2024-002',
        'tenderTitle': 'Water Meter Supply',
        'submittedDate': '2024-01-20',
        'amount': 'KES 1,750,000',
        'status': 'Accepted',
        'validity': '60 days',
      },
    ];

    return Column(
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF0066A1), size: 22), // Smaller icon
                    SizedBox(width: 10), // Reduced spacing
                    Text(
                      'Quotation History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700), // Smaller font
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  'View the status and history of your submitted quotations.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13, // Smaller font
                  ),
                ),
                const SizedBox(height: 12), // Reduced spacing
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return isMobile
                        ? Column(
                      children: [
                        // Compact search field for mobile
                        SizedBox(
                          height: 48, // Fixed compact height
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Search quotations...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search, size: 20), // Smaller icon
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Tighter padding
                              isDense: true, // Makes the field more compact
                            ),
                            style: TextStyle(fontSize: 14), // Smaller text
                          ),
                        ),
                        const SizedBox(height: 12), // Reduced spacing
                        // Compact dropdown for mobile
                        SizedBox(
                          height: 48, // Fixed compact height
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                              labelText: 'Filter by Status',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Tighter padding
                              isDense: true, // Makes the field more compact
                            ),
                            style: TextStyle(fontSize: 14), // Smaller text
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Status', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: 'submitted', child: Text('Submitted', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: 'under_review', child: Text('Under Review', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: 'accepted', child: Text('Accepted', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: 'rejected', child: Text('Rejected', style: TextStyle(fontSize: 14))),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Search quotations...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                              labelText: 'Filter by Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Status')),
                              DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                              DropdownMenuItem(value: 'under_review', child: Text('Under Review')),
                              DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              itemCount: quotations.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildQuotationCard(quotations[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationCard(Map<String, dynamic> quotation) {
    return Card(
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
                    quotation['tenderTitle'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(quotation['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quotation['status'],
                    style: TextStyle(
                      color: _getStatusColor(quotation['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Quotation ID: ${quotation['id']}'),
            Text('Tender ID: ${quotation['tenderId']}'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return isMobile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Amount', quotation['amount']),
                    const SizedBox(height: 8),
                    _buildDetailItem('Submitted', quotation['submittedDate']),
                    const SizedBox(height: 8),
                    _buildDetailItem('Validity', quotation['validity']),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: _buildDetailItem('Amount', quotation['amount'])),
                    Expanded(child: _buildDetailItem('Submitted', quotation['submittedDate'])),
                    Expanded(child: _buildDetailItem('Validity', quotation['validity'])),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 400;
                return isMobile
                    ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066A1),
                          side: const BorderSide(color: Color(0xFF0066A1)),
                          padding: const EdgeInsets.symmetric(vertical: 10), // Smaller button
                        ),
                        child: const Text('VIEW DETAILS', style: TextStyle(fontSize: 13)), // Smaller text
                      ),
                    ),
                    if (quotation['status'] == 'Accepted') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10), // Smaller button
                          ),
                          child: const Text('CREATE PO', style: TextStyle(fontSize: 13)), // Smaller text
                        ),
                      ),
                    ],
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066A1),
                          side: const BorderSide(color: Color(0xFF0066A1)),
                        ),
                        child: const Text('VIEW DETAILS'),
                      ),
                    ),
                    if (quotation['status'] == 'Accepted') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066A1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CREATE PO'),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'accepted' => Color(0xFF0066A1),
      'under review' => Colors.orange,
      'submitted' => Colors.blue,
      'rejected' => Colors.red,
      _ => Colors.grey,
    };
  }
}