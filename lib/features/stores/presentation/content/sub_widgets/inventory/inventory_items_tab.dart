import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/inventory/inventory_item_model.dart';
import '../../../../providers/inventory_item_provider.dart';
import 'inventory_item_card.dart';
import 'add_edit_item_dialog.dart';

class InventoryItemsTab extends ConsumerStatefulWidget {
  const InventoryItemsTab({super.key});

  @override
  ConsumerState<InventoryItemsTab> createState() => _InventoryItemsTabState();
}

class _InventoryItemsTabState extends ConsumerState<InventoryItemsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(inventoryItemProvider.notifier).getInventoryItems();
  }

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ItemDetailsSheet(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryItemProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Actions
          _buildHeaderActions(inventoryState),

          const SizedBox(height: 16),

          // Loading State
          if (inventoryState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // Error State
          else if (inventoryState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inventoryState.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // Empty State
          else if (inventoryState.items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No inventory items found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first inventory item to get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditItemDialog(null),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Item'),
                      ),
                    ],
                  ),
                ),
              )
            // Data State
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: inventoryState.items.length,
                    itemBuilder: (context, index) {
                      final item = inventoryState.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InventoryItemCard(
                          item: item,
                          onTap: () => _showItemDetails(item),
                          onEdit: () => _showAddEditItemDialog(item),
                          onDelete: () => _showDeleteDialog(item),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(InventoryItemState state) {
    return Row(
      children: [
        // Sort Dropdown
        DropdownButton<String>(
          value: 'name',
          items: const [
            DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
            DropdownMenuItem(value: 'code', child: Text('Sort by Code')),
            DropdownMenuItem(value: 'stock', child: Text('Sort by Stock')),
            DropdownMenuItem(value: 'value', child: Text('Sort by Value')),
          ],
          onChanged: (value) {
            // Implement sort logic
          },
        ),

        const Spacer(),

        // View Toggle
        ToggleButtons(
          isSelected: const [true, false],
          onPressed: (index) {
            // Toggle between grid and list view
          },
          children: const [
            Icon(Icons.view_list),
            Icon(Icons.grid_view),
          ],
        ),

        const SizedBox(width: 12),

        // Add Button
        FloatingActionButton(
          onPressed: () => _showAddEditItemDialog(null),
          mini: true,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _showAddEditItemDialog(InventoryItem? item) {
    showDialog(
      context: context,
      builder: (context) => AddEditItemDialog(
        item: item,
        onSaved: () => _loadData(),
      ),
    );
  }

  void _showDeleteDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(inventoryItemProvider.notifier).deleteInventoryItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.itemName} deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting item: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Item Details Bottom Sheet
class ItemDetailsSheet extends ConsumerWidget {
  final InventoryItem item;

  const ItemDetailsSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.itemName),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Specifications'),
              Tab(text: 'Location'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildSpecificationsTab(),
            _buildLocationTab(),
            _buildHistoryTab(),
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
          // Basic Info
          _buildInfoCard('Basic Information', [
            _buildInfoRow('Item Code', item.itemCode),
            _buildInfoRow('Category', item.category),
            _buildInfoRow('Item Type', item.itemType),
            _buildInfoRow('Unit of Measure', item.unitOfMeasure),
          ]),

          const SizedBox(height: 16),

          // Stock Information
          _buildInfoCard('Stock Information', [
            _buildInfoRow('Current Stock', '${item.currentStock} ${item.unitOfMeasure}'),
            _buildInfoRow('Minimum Stock', '${item.minimumStock} ${item.unitOfMeasure}'),
            _buildInfoRow('Maximum Stock', '${item.maximumStock} ${item.unitOfMeasure}'),
            _buildInfoRow('Reorder Point', '${item.reorderPoint} ${item.unitOfMeasure}'),
            _buildInfoRow('Status', _getStockStatus(item)),
          ]),

          const SizedBox(height: 16),

          // Pricing
          _buildInfoCard('Pricing', [
            _buildInfoRow('Cost Price', 'KES ${item.costPrice.toStringAsFixed(2)}'),
            _buildInfoRow('Selling Price', 'KES ${item.sellingPrice.toStringAsFixed(2)}'),
            _buildInfoRow('Average Cost', 'KES ${item.averageCost.toStringAsFixed(2)}'),
            _buildInfoRow('Stock Value', 'KES ${item.stockValue.toStringAsFixed(2)}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.specifications.isNotEmpty) ...[
            _buildInfoCard('Specifications', [
              for (final spec in item.specifications)
                _buildInfoRow(spec.parameter, '${spec.value} ${spec.unit}'),
            ]),
            const SizedBox(height: 16),
          ],

          if (item.technicalDetails.isNotEmpty) ...[
            _buildInfoCard('Technical Details', [
              for (final detail in item.technicalDetails)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.aspect,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(detail.description),
                    if (detail.standards.isNotEmpty)
                      Text(
                        'Standards: ${detail.standards.join(', ')}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    const Divider(),
                  ],
                ),
            ]),
            const SizedBox(height: 16),
          ],

          if (item.qualityRequirements.isNotEmpty) ...[
            _buildInfoCard('Quality Requirements', [
              for (final req in item.qualityRequirements)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.requirement,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Standard: ${req.standard}'),
                    Text('Test Method: ${req.testMethod}'),
                    Text('Frequency: ${req.frequency}'),
                    const Divider(),
                  ],
                ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Storage Location', [
            _buildInfoRow('Warehouse', item.storageLocation.warehouse),
            _buildInfoRow('Zone', item.storageLocation.zone),
            _buildInfoRow('Rack', item.storageLocation.rack),
            _buildInfoRow('Shelf', item.storageLocation.shelf),
            _buildInfoRow('Position', item.storageLocation.position),
            _buildInfoRow('Bin Location', item.binLocation),
          ]),

          const SizedBox(height: 16),

          if (item.storageRequirements.isNotEmpty) ...[
            _buildInfoCard('Storage Requirements', [
              for (final req in item.storageRequirements)
                Row(
                  children: [
                    Expanded(child: Text(req.requirement)),
                    Text(req.value),
                    if (req.critical)
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                  ],
                ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text('Movement history will be displayed here'),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStockStatus(InventoryItem item) {
    if (item.isOutOfStock) return 'Out of Stock';
    if (item.isCriticalStock) return 'Critical';
    if (item.isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}