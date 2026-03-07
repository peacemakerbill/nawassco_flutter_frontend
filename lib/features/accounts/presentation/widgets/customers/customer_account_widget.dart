import 'package:flutter/material.dart';

class CustomerAccountWidget extends StatelessWidget {
  final Map<String, dynamic> customer;
  final Function(String) onEdit;
  final Function(String) onViewStatement;
  final Function(String) onContact;

  const CustomerAccountWidget({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onViewStatement,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1E3A8A),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customer['accountNumber'] ?? 'N/A',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(customer['status'] ?? 'Active'),
              ],
            ),
            const SizedBox(height: 20),

            // Account Details
            const Text(
              'Account Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailGrid(),
            const SizedBox(height: 20),

            // Balance Information
            _buildBalanceSection(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        _buildDetailItem('Meter Number', customer['meterNumber'] ?? 'N/A'),
        _buildDetailItem('Customer Type', customer['customerType'] ?? 'Residential'),
        _buildDetailItem('Zone', customer['zone'] ?? 'N/A'),
        _buildDetailItem('Connection Date', '15 Jan 2023'),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    final balance = customer['balance'] ?? 0.0;
    final lastPayment = customer['lastPayment'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: balance > 0 ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: balance > 0 ? Colors.red[100]! : Colors.green[100]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'KES ${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: balance > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Last Payment', style: TextStyle(fontSize: 12)),
              Text(lastPayment, style: const TextStyle(fontWeight: FontWeight.w500)),
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
          child: OutlinedButton.icon(
            onPressed: () => onEdit(customer['accountNumber'] ?? ''),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onViewStatement(customer['accountNumber'] ?? ''),
            icon: const Icon(Icons.receipt),
            label: const Text('Statement'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onContact(customer['accountNumber'] ?? ''),
            icon: const Icon(Icons.contact_phone),
            label: const Text('Contact'),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'active' => Colors.green,
      'overdue' => Colors.orange,
      'delinquent' => Colors.red,
      'inactive' => Colors.grey,
      _ => Colors.blue,
    };
  }
}