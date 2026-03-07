import 'package:flutter/material.dart';

class StatsSummary extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isManagementView;

  const StatsSummary({
    super.key,
    required this.stats,
    required this.isManagementView,
  });

  @override
  Widget build(BuildContext context) {
    final statusCounts = stats['statusCounts'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Billing Statistics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Bills',
                    value: '${stats['totalBills'] ?? 0}',
                    color: Colors.blue,
                    icon: Icons.receipt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Amount',
                    value: 'TZS ${(stats['totalAmount'] ?? 0).toStringAsFixed(2)}',
                    color: Colors.green,
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Paid',
                    value: 'TZS ${(stats['totalPaid'] ?? 0).toStringAsFixed(2)}',
                    color: Colors.purple,
                    icon: Icons.paid,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Balance',
                    value: 'TZS ${(stats['totalBalance'] ?? 0).toStringAsFixed(2)}',
                    color: Colors.orange,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status Breakdown
            const Text(
              'Status Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatusChip(
                  'Pending',
                  statusCounts['pending'] ?? 0,
                  Colors.orange,
                ),
                _buildStatusChip(
                  'Paid',
                  statusCounts['paid'] ?? 0,
                  Colors.green,
                ),
                _buildStatusChip(
                  'Overdue',
                  statusCounts['overdue'] ?? 0,
                  Colors.red,
                ),
                _buildStatusChip(
                  'Partially Paid',
                  statusCounts['partially_paid'] ?? 0,
                  Colors.purple,
                ),
                _buildStatusChip(
                  'Cancelled',
                  statusCounts['cancelled'] ?? 0,
                  Colors.grey,
                ),
              ],
            ),

            if (stats['averageConsumption'] != null) ...[
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Average Consumption',
                value: '${(stats['averageConsumption'] ?? 0).toStringAsFixed(2)} m³',
                color: Colors.teal,
                icon: Icons.water_drop,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}