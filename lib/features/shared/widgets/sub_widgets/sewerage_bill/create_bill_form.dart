import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/sewerage_bill_model.dart';
import '../../../providers/sewerage_bill_provider.dart';

class CreateBillForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const CreateBillForm({
    super.key,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<CreateBillForm> createState() => _CreateBillFormState();
}

class _CreateBillFormState extends ConsumerState<CreateBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _baseChargeController = TextEditingController();
  final _usageChargeController = TextEditingController(text: '0');
  final _penaltyController = TextEditingController(text: '0');
  final _arrearsController = TextEditingController(text: '0');
  final _taxAmountController = TextEditingController(text: '0');
  final _totalAmountController = TextEditingController();

  DateTime? _billingPeriodFrom;
  DateTime? _billingPeriodTo;
  DateTime? _dueDate;

  bool _calculateTotal = true;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _baseChargeController.dispose();
    _usageChargeController.dispose();
    _penaltyController.dispose();
    _arrearsController.dispose();
    _taxAmountController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  void _calculateTotalAmount() {
    if (!_calculateTotal) return;

    try {
      final baseCharge = double.tryParse(_baseChargeController.text) ?? 0;
      final usageCharge = double.tryParse(_usageChargeController.text) ?? 0;
      final penalty = double.tryParse(_penaltyController.text) ?? 0;
      final arrears = double.tryParse(_arrearsController.text) ?? 0;
      final taxAmount = double.tryParse(_taxAmountController.text) ?? 0;

      final total = baseCharge + usageCharge + penalty + arrears + taxAmount;
      _totalAmountController.text = total.toStringAsFixed(2);
    } catch (e) {
      // Ignore calculation errors
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_billingPeriodFrom == null ||
        _billingPeriodTo == null ||
        _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required dates')),
      );
      return;
    }

    final billData = CreateBillDto(
      customerName: _customerNameController.text,
      customerEmail: _customerEmailController.text.toLowerCase(),
      billingPeriod: BillingPeriod(
        from: _billingPeriodFrom!,
        to: _billingPeriodTo!,
      ),
      baseCharge: double.parse(_baseChargeController.text),
      usageCharge: double.parse(_usageChargeController.text),
      penalty: double.parse(_penaltyController.text),
      arrears: double.parse(_arrearsController.text),
      taxAmount: double.parse(_taxAmountController.text),
      totalAmount: double.parse(_totalAmountController.text),
      dueDate: _dueDate!,
    );

    final success =
        await ref.read(sewerageBillProvider.notifier).createBill(billData);
    if (success && widget.onSuccess != null) {
      widget.onSuccess!();
    }
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sewerageBillProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.blue[700], size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Create New Sewerage Bill',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer Information
            _buildSection(
              title: 'Customer Information',
              icon: Icons.person,
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Email *',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Billing Period
            _buildSection(
              title: 'Billing Period',
              icon: Icons.calendar_today,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, (date) {
                          setState(() => _billingPeriodFrom = date);
                        }),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'From Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _billingPeriodFrom != null
                                ? dateFormat.format(_billingPeriodFrom!)
                                : 'Select date',
                            style: TextStyle(
                              color: _billingPeriodFrom != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, (date) {
                          setState(() => _billingPeriodTo = date);
                        }),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _billingPeriodTo != null
                                ? dateFormat.format(_billingPeriodTo!)
                                : 'Select date',
                            style: TextStyle(
                              color: _billingPeriodTo != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, (date) {
                    setState(() => _dueDate = date);
                  }),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date *',
                      prefixIcon: Icon(Icons.event_note),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _dueDate != null
                          ? dateFormat.format(_dueDate!)
                          : 'Select due date',
                      style: TextStyle(
                        color: _dueDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Charges
            _buildSection(
              title: 'Charges',
              icon: Icons.attach_money,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _baseChargeController,
                        decoration: const InputDecoration(
                          labelText: 'Base Charge *',
                          prefixIcon: Icon(Icons.home_work),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalAmount(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter base charge';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _usageChargeController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Charge',
                          prefixIcon: Icon(Icons.water_drop),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalAmount(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _penaltyController,
                        decoration: const InputDecoration(
                          labelText: 'Penalty',
                          prefixIcon: Icon(Icons.warning),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalAmount(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _arrearsController,
                        decoration: const InputDecoration(
                          labelText: 'Arrears',
                          prefixIcon: Icon(Icons.history),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalAmount(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _taxAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Amount',
                          prefixIcon: Icon(Icons.account_balance),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalAmount(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _totalAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount *',
                          prefixIcon: Icon(Icons.calculate),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        readOnly: _calculateTotal,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter total amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _calculateTotal,
                      onChanged: (value) {
                        setState(() {
                          _calculateTotal = value ?? true;
                          if (_calculateTotal) {
                            _calculateTotalAmount();
                          }
                        });
                      },
                    ),
                    const Text('Calculate total automatically'),
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
                    onPressed: state.isCreating ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Bill',
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
}
