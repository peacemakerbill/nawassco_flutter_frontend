import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chart_of_accounts_provider.dart';
import 'sub_widgets/chart_of_accounts/account_analytics_widget.dart';
import 'sub_widgets/chart_of_accounts/account_form_dialog.dart';
import 'sub_widgets/chart_of_accounts/account_hierarchy_widget.dart';
import 'sub_widgets/chart_of_accounts/accounts_list_widget.dart';
import 'sub_widgets/chart_of_accounts/bank_accounts_widget.dart';

class ChartOfAccountsContent extends ConsumerStatefulWidget {
  const ChartOfAccountsContent({super.key});

  @override
  ConsumerState<ChartOfAccountsContent> createState() =>
      _ChartOfAccountsContentState();
}

class _ChartOfAccountsContentState extends ConsumerState<ChartOfAccountsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialLoad = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Use a small delay to ensure widget is mounted
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(chartOfAccountsProvider.notifier);

    // Load accounts first (most important)
    await notifier.fetchAccounts();

    // Load other data sequentially to avoid freezing
    await Future.delayed(const Duration(milliseconds: 100));
    await notifier.fetchAccountHierarchy();

    await Future.delayed(const Duration(milliseconds: 100));
    await notifier.fetchBankAccounts();

    if (mounted) {
      setState(() {
        _isInitialLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      // Added Scaffold for better structure
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // SafeArea prevents overflow on notch devices
        child: Column(
          children: [
            // Header with Tabs - Now with flexible height
            Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 120 : 100, // Flexible height
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // Make header scrollable on small screens
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 20,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            children: [
                              Icon(Icons.account_balance,
                                  color: theme.primaryColor,
                                  size: isSmallScreen ? 24 : 28),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Expanded(
                                child: Text(
                                  'Chart of Accounts',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    fontSize: isSmallScreen ? 20 : 24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 12),

                          // Quick Actions - Responsive layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isVerySmall = constraints.maxWidth < 400;

                              return Wrap(
                                spacing: isVerySmall ? 6 : 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: _buildResponsiveQuickActions(isVerySmall),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Tabs - Scrollable on small screens
                    SizedBox(
                      height: isSmallScreen ? 48 : null,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: theme.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: theme.primaryColor,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        tabs: const [
                          Tab(text: 'All Accounts'),
                          Tab(text: 'Hierarchy'),
                          Tab(text: 'Bank Accounts'),
                          Tab(text: 'Analytics'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Content - Now with flexible, scrollable container
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    AccountsListWidget(),
                    AccountHierarchyWidget(),
                    BankAccountsWidget(),
                    AccountAnalyticsWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResponsiveQuickActions(bool isVerySmall) {
    final state = ref.watch(chartOfAccountsProvider);

    if (isVerySmall) {
      // Icon-only buttons for very small screens
      return [
        IconButton(
          onPressed: () => _showCreateAccountDialog(),
          icon: const Icon(Icons.add, size: 20),
          tooltip: 'New Account',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
        ),
        IconButton(
          onPressed: state.isLoading ? null : () => _refreshAllData(),
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ];
    }

    // Full buttons for larger screens
    return [
      ElevatedButton.icon(
        onPressed: () => _showCreateAccountDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Account'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40), // Fixed height for consistency
        ),
      ),
      OutlinedButton.icon(
        onPressed: state.isLoading ? null : () => _refreshAllData(),
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Refresh'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40), // Fixed height for consistency
        ),
      ),
    ];
  }

  Future<void> _refreshAllData() async {
    final notifier = ref.read(chartOfAccountsProvider.notifier);
    await notifier.fetchAccounts();
    await Future.delayed(const Duration(milliseconds: 50));
    await notifier.fetchAccountHierarchy();
    await Future.delayed(const Duration(milliseconds: 50));
    await notifier.fetchBankAccounts();
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const AccountFormDialog(),
    );
  }
}