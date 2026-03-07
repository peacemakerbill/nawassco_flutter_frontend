import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';
import 'document_manager_widget.dart';
import 'payment_form_widget.dart';

class PaymentDetailsWidget extends ConsumerWidget {
  final Payment payment;

  const PaymentDetailsWidget({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isSmallScreen ? 0.95 : 0.9),
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: payment.statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      payment.statusIcon,
                      color: payment.statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.paymentNumber,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          payment.statusDisplay,
                          style: TextStyle(
                            color: payment.statusColor,
                            fontWeight: FontWeight.w500,
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
              const SizedBox(height: 16),

              // Content with Tabs
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          labelColor: const Color(0xFF0D47A1),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFF0D47A1),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: 'Payment Details'),
                            Tab(text: 'Documents'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Payment Details Tab
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildOverviewSection(isSmallScreen),
                                  const SizedBox(height: 16),
                                  _buildAmountSection(),
                                  const SizedBox(height: 16),
                                  _buildPayeeSection(),
                                  const SizedBox(height: 16),
                                  _buildBankSection(),
                                  const SizedBox(height: 16),
                                  _buildReferencesSection(),
                                  const SizedBox(height: 16),
                                  _buildTimelineSection(),
                                  const SizedBox(height: 16),
                                  _buildActionButtons(context, ref),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                            // Documents Tab
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  DocumentManagerWidget(
                                    paymentId: payment.id,
                                    documents: payment.documents,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Overview',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (isSmallScreen)
              Column(
                children: [
                  _buildOverviewItem('Type', _formatEnumValue(payment.paymentType.name)),
                  _buildOverviewItem('Method', _formatEnumValue(payment.paymentMethod.name)),
                  _buildOverviewItem('Date', _formatDate(payment.paymentDate)),
                  _buildOverviewItem('Currency', payment.currency),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: 150, child: _buildOverviewItem('Type', _formatEnumValue(payment.paymentType.name))),
                  SizedBox(width: 150, child: _buildOverviewItem('Method', _formatEnumValue(payment.paymentMethod.name))),
                  SizedBox(width: 150, child: _buildOverviewItem('Date', _formatDate(payment.paymentDate))),
                  SizedBox(width: 150, child: _buildOverviewItem('Currency', payment.currency)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountItem('Gross Amount', payment.formattedAmount),
            _buildAmountItem('Tax Amount', payment.formattedTaxAmount),
            _buildAmountItem('Withholding Tax', payment.formattedWithholdingTax),
            const Divider(),
            _buildAmountItem(
              'Net Amount',
              payment.formattedNetAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayeeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payee Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Payee Type', _formatEnumValue(payment.payeeType.name)),
            if (payment.payeeName != null && payment.payeeName!.isNotEmpty)
              _buildDetailItem('Payee Name', payment.payeeName!),
            if (payment.payeeEmail != null && payment.payeeEmail!.isNotEmpty)
              _buildDetailItem('Payee Email', payment.payeeEmail!),
            if (payment.payeePhone != null && payment.payeePhone!.isNotEmpty)
              _buildDetailItem('Payee Phone', payment.payeePhone!),
            if (payment.payeeBankAccount != null && payment.payeeBankAccount!.isNotEmpty)
              _buildDetailItem('Payee Bank Account', payment.payeeBankAccount!),
            if (payment.payeeBankAccountName != null && payment.payeeBankAccountName!.isNotEmpty)
              _buildDetailItem('Account Holder', payment.payeeBankAccountName!),
            if (payment.description != null && payment.description!.isNotEmpty)
              _buildDetailItem('Description', payment.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (payment.companyBankName != null && payment.companyBankName!.isNotEmpty)
              _buildDetailItem('Company Bank', payment.companyBankName!),
            if (payment.companyBankAccount != null && payment.companyBankAccount!.isNotEmpty)
              _buildDetailItem('Company Account', payment.companyBankAccount!),
            if (payment.checkNumber != null && payment.checkNumber!.isNotEmpty)
              _buildDetailItem('Check Number', payment.checkNumber!),
            if (payment.transactionReference != null && payment.transactionReference!.isNotEmpty)
              _buildDetailItem('Transaction Reference', payment.transactionReference!),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reference Numbers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (payment.invoiceNumber != null && payment.invoiceNumber!.isNotEmpty)
              _buildDetailItem('Invoice Number', payment.invoiceNumber!),
            if (payment.purchaseOrderNumber != null && payment.purchaseOrderNumber!.isNotEmpty)
              _buildDetailItem('Purchase Order', payment.purchaseOrderNumber!),
            if (payment.contractNumber != null && payment.contractNumber!.isNotEmpty)
              _buildDetailItem('Contract Number', payment.contractNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Created',
              payment.createdAt,
              Icons.create,
              Colors.blue,
              payment.createdBy,
            ),
            if (payment.approvedDate != null)
              _buildTimelineItem(
                'Approved',
                payment.approvedDate!,
                Icons.verified,
                Colors.green,
                payment.approvedBy,
              ),
            if (payment.updatedBy != null)
              _buildTimelineItem(
                'Last Updated',
                payment.updatedAt,
                Icons.update,
                Colors.orange,
                payment.updatedBy,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? const Color(0xFF0D47A1) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String event,
      DateTime date,
      IconData icon,
      Color color,
      Map<String, dynamic>? user,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (user != null && user['firstName'] != null)
                  Text(
                    'By: ${user['firstName']} ${user['lastName']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final paymentNotifier = ref.read(paymentProvider.notifier);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        if (payment.canEdit)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => PaymentFormWidget(payment: payment),
              );
            },
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (payment.canApprove)
          ElevatedButton.icon(
            onPressed: () => _approvePayment(context, paymentNotifier),
            icon: const Icon(Icons.verified, size: 20),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (payment.canProcess)
          ElevatedButton.icon(
            onPressed: () => _processPayment(context, paymentNotifier),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Process'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (payment.canCancel)
          OutlinedButton.icon(
            onPressed: () => _cancelPayment(context, paymentNotifier),
            icon: const Icon(Icons.cancel, size: 20),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _approvePayment(BuildContext context, PaymentProvider notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Payment'),
        content: Text('Are you sure you want to approve payment ${payment.paymentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await notifier.approvePayment(payment.id);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment ${payment.paymentNumber} approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(BuildContext context, PaymentProvider notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Text('Are you sure you want to process payment ${payment.paymentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Process'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await notifier.processPayment(payment.id);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment ${payment.paymentNumber} processed successfully'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  Future<void> _cancelPayment(BuildContext context, PaymentProvider notifier) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel payment ${payment.paymentNumber}?'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await notifier.cancelPayment(payment.id, reason: reasonController.text);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment ${payment.paymentNumber} cancelled successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatEnumValue(String value) {
    return value.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}