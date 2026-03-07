import 'package:flutter/material.dart';

class DebitCreditNotesWidget extends StatefulWidget {
  final Function(String, double, String, String) onCreateNote;

  const DebitCreditNotesWidget({super.key, required this.onCreateNote});

  @override
  State<DebitCreditNotesWidget> createState() => _DebitCreditNotesWidgetState();
}

class _DebitCreditNotesWidgetState extends State<DebitCreditNotesWidget> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _noteType = 'debit';

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
              'Create Debit/Credit Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _noteType,
                    decoration: const InputDecoration(
                      labelText: 'Note Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'debit',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Debit Note (Charge)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'credit',
                        child: Row(
                          children: [
                            Icon(Icons.remove, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Credit Note (Refund)'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _noteType = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            _buildNoteSummary(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _noteType == 'debit' ? Colors.red : Colors.green,
                ),
                child: Text(
                  _noteType == 'debit' ? 'CREATE DEBIT NOTE' : 'CREATE CREDIT NOTE',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _noteType == 'debit' ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _noteType == 'debit' ? Colors.red[100]! : Colors.green[100]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _noteType == 'debit' ? Icons.warning : Icons.check_circle,
            color: _noteType == 'debit' ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _noteType == 'debit' ? 'Debit Note Summary' : 'Credit Note Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _noteType == 'debit' ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  'Amount: KES ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (_accountController.text.isNotEmpty)
                  Text(
                    'Account: ${_accountController.text}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createNote() {
    if (_accountController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    widget.onCreateNote(
      _accountController.text,
      amount,
      _noteType,
      _reasonController.text,
    );

    // Clear form
    _accountController.clear();
    _amountController.clear();
    _reasonController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_noteType == 'debit' ? 'Debit' : 'Credit'} note created successfully'),
        backgroundColor: _noteType == 'debit' ? Colors.red : Colors.green,
      ),
    );
  }
}