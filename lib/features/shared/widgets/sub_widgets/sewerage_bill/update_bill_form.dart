import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/sewerage_bill_model.dart';
import '../../../providers/sewerage_bill_provider.dart';

class UpdateBillForm extends ConsumerStatefulWidget {
  final SewerageBill bill;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const UpdateBillForm({
    super.key,
    required this.bill,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<UpdateBillForm> createState() => _UpdateBillFormState();
}

class _UpdateBillFormState extends ConsumerState<UpdateBillForm> {
  late final _formKey = GlobalKey<FormState>();
  late final _customerNameController =
      TextEditingController(text: widget.bill.customerName);
  late final _customerEmailController =
      TextEditingController(text: widget.bill.customerEmail);
  late final _baseChargeController =
      TextEditingController(text: widget.bill.baseCharge.toString());
  late final _usageChargeController =
      TextEditingController(text: widget.bill.usageCharge.toString());
  late final _arrearsController =
      TextEditingController(text: widget.bill.arrears.toString());
  late final _taxAmountController =
      TextEditingController(text: widget.bill.taxAmount.toString());
  late final _totalAmountController =
      TextEditingController(text: widget.bill.totalAmount.toString());

  late DateTime _billingPeriodFrom;
  late DateTime _billingPeriodTo;
  late DateTime _dueDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    _billingPeriodFrom = widget.bill.billingPeriod.from;
    _billingPeriodTo = widget.bill.billingPeriod.to;
    _dueDate = widget.bill.dueDate;
    _status = widget.bill.status;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _baseChargeController.dispose();
    _usageChargeController.dispose();
    _arrearsController.dispose();
    _taxAmountController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final billData = UpdateBillDto(
      customerName: _customerNameController.text,
      customerEmail: _customerEmailController.text.toLowerCase(),
      billingPeriod:
          BillingPeriod(from: _billingPeriodFrom, to: _billingPeriodTo),
      baseCharge: double.parse(_baseChargeController.text),
      usageCharge: double.parse(_usageChargeController.text),
      arrears: double.parse(_arrearsController.text),
      taxAmount: double.parse(_taxAmountController.text),
      totalAmount: double.parse(_totalAmountController.text),
      dueDate: _dueDate,
      status: _status,
    );

    final success = await ref
        .read(sewerageBillProvider.notifier)
        .updateBill(widget.bill.id!, billData);

    if (success && widget.onSuccess != null) {
      widget.onSuccess!();
    }
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onSelected,
      DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Bill: ${widget.bill.sewageServiceNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          widget.bill.customerName,
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
                        }, _billingPeriodFrom),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'From Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            dateFormat.format(_billingPeriodFrom),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, (date) {
                          setState(() => _billingPeriodTo = date);
                        }, _billingPeriodTo),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            dateFormat.format(_billingPeriodTo),
                            style: const TextStyle(color: Colors.black),
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
                  }, _dueDate),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date *',
                      prefixIcon: Icon(Icons.event_note),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      dateFormat.format(_dueDate),
                      style: const TextStyle(color: Colors.black),
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _arrearsController,
                        decoration: const InputDecoration(
                          labelText: 'Arrears',
                          prefixIcon: Icon(Icons.history),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _taxAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Amount',
                          prefixIcon: Icon(Icons.account_balance),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount *',
                    prefixIcon: Icon(Icons.calculate),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
              ],
            ),

            const SizedBox(height: 24),

            // Status
            _buildSection(
              title: 'Status',
              icon: Icons.info,
              children: [
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Bill Status',
                    prefixIcon: Icon(Icons.info),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text('Paid'),
                    ),
                    DropdownMenuItem(
                      value: 'overdue',
                      child: Text('Overdue'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
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
                    onPressed: state.isUpdating ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Bill',
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
