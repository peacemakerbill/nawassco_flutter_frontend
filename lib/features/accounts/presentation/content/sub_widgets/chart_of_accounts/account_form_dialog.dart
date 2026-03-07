import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class AccountFormDialog extends ConsumerStatefulWidget {
  final ChartOfAccount? account;

  const AccountFormDialog({super.key, this.account});

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isBankAccount = false;
  bool _isLoading = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  List<ChartOfAccount> _parentAccounts = [];
  bool _isLoadingParentAccounts = false;
  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _formData.addAll(widget.account!.toJson());
      _isBankAccount = widget.account!.isBankAccount;
      _selectedLevel = widget.account!.level;
    } else {
      _formData['isActive'] = true;
      _formData['budgetAllowed'] = true;
      _formData['taxApplicable'] = false;
      _formData['isBankAccount'] = false;
      _formData['level'] = 1;
    }

    // Load parent accounts if needed
    _loadParentAccounts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadParentAccounts() async {
    try {
      setState(() => _isLoadingParentAccounts = true);
      final state = ref.read(chartOfAccountsProvider);

      // Use existing accounts or fetch if needed
      if (state.accounts.isEmpty) {
        await ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
        final updatedState = ref.read(chartOfAccountsProvider);
        _parentAccounts = updatedState.accounts;
      } else {
        _parentAccounts = state.accounts;
      }

      // Remove the current account from parent options if editing
      if (widget.account != null) {
        _parentAccounts = _parentAccounts
            .where((account) => account.id != widget.account!.id)
            .toList();
      }

      setState(() => _isLoadingParentAccounts = false);
    } catch (e) {
      setState(() {
        _isLoadingParentAccounts = false;
        _errorMessage = 'Failed to load parent accounts: ${e.toString()}';
      });
    }
  }

  void _updateLevelBasedOnParent(String? parentAccountId) {
    if (parentAccountId == null) {
      setState(() {
        _selectedLevel = 1;
        _formData['level'] = 1;
      });
      return;
    }

    final parentAccount = _parentAccounts.firstWhere(
          (account) => account.id == parentAccountId,
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

    setState(() {
      _selectedLevel = parentAccount.level + 1;
      _formData['level'] = _selectedLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isVerySmallScreen = MediaQuery.of(context).size.width < 400;

    return Dialog(
      insetPadding: EdgeInsets.all(isSmallScreen ? 12 : 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isSmallScreen ? 0.98 : 0.9),
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.account == null ? Icons.add_circle_outline : Icons.edit_outlined,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.account == null ? 'Create New Account' : 'Edit Account',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_errorMessage),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red[100]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
                          onPressed: () => setState(() => _errorMessage = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildSectionHeader(
                          'Basic Information',
                          icon: Icons.info_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildBasicInfoFields(isSmallScreen, isVerySmallScreen),

                        const SizedBox(height: 24),

                        // Hierarchy Section
                        _buildSectionHeader(
                          'Account Hierarchy',
                          icon: Icons.account_tree_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildHierarchyFields(isSmallScreen, isVerySmallScreen),

                        const SizedBox(height: 24),

                        // Financial Settings Section
                        _buildSectionHeader(
                          'Financial Settings',
                          icon: Icons.settings_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildFinancialSettings(isSmallScreen, isVerySmallScreen),

                        const SizedBox(height: 24),

                        // Banking Information (Conditional)
                        if (_isBankAccount) ...[
                          _buildSectionHeader(
                            'Banking Information',
                            icon: Icons.account_balance_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildBankingInfoFields(isSmallScreen, isVerySmallScreen),
                          const SizedBox(height: 24),
                        ],

                        // Tax & Budget Section
                        _buildSectionHeader(
                          'Tax & Budget Settings',
                          icon: Icons.pie_chart_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTaxBudgetSettings(isSmallScreen, isVerySmallScreen),

                        // Add extra space for scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          shadowColor: theme.primaryColor.withValues(alpha: 0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.account == null ? Icons.add : Icons.check_circle,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.account == null ? 'Create Account' : 'Update Account',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blueGrey[600],
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey[800],
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields(bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField('Account Code', 'accountCode', required: true),
          const SizedBox(height: 16),
          _buildTextField('Account Name', 'accountName', required: true),
          const SizedBox(height: 16),
          _buildAccountTypeDropdown(),
          const SizedBox(height: 16),
          _buildAccountCategoryDropdown(),
        ],
      );
    }

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Flexible(
                child: _buildTextField('Account Code', 'accountCode', required: true),
              ),
              Flexible(
                child: _buildTextField('Account Name', 'accountName', required: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Flexible(
                child: _buildAccountTypeDropdown(),
              ),
              Flexible(
                child: _buildAccountCategoryDropdown(),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildTextField('Account Code', 'accountCode', required: true),
              const SizedBox(height: 16),
              _buildAccountTypeDropdown(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildTextField('Account Name', 'accountName', required: true),
              const SizedBox(height: 16),
              _buildAccountCategoryDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHierarchyFields(bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildParentAccountDropdown(),
          const SizedBox(height: 16),
          _buildLevelIndicator(),
        ],
      );
    }

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildParentAccountDropdown(),
          const SizedBox(height: 16),
          _buildLevelIndicator(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildParentAccountDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLevelIndicator(),
        ),
      ],
    );
  }

  Widget _buildParentAccountDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parent Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: _isLoadingParentAccounts
              ? Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
              ),
            ),
          )
              : DropdownButtonFormField<String?>(
            decoration: InputDecoration(
              hintText: 'Select parent account (optional)',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            value: _formData['parentAccount'] ?? _formData['parentAccountId'],
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No parent (Top level)'),
              ),
              ..._parentAccounts.map((account) {
                return DropdownMenuItem<String?>(
                  value: account.id,
                  child: Text(
                    '${account.accountCode} - ${account.accountName} (L${account.level})',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _formData['parentAccount'] = value;
                _updateLevelBasedOnParent(value);
              });
            },
            icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
            isExpanded: true,
            validator: null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Leave empty for top-level accounts',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers_outlined,
                color: Colors.blueGrey[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Level',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _getLevelColor(_selectedLevel),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'LEVEL $_selectedLevel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLevelDescription(_selectedLevel),
            style: TextStyle(
              color: Colors.blueGrey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Top-level account';
      case 2:
        return 'Sub-account of a main account';
      case 3:
        return 'Detail account under sub-account';
      case 4:
        return 'Detailed transaction level';
      case 5:
        return 'Most detailed level';
      default:
        return 'Nested account level $level';
    }
  }

  Widget _buildTextField(String label, String field, {bool required = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      initialValue: _formData[field]?.toString(),
      onSaved: (value) => _formData[field] = value?.trim(),
      validator: required
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      }
          : null,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildAccountTypeDropdown() {
    return DropdownButtonFormField<AccountType>(
      decoration: InputDecoration(
        labelText: 'Account Type *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      value: _formData['accountType'] != null
          ? AccountType.values.firstWhere(
            (e) => e.name == _formData['accountType'],
        orElse: () => AccountType.asset,
      )
          : null,
      items: AccountType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            _formatAccountType(type),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formData['accountType'] = value?.name;
        });
      },
      validator: (value) => value == null ? 'Account Type is required' : null,
      icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
      isExpanded: true,
    );
  }

  Widget _buildAccountCategoryDropdown() {
    return DropdownButtonFormField<AccountCategory>(
      decoration: InputDecoration(
        labelText: 'Account Category *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      value: _formData['accountCategory'] != null
          ? AccountCategory.values.firstWhere(
            (e) => e.name == _formData['accountCategory'],
        orElse: () => AccountCategory.current_assets,
      )
          : null,
      items: AccountCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            _formatAccountCategory(category),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formData['accountCategory'] = value?.name;
        });
      },
      validator: (value) => value == null ? 'Account Category is required' : null,
      icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
      isExpanded: true,
    );
  }

  Widget _buildFinancialSettings(bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNormalBalanceDropdown(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildBankAccountToggle(),
        ],
      );
    }

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNormalBalanceDropdown(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildBankAccountToggle(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildNormalBalanceDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildDescriptionField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBankAccountToggle(),
        ),
      ],
    );
  }

  Widget _buildNormalBalanceDropdown() {
    return DropdownButtonFormField<NormalBalance>(
      decoration: InputDecoration(
        labelText: 'Normal Balance *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      value: _formData['normalBalance'] != null
          ? NormalBalance.values.firstWhere(
            (e) => e.name == _formData['normalBalance'],
        orElse: () => NormalBalance.debit,
      )
          : null,
      items: NormalBalance.values.map((balance) {
        return DropdownMenuItem(
          value: balance,
          child: Text(
            _formatNormalBalance(balance),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formData['normalBalance'] = value?.name;
        });
      },
      validator: (value) => value == null ? 'Normal Balance is required' : null,
      icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
      isExpanded: true,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      minLines: 3,
      initialValue: _formData['description']?.toString(),
      onSaved: (value) => _formData['description'] = value?.trim(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description is required';
        }
        return null;
      },
    );
  }

  Widget _buildBankAccountToggle() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.blueGrey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enable for bank accounts',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isBankAccount,
              onChanged: (value) {
                setState(() {
                  _isBankAccount = value;
                  _formData['isBankAccount'] = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
    );
  }

  Widget _buildBankingInfoFields(bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField('Bank Account Number', 'bankAccountNumber'),
          const SizedBox(height: 16),
          _buildTextField('Bank Name', 'bankName'),
        ],
      );
    }

    if (isSmallScreen) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          Flexible(
            child: _buildTextField('Bank Account Number', 'bankAccountNumber'),
          ),
          Flexible(
            child: _buildTextField('Bank Name', 'bankName'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildTextField('Bank Account Number', 'bankAccountNumber'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField('Bank Name', 'bankName'),
        ),
      ],
    );
  }

  Widget _buildTaxBudgetSettings(bool isSmallScreen, bool isVerySmallScreen) {
    final settings = [
      _buildSettingSwitch(
        title: 'Tax Applicable',
        value: _formData['taxApplicable'] ?? false,
        icon: Icons.percent_outlined,
        onChanged: (value) => setState(() => _formData['taxApplicable'] = value),
      ),
      if (_formData['taxApplicable'] == true)
        SizedBox(
          width: isVerySmallScreen ? double.infinity : 200,
          child: _buildTextField('Tax Rate (%)', 'taxRate'),
        ),
      _buildSettingSwitch(
        title: 'Budget Allowed',
        value: _formData['budgetAllowed'] ?? true,
        icon: Icons.pie_chart_outline,
        onChanged: (value) => setState(() => _formData['budgetAllowed'] = value),
      ),
      _buildSettingSwitch(
        title: 'Requires Approval',
        value: _formData['requiresApproval'] ?? false,
        icon: Icons.verified_outlined,
        onChanged: (value) => setState(() => _formData['requiresApproval'] = value),
      ),
      if (_formData['requiresApproval'] == true)
        SizedBox(
          width: isVerySmallScreen ? double.infinity : 200,
          child: _buildTextField('Approval Limit (KES)', 'approvalLimit'),
        ),
      _buildSettingSwitch(
        title: 'Active Account',
        value: _formData['isActive'] ?? true,
        icon: Icons.toggle_on_outlined,
        onChanged: (value) => setState(() => _formData['isActive'] = value),
      ),
    ].where((element) => element != null).toList();

    if (isVerySmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: settings,
      );
    }

    if (isSmallScreen) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: settings
            .map((setting) => Flexible(
          child: setting,
        ))
            .toList(),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: settings,
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blueGrey[600],
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontSize: 14,
              ),
              maxLines: 2,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _formatAccountType(AccountType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  String _formatAccountCategory(AccountCategory category) {
    return category.name.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatNormalBalance(NormalBalance balance) {
    return balance.name[0].toUpperCase() + balance.name.substring(1);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final notifier = ref.read(chartOfAccountsProvider.notifier);

        // Prepare the account data
        final accountData = {
          'accountCode': _formData['accountCode'],
          'accountName': _formData['accountName'],
          'accountType': _formData['accountType'],
          'accountCategory': _formData['accountCategory'],
          'description': _formData['description'],
          'normalBalance': _formData['normalBalance'],
          'isSystemAccount': false,
          'isActive': _formData['isActive'] ?? true,
          'budgetAllowed': _formData['budgetAllowed'] ?? true,
          'requiresApproval': _formData['requiresApproval'] ?? false,
          'approvalLimit': _formData['approvalLimit'],
          'taxApplicable': _formData['taxApplicable'] ?? false,
          'taxRate': _formData['taxRate'],
          'isBankAccount': _formData['isBankAccount'] ?? false,
          'bankAccountNumber': _formData['bankAccountNumber'],
          'bankName': _formData['bankName'],
          'level': _formData['level'] ?? 1,
        };

        // Add parent account if selected
        if (_formData['parentAccount'] != null && _formData['parentAccount'].toString().isNotEmpty) {
          accountData['parentAccount'] = _formData['parentAccount'];
        }

        // Remove null values
        accountData.removeWhere((key, value) => value == null);

        bool success;
        if (widget.account == null) {
          // Create new account
          success = await notifier.createAccount(ChartOfAccount.fromJson(accountData));
        } else {
          // Update existing account
          success = await notifier.updateAccount(widget.account!.id, ChartOfAccount.fromJson({
            ...widget.account!.toJson(),
            ...accountData,
          }));
        }

        setState(() => _isLoading = false);

        if (success) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.account == null ? 'Account created successfully' : 'Account updated successfully',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          final error = ref.read(chartOfAccountsProvider).error;
          setState(() {
            _errorMessage = error ?? 'Operation failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString().replaceAll('Exception:', '').trim()}';
        });
      }
    }
  }
}