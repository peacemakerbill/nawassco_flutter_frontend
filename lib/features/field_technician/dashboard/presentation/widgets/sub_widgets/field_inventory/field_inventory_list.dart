import 'package:flutter/material.dart';
import '../../../../models/field_inventory.dart';

class FieldInventoryListView extends StatefulWidget {
  final List<FieldInventory> items;
  final bool isLoading;
  final Function(FieldInventory) onItemTap;
  final Function(FieldInventory) onEditTap;
  final Function(FieldInventory) onDeleteTap;
  final Function(FieldInventory) onStockUpdate;
  final Function(FieldInventory) onUsageRecord;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(String?) onFilterByCategory;
  final Function(String?) onFilterByStatus;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateNew;
  final VoidCallback onViewMetrics;
  final bool isCompact;

  const FieldInventoryListView({
    super.key,
    required this.items,
    required this.isLoading,
    required this.onItemTap,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onStockUpdate,
    required this.onUsageRecord,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterByCategory,
    required this.onFilterByStatus,
    required this.onClearFilters,
    required this.onCreateNew,
    required this.onViewMetrics,
    this.isCompact = false,
  });

  @override
  State<FieldInventoryListView> createState() => _FieldInventoryListViewState();
}

class _FieldInventoryListViewState extends State<FieldInventoryListView> {
  String? _selectedCategory;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Field Inventory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  if (!widget.isCompact) ...[
                    IconButton(
                      onPressed: widget.onViewMetrics,
                      icon: const Icon(Icons.analytics, color: Colors.blue),
                      tooltip: 'View Analytics',
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: widget.onCreateNew,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search
              TextField(
                controller: widget.searchController,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: widget.searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            widget.searchController.clear();
                            widget.onSearchChanged('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Categories')),
                        ...InventoryCategoryEnum.values.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Row(
                              children: [
                                Icon(category.icon,
                                    size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(category.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                        widget.onFilterByCategory(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Status')),
                        ...InventoryStatusEnum.values.map((status) {
                          return DropdownMenuItem(
                            value: status.name,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: status.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                        widget.onFilterByStatus(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                      });
                      widget.onClearFilters();
                    },
                    icon: const Icon(Icons.filter_alt_off),
                    tooltip: 'Clear filters',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Stats Bar
        if (!widget.isCompact) _buildStatsBar(),
        // List
        Expanded(
          child: widget.isLoading && widget.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : widget.items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No inventory items found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first inventory item to get started',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          widget.items.length + (widget.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= widget.items.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final item = widget.items[index];
                        return InventoryListItem(
                          item: item,
                          onTap: () => widget.onItemTap(item),
                          onEdit: () => widget.onEditTap(item),
                          onDelete: () => widget.onDeleteTap(item),
                          onStockUpdate: () => widget.onStockUpdate(item),
                          onUsageRecord: () => widget.onUsageRecord(item),
                          isCompact: widget.isCompact,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final inStock =
        widget.items.where((item) => item.status == 'in_stock').length;
    final lowStock =
        widget.items.where((item) => item.status == 'low_stock').length;
    final outOfStock =
        widget.items.where((item) => item.status == 'out_of_stock').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildStatChip('Total Items', '${widget.items.length}', Colors.blue),
          const SizedBox(width: 12),
          _buildStatChip('In Stock', '$inStock', Colors.green),
          const SizedBox(width: 12),
          _buildStatChip('Low Stock', '$lowStock', Colors.orange),
          const SizedBox(width: 12),
          _buildStatChip('Out of Stock', '$outOfStock', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryListItem extends StatelessWidget {
  final FieldInventory item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStockUpdate;
  final VoidCallback onUsageRecord;
  final bool isCompact;

  const InventoryListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStockUpdate,
    required this.onUsageRecord,
    this.isCompact = false,
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.itemCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStockInfo(),
                        const Spacer(),
                        if (!isCompact) _buildActionButtons(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${item.currentStock} ${item.unit}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: item.currentStock <= item.reorderPoint
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            Text(
              'Reorder: ${item.reorderPoint} ${item.unit}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Cost: KES ${item.unitCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Value: KES ${(item.currentStock * item.unitCost).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          onPressed: onStockUpdate,
          icon: const Icon(Icons.inventory_2, size: 20),
          tooltip: 'Update Stock',
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          onPressed: onUsageRecord,
          icon: const Icon(Icons.history, size: 20),
          tooltip: 'Record Usage',
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
          tooltip: 'Edit',
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          tooltip: 'Delete',
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }
}
