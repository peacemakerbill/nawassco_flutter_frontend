import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../public/auth/providers/auth_provider.dart';
import '../../../models/water_bill_model.dart';

class WaterBillForm extends StatefulWidget {
  final WaterBill? initialData;
  final Function(WaterBill) onSubmit;
  final bool isEditing;

  const WaterBillForm({
    super.key,
    this.initialData,
    required this.onSubmit,
    this.isEditing = false,
  });

  @override
  _WaterBillFormState createState() => _WaterBillFormState();
}

class _WaterBillFormState extends State<WaterBillForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _meterNumberController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerEmailController;
  late TextEditingController _serviceRegionController;
  late TextEditingController _previousReadingController;
  late TextEditingController _currentReadingController;
  late TextEditingController _waterChargesController;
  late TextEditingController _sewerageChargesController;
  late TextEditingController _meterRentController;
  late TextEditingController _penaltyController;
  late TextEditingController _arrearsController;
  late TextEditingController _taxAmountController;
  late TextEditingController _billingMonthController;
  late DateTime _readingDate;
  late DateTime _dueDate;
  late DateTime _billingPeriodFrom;
  late DateTime _billingPeriodTo;
  String _readingType = 'manual';
  String _status = 'pending';
  bool _isEstimated = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, now.day);

    if (widget.initialData != null) {
      final bill = widget.initialData!;
      _meterNumberController = TextEditingController(text: bill.meterNumber);
      _customerNameController = TextEditingController(text: bill.customerName);
      _customerEmailController =
          TextEditingController(text: bill.customerEmail);
      _serviceRegionController =
          TextEditingController(text: bill.serviceRegion);
      _previousReadingController =
          TextEditingController(text: bill.previousReading.toString());
      _currentReadingController =
          TextEditingController(text: bill.currentReading.toString());
      _waterChargesController =
          TextEditingController(text: bill.waterCharges.toString());
      _sewerageChargesController =
          TextEditingController(text: bill.sewerageCharges.toString());
      _meterRentController =
          TextEditingController(text: bill.meterRent.toString());
      _penaltyController = TextEditingController(text: bill.penalty.toString());
      _arrearsController = TextEditingController(text: bill.arrears.toString());
      _taxAmountController =
          TextEditingController(text: bill.taxAmount.toString());
      _billingMonthController = TextEditingController(text: bill.billingMonth);
      _readingDate = bill.readingDate;
      _dueDate = bill.dueDate;
      _billingPeriodFrom = bill.billingPeriodFrom;
      _billingPeriodTo = bill.billingPeriodTo;
      _readingType = bill.readingType;
      _status = bill.status;
      _isEstimated = bill.isEstimated;
    } else {
      _meterNumberController = TextEditingController();
      _customerNameController = TextEditingController();
      _customerEmailController = TextEditingController();
      _serviceRegionController = TextEditingController();
      _previousReadingController = TextEditingController();
      _currentReadingController = TextEditingController();
      _waterChargesController = TextEditingController();
      _sewerageChargesController = TextEditingController(text: '0');
      _meterRentController = TextEditingController(text: '0');
      _penaltyController = TextEditingController(text: '0');
      _arrearsController = TextEditingController(text: '0');
      _taxAmountController = TextEditingController(text: '0');
      _billingMonthController = TextEditingController(
        text: '${now.year}-${now.month.toString().padLeft(2, '0')}',
      );
      _readingDate = now;
      _dueDate = nextMonth;
      _billingPeriodFrom = DateTime(now.year, now.month, 1);
      _billingPeriodTo = DateTime(now.year, now.month + 1, 0);
      _readingType = 'manual';
      _status = 'pending';
      _isEstimated = false;
    }
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _serviceRegionController.dispose();
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    _waterChargesController.dispose();
    _sewerageChargesController.dispose();
    _meterRentController.dispose();
    _penaltyController.dispose();
    _arrearsController.dispose();
    _taxAmountController.dispose();
    _billingMonthController.dispose();
    super.dispose();
  }

  double get consumption {
    final previous = double.tryParse(_previousReadingController.text) ?? 0;
    final current = double.tryParse(_currentReadingController.text) ?? 0;
    return current - previous;
  }

  double get totalAmount {
    final waterCharges = double.tryParse(_waterChargesController.text) ?? 0;
    final sewerageCharges =
        double.tryParse(_sewerageChargesController.text) ?? 0;
    final meterRent = double.tryParse(_meterRentController.text) ?? 0;
    final penalty = double.tryParse(_penaltyController.text) ?? 0;
    final arrears = double.tryParse(_arrearsController.text) ?? 0;
    final taxAmount = double.tryParse(_taxAmountController.text) ?? 0;

    return waterCharges +
        sewerageCharges +
        meterRent +
        penalty +
        arrears +
        taxAmount;
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _billingPeriodFrom : _billingPeriodTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _billingPeriodFrom = picked;
        } else {
          _billingPeriodTo = picked;
        }
      });
    }
  }

  Future<void> _selectReadingDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _readingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _readingDate = picked;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bill = WaterBill(
        id: widget.initialData?.id,
        meterNumber: _meterNumberController.text.trim(),
        customerName: _customerNameController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        serviceRegion: _serviceRegionController.text.trim(),
        billingPeriodFrom: _billingPeriodFrom,
        billingPeriodTo: _billingPeriodTo,
        previousReading: double.parse(_previousReadingController.text),
        currentReading: double.parse(_currentReadingController.text),
        consumption: consumption,
        readingDate: _readingDate,
        waterCharges: double.parse(_waterChargesController.text),
        sewerageCharges: double.parse(_sewerageChargesController.text),
        meterRent: double.parse(_meterRentController.text),
        penalty: double.parse(_penaltyController.text),
        arrears: double.parse(_arrearsController.text),
        taxAmount: double.parse(_taxAmountController.text),
        totalAmount: totalAmount,
        paidAmount: 0,
        balance: totalAmount,
        status: _status,
        dueDate: _dueDate,
        billingMonth: _billingMonthController.text.trim(),
        readingType: _readingType,
        readingVerified: false,
        isEstimated: _isEstimated,
        disputed: false,
        discountApplied: 0,
        adjustments: [],
        createdAt: widget.initialData?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.read(authProvider);
        final isUser = authState.isUser;

        // If user is viewing, pre-fill their email
        if (!widget.isEditing && isUser && authState.user?['email'] != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_customerEmailController.text.isEmpty) {
              _customerEmailController.text = authState.user!['email'];
            }
          });
        }

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information Section
                  _buildSectionHeader('Customer Information'),
                  _buildTextFormField(
                    controller: _meterNumberController,
                    label: 'Meter Number *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Meter number is required';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField(
                    controller: _customerNameController,
                    label: 'Customer Name *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Customer name is required';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField(
                    controller: _customerEmailController,
                    label: 'Customer Email *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Customer email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField(
                    controller: _serviceRegionController,
                    label: 'Service Region *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Service region is required';
                      }
                      return null;
                    },
                  ),

                  // Billing Period Section
                  _buildSectionHeader('Billing Period'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Period From',
                          date: _billingPeriodFrom,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Period To',
                          date: _billingPeriodTo,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _billingMonthController,
                    label: 'Billing Month (YYYY-MM) *',
                    hintText: 'e.g., 2024-02',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Billing month is required';
                      }
                      if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(value)) {
                        return 'Format: YYYY-MM';
                      }
                      return null;
                    },
                  ),

                  // Reading Information Section
                  _buildSectionHeader('Reading Information'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          controller: _previousReadingController,
                          label: 'Previous Reading (m³) *',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Previous reading is required';
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
                        child: _buildTextFormField(
                          controller: _currentReadingController,
                          label: 'Current Reading (m³) *',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current reading is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            final previous = double.tryParse(
                                    _previousReadingController.text) ??
                                0;
                            final current = double.tryParse(value) ?? 0;
                            if (current < previous) {
                              return 'Current reading must be >= previous reading';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Reading Date',
                          date: _readingDate,
                          onTap: () => _selectReadingDate(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reading Type',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _readingType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                              items: [
                                'manual',
                                'smart_meter',
                                'estimated',
                                'customer',
                              ].map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                      type.replaceAll('_', ' ').toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _readingType = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Estimated Reading'),
                    subtitle:
                        const Text('Check if this is an estimated reading'),
                    value: _isEstimated,
                    onChanged: (value) {
                      setState(() {
                        _isEstimated = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Charges Section
                  _buildSectionHeader('Charges'),
                  _buildTextFormField(
                    controller: _waterChargesController,
                    label: 'Water Charges (TZS) *',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Water charges are required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField(
                    controller: _sewerageChargesController,
                    label: 'Sewerage Charges (TZS)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: _meterRentController,
                    label: 'Meter Rent (TZS)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: _penaltyController,
                    label: 'Penalty (TZS)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: _arrearsController,
                    label: 'Arrears (TZS)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: _taxAmountController,
                    label: 'Tax Amount (TZS)',
                    keyboardType: TextInputType.number,
                  ),

                  // Summary Card
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Summary',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Consumption:',
                              '${consumption.toStringAsFixed(2)} m³'),
                          _buildSummaryRow('Total Amount:',
                              'TZS ${totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),

                  // Due Date and Status
                  _buildSectionHeader('Payment Information'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Due Date',
                          date: _dueDate,
                          onTap: () => _selectDueDate(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                              items: [
                                'pending',
                                'paid',
                                'overdue',
                                'partially_paid',
                                'cancelled',
                              ].map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status
                                      .replaceAll('_', ' ')
                                      .toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Submit Button
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isEditing ? 'UPDATE BILL' : 'CREATE BILL',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
