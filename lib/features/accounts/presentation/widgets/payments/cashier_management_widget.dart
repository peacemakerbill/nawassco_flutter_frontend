import 'package:flutter/material.dart';

class CashierManagementWidget extends StatefulWidget {
  final Function(String, DateTime) onGenerateReport;

  const CashierManagementWidget({super.key, required this.onGenerateReport});

  @override
  State<CashierManagementWidget> createState() => _CashierManagementWidgetState();
}

class _CashierManagementWidgetState extends State<CashierManagementWidget> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCashier = 'all';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cashier Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Date and Cashier Selection
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                        text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCashier,
                    decoration: const InputDecoration(
                      labelText: 'Cashier',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Cashiers')),
                      DropdownMenuItem(value: 'cashier1', child: Text('Cashier 001 - John Mwangi')),
                      DropdownMenuItem(value: 'cashier2', child: Text('Cashier 002 - Mary Wambui')),
                      DropdownMenuItem(value: 'cashier3', child: Text('Cashier 003 - Peter Ochieng')),
                    ],
                    onChanged: (value) => setState(() => _selectedCashier = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Summary
            _buildDailySummary(),
            const SizedBox(height: 20),

            // Cashier Performance
            _buildCashierPerformance(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary() {
    final summaryData = {
      'totalCollections': 'KES 245,680',
      'cashTransactions': '45',
      'digitalTransactions': '89',
      'averageTransaction': 'KES 1,835',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Collection Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              _buildSummaryItem('Total Collections', summaryData['totalCollections']!, Icons.attach_money),
              _buildSummaryItem('Cash Transactions', summaryData['cashTransactions']!, Icons.money),
              _buildSummaryItem('Digital Transactions', summaryData['digitalTransactions']!, Icons.phone_android),
              _buildSummaryItem('Average Transaction', summaryData['averageTransaction']!, Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashierPerformance() {
    final cashiers = [
      {'name': 'John Mwangi', 'collections': 'KES 89,450', 'transactions': '32', 'efficiency': '98.2%'},
      {'name': 'Mary Wambui', 'collections': 'KES 78,230', 'transactions': '28', 'efficiency': '96.5%'},
      {'name': 'Peter Ochieng', 'collections': 'KES 68,000', 'transactions': '25', 'efficiency': '95.8%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cashier Performance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...cashiers.map((cashier) => _buildCashierRow(cashier)),
      ],
    );
  }

  Widget _buildCashierRow(Map<String, String> cashier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1E3A8A),
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cashier['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('Collections: ${cashier['collections']} • Transactions: ${cashier['transactions']}'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cashier['efficiency']!,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generateZRead,
            icon: const Icon(Icons.receipt),
            label: const Text('GENERATE Z-READ'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _viewDetailedReport,
            icon: const Icon(Icons.assessment),
            label: const Text('DETAILED REPORT'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _closeDay,
            icon: const Icon(Icons.lock_clock),
            label: const Text('CLOSE DAY'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _generateZRead() {
    widget.onGenerateReport(_selectedCashier, _selectedDate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Z-Read report generated')),
    );
  }

  void _viewDetailedReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening detailed report...')),
    );
  }

  void _closeDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Business Day'),
        content: const Text('Are you sure you want to close the business day? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Business day closed successfully')),
              );
            },
            child: const Text('CLOSE DAY'),
          ),
        ],
      ),
    );
  }
}