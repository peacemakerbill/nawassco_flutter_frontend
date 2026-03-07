import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/budget_model.dart';
import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class BudgetItemFormWidget extends ConsumerStatefulWidget {
  final BudgetItem? item;
  final Function(BudgetItem)? onSave;

  const BudgetItemFormWidget({
    super.key,
    this.item,
    this.onSave,
  });

  @override
  ConsumerState<BudgetItemFormWidget> createState() => _BudgetItemFormWidgetState();
}

class _BudgetItemFormWidgetState extends ConsumerState<BudgetItemFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _budgetAmountController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _projectCodeController = TextEditingController();
  final _notesController = TextEditingController();

  ChartOfAccount? _selectedAccount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _initializeFormWithItem();
    }
  }

  void _initializeFormWithItem() {
    final item = widget.item!;
    _budgetAmountController.text = item.budgetAmount.toStringAsFixed(2);
    _costCenterController.text = item.costCenter ?? '';
    _projectCodeController.text = item.projectCode ?? '';
    _notesController.text = item.notes ?? '';

    // Try to find the account in the loaded accounts
    _findAccountById(item.account);
  }

  void _findAccountById(String accountId) async {
    final chartOfAccountsState = ref.read(chartOfAccountsProvider);

    // Create a temporary account with the item's data if not found
    final foundAccount = chartOfAccountsState.accounts
        .firstWhere(
          (acc) => acc.id == accountId,
      orElse: () {
        // Create a temporary account with item data
        return ChartOfAccount(
          id: accountId,
          accountCode: widget.item?.accountCode ?? '',
          accountName: widget.item?.accountName ?? 'Unknown Account',
          accountType: AccountType.expense,
          accountCategory: AccountCategory.operating_expenses,
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
        );
      },
    );

    setState(() {
      _selectedAccount = foundAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Get budget allowed accounts from provider
    final chartOfAccountsState = ref.watch(chartOfAccountsProvider);
    final budgetAllowedAccounts = chartOfAccountsState.accounts
        .where((account) => account.budgetAllowed && account.isActive)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_chart,
                    color: theme.colorScheme.primary,
                    size: isMobile ? 22 : 24,
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Text(
                      widget.item == null ? 'Add Budget Item' : 'Edit Budget Item',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 40 : 48,
                      minHeight: isMobile ? 40 : 48,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                controller: ScrollController(),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 16 : 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.4,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Selection
                        _buildAccountSelector(
                          budgetAllowedAccounts,
                          isMobile,
                          screenHeight,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        // Budget Amount
                        TextFormField(
                          controller: _budgetAmountController,
                          decoration: InputDecoration(
                            labelText: 'Budget Amount (KES)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 12 : 14,
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter budget amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Please enter a valid amount';
                            }
                            if (amount <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isMobile ? 12 : 16),

                        // Cost Center
                        TextFormField(
                          controller: _costCenterController,
                          decoration: InputDecoration(
                            labelText: 'Cost Center (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.business),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 12 : 14,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),

                        // Project Code
                        TextFormField(
                          controller: _projectCodeController,
                          decoration: InputDecoration(
                            labelText: 'Project Code (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.code),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 12 : 14,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),

                        // Notes
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.notes),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 12 : 14,
                            ),
                          ),
                        ),

                        // Add some extra space at the bottom to prevent overflow
                        SizedBox(height: isMobile ? 32 : 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 14,
                        ),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 14,
                        ),
                      ),
                      child: Text(
                        'SAVE ITEM',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
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

  Widget _buildAccountSelector(
      List<ChartOfAccount> budgetAllowedAccounts,
      bool isMobile,
      double screenHeight,
      ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Account *',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ChartOfAccount>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 14,
            ),
            prefixIcon: const Icon(Icons.account_balance),
            suffixIcon: budgetAllowedAccounts.isEmpty
                ? IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
              },
              tooltip: 'Refresh accounts',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isMobile ? 40 : 48,
                minHeight: isMobile ? 40 : 48,
              ),
            )
                : null,
          ),
          value: _selectedAccount,
          items: [
            DropdownMenuItem<ChartOfAccount>(
              value: null,
              child: Text(
                'Select Account',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
            ...budgetAllowedAccounts.map((account) {
              return DropdownMenuItem<ChartOfAccount>(
                value: account,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.accountName,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${account.accountCode} - ${_getAccountTypeDisplay(account.accountType)}',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: theme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
          validator: (value) {
            if (value == null) {
              return 'Please select an account';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedAccount = value;
            });
          },
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: theme.colorScheme.surface,
          menuMaxHeight: screenHeight * 0.5, // Limit dropdown height
          borderRadius: BorderRadius.circular(8),
        ),
        if (budgetAllowedAccounts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No budget-allowed accounts found. Please refresh or contact administrator.',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (_selectedAccount != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selected Account Details:',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedAccount!.accountCode} - ${_selectedAccount!.accountName}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedAccount!.accountCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Category: ${_formatCategoryName(_selectedAccount!.accountCategory.name)}',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getAccountTypeDisplay(AccountType accountType) {
    return accountType.toString().split('.').last.replaceAll('_', ' ');
  }

  String _formatCategoryName(String categoryName) {
    return categoryName.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an account'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final item = BudgetItem(
      id: widget.item?.id,
      account: _selectedAccount!.id,
      accountCode: _selectedAccount!.accountCode,
      accountName: _selectedAccount!.accountName,
      accountType: _selectedAccount!.accountType.name,
      accountCategory: _selectedAccount!.accountCategory.name,
      budgetAmount: double.parse(_budgetAmountController.text),
      costCenter: _costCenterController.text.isEmpty ? null : _costCenterController.text,
      projectCode: _projectCodeController.text.isEmpty ? null : _projectCodeController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (widget.onSave != null) {
      widget.onSave!(item);
    }

    Navigator.pop(context, item);
  }

  @override
  void dispose() {
    _budgetAmountController.dispose();
    _costCenterController.dispose();
    _projectCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}