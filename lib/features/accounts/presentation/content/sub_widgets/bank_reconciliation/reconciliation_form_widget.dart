import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/bank_reconciliation_model.dart';
import '../../../../providers/bank_reconciliation_provider.dart';

class ReconciliationFormWidget extends ConsumerStatefulWidget {
  final BankReconciliation? reconciliation;

  const ReconciliationFormWidget({super.key, this.reconciliation});

  @override
  ConsumerState<ReconciliationFormWidget> createState() =>
      _ReconciliationFormWidgetState();
}

class _ReconciliationFormWidgetState
    extends ConsumerState<ReconciliationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _statementBalanceController = TextEditingController();
  final _bookBalanceController = TextEditingController();
  final _statementDateController = TextEditingController();
  final _nextReconciliationDateController = TextEditingController();

  String? _selectedBankAccountId;
  DateTime? _statementDate;
  DateTime? _nextReconciliationDate;
  List<ClearedTransaction> _clearedTransactions = [];
  List<OutstandingItem> _outstandingItems = [];

  bool _isSubmitting = false;

  bool get _isEditing => widget.reconciliation != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditing) {
      final rec = widget.reconciliation!;
      _selectedBankAccountId = rec.bankAccountId;
      _statementDate = rec.statementDate;
      _nextReconciliationDate = rec.nextReconciliationDate;
      _statementBalanceController.text = rec.statementBalance.toStringAsFixed(2);
      _bookBalanceController.text = rec.bookBalance.toStringAsFixed(2);
      _clearedTransactions = List.from(rec.clearedTransactions);
      _outstandingItems = List.from(rec.outstandingItems);
      _updateDateControllers();
    } else {
      _statementDate = DateTime.now();
      _nextReconciliationDate = DateTime.now().add(const Duration(days: 30));
      _updateDateControllers();
    }
  }

  void _updateDateControllers() {
    if (_statementDate != null) {
      _statementDateController.text = _formatDate(_statementDate!);
    }
    if (_nextReconciliationDate != null) {
      _nextReconciliationDateController.text = _formatDate(_nextReconciliationDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankReconciliationProvider);
    final notifier = ref.read(bankReconciliationProvider.notifier);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: MediaQuery.of(context).size.width < 600 ? 16 : 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width < 600 ? 8 : 12),
                  Flexible(
                    child: Text(
                      _isEditing
                          ? 'Edit Reconciliation'
                          : 'Create New Reconciliation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 16 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.bankAccounts.isEmpty && !state.isLoadingBankAccounts)
                      _buildNoBankAccountsWarning(),
                    if (state.isLoadingBankAccounts)
                      _buildLoadingIndicator(),
                    // Basic Information
                    if (state.bankAccounts.isNotEmpty)
                      _buildBasicInfoSection(state),
                    const SizedBox(height: 20),
                    // Balances
                    if (state.bankAccounts.isNotEmpty)
                      _buildBalancesSection(),
                    const SizedBox(height: 20),
                    // Transactions
                    if (state.bankAccounts.isNotEmpty)
                      _buildTransactionsSection(),
                    const SizedBox(height: 20),
                    // Outstanding Items
                    if (state.bankAccounts.isNotEmpty)
                      _buildOutstandingItemsSection(),
                  ],
                ),
              ),
            ),
            // Actions
            if (state.bankAccounts.isNotEmpty)
              Container(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 600 ? 8 : 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitForm(state, notifier),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : Text(
                          _isEditing ? 'Update' : 'Create',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBankAccountsWarning() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.warning, size: 48, color: Colors.orange[700]),
            const SizedBox(height: 12),
            Text(
              'No Bank Accounts Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please create bank accounts in Chart of Accounts first.',
              style: TextStyle(
                color: Colors.orange[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading bank accounts...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BankReconciliationState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildBankAccountDropdown(state),
                      const SizedBox(height: 16),
                      _buildDateField(
                        'Statement Date',
                        _statementDateController,
                            () => _selectDate(true),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        'Next Reconciliation Date',
                        _nextReconciliationDateController,
                            () => _selectDate(false),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBankAccountDropdown(state),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 12 : 16),
                    Expanded(
                      child: _buildDateField(
                        'Statement Date',
                        _statementDateController,
                            () => _selectDate(true),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 12 : 16),
                    Expanded(
                      child: _buildDateField(
                        'Next Reconciliation Date',
                        _nextReconciliationDateController,
                            () => _selectDate(false),
                      ),
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

  Widget _buildBankAccountDropdown(BankReconciliationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Account *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: _selectedBankAccountId,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select a bank account',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ...state.bankAccounts.map((account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      account.accountName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (account.bankAccountNumber != null)
                      Text(
                        account.bankAccountNumber!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedBankAccountId = value;
            });
          },
          validator: (value) =>
          value == null ? 'Please select a bank account' : null,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label,
      TextEditingController controller,
      VoidCallback onTap,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          readOnly: true,
          onTap: onTap,
          validator: (value) =>
          value?.isEmpty == true ? 'Please select a date' : null,
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStatementDate) async {
    final currentDate = isStatementDate ? _statementDate : _nextReconciliationDate;
    final initialDate = currentDate ?? DateTime.now();
    final firstDate = isStatementDate ? DateTime(2020) : initialDate;
    final lastDate = DateTime(2030);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (isStatementDate) {
          _statementDate = selectedDate;
          _statementDateController.text = _formatDate(selectedDate);
          // Ensure next reconciliation date is after statement date
          if (_nextReconciliationDate != null &&
              _nextReconciliationDate!.isBefore(selectedDate)) {
            _nextReconciliationDate = selectedDate.add(const Duration(days: 30));
            _nextReconciliationDateController.text =
                _formatDate(_nextReconciliationDate!);
          }
        } else {
          _nextReconciliationDate = selectedDate;
          _nextReconciliationDateController.text = _formatDate(selectedDate);
        }
      });
    }
  }

  Widget _buildBalancesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balances',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildBalanceField(
                        'Statement Balance',
                        _statementBalanceController,
                        'KES',
                      ),
                      const SizedBox(height: 16),
                      _buildBalanceField(
                        'Book Balance',
                        _bookBalanceController,
                        'KES',
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBalanceField(
                        'Statement Balance',
                        _statementBalanceController,
                        'KES',
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 12 : 16),
                    Expanded(
                      child: _buildBalanceField(
                        'Book Balance',
                        _bookBalanceController,
                        'KES',
                      ),
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

  Widget _buildBalanceField(
      String label,
      TextEditingController controller,
      String prefix,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            prefixText: '$prefix ',
            prefixStyle: const TextStyle(color: Colors.black),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            final amount = double.tryParse(value.replaceAll(',', '.'));
            if (amount == null) {
              return 'Please enter a valid amount';
            }
            if (amount <= 0) {
              return 'Amount must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cleared Transactions',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (!_isEditing || widget.reconciliation!.canEdit)
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                    onPressed: _addClearedTransaction,
                    tooltip: 'Add Transaction',
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_clearedTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No cleared transactions',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_isEditing || widget.reconciliation!.canEdit)
                      TextButton(
                        onPressed: _addClearedTransaction,
                        child: const Text('Add Transaction'),
                      ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _clearedTransactions.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildTransactionItem(_clearedTransactions[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(ClearedTransaction transaction, int index) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getTransactionColor(transaction.transactionType)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTransactionIcon(transaction.transactionType),
                color: _getTransactionColor(transaction.transactionType),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${transaction.reference}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _getTransactionAmountColor(transaction.transactionType),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTransactionTypeText(transaction.transactionType),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (!_isEditing || widget.reconciliation!.canEdit) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.red[400],
                ),
                onPressed: () {
                  setState(() {
                    _clearedTransactions.removeAt(index);
                  });
                },
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingItemsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Outstanding Items',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (!_isEditing || widget.reconciliation!.canEdit)
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                    onPressed: _addOutstandingItem,
                    tooltip: 'Add Outstanding Item',
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_outstandingItems.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No outstanding items',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_isEditing || widget.reconciliation!.canEdit)
                      TextButton(
                        onPressed: _addOutstandingItem,
                        child: const Text('Add Outstanding Item'),
                      ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _outstandingItems.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildOutstandingItem(_outstandingItems[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingItem(OutstandingItem item, int index) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: item.cleared ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      color: item.cleared ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.cleared ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.cleared ? Icons.check_circle : Icons.pending,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${item.reference}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(item.itemDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getOutstandingItemTypeText(item.itemType),
                    style: TextStyle(
                      fontSize: 11,
                      color: item.cleared ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.cleared && item.clearedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Cleared ${_formatDate(item.clearedDate!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(item.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (!_isEditing || widget.reconciliation!.canEdit) ...[
                  if (!item.cleared)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _outstandingItems[index] = item.copyWith(
                            cleared: true,
                            clearedDate: DateTime.now(),
                          );
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Mark Cleared',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _outstandingItems.removeAt(index);
                      });
                    },
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addClearedTransaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cleared Transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TransactionType>(
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: TransactionType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getTransactionTypeText(type)),
                ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTransaction = ClearedTransaction(
                transactionDate: DateTime.now(),
                description: 'Sample Transaction',
                amount: 1000.0,
                transactionType: TransactionType.deposit,
                reference: 'REF-${DateTime.now().millisecondsSinceEpoch}',
              );
              setState(() => _clearedTransactions.add(newTransaction));
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addOutstandingItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Outstanding Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OutstandingItemType>(
                decoration: const InputDecoration(
                  labelText: 'Item Type',
                  border: OutlineInputBorder(),
                ),
                items: OutstandingItemType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getOutstandingItemTypeText(type)),
                ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = OutstandingItem(
                itemDate: DateTime.now(),
                description: 'Sample Outstanding Item',
                amount: 500.0,
                itemType: OutstandingItemType.outstanding_check,
                reference: 'CHK-${DateTime.now().millisecondsSinceEpoch}',
              );
              setState(() => _outstandingItems.add(newItem));
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankAccountId == null ||
        _statementDate == null ||
        _nextReconciliationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      final data = CreateReconciliationData(
        bankAccount: _selectedBankAccountId!,
        statementDate: _statementDate!,
        statementBalance:
        double.parse(_statementBalanceController.text.replaceAll(',', '.')),
        bookBalance:
        double.parse(_bookBalanceController.text.replaceAll(',', '.')),
        clearedTransactions: _clearedTransactions,
        outstandingItems: _outstandingItems,
        nextReconciliationDate: _nextReconciliationDate!,
      );

      bool success;
      if (_isEditing) {
        success = await notifier.updateReconciliation(
          widget.reconciliation!.id!,
          data.toJson(),
        );
      } else {
        success = await notifier.createReconciliation(data);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.bank_charge:
        return Colors.orange;
      case TransactionType.interest:
        return Colors.blue;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.bank_charge:
        return Icons.attach_money;
      case TransactionType.interest:
        return Icons.trending_up;
    }
  }

  Color _getTransactionAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
      case TransactionType.interest:
        return Colors.green;
      case TransactionType.withdrawal:
      case TransactionType.bank_charge:
        return Colors.red;
    }
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.bank_charge:
        return 'Bank Charge';
      case TransactionType.interest:
        return 'Interest';
    }
  }

  String _getOutstandingItemTypeText(OutstandingItemType type) {
    switch (type) {
      case OutstandingItemType.outstanding_deposit:
        return 'Outstanding Deposit';
      case OutstandingItemType.outstanding_check:
        return 'Outstanding Check';
      case OutstandingItemType.bank_error:
        return 'Bank Error';
      case OutstandingItemType.book_error:
        return 'Book Error';
    }
  }

  @override
  void dispose() {
    _statementBalanceController.dispose();
    _bookBalanceController.dispose();
    _statementDateController.dispose();
    _nextReconciliationDateController.dispose();
    super.dispose();
  }
}