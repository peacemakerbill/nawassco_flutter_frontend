import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/field_inventory.dart';

class FieldInventoryDetailsView extends StatelessWidget {
  final FieldInventory item;
  final VoidCallback onEdit;
  final VoidCallback onBack;
  final VoidCallback onStockUpdate;
  final VoidCallback onUsageRecord;
  final VoidCallback onDelete;

  const FieldInventoryDetailsView({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onBack,
    required this.onStockUpdate,
    required this.onUsageRecord,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = InventoryStatusEnum.values.firstWhere(
          (s) => s.name == item.status,
      orElse: () => InventoryStatusEnum.in_stock,
    );

    final category = InventoryCategoryEnum.values.firstWhere(
          (c) => c.name == item.category,
      orElse: () => InventoryCategoryEnum.general_supplies,
    );

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
        title: const Text('Inventory Details'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.itemCode,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: status.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        status.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 20),

            // Main Details in Tabs
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'Overview'),
                        Tab(text: 'Stock Info'),
                        Tab(text: 'Supplier'),
                        Tab(text: 'Specs'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildOverviewTab(currencyFormat),
                        _buildStockTab(currencyFormat, context),
                        _buildSupplierTab(),
                        _buildSpecificationsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Usage Statistics
            _buildUsageStatistics(currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onStockUpdate,
            icon: const Icon(Icons.inventory_2),
            label: const Text('Update Stock'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUsageRecord,
            icon: const Icon(Icons.history),
            label: const Text('Record Usage'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Description', item.description),
            const SizedBox(height: 12),
            _buildDetailRow('Category', item.category),
            const SizedBox(height: 12),
            _buildDetailRow('Subcategory', item.subcategory),
            const SizedBox(height: 12),
            _buildDetailRow('Unit', item.unit),
            const SizedBox(height: 12),
            _buildDetailRow('Unit Cost', currencyFormat.format(item.unitCost)),
            const SizedBox(height: 12),
            _buildDetailRow('Storage Location', item.storageLocation),
            const SizedBox(height: 12),
            if (item.shelfNumber != null)
              _buildDetailRow('Shelf Number', item.shelfNumber!),
            if (item.binNumber != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Bin Number', item.binNumber!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockTab(NumberFormat currencyFormat, BuildContext context) {
    final stockValue = item.currentStock * item.unitCost;
    final stockPercentage = (item.currentStock / item.maximumStock) * 100;
    final reorderPercentage = (item.reorderPoint / item.maximumStock) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Gauge
            Container(
              height: 120,
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Stock level
                  Positioned(
                    left: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: (stockPercentage / 100) * MediaQuery.of(context).size.width - 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStockColor(stockPercentage),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Reorder point marker
                  if (item.reorderPoint > 0)
                    Positioned(
                      left: (reorderPercentage / 100) * MediaQuery.of(context).size.width - 40 - 1,
                      child: Container(
                        width: 2,
                        height: 20,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stock Metrics
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  'Current Stock',
                  '${item.currentStock} ${item.unit}',
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Stock Value',
                  currencyFormat.format(stockValue),
                  Colors.green,
                ),
                _buildMetricCard(
                  'Minimum Stock',
                  '${item.minimumStock} ${item.unit}',
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Maximum Stock',
                  '${item.maximumStock} ${item.unit}',
                  Colors.purple,
                ),
                _buildMetricCard(
                  'Reorder Point',
                  '${item.reorderPoint} ${item.unit}',
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Reorder Quantity',
                  '${item.reorderQuantity} ${item.unit}',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.business, color: Colors.blue),
              title: Text(
                item.supplier.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item.supplier.contactPerson),
            ),
            const Divider(),
            _buildDetailRow('Contact Person', item.supplier.contactPerson),
            const SizedBox(height: 12),
            _buildDetailRow('Phone', item.supplier.phone),
            const SizedBox(height: 12),
            _buildDetailRow('Email', item.supplier.email),
            const SizedBox(height: 12),
            _buildDetailRow('Lead Time', '${item.supplier.leadTime} days'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Launch phone
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Launch email
                  },
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: item.specifications.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No specifications added',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: item.specifications.length,
          itemBuilder: (context, index) {
            final spec = item.specifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.tune, color: Colors.blue),
                title: Text(
                  spec.parameter,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Value: ${spec.value} ${spec.unit}'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUsageStatistics(NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  'Total Used',
                  '${item.totalUsed} ${item.unit}',
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Usage Rate',
                  '${item.usageRate.toStringAsFixed(1)}%',
                  Colors.green,
                ),
                _buildMetricCard(
                  'Last Used',
                  item.lastUsed != null
                      ? DateFormat('MMM dd, yyyy').format(item.lastUsed!)
                      : 'Never',
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Total Value Used',
                  currencyFormat.format(item.totalUsed * item.unitCost),
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.lastUsed != null)
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(item.updatedAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(double percentage) {
    if (percentage <= 15) return Colors.red;
    if (percentage <= 30) return Colors.orange;
    if (percentage <= 60) return Colors.yellow.shade700;
    return Colors.green;
  }
}