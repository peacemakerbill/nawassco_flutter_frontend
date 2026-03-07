import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/journal_entry_model.dart';
import '../../../../providers/journal_entry_provider.dart';
import 'journal_entry_form_widget.dart';

class JournalEntryDetailsWidget extends ConsumerWidget {
  final JournalEntry journalEntry;

  const JournalEntryDetailsWidget({
    super.key,
    required this.journalEntry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Card
                    _buildBasicInfoCard(),
                    const SizedBox(height: 20),
                    // Transactions Card
                    _buildTransactionsCard(),
                    const SizedBox(height: 20),
                    // Audit Info Card
                    _buildAuditInfoCard(),
                  ],
                ),
              ),
            ),
            // Actions Footer
            _buildActionsFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF0D47A1), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journalEntry.entryNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  journalEntry.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                _buildInfoItem('Reference', journalEntry.reference),
                _buildInfoItem('Entry Date',
                    '${journalEntry.entryDate.year}-${journalEntry.entryDate.month.toString().padLeft(2, '0')}-${journalEntry.entryDate.day.toString().padLeft(2, '0')}'),
                _buildInfoItem('Status', journalEntry.statusText,
                    color: journalEntry.statusColor),
                _buildInfoItem('Source Document',
                    _formatSourceDocument(journalEntry.sourceDocument)),
                _buildInfoItem('Accounting Period', journalEntry.accountingPeriod),
                _buildInfoItem('Fiscal Year', journalEntry.fiscalYear),
                _buildInfoItem('Currency', journalEntry.currency),
                if (journalEntry.sourceId != null && journalEntry.sourceId!.isNotEmpty)
                  _buildInfoItem('Source ID', journalEntry.sourceId!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? color}) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Transactions Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Account')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Debit'), numeric: true),
                  DataColumn(label: Text('Credit'), numeric: true),
                  DataColumn(label: Text('Cost Center')),
                  DataColumn(label: Text('Project')),
                ],
                rows: journalEntry.transactions.map((transaction) {
                  return DataRow(cells: [
                    DataCell(Text('${transaction.accountCode} - ${transaction.accountName}')),
                    DataCell(Text(transaction.description)),
                    DataCell(Text(
                      transaction.debit > 0 ? 'KES ${transaction.debit.toStringAsFixed(2)}' : '-',
                      style: TextStyle(
                        color: transaction.debit > 0 ? Colors.green : Colors.grey,
                        fontWeight: transaction.debit > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    )),
                    DataCell(Text(
                      transaction.credit > 0 ? 'KES ${transaction.credit.toStringAsFixed(2)}' : '-',
                      style: TextStyle(
                        color: transaction.credit > 0 ? Colors.red : Colors.grey,
                        fontWeight: transaction.credit > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    )),
                    DataCell(Text(transaction.costCenter ?? '-')),
                    DataCell(Text(transaction.projectCode ?? '-')),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Totals
            _buildTotalsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalItem('Total Debit', journalEntry.totalDebit, Colors.green),
            const SizedBox(width: 24),
            _buildTotalItem('Total Credit', journalEntry.totalCredit, Colors.red),
            const SizedBox(width: 24),
            _buildTotalItem(
              'Balance',
              (journalEntry.totalDebit - journalEntry.totalCredit).abs(),
              (journalEntry.totalDebit - journalEntry.totalCredit).abs() <= 0.01
                  ? Colors.green
                  : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAuditInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                _buildInfoItem('Created By', journalEntry.createdByName),
                _buildInfoItem('Created On',
                    '${journalEntry.createdAt.year}-${journalEntry.createdAt.month.toString().padLeft(2, '0')}-${journalEntry.createdAt.day.toString().padLeft(2, '0')}'),
                if (journalEntry.approvedByName != null)
                  _buildInfoItem('Approved By', journalEntry.approvedByName!),
                if (journalEntry.approvedDate != null)
                  _buildInfoItem('Approved On',
                      '${journalEntry.approvedDate!.year}-${journalEntry.approvedDate!.month.toString().padLeft(2, '0')}-${journalEntry.approvedDate!.day.toString().padLeft(2, '0')}'),
                if (journalEntry.reversalEntryId != null)
                  _buildInfoItem('Reversal Entry', 'Yes', color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (journalEntry.canEdit)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditJournalEntryDialog(context, ref);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            if (journalEntry.canEdit) const SizedBox(width: 12),
            if (journalEntry.canApprove)
              FilledButton.icon(
                onPressed: () async {
                  final success = await ref.read(journalEntryProvider.notifier)
                      .approveJournalEntry(journalEntry.id);
                  if (success) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            if (journalEntry.canApprove) const SizedBox(width: 12),
            if (journalEntry.canReverse)
              FilledButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Reverse Journal Entry'),
                      content: const Text(
                        'Are you sure you want to reverse this journal entry? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Reverse'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final success = await ref.read(journalEntryProvider.notifier)
                        .reverseJournalEntry(journalEntry.id);
                    if (success) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: const Icon(Icons.replay),
                label: const Text('Reverse'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditJournalEntryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(dialogContext).size.width * 0.95,
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
          ),
          child: JournalEntryFormWidget(
            initialEntry: journalEntry,
            onSaved: () {
              Navigator.of(dialogContext).pop();
              ref.read(journalEntryProvider.notifier).fetchJournalEntries();
            },
          ),
        ),
      ),
    );
  }

  String _formatSourceDocument(SourceDocument source) {
    switch (source) {
      case SourceDocument.manual:
        return 'Manual Entry';
      case SourceDocument.invoice:
        return 'Invoice';
      case SourceDocument.payment:
        return 'Payment';
      case SourceDocument.receipt:
        return 'Receipt';
      case SourceDocument.purchase_order:
        return 'Purchase Order';
      case SourceDocument.sales_order:
        return 'Sales Order';
      case SourceDocument.bank_reconciliation:
        return 'Bank Reconciliation';
      case SourceDocument.adjustment:
        return 'Adjustment';
    }
  }
}