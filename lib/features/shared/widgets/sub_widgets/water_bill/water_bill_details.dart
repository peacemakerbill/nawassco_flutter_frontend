import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/water_bill_model.dart';
import '../../../providers/water_bill_provider.dart';
import 'adjustment_form.dart';

class WaterBillDetails extends ConsumerWidget {
  final WaterBill bill;
  final bool isManagementView;
  final VoidCallback onBack;
  final Function() onRefresh;

  const WaterBillDetails({
    super.key,
    required this.bill,
    required this.isManagementView,
    required this.onBack,
    required this.onRefresh,
  });

  void _showAdjustmentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: AdjustmentForm(
          billId: bill.id!,
          onSubmit: (adjustment) async {
            final success = await ref
                .read(waterBillProvider.notifier)
                .addAdjustment(bill.id!, adjustment);
            if (success) {
              onRefresh();
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
    );
  }

  void _showDiscountDialog(BuildContext context, WidgetRef ref) {
    final discountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply Discount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount Amount (TZS)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Discount',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(discountController.text);
                        final reason = reasonController.text.trim();

                        if (amount != null && amount > 0 && reason.isNotEmpty) {
                          final success = await ref
                              .read(waterBillProvider.notifier)
                              .applyDiscount(bill.id!, amount, reason);
                          if (success) {
                            onRefresh();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: const Text('APPLY'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mark as Disputed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Dispute',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final reason = reasonController.text.trim();
                        if (reason.isNotEmpty) {
                          final success = await ref
                              .read(waterBillProvider.notifier)
                              .markAsDisputed(bill.id!, reason);
                          if (success) {
                            onRefresh();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: const Text('SUBMIT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(
          bill.billNumber ?? 'Bill Details',
          style: const TextStyle(fontSize: 16),
        ),
        actions: isManagementView
            ? [
                if (!bill.readingVerified)
                  IconButton(
                    icon: const Icon(Icons.verified),
                    onPressed: () async {
                      final success = await ref
                          .read(waterBillProvider.notifier)
                          .verifyReading(bill.id!);
                      if (success) {
                        onRefresh();
                      }
                    },
                    tooltip: 'Verify Reading',
                  ),
                IconButton(
                  icon: const Icon(Icons.discount),
                  onPressed: () => _showDiscountDialog(context, ref),
                  tooltip: 'Apply Discount',
                ),
                IconButton(
                  icon: const Icon(Icons.add_chart),
                  onPressed: () => _showAdjustmentDialog(context, ref),
                  tooltip: 'Add Adjustment',
                ),
                if (!bill.disputed)
                  IconButton(
                    icon: const Icon(Icons.warning),
                    onPressed: () => _showDisputeDialog(context, ref),
                    tooltip: 'Mark as Disputed',
                  ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bill.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bill.statusColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(bill.status),
                      color: bill.statusColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.statusText.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: bill.statusColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due Date: ${bill.formattedDueDate}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'TZS ${bill.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: bill.statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Customer Information Card
              _buildSectionCard(
                title: 'Customer Information',
                children: [
                  _buildDetailItem('Customer Name', bill.customerName),
                  _buildDetailItem('Email', bill.customerEmail),
                  _buildDetailItem('Meter Number', bill.meterNumber),
                  _buildDetailItem('Service Region', bill.serviceRegion),
                ],
              ),

              const SizedBox(height: 16),

              // Billing Information Card
              _buildSectionCard(
                title: 'Billing Information',
                children: [
                  _buildDetailItem('Billing Month', bill.billingMonth),
                  _buildDetailItem('Billing Period', bill.formattedPeriod),
                  _buildDetailItem('Due Date', bill.formattedDueDate),
                  _buildDetailItem('Bill Number', bill.billNumber ?? 'N/A'),
                ],
              ),

              const SizedBox(height: 16),

              // Reading Information Card
              _buildSectionCard(
                title: 'Reading Information',
                children: [
                  _buildDetailItem(
                      'Previous Reading', '${bill.previousReading} m³'),
                  _buildDetailItem(
                      'Current Reading', '${bill.currentReading} m³'),
                  _buildDetailItem('Consumption', '${bill.consumption} m³'),
                  _buildDetailItem(
                      'Reading Date', _formatDate(bill.readingDate)),
                  _buildDetailItem(
                      'Reading Type', bill.readingType.toUpperCase()),
                  _buildDetailItem(
                      'Verified', bill.readingVerified ? 'Yes' : 'No'),
                  if (bill.isEstimated)
                    _buildDetailItem('Estimation',
                        'Yes - ${bill.isEstimated ? 'Estimated Reading' : ''}'),
                ],
              ),

              const SizedBox(height: 16),

              // Charges Breakdown Card
              _buildSectionCard(
                title: 'Charges Breakdown',
                children: [
                  _buildChargeItem('Water Charges', bill.waterCharges),
                  _buildChargeItem('Sewerage Charges', bill.sewerageCharges),
                  _buildChargeItem('Meter Rent', bill.meterRent),
                  _buildChargeItem('Penalty', bill.penalty),
                  _buildChargeItem('Arrears', bill.arrears),
                  _buildChargeItem('Tax Amount', bill.taxAmount),
                  if (bill.discountApplied > 0)
                    _buildChargeItem('Discount Applied', -bill.discountApplied,
                        isDiscount: true),
                  const Divider(height: 24, thickness: 1),
                  _buildChargeItem(
                    'TOTAL AMOUNT',
                    bill.totalAmount,
                    isTotal: true,
                  ),
                  _buildChargeItem('Paid Amount', bill.paidAmount),
                  _buildChargeItem(
                    'BALANCE DUE',
                    bill.balance,
                    isBalance: true,
                    color: bill.balance > 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),

              // Dispute Information (if disputed)
              if (bill.disputed) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Dispute Information',
                  color: Colors.orange.withValues(alpha: 0.1),
                  children: [
                    _buildDetailItem('Dispute Status',
                        bill.disputeResolved == true ? 'Resolved' : 'Pending'),
                    if (bill.disputeReason != null)
                      _buildDetailItem('Reason', bill.disputeReason!),
                    if (bill.disputeDate != null)
                      _buildDetailItem(
                          'Date Raised', _formatDate(bill.disputeDate!)),
                    if (bill.disputeResolved == true &&
                        bill.disputeDate != null)
                      _buildDetailItem(
                          'Resolved Date', _formatDate(bill.disputeDate!)),
                  ],
                ),
              ],

              // Adjustments (if any)
              if (bill.adjustments.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Adjustments',
                  children: [
                    ...bill.adjustments.map(
                      (adjustment) => _buildAdjustmentItem(adjustment),
                    ),
                  ],
                ),
              ],

              // Meta Information
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Meta Information',
                children: [
                  _buildDetailItem('Created', _formatDate(bill.createdAt)),
                  _buildDetailItem('Last Updated', _formatDate(bill.updatedAt)),
                  if (bill.averageDailyConsumption != null)
                    _buildDetailItem('Avg Daily Consumption',
                        '${bill.averageDailyConsumption!.toStringAsFixed(2)} m³'),
                  if (bill.consumptionTrend != null)
                    _buildDetailItem('Consumption Trend',
                        bill.consumptionTrend!.toUpperCase()),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeItem(
    String label,
    double amount, {
    bool isTotal = false,
    bool isBalance = false,
    bool isDiscount = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight:
                  isTotal || isBalance ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.blue : (color ?? Colors.grey[700]),
            ),
          ),
          Text(
            'TZS ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight:
                  isTotal || isBalance ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount
                  ? Colors.green
                  : (color ?? (amount < 0 ? Colors.red : Colors.green)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentItem(Adjustment adjustment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: adjustment.type == 'credit' ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        adjustment.type == 'credit' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    adjustment.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'TZS ${adjustment.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        adjustment.type == 'credit' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              adjustment.reason,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(adjustment.appliedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'overdue':
        return Icons.warning;
      case 'partially_paid':
        return Icons.paid;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }
}
