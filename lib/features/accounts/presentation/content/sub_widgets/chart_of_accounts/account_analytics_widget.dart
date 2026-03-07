import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class AccountAnalyticsWidget extends ConsumerWidget {
  const AccountAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartOfAccountsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Cards
            _buildSummaryCards(state),
            const SizedBox(height: 24),

            // Charts
            _buildChartsSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ChartOfAccountsState state) {
    final accounts = state.accounts;

    final totalAccounts = accounts.length;
    final activeAccounts = accounts.where((a) => a.isActive).length;
    final bankAccounts = accounts.where((a) => a.isBankAccount).length;
    final systemAccounts = accounts.where((a) => a.isSystemAccount).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final crossAxisCount = isMobile ? 2 : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSummaryCard(
              'Total Accounts',
              totalAccounts.toString(),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Active Accounts',
              activeAccounts.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildSummaryCard(
              'Bank Accounts',
              bankAccounts.toString(),
              Icons.account_balance,
              Colors.purple,
            ),
            _buildSummaryCard(
              'System Accounts',
              systemAccounts.toString(),
              Icons.security,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ChartOfAccountsState state) {
    final accounts = state.accounts;

    if (accounts.isEmpty) {
      return _buildEmptyChartsState();
    }

    return Column(
      children: [
        // Account Type Distribution
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Type Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildAccountTypeChart(accounts),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Account Status
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Status Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: _buildAccountStatusChart(accounts),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChartsState() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Analytics Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analytics charts will appear here once you have accounts',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeChart(List<ChartOfAccount> accounts) {
    final typeCounts = <AccountType, int>{};
    for (final type in AccountType.values) {
      typeCounts[type] = accounts.where((a) => a.accountType == type).length;
    }

    final chartData = typeCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => _PieChartData(
      entry.key,
      entry.value,
      _getAccountTypeColor(entry.key),
    ))
        .toList();

    return PieChart(
      PieChartData(
        sections: chartData.map((data) => PieChartSectionData(
          color: data.color,
          value: data.value.toDouble(),
          title: '${data.value}',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildAccountStatusChart(List<ChartOfAccount> accounts) {
    final activeCount = accounts.where((a) => a.isActive).length;
    final inactiveCount = accounts.length - activeCount;

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: activeCount.toDouble(),
                color: Colors.green,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: inactiveCount.toDouble(),
                color: Colors.red,
                width: 20,
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('Active');
                if (value == 1) return const Text('Inactive');
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset: return Colors.green;
      case AccountType.liability: return Colors.orange;
      case AccountType.equity: return Colors.blue;
      case AccountType.revenue: return Colors.purple;
      case AccountType.expense: return Colors.red;
    }
  }
}

class _PieChartData {
  final AccountType type;
  final int value;
  final Color color;

  _PieChartData(this.type, this.value, this.color);
}