import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/chart_of_account_model.dart';
import '../../../../models/journal_entry_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';
import '../../../../providers/journal_entry_provider.dart';

class JournalEntryFormWidget extends ConsumerStatefulWidget {
  final JournalEntry? initialEntry;
  final VoidCallback? onSaved;

  const JournalEntryFormWidget({
    super.key,
    this.initialEntry,
    this.onSaved,
  });

  @override
  ConsumerState<JournalEntryFormWidget> createState() =>
      _JournalEntryFormWidgetState();
}

class _JournalEntryFormWidgetState
    extends ConsumerState<JournalEntryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accountingPeriodController = TextEditingController();
  final _fiscalYearController = TextEditingController();

  DateTime _entryDate = DateTime.now();
  SourceDocument _sourceDocument = SourceDocument.manual;
  String? _sourceId;
  final List<JournalTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadAccounts();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    _accountingPeriodController.dispose();
    _fiscalYearController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.initialEntry != null) {
      final entry = widget.initialEntry!;
      _referenceController.text = entry.reference;
      _descriptionController.text = entry.description;
      _entryDate = entry.entryDate;
      _sourceDocument = entry.sourceDocument;
      _sourceId = entry.sourceId;
      _accountingPeriodController.text = entry.accountingPeriod;
      _fiscalYearController.text = entry.fiscalYear;
      _transactions.addAll(entry.transactions);
    } else {
      // Set default values for new entry
      _referenceController.text = 'JE-${DateTime.now().millisecondsSinceEpoch}';
      _accountingPeriodController.text =
      '${DateTime.now().month}/${DateTime.now().year}';
      _fiscalYearController.text = DateTime.now().year.toString();
      _addEmptyTransaction();
      _addEmptyTransaction();
    }
  }

  void _loadAccounts() {
    ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
  }

  void _addEmptyTransaction() {
    setState(() {
      _transactions.add(JournalTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: '',
        accountCode: '',
        accountName: '',
        description: '',
        debit: 0,
        credit: 0,
        taxAmount: 0,
      ));
    });
  }

  void _removeTransaction(int index) {
    if (_transactions.length > 2) {
      setState(() {
        _transactions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least two transactions are required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateTransaction(int index, JournalTransaction transaction) {
    setState(() {
      _transactions[index] = transaction;
    });
  }

  bool _validateTransactions() {
    // Check minimum transactions
    if (_transactions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least two transactions are required'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check all accounts are selected
    for (final transaction in _transactions) {
      if (transaction.accountId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All transactions must have an account selected'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (transaction.debit == 0 && transaction.credit == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Transactions must have either debit or credit amount'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (transaction.debit > 0 && transaction.credit > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Transactions cannot have both debit and credit amounts'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    // Check debit/credit balance
    final totalDebit = _transactions.fold<double>(0, (sum, t) => sum + t.debit);
    final totalCredit =
    _transactions.fold<double>(0, (sum, t) => sum + t.credit);

    if ((totalDebit - totalCredit).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Debit and credit must balance. Difference: ${(totalDebit - totalCredit).abs().toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveJournalEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateTransactions()) return;

    try {
      final entryData = {
        'entryDate': _entryDate.toIso8601String(),
        'reference': _referenceController.text.trim(),
        'description': _descriptionController.text.trim(),
        'transactions': _transactions.map((t) => t.toJson()).toList(),
        'sourceDocument': _sourceDocument.name,
        if (_sourceId != null && _sourceId!.isNotEmpty) 'sourceId': _sourceId,
        'accountingPeriod': _accountingPeriodController.text.trim(),
        'fiscalYear': _fiscalYearController.text.trim(),
      };

      final success = widget.initialEntry != null
          ? await ref
          .read(journalEntryProvider.notifier)
          .updateJournalEntry(widget.initialEntry!.id, entryData)
          : await ref
          .read(journalEntryProvider.notifier)
          .createJournalEntry(entryData);

      if (success && mounted) {
        widget.onSaved?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDebit = _transactions.fold<double>(0, (sum, t) => sum + t.debit);
    final totalCredit =
    _transactions.fold<double>(0, (sum, t) => sum + t.credit);
    final balanceDifference = (totalDebit - totalCredit).abs();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Form Content
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Basic Info
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildBasicInfoSection(),
                              const SizedBox(height: 24),
                              _buildTransactionsSection(),
                            ],
                          ),
                        ),
                      ),
                      // Footer with totals and actions
                      _buildFooter(totalDebit, totalCredit, balanceDifference),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF0D47A1), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.initialEntry != null
                  ? 'Edit Journal Entry'
                  : 'Create Journal Entry',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildReferenceField(),
                      const SizedBox(height: 16),
                      _buildSourceDocumentDropdown(),
                    ],
                  );
                }
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth < 800
                          ? constraints.maxWidth / 3 - 16
                          : 200,
                      child: _buildDateField(),
                    ),
                    SizedBox(
                      width: constraints.maxWidth < 800
                          ? constraints.maxWidth / 3 - 16
                          : 200,
                      child: _buildReferenceField(),
                    ),
                    SizedBox(
                      width: constraints.maxWidth < 800
                          ? constraints.maxWidth / 3 - 16
                          : 200,
                      child: _buildSourceDocumentDropdown(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      _buildAccountingPeriodField(),
                      const SizedBox(height: 16),
                      _buildFiscalYearField(),
                    ],
                  );
                }
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth < 800
                          ? constraints.maxWidth / 2 - 24
                          : 200,
                      child: _buildAccountingPeriodField(),
                    ),
                    SizedBox(
                      width: constraints.maxWidth < 800
                          ? constraints.maxWidth / 2 - 24
                          : 200,
                      child: _buildFiscalYearField(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Entry Date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      controller: TextEditingController(
        text: '${_entryDate.year}-${_entryDate.month.toString().padLeft(2, '0')}-${_entryDate.day.toString().padLeft(2, '0')}',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _entryDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && mounted) {
          setState(() => _entryDate = picked);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entry date is required';
        }
        return null;
      },
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _referenceController,
      decoration: InputDecoration(
        labelText: 'Reference',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.tag),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Reference is required';
        }
        return null;
      },
    );
  }

  Widget _buildSourceDocumentDropdown() {
    return DropdownButtonFormField<SourceDocument>(
      value: _sourceDocument,
      decoration: InputDecoration(
        labelText: 'Source Document',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.description),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: SourceDocument.values.map((source) {
        return DropdownMenuItem(
          value: source,
          child: Text(_formatSourceDocument(source)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null && mounted) {
          setState(() => _sourceDocument = value);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Source document is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description is required';
        }
        return null;
      },
    );
  }

  Widget _buildAccountingPeriodField() {
    return TextFormField(
      controller: _accountingPeriodController,
      decoration: InputDecoration(
        labelText: 'Accounting Period',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.date_range),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Accounting period is required';
        }
        return null;
      },
    );
  }

  Widget _buildFiscalYearField() {
    return TextFormField(
      controller: _fiscalYearController,
      decoration: InputDecoration(
        labelText: 'Fiscal Year',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.date_range),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Fiscal year is required';
        }
        return null;
      },
    );
  }

  Widget _buildTransactionsSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addEmptyTransaction,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: 'Add Transaction',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              return TransactionRowWidget(
                key: Key('${transaction.id}_$index'),
                transaction: transaction,
                onChanged: (updatedTransaction) =>
                    _updateTransaction(index, updatedTransaction),
                onRemove: _transactions.length > 2
                    ? () => _removeTransaction(index)
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(
      double totalDebit, double totalCredit, double balanceDifference) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Totals Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTotalItem('Total Debit', totalDebit, Colors.green),
                const SizedBox(width: 24),
                _buildTotalItem('Total Credit', totalCredit, Colors.red),
                const SizedBox(width: 24),
                _buildTotalItem(
                  'Difference',
                  balanceDifference,
                  balanceDifference <= 0.01 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saveJournalEntry,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Journal Entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatSourceDocument(SourceDocument source) {
    switch (source) {
      case SourceDocument.manual:
        return 'Manual Entry';
      case SourceDocument.invoice:
        return 'Invoice';
      case SourceDocument.payment:
        return 'Payment';
      case SourceDocument.receipt:
        return 'Receipt';
      case SourceDocument.purchase_order:
        return 'Purchase Order';
      case SourceDocument.sales_order:
        return 'Sales Order';
      case SourceDocument.bank_reconciliation:
        return 'Bank Reconciliation';
      case SourceDocument.adjustment:
        return 'Adjustment';
    }
  }
}

class TransactionRowWidget extends ConsumerStatefulWidget {
  final JournalTransaction transaction;
  final ValueChanged<JournalTransaction> onChanged;
  final VoidCallback? onRemove;

  const TransactionRowWidget({
    super.key,
    required this.transaction,
    required this.onChanged,
    this.onRemove,
  });

  @override
  ConsumerState<TransactionRowWidget> createState() =>
      _TransactionRowWidgetState();
}

class _TransactionRowWidgetState extends ConsumerState<TransactionRowWidget> {
  final _descriptionController = TextEditingController();
  final _debitController = TextEditingController();
  final _creditController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _projectCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    _costCenterController.dispose();
    _projectCodeController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _descriptionController.text = widget.transaction.description;
    _debitController.text = widget.transaction.debit > 0
        ? widget.transaction.debit.toStringAsFixed(2)
        : '';
    _creditController.text = widget.transaction.credit > 0
        ? widget.transaction.credit.toStringAsFixed(2)
        : '';
    _costCenterController.text = widget.transaction.costCenter ?? '';
    _projectCodeController.text = widget.transaction.projectCode ?? '';
  }

  void _updateTransaction() {
    final updatedTransaction = widget.transaction.copyWith(
      description: _descriptionController.text.trim(),
      debit: double.tryParse(_debitController.text) ?? 0,
      credit: double.tryParse(_creditController.text) ?? 0,
      costCenter: _costCenterController.text.trim().isEmpty
          ? null
          : _costCenterController.text.trim(),
      projectCode: _projectCodeController.text.trim().isEmpty
          ? null
          : _projectCodeController.text.trim(),
    );
    widget.onChanged(updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(chartOfAccountsProvider);
    final selectedAccount = accountsState.accounts.firstWhere(
          (account) => account.id == widget.transaction.accountId,
      orElse: () => ChartOfAccount(
        id: '',
        accountCode: '',
        accountName: '',
        accountType: AccountType.asset,
        accountCategory: AccountCategory.current_assets,
        description: '',
        level: 1,
        normalBalance: NormalBalance.debit,
        isSystemAccount: false,
        isActive: true,
        budgetAllowed: true,
        requiresApproval: false,
        taxApplicable: false,
        isBankAccount: false,
        createdById: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Account Selection
          DropdownButtonFormField<ChartOfAccount>(
            value: selectedAccount.id.isEmpty ? null : selectedAccount,
            decoration: InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: accountsState.accounts
                .where((account) => account.isActive)
                .map((account) {
              return DropdownMenuItem(
                value: account,
                child: Text('${account.accountCode} - ${account.accountName}'),
              );
            }).toList(),
            onChanged: (account) {
              if (account != null && mounted) {
                final updatedTransaction = widget.transaction.copyWith(
                  accountId: account.id,
                  accountCode: account.accountCode,
                  accountName: account.accountName,
                );
                widget.onChanged(updatedTransaction);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Account is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (_) => _updateTransaction(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Amounts Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              if (isMobile) {
                return Column(
                  children: [
                    _buildAmountField(_debitController, 'Debit', Colors.green),
                    const SizedBox(height: 12),
                    _buildAmountField(_creditController, 'Credit', Colors.red),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                      child: _buildAmountField(
                          _debitController, 'Debit', Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildAmountField(
                          _creditController, 'Credit', Colors.red)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Optional Fields
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              if (isMobile) {
                return Column(
                  children: [
                    _buildOptionalField(_costCenterController, 'Cost Center'),
                    const SizedBox(height: 12),
                    _buildOptionalField(_projectCodeController, 'Project Code'),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                      child: _buildOptionalField(
                          _costCenterController, 'Cost Center')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildOptionalField(
                          _projectCodeController, 'Project Code')),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Remove Button
          if (widget.onRemove != null)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remove Transaction',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountField(
      TextEditingController controller, String label, Color color) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixText: 'KES ',
        prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _updateTransaction(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label amount is required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount < 0) {
          return 'Enter a valid $label amount';
        }
        return null;
      },
    );
  }

  Widget _buildOptionalField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (_) => _updateTransaction(),
    );
  }
}