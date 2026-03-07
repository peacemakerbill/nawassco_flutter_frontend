import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sewerage_bill_model.dart';

class SewerageBillDetails extends StatelessWidget {
  final SewerageBill bill;
  final bool showFullDetails;
  final VoidCallback? onPay;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onCancel;

  const SewerageBillDetails({
    super.key,
    required this.bill,
    this.showFullDetails = true,
    this.onPay,
    this.onPrint,
    this.onShare,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bill.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(bill.statusIcon, color: bill.statusColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.sewageServiceNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bill.customerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    bill.formattedStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: bill.statusColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Billing Information
          _buildSection(
            title: 'Billing Information',
            icon: Icons.receipt,
            children: [
              _buildInfoRow('Service Number', bill.sewageServiceNumber),
              _buildInfoRow('Customer Name', bill.customerName),
              _buildInfoRow('Customer Email', bill.customerEmail),
              _buildInfoRow(
                  'Billing Period', bill.billingPeriod.formattedPeriod),
              _buildInfoRow('Due Date', dateFormat.format(bill.dueDate)),
              if (bill.paidDate != null)
                _buildInfoRow('Paid Date', dateFormat.format(bill.paidDate!)),
            ],
          ),

          const SizedBox(height: 24),

          // Charges Breakdown
          _buildSection(
            title: 'Charges Breakdown',
            icon: Icons.attach_money,
            children: [
              _buildChargeRow(
                  'Base Charge', currencyFormat.format(bill.baseCharge)),
              _buildChargeRow(
                  'Usage Charge', currencyFormat.format(bill.usageCharge)),
              _buildChargeRow('Penalty', currencyFormat.format(bill.penalty)),
              _buildChargeRow('Arrears', currencyFormat.format(bill.arrears)),
              _buildChargeRow(
                  'Tax Amount', currencyFormat.format(bill.taxAmount)),
              const Divider(height: 24),
              _buildChargeRow(
                'Total Amount',
                currencyFormat.format(bill.totalAmount),
                isTotal: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment Summary
          _buildSection(
            title: 'Payment Summary',
            icon: Icons.payment,
            children: [
              _buildPaymentRow(
                  'Total Amount', currencyFormat.format(bill.totalAmount)),
              _buildPaymentRow(
                  'Paid Amount', currencyFormat.format(bill.paidAmount)),
              const Divider(height: 16),
              _buildPaymentRow(
                'Balance',
                currencyFormat.format(bill.balance),
                isBalance: true,
              ),
              if (bill.isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This bill is overdue. Please pay immediately to avoid service interruption.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          if (showFullDetails) ...[
            const SizedBox(height: 24),

            // Timeline
            _buildSection(
              title: 'Timeline',
              icon: Icons.timeline,
              children: [
                _buildTimelineRow('Created', bill.createdAt),
                _buildTimelineRow('Updated', bill.updatedAt),
                if (bill.paidDate != null)
                  _buildTimelineRow('Paid', bill.paidDate!),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // Action Buttons
          if (onPay != null ||
              onPrint != null ||
              onShare != null ||
              onCancel != null)
            Row(
              children: [
                if (onPay != null && bill.canPay)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPay,
                      icon: const Icon(Icons.payment),
                      label: const Text('Make Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (onPay != null && onPrint != null) const SizedBox(width: 8),
                if (onPrint != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print),
                      label: const Text('Print Bill'),
                    ),
                  ),
                if ((onPay != null || onPrint != null) && onShare != null)
                  const SizedBox(width: 8),
                if (onShare != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                if ((onPay != null || onPrint != null || onShare != null) &&
                    onCancel != null)
                  const SizedBox(width: 8),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Bill'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.blue : Colors.black,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount,
      {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBalance ? FontWeight.bold : FontWeight.normal,
                color: isBalance
                    ? (bill.balance > 0 ? Colors.red : Colors.green)
                    : Colors.black,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBalance ? FontWeight.bold : FontWeight.w600,
              color: isBalance
                  ? (bill.balance > 0 ? Colors.red : Colors.green)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(date),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
