import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/invoice.dart';
import '../../../../providers/invoice_provider.dart';
import 'invoice_form_screen.dart';


class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoiceProvider.notifier).getInvoice(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);
    final invoice = invoiceState.selectedInvoice;

    if (invoiceState.isLoading && invoice == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Details'),
        ),
        body: const Center(
          child: Text('Invoice not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNumber}'),
        actions: [
          if (invoice.status == InvoiceStatus.draft)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceFormScreen(invoice: invoice),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, invoice),
            itemBuilder: (context) => _buildPopupMenuItems(invoice),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(invoice),
            const SizedBox(height: 20),

            // Status Section
            _buildStatusSection(invoice),
            const SizedBox(height: 20),

            // Items Section
            _buildItemsSection(invoice),
            const SizedBox(height: 20),

            // Payment Section
            _buildPaymentSection(invoice),
            const SizedBox(height: 20),

            // Actions Section
            _buildActionSection(invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'KES ${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Supplier', invoice.supplierName),
            _buildDetailRow('Purchase Order', invoice.purchaseOrderNumber),
            _buildDetailRow('Invoice Date', _formatDate(invoice.invoiceDate)),
            _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
            if (invoice.grnReferences.isNotEmpty)
              _buildDetailRow('GRN References', invoice.grnReferences.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusIndicator('Invoice Status', invoice.status),
                const SizedBox(width: 20),
                _buildStatusIndicator('Payment Status', invoice.paymentStatus),
                const SizedBox(width: 20),
                _buildStatusIndicator('Approval', invoice.approvalStatus),
              ],
            ),
            if (invoice.matchingDiscrepancies.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Matching Discrepancies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...invoice.matchingDiscrepancies.map((discrepancy) =>
                  Text('• $discrepancy')
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, dynamic status) {
    final statusMap = status is InvoiceStatus
        ? _getStatusInfo(status)
        : status is PaymentStatus
        ? _getPaymentInfo(status)
        : _getApprovalInfo(status as ApprovalStatus);

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: statusMap['color'].withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: statusMap['color']),
          ),
          child: Icon(
            statusMap['icon'],
            color: statusMap['color'],
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          statusMap['label'],
          style: TextStyle(
            fontSize: 10,
            color: statusMap['color'],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildItemsSection(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...invoice.items.map((item) => _buildItemRow(item)).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('KES ${(invoice.totalAmount - invoice.taxAmount).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Text('KES ${invoice.taxAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'KES ${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'GL: ${item.glAccount} | Center: ${item.costCenter}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text('${item.quantity} x ${item.unitPrice}'),
          ),
          Expanded(
            child: Text(
              'KES ${item.totalPrice}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Paid Amount', 'KES ${invoice.paidAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Balance Due', 'KES ${invoice.balanceDue.toStringAsFixed(2)}'),
            if (invoice.paymentDate != null)
              _buildDetailRow('Payment Date', _formatDate(invoice.paymentDate!)),
            if (invoice.paymentMethod != null)
              _buildDetailRow('Payment Method', invoice.paymentMethod!),
            if (invoice.paymentReference != null)
              _buildDetailRow('Reference', invoice.paymentReference!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActionButtons(invoice),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Invoice invoice) {
    final buttons = <Widget>[];

    if (invoice.status == InvoiceStatus.draft) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _submitInvoice(invoice.id),
          icon: const Icon(Icons.send),
          label: const Text('Submit for Approval'),
        ),
      );
    }

    if (invoice.status == InvoiceStatus.submitted &&
        invoice.approvalStatus == ApprovalStatus.pending) {
      buttons.addAll([
        ElevatedButton.icon(
          onPressed: () => _processApproval(invoice.id, 'approve'),
          icon: const Icon(Icons.check),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        ElevatedButton.icon(
          onPressed: () => _processApproval(invoice.id, 'reject'),
          icon: const Icon(Icons.close),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ]);
    }

    if (invoice.approvalStatus == ApprovalStatus.approved &&
        invoice.paymentStatus != PaymentStatus.paid) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _processPayment(invoice),
          icon: const Icon(Icons.payment),
          label: const Text('Process Payment'),
        ),
      );
    }

    if (!invoice.isMatched && invoice.status == InvoiceStatus.verified) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _matchInvoice(invoice.id, true),
          icon: const Icon(Icons.verified),
          label: const Text('Match with GRN'),
        ),
      );
    }

    return buttons;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _buildPopupMenuItems(Invoice invoice) {
    final items = <PopupMenuItem<String>>[];

    if (invoice.status == InvoiceStatus.draft) {
      items.add(const PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ));
      items.add(const PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
      ));
    }

    if (invoice.status == InvoiceStatus.submitted) {
      items.add(const PopupMenuItem<String>(
        value: 'cancel',
        child: Row(
          children: [
            Icon(Icons.cancel, size: 20),
            SizedBox(width: 8),
            Text('Cancel'),
          ],
        ),
      ));
    }

    items.add(const PopupMenuItem<String>(
      value: 'refresh',
      child: Row(
        children: [
          Icon(Icons.refresh, size: 20),
          SizedBox(width: 8),
          Text('Refresh'),
        ],
      ),
    ));

    return items;
  }

  void _handleMenuAction(String value, Invoice invoice) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceFormScreen(invoice: invoice),
          ),
        );
        break;
      case 'delete':
        _deleteInvoice(invoice.id);
        break;
      case 'cancel':
        _cancelInvoice(invoice.id);
        break;
      case 'refresh':
        ref.read(invoiceProvider.notifier).getInvoice(invoice.id);
        break;
    }
  }

  Future<void> _submitInvoice(String invoiceId) async {
    final success = await ref.read(invoiceProvider.notifier).submitInvoice(invoiceId);
    if (success) {
      // Refresh the invoice details
      ref.read(invoiceProvider.notifier).getInvoice(invoiceId);
    }
  }

  Future<void> _processApproval(String invoiceId, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'approve' ? 'Approve' : 'Reject'} Invoice'),
        content: Text('Are you sure you want to ${action == 'approve' ? 'approve' : 'reject'} this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action == 'approve' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(invoiceProvider.notifier).processApproval(invoiceId, action);
      if (success) {
        ref.read(invoiceProvider.notifier).getInvoice(invoiceId);
      }
    }
  }

  Future<void> _processPayment(Invoice invoice) async {
    final amountController = TextEditingController(text: invoice.balanceDue.toString());
    final methodController = TextEditingController();
    final referenceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: methodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final paymentData = {
                'paidAmount': double.parse(amountController.text),
                'paymentDate': DateTime.now().toIso8601String(),
                'paymentMethod': methodController.text,
                'paymentReference': referenceController.text,
              };

              final success = await ref.read(invoiceProvider.notifier).processPayment(
                invoice.id,
                paymentData,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ref.read(invoiceProvider.notifier).getInvoice(invoice.id);
              }
            },
            child: const Text('Process Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _matchInvoice(String invoiceId, bool isMatched) async {
    final success = await ref.read(invoiceProvider.notifier).matchInvoice(invoiceId, isMatched);
    if (success) {
      ref.read(invoiceProvider.notifier).getInvoice(invoiceId);
    }
  }

  Future<void> _deleteInvoice(String invoiceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(invoiceProvider.notifier).deleteInvoice(invoiceId);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _cancelInvoice(String invoiceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invoice'),
        content: const Text('Are you sure you want to cancel this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(invoiceProvider.notifier).updateInvoice(
        invoiceId,
        {'status': InvoiceStatus.cancelled.name},
      );
      if (success) {
        ref.read(invoiceProvider.notifier).getInvoice(invoiceId);
      }
    }
  }

  Map<String, dynamic> _getStatusInfo(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return {'label': 'Draft', 'color': Colors.grey, 'icon': Icons.drafts};
      case InvoiceStatus.submitted:
        return {'label': 'Submitted', 'color': Colors.orange, 'icon': Icons.send};
      case InvoiceStatus.verified:
        return {'label': 'Verified', 'color': Colors.blue, 'icon': Icons.verified};
      case InvoiceStatus.approved:
        return {'label': 'Approved', 'color': Colors.green, 'icon': Icons.check_circle};
      case InvoiceStatus.paid:
        return {'label': 'Paid', 'color': Colors.purple, 'icon': Icons.payment};
      case InvoiceStatus.disputed:
        return {'label': 'Disputed', 'color': Colors.red, 'icon': Icons.warning};
      case InvoiceStatus.cancelled:
        return {'label': 'Cancelled', 'color': Colors.black, 'icon': Icons.cancel};
    }
  }

  Map<String, dynamic> _getPaymentInfo(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return {'label': 'Pending', 'color': Colors.orange, 'icon': Icons.pending};
      case PaymentStatus.partially_paid:
        return {'label': 'Partial', 'color': Colors.blue, 'icon': Icons.payment};
      case PaymentStatus.paid:
        return {'label': 'Paid', 'color': Colors.green, 'icon': Icons.check_circle};
      case PaymentStatus.overdue:
        return {'label': 'Overdue', 'color': Colors.red, 'icon': Icons.warning};
      case PaymentStatus.cancelled:
        return {'label': 'Cancelled', 'color': Colors.black, 'icon': Icons.cancel};
    }
  }

  Map<String, dynamic> _getApprovalInfo(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return {'label': 'Pending', 'color': Colors.orange, 'icon': Icons.pending};
      case ApprovalStatus.approved:
        return {'label': 'Approved', 'color': Colors.green, 'icon': Icons.check_circle};
      case ApprovalStatus.rejected:
        return {'label': 'Rejected', 'color': Colors.red, 'icon': Icons.close};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}