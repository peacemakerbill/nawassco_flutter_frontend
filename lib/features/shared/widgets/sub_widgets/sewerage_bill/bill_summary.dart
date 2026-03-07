import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/sewerage_bill_model.dart';

class BillSummary extends StatelessWidget {
  final SewerageBill bill;
  final bool showPrintButton;
  final bool showShareButton;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const BillSummary({
    super.key,
    required this.bill,
    this.showPrintButton = true,
    this.showShareButton = true,
    this.onPrint,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Define helper methods inside build method but BEFORE they're used
    Widget _buildInfoSection({
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
          ...children,
        ],
      );
    }

    Widget _buildInfoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildChargeRow(String label, double amount,
        {bool isTotal = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.blue : Colors.black,
                ),
              ),
            ),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildPaymentRow(String label, double amount,
        {bool isBalance = false}) {
      final color = isBalance
          ? (bill.balance > 0 ? Colors.red : Colors.green)
          : Colors.black;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBalance ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBalance ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bill.statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
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
                        'Bill Summary',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bill.sewageServiceNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showPrintButton || showShareButton)
                  Row(
                    children: [
                      if (showPrintButton)
                        IconButton(
                          onPressed: onPrint,
                          icon: const Icon(Icons.print, color: Colors.blue),
                        ),
                      if (showShareButton)
                        IconButton(
                          onPressed: onShare,
                          icon: const Icon(Icons.share, color: Colors.blue),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Info
                _buildInfoSection(
                  title: 'Customer Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Name', bill.customerName),
                    _buildInfoRow('Email', bill.customerEmail),
                    _buildInfoRow('Service Number', bill.sewageServiceNumber),
                  ],
                ),

                const SizedBox(height: 20),

                // Billing Period
                _buildInfoSection(
                  title: 'Billing Period',
                  icon: Icons.calendar_today,
                  children: [
                    _buildInfoRow('Period', bill.billingPeriod.formattedPeriod),
                    _buildInfoRow('Due Date', dateFormat.format(bill.dueDate)),
                    if (bill.paidDate != null)
                      _buildInfoRow(
                          'Paid Date', dateFormat.format(bill.paidDate!)),
                  ],
                ),

                const SizedBox(height: 20),

                // Charges Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildChargeRow('Base Charge', bill.baseCharge),
                      _buildChargeRow('Usage Charge', bill.usageCharge),
                      _buildChargeRow('Penalty', bill.penalty),
                      _buildChargeRow('Arrears', bill.arrears),
                      _buildChargeRow('Tax Amount', bill.taxAmount),
                      const Divider(height: 20, thickness: 2),
                      _buildChargeRow('Total Amount', bill.totalAmount,
                          isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentRow('Total Amount', bill.totalAmount),
                      _buildPaymentRow('Paid Amount', bill.paidAmount),
                      const Divider(height: 16, color: Colors.blue),
                      _buildPaymentRow(
                        'Balance Due',
                        bill.balance,
                        isBalance: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bill.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: bill.statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(bill.statusIcon, color: bill.statusColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        bill.formattedStatus,
                        style: TextStyle(
                          color: bill.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
