import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/work_order.dart';
import 'work_order_provider.dart';

final workOrderNotifierProvider = Provider<WorkOrderNotifier>((ref) {
  return WorkOrderNotifier(ref);
});

class WorkOrderNotifier {
  final Ref _ref;

  WorkOrderNotifier(this._ref);

  // Get the provider instance
  WorkOrderProvider get _provider => _ref.read(workOrderProvider.notifier);

  // Get the current state
  WorkOrderState get _state => _ref.read(workOrderProvider);

  // ============ SIMPLE NAVIGATION HELPERS ============

  /// Get work order by ID
  WorkOrder? getWorkOrderById(String id) {
    try {
      return _state.workOrders.firstWhere(
            (wo) => wo.id == id,
      );
    } catch (e) {
      // Check if it's the selected work order
      if (_state.selectedWorkOrder?.id == id) {
        return _state.selectedWorkOrder!;
      }
      return null;
    }
  }

  /// Check if work order exists
  bool workOrderExists(String id) {
    return getWorkOrderById(id) != null;
  }

  // ============ SIMPLE FILTERING ============

  /// Get work orders by status
  List<WorkOrder> getWorkOrdersByStatus(WorkOrderStatus status) {
    return _state.workOrders.where((wo) => wo.status == status).toList();
  }

  /// Get overdue work orders
  List<WorkOrder> getOverdueWorkOrders() {
    return _state.workOrders.where((wo) => wo.isOverdue).toList();
  }

  /// Get today's work orders
  List<WorkOrder> getTodayWorkOrders() {
    final now = DateTime.now();
    return _state.workOrders
        .where((wo) =>
    wo.scheduledDate.day == now.day &&
        wo.scheduledDate.month == now.month &&
        wo.scheduledDate.year == now.year)
        .toList();
  }

  // ============ SIMPLE STATISTICS ============

  /// Get completion rate
  double getCompletionRate() {
    if (_state.workOrders.isEmpty) return 0.0;
    final completed = _state.workOrders
        .where((wo) => wo.status == WorkOrderStatus.completed)
        .length;
    return (completed / _state.workOrders.length) * 100;
  }

  /// Get total count
  int getTotalCount() {
    return _state.workOrders.length;
  }

  /// Get completed count
  int getCompletedCount() {
    return _state.workOrders
        .where((wo) => wo.status == WorkOrderStatus.completed)
        .length;
  }

  /// Get in progress count
  int getInProgressCount() {
    return _state.workOrders
        .where((wo) => wo.status == WorkOrderStatus.inProgress)
        .length;
  }

  /// Get overdue count
  int getOverdueCount() {
    return _state.workOrders.where((wo) => wo.isOverdue).length;
  }

  // ============ SIMPLE SEARCH ============

  /// Search work orders
  List<WorkOrder> searchWorkOrders(String query) {
    if (query.isEmpty) return _state.workOrders;

    final lowercaseQuery = query.toLowerCase();
    return _state.workOrders
        .where((wo) =>
    wo.workOrderNumber.toLowerCase().contains(lowercaseQuery) ||
        wo.title.toLowerCase().contains(lowercaseQuery) ||
        wo.customerName.toLowerCase().contains(lowercaseQuery) ||
        wo.location.address.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // ============ SIMPLE VALIDATION ============

  /// Check if work order can be started
  bool canStartWorkOrder(String workOrderId) {
    final workOrder = getWorkOrderById(workOrderId);
    return workOrder != null &&
        (workOrder.status == WorkOrderStatus.pending ||
            workOrder.status == WorkOrderStatus.scheduled);
  }

  /// Check if work order can be completed
  bool canCompleteWorkOrder(String workOrderId) {
    final workOrder = getWorkOrderById(workOrderId);
    return workOrder != null && workOrder.status == WorkOrderStatus.inProgress;
  }

  // ============ PROXY METHODS TO PROVIDER ============

  /// Get work orders (initial load)
  Future<void> getWorkOrders() async {
    await _provider.getWorkOrders();
  }

  /// Refresh work orders
  Future<void> refreshWorkOrders() async {
    await _provider.refreshWorkOrders();
  }

  /// Load more work orders
  Future<void> loadMoreWorkOrders() async {
    await _provider.loadMoreWorkOrders();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _provider.setSearchQuery(query);
  }

  /// Update filters
  void updateFilters(Map<String, dynamic> filters) {
    _provider.updateFilters(filters);
  }

  /// Clear all filters
  void clearAllFilters() {
    _provider.clearAllFilters();
  }

  /// Update work order status
  Future<void> updateWorkOrderStatus(
      String workOrderId,
      WorkOrderStatus newStatus,
      String? technicianId,
      ) async {
    await _provider.updateWorkOrderStatus(workOrderId, newStatus, technicianId);
  }
}