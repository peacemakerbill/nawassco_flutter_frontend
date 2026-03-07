import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_item_provider.dart';
import '../../providers/inventory_category_provider.dart';
import 'sub_widgets/inventory/categories_tab.dart';
import 'sub_widgets/inventory/inventory_items_tab.dart';
import 'sub_widgets/inventory/stock_take_tab.dart';


class InventoryContent extends ConsumerStatefulWidget {
  const InventoryContent({super.key});

  @override
  ConsumerState<InventoryContent> createState() => _InventoryContentState();
}

class _InventoryContentState extends ConsumerState<InventoryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryItemProvider.notifier).getInventoryItems();
      ref.read(inventoryCategoryProvider.notifier).getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryItemProvider);
    final categoryState = ref.watch(inventoryCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context),
            tooltip: 'Add New Item',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview Cards
          _buildStatsOverview(inventoryState, categoryState),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1E3A8A),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1E3A8A),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'All Items'),
                Tab(text: 'Categories'),
                Tab(text: 'Stock Take'),
                // Tab(text: 'Reports'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                InventoryItemsTab(),
                CategoriesTab(),
                StockTakeTab(),
                // ReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(InventoryItemState inventoryState, InventoryCategoryState categoryState) {
    final totalItems = inventoryState.items.length;
    final lowStockCount = inventoryState.items.where((item) => item.isLowStock).length;
    final outOfStockCount = inventoryState.items.where((item) => item.isOutOfStock).length;
    final totalValue = inventoryState.items.fold(0.0, (sum, item) => sum + item.stockValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items by code or name...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilterDialog(context),
                ),
              ),
              onChanged: (value) {
                ref.read(inventoryItemProvider.notifier).getInventoryItems(search: value);
              },
            ),
          ),

          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard(
                'Total Items',
                totalItems.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              _buildStatCard(
                'Low Stock',
                lowStockCount.toString(),
                Icons.warning,
                Colors.orange,
              ),
              _buildStatCard(
                'Out of Stock',
                outOfStockCount.toString(),
                Icons.error,
                Colors.red,
              ),
              _buildStatCard(
                'Total Value',
                'KES ${totalValue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (title.contains('Stock'))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Alert',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Inventory Item'),
        content: const Text('Choose what you want to add:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add item screen
            },
            child: const Text('Inventory Item'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add category screen
            },
            child: const Text('Category'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Filter Dialog Widget
class FilterDialog extends ConsumerWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Filter Inventory'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Add filter options here
            const Text('Filter options will be implemented here'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            Navigator.pop(context);
          },
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}