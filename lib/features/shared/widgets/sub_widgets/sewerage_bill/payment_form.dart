import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/sewerage_bill_model.dart';
import '../../../providers/sewerage_bill_provider.dart';

class PaymentForm extends ConsumerStatefulWidget {
  final SewerageBill bill;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PaymentForm({
    super.key,
    required this.bill,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _paymentIdController = TextEditingController();
  DateTime? _paidDate;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.balance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final payment = PaymentDto(
      amount: double.parse(_amountController.text),
      paymentId: _paymentIdController.text.isNotEmpty
          ? _paymentIdController.text
          : null,
      paidDate: _paidDate,
    );

    final success = await ref
        .read(sewerageBillProvider.notifier)
        .applyPayment(widget.bill.id!, payment);

    if (success && widget.onSuccess != null) {
      widget.onSuccess!();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _paidDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sewerageBillProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment, color: Colors.green[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          widget.bill.sewageServiceNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bill Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Customer', widget.bill.customerName),
                  _buildSummaryRow(
                      'Service Number', widget.bill.sewageServiceNumber),
                  _buildSummaryRow('Total Amount',
                      currencyFormat.format(widget.bill.totalAmount)),
                  _buildSummaryRow('Paid Amount',
                      currencyFormat.format(widget.bill.paidAmount)),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Balance Due',
                    currencyFormat.format(widget.bill.balance),
                    isBold: true,
                    color: widget.bill.balance > 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Details
            _buildSection(
              title: 'Payment Details',
              icon: Icons.credit_card,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount *',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    suffixText: 'TSh',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    if (amount > widget.bill.balance) {
                      return 'Amount exceeds balance due';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Reference ID (Optional)',
                    prefixIcon: Icon(Icons.receipt),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date (Optional)',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _paidDate != null
                          ? dateFormat.format(_paidDate!)
                          : 'Select payment date',
                      style: TextStyle(
                        color: _paidDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Payment Methods
            _buildSection(
              title: 'Payment Method',
              icon: Icons.payment,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentMethod(
                      icon: Icons.credit_card,
                      label: 'Card',
                      isSelected: true,
                    ),
                    const SizedBox(width: 12),
                    _buildPaymentMethod(
                      icon: Icons.account_balance,
                      label: 'Bank',
                    ),
                    const SizedBox(width: 12),
                    _buildPaymentMethod(
                      icon: Icons.phone_android,
                      label: 'Mobile',
                    ),
                    const SizedBox(width: 12),
                    _buildPaymentMethod(
                      icon: Icons.money,
                      label: 'Cash',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (widget.onCancel != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isApplyingPayment ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isApplyingPayment
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Payment',
                            style: TextStyle(fontSize: 16),
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

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
