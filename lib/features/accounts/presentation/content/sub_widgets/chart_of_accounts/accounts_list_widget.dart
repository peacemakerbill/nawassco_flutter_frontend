import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';
import 'account_form_dialog.dart';
import 'account_details_dialog.dart';

class AccountsListWidget extends ConsumerStatefulWidget {
  const AccountsListWidget({super.key});

  @override
  ConsumerState<AccountsListWidget> createState() => _AccountsListWidgetState();
}

class _AccountsListWidgetState extends ConsumerState<AccountsListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize search controller with current value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(chartOfAccountsProvider);
      _searchController.text = state.searchQuery;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() async {
    final state = ref.read(chartOfAccountsProvider);
    if (!_isLoadingMore && state.currentPage < state.totalPages) {
      setState(() => _isLoadingMore = true);
      await ref.read(chartOfAccountsProvider.notifier).fetchAccounts(
        page: state.currentPage + 1,
      );
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chartOfAccountsProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMediumScreen = MediaQuery.of(context).size.width < 1024;

    // Determine if we should show active filters based on current state
    final hasActiveFilters = state.searchQuery.isNotEmpty ||
        state.accountTypeFilter != null ||
        state.isActiveFilter != null;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with search (stays at top)
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 2,
            title: Text(
              'Chart of Accounts',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildSearchBar(state, isSmallScreen),
            ),
          ),

          // Filters section - Only show if there are active filters
          if (hasActiveFilters)
            SliverToBoxAdapter(
              child: _buildActiveFilters(state),
            ),

          // Quick filters (always visible)
          SliverToBoxAdapter(
            child: _buildQuickFilters(state, isSmallScreen, isMediumScreen),
          ),

          // Accounts list
          _buildAccountsList(state, isSmallScreen, isMediumScreen),

          // Loading indicator for infinite scroll
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // Pagination info (sticky at bottom)
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: _buildPaginationInfo(state),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewAccount(),
        child: const Icon(Icons.add),
        mini: isSmallScreen,
      ),
    );
  }

  Widget _buildSearchBar(ChartOfAccountsState state, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search accounts...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        ref.read(chartOfAccountsProvider.notifier)
                            .updateFilters(searchQuery: value);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(chartOfAccountsProvider.notifier)
                            .updateFilters(searchQuery: '');
                      },
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          if (!isSmallScreen) ...[
            const SizedBox(width: 12),
            _buildFilterButton(state),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton(ChartOfAccountsState state) {
    final hasFilters = state.accountTypeFilter != null || state.isActiveFilter != null;
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: hasFilters ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.filter_list,
          size: 20,
          color: hasFilters ? Colors.white : Colors.grey[600],
        ),
        onPressed: () => _showFilterDialog(state),
      ),
    );
  }

  Widget _buildActiveFilters(ChartOfAccountsState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Only show if search is not empty
              if (state.searchQuery.isNotEmpty)
                _buildActiveFilterChip(
                  label: 'Search: "${state.searchQuery}"',
                  onDelete: () => _clearFilter(type: 'search'),
                ),

              // Only show if account type filter exists
              if (state.accountTypeFilter != null)
                _buildActiveFilterChip(
                  label: 'Type: ${_formatAccountTypeString(state.accountTypeFilter!)}',
                  onDelete: () => _clearFilter(type: 'accountType'),
                ),

              // Only show if status filter exists
              if (state.isActiveFilter != null)
                _buildActiveFilterChip(
                  label: 'Status: ${state.isActiveFilter! ? 'Active' : 'Inactive'}',
                  onDelete: () => _clearFilter(type: 'isActive'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDelete,
  }) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 14),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: StadiumBorder(
        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildQuickFilters(
      ChartOfAccountsState state,
      bool isSmallScreen,
      bool isMediumScreen
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: isSmallScreen
          ? _buildMobileFilters(state)
          : _buildDesktopFilters(state, isMediumScreen),
    );
  }

  Widget _buildMobileFilters(ChartOfAccountsState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAccountTypeFilter(state, true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusFilter(state, true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters(ChartOfAccountsState state, bool isMediumScreen) {
    return Row(
      children: [
        Expanded(
          flex: isMediumScreen ? 3 : 2,
          child: _buildAccountTypeFilter(state, false),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: isMediumScreen ? 2 : 1,
          child: _buildStatusFilter(state, false),
        ),
        const SizedBox(width: 12),
        if (!isMediumScreen)
          Expanded(
            flex: 1,
            child: _buildBankAccountFilter(),
          ),
      ],
    );
  }

  Widget _buildAccountTypeFilter(ChartOfAccountsState state, bool isMobile) {
    return DropdownButtonFormField<String?>(
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: isMobile ? 'Type' : 'Account Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: state.accountTypeFilter,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Types')),
        const DropdownMenuItem(value: 'asset', child: Text('Assets')),
        const DropdownMenuItem(value: 'liability', child: Text('Liabilities')),
        const DropdownMenuItem(value: 'equity', child: Text('Equity')),
        const DropdownMenuItem(value: 'revenue', child: Text('Revenue')),
        const DropdownMenuItem(value: 'expense', child: Text('Expenses')),
      ],
      onChanged: (value) {
        ref.read(chartOfAccountsProvider.notifier).updateFilters(accountType: value);
      },
    );
  }

  Widget _buildStatusFilter(ChartOfAccountsState state, bool isMobile) {
    return DropdownButtonFormField<bool?>(
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: isMobile ? 'Status' : 'Account Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: state.isActiveFilter,
      items: const [
        DropdownMenuItem(value: null, child: Text('All Status')),
        DropdownMenuItem(value: true, child: Text('Active')),
        DropdownMenuItem(value: false, child: Text('Inactive')),
      ],
      onChanged: (value) {
        ref.read(chartOfAccountsProvider.notifier).updateFilters(isActive: value);
      },
    );
  }

  Widget _buildBankAccountFilter() {
    return DropdownButtonFormField<bool?>(
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: 'Bank Account',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: null,
      items: const [
        DropdownMenuItem(value: null, child: Text('All Accounts')),
        DropdownMenuItem(value: true, child: Text('Bank Accounts Only')),
        DropdownMenuItem(value: false, child: Text('Non-Bank Accounts')),
      ],
      onChanged: (value) {
        // You'll need to add bank account filtering to your provider
      },
    );
  }

  Widget _buildAccountsList(
      ChartOfAccountsState state,
      bool isSmallScreen,
      bool isMediumScreen,
      ) {
    if (state.isLoading && state.accounts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading accounts...'),
            ],
          ),
        ),
      );
    }

    if (state.accounts.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(state),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _buildAccountItem(state.accounts[index], isSmallScreen);
        },
        childCount: state.accounts.length,
      ),
    );
  }

  Widget _buildAccountItem(ChartOfAccount account, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () => _showAccountDetails(account),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Account Code (with colored background)
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: _getAccountTypeColor(account.accountType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  account.accountCode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getAccountTypeColor(account.accountType),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.accountName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatAccountType(account.accountType),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Level ${account.level}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: account.isActive ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: account.isActive ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            account.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              color: account.isActive ? Colors.green[700] : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              _buildActionButtons(account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ChartOfAccount account) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 18),
          onPressed: () => _showAccountDetails(account),
          tooltip: 'View Details',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          iconSize: 18,
          color: Colors.grey[600],
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: account.isSystemAccount
              ? null
              : () => _editAccount(account),
          tooltip: 'Edit',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          iconSize: 18,
          color: Colors.grey[600],
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 18),
          onPressed: account.isSystemAccount
              ? null
              : () => _deleteAccount(account),
          tooltip: 'Delete',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          iconSize: 18,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildEmptyState(ChartOfAccountsState state) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Accounts Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const Text(
              'Try adjusting your search filters or create a new account',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
              },
              child: const Text('Reload Accounts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationInfo(ChartOfAccountsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${state.accounts.length} of ${state.totalCount} accounts',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Colors.green;
      case AccountType.liability:
        return Colors.orange;
      case AccountType.equity:
        return Colors.blue;
      case AccountType.revenue:
        return Colors.purple;
      case AccountType.expense:
        return Colors.red;
    }
  }

  String _formatAccountType(AccountType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  String _formatAccountTypeString(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  void _clearFilter({required String type}) {
    final notifier = ref.read(chartOfAccountsProvider.notifier);

    switch (type) {
      case 'search':
        _searchController.clear();
        notifier.updateFilters(searchQuery: '');
        break;
      case 'accountType':
        notifier.updateFilters(accountType: null);
        break;
      case 'isActive':
        notifier.updateFilters(isActive: null);
        break;
    }
  }

  void _clearAllFilters() {
    final notifier = ref.read(chartOfAccountsProvider.notifier);
    _searchController.clear();
    notifier.clearFilters();
  }

  void _showFilterDialog(ChartOfAccountsState state) {
    // Implement filter dialog for mobile
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAccountTypeFilter(state, false),
              const SizedBox(height: 16),
              _buildStatusFilter(state, false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountDetails(ChartOfAccount account) {
    showDialog(
      context: context,
      builder: (context) => AccountDetailsDialog(account: account),
    );
  }

  void _editAccount(ChartOfAccount account) {
    showDialog(
      context: context,
      builder: (context) => AccountFormDialog(account: account),
    );
  }

  void _addNewAccount() {
    showDialog(
      context: context,
      builder: (context) => const AccountFormDialog(),
    );
  }

  void _deleteAccount(ChartOfAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete account ${account.accountCode} - ${account.accountName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(chartOfAccountsProvider.notifier)
          .deleteAccount(account.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account ${account.accountCode} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}