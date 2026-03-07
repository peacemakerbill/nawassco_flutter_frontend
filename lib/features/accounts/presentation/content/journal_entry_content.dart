import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chart_of_accounts_provider.dart';
import '../../providers/journal_entry_provider.dart';
import 'sub_widgets/journal_entries/journal_entry_form_widget.dart';
import 'sub_widgets/journal_entries/journal_entry_list_widget.dart';
import 'sub_widgets/journal_entries/trial_balance_widget.dart';

class JournalEntryContent extends ConsumerStatefulWidget {
  const JournalEntryContent({super.key});

  @override
  ConsumerState<JournalEntryContent> createState() =>
      _JournalEntryContentState();
}

class _JournalEntryContentState extends ConsumerState<JournalEntryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load chart of accounts when content is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChartOfAccounts();
    });
  }

  void _loadChartOfAccounts() {
    ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          _buildHeader(),
          // Tab Bar
          _buildTabBar(),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                JournalEntryListWidget(),
                TrialBalanceWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.book, color: Color(0xFF0D47A1), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Journal Entries',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Manage accounting journal entries and trial balance',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final accountsState = ref.watch(chartOfAccountsProvider);
              return FilledButton.icon(
                onPressed: accountsState.isLoading
                    ? null // Disable button while loading
                    : () {
                  _showCreateJournalEntryDialog(ref);
                },
                icon: accountsState.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.add, size: 20),
                label: accountsState.isLoading
                    ? const Text('Loading...')
                    : const Text('New Entry'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF0D47A1),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF0D47A1),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        tabs: const [
          Tab(
            icon: Icon(Icons.list_alt, size: 20),
            text: 'Journal Entries',
          ),
          Tab(
            icon: Icon(Icons.balance, size: 20),
            text: 'Trial Balance',
          ),
        ],
      ),
    );
  }

  void _showCreateJournalEntryDialog(WidgetRef ref) {
    final accountsState = ref.read(chartOfAccountsProvider);

    // Show loading dialog if accounts are still loading
    if (accountsState.isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Loading Accounts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Please wait while we load chart of accounts...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Show error dialog if accounts failed to load
    if (accountsState.error != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(
            'Failed to load chart of accounts: ${accountsState.error}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadChartOfAccounts();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
      return;
    }

    // Show warning if no accounts available
    if (accountsState.accounts.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Accounts Available'),
          content: const Text(
            'Please create chart of accounts first before creating journal entries.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show the actual journal entry form
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: JournalEntryFormWidget(
            onSaved: () {
              Navigator.of(context).pop();
              ref.read(journalEntryProvider.notifier).fetchJournalEntries();
            },
          ),
        ),
      ),
    );
  }
}