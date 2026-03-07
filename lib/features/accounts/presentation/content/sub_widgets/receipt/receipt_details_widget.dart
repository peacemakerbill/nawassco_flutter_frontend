import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/receipt_model.dart';
import '../../../../providers/receipt_provider.dart';
import 'receipt_form_widget.dart';

class ReceiptDetailsWidget extends ConsumerStatefulWidget {
  final Receipt receipt;

  const ReceiptDetailsWidget({super.key, required this.receipt});

  @override
  ConsumerState<ReceiptDetailsWidget> createState() =>
      _ReceiptDetailsWidgetState();
}

class _ReceiptDetailsWidgetState extends ConsumerState<ReceiptDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    final receipt = widget.receipt;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: receipt.receiptType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    receipt.receiptType.icon,
                    color: receipt.receiptType.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.receiptNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        receipt.receiptType.displayName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
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
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Actions
                  _buildStatusSection(receipt),
                  const SizedBox(height: 24),
                  // Receipt Information
                  _buildReceiptInfoSection(receipt),
                  const SizedBox(height: 24),
                  // Payer Information
                  _buildPayerInfoSection(receipt),
                  const SizedBox(height: 24),
                  // Financial Information
                  _buildFinancialInfoSection(receipt),
                  const SizedBox(height: 24),
                  // Customer Information
                  if (receipt.customerName != null || receipt.customerEmail != null)
                    Column(
                      children: [
                        _buildCustomerInfoSection(receipt),
                        const SizedBox(height: 24),
                      ],
                    ),
                  // Allocation Information
                  _buildAllocationSection(receipt),
                  const SizedBox(height: 24),
                  // Document Section
                  _buildDocumentSection(receipt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(Receipt receipt) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: receipt.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    receipt.status.icon,
                    color: receipt.status.color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    receipt.status.displayName,
                    style: TextStyle(
                      color: receipt.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (receipt.isDraft) _buildDraftActions(),
            if (receipt.isConfirmed) _buildConfirmedActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _editReceipt,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D47A1),
            side: const BorderSide(color: Color(0xFF0D47A1)),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _confirmReceipt,
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Confirm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _allocateReceipt,
          icon: const Icon(Icons.assignment, size: 16),
          label: const Text('Allocate'),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _downloadReceipt,
          icon: const Icon(Icons.download),
          tooltip: 'Download Receipt',
        ),
      ],
    );
  }

  Widget _buildReceiptInfoSection(Receipt receipt) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Receipt Date', receipt.formattedDate),
            _buildInfoRow('Receipt Type', receipt.receiptType.displayName),
            _buildInfoRow('Payer Type', receipt.payerType.displayName),
            if (receipt.referenceNumber != null && receipt.referenceNumber!.isNotEmpty)
              _buildInfoRow('Reference Number', receipt.referenceNumber!),
            if (receipt.invoiceNumber != null && receipt.invoiceNumber!.isNotEmpty)
              _buildInfoRow('Invoice Number', receipt.invoiceNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerInfoSection(Receipt receipt) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Payer Name', receipt.payerName),
            if (receipt.payerEmail.isNotEmpty)
              _buildInfoRow('Payer Email', receipt.payerEmail),
            if (receipt.payerPhone.isNotEmpty)
              _buildInfoRow('Payer Phone', receipt.payerPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfoSection(Receipt receipt) {
    final totalAmount = receipt.amount + receipt.taxAmount;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Amount', receipt.formattedAmount),
            _buildInfoRow(
                'Tax Amount', 'KES ${receipt.taxAmount.toStringAsFixed(2)}'),
            const Divider(),
            _buildInfoRow('Total Amount',
                'KES ${totalAmount.toStringAsFixed(2)}', isBold: true),
            _buildInfoRow('Payment Method', receipt.paymentMethod.displayName),
            _buildInfoRow('Currency', receipt.currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection(Receipt receipt) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (receipt.customerName != null && receipt.customerName!.isNotEmpty)
              _buildInfoRow('Customer Name', receipt.customerName!),
            if (receipt.customerEmail != null && receipt.customerEmail!.isNotEmpty)
              _buildInfoRow('Customer Email', receipt.customerEmail!),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationSection(Receipt receipt) {
    final percentage = receipt.allocationPercentage;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allocated: KES ${receipt.allocatedAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Unallocated: KES ${receipt.unallocatedAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: percentage == 100
                      ? Colors.green
                      : percentage > 50
                      ? Colors.orange
                      : Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}% Allocated',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (receipt.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _allocateReceipt,
                    icon: const Icon(Icons.assignment, size: 16),
                    label: const Text('Allocate Funds'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection(Receipt receipt) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supporting Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (receipt.document == null)
              Column(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No document attached',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _uploadDocument,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Document'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: Text(receipt.document!.originalName),
                    subtitle: Text(
                      'Uploaded: ${_formatDate(receipt.document!.uploadedAt)} • ${receipt.document!.fileSizeFormatted}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _viewDocument,
                          icon: const Icon(Icons.visibility),
                          tooltip: 'View Document',
                        ),
                        IconButton(
                          onPressed: _deleteDocument,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Document',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editReceipt() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptFormWidget(receipt: widget.receipt),
    );
  }

  void _confirmReceipt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Receipt'),
        content: const Text(
            'Are you sure you want to confirm this receipt? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(receiptProvider.notifier)
          .confirmReceipt(widget.receipt.id);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _allocateReceipt() async {
    final allocatedAmount = await showDialog<double>(
      context: context,
      builder: (context) {
        final amountController = TextEditingController(
          text: widget.receipt.unallocatedAmount.toStringAsFixed(2),
        );

        return AlertDialog(
          title: const Text('Allocate Funds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Receipt Amount: ${widget.receipt.formattedAmount}'),
              Text('Already Allocated: KES ${widget.receipt.allocatedAmount.toStringAsFixed(2)}'),
              Text('Available: KES ${widget.receipt.unallocatedAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount to Allocate (KES)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount > widget.receipt.unallocatedAmount) {
                    return 'Cannot allocate more than available';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && amount <= widget.receipt.unallocatedAmount) {
                  Navigator.of(context).pop(amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
              ),
              child: const Text('ALLOCATE'),
            ),
          ],
        );
      },
    );

    if (allocatedAmount != null && allocatedAmount > 0) {
      final success = await ref
          .read(receiptProvider.notifier)
          .allocateReceipt(widget.receipt.id, allocatedAmount);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _downloadReceipt() {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download receipt functionality coming soon'),
      ),
    );
  }

  void _uploadDocument() async {
    // Implement document upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document upload functionality coming soon'),
      ),
    );
  }

  void _viewDocument() {
    if (widget.receipt.document != null) {
      // Implement document viewer
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(widget.receipt.document!.originalName),
                subtitle: Text(widget.receipt.document!.fileSizeFormatted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Open document URL
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Document'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    }
  }

  void _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(receiptProvider.notifier)
          .deleteReceiptDocument(widget.receipt.id);
    }
  }
}