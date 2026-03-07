import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/chart_of_accounts_provider.dart';
import 'sub_widgets/budget/budget_details_widget.dart';
import 'sub_widgets/budget/budget_form_widget.dart';
import 'sub_widgets/budget/budget_list_widget.dart';
import 'sub_widgets/budget/budget_performance_widget.dart';

class BudgetContent extends StatefulWidget {
  const BudgetContent({super.key});

  @override
  State<BudgetContent> createState() => _BudgetContentState();
}

class _BudgetContentState extends State<BudgetContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialize both budget and chart of accounts data
    final context = this.context;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ref = ProviderScope.containerOf(context);
      // Fetch budgets
      await ref.read(budgetProvider.notifier).fetchBudgets();
      // Fetch chart of accounts (including bank accounts)
      await ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
      await ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(budgetProvider);
        final chartOfAccountsState = ref.watch(chartOfAccountsProvider);
        final hasSelectedBudget = state.selectedBudget != null;

        // Check if we have bank accounts loaded
        final hasBankAccounts = chartOfAccountsState.bankAccounts.isNotEmpty;
        final hasBudgetAllowedAccounts = chartOfAccountsState.accounts
            .any((account) => account.budgetAllowed && account.isActive);

        return Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.9),
              ],
            )
                : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.background,
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with Tabs
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Top Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primaryContainer,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      theme.colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: theme.colorScheme.onPrimary,
                                  size: isMobile ? 24 : 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Budget Management',
                                      style: TextStyle(
                                        fontSize: isMobile ? 20 : 24,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Create, manage, and track budgets',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    // Show loading status for accounts
                                    if (!_isInitialized ||
                                        (!hasBankAccounts && _currentTabIndex == 0))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info,
                                              size: 12,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              !_isInitialized
                                                  ? 'Loading accounts...'
                                                  : 'No bank accounts found',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!isMobile && _currentTabIndex == 0 && !hasSelectedBudget)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.primaryContainer,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showBudgetForm(context, null);
                                    },
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('Create Budget'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              if (hasSelectedBudget)
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surfaceVariant,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: theme.colorScheme.onSurface,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(budgetProvider.notifier)
                                        .clearSelectedBudget();
                                  },
                                  tooltip: 'Back to List',
                                ),
                            ],
                          ),
                          if (isMobile && _currentTabIndex == 0 && !hasSelectedBudget)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showBudgetForm(context, null);
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Create Budget'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Tabs
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: isMobile,
                        labelColor: theme.colorScheme.onPrimary,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        padding: const EdgeInsets.all(4),
                        tabs: [
                          Tab(
                            icon: Icon(Icons.list_alt, size: isMobile ? 16 : 18),
                            text: 'All Budgets',
                          ),
                          Tab(
                            icon: Icon(Icons.analytics, size: isMobile ? 16 : 18),
                            text: 'Performance',
                          ),
                          Tab(
                            icon: Icon(Icons.description, size: isMobile ? 16 : 18),
                            text: 'Details',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Error Message
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: theme.colorScheme.errorContainer,
                  child: Row(
                    children: [
                      Icon(Icons.error, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.error, size: 20),
                        onPressed: () {
                          ref.read(budgetProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: _isInitialized
                    ? TabBarView(
                  controller: _tabController,
                  children: [
                    // All Budgets Tab
                    const BudgetListWidget(),

                    // Performance Tab
                    const BudgetPerformanceWidget(),

                    // Budget Details Tab
                    state.selectedBudget != null
                        ? BudgetDetailsWidget(budget: state.selectedBudget!)
                        : _buildEmptyDetailsState(theme, isMobile),
                  ],
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading budget data...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyDetailsState(ThemeData theme, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 80 : 120,
              height: isMobile ? 80 : 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                size: isMobile ? 40 : 60,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Budget Selected',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a budget from the list to view detailed information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.list, size: 20),
              label: const Text('View All Budgets'),
              style: ElevatedButton.styleFrom(
                padding:
                EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetForm(BuildContext context, Budget? budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BudgetFormWidget(budget: budget),
    );
  }
}