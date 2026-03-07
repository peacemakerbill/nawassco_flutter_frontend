import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/field_inventory.dart';
import '../../../providers/field_inventory_provider.dart';
import '../sub_widgets/field_inventory/field_inventory_details.dart';
import '../sub_widgets/field_inventory/field_inventory_form.dart';
import '../sub_widgets/field_inventory/field_inventory_list.dart';
import '../sub_widgets/field_inventory/inventory_metrics.dart';
import '../sub_widgets/field_inventory/stock_management_dialog.dart';
import '../sub_widgets/field_inventory/usage_record_dialog.dart';

enum FieldInventoryView {
  list,
  details,
  create,
  edit,
  metrics,
}

class FieldInventoryContent extends ConsumerStatefulWidget {
  const FieldInventoryContent({super.key});

  @override
  ConsumerState<FieldInventoryContent> createState() =>
      _FieldInventoryContentState();
}

class _FieldInventoryContentState extends ConsumerState<FieldInventoryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FieldInventoryView _currentView = FieldInventoryView.list;
  FieldInventory? _selectedItemForEdit;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldInventoryProvider.notifier).fetchInventoryItems();
      ref.read(fieldInventoryProvider.notifier).fetchMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = ref.read(fieldInventoryProvider);
      if (state.currentPage < state.totalPages) {
        ref.read(fieldInventoryProvider.notifier).fetchInventoryItems(
              page: state.currentPage + 1,
              loadMore: true,
            );
      }
    }
  }

  void _showCreateForm() {
    setState(() {
      _currentView = FieldInventoryView.create;
      _selectedItemForEdit = null;
    });
  }

  void _showEditForm(FieldInventory item) {
    setState(() {
      _currentView = FieldInventoryView.edit;
      _selectedItemForEdit = item;
    });
  }

  void _showDetails(FieldInventory item) {
    setState(() {
      _currentView = FieldInventoryView.details;
      ref.read(fieldInventoryProvider.notifier).getInventoryItemById(item.id);
    });
  }

  void _showMetrics() {
    setState(() {
      _currentView = FieldInventoryView.metrics;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentView = FieldInventoryView.list;
      _selectedItemForEdit = null;
      ref.read(fieldInventoryProvider.notifier).clearSelectedItem();
    });
  }

  Widget _buildCurrentView() {
    final state = ref.watch(fieldInventoryProvider);

    switch (_currentView) {
      case FieldInventoryView.list:
        return FieldInventoryListView(
          items: state.filteredItems,
          isLoading: state.isLoading,
          onItemTap: _showDetails,
          onEditTap: _showEditForm,
          onDeleteTap: (item) => _showDeleteConfirmation(item, context),
          onStockUpdate: (item) => _showStockDialog(item, context),
          onUsageRecord: (item) => _showUsageDialog(item, context),
          searchController: _searchController,
          onSearchChanged: (value) =>
              ref.read(fieldInventoryProvider.notifier).searchInventory(value),
          onFilterByCategory: (category) => ref
              .read(fieldInventoryProvider.notifier)
              .filterByCategory(category),
          onFilterByStatus: (status) =>
              ref.read(fieldInventoryProvider.notifier).filterByStatus(status),
          onClearFilters: () =>
              ref.read(fieldInventoryProvider.notifier).clearFilters(),
          onCreateNew: _showCreateForm,
          onViewMetrics: _showMetrics,
        );
      case FieldInventoryView.details:
        if (state.selectedItem != null) {
          return FieldInventoryDetailsView(
            item: state.selectedItem!,
            onEdit: () => _showEditForm(state.selectedItem!),
            onBack: _navigateBack,
            onStockUpdate: () => _showStockDialog(state.selectedItem!, context),
            onUsageRecord: () => _showUsageDialog(state.selectedItem!, context),
            onDelete: () =>
                _showDeleteConfirmation(state.selectedItem!, context),
          );
        }
        return const Center(child: CircularProgressIndicator());
      case FieldInventoryView.create:
        return FieldInventoryFormView(
          mode: FormMode.create,
          onSave: (data) async {
            final success = await ref
                .read(fieldInventoryProvider.notifier)
                .createInventoryItem(data);
            if (success) _navigateBack();
          },
          onCancel: _navigateBack,
        );
      case FieldInventoryView.edit:
        return FieldInventoryFormView(
          mode: FormMode.edit,
          initialData: _selectedItemForEdit,
          onSave: (data) async {
            final success = await ref
                .read(fieldInventoryProvider.notifier)
                .updateInventoryItem(
                  _selectedItemForEdit!.id,
                  data,
                );
            if (success) _navigateBack();
          },
          onCancel: _navigateBack,
        );
      case FieldInventoryView.metrics:
        return InventoryMetricsView(
          metrics: state.metrics,
          lowStockItems: state.lowStockItems,
          onBack: _navigateBack,
          onRefresh: () {
            ref.read(fieldInventoryProvider.notifier).fetchMetrics();
            ref.read(fieldInventoryProvider.notifier).fetchLowStockItems();
          },
        );
    }
  }

  Future<void> _showStockDialog(
      FieldInventory item, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StockManagementDialog(
        item: item,
        onUpdate: (quantity, action) async {
          final success =
              await ref.read(fieldInventoryProvider.notifier).updateStockLevel(
                    item.id,
                    quantity,
                    action,
                  );
          if (success && mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showUsageDialog(
      FieldInventory item, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => UsageRecordDialog(
        item: item,
        onRecord: (quantity, workOrderId) async {
          final success =
              await ref.read(fieldInventoryProvider.notifier).recordUsage(
                    item.id,
                    quantity,
                    workOrderId: workOrderId,
                  );
          if (success && mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      FieldInventory item, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Inventory Item'),
        content: Text(
            'Are you sure you want to delete "${item.itemName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(fieldInventoryProvider.notifier)
                  .deleteInventoryItem(item.id);
              if (success && mounted) {
                Navigator.pop(context);
                if (_currentView == FieldInventoryView.details) {
                  _navigateBack();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldInventoryProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1024;

          return isWide ? _buildWideLayout() : _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - List
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: FieldInventoryListView(
              items: ref.watch(fieldInventoryProvider).filteredItems,
              isLoading: ref.watch(fieldInventoryProvider).isLoading,
              onItemTap: _showDetails,
              onEditTap: _showEditForm,
              onDeleteTap: (item) => _showDeleteConfirmation(item, context),
              onStockUpdate: (item) => _showStockDialog(item, context),
              onUsageRecord: (item) => _showUsageDialog(item, context),
              searchController: _searchController,
              onSearchChanged: (value) => ref
                  .read(fieldInventoryProvider.notifier)
                  .searchInventory(value),
              onFilterByCategory: (category) => ref
                  .read(fieldInventoryProvider.notifier)
                  .filterByCategory(category),
              onFilterByStatus: (status) => ref
                  .read(fieldInventoryProvider.notifier)
                  .filterByStatus(status),
              onClearFilters: () =>
                  ref.read(fieldInventoryProvider.notifier).clearFilters(),
              onCreateNew: _showCreateForm,
              onViewMetrics: _showMetrics,
              isCompact: true,
            ),
          ),
        ),
        // Right panel - Details/Form
        Expanded(
          flex: 2,
          child: _buildCurrentView(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildCurrentView();
  }
}
