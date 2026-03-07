import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/chart_of_account_model.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class PaymentFormWidget extends ConsumerStatefulWidget {
  final Payment? payment;

  const PaymentFormWidget({super.key, this.payment});

  @override
  ConsumerState<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends ConsumerState<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Payment _payment;
  late Map<String, dynamic> _formData;
  final List<PlatformFile> _newFiles = [];
  bool _initialBankFetchDone = false;

  @override
  void initState() {
    super.initState();
    _payment = widget.payment ?? _createEmptyPayment();
    _formData = {
      'paymentDate': _payment.paymentDate.toIso8601String(),
      'paymentType': _payment.paymentType.name,
      'paymentMethod': _payment.paymentMethod.name,
      'payeeType': _payment.payeeType.name,
      'payeeName': _payment.payeeName ?? '',
      'payeeEmail': _payment.payeeEmail ?? '',
      'payeePhone': _payment.payeePhone ?? '',
      'payeeBankAccount': _payment.payeeBankAccount ?? '',
      'payeeBankAccountName': _payment.payeeBankAccountName ?? '',
      'companyBankName': _payment.companyBankName ?? '',
      'companyBankAccount': _payment.companyBankAccount ?? '',
      'amount': _payment.amount,
      'taxAmount': _payment.taxAmount,
      'withholdingTax': _payment.withholdingTax,
      'netAmount': _payment.netAmount,
      'invoiceNumber': _payment.invoiceNumber ?? '',
      'purchaseOrderNumber': _payment.purchaseOrderNumber ?? '',
      'contractNumber': _payment.contractNumber ?? '',
      'checkNumber': _payment.checkNumber ?? '',
      'transactionReference': _payment.transactionReference ?? '',
      'description': _payment.description ?? '',
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch bank accounts when the widget is mounted/opened
    if (!_initialBankFetchDone) {
      _initialBankFetchDone = true;
      ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();
    }
  }

  Payment _createEmptyPayment() {
    return Payment(
      id: '',
      paymentNumber: '',
      paymentDate: DateTime.now(),
      paymentType: PaymentType.supplier_payment,
      paymentMethod: PaymentMethod.bank_transfer,
      payeeType: PayeeType.supplier,
      payeeName: '',
      amount: 0.0,
      netAmount: 0.0,
      status: PaymentStatus.draft,
      createdById: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      documents: const [],
    );
  }

  void _updateNetAmount() {
    final amount = (_formData['amount'] as num?)?.toDouble() ?? 0.0;
    final withholdingTax = (_formData['withholdingTax'] as num?)?.toDouble() ?? 0.0;
    _formData['netAmount'] = amount - withholdingTax;
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_formData['paymentDate']),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _formData['paymentDate'] = picked.toIso8601String();
      });
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _newFiles.addAll(result.files);
      });
    }
  }

  void _removeNewFile(int index) {
    setState(() {
      _newFiles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final paymentNotifier = ref.read(paymentProvider.notifier);

    final newPayment = _payment.copyWith(
      paymentDate: DateTime.parse(_formData['paymentDate']),
      paymentType: PaymentType.values.firstWhere((e) => e.name == _formData['paymentType']),
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == _formData['paymentMethod']),
      payeeType: PayeeType.values.firstWhere((e) => e.name == _formData['payeeType']),
      payeeName: _formData['payeeName'],
      payeeEmail: _formData['payeeEmail'],
      payeePhone: _formData['payeePhone'],
      payeeBankAccount: _formData['payeeBankAccount'],
      payeeBankAccountName: _formData['payeeBankAccountName'],
      companyBankName: _formData['companyBankName'],
      companyBankAccount: _formData['companyBankAccount'],
      amount: (_formData['amount'] as num).toDouble(),
      taxAmount: (_formData['taxAmount'] as num?)?.toDouble() ?? 0.0,
      withholdingTax: (_formData['withholdingTax'] as num?)?.toDouble() ?? 0.0,
      netAmount: (_formData['netAmount'] as num).toDouble(),
      invoiceNumber: _formData['invoiceNumber'],
      purchaseOrderNumber: _formData['purchaseOrderNumber'],
      contractNumber: _formData['contractNumber'],
      checkNumber: _formData['checkNumber'],
      transactionReference: _formData['transactionReference'],
      description: _formData['description'],
    );

    bool success;
    String? paymentId;

    if (widget.payment == null) {
      success = await paymentNotifier.createPayment(newPayment);
      if (success) {
        await paymentNotifier.fetchPayments(page: 1);
        final createdPayment = paymentNotifier.state.payments.firstWhere(
              (p) => p.paymentDate == newPayment.paymentDate && p.amount == newPayment.amount && p.payeeName == newPayment.payeeName,
          orElse: () => paymentNotifier.state.payments.first,
        );
        paymentId = createdPayment.id;
      }
    } else {
      success = await paymentNotifier.updatePayment(_payment.id, newPayment);
      paymentId = _payment.id;
    }

    if (!success || paymentId == null || !mounted) return;

    // Upload new documents
    for (var file in _newFiles) {
      if (file.path != null) {
        final uploadSuccess = await paymentNotifier.uploadPaymentDocument(paymentId, file);
        if (!uploadSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload ${file.name}')),
          );
        }
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList())
            : Row(children: children.asMap().entries.map((e) => Expanded(child: Padding(padding: e.key > 0 ? const EdgeInsets.only(left: 16) : EdgeInsets.zero, child: e.value))).toList());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankAccounts = ref.watch(chartOfAccountsProvider.select((s) => s.bankAccounts));
    final isLoadingBank = ref.watch(chartOfAccountsProvider.select((s) => s.isLoadingBankAccounts));
    final isUploading = ref.watch(paymentProvider.select((s) => s.isUploadingDocument));

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(widget.payment == null ? Icons.add : Icons.edit, color: const Color(0xFF0D47A1), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.payment == null ? 'Create Payment' : 'Edit Payment',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Payment Information'),
                        _buildResponsiveRow([_buildPaymentTypeDropdown(), _buildPaymentMethodDropdown(), _buildPayeeTypeDropdown()]),
                        const SizedBox(height: 16),
                        _buildPaymentDateField(),

                        _buildSectionHeader('Payee Information'),
                        _buildPayeeNameField(),
                        const SizedBox(height: 16),
                        _buildResponsiveRow([_buildPayeeEmailField(), _buildPayeePhoneField()]),
                        const SizedBox(height: 16),
                        _buildResponsiveRow([_buildPayeeBankAccountField(), _buildPayeeBankAccountNameField()]),

                        _buildSectionHeader('Company Bank Details'),
                        if (isLoadingBank)
                          const Center(child: CircularProgressIndicator())
                        else if (bankAccounts.isEmpty)
                          const Text('No bank accounts configured', style: TextStyle(color: Colors.orange))
                        else
                          _buildCompanyBankAccountDropdown(bankAccounts),

                        _buildSectionHeader('Amount Information'),
                        _buildAmountField(),
                        const SizedBox(height: 16),
                        _buildResponsiveRow([_buildTaxAmountField(), _buildWithholdingTaxField()]),
                        const SizedBox(height: 16),
                        _buildNetAmountDisplay(),

                        _buildSectionHeader('Reference Numbers'),
                        _buildResponsiveRow([_buildInvoiceNumberField(), _buildPurchaseOrderNumberField(), _buildContractNumberField()]),

                        _buildSectionHeader('Payment Details'),
                        if (_formData['paymentMethod'] == PaymentMethod.check.name) ...[
                          _buildCheckNumberField(),
                          const SizedBox(height: 16),
                        ],
                        if (_formData['paymentMethod'] == PaymentMethod.bank_transfer.name ||
                            _formData['paymentMethod'] == PaymentMethod.mobile_money.name)
                          _buildTransactionReferenceField(),

                        _buildSectionHeader('Supporting Documents (Optional)'),
                        const Text('Attach invoices, receipts, contracts, etc.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                        const SizedBox(height: 12),

                        if (widget.payment != null && widget.payment!.documents.isNotEmpty) ...[
                          const Text('Existing Documents:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          ...widget.payment!.documents.map((doc) => ListTile(
                            leading: Icon(doc.fileIcon, color: doc.fileColor),
                            title: Text(doc.originalName ?? doc.fileName),
                            subtitle: Text(doc.fileSizeFormatted),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Document'),
                                    content: Text('Delete ${doc.originalName ?? doc.fileName}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(paymentProvider.notifier).deletePaymentDocument(widget.payment!.id, doc.id);
                                }
                              },
                            ),
                          )),
                          const Divider(),
                        ],

                        if (_newFiles.isNotEmpty) ...[
                          const Text('New Files to Upload:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          ..._newFiles.asMap().entries.map((e) => ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(e.value.name),
                            subtitle: e.value.size > 0 ? Text('${(e.value.size / 1024).toStringAsFixed(1)} KB') : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeNewFile(e.key),
                            ),
                          )),
                        ],

                        _buildSectionHeader('Additional Information'),
                        _buildDescriptionField(),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isUploading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                              child: isUploading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(widget.payment == null ? 'Create Payment' : 'Update Payment'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Field Builders

  Widget _buildPaymentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _formData['paymentType'],
      decoration: const InputDecoration(labelText: 'Payment Type *', border: OutlineInputBorder()),
      items: PaymentType.values
          .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '))))
          .toList(),
      onChanged: (v) => setState(() => _formData['paymentType'] = v!),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _formData['paymentMethod'],
      decoration: const InputDecoration(labelText: 'Payment Method *', border: OutlineInputBorder()),
      items: PaymentMethod.values
          .map((m) => DropdownMenuItem(value: m.name, child: Text(m.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '))))
          .toList(),
      onChanged: (v) => setState(() => _formData['paymentMethod'] = v!),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildPayeeTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _formData['payeeType'],
      decoration: const InputDecoration(labelText: 'Payee Type *', border: OutlineInputBorder()),
      items: PayeeType.values
          .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '))))
          .toList(),
      onChanged: (v) => setState(() => _formData['payeeType'] = v!),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildPaymentDateField() {
    return TextFormField(
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Payment Date *',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
        hintText: DateTime.parse(_formData['paymentDate']).toLocal().toString().split(' ')[0],
      ),
    );
  }

  Widget _buildPayeeNameField() {
    return TextFormField(
      initialValue: _formData['payeeName'],
      decoration: const InputDecoration(labelText: 'Payee Name *', border: OutlineInputBorder()),
      onChanged: (v) => _formData['payeeName'] = v,
      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildPayeeEmailField() {
    return TextFormField(
      initialValue: _formData['payeeEmail'],
      decoration: const InputDecoration(labelText: 'Payee Email', border: OutlineInputBorder()),
      keyboardType: TextInputType.emailAddress,
      onChanged: (v) => _formData['payeeEmail'] = v,
    );
  }

  Widget _buildPayeePhoneField() {
    return TextFormField(
      initialValue: _formData['payeePhone'],
      decoration: const InputDecoration(labelText: 'Payee Phone', border: OutlineInputBorder()),
      keyboardType: TextInputType.phone,
      onChanged: (v) => _formData['payeePhone'] = v,
    );
  }

  Widget _buildPayeeBankAccountField() {
    return TextFormField(
      initialValue: _formData['payeeBankAccount'],
      decoration: const InputDecoration(labelText: 'Payee Bank Account', border: OutlineInputBorder()),
      onChanged: (v) => _formData['payeeBankAccount'] = v,
    );
  }

  Widget _buildPayeeBankAccountNameField() {
    return TextFormField(
      initialValue: _formData['payeeBankAccountName'],
      decoration: const InputDecoration(labelText: 'Payee Account Name', border: OutlineInputBorder()),
      onChanged: (v) => _formData['payeeBankAccountName'] = v,
    );
  }

  Widget _buildCompanyBankAccountDropdown(List<ChartOfAccount> accounts) {
    final selected = _formData['companyBankAccount'].isNotEmpty ? _formData['companyBankAccount'] : null;

    return DropdownButtonFormField<String>(
      value: selected,
      decoration: const InputDecoration(labelText: 'Company Bank Account *', border: OutlineInputBorder()),
      hint: const Text('Select account'),
      items: accounts
          .map((a) => DropdownMenuItem(
        value: a.bankAccountNumber,
        child: Text('${a.bankName ?? 'Unknown Bank'} - ${a.bankAccountNumber ?? 'No Number'}'),
      ))
          .toList(),
      onChanged: (v) {
        final acc = accounts.firstWhere((a) => a.bankAccountNumber == v, orElse: () => accounts.first);
        setState(() {
          _formData['companyBankAccount'] = acc.bankAccountNumber ?? '';
          _formData['companyBankName'] = acc.bankName ?? '';
        });
      },
      validator: (v) => v == null || v.isEmpty ? 'Please select a bank account' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      initialValue: _formData['amount'] > 0 ? _formData['amount'].toString() : '',
      decoration: const InputDecoration(labelText: 'Amount (KES) *', border: OutlineInputBorder(), prefixText: 'KES '),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final val = double.tryParse(v) ?? 0.0;
        _formData['amount'] = val;
        _updateNetAmount();
      },
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final num = double.tryParse(v);
        if (num == null || num <= 0) return 'Enter a valid positive amount';
        return null;
      },
    );
  }

  Widget _buildTaxAmountField() {
    return TextFormField(
      initialValue: _formData['taxAmount'] > 0 ? _formData['taxAmount'].toString() : '',
      decoration: const InputDecoration(labelText: 'Tax Amount (KES)', border: OutlineInputBorder(), prefixText: 'KES '),
      keyboardType: TextInputType.number,
      onChanged: (v) => _formData['taxAmount'] = double.tryParse(v) ?? 0.0,
    );
  }

  Widget _buildWithholdingTaxField() {
    return TextFormField(
      initialValue: _formData['withholdingTax'] > 0 ? _formData['withholdingTax'].toString() : '',
      decoration: const InputDecoration(labelText: 'Withholding Tax (KES)', border: OutlineInputBorder(), prefixText: 'KES '),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        _formData['withholdingTax'] = double.tryParse(v) ?? 0.0;
        _updateNetAmount();
      },
    );
  }

  Widget _buildNetAmountDisplay() {
    final net = _formData['netAmount']?.toStringAsFixed(2) ?? '0.00';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0D47A1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.calculate, color: Color(0xFF0D47A1)),
          const SizedBox(width: 12),
          const Text('Net Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('KES $net', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        ],
      ),
    );
  }

  Widget _buildInvoiceNumberField() => TextFormField(initialValue: _formData['invoiceNumber'], decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()), onChanged: (v) => _formData['invoiceNumber'] = v);

  Widget _buildPurchaseOrderNumberField() => TextFormField(initialValue: _formData['purchaseOrderNumber'], decoration: const InputDecoration(labelText: 'PO Number', border: OutlineInputBorder()), onChanged: (v) => _formData['purchaseOrderNumber'] = v);

  Widget _buildContractNumberField() => TextFormField(initialValue: _formData['contractNumber'], decoration: const InputDecoration(labelText: 'Contract Number', border: OutlineInputBorder()), onChanged: (v) => _formData['contractNumber'] = v);

  // FIXED CHECK NUMBER VALIDATOR
  Widget _buildCheckNumberField() {
    return TextFormField(
      initialValue: _formData['checkNumber'],
      decoration: const InputDecoration(labelText: 'Check Number *', border: OutlineInputBorder()),
      onChanged: (v) => _formData['checkNumber'] = v,
      validator: (value) {
        if (_formData['paymentMethod'] == PaymentMethod.check.name) {
          if (value == null || value.trim().isEmpty) {
            return 'Check number is required for check payments';
          }
        }
        return null;
      },
    );
  }

  Widget _buildTransactionReferenceField() {
    return TextFormField(
      initialValue: _formData['transactionReference'],
      decoration: const InputDecoration(labelText: 'Transaction Reference', border: OutlineInputBorder()),
      onChanged: (v) => _formData['transactionReference'] = v,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      initialValue: _formData['description'],
      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
      maxLines: 4,
      onChanged: (v) => _formData['description'] = v,
    );
  }
}