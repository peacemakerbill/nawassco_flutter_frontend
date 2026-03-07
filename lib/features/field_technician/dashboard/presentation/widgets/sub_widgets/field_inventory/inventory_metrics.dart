import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../../models/field_inventory.dart';

class InventoryMetricsView extends StatelessWidget {
  final FieldInventoryMetrics? metrics;
  final List<FieldInventory> lowStockItems;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const InventoryMetricsView({
    super.key,
    required this.metrics,
    required this.lowStockItems,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'KES ',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Inventory Analytics'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(currencyFormat),
            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(),
            const SizedBox(height: 24),

            // Low Stock Alerts
            _buildLowStockAlerts(currencyFormat),
            const SizedBox(height: 24),

            // Category Breakdown
            if (metrics?.categorySummary != null)
              _buildCategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat currencyFormat) {
    final totalValue = metrics?.totalValue.totalInventoryValue ?? 0;
    final totalItems = metrics?.totalValue.totalItems ?? 0;
    final itemsInStock = metrics?.totalValue.itemsInStock ?? 0;
    final lowStockCount = metrics?.categorySummary.fold<int>(
        0, (sum, item) => sum + item.lowStockItems
    ) ?? 0;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Inventory Value',
          currencyFormat.format(totalValue),
          Colors.blue,
          Icons.attach_money,
        ),
        _buildMetricCard(
          'Total Items',
          '$totalItems',
          Colors.green,
          Icons.inventory_2,
        ),
        _buildMetricCard(
          'Items in Stock',
          '$itemsInStock',
          Colors.teal,
          Icons.check_circle,
        ),
        _buildMetricCard(
          'Low Stock Items',
          '$lowStockCount',
          Colors.orange,
          Icons.warning,
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: SfCircularChart(
            title: ChartTitle(text: 'Stock Status Distribution'),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
            ),
            series: <CircularSeries>[
              PieSeries<StatusSummary, String>(
                dataSource: metrics?.statusSummary ?? [],
                xValueMapper: (StatusSummary data, _) => data.status,
                yValueMapper: (StatusSummary data, _) => data.count.toDouble(),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                enableTooltip: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockAlerts(NumberFormat currencyFormat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '${lowStockItems.length} items',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lowStockItems.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'All items are sufficiently stocked',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...lowStockItems.map((item) {
                final needed = item.reorderQuantity;
                final cost = needed * item.unitCost;
                final stockPercent = (item.currentStock / item.reorderPoint) * 100;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning, color: Colors.orange),
                    ),
                    title: Text(
                      item.itemName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Stock: ${item.currentStock}/${item.reorderPoint} ${item.unit}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                        LinearProgressIndicator(
                          value: stockPercent / 100,
                          backgroundColor: Colors.orange.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Need: $needed ${item.unit}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currencyFormat.format(cost),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...metrics!.categorySummary.map((category) {
              final catEnum = InventoryCategoryEnum.values.firstWhere(
                    (c) => c.name == category.category,
                orElse: () => InventoryCategoryEnum.general_supplies,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(catEnum.icon, color: Colors.blue),
                  title: Text(catEnum.displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${category.totalItems} items • '
                            '${category.lowStockItems} low stock',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KES ${category.totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (category.lowStockItems > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${category.lowStockItems} alert${category.lowStockItems > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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