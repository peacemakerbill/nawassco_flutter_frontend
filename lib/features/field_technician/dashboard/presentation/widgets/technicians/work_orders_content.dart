import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nawassco/features/field_technician/dashboard/presentation/widgets/sub_widgets/work_order/work_order_card.dart';
import '../../../providers/work_order_notifier.dart';
import '../../../providers/work_order_provider.dart';
import '../sub_widgets/work_order/work_order_details_screen.dart';
import '../sub_widgets/work_order/work_order_filters.dart';
import '../sub_widgets/work_order/work_order_form_screen.dart';
import '../sub_widgets/work_order/work_order_stats.dart';

class WorkOrdersContent extends ConsumerStatefulWidget {
  const WorkOrdersContent({super.key});

  @override
  ConsumerState<WorkOrdersContent> createState() => _WorkOrdersContentState();
}

class _WorkOrdersContentState extends ConsumerState<WorkOrdersContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Navigation states
  Widget _currentScreen = const _WorkOrdersListScreen();
  final List<Widget> _screenStack = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
    // Initialize with main list screen
    _screenStack.add(_currentScreen);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workOrderNotifierProvider).getWorkOrders();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _loadMore() {
    ref.read(workOrderNotifierProvider).loadMoreWorkOrders();
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    ref.read(workOrderNotifierProvider).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    ref.read(workOrderNotifierProvider).getWorkOrders();
  }

  // Navigation methods
  void _showWorkOrderDetails(String workOrderId) {
    final detailsScreen = WorkOrderDetailsScreen(
      workOrderId: workOrderId,
      onBack: _popScreen,
      onEdit: () => _showWorkOrderForm(workOrderId),
    );
    _pushScreen(detailsScreen);
  }

  void _showWorkOrderForm([String? workOrderId]) {
    final formScreen = WorkOrderFormScreen(
      workOrderId: workOrderId,
      onBack: _popScreen,
      onSave: () {
        _popScreen();
        ref.read(workOrderNotifierProvider).refreshWorkOrders();
      },
    );
    _pushScreen(formScreen);
  }

  void _pushScreen(Widget screen) {
    setState(() {
      _screenStack.add(screen);
      _currentScreen = screen;
    });
  }

  void _popScreen() {
    if (_screenStack.length > 1) {
      setState(() {
        _screenStack.removeLast();
        _currentScreen = _screenStack.last;
      });
    }
  }

  void _goBackToMainScreen() {
    setState(() {
      _screenStack.clear();
      _screenStack.add(const _WorkOrdersListScreen());
      _currentScreen = _screenStack.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentScreen;
  }
}

// Main Work Orders List Screen (now internal)
class _WorkOrdersListScreen extends ConsumerStatefulWidget {
  const _WorkOrdersListScreen();

  @override
  ConsumerState<_WorkOrdersListScreen> createState() => _WorkOrdersListScreenState();
}

class _WorkOrdersListScreenState extends ConsumerState<_WorkOrdersListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(workOrderNotifierProvider).loadMoreWorkOrders();
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    ref.read(workOrderNotifierProvider).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    ref.read(workOrderNotifierProvider).getWorkOrders();
  }

  // Get parent state to access navigation methods
  _WorkOrdersContentState? _getParentState() {
    final context = this.context;
    var parent = context.findAncestorStateOfType<_WorkOrdersContentState>();
    return parent;
  }

  void _showWorkOrderDetails(String workOrderId) {
    _getParentState()?._showWorkOrderDetails(workOrderId);
  }

  void _createWorkOrder() {
    _getParentState()?._showWorkOrderForm();
  }

  @override
  Widget build(BuildContext context) {
    final workOrderState = ref.watch(workOrderProvider);
    final workOrderNotifier = ref.read(workOrderNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Work Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Search Bar
                    Container(
                      width: 300,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search work orders...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: _handleSearch,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _clearSearch,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and track all field service work orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Statistics Section
          const WorkOrderStats(),

          // Filters Section
          WorkOrderFilters(
            onFiltersChanged: (filters) {
              workOrderNotifier.updateFilters(filters);
            },
          ),

          // Work Orders List
          Expanded(
            child: _buildWorkOrdersList(workOrderState),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createWorkOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Work Order'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWorkOrdersList(WorkOrderState state) {
    if (state.isLoading && state.workOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.workOrders.isEmpty) {
      return _buildErrorState(state.error!, ref.read(workOrderNotifierProvider));
    }

    if (state.workOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(workOrderNotifierProvider).refreshWorkOrders();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.workOrders.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.workOrders.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final workOrder = state.workOrders[index];
          return WorkOrderCard(
            workOrder: workOrder,
            onTap: () {
              _showWorkOrderDetails(workOrder.id);
            },
            onStatusChange: (newStatus) {
              ref.read(workOrderNotifierProvider).updateWorkOrderStatus(
                workOrder.id,
                newStatus,
                null, // technicianId can be null or pass actual technician ID
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error, WorkOrderNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => notifier.getWorkOrders(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching
                ? 'No work orders found for your search'
                : 'No Work Orders',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Try adjusting your search criteria'
                : 'Get started by creating your first work order',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          if (!_isSearching)
            ElevatedButton(
              onPressed: _createWorkOrder,
              child: const Text('Create Work Order'),
            ),
        ],
      ),
    );
  }
}