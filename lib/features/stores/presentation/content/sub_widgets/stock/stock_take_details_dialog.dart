import 'package:flutter/material.dart';
import '../../../../models/stock/adjustment_model.dart';
import '../../../../models/stock/counted_item_model.dart';
import '../../../../models/stock/counting_team_model.dart';
import '../../../../models/stock/stock_take_model.dart';

class StockTakeDetailsDialog extends StatelessWidget {
  final StockTake stockTake;

  const StockTakeDetailsDialog({super.key, required this.stockTake});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stockTake.stockTakeNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getStockTakeTypeText(stockTake.stockTakeType),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: const Color(0xFF1E3A8A),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF1E3A8A),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Counted Items'),
                          Tab(text: 'Team'),
                          Tab(text: 'Adjustments'),
                        ],
                      ),
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(),
                          _buildCountedItemsTab(),
                          _buildTeamTab(),
                          _buildAdjustmentsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(stockTake.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Last Updated: ${_formatDate(stockTake.updatedAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Progress
          _buildStatusSection(),
          const SizedBox(height: 24),

          // Key Metrics
          _buildMetricsSection(),
          const SizedBox(height: 24),

          // Location Information
          _buildLocationSection(),
          const SizedBox(height: 24),

          // Additional Information
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: _getStatusText(stockTake.status),
                  color: _getStatusColor(stockTake.status),
                ),
                _StatusChip(
                  label: _getCountingStatusText(stockTake.countingStatus),
                  color: _getCountingStatusColor(stockTake.countingStatus),
                ),
                _StatusChip(
                  label: _getApprovalStatusText(stockTake.approvalStatus),
                  color: _getApprovalStatusColor(stockTake.approvalStatus),
                ),
                if (stockTake.adjustmentRequired)
                  const _StatusChip(
                    label: 'Adjustment Required',
                    color: Colors.orange,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stockTake.completionPercentage / 100,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(stockTake.completionPercentage),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${stockTake.completionPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${stockTake.countedItemsCount}/${stockTake.totalItems} items counted',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _MetricCard(
                  label: 'Total Expected Value',
                  value:
                      'KES ${stockTake.totalExpectedValue.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
                _MetricCard(
                  label: 'Total Counted Value',
                  value:
                      'KES ${stockTake.totalCountedValue.toStringAsFixed(2)}',
                  icon: Icons.calculate,
                  color: Colors.green,
                ),
                _MetricCard(
                  label: 'Variance Value',
                  value:
                      'KES ${stockTake.totalVarianceValue.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: _getVarianceColor(stockTake.totalVarianceValue),
                ),
                _MetricCard(
                  label: 'Variance Percentage',
                  value: '${stockTake.variancePercentage.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  color: _getVarianceColor(stockTake.totalVarianceValue),
                ),
                _MetricCard(
                  label: 'Items with Variance',
                  value: '${stockTake.varianceItems} items',
                  icon: Icons.warning,
                  color: stockTake.varianceItems > 0
                      ? Colors.orange
                      : Colors.green,
                ),
                _MetricCard(
                  label: 'Counting Accuracy',
                  value:
                      '${(100 - stockTake.variancePercentage).toStringAsFixed(1)}%',
                  icon: Icons.track_changes,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Warehouse',
                        value: stockTake.warehouse,
                      ),
                      _InfoRow(
                        label: 'Number of Zones',
                        value: '${stockTake.zones.length} zones',
                      ),
                    ],
                  ),
                ),
                if (stockTake.zones.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zones:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: stockTake.zones
                              .map((zone) => Chip(
                                    label: Text(zone),
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.1),
                                    labelStyle: const TextStyle(fontSize: 12),
                                  ))
                              .toList(),
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

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Stock Take Date',
              value: _formatDate(stockTake.stockTakeDate),
            ),
            _InfoRow(
              label: 'Stock Take Type',
              value: _getStockTakeTypeText(stockTake.stockTakeType),
            ),
            _InfoRow(
              label: 'Counting Team Size',
              value: '${stockTake.countingTeam.length} members',
            ),
            if (stockTake.notes != null && stockTake.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(stockTake.notes!),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountedItemsTab() {
    return Column(
      children: [
        // Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryItem(
                    label: 'Total Items',
                    value: stockTake.totalItems.toString(),
                  ),
                  _SummaryItem(
                    label: 'Counted Items',
                    value: stockTake.countedItemsCount.toString(),
                  ),
                  _SummaryItem(
                    label: 'Variance Items',
                    value: stockTake.varianceItems.toString(),
                  ),
                  _SummaryItem(
                    label: 'Completion',
                    value:
                        '${stockTake.completionPercentage.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stockTake.countedItems.length,
            itemBuilder: (context, index) {
              final countedItem = stockTake.countedItems[index];
              return _CountedItemCard(countedItem: countedItem, index: index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Counting Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...stockTake.countingTeam
                    .map((member) => _TeamMemberCard(member: member)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentsTab() {
    return Column(
      children: [
        // Adjustment Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryItem(
                    label: 'Total Adjustments',
                    value: stockTake.adjustments.length.toString(),
                  ),
                  _SummaryItem(
                    label: 'Adjustment Required',
                    value: stockTake.adjustmentRequired ? 'Yes' : 'No',
                    color: stockTake.adjustmentRequired
                        ? Colors.orange
                        : Colors.green,
                  ),
                  _SummaryItem(
                    label: 'Total Adjustment Value',
                    value:
                        'KES ${_getTotalAdjustmentValue().toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Adjustments List
        if (stockTake.adjustments.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.adjust, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No adjustments made',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        if (stockTake.adjustments.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stockTake.adjustments.length,
              itemBuilder: (context, index) {
                final adjustment = stockTake.adjustments[index];
                return _AdjustmentCard(adjustment: adjustment, index: index);
              },
            ),
          ),
      ],
    );
  }

  double _getTotalAdjustmentValue() {
    return stockTake.adjustments
        .fold(0.0, (sum, adjustment) => sum + adjustment.value);
  }

  String _getStockTakeTypeText(String type) {
    switch (type) {
      case 'annual':
        return 'Annual Count';
      case 'quarterly':
        return 'Quarterly Count';
      case 'monthly':
        return 'Monthly Count';
      case 'cycle_count':
        return 'Cycle Count';
      case 'spot_check':
        return 'Spot Check';
      case 'full_count':
        return 'Full Count';
      default:
        return type;
    }
  }

  String _getStatusText(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _getCountingStatusText(String status) {
    switch (status) {
      case 'not_started':
        return 'Not Started';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String _getApprovalStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'revised':
        return 'Revised';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'counting_completed':
        return Colors.orange;
      case 'under_review':
        return Colors.purple;
      case 'adjusted':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCountingStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getApprovalStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'revised':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 50) return Colors.red;
    if (percentage < 80) return Colors.orange;
    return Colors.green;
  }

  Color _getVarianceColor(double variance) {
    final absVariance = variance.abs();
    if (absVariance < 100) return Colors.green;
    if (absVariance < 500) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _CountedItemCard extends StatelessWidget {
  final CountedItem countedItem;
  final int index;

  const _CountedItemCard({required this.countedItem, required this.index});

  @override
  Widget build(BuildContext context) {
    final variancePercent = countedItem.expectedQuantity > 0
        ? (countedItem.variance / countedItem.expectedQuantity * 100)
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item: ${countedItem.itemId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (countedItem.batchNumber != null)
                    Text(
                      'Batch: ${countedItem.batchNumber}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (countedItem.remarks != null)
                    Text(
                      'Remarks: ${countedItem.remarks}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Expected: ${countedItem.expectedQuantity}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          'Counted: ${countedItem.countedQuantity}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getVarianceColor(variancePercent.abs().toDouble()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${countedItem.variance >= 0 ? '+' : ''}${countedItem.variance}',
                        style: TextStyle(
                          color: _getVarianceTextColor(variancePercent.abs().toDouble()),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${variancePercent >= 0 ? '+' : ''}${variancePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getVarianceColor(double variancePercent) {
    if (variancePercent <= 1) return Colors.green.withOpacity(0.2);
    if (variancePercent <= 5) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }

  Color _getVarianceTextColor(double variancePercent) {
    if (variancePercent <= 1) return Colors.green;
    if (variancePercent <= 5) return Colors.orange;
    return Colors.red;
  }
}

class _TeamMemberCard extends StatelessWidget {
  final CountingTeamMember member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member: ${member.memberId}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Role: ${_getRoleText(member.role)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (member.assignedZones.isNotEmpty)
                  Text(
                    'Zones: ${member.assignedZones.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Items Counted: ${member.itemsCounted}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Started: ${_formatTime(member.startTime)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (member.endTime != null)
                Text(
                  'Ended: ${_formatTime(member.endTime!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'supervisor':
        return 'Supervisor';
      case 'counter':
        return 'Counter';
      case 'verifier':
        return 'Verifier';
      case 'data_entry':
        return 'Data Entry';
      default:
        return role;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AdjustmentCard extends StatelessWidget {
  final Adjustment adjustment;
  final int index;

  const _AdjustmentCard({required this.adjustment, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getAdjustmentColor(adjustment.adjustmentType),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAdjustmentIcon(adjustment.adjustmentType),
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item: ${adjustment.itemId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Reason: ${adjustment.reason}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_getAdjustmentTypeText(adjustment.adjustmentType)}: ${adjustment.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getAdjustmentColor(adjustment.adjustmentType),
                  ),
                ),
                Text(
                  'Value: KES ${adjustment.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDate(adjustment.adjustmentDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAdjustmentColor(String type) {
    switch (type) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'write_off':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAdjustmentIcon(String type) {
    switch (type) {
      case 'positive':
        return Icons.add;
      case 'negative':
        return Icons.remove;
      case 'write_off':
        return Icons.block;
      default:
        return Icons.adjust;
    }
  }

  String _getAdjustmentTypeText(String type) {
    switch (type) {
      case 'positive':
        return 'Increase';
      case 'negative':
        return 'Decrease';
      case 'write_off':
        return 'Write Off';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
