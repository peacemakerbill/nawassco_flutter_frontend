import 'package:flutter/material.dart';

class PaymentPostingWidget extends StatefulWidget {
  final Function(String, double, String, String) onPostPayment;

  const PaymentPostingWidget({super.key, required this.onPostPayment});

  @override
  State<PaymentPostingWidget> createState() => _PaymentPostingWidgetState();
}

class _PaymentPostingWidgetState extends State<PaymentPostingWidget> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isAccountValid = false;

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
              'Manual Payment Posting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Account Search
            TextFormField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isAccountValid ? const Icon(Icons.check_circle, color: Colors.green) : null,
              ),
              onChanged: _validateAccount,
            ),
            const SizedBox(height: 16),

            // Customer Info (if account valid)
            if (_isAccountValid) _buildCustomerInfo(),
            if (_isAccountValid) const SizedBox(height: 16),

            // Payment Details
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (KES)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                      DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                      DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
                    ],
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reference Number
            TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: _getReferenceLabel(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Summary
            if (_amountController.text.isNotEmpty) _buildPaymentSummary(),
            if (_amountController.text.isNotEmpty) const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAccountValid && _amountController.text.isNotEmpty ? _postPayment : null,
                child: const Text('POST PAYMENT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.person, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Kamau', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Account: ACC001234 • Zone: Nakuru East'),
                Text('Current Balance: KES 12,500.00', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount:'),
              Text(
                'KES ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Method:'),
              Text(_getPaymentMethodText()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transaction Date:'),
              Text(DateTime.now().toString().split(' ')[0]),
            ],
          ),
        ],
      ),
    );
  }

  String _getReferenceLabel() {
    return switch (_paymentMethod) {
      'mpesa' => 'M-Pesa Transaction ID',
      'bank' => 'Bank Reference Number',
      'cheque' => 'Cheque Number',
      'card' => 'Card Transaction ID',
      _ => 'Receipt Number',
    };
  }

  String _getPaymentMethodText() {
    return switch (_paymentMethod) {
      'cash' => 'Cash',
      'mpesa' => 'M-Pesa',
      'bank' => 'Bank Transfer',
      'cheque' => 'Cheque',
      'card' => 'Credit/Debit Card',
      _ => 'Other',
    };
  }

  void _validateAccount(String value) {
    setState(() {
      _isAccountValid = value.length >= 8; // Simple validation
    });
  }

  void _postPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    widget.onPostPayment(
      _accountController.text,
      amount,
      _paymentMethod,
      _referenceController.text.isEmpty ? 'N/A' : _referenceController.text,
    );

    // Clear form
    _accountController.clear();
    _amountController.clear();
    _referenceController.clear();
    setState(() => _isAccountValid = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment posted successfully')),
    );
  }
}