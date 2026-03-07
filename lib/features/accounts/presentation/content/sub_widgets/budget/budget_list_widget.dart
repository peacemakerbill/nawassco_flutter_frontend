import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/budget_model.dart';
import '../../../../providers/budget_provider.dart';
import 'budget_form_widget.dart';

class BudgetListWidget extends ConsumerStatefulWidget {
  const BudgetListWidget({super.key});

  @override
  ConsumerState<BudgetListWidget> createState() => _BudgetListWidgetState();
}

class _BudgetListWidgetState extends ConsumerState<BudgetListWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).fetchBudgets();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(budgetProvider);
    if (!state.isLoading && state.currentPage < state.totalPages) {
      ref.read(budgetProvider.notifier).fetchBudgets(
        page: state.currentPage + 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        fiscalYear: state.fiscalYearFilter,
        periodType: state.periodTypeFilter,
        status: state.statusFilter,
      );
    }
  }

  void _onSearchChanged() {
    if (_searchController.text != ref.read(budgetProvider).searchQuery) {
      ref.read(budgetProvider.notifier).updateFilters(
        searchQuery: _searchController.text,
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;
    final isVerySmallMobile = screenWidth < 350;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(state, isMobile, isSmallMobile, isVerySmallMobile),
          const SizedBox(height: 16),

          // Budget List
          Expanded(
            child: state.isLoading && state.budgets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.budgets.isEmpty
                ? _buildEmptyState(isMobile)
                : _buildBudgetList(state, isMobile, isVerySmallMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BudgetState state, bool isMobile, bool isSmallMobile, bool isVerySmallMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(state, isMobile),
            const SizedBox(height: 12),

            // Filters
            _buildFilters(state, isMobile, isSmallMobile, isVerySmallMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BudgetState state, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search budgets...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 14,
              ),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
            },
            onSubmitted: (value) {
              ref.read(budgetProvider.notifier).updateFilters(
                searchQuery: value,
              );
            },
          ),
        ),
        if (!isMobile) const SizedBox(width: 12),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: () {
              _showCreateBudgetForm();
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              minimumSize: Size.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(BudgetState state, bool isMobile, bool isSmallMobile, bool isVerySmallMobile) {
    if (isVerySmallMobile) {
      return Column(
        children: [
          _buildFiscalYearDropdown(state, isMobile),
          const SizedBox(height: 8),
          _buildPeriodTypeDropdown(state, isMobile),
          const SizedBox(height: 8),
          _buildStatusDropdown(state, isMobile),
          const SizedBox(height: 8),
          if (isMobile)
            ElevatedButton.icon(
              onPressed: () {
                _showCreateBudgetForm();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      );
    } else if (isSmallMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFiscalYearDropdown(state, isMobile)),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodTypeDropdown(state, isMobile)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatusDropdown(state, isMobile)),
              if (isMobile) const SizedBox(width: 8),
              if (isMobile)
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreateBudgetForm();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildFiscalYearDropdown(state, isMobile)),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodTypeDropdown(state, isMobile)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatusDropdown(state, isMobile)),
          if (isMobile) const SizedBox(width: 8),
          if (isMobile)
            ElevatedButton.icon(
              onPressed: () {
                _showCreateBudgetForm();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                minimumSize: Size.zero,
              ),
            ),
        ],
      );
    }
  }

  Widget _buildFiscalYearDropdown(BudgetState state, bool isMobile) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => (currentYear - 2 + index).toString());

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Fiscal Year',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
      value: state.fiscalYearFilter,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Years')),
        ...years.map((year) => DropdownMenuItem(
          value: year,
          child: Text(year),
        )),
      ],
      onChanged: (value) {
        ref.read(budgetProvider.notifier).updateFilters(fiscalYear: value);
      },
      isExpanded: true,
    );
  }

  Widget _buildPeriodTypeDropdown(BudgetState state, bool isMobile) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Period Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
      value: state.periodTypeFilter,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Periods')),
        ...PeriodType.values.map((type) => DropdownMenuItem(
          value: type.name,
          child: Text(_getPeriodTypeLabel(type)),
        )),
      ],
      onChanged: (value) {
        ref.read(budgetProvider.notifier).updateFilters(periodType: value);
      },
      isExpanded: true,
    );
  }

  Widget _buildStatusDropdown(BudgetState state, bool isMobile) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
      value: state.statusFilter,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Status')),
        ...BudgetStatus.values.map((status) => DropdownMenuItem(
          value: status.name,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _getStatusLabel(status),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
      ],
      onChanged: (value) {
        ref.read(budgetProvider.notifier).updateFilters(status: value);
      },
      isExpanded: true,
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: isMobile ? 60 : 80,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'No budgets found',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
              child: Text(
                _searchController.text.isNotEmpty
                    ? 'Try adjusting your search or filters'
                    : 'Create your first budget to get started',
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            ElevatedButton.icon(
              onPressed: () {
                _showCreateBudgetForm();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList(BudgetState state, bool isMobile, bool isVerySmallMobile) {
    return Column(
      children: [
        // Summary Stats
        if (!isMobile) _buildSummaryStats(state),
        if (!isMobile) const SizedBox(height: 16),

        // Budget List
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                if (!isMobile) _buildListHeader(),
                if (isMobile) _buildMobileListHeader(state),

                // List
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          _scrollController.position.extentAfter == 0) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.budgets.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.budgets.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final budget = state.budgets[index];
                        return isMobile
                            ? _buildMobileBudgetListItem(budget, isVerySmallMobile)
                            : _buildDesktopBudgetListItem(budget);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(BudgetState state) {
    final totalBudgets = state.budgets.length;
    final totalAmount =
    state.budgets.fold(0.0, (sum, budget) => sum + budget.totalBudget);
    final totalSpent =
    state.budgets.fold(0.0, (sum, budget) => sum + budget.actualSpent);
    final utilization = totalAmount > 0 ? (totalSpent / totalAmount) * 100 : 0;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildSummaryCard(
          'Total Budgets',
          totalBudgets.toString(),
          Icons.list_alt,
          Theme.of(context).colorScheme.primary,
        ),
        _buildSummaryCard(
          'Total Amount',
          'KES ${totalAmount.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Spent',
          'KES ${totalSpent.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Utilization',
          '${utilization.toStringAsFixed(1)}%',
          Icons.pie_chart,
          utilization > 80 ? Colors.red : Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('Budget Name',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: Text('Fiscal Year',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: Text('Period',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: Text('Amount',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: Text('Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          SizedBox(width: 80), // Actions column
        ],
      ),
    );
  }

  Widget _buildMobileListHeader(BudgetState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Budget List',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.budgets.length} items',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBudgetListItem(Budget budget) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(budgetProvider.notifier).fetchBudgetById(budget.id!);
          },
          hoverColor: Theme.of(context).hoverColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.budgetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.budgetNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    budget.fiscalYear,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    _getPeriodTypeLabel(budget.periodType),
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    'KES ${budget.totalBudget.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: budget.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      budget.statusLabel,
                      style: TextStyle(
                        color: budget.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {
                          ref
                              .read(budgetProvider.notifier)
                              .fetchBudgetById(budget.id!);
                        },
                        tooltip: 'View Details',
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) => _handleMenuAction(value, budget),
                        itemBuilder: (context) => _buildPopupMenuItems(budget),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBudgetListItem(Budget budget, bool isVerySmallMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(budgetProvider.notifier).fetchBudgetById(budget.id!);
          },
          child: Padding(
            padding: EdgeInsets.all(isVerySmallMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        budget.budgetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: budget.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        budget.statusLabel,
                        style: TextStyle(
                          color: budget.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  budget.budgetNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (isVerySmallMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMobileInfoRow('Fiscal Year', budget.fiscalYear),
                      const SizedBox(height: 8),
                      _buildMobileInfoRow('Period', _getPeriodTypeLabel(budget.periodType)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fiscal Year',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              budget.fiscalYear,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Period',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPeriodTypeLabel(budget.periodType),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'KES ${budget.totalBudget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          onPressed: () {
                            ref
                                .read(budgetProvider.notifier)
                                .fetchBudgetById(budget.id!);
                          },
                          tooltip: 'View Details',
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) => _handleMenuAction(value, budget),
                          itemBuilder: (context) => _buildPopupMenuItems(budget),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(Budget budget) {
    final items = <PopupMenuEntry<String>>[];

    if (budget.status == BudgetStatus.draft) {
      items.add(const PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ));
    }

    if (budget.status == BudgetStatus.draft) {
      items.add(const PopupMenuItem<String>(
        value: 'submit',
        child: Row(
          children: [
            Icon(Icons.send, size: 18),
            SizedBox(width: 8),
            Text('Submit for Review'),
          ],
        ),
      ));
    }

    if (budget.status == BudgetStatus.under_review) {
      items.add(const PopupMenuItem<String>(
        value: 'approve',
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 18),
            SizedBox(width: 8),
            Text('Approve'),
          ],
        ),
      ));
    }

    if (budget.status == BudgetStatus.approved) {
      items.add(const PopupMenuItem<String>(
        value: 'close',
        child: Row(
          children: [
            Icon(Icons.lock, size: 18),
            SizedBox(width: 8),
            Text('Close'),
          ],
        ),
      ));
    }

    if (items.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }

    if (budget.status == BudgetStatus.draft) {
      items.add(const PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ));
    }

    return items;
  }

  void _handleMenuAction(String action, Budget budget) {
    switch (action) {
      case 'edit':
        _showEditBudgetForm(budget);
        break;
      case 'submit':
        _submitBudget(budget);
        break;
      case 'approve':
        _approveBudget(budget);
        break;
      case 'close':
        _closeBudget(budget);
        break;
      case 'delete':
        _deleteBudget(budget);
        break;
    }
  }

  void _showCreateBudgetForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BudgetFormWidget(),
    );
  }

  void _showEditBudgetForm(Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetFormWidget(budget: budget),
    );
  }

  void _submitBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Budget for Review'),
        content: const Text(
            'Are you sure you want to submit this budget for review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(budgetProvider.notifier)
                  .submitBudget(budget.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget submitted for review successfully'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _approveBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Budget'),
        content: const Text('Are you sure you want to approve this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(budgetProvider.notifier)
                  .approveBudget(budget.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget approved successfully'),
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _closeBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Budget'),
        content: const Text('Are you sure you want to close this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(budgetProvider.notifier)
                  .closeBudget(budget.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget closed successfully'),
                  ),
                );
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
            'Are you sure you want to delete this budget? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality to be implemented'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getPeriodTypeLabel(PeriodType type) {
    switch (type) {
      case PeriodType.annual:
        return 'Annual';
      case PeriodType.quarterly:
        return 'Quarterly';
      case PeriodType.monthly:
        return 'Monthly';
    }
  }

  String _getStatusLabel(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.draft:
        return 'Draft';
      case BudgetStatus.under_review:
        return 'Under Review';
      case BudgetStatus.approved:
        return 'Approved';
      case BudgetStatus.rejected:
        return 'Rejected';
      case BudgetStatus.closed:
        return 'Closed';
    }
  }

  Color _getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.draft:
        return Colors.blue;
      case BudgetStatus.under_review:
        return Colors.orange;
      case BudgetStatus.approved:
        return Colors.green;
      case BudgetStatus.rejected:
        return Colors.red;
      case BudgetStatus.closed:
        return Colors.grey;
    }
  }
}