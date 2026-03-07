import 'package:flutter/material.dart';

import '../../../../models/journal_entry_model.dart';

class JournalEntryCardWidget extends StatelessWidget {
  final JournalEntry journalEntry;
  final VoidCallback onTap;

  const JournalEntryCardWidget({
    super.key,
    required this.journalEntry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              _buildHeaderRow(),
              const SizedBox(height: 16),
              // Description
              _buildDescription(),
              const SizedBox(height: 16),
              // Transactions Summary
              _buildTransactionsSummary(),
              const SizedBox(height: 16),
              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: journalEntry.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: journalEntry.statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                journalEntry.statusIcon,
                size: 14,
                color: journalEntry.statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                journalEntry.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: journalEntry.statusColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Entry Number
        Text(
          journalEntry.entryNumber,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          journalEntry.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Ref: ${journalEntry.reference}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Transactions Count
          _buildSummaryItem(
            'Transactions',
            '${journalEntry.transactions.length}',
            Icons.list_alt,
          ),
          const VerticalDivider(),
          // Total Debit
          _buildSummaryItem(
            'Total Debit',
            'KES ${journalEntry.totalDebit.toStringAsFixed(2)}',
            Icons.arrow_downward,
            Colors.green,
          ),
          const VerticalDivider(),
          // Total Credit
          _buildSummaryItem(
            'Total Credit',
            'KES ${journalEntry.totalCredit.toStringAsFixed(2)}',
            Icons.arrow_upward,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon,
      [Color? color]) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey[700],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Date
        _buildFooterItem(
          Icons.calendar_today,
          '${journalEntry.entryDate.day}/${journalEntry.entryDate.month}/${journalEntry.entryDate.year}',
        ),
        const Spacer(),
        // Created By
        _buildFooterItem(
          Icons.person,
          journalEntry.createdByName,
        ),
        const Spacer(),
        // Source Document
        _buildFooterItem(
          Icons.description,
          _formatSourceDocument(journalEntry.sourceDocument),
        ),
      ],
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
