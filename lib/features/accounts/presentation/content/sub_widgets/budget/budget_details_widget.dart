import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/budget_model.dart';
import '../../../../providers/budget_provider.dart';
import 'budget_form_widget.dart';

class BudgetDetailsWidget extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailsWidget({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: CustomScrollView(
        slivers: [
          // Header with Actions
          SliverToBoxAdapter(
            child: _buildHeader(context, ref, theme, isMobile),
          ),
          SliverToBoxAdapter(child: SizedBox(height: isMobile ? 16 : 20)),

          // Budget Summary Cards
          SliverToBoxAdapter(
            child: _buildSummaryCards(theme, isMobile),
          ),
          SliverToBoxAdapter(child: SizedBox(height: isMobile ? 16 : 20)),

          // Budget Items
          SliverToBoxAdapter(
            child: _buildBudgetItemsHeader(theme, isMobile),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => isMobile
                  ? _buildMobileBudgetItem(budget.items[index], theme)
                  : _buildDesktopBudgetItem(budget.items[index], theme),
              childCount: budget.items.length,
            ),
          ),

          // Empty Items State
          if (budget.items.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          size: isMobile ? 48 : 64,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'No budget items added',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      if (budget.status == BudgetStatus.draft)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Show add item dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Add item functionality'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Item'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, ThemeData theme, bool isMobile) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.budgetName,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        budget.budgetNumber,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: budget.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    budget.statusLabel,
                    style: TextStyle(
                      color: budget.statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              budget.description,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            if (isMobile)
              Column(
                children: [
                  _buildDetailRow('Fiscal Year', budget.fiscalYear, theme, isMobile),
                  SizedBox(height: 8),
                  _buildDetailRow('Period Type',
                      _getPeriodTypeLabel(budget.periodType), theme, isMobile),
                  SizedBox(height: 8),
                  _buildDetailRow(
                      'Start Date', dateFormat.format(budget.startDate), theme, isMobile),
                  SizedBox(height: 8),
                  _buildDetailRow(
                      'End Date', dateFormat.format(budget.endDate), theme, isMobile),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                      child: _buildDetailRow(
                          'Fiscal Year', budget.fiscalYear, theme, isMobile)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildDetailRow('Period Type',
                          _getPeriodTypeLabel(budget.periodType), theme, isMobile)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildDetailRow('Start Date',
                          dateFormat.format(budget.startDate), theme, isMobile)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildDetailRow(
                          'End Date', dateFormat.format(budget.endDate), theme, isMobile)),
                ],
              ),
            SizedBox(height: isMobile ? 16 : 20),
            _buildActionButtons(context, ref, theme, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, ThemeData theme, bool isMobile) {
    final buttons = <Widget>[];

    if (budget.status == BudgetStatus.draft) {
      buttons.addAll([
        ElevatedButton.icon(
          onPressed: () => _editBudget(context),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        ElevatedButton.icon(
          onPressed: () => _addBudgetItem(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        ElevatedButton.icon(
          onPressed: () => _submitBudget(ref, context),
          icon: const Icon(Icons.send, size: 18),
          label: const Text('Submit for Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ]);
    }

    if (budget.status == BudgetStatus.under_review) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _approveBudget(ref, context),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Approve Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (budget.status == BudgetStatus.approved) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _closeBudget(ref, context),
          icon: const Icon(Icons.lock, size: 18),
          label: const Text('Close Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    buttons.addAll([
      if (buttons.isNotEmpty) SizedBox(width: isMobile ? 8 : 12),
      OutlinedButton.icon(
        onPressed: () => ref.read(budgetProvider.notifier).clearSelectedBudget(),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Back to List'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.dividerColor),
        ),
      ),
    ]);

    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: buttons,
      );
    } else {
      return Row(
        children: buttons,
      );
    }
  }

  Widget _buildSummaryCards(ThemeData theme, bool isMobile) {
    final cardCount = isMobile ? 2 : 4;

    return GridView.count(
      crossAxisCount: cardCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isMobile ? 1.2 : 1.5,
      children: [
        _buildSummaryCard(
          'Total Budget',
          'KES ${budget.totalBudget.toStringAsFixed(2)}',
          Icons.attach_money,
          theme.colorScheme.primary,
          theme,
          isMobile,
        ),
        _buildSummaryCard(
          'Committed',
          'KES ${budget.committedAmount.toStringAsFixed(2)}',
          Icons.schedule,
          Colors.orange,
          theme,
          isMobile,
        ),
        if (!isMobile)
          _buildSummaryCard(
            'Actual Spent',
            'KES ${budget.actualSpent.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.green,
            theme,
            isMobile,
          ),
        if (!isMobile)
          _buildSummaryCard(
            'Remaining',
            'KES ${budget.remainingBalance.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.purple,
            theme,
            isMobile,
          ),
        if (isMobile)
          _buildSummaryCard(
            'Utilization',
            '${budget.utilizationRate.toStringAsFixed(1)}%',
            Icons.pie_chart,
            budget.utilizationRate > 80 ? Colors.red : Colors.purple,
            theme,
            isMobile,
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color,
      ThemeData theme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItemsHeader(ThemeData theme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Icon(Icons.list_alt,
                color: theme.colorScheme.primary, size: isMobile ? 20 : 24),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Budget Items',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${budget.items.length} items',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBudgetItem(BudgetItem item, ThemeData theme) {
    final utilization = item.budgetAmount > 0 ? (item.actualSpent / item.budgetAmount) * 100 : 0;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.accountName ?? 'Unknown Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.accountCode != null)
                        Text(
                          'Account: ${item.accountCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                      if (item.accountType != null)
                        Text(
                          'Type: ${item.accountType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KES ${item.budgetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${utilization.toStringAsFixed(1)}% spent',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemProgressBar(item, utilization, theme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildItemDetailRow('Committed',
                        'KES ${item.committedAmount.toStringAsFixed(2)}', theme)),
                Expanded(
                    child: _buildItemDetailRow('Actual Spent',
                        'KES ${item.actualSpent.toStringAsFixed(2)}', theme)),
                Expanded(
                    child: _buildItemDetailRow('Remaining',
                        'KES ${item.remainingBalance.toStringAsFixed(2)}', theme)),
              ],
            ),
            if (item.costCenter != null || item.projectCode != null || item.notes != null) ...[
              const SizedBox(height: 12),
              _buildItemMetadata(item, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBudgetItem(BudgetItem item, ThemeData theme) {
    final utilization = item.budgetAmount > 0 ? (item.actualSpent / item.budgetAmount) * 100 : 0;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.accountName ?? 'Unknown Account',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.accountCode != null)
                        Text(
                          'Code: ${item.accountCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KES ${item.budgetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.actualSpent > 0)
                      Text(
                        '${utilization.toStringAsFixed(1)}% spent',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemProgressBar(item, utilization, theme),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildItemDetailRow('Committed',
                    'KES ${item.committedAmount.toStringAsFixed(2)}', theme),
                const SizedBox(height: 4),
                _buildItemDetailRow('Actual Spent',
                    'KES ${item.actualSpent.toStringAsFixed(2)}', theme),
                const SizedBox(height: 4),
                _buildItemDetailRow('Remaining',
                    'KES ${item.remainingBalance.toStringAsFixed(2)}', theme),
              ],
            ),
            if (item.costCenter != null || item.projectCode != null || item.notes != null) ...[
              const SizedBox(height: 12),
              _buildItemMetadata(item, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemProgressBar(BudgetItem item, num utilization, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilization',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            Text(
              '${utilization.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: utilization > 80
                    ? Colors.red
                    : utilization > 50
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: utilization / 100,
          backgroundColor: theme.dividerColor,
          color: utilization > 80
              ? Colors.red
              : utilization > 50
              ? Colors.orange
              : Colors.green,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildItemDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemMetadata(BudgetItem item, ThemeData theme) {
    final chips = <Widget>[];

    if (item.costCenter != null) {
      chips.add(
        _buildMetadataChip('Cost Center: ${item.costCenter}', theme),
      );
    }

    if (item.projectCode != null) {
      chips.add(
        _buildMetadataChip('Project: ${item.projectCode}', theme),
      );
    }

    if (item.notes != null && item.notes!.length < 30) {
      chips.add(
        _buildMetadataChip('Notes: ${item.notes}', theme),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _buildMetadataChip(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getPeriodTypeLabel(PeriodType type) {
    switch (type) {
      case PeriodType.annual:
        return 'Annual';
      case PeriodType.quarterly:
        return 'Quarterly';
      case PeriodType.monthly:
        return 'Monthly';
    }
  }

  void _editBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetFormWidget(budget: budget),
    );
  }

  void _addBudgetItem(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add budget item functionality'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _submitBudget(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Budget for Review'),
        content: const Text('Are you sure you want to submit this budget for review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(budgetProvider.notifier).submitBudget(budget.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget submitted for review successfully'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _approveBudget(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Budget'),
        content: const Text('Are you sure you want to approve this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(budgetProvider.notifier).approveBudget(budget.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget approved successfully'),
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _closeBudget(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Budget'),
        content: const Text('Are you sure you want to close this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(budgetProvider.notifier).closeBudget(budget.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget closed successfully'),
                  ),
                );
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}