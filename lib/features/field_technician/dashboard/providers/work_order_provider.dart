import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/work_order.dart';

class WorkOrderState {
  final List<WorkOrder> workOrders;
  final WorkOrder? selectedWorkOrder;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const WorkOrderState({
    this.workOrders = const [],
    this.selectedWorkOrder,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
  });

  WorkOrderState copyWith({
    List<WorkOrder>? workOrders,
    WorkOrder? selectedWorkOrder,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
  }) {
    return WorkOrderState(
      workOrders: workOrders ?? this.workOrders,
      selectedWorkOrder: selectedWorkOrder ?? this.selectedWorkOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class WorkOrderProvider extends StateNotifier<WorkOrderState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  WorkOrderProvider(this._dio, this._scaffoldMessengerKey)
      : super(const WorkOrderState());

  // ============ CORE CRUD OPERATIONS ============

  Future<void> getWorkOrders({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: page,
      );

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
        ...state.filters,
      };

      final response = await _dio.get('/v1/nawassco/field_technician/work-orders', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final workOrdersData = data['workOrders'] as List? ?? [];
        final pagination = data['pagination'] ?? {};

        final workOrders = workOrdersData
            .map((wo) => WorkOrder.fromJson(wo))
            .toList();

        final newWorkOrders = loadMore
            ? [...state.workOrders, ...workOrders]
            : workOrders;

        state = state.copyWith(
          workOrders: newWorkOrders,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) < (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load work orders');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load work orders: $error');
    }
  }

  Future<void> getWorkOrderById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/work-orders/$id');

      if (response.data['success'] == true) {
        final workOrderData = response.data['data']['workOrder'];
        final workOrder = WorkOrder.fromJson(workOrderData);

        state = state.copyWith(
          selectedWorkOrder: workOrder,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load work order');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load work order: $error');
    }
  }

  Future<bool> createWorkOrder(WorkOrder workOrder) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post('/v1/nawassco/field_technician/work-orders', data: workOrder.toJson());

      if (response.data['success'] == true) {
        final newWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        state = state.copyWith(
          workOrders: [newWorkOrder, ...state.workOrders],
          isLoading: false,
        );

        _showSuccess('Work order created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create work order');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to create work order: $error');
      return false;
    }
  }

  Future<bool> updateWorkOrder(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.put('/v1/nawassco/field_technician/work-orders/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == id ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == id
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Work order updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update work order');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update work order: $error');
      return false;
    }
  }

  Future<bool> deleteWorkOrder(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/v1/nawassco/field_technician/work-orders/$id');

      if (response.data['success'] == true) {
        final updatedWorkOrders = state.workOrders.where((wo) => wo.id != id).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == id
              ? null
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Work order deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete work order');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to delete work order: $error');
      return false;
    }
  }

  // ============ WORK ORDER OPERATIONS ============

  Future<bool> assignTechnicians(
      String workOrderId,
      List<String> technicianIds,
      String? teamLeadId,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/work-orders/$workOrderId/assign-technicians',
        data: {
          'technicianIds': technicianIds,
          'teamLeadId': teamLeadId,
        },
      );

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == workOrderId ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == workOrderId
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Technicians assigned successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to assign technicians');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to assign technicians: $error');
      return false;
    }
  }

  Future<bool> updateWorkOrderStatus(
      String workOrderId,
      WorkOrderStatus status,
      String? completionNotes,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/work-orders/$workOrderId/status',
        data: {
          'status': status.apiValue,
          'completionNotes': completionNotes,
        },
      );

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == workOrderId ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == workOrderId
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Work order status updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update status: $error');
      return false;
    }
  }

  Future<bool> addTask(String workOrderId, Map<String, dynamic> taskData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/work-orders/$workOrderId/tasks',
        data: taskData,
      );

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == workOrderId ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == workOrderId
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Task added successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add task');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to add task: $error');
      return false;
    }
  }

  Future<bool> updateTaskStatus(
      String workOrderId,
      int taskIndex,
      TaskStatus status,
      String? completedBy,
      int? actualTime,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/work-orders/$workOrderId/tasks/status',
        data: {
          'taskIndex': taskIndex,
          'status': status.apiValue,
          'completedBy': completedBy,
          'actualTime': actualTime,
        },
      );

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == workOrderId ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == workOrderId
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Task status updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update task status');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update task status: $error');
      return false;
    }
  }

  Future<bool> recordMaterialUsage(
      String workOrderId,
      Map<String, dynamic> materialUsage,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/work-orders/$workOrderId/materials',
        data: materialUsage,
      );

      if (response.data['success'] == true) {
        final updatedWorkOrder = WorkOrder.fromJson(response.data['data']['workOrder']);

        final updatedWorkOrders = state.workOrders.map((wo) =>
        wo.id == workOrderId ? updatedWorkOrder : wo
        ).toList();

        state = state.copyWith(
          workOrders: updatedWorkOrders,
          selectedWorkOrder: state.selectedWorkOrder?.id == workOrderId
              ? updatedWorkOrder
              : state.selectedWorkOrder,
          isLoading: false,
        );

        _showSuccess('Material usage recorded successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to record material usage');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to record material usage: $error');
      return false;
    }
  }

  Future<void> searchWorkOrders(String query, {int page = 1, int limit = 20}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/work-orders/search', queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final workOrdersData = data['workOrders'] as List? ?? [];
        final pagination = data['pagination'] ?? {};

        final workOrders = workOrdersData
            .map((wo) => WorkOrder.fromJson(wo))
            .toList();

        state = state.copyWith(
          workOrders: workOrders,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) < (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Search failed');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Search failed: $error');
    }
  }

  // ============ NOTIFIER METHODS ============

  Future<void> refreshWorkOrders() async {
    state = state.copyWith(isLoading: true);
    await getWorkOrders();
  }

  Future<void> loadMoreWorkOrders() async {
    if (state.hasMore && !state.isLoading) {
      await getWorkOrders(
        page: state.currentPage + 1,
        loadMore: true,
      );
    }
  }

  void clearAllFilters() {
    state = state.copyWith(filters: {});
    getWorkOrders(page: 1);
  }

  void setSearchQuery(String query) {
    if (query.isEmpty) {
      getWorkOrders();
    } else {
      searchWorkOrders(query);
    }
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
    getWorkOrders(page: 1);
  }

  void clearSelectedWorkOrder() {
    state = state.copyWith(selectedWorkOrder: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // ============ STATE QUERY METHODS ============

  // WorkOrder? getWorkOrderById(String id) {
  //   try {
  //     return state.workOrders.firstWhere((wo) => wo.id == id);
  //   } catch (e) {
  //     try {
  //       return state.workOrders.firstWhere((wo) => wo.workOrderNumber == id);
  //     } catch (e) {
  //       return state.selectedWorkOrder?.id == id ? state.selectedWorkOrder : null;
  //     }
  //   }
  // }

  List<WorkOrder> getWorkOrdersByStatus(WorkOrderStatus status) {
    return state.workOrders.where((wo) => wo.status == status).toList();
  }

  List<WorkOrder> getOverdueWorkOrders() {
    return state.workOrders.where((wo) => wo.isOverdue).toList();
  }

  List<WorkOrder> getHighPriorityWorkOrders() {
    return state.workOrders.where((wo) =>
    wo.priority == WorkOrderPriority.high ||
        wo.priority == WorkOrderPriority.urgent
    ).toList();
  }

  List<WorkOrder> getWorkOrdersByTechnician(String technicianId) {
    return state.workOrders.where((wo) => wo.assignedTechnicianIds.contains(technicianId)).toList();
  }

  List<WorkOrder> getTodayWorkOrders() {
    final now = DateTime.now();
    return state.workOrders.where((wo) =>
    wo.scheduledDate.day == now.day &&
        wo.scheduledDate.month == now.month &&
        wo.scheduledDate.year == now.year
    ).toList();
  }

  List<WorkOrder> getWorkOrdersByCustomer(String customerId) {
    return state.workOrders.where((wo) => wo.customerId == customerId).toList();
  }

  List<WorkOrder> getWorkOrdersByType(WorkOrderType type) {
    return state.workOrders.where((wo) => wo.type == type).toList();
  }

  List<WorkOrder> getWorkOrdersByPriority(WorkOrderPriority priority) {
    return state.workOrders.where((wo) => wo.priority == priority).toList();
  }

  // ============ STATISTICS METHODS ============

  double getCompletionRate() {
    if (state.workOrders.isEmpty) return 0.0;
    final completed = state.workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length;
    return (completed / state.workOrders.length) * 100;
  }

  int getTotalWorkOrders() {
    return state.workOrders.length;
  }

  int getCompletedWorkOrders() {
    return state.workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length;
  }

  int getInProgressWorkOrders() {
    return state.workOrders.where((wo) => wo.status == WorkOrderStatus.inProgress).length;
  }

  int getPendingWorkOrders() {
    return state.workOrders.where((wo) => wo.status == WorkOrderStatus.pending).length;
  }

  int getOverdueCount() {
    return state.workOrders.where((wo) => wo.isOverdue).length;
  }

  Map<WorkOrderStatus, int> getStatusCounts() {
    final counts = <WorkOrderStatus, int>{};
    for (final status in WorkOrderStatus.values) {
      counts[status] = state.workOrders.where((wo) => wo.status == status).length;
    }
    return counts;
  }

  Map<WorkOrderPriority, int> getPriorityCounts() {
    final counts = <WorkOrderPriority, int>{};
    for (final priority in WorkOrderPriority.values) {
      counts[priority] = state.workOrders.where((wo) => wo.priority == priority).length;
    }
    return counts;
  }

  Map<WorkOrderType, int> getTypeCounts() {
    final counts = <WorkOrderType, int>{};
    for (final type in WorkOrderType.values) {
      counts[type] = state.workOrders.where((wo) => wo.type == type).length;
    }
    return counts;
  }

  double getAverageCompletionTime() {
    final completedOrders = state.workOrders.where((wo) =>
    wo.status == WorkOrderStatus.completed &&
        wo.actualStartDate != null &&
        wo.actualEndDate != null
    ).toList();

    if (completedOrders.isEmpty) return 0.0;

    final totalMinutes = completedOrders.fold<double>(0, (sum, wo) {
      final duration = wo.actualEndDate!.difference(wo.actualStartDate!);
      return sum + duration.inMinutes.toDouble();
    });

    return totalMinutes / completedOrders.length;
  }

  double getTotalEstimatedCost() {
    return state.workOrders.fold<double>(0, (sum, wo) => sum + wo.estimatedCost);
  }

  double getTotalActualCost() {
    return state.workOrders.fold<double>(0, (sum, wo) => sum + wo.actualCost);
  }

  // ============ HELPER METHODS ============

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }

  bool get isMounted => true;

  // ============ BATCH OPERATIONS ============

  Future<bool> bulkUpdateStatus(List<String> workOrderIds, WorkOrderStatus newStatus) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final results = await Future.wait(
        workOrderIds.map((id) => updateWorkOrderStatus(id, newStatus, null)),
      );

      final success = results.every((result) => result == true);

      if (success) {
        _showSuccess('${workOrderIds.length} work orders updated successfully');
      } else {
        _showError('Some work orders failed to update');
      }

      return success;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Bulk update failed: $error');
      return false;
    }
  }

  Future<bool> bulkAssignTechnicians(List<String> workOrderIds, List<String> technicianIds, String? teamLeadId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final results = await Future.wait(
        workOrderIds.map((id) => assignTechnicians(id, technicianIds, teamLeadId)),
      );

      final success = results.every((result) => result == true);

      if (success) {
        _showSuccess('Technicians assigned to ${workOrderIds.length} work orders');
      } else {
        _showError('Some assignments failed');
      }

      return success;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Bulk assignment failed: $error');
      return false;
    }
  }
}

// ============ PROVIDER DECLARATIONS ============

final workOrderProvider = StateNotifierProvider<WorkOrderProvider, WorkOrderState>((ref) {
  final dio = ref.read(dioProvider);
  return WorkOrderProvider(dio, scaffoldMessengerKey);
});

// Helper provider for common operations
final workOrderStatsProvider = Provider((ref) {
  final state = ref.watch(workOrderProvider);
  return {
    'total': state.workOrders.length,
    'completed': state.workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length,
    'inProgress': state.workOrders.where((wo) => wo.status == WorkOrderStatus.inProgress).length,
    'overdue': state.workOrders.where((wo) => wo.isOverdue).length,
    'completionRate': state.workOrders.isEmpty ? 0.0 :
    (state.workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length / state.workOrders.length) * 100,
  };
});

// Provider for filtered work orders
final filteredWorkOrdersProvider = Provider.family<List<WorkOrder>, Map<String, dynamic>>((ref, filters) {
  final state = ref.watch(workOrderProvider);

  if (filters.isEmpty) return state.workOrders;

  var filtered = state.workOrders;

  if (filters.containsKey('status') && filters['status'] != null) {
    filtered = filtered.where((wo) => wo.status.apiValue == filters['status']).toList();
  }

  if (filters.containsKey('priority') && filters['priority'] != null) {
    filtered = filtered.where((wo) => wo.priority.apiValue == filters['priority']).toList();
  }

  if (filters.containsKey('workOrderType') && filters['workOrderType'] != null) {
    filtered = filtered.where((wo) => wo.type.apiValue == filters['workOrderType']).toList();
  }

  if (filters.containsKey('assignedTo') && filters['assignedTo'] != null) {
    filtered = filtered.where((wo) =>
        wo.assignedTechnicianNames.any((name) =>
            name.toLowerCase().contains(filters['assignedTo'].toString().toLowerCase())
        )
    ).toList();
  }

  if (filters.containsKey('customer') && filters['customer'] != null) {
    filtered = filtered.where((wo) =>
        wo.customerName.toLowerCase().contains(filters['customer'].toString().toLowerCase())
    ).toList();
  }

  if (filters.containsKey('startDate') && filters['startDate'] != null) {
    final startDate = DateTime.parse(filters['startDate']);
    filtered = filtered.where((wo) => wo.scheduledDate.isAfter(startDate)).toList();
  }

  if (filters.containsKey('endDate') && filters['endDate'] != null) {
    final endDate = DateTime.parse(filters['endDate']);
    filtered = filtered.where((wo) => wo.scheduledDate.isBefore(endDate)).toList();
  }

  return filtered;
});