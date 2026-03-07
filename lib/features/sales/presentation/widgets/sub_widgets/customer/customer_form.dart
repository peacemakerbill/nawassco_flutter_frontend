import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class CustomerForm extends ConsumerStatefulWidget {
  final Customer? initialCustomer;
  final VoidCallback? onSuccess;

  const CustomerForm({
    super.key,
    this.initialCustomer,
    this.onSuccess,
  });

  @override
  ConsumerState<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyNameController;
  late TextEditingController _nationalIdController;
  late TextEditingController _customerSinceController;

  // Form Values
  CustomerType _customerType = CustomerType.residential;
  CustomerSegment _customerSegment = CustomerSegment.standard;
  PriorityLevel _priorityLevel = PriorityLevel.medium;
  CustomerStatus _status = CustomerStatus.prospect;
  SalesSource _salesSource = SalesSource.walk_in;

  // Business Details
  late TextEditingController _industryController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _taxIdController;
  late TextEditingController _businessTypeController;
  late TextEditingController _employeesController;
  late TextEditingController _annualRevenueController;

  // Billing
  BillingCycle _billingCycle = BillingCycle.monthly;
  InvoiceDelivery _invoiceDelivery = InvoiceDelivery.email;
  PaymentMethod _paymentMethod = PaymentMethod.bank_transfer;

  // Payment Terms
  late TextEditingController _netDaysController;
  late TextEditingController _discountDaysController;
  late TextEditingController _discountPercentageController;
  late TextEditingController _lateFeeController;

  // Connection Details
  late TextEditingController _connectionDateController;
  ConnectionType _connectionType = ConnectionType.new_connection;
  late TextEditingController _pipeSizeController;
  late TextEditingController _pressureZoneController;
  late TextEditingController _waterSourceController;
  late TextEditingController _previousProviderController;

  // Bank Details
  late TextEditingController _bankNameController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _branchCodeController;

  // Communication Preferences
  ContactMethod _preferredContactMethod = ContactMethod.email;
  bool _receiveMarketing = false;
  bool _receiveSMS = true;
  bool _receiveEmail = true;
  String _language = 'en';

  // Credit
  late TextEditingController _creditLimitController;
  late TextEditingController _currentBalanceController;

  // Referral
  late TextEditingController _referralSourceController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data or defaults
    final customer = widget.initialCustomer;

    _firstNameController = TextEditingController(text: customer?.firstName ?? '');
    _lastNameController = TextEditingController(text: customer?.lastName ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _companyNameController = TextEditingController(text: customer?.companyName ?? '');
    _nationalIdController = TextEditingController(text: customer?.nationalId ?? '');
    _customerSinceController = TextEditingController(
      text: customer?.customerSince != null
          ? DateFormat('yyyy-MM-dd').format(customer!.customerSince)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    _customerType = customer?.customerType ?? CustomerType.residential;
    _customerSegment = customer?.customerSegment ?? CustomerSegment.standard;
    _priorityLevel = customer?.priorityLevel ?? PriorityLevel.medium;
    _status = customer?.status ?? CustomerStatus.prospect;
    _salesSource = customer?.salesSource ?? SalesSource.walk_in;

    // Business Details
    _industryController = TextEditingController(
      text: customer?.industry ?? customer?.businessDetails?.industry ?? '',
    );
    _registrationNumberController = TextEditingController(
      text: customer?.businessDetails?.registrationNumber ?? '',
    );
    _taxIdController = TextEditingController(
      text: customer?.businessDetails?.taxId ?? '',
    );
    _businessTypeController = TextEditingController(
      text: customer?.businessDetails?.businessType ?? '',
    );
    _employeesController = TextEditingController(
      text: customer?.businessDetails?.numberOfEmployees?.toString() ?? '0',
    );
    _annualRevenueController = TextEditingController(
      text: customer?.businessDetails?.annualRevenue?.toString() ?? '',
    );

    // Billing
    _billingCycle = customer?.billingInformation.billingCycle ?? BillingCycle.monthly;
    _invoiceDelivery = customer?.billingInformation.invoiceDelivery ?? InvoiceDelivery.email;
    _paymentMethod = customer?.billingInformation.paymentMethod ?? PaymentMethod.bank_transfer;

    // Payment Terms
    _netDaysController = TextEditingController(
      text: customer?.paymentTerms.netDays.toString() ?? '30',
    );
    _discountDaysController = TextEditingController(
      text: customer?.paymentTerms.discountDays?.toString() ?? '',
    );
    _discountPercentageController = TextEditingController(
      text: customer?.paymentTerms.discountPercentage?.toString() ?? '',
    );
    _lateFeeController = TextEditingController(
      text: customer?.paymentTerms.latePaymentFee.toString() ?? '0',
    );

    // Connection Details
    _connectionDateController = TextEditingController(
      text: customer?.connectionDetails.connectionDate != null
          ? DateFormat('yyyy-MM-dd').format(customer!.connectionDetails.connectionDate)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _connectionType = customer?.connectionDetails.connectionType ?? ConnectionType.new_connection;
    _pipeSizeController = TextEditingController(
      text: customer?.connectionDetails.pipeSize ?? '',
    );
    _pressureZoneController = TextEditingController(
      text: customer?.connectionDetails.pressureZone ?? '',
    );
    _waterSourceController = TextEditingController(
      text: customer?.connectionDetails.waterSource ?? '',
    );
    _previousProviderController = TextEditingController(
      text: customer?.connectionDetails.previousProvider ?? '',
    );

    // Bank Details
    _bankNameController = TextEditingController(
      text: customer?.billingInformation.bankDetails?.bankName ?? '',
    );
    _accountNameController = TextEditingController(
      text: customer?.billingInformation.bankDetails?.accountName ?? '',
    );
    _accountNumberController = TextEditingController(
      text: customer?.billingInformation.bankDetails?.accountNumber ?? '',
    );
    _branchCodeController = TextEditingController(
      text: customer?.billingInformation.bankDetails?.branchCode ?? '',
    );

    // Communication Preferences
    _preferredContactMethod = customer?.communicationPreferences.preferredContactMethod ?? ContactMethod.email;
    _receiveMarketing = customer?.communicationPreferences.receiveMarketing ?? false;
    _receiveSMS = customer?.communicationPreferences.receiveSMS ?? true;
    _receiveEmail = customer?.communicationPreferences.receiveEmail ?? true;
    _language = customer?.communicationPreferences.language ?? 'en';

    // Credit
    _creditLimitController = TextEditingController(
      text: customer?.creditLimit.toString() ?? '0',
    );
    _currentBalanceController = TextEditingController(
      text: customer?.currentBalance.toString() ?? '0',
    );

    // Referral
    _referralSourceController = TextEditingController(
      text: customer?.referralSource ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _nationalIdController.dispose();
    _customerSinceController.dispose();
    _industryController.dispose();
    _registrationNumberController.dispose();
    _taxIdController.dispose();
    _businessTypeController.dispose();
    _employeesController.dispose();
    _annualRevenueController.dispose();
    _netDaysController.dispose();
    _discountDaysController.dispose();
    _discountPercentageController.dispose();
    _lateFeeController.dispose();
    _connectionDateController.dispose();
    _pipeSizeController.dispose();
    _pressureZoneController.dispose();
    _waterSourceController.dispose();
    _previousProviderController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _branchCodeController.dispose();
    _creditLimitController.dispose();
    _currentBalanceController.dispose();
    _referralSourceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = ref.read(customerProvider.notifier);

      final customerData = {
        'customerType': _customerType.name,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        if (_companyNameController.text.isNotEmpty)
          'companyName': _companyNameController.text.trim(),
        if (_nationalIdController.text.isNotEmpty)
          'nationalId': _nationalIdController.text.trim(),

        // Business Information - Only for non-residential
        if (_customerType != CustomerType.residential) ...{
          if (_industryController.text.isNotEmpty) 'industry': _industryController.text.trim(),
          if (_registrationNumberController.text.isNotEmpty ||
              _taxIdController.text.isNotEmpty ||
              _businessTypeController.text.isNotEmpty) ...{
            'businessDetails': {
              if (_registrationNumberController.text.isNotEmpty)
                'registrationNumber': _registrationNumberController.text.trim(),
              if (_taxIdController.text.isNotEmpty)
                'taxId': _taxIdController.text.trim(),
              if (_businessTypeController.text.isNotEmpty)
                'businessType': _businessTypeController.text.trim(),
              'numberOfEmployees': int.tryParse(_employeesController.text) ?? 0,
              if (_annualRevenueController.text.isNotEmpty)
                'annualRevenue': double.tryParse(_annualRevenueController.text),
            },
          },
        },

        'customerSince': _customerSinceController.text,
        'customerSegment': _customerSegment.name,
        'priorityLevel': _priorityLevel.name,
        'status': _status.name,
        'salesSource': _salesSource.name,

        // Billing & Payment
        'billingInformation': {
          'billingCycle': _billingCycle.name,
          'invoiceDelivery': _invoiceDelivery.name,
          'paymentMethod': _paymentMethod.name,
          if (_paymentMethod == PaymentMethod.bank_transfer &&
              _bankNameController.text.isNotEmpty &&
              _accountNameController.text.isNotEmpty &&
              _accountNumberController.text.isNotEmpty &&
              _branchCodeController.text.isNotEmpty) ...{
            'bankDetails': {
              'bankName': _bankNameController.text.trim(),
              'accountName': _accountNameController.text.trim(),
              'accountNumber': _accountNumberController.text.trim(),
              'branchCode': _branchCodeController.text.trim(),
            },
          },
        },

        'paymentTerms': {
          'netDays': int.tryParse(_netDaysController.text) ?? 30,
          if (_discountDaysController.text.isNotEmpty && _discountDaysController.text != '0')
            'discountDays': int.tryParse(_discountDaysController.text),
          if (_discountPercentageController.text.isNotEmpty && _discountPercentageController.text != '0')
            'discountPercentage': double.tryParse(_discountPercentageController.text),
          'latePaymentFee': double.tryParse(_lateFeeController.text) ?? 0,
        },

        'creditLimit': double.tryParse(_creditLimitController.text) ?? 0,
        'currentBalance': double.tryParse(_currentBalanceController.text) ?? 0,

        // Connection Details
        'connectionDetails': {
          'connectionDate': _connectionDateController.text,
          'connectionType': _connectionType.name,
          if (_pipeSizeController.text.isNotEmpty) 'pipeSize': _pipeSizeController.text.trim(),
          if (_pressureZoneController.text.isNotEmpty) 'pressureZone': _pressureZoneController.text.trim(),
          if (_waterSourceController.text.isNotEmpty) 'waterSource': _waterSourceController.text.trim(),
          if (_previousProviderController.text.isNotEmpty)
            'previousProvider': _previousProviderController.text.trim(),
        },

        // Communication Preferences
        'communicationPreferences': {
          'preferredContactMethod': _preferredContactMethod.name,
          'receiveMarketing': _receiveMarketing,
          'receiveSMS': _receiveSMS,
          'receiveEmail': _receiveEmail,
          'language': _language,
        },

        // Referral Source
        if (_referralSourceController.text.isNotEmpty)
          'referralSource': _referralSourceController.text.trim(),
      };

      final isEditing = widget.initialCustomer != null;

      if (isEditing) {
        await provider.updateCustomer(
          widget.initialCustomer!.id,
          customerData,
        );
      } else {
        await provider.createCustomer(customerData);
      }

      if (mounted) {
        widget.onSuccess?.call();
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final initialDate = controller.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(controller.text)
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    String? Function(String?)? validator,
    int? maxLines,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        validator: validator ??
            (required
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
                : null),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) displayString,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayString(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
          if (value == null) {
            return 'Please select $label';
          }
          return null;
        }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final provider = ref.read(customerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.initialCustomer == null
              ? 'New Customer'
              : 'Edit Customer',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: state.isCreating || state.isUpdating
                ? null
                : _submitForm,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Basic Information
                    _buildSection(
                      title: 'Basic Information',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _buildDropdown<CustomerType>(
                            label: 'Customer Type',
                            value: _customerType,
                            items: CustomerType.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _customerType = value);
                              }
                            },
                            displayString: (type) => type.displayName,
                            required: true,
                          ),

                          if (_customerType != CustomerType.residential)
                            _buildFormField(
                              label: 'Company Name',
                              controller: _companyNameController,
                            ),

                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'First Name',
                                  controller: _firstNameController,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Last Name',
                                  controller: _lastNameController,
                                  required: true,
                                ),
                              ),
                            ],
                          ),

                          _buildFormField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            required: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          _buildFormField(
                            label: 'Phone',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            required: true,
                          ),

                          _buildFormField(
                            label: 'National ID',
                            controller: _nationalIdController,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Customer Since',
                                  controller: _customerSinceController,
                                  required: true,
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                    context,
                                    _customerSinceController,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(
                                  context,
                                  _customerSinceController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Classification
                    _buildSection(
                      title: 'Classification',
                      icon: Icons.category_outlined,
                      child: Column(
                        children: [
                          _buildDropdown<CustomerSegment>(
                            label: 'Customer Segment',
                            value: _customerSegment,
                            items: CustomerSegment.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _customerSegment = value);
                              }
                            },
                            displayString: (segment) => segment.displayName,
                            required: true,
                          ),

                          _buildDropdown<PriorityLevel>(
                            label: 'Priority Level',
                            value: _priorityLevel,
                            items: PriorityLevel.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _priorityLevel = value);
                              }
                            },
                            displayString: (priority) => priority.displayName,
                            required: true,
                          ),

                          _buildDropdown<CustomerStatus>(
                            label: 'Status',
                            value: _status,
                            items: CustomerStatus.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                            displayString: (status) => status.displayName,
                            required: true,
                          ),

                          _buildDropdown<SalesSource>(
                            label: 'Sales Source',
                            value: _salesSource,
                            items: SalesSource.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _salesSource = value);
                              }
                            },
                            displayString: (source) => source.displayName,
                            required: true,
                          ),

                          _buildFormField(
                            label: 'Referral Source',
                            controller: _referralSourceController,
                          ),
                        ],
                      ),
                    ),

                    // Business Information (for non-residential)
                    if (_customerType != CustomerType.residential)
                      _buildSection(
                        title: 'Business Information',
                        icon: Icons.business_outlined,
                        child: Column(
                          children: [
                            _buildFormField(
                              label: 'Industry',
                              controller: _industryController,
                            ),

                            _buildFormField(
                              label: 'Registration Number',
                              controller: _registrationNumberController,
                            ),

                            _buildFormField(
                              label: 'Tax ID',
                              controller: _taxIdController,
                            ),

                            _buildFormField(
                              label: 'Business Type',
                              controller: _businessTypeController,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Number of Employees',
                                    controller: _employeesController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Annual Revenue (KES)',
                                    controller: _annualRevenueController,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Billing & Payment
                    _buildSection(
                      title: 'Billing & Payment',
                      icon: Icons.payments_outlined,
                      child: Column(
                        children: [
                          _buildDropdown<BillingCycle>(
                            label: 'Billing Cycle',
                            value: _billingCycle,
                            items: BillingCycle.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _billingCycle = value);
                              }
                            },
                            displayString: (cycle) => cycle.displayName,
                            required: true,
                          ),

                          _buildDropdown<InvoiceDelivery>(
                            label: 'Invoice Delivery',
                            value: _invoiceDelivery,
                            items: InvoiceDelivery.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _invoiceDelivery = value);
                              }
                            },
                            displayString: (delivery) => delivery.displayName,
                            required: true,
                          ),

                          _buildDropdown<PaymentMethod>(
                            label: 'Payment Method',
                            value: _paymentMethod,
                            items: PaymentMethod.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _paymentMethod = value);
                              }
                            },
                            displayString: (method) => method.displayName,
                            required: true,
                          ),

                          // Bank Details (if payment method is bank transfer)
                          if (_paymentMethod == PaymentMethod.bank_transfer) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Bank Details',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            _buildFormField(
                              label: 'Bank Name',
                              controller: _bankNameController,
                            ),
                            _buildFormField(
                              label: 'Account Name',
                              controller: _accountNameController,
                            ),
                            _buildFormField(
                              label: 'Account Number',
                              controller: _accountNumberController,
                              keyboardType: TextInputType.number,
                            ),
                            _buildFormField(
                              label: 'Branch Code',
                              controller: _branchCodeController,
                            ),
                          ],

                          // Payment Terms
                          const SizedBox(height: 8),
                          Text(
                            'Payment Terms',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Net Days',
                                  controller: _netDaysController,
                                  keyboardType: TextInputType.number,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Discount Days',
                                  controller: _discountDaysController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Discount %',
                                  controller: _discountPercentageController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Late Payment Fee (KES)',
                                  controller: _lateFeeController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),

                          // Credit Information
                          const SizedBox(height: 8),
                          Text(
                            'Credit Information',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Credit Limit (KES)',
                                  controller: _creditLimitController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Current Balance (KES)',
                                  controller: _currentBalanceController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Connection Details
                    _buildSection(
                      title: 'Connection Details',
                      icon: Icons.plumbing_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Connection Date',
                                  controller: _connectionDateController,
                                  required: true,
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                    context,
                                    _connectionDateController,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(
                                  context,
                                  _connectionDateController,
                                ),
                              ),
                            ],
                          ),

                          _buildDropdown<ConnectionType>(
                            label: 'Connection Type',
                            value: _connectionType,
                            items: ConnectionType.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _connectionType = value);
                              }
                            },
                            displayString: (type) => type.displayName,
                            required: true,
                          ),

                          _buildFormField(
                            label: 'Pipe Size',
                            controller: _pipeSizeController,
                          ),

                          _buildFormField(
                            label: 'Pressure Zone',
                            controller: _pressureZoneController,
                          ),

                          _buildFormField(
                            label: 'Water Source',
                            controller: _waterSourceController,
                          ),

                          _buildFormField(
                            label: 'Previous Provider',
                            controller: _previousProviderController,
                          ),
                        ],
                      ),
                    ),

                    // Communication Preferences
                    _buildSection(
                      title: 'Communication Preferences',
                      icon: Icons.settings_phone_outlined,
                      child: Column(
                        children: [
                          _buildDropdown<ContactMethod>(
                            label: 'Preferred Contact Method',
                            value: _preferredContactMethod,
                            items: ContactMethod.values,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _preferredContactMethod = value);
                              }
                            },
                            displayString: (method) => method.displayName,
                            required: true,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text('Receive Marketing'),
                                  value: _receiveMarketing,
                                  onChanged: (value) {
                                    setState(() => _receiveMarketing = value ?? false);
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text('Receive SMS'),
                                  value: _receiveSMS,
                                  onChanged: (value) {
                                    setState(() => _receiveSMS = value ?? false);
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),

                          CheckboxListTile(
                            title: const Text('Receive Email'),
                            value: _receiveEmail,
                            onChanged: (value) {
                              setState(() => _receiveEmail = value ?? false);
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          _buildDropdown<String>(
                            label: 'Language',
                            value: _language,
                            items: const ['en', 'sw'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _language = value);
                              }
                            },
                            displayString: (lang) => lang == 'en' ? 'English' : 'Swahili',
                          ),
                        ],
                      ),
                    ),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isCreating || state.isUpdating
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.isCreating || state.isUpdating
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            widget.initialCustomer == null
                                ? 'Create Customer'
                                : 'Update Customer',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (state.isCreating || state.isUpdating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}