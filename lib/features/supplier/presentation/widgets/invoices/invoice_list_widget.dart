import 'package:flutter/material.dart';

class InvoiceListWidget extends StatelessWidget {
  const InvoiceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingInvoices = [
      {
        'invoiceNumber': 'INV-2024-00125',
        'date': '2024-02-18',
        'dueDate': '2024-03-04',
        'amount': 'KES 450,000',
        'poNumber': 'PO-2024-00123',
        'status': 'Pending',
        'daysOverdue': 0,
      },
      {
        'invoiceNumber': 'INV-2024-00124',
        'date': '2024-02-15',
        'dueDate': '2024-02-29',
        'amount': 'KES 280,000',
        'poNumber': 'PO-2024-00124',
        'status': 'Overdue',
        'daysOverdue': 3,
      },
      {
        'invoiceNumber': 'INV-2024-00122',
        'date': '2024-02-10',
        'dueDate': '2024-02-24',
        'amount': 'KES 120,000',
        'poNumber': 'PO-2024-00125',
        'status': 'Pending',
        'daysOverdue': 0,
      },
    ];

    return Column(
      children: [
        Card(
          elevation: 3,
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
                    Icon(Icons.pending_actions, color: Color(0xFF0066A1), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Pending Invoices',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your pending invoices and follow up on payments.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return isMobile
                        ? Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Search invoices...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            labelText: 'Filter by Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Status')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                            DropdownMenuItem(value: 'paid', child: Text('Paid')),
                          ],
                          onChanged: (value) {},
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Search invoices...',
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
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                              DropdownMenuItem(value: 'paid', child: Text('Paid')),
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
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: pendingInvoices.length,
            itemBuilder: (context, index) => _buildInvoiceCard(pendingInvoices[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
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
                Text(
                  invoice['invoiceNumber'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066A1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice['status'],
                    style: TextStyle(
                      color: _getStatusColor(invoice['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Purchase Order: ${invoice['poNumber']}'),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return isMobile
                    ? Column(
                  children: [
                    _buildInvoiceDetail('Invoice Date:', invoice['date']),
                    const SizedBox(height: 8),
                    _buildInvoiceDetail('Due Date:', invoice['dueDate']),
                    const SizedBox(height: 8),
                    _buildInvoiceDetail('Amount:', invoice['amount']),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: _buildInvoiceDetail('Invoice Date:', invoice['date'])),
                    Expanded(child: _buildInvoiceDetail('Due Date:', invoice['dueDate'])),
                    Expanded(child: _buildInvoiceDetail('Amount:', invoice['amount'])),
                  ],
                );
              },
            ),
            if (invoice['daysOverdue'] > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[800], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${invoice['daysOverdue']} days overdue',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 400;
                return isMobile
                    ? Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066A1),
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF0066A1)),
                      ),
                      child: const Text('VIEW INVOICE'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text('SEND REMINDER'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066A1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('RECORD PAYMENT'),
                    ),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('VIEW INVOICE'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('SEND REMINDER'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('RECORD PAYMENT'),
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

  Widget _buildInvoiceDetail(String label, String value) {
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
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => Color(0xFF0066A1),
      'overdue' => Colors.red,
      'paid' => Colors.green,
      'cancelled' => Colors.grey,
      _ => Colors.blue,
    };
  }
}