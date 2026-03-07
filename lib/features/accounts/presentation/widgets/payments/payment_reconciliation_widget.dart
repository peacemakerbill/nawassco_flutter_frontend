import 'package:flutter/material.dart';

class PaymentReconciliationWidget extends StatefulWidget {
  final Function(String, String) onReconcile;

  const PaymentReconciliationWidget({super.key, required this.onReconcile});

  @override
  State<PaymentReconciliationWidget> createState() => _PaymentReconciliationWidgetState();
}

class _PaymentReconciliationWidgetState extends State<PaymentReconciliationWidget> {
  String _statementType = 'mpesa';
  String _reconciliationStatus = 'pending';

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
              'Payment Reconciliation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Statement Type Selection
            Row(
              children: [
                Expanded(
                  child: _buildStatementTypeCard(
                    'M-Pesa',
                    'Reconcile M-Pesa statements',
                    Icons.phone_android,
                    'mpesa',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatementTypeCard(
                    'Bank',
                    'Reconcile bank statements',
                    Icons.account_balance,
                    'bank',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // File Upload
            _buildFileUploadSection(),
            const SizedBox(height: 20),

            // Reconciliation Summary
            _buildReconciliationSummary(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementTypeCard(String title, String subtitle, IconData icon, String type) {
    final isSelected = _statementType == type;
    return Card(
      color: isSelected ? const Color(0xFF1E3A8A).withOpacity(0.1) : null,
      elevation: isSelected ? 2 : 1,
      child: InkWell(
        onTap: () => setState(() => _statementType = type),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.black,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Upload Statement File',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _statementType == 'mpesa'
                ? 'Upload M-Pesa statement (CSV format)'
                : 'Upload bank statement (Excel/CSV format)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _uploadFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('SELECT FILE'),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationSummary() {
    final summaryData = {
      'totalTransactions': '145',
      'matchedPayments': '138',
      'unmatchedPayments': '7',
      'reconciliationRate': '95.2%',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reconciliation Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', summaryData['totalTransactions']!),
              _buildSummaryItem('Matched', summaryData['matchedPayments']!),
              _buildSummaryItem('Unmatched', summaryData['unmatchedPayments']!),
              _buildSummaryItem('Rate', summaryData['reconciliationRate']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _runPreview,
            child: const Text('PREVIEW RECONCILIATION'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _runReconciliation,
            child: const Text('RUN RECONCILIATION'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _uploadFile() {
    // Simulate file upload
    setState(() => _reconciliationStatus = 'uploaded');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File uploaded successfully')),
    );
  }

  void _runPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reconciliation preview generated')),
    );
  }

  void _runReconciliation() {
    widget.onReconcile(_statementType, 'statement_file.csv');
    setState(() => _reconciliationStatus = 'completed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reconciliation completed successfully')),
    );
  }
}