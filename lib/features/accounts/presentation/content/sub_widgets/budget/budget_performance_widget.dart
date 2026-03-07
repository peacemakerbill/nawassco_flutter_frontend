import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/budget_model.dart';
import '../../../../providers/budget_provider.dart';

class BudgetPerformanceWidget extends ConsumerStatefulWidget {
  const BudgetPerformanceWidget({super.key});

  @override
  ConsumerState<BudgetPerformanceWidget> createState() =>
      _BudgetPerformanceWidgetState();
}

class _BudgetPerformanceWidgetState
    extends ConsumerState<BudgetPerformanceWidget> {
  String? _selectedFiscalYear;
  String? _selectedPeriodType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).fetchBudgetPerformance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;
    final isVerySmallMobile = screenWidth < 350;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Filters
            _buildPerformanceFilters(state, isMobile, isSmallMobile, isVerySmallMobile),
            SizedBox(height: isMobile ? 12 : 20),

            // Performance Overview
            if (state.performance != null)
              _buildPerformanceOverview(state.performance!, isMobile, isVerySmallMobile),

            // Charts and Detailed Analysis
            if (state.performance != null) ...[
              SizedBox(height: isMobile ? 12 : 20),
              _buildDetailedAnalysis(state.performance!, isMobile, isVerySmallMobile),
            ],

            // Loading State
            if (state.isLoading && state.performance == null)
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: const Center(child: CircularProgressIndicator()),
              ),

            // Empty State
            if (!state.isLoading && state.performance == null)
              _buildEmptyPerformanceState(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceFilters(
      BudgetState state, bool isMobile, bool isSmallMobile, bool isVerySmallMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Filters',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (isVerySmallMobile)
              Column(
                children: [
                  _buildFiscalYearFilter(state, isMobile),
                  SizedBox(height: 8),
                  _buildPeriodTypeFilter(state, isMobile),
                  SizedBox(height: 8),
                  _buildRefreshButton(isMobile),
                ],
              )
            else if (isSmallMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildFiscalYearFilter(state, isMobile)),
                      SizedBox(width: 8),
                      Expanded(child: _buildPeriodTypeFilter(state, isMobile)),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildRefreshButton(isMobile),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildFiscalYearFilter(state, isMobile)),
                  SizedBox(width: 8),
                  Expanded(child: _buildPeriodTypeFilter(state, isMobile)),
                  SizedBox(width: 8),
                  Container(
                    width: isMobile ? 120 : 140,
                    child: _buildRefreshButton(isMobile),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiscalYearFilter(BudgetState state, bool isMobile) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => (currentYear - 2 + index).toString());

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Fiscal Year',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
      value: _selectedFiscalYear,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Years')),
        ...years.map((year) => DropdownMenuItem(
          value: year,
          child: Text(year),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedFiscalYear = value;
        });
        ref.read(budgetProvider.notifier).fetchBudgetPerformance(
          fiscalYear: value,
          periodType: _selectedPeriodType,
        );
      },
      isExpanded: true,
    );
  }

  Widget _buildPeriodTypeFilter(BudgetState state, bool isMobile) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Period Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
      value: _selectedPeriodType,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Periods')),
        ...PeriodType.values.map((type) => DropdownMenuItem(
          value: type.name,
          child: Text(_getPeriodTypeLabel(type)),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPeriodType = value;
        });
        ref.read(budgetProvider.notifier).fetchBudgetPerformance(
          fiscalYear: _selectedFiscalYear,
          periodType: value,
        );
      },
      isExpanded: true,
    );
  }

  Widget _buildRefreshButton(bool isMobile) {
    final state = ref.watch(budgetProvider);

    return ElevatedButton.icon(
      onPressed: state.isLoading
          ? null
          : () {
        ref.read(budgetProvider.notifier).fetchBudgetPerformance(
          fiscalYear: _selectedFiscalYear,
          periodType: _selectedPeriodType,
        );
      },
      icon: Icon(Icons.refresh, size: isMobile ? 18 : 20),
      label: Text(
        'Refresh',
        style: TextStyle(fontSize: isMobile ? 13 : 14),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
        minimumSize: Size.zero,
      ),
    );
  }

  Widget _buildPerformanceOverview(BudgetPerformance performance, bool isMobile, bool isVerySmallMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 20 : 24),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Budget Performance Overview',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardCount = isVerySmallMobile ? 1 : (isMobile ? 2 : 4);
                final childAspectRatio = isVerySmallMobile ? 1.5 : (isMobile ? 1.2 : 1.5);

                return GridView.count(
                  crossAxisCount: cardCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildPerformanceCard(
                      'Total Budgets',
                      performance.totalBudgets.toString(),
                      Icons.account_balance_wallet,
                      Theme.of(context).colorScheme.primary,
                      isMobile,
                    ),
                    _buildPerformanceCard(
                      'Total Budget Amount',
                      'KES ${performance.totalBudgetAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                      isMobile,
                    ),
                    if (!isMobile || (isMobile && !isVerySmallMobile))
                      _buildPerformanceCard(
                        'Total Spent',
                        'KES ${performance.totalSpent.toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.orange,
                        isMobile,
                      ),
                    if (!isMobile || (isMobile && !isVerySmallMobile))
                      _buildPerformanceCard(
                        'Utilization Rate',
                        '${performance.utilizationRate.toStringAsFixed(1)}%',
                        Icons.pie_chart,
                        performance.utilizationRate > 80
                            ? Colors.red
                            : Colors.purple,
                        isMobile,
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: isMobile ? 12 : 20),
            _buildProgressBars(performance, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
      String title, String value, IconData icon, Color color, bool isMobile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars(BudgetPerformance performance, bool isMobile) {
    final totalBudget = performance.totalBudgetAmount;
    final totalSpent = performance.totalSpent;
    final totalCommitted = performance.totalCommitted;
    final totalRemaining = performance.totalRemaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Allocation',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildProgressItem('Spent', totalSpent, totalBudget, Colors.orange, isMobile),
        SizedBox(height: isMobile ? 8 : 12),
        _buildProgressItem('Committed', totalCommitted, totalBudget, Colors.blue, isMobile),
        SizedBox(height: isMobile ? 8 : 12),
        _buildProgressItem('Remaining', totalRemaining, totalBudget, Colors.green, isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        _buildLegend(isMobile),
      ],
    );
  }

  Widget _buildProgressItem(
      String label, double value, double total, Color color, bool isMobile) {
    final percentage = total > 0 ? (value / total) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 13 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'KES ${value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 14,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Theme.of(context).dividerColor,
          color: color,
          minHeight: isMobile ? 6 : 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegend(bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isMobile ? 12 : 16,
      runSpacing: isMobile ? 8 : 12,
      children: [
        _buildLegendItem('Spent', Colors.orange, isMobile),
        _buildLegendItem('Committed', Colors.blue, isMobile),
        _buildLegendItem('Remaining', Colors.green, isMobile),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 10 : 12,
          height: isMobile ? 10 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: isMobile ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis(BudgetPerformance performance, bool isMobile, bool isVerySmallMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 20 : 24),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Analysis by Account Type',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 20),
            _buildAccountTypeAnalysis(performance.byAccountType, isMobile, isVerySmallMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeAnalysis(Map<String, dynamic> byAccountType, bool isMobile, bool isVerySmallMobile) {
    if (byAccountType.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart,
                  size: isMobile ? 48 : 64,
                  color: Theme.of(context).hintColor),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'No account type data available',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      );
    }

    final accountTypes = byAccountType.keys.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isVerySmallMobile ? 1 : (isMobile ? 2 : 3),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? (isVerySmallMobile ? 1.8 : 1.5) : 1.2,
      ),
      itemCount: accountTypes.length,
      itemBuilder: (context, index) {
        final type = accountTypes[index];
        final data = byAccountType[type] as Map<String, dynamic>;
        return _buildAccountTypeCard(type, data, isMobile, isVerySmallMobile);
      },
    );
  }

  Widget _buildAccountTypeCard(
      String accountType, Map<String, dynamic> data, bool isMobile, bool isVerySmallMobile) {
    final budget = (data['budget'] as num?)?.toDouble() ?? 0;
    final spent = (data['spent'] as num?)?.toDouble() ?? 0;
    final utilization = budget > 0 ? (spent / budget) * 100 : 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              accountType.toUpperCase(),
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            if (isVerySmallMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAccountTypeRow('Budget', 'KES ${budget.toStringAsFixed(2)}', isMobile),
                  SizedBox(height: 4),
                  _buildAccountTypeRow('Spent', 'KES ${spent.toStringAsFixed(2)}', isMobile),
                  SizedBox(height: 4),
                  _buildAccountTypeRow('Utilization', '${utilization.toStringAsFixed(1)}%', isMobile),
                ],
              )
            else if (isMobile)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAccountTypeColumn('Budget', 'KES ${budget.toStringAsFixed(2)}', isMobile),
                      _buildAccountTypeColumn('Spent', 'KES ${spent.toStringAsFixed(2)}', isMobile),
                      _buildAccountTypeColumn('Utilization', '${utilization.toStringAsFixed(1)}%', isMobile),
                    ],
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAccountTypeColumn('Budget', 'KES ${budget.toStringAsFixed(2)}', isMobile),
                  _buildAccountTypeColumn('Spent', 'KES ${spent.toStringAsFixed(2)}', isMobile),
                  _buildAccountTypeColumn('Utilization', '${utilization.toStringAsFixed(1)}%', isMobile),
                ],
              ),
            SizedBox(height: isMobile ? 8 : 12),
            LinearProgressIndicator(
              value: utilization / 100,
              backgroundColor: Theme.of(context).dividerColor,
              color: utilization > 80 ? Colors.red : Colors.green,
              minHeight: isMobile ? 6 : 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeRow(String label, String value, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Theme.of(context).hintColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeColumn(String label, String value, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: Theme.of(context).hintColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyPerformanceState(bool isMobile) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined,
                  size: isMobile ? 60 : 80,
                  color: Theme.of(context).hintColor),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'No Performance Data',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
                child: Text(
                  'Performance data will appear here once budgets are created',
                  style: TextStyle(color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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
}