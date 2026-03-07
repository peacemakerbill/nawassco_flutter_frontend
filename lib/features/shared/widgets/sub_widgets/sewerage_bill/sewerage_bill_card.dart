import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sewerage_bill_model.dart';

class SewerageBillCard extends StatelessWidget {
  final SewerageBill bill;
  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onViewDetails;
  final bool showActions;

  const SewerageBillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onPay,
    this.onViewDetails,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: bill.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bill.sewageServiceNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      bill.formattedStatus,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: bill.statusColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bill details
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Billing Period',
                value: bill.billingPeriod.formattedPeriod,
              ),

              _buildDetailRow(
                icon: Icons.calendar_month,
                label: 'Due Date',
                value: dateFormat.format(bill.dueDate),
                isOverdue: bill.isOverdue,
              ),

              _buildDetailRow(
                icon: Icons.attach_money,
                label: 'Total Amount',
                value: currencyFormat.format(bill.totalAmount),
              ),

              _buildDetailRow(
                icon: Icons.payments,
                label: 'Paid Amount',
                value: currencyFormat.format(bill.paidAmount),
              ),

              _buildDetailRow(
                icon: Icons.account_balance_wallet,
                label: 'Balance',
                value: currencyFormat.format(bill.balance),
                valueColor: bill.balance > 0 ? Colors.red : Colors.green,
              ),

              // Actions row
              if (showActions) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onViewDetails != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.remove_red_eye, size: 16),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (onViewDetails != null && onPay != null)
                      const SizedBox(width: 8),
                    if (onPay != null && bill.canPay)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onPay,
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Pay Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isOverdue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isOverdue ? Colors.red : Colors.black),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
