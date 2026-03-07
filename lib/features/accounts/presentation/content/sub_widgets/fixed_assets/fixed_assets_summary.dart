import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/fixed_asset_model.dart';
import '../../../../providers/fixed_asset_provider.dart';

class FixedAssetsSummaryWidget extends ConsumerStatefulWidget {
  const FixedAssetsSummaryWidget({super.key});

  @override
  ConsumerState<FixedAssetsSummaryWidget> createState() =>
      _FixedAssetsSummaryWidgetState();
}

class _FixedAssetsSummaryWidgetState
    extends ConsumerState<FixedAssetsSummaryWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch summary data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixedAssetsProvider.notifier).fetchAssetsSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsProvider);

    if (state.summary == null && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No summary data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.read(fixedAssetsProvider.notifier).fetchAssetsSummary(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final summary = state.summary!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          // Key Metrics
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final crossAxisCount = isMobile ? 2 : 4;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMetricCard(
                      'Total Assets',
                      summary.totalAssets.toString(),
                      Icons.business_center,
                      Colors.blue,
                    ),
                    _buildMetricCard(
                      'Total Acquisition Cost',
                      _formatCurrency(summary.totalAcquisitionCost),
                      Icons.attach_money,
                      Colors.green,
                    ),
                    _buildMetricCard(
                      'Total Book Value',
                      _formatCurrency(summary.totalBookValue),
                      Icons.account_balance_wallet,
                      Colors.orange,
                    ),
                    _buildMetricCard(
                      'Total Depreciation',
                      _formatCurrency(summary.totalDepreciation),
                      Icons.trending_down,
                      Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Charts and Breakdowns
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildCategoryBreakdown(summary),
                      const SizedBox(height: 16),
                      _buildStatusBreakdown(summary),
                      const SizedBox(height: 16),
                      _buildDepartmentBreakdown(summary),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCategoryBreakdown(summary)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusBreakdown(summary)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDepartmentBreakdown(summary)),
                    ],
                  );
                }
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Depreciation Rate
          SliverToBoxAdapter(
            child: _buildDepreciationRateCard(summary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                const Icon(Icons.more_vert, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(FixedAssetsSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, size: 18, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text(
                  'Assets by Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildBreakdownItems(summary.byCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(FixedAssetsSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, size: 18, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text(
                  'Assets by Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildBreakdownItems(summary.byStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentBreakdown(FixedAssetsSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.business, size: 18, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text(
                  'Assets by Department',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildBreakdownItems(summary.byDepartment),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBreakdownItems(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return [
        const Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      ];
    }

    final items = data.entries.toList();
    items.sort(
        (a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));

    return items.take(5).map((entry) {
      final count = entry.value['count'] as int;
      final value = (entry.value['acquisitionCost'] as num).toDouble();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count assets • ${_formatCurrency(value)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: count /
                    (data.values.fold(
                        0, (sum, item) => sum + (item['count'] as int)) as num),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDepreciationRateCard(FixedAssetsSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_down, size: 18, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text(
                  'Depreciation Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.depreciationRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Overall Depreciation Rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrency(summary.totalDepreciation),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Depreciation',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: summary.depreciationRate / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.depreciationRate > 50 ? Colors.red : Colors.orange,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  '100%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'KES ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'KES ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'KES ${amount.toStringAsFixed(2)}';
  }
}
