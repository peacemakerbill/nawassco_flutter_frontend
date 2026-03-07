import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bank_reconciliation_provider.dart';
import 'sub_widgets/bank_reconciliation/reconciliation_detail_widget.dart';
import 'sub_widgets/bank_reconciliation/reconciliation_form_widget.dart';
import 'sub_widgets/bank_reconciliation/reconciliation_list_widget.dart';

class BankReconciliationContent extends ConsumerStatefulWidget {
  const BankReconciliationContent({super.key});

  @override
  ConsumerState<BankReconciliationContent> createState() =>
      _BankReconciliationContentState();
}

class _BankReconciliationContentState
    extends ConsumerState<BankReconciliationContent> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final notifier = ref.read(bankReconciliationProvider.notifier);
      // Initialize both bank accounts and reconciliations
      await notifier.fetchBankAccounts();
      await notifier.fetchReconciliations();
    } catch (e) {
      // Handle initialization error gracefully
      print('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final notifier = ref.read(bankReconciliationProvider.notifier);
      await notifier.refresh();
    } catch (e) {
      print('Refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankReconciliationProvider);
    final notifier = ref.read(bankReconciliationProvider.notifier);

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading Bank Reconciliation...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Header
            _buildHeader(context, state, notifier),
            // Content
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
      floatingActionButton: state.selectedReconciliation == null &&
          state.bankAccounts.isNotEmpty
          ? FloatingActionButton(
        onPressed: () {
          notifier.clearSelectedReconciliation();
          _showCreateDialog(context);
        },
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildHeader(
      BuildContext context,
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: MediaQuery.of(context).size.width < 600 ? 16 : 20,
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
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Bank Reconciliation',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D47A1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (state.selectedReconciliation != null)
                  IconButton(
                    onPressed: () => notifier.clearSelectedReconciliation(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back to list',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.selectedReconciliation == null
                  ? 'Manage and reconcile bank statements'
                  : 'Reconciliation Details',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            if (state.isLoadingBankAccounts && state.bankAccounts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading bank accounts...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildContent(BankReconciliationState state) {
    if (state.selectedReconciliation != null) {
      return const ReconciliationDetailWidget();
    }

    return const ReconciliationListWidget();
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width * 0.95
                : 800,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: ReconciliationFormWidget(),
        ),
      ),
    ).then((_) {
      // Refresh list after dialog closes
      ref.read(bankReconciliationProvider.notifier).fetchReconciliations();
    });
  }
}