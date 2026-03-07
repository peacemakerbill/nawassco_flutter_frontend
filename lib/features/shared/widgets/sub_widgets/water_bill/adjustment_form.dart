import 'package:flutter/material.dart';

import '../../../models/water_bill_model.dart';

class AdjustmentForm extends StatefulWidget {
  final String billId;
  final Function(Adjustment) onSubmit;

  const AdjustmentForm({
    super.key,
    required this.billId,
    required this.onSubmit,
  });

  @override
  _AdjustmentFormState createState() => _AdjustmentFormState();
}

class _AdjustmentFormState extends State<AdjustmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  String _type = 'credit';

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final adjustment = Adjustment(
        type: _type,
        amount: double.parse(_amountController.text),
        reason: _reasonController.text.trim(),
        appliedAt: DateTime.now(),
      );

      widget.onSubmit(adjustment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Adjustment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apply credit or debit adjustment to this bill',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Adjustment Type
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adjustment Type',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('CREDIT'),
                        selected: _type == 'credit',
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _type == 'credit' ? Colors.white : Colors.grey,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _type = 'credit';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('DEBIT'),
                        selected: _type == 'debit',
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: _type == 'debit' ? Colors.white : Colors.grey,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _type = 'debit';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (TZS)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Reason is required';
                }
                if (value.length < 10) {
                  return 'Please provide a detailed reason';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _type == 'credit' ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'APPLY ${_type.toUpperCase()}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
