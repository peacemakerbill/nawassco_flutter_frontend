import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/bank_reconciliation_model.dart';
import '../../../../providers/bank_reconciliation_provider.dart';
import 'reconciliation_form_widget.dart';

class ReconciliationDetailWidget extends ConsumerStatefulWidget {
  const ReconciliationDetailWidget({super.key});

  @override
  ConsumerState<ReconciliationDetailWidget> createState() =>
      _ReconciliationDetailWidgetState();
}

class _ReconciliationDetailWidgetState
    extends ConsumerState<ReconciliationDetailWidget> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankReconciliationProvider);
    final notifier = ref.read(bankReconciliationProvider.notifier);
    final reconciliation = state.selectedReconciliation;

    if (reconciliation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 12 : 16,
      ),
      child: CustomScrollView(
        slivers: [
          // Header Summary
          SliverToBoxAdapter(
            child: _buildSummaryCard(reconciliation, notifier),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Balance Comparison
          SliverToBoxAdapter(
            child: _buildBalanceComparisonCard(reconciliation),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Outstanding Items
          SliverToBoxAdapter(
            child:
            _buildOutstandingItemsCard(reconciliation, notifier),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Cleared Transactions
          SliverToBoxAdapter(
            child: _buildClearedTransactionsCard(reconciliation),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BankReconciliation reconciliation,
      BankReconciliationProvider notifier,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width < 600 ? 48 : 60,
                  height: MediaQuery.of(context).size.width < 600 ? 48 : 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reconciliation.displayName,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reconciliation.reconciliationNumber,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                              reconciliation.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              reconciliation.statusDisplayText,
                              style: TextStyle(
                                color: reconciliation.statusColor,
                                fontWeight: FontWeight.w500,
                                fontSize:
                                MediaQuery.of(context).size.width < 600 ? 11 : 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (reconciliation.reconciledByName != null)
                            Flexible(
                              child: Text(
                                'By: ${reconciliation.reconciledByName!}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize:
                                  MediaQuery.of(context).size.width < 600 ? 10 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Statement Date',
                        _formatDate(reconciliation.statementDate),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Next Reconciliation',
                        _formatDate(reconciliation.nextReconciliationDate),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Created',
                        _formatDate(reconciliation.createdAt),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Statement Date',
                        _formatDate(reconciliation.statementDate),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Next Reconciliation',
                        _formatDate(reconciliation.nextReconciliationDate),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Created',
                        _formatDate(reconciliation.createdAt),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (reconciliation.canEdit || reconciliation.canComplete) ...[
              const Divider(height: 1),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    return Column(
                      children: [
                        if (reconciliation.canEdit)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showEditDialog(reconciliation),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        if (reconciliation.canEdit && reconciliation.canComplete)
                          const SizedBox(height: 8),
                        if (reconciliation.canComplete)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => notifier
                                  .completeReconciliation(reconciliation.id!),
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Complete Reconciliation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      if (reconciliation.canEdit)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showEditDialog(reconciliation),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                      if (reconciliation.canEdit && reconciliation.canComplete)
                        SizedBox(
                          width: MediaQuery.of(context).size.width < 768 ? 8 : 12,
                        ),
                      if (reconciliation.canComplete)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => notifier
                                .completeReconciliation(reconciliation.id!),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Complete Reconciliation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceComparisonCard(BankReconciliation reconciliation) {
    final isBalanced = reconciliation.difference.abs() <= 0.01;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Comparison',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
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
                      _buildBalanceItem(
                        'Bank Statement',
                        reconciliation.statementBalance,
                        Icons.account_balance,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildBalanceItem(
                        'Book Balance',
                        reconciliation.bookBalance,
                        Icons.book,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildBalanceItem(
                        'Adjusted Balance',
                        reconciliation.adjustedBalance,
                        Icons.adjust,
                        Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      _buildDifferenceItem(
                        reconciliation.difference,
                        isBalanced,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        'Bank Statement',
                        reconciliation.statementBalance,
                        Icons.account_balance,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 8 : 12),
                    Expanded(
                      child: _buildBalanceItem(
                        'Book Balance',
                        reconciliation.bookBalance,
                        Icons.book,
                        Colors.purple,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 8 : 12),
                    Expanded(
                      child: _buildBalanceItem(
                        'Adjusted Balance',
                        reconciliation.adjustedBalance,
                        Icons.adjust,
                        Colors.teal,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width < 768 ? 8 : 12),
                    Expanded(
                      child: _buildDifferenceItem(
                        reconciliation.difference,
                        isBalanced,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (!isBalanced) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildReconciliationBreakdown(reconciliation),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
      String label,
      double amount,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceItem(double difference, bool isBalanced) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBalanced ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            size: 32,
            color: isBalanced ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 8),
          Text(
            'Difference',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(difference),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: isBalanced ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBalanced ? 'Balanced' : 'Needs Adjustment',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
              color: isBalanced ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationBreakdown(BankReconciliation reconciliation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reconciliation Breakdown',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return Column(
                children: [
                  _buildBreakdownItem(
                    'Outstanding Deposits',
                    reconciliation.totalOutstandingDeposits,
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildBreakdownItem(
                    'Outstanding Checks',
                    reconciliation.totalOutstandingChecks,
                    Colors.red,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'Outstanding Deposits',
                    reconciliation.totalOutstandingDeposits,
                    Colors.green,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width < 768 ? 8 : 12),
                Expanded(
                  child: _buildBreakdownItem(
                    'Outstanding Checks',
                    reconciliation.totalOutstandingChecks,
                    Colors.red,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Adjusted Balance = Statement Balance + Outstanding Deposits - Outstanding Checks',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingItemsCard(
      BankReconciliation reconciliation,
      BankReconciliationProvider notifier,
      ) {
    final outstandingItems = reconciliation.outstandingItems;
    final clearedItems =
    outstandingItems.where((item) => item.cleared).toList();
    final pendingItems =
    outstandingItems.where((item) => !item.cleared).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Outstanding Items',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (reconciliation.canEdit)
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                    onPressed: () =>
                        _addOutstandingItem(reconciliation, notifier),
                    tooltip: 'Add Outstanding Item',
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (pendingItems.isNotEmpty) ...[
              Text(
                'Pending Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 12),
              ...pendingItems.map((item) => _buildOutstandingItemRow(
                item,
                reconciliation,
                notifier,
                false,
              )),
              const SizedBox(height: 20),
            ],
            if (clearedItems.isNotEmpty) ...[
              Text(
                'Cleared Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),
              ...clearedItems.map((item) => _buildOutstandingItemRow(
                item,
                reconciliation,
                notifier,
                true,
              )),
            ],
            if (outstandingItems.isEmpty)
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingItemRow(
      OutstandingItem item,
      BankReconciliation reconciliation,
      BankReconciliationProvider notifier,
      bool isCleared,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isCleared ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      color: isCleared ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCleared ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCleared ? Icons.check_circle : Icons.pending,
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
                      color: isCleared ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w500,
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
                if (!isCleared && reconciliation.canEdit)
                  TextButton(
                    onPressed: () => notifier.clearOutstandingItem(
                      reconciliation.id!,
                      item.id!,
                    ),
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
                if (isCleared && item.clearedDate != null)
                  Text(
                    'Cleared ${_formatDate(item.clearedDate!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearedTransactionsCard(BankReconciliation reconciliation) {
    final transactions = reconciliation.clearedTransactions;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cleared Transactions',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (transactions.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildTransactionRow(transactions[index]);
                },
              )
            else
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(ClearedTransaction transaction) {
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
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

  void _showEditDialog(
      BankReconciliation reconciliation,
      ) {
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
          child: ReconciliationFormWidget(reconciliation: reconciliation),
        ),
      ),
    ).then((_) {
      // Refresh data after dialog closes
      ref.read(bankReconciliationProvider.notifier).fetchReconciliations();
    });
  }

  void _addOutstandingItem(
      BankReconciliation reconciliation,
      BankReconciliationProvider notifier,
      ) {
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
              final itemData = OutstandingItemData(
                itemDate: DateTime.now(),
                description: 'Sample Outstanding Item',
                amount: 500.0,
                itemType: OutstandingItemType.outstanding_check,
                reference: 'CHK-${DateTime.now().millisecondsSinceEpoch}',
              );
              notifier.addOutstandingItem(reconciliation.id!, itemData);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
}