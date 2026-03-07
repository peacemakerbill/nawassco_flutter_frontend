import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/quote.model.dart';
import '../../../../providers/quote_provider.dart';
import 'quote_approval_widget.dart';
import 'quote_export_widget.dart';
import 'quote_form_widget.dart';

class QuoteDetailWidget extends ConsumerWidget {
  final Quote quote;

  const QuoteDetailWidget({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          quote.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (quote.canBeSent)
            IconButton(
              onPressed: quoteState.isSending
                  ? null
                  : () {
                _showSendConfirmation(context, ref);
              },
              icon: Icon(
                quoteState.isSending ? Icons.hourglass_empty : Icons.send,
              ),
              tooltip: 'Send',
            ),
          if (quote.canBeApproved)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => QuoteApprovalWidget(quote: quote),
                );
              },
              icon: const Icon(Icons.thumb_up),
              tooltip: 'Approve',
            ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => QuoteExportWidget(quote: quote),
              );
            },
            icon: const Icon(Icons.download),
            tooltip: 'Export',
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              _showQuoteFormDialog(context, ref, quote);
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quote.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                    Border.all(color: quote.status.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(quote.status.icon,
                          size: 16, color: quote.status.color),
                      const SizedBox(width: 8),
                      Text(
                        quote.status.displayName,
                        style: TextStyle(
                          color: quote.status.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quote.approvalStatus.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: quote.approvalStatus.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(quote.approvalStatus.icon,
                          size: 16, color: quote.approvalStatus.color),
                      const SizedBox(width: 8),
                      Text(
                        quote.approvalStatus.displayName,
                        style: TextStyle(
                          color: quote.approvalStatus.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Info - Updated with new fields
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quote.customerDisplayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (quote.customerEmail != null &&
                        quote.customerEmail!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          quote.customerEmail!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (quote.opportunityNumber != null &&
                        quote.opportunityNumber!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Opportunity: ${quote.opportunityDisplayName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Warning
            if (!quote.isExpired && quote.daysUntilExpiry <= 7 || quote.isExpired)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: quote.expiryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: quote.expiryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      quote.isExpired ? Icons.warning : Icons.info,
                      color: quote.expiryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        quote.isExpired
                            ? 'This quote expired ${DateTime.now().difference(quote.expiryDate).inDays} days ago'
                            : 'This quote expires in ${quote.daysUntilExpiry} days',
                        style: TextStyle(
                          color: quote.expiryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!quote.isExpired && quote.daysUntilExpiry <= 7 || quote.isExpired)
              const SizedBox(height: 16),

            // Quote Details - Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.2 : 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildDetailCard(
                      'Quote Date',
                      '${quote.quoteDate.day}/${quote.quoteDate.month}/${quote.quoteDate.year}',
                      Icons.calendar_today,
                    ),
                    _buildDetailCard(
                      'Expiry Date',
                      '${quote.expiryDate.day}/${quote.expiryDate.month}/${quote.expiryDate.year}',
                      Icons.timer,
                      color: quote.expiryColor,
                    ),
                    _buildDetailCard(
                      'Payment Terms',
                      quote.paymentTerms,
                      Icons.payments,
                    ),
                    _buildDetailCard(
                      'Delivery Terms',
                      quote.deliveryTerms,
                      Icons.local_shipping,
                    ),
                    _buildDetailCard(
                      'Validity Period',
                      '${quote.validityPeriod} days',
                      Icons.schedule,
                    ),
                    _buildDetailCard(
                      'Currency',
                      quote.currency,
                      Icons.monetization_on,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // User Information - New Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUserInfoItem(
                            'Created By',
                            quote.createdByDisplayName,
                            quote.createdByUser?.email ??
                                quote.createdBy?['email']?.toString() ??
                                '',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUserInfoItem(
                            'Last Updated By',
                            quote.updatedByDisplayName,
                            quote.updatedByUser?.email ??
                                quote.updatedBy?['email']?.toString() ??
                                '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${quote.createdAt.day}/${quote.createdAt.month}/${quote.createdAt.year} ${quote.createdAt.hour}:${quote.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Updated: ${quote.updatedAt.day}/${quote.updatedAt.month}/${quote.updatedAt.year} ${quote.updatedAt.hour}:${quote.updatedAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Table
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quote Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowColor:
                        MaterialStateProperty.all(Colors.grey[50]),
                        dataRowHeight: 48,
                        headingRowHeight: 40,
                        columns: const [
                          DataColumn(label: Text('Item Code')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Qty'), numeric: true),
                          DataColumn(label: Text('Unit')),
                          DataColumn(label: Text('Price'), numeric: true),
                          DataColumn(label: Text('Total'), numeric: true),
                        ],
                        rows: quote.items.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    item.itemCode ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    item.description,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text(item.quantity.toString())),
                              DataCell(Text(item.unit)),
                              DataCell(
                                  Text('KES ${item.unitPrice.toStringAsFixed(2)}')),
                              DataCell(
                                  Text('KES ${item.totalPrice.toStringAsFixed(2)}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Totals
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTotalRow('Subtotal', quote.formattedSubtotal),
                    _buildTotalRow('Tax Amount', quote.formattedTax),
                    _buildTotalRow('Discount', quote.formattedDiscount),
                    const Divider(height: 32),
                    _buildTotalRow(
                      'Total Amount',
                      quote.formattedTotal,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // Special Conditions
            if (quote.specialConditions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Conditions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...quote.specialConditions.map((condition) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  condition,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],

            // Approval History
            if (quote.approvalDate != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Approval History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          quote.approvalStatus.color.withOpacity(0.1),
                          child: Icon(
                            quote.approvalStatus.icon,
                            color: quote.approvalStatus.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${quote.approvalStatus.displayName} by ${quote.approvedByDisplayName}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${quote.approvalDate!.day}/${quote.approvalDate!.month}/${quote.approvalDate!.year} ${quote.approvalDate!.hour}:${quote.approvalDate!.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: quote.approvalComments != null
                            ? IconButton(
                          onPressed: () {
                            _showApprovalComments(context);
                          },
                          icon:
                          const Icon(Icons.comment, color: Colors.grey),
                        )
                            : null,
                      ),
                      if (quote.approvedByEmail != null &&
                          quote.approvedByEmail!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 72),
                          child: Text(
                            quote.approvedByEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDeleteConfirmation(context, ref);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
        mini: MediaQuery.of(context).size.width < 600,
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon,
      {Color? color}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF1E3A8A)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color ?? const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color ?? const Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoItem(String title, String name, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        if (email.isNotEmpty)
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF1E3A8A) : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF1E3A8A) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showSendConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Quote'),
        content: const Text(
          'Are you sure you want to send this quote to the customer? This will change the status to "Sent" and notify the customer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(quoteProvider.notifier).sendQuote(quote.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Quote'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text(
          'Are you sure you want to delete this quote? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(quoteProvider.notifier).deleteQuote(quote.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showApprovalComments(BuildContext context) {
    if (quote.approvalComments == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approval Comments'),
        content: SingleChildScrollView(
          child: Text(quote.approvalComments!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuoteFormDialog(BuildContext context, WidgetRef ref, Quote quote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: QuoteFormWidget(initialQuote: quote),
        ),
      ),
    );
  }
}