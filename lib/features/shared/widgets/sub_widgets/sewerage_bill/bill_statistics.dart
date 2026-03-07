import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/sewerage_bill_model.dart';

class BillStatistics extends StatelessWidget {
  final BillingStatistics statistics;
  final VoidCallback? onRefresh;

  const BillStatistics({
    super.key,
    required this.statistics,
    this.onRefresh,
  });

  // Moved outside of build method
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    // Moved inside build method to access context and currencyFormat
    Widget _buildRevenueBar({
      required String label,
      required double amount,
      required double percentage,
      required Color color,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currencyFormat.format(amount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: MediaQuery.of(context).size.width * 0.7 * (percentage / 100),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Billing Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                  ),
              ],
            ),
          ),

          // Statistics Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // First Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Bills',
                        value: statistics.totalBills.toString(),
                        icon: Icons.receipt,
                        color: Colors.blue,
                        iconColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Revenue',
                        value: currencyFormat.format(statistics.totalRevenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Second Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending',
                        value: statistics.pendingBills.toString(),
                        icon: Icons.pending,
                        color: Colors.orange,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Paid',
                        value: statistics.paidBills.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Third Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Overdue',
                        value: statistics.overdueBills.toString(),
                        icon: Icons.warning,
                        color: Colors.red,
                        iconColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Average Bill',
                        value: currencyFormat.format(statistics.averageBillAmount),
                        icon: Icons.trending_up,
                        color: Colors.purple,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Revenue Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Distribution',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRevenueBar(
                        label: 'Paid Revenue',
                        amount: statistics.totalRevenue,
                        percentage: 100,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildRevenueBar(
                        label: 'Outstanding',
                        amount: statistics.averageBillAmount * statistics.pendingBills,
                        percentage: (statistics.pendingBills / statistics.totalBills * 100)
                            .clamp(0, 100)
                            .toDouble(),
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildRevenueBar(
                        label: 'Overdue',
                        amount: statistics.averageBillAmount * statistics.overdueBills,
                        percentage: (statistics.overdueBills / statistics.totalBills * 100)
                            .clamp(0, 100)
                            .toDouble(),
                        color: Colors.red,
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