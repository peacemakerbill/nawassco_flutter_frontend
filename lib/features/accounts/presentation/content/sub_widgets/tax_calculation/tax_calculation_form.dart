import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/tax_calculation_model.dart';
import '../../../../providers/tax_calculation_provider.dart';

class TaxCalculationFormWidget extends ConsumerStatefulWidget {
  const TaxCalculationFormWidget({super.key});

  @override
  ConsumerState<TaxCalculationFormWidget> createState() =>
      _TaxCalculationFormWidgetState();
}

class _TaxCalculationFormWidgetState
    extends ConsumerState<TaxCalculationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _taxPeriodController = TextEditingController();
  final _taxableAmountController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _withholdingTaxController = TextEditingController(text: '0');

  TaxType _selectedTaxType = TaxType.vat;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _taxPeriodController.dispose();
    _taxableAmountController.dispose();
    _taxRateController.dispose();
    _withholdingTaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_chart,
                              color: Color(0xFF0D47A1), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Create Tax Calculation',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details below to create a new tax calculation',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),

                      // Basic Information
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          return isMobile
                              ? Column(
                            children: [
                              _buildTaxPeriodField(),
                              const SizedBox(height: 16),
                              _buildTaxTypeDropdown(),
                              const SizedBox(height: 16),
                              _buildDueDateField(),
                            ],
                          )
                              : Row(
                            children: [
                              Expanded(child: _buildTaxPeriodField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTaxTypeDropdown()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDueDateField()),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Amounts
                      const Text(
                        'Tax Amounts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          return isMobile
                              ? Column(
                            children: [
                              _buildTaxableAmountField(),
                              const SizedBox(height: 16),
                              _buildTaxRateField(),
                              const SizedBox(height: 16),
                              _buildWithholdingTaxField(),
                            ],
                          )
                              : Row(
                            children: [
                              Expanded(child: _buildTaxableAmountField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTaxRateField()),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildWithholdingTaxField()),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Calculation Preview
                      _buildCalculationPreview(),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : const Text(
                            'CREATE TAX CALCULATION',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxPeriodField() {
    return TextFormField(
      controller: _taxPeriodController,
      decoration: InputDecoration(
        labelText: 'Tax Period*',
        hintText: 'e.g., 2024-Q1, Jan-2024',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.calendar_today),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter tax period';
        }
        return null;
      },
    );
  }

  Widget _buildTaxTypeDropdown() {
    return DropdownButtonFormField<TaxType>(
      value: _selectedTaxType,
      decoration: InputDecoration(
        labelText: 'Tax Type*',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: TaxType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.label),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select tax type';
        }
        return null;
      },
      onChanged: (value) => setState(() => _selectedTaxType = value!),
    );
  }

  Widget _buildDueDateField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Due Date*',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.event),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
      ),
      onTap: () => _selectDueDate(context),
      validator: (value) {
        if (_dueDate == null) {
          return 'Please select due date';
        }
        return null;
      },
    );
  }

  Widget _buildTaxableAmountField() {
    return TextFormField(
      controller: _taxableAmountController,
      decoration: InputDecoration(
        labelText: 'Taxable Amount (KES)*',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.attach_money),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter taxable amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildTaxRateField() {
    return TextFormField(
      controller: _taxRateController,
      decoration: InputDecoration(
        labelText: 'Tax Rate (%)*',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.percent),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter tax rate';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate <= 0) {
          return 'Please enter a valid tax rate';
        }
        return null;
      },
    );
  }

  Widget _buildWithholdingTaxField() {
    return TextFormField(
      controller: _withholdingTaxController,
      decoration: InputDecoration(
        labelText: 'Withholding Tax (KES)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.money_off),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final amount = double.tryParse(value);
          if (amount == null || amount < 0) {
            return 'Please enter a valid amount';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCalculationPreview() {
    final taxableAmount =
        double.tryParse(_taxableAmountController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    final withholdingTax =
        double.tryParse(_withholdingTaxController.text) ?? 0;

    final taxAmount = taxableAmount * (taxRate / 100);
    final netTaxPayable = taxAmount - withholdingTax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculation Preview',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D47A1)),
          ),
          const SizedBox(height: 16),
          _buildPreviewRow(
              'Taxable Amount', 'KES ${taxableAmount.toStringAsFixed(2)}'),
          _buildPreviewRow('Tax Rate', '$taxRate%'),
          _buildPreviewRow('Tax Amount', 'KES ${taxAmount.toStringAsFixed(2)}'),
          _buildPreviewRow(
              'Withholding Tax', 'KES ${withholdingTax.toStringAsFixed(2)}'),
          const Divider(),
          _buildPreviewRow(
            'Net Tax Payable',
            'KES ${netTaxPayable.toStringAsFixed(2)}',
            isBold: true,
            color: const Color(0xFF0D47A1),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Prepare form data to match backend structure
    final formData = {
      'taxPeriod': _taxPeriodController.text,
      'taxType': _selectedTaxType.name,
      'taxableAmount': double.parse(_taxableAmountController.text),
      'taxRate': double.parse(_taxRateController.text),
      'withholdingTax': double.parse(_withholdingTaxController.text),
      'dueDate': _dueDate.toIso8601String(),
      'transactions': [], // Empty transactions array as per backend
    };

    final success = await ref
        .read(taxCalculationProvider.notifier)
        .createTaxCalculation(formData);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      // Reset form
      _formKey.currentState!.reset();
      _taxPeriodController.clear();
      _taxableAmountController.clear();
      _taxRateController.clear();
      _withholdingTaxController.text = '0';
      setState(() {
        _selectedTaxType = TaxType.vat;
        _dueDate = DateTime.now().add(const Duration(days: 30));
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tax calculation created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}