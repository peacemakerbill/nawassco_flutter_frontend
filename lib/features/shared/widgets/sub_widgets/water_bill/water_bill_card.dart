import 'package:flutter/material.dart';

import '../../../models/water_bill_model.dart';

class WaterBillCard extends StatelessWidget {
  final WaterBill bill;
  final VoidCallback onTap;
  final bool isManagementView;

  const WaterBillCard({
    super.key,
    required this.bill,
    required this.onTap,
    this.isManagementView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: bill.isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
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
              // Header with bill number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bill.billNumber ?? 'Bill #${bill.id!.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: bill.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bill.statusColor, width: 1),
                    ),
                    child: Text(
                      bill.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: bill.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bill details
              if (isManagementView)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Customer:', bill.customerName),
                    _buildDetailRow('Email:', bill.customerEmail),
                    const SizedBox(height: 8),
                  ],
                ),

              _buildDetailRow('Meter No:', bill.meterNumber),
              _buildDetailRow('Billing Month:', bill.billingMonth),
              _buildDetailRow('Period:', bill.formattedPeriod),

              const SizedBox(height: 12),

              // Consumption and charges
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Consumption',
                      value: '${bill.consumption} m³',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Amount',
                      value: 'TZS ${bill.totalAmount.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Balance and due date
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Balance',
                      value: 'TZS ${bill.balance.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: bill.balance > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Due Date',
                      value: bill.formattedDueDate,
                      icon: Icons.calendar_today,
                      color: bill.isOverdue ? Colors.red : Colors.purple,
                    ),
                  ),
                ],
              ),

              // Disputed badge if applicable
              if (bill.disputed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'Disputed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
