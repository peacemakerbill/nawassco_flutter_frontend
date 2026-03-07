import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../sales/models/customer.model.dart' hide PaymentMethod;
import '../../../../../sales/providers/customer_provider.dart';
import '../../../../models/receipt_model.dart';
import '../../../../providers/receipt_provider.dart';

class ReceiptFormWidget extends ConsumerStatefulWidget {
  final Receipt? receipt;

  const ReceiptFormWidget({super.key, this.receipt});

  @override
  ConsumerState<ReceiptFormWidget> createState() => _ReceiptFormWidgetState();
}

class _ReceiptFormWidgetState extends ConsumerState<ReceiptFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _payerEmailController = TextEditingController();
  final _payerPhoneController = TextEditingController();
  final _payerNameController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReceiptType _selectedReceiptType = ReceiptType.CUSTOMER_PAYMENT;
  PayerType _selectedPayerType = PayerType.CUSTOMER;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.CASH;
  DateTime _selectedDate = DateTime.now();

  Customer? _selectedCustomer;
  bool _useCustomerDetails = false;
  bool _manuallyEnterCustomer = true;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.receipt != null;

    if (_isEditing) {
      _populateForm();
    }

    // Load customers if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  void _populateForm() {
    final receipt = widget.receipt!;
    _selectedReceiptType = receipt.receiptType;
    _selectedPayerType = receipt.payerType;
    _selectedPaymentMethod = receipt.paymentMethod;
    _selectedDate = receipt.receiptDate;

    _amountController.text = receipt.amount.toStringAsFixed(2);
    _taxAmountController.text = receipt.taxAmount.toStringAsFixed(2);
    _payerEmailController.text = receipt.payerEmail;
    _payerPhoneController.text = receipt.payerPhone;
    _payerNameController.text = receipt.payerName;
    _invoiceNumberController.text = receipt.invoiceNumber ?? '';
    _customerEmailController.text = receipt.customerEmail ?? '';
    _customerNameController.text = receipt.customerName ?? '';
    _referenceNumberController.text = receipt.referenceNumber ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onCustomerSelected(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      if (customer != null) {
        _useCustomerDetails = true;
        _payerEmailController.text = customer.email;
        _payerPhoneController.text = customer.phone;
        _payerNameController.text = customer.fullName;
        _customerEmailController.text = customer.email;
        _customerNameController.text = customer.displayName;
      } else {
        _useCustomerDetails = false;
      }
    });
  }

  void _toggleCustomerEntryMode() {
    setState(() {
      _manuallyEnterCustomer = !_manuallyEnterCustomer;
      if (_manuallyEnterCustomer) {
        _selectedCustomer = null;
        _useCustomerDetails = false;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Helper function to convert empty strings to null
      String? _cleanString(String? value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }
        return value.trim();
      }

      final receiptData = {
        'receiptDate': _selectedDate.toIso8601String(),
        'receiptType': _selectedReceiptType.apiName,
        'payerType': _selectedPayerType.apiName,
        'payerEmail': _cleanString(_payerEmailController.text),
        'payerPhone': _cleanString(_payerPhoneController.text),
        'payerName': _payerNameController.text.trim(),
        'amount': double.parse(_amountController.text),
        'currency': 'KES',
        'taxAmount': double.parse(_taxAmountController.text),
        'paymentMethod': _selectedPaymentMethod.apiName,
        'referenceNumber': _cleanString(_referenceNumberController.text),
        'invoiceNumber': _cleanString(_invoiceNumberController.text),
        'customerEmail': _cleanString(_customerEmailController.text),
        'customerName': _cleanString(_customerNameController.text),
        'description': _cleanString(_descriptionController.text),
      };

      final success = _isEditing
          ? await ref.read(receiptProvider.notifier).updateReceipt(
                widget.receipt!.id,
                receiptData,
              )
          : await ref.read(receiptProvider.notifier).createReceipt(receiptData);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptState = ref.watch(receiptProvider);
    final customerState = ref.watch(customerProvider);
    final isSubmitting = receiptState.isCreating || receiptState.isUpdating;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    color: const Color(0xFF0D47A1),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'Edit Receipt' : 'Create New Receipt',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Type and Payer Type
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  _buildReceiptTypeDropdown(),
                                  const SizedBox(height: 16),
                                  _buildPayerTypeDropdown(),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildReceiptTypeDropdown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildPayerTypeDropdown()),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date and Payment Method
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  _buildDateField(),
                                  const SizedBox(height: 16),
                                  _buildPaymentMethodDropdown(),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildDateField()),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: _buildPaymentMethodDropdown()),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Customer Selection Section
                    _buildCustomerSelectionSection(customerState),
                    const SizedBox(height: 20),
                    // Payer Information
                    const Text(
                      'Payer Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _payerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Payer Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter payer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  _buildPayerEmailField(),
                                  const SizedBox(height: 16),
                                  _buildPayerPhoneField(),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildPayerEmailField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildPayerPhoneField()),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Financial Information
                    const Text(
                      'Financial Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  _buildAmountField(),
                                  const SizedBox(height: 16),
                                  _buildTaxAmountField(),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildAmountField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTaxAmountField()),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Additional Information
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  _buildCustomerEmailField(),
                                  const SizedBox(height: 16),
                                  _buildCustomerNameField(),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildCustomerEmailField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCustomerNameField()),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _referenceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'UPDATE RECEIPT'
                                    : 'CREATE RECEIPT',
                                style: const TextStyle(
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
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelectionSection(CustomerState customerState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF0D47A1)),
                const SizedBox(width: 8),
                const Text(
                  'Customer Selection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _toggleCustomerEntryMode,
                  icon: Icon(
                    _manuallyEnterCustomer ? Icons.list : Icons.edit,
                    color: const Color(0xFF0D47A1),
                  ),
                  tooltip: _manuallyEnterCustomer
                      ? 'Switch to customer list'
                      : 'Switch to manual entry',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_manuallyEnterCustomer)
              const Text(
                'Manually enter customer details below',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: [
                  DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Select Customer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    items: [
                      const DropdownMenuItem<Customer>(
                        value: null,
                        child: Text('No customer selected'),
                      ),
                      ...customerState.customers.map((customer) {
                        return DropdownMenuItem<Customer>(
                          value: customer,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  customer.fullName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.fullName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    customer.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: _onCustomerSelected,
                  ),
                  if (_selectedCustomer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Customer details will be auto-filled',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptTypeDropdown() {
    return DropdownButtonFormField<ReceiptType>(
      value: _selectedReceiptType,
      decoration: const InputDecoration(
        labelText: 'Receipt Type *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
      items: ReceiptType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(type.icon, color: type.color, size: 16),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedReceiptType = value;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select receipt type';
        }
        return null;
      },
    );
  }

  Widget _buildPayerTypeDropdown() {
    return DropdownButtonFormField<PayerType>(
      value: _selectedPayerType,
      decoration: const InputDecoration(
        labelText: 'Payer Type *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.group),
      ),
      items: PayerType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPayerType = value;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select payer type';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<PaymentMethod>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'Payment Method *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: PaymentMethod.values.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Row(
            children: [
              Icon(method.icon, size: 16),
              const SizedBox(width: 8),
              Text(method.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select payment method';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Receipt Date *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ),
      controller: TextEditingController(
        text: _selectedDate.toLocal().toString().split(' ')[0],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select receipt date';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount (KES) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildTaxAmountField() {
    return TextFormField(
      controller: _taxAmountController,
      decoration: const InputDecoration(
        labelText: 'Tax Amount (KES)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter tax amount';
        }
        final taxAmount = double.tryParse(value);
        if (taxAmount == null || taxAmount < 0) {
          return 'Please enter a valid tax amount';
        }
        return null;
      },
    );
  }

  Widget _buildPayerEmailField() {
    return TextFormField(
      controller: _payerEmailController,
      decoration: const InputDecoration(
        labelText: 'Payer Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Optional field
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPayerPhoneField() {
    return TextFormField(
      controller: _payerPhoneController,
      decoration: const InputDecoration(
        labelText: 'Payer Phone',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildCustomerEmailField() {
    return TextFormField(
      controller: _customerEmailController,
      decoration: const InputDecoration(
        labelText: 'Customer Email (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildCustomerNameField() {
    return TextFormField(
      controller: _customerNameController,
      decoration: const InputDecoration(
        labelText: 'Customer Name (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }
}
