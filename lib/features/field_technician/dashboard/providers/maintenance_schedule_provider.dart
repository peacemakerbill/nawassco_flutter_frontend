import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceScheduleState {
  final List<MaintenanceSchedule> schedules;
  final MaintenanceSchedule? selectedSchedule;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final MaintenanceTargetType? targetTypeFilter;
  final MaintenanceStatus? statusFilter;
  final PriorityLevel? priorityFilter;
  final Map<String, dynamic> metrics;
  final bool showCompleted;
  final bool showOverdue;

  const MaintenanceScheduleState({
    this.schedules = const [],
    this.selectedSchedule,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.targetTypeFilter,
    this.statusFilter,
    this.priorityFilter,
    this.metrics = const {},
    this.showCompleted = true,
    this.showOverdue = true,
  });

  MaintenanceScheduleState copyWith({
    List<MaintenanceSchedule>? schedules,
    MaintenanceSchedule? selectedSchedule,
    bool? isLoading,
    String? error,
    String? searchQuery,
    MaintenanceTargetType? targetTypeFilter,
    MaintenanceStatus? statusFilter,
    PriorityLevel? priorityFilter,
    Map<String, dynamic>? metrics,
    bool? showCompleted,
    bool? showOverdue,
  }) {
    return MaintenanceScheduleState(
      schedules: schedules ?? this.schedules,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      targetTypeFilter: targetTypeFilter ?? this.targetTypeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      metrics: metrics ?? this.metrics,
      showCompleted: showCompleted ?? this.showCompleted,
      showOverdue: showOverdue ?? this.showOverdue,
    );
  }

  List<MaintenanceSchedule> get filteredSchedules {
    var filtered = schedules.where((schedule) => schedule.isActive).toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((schedule) =>
              schedule.scheduleNumber
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              schedule.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              schedule.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              schedule.targetName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply target type filter
    if (targetTypeFilter != null) {
      filtered = filtered
          .where((schedule) => schedule.targetType == targetTypeFilter)
          .toList();
    }

    // Apply status filter
    if (statusFilter != null) {
      filtered = filtered
          .where((schedule) => schedule.status == statusFilter)
          .toList();
    }

    // Apply priority filter
    if (priorityFilter != null) {
      filtered = filtered
          .where((schedule) => schedule.priority == priorityFilter)
          .toList();
    }

    // Apply completed filter
    if (!showCompleted) {
      filtered = filtered
          .where((schedule) => schedule.status != MaintenanceStatus.completed)
          .toList();
    }

    // Apply overdue filter
    if (!showOverdue) {
      filtered = filtered.where((schedule) => !schedule.isOverdue).toList();
    }

    return filtered;
  }

  List<MaintenanceSchedule> get overdueSchedules {
    return schedules.where((schedule) => schedule.isOverdue).toList();
  }

  List<MaintenanceSchedule> get upcomingSchedules {
    return schedules
        .where((schedule) =>
            schedule.daysUntilDue <= 7 &&
            schedule.status != MaintenanceStatus.completed)
        .toList();
  }

  List<MaintenanceSchedule> get inProgressSchedules {
    return schedules
        .where((schedule) => schedule.status == MaintenanceStatus.inProgress)
        .toList();
  }
}

class MaintenanceScheduleProvider
    extends StateNotifier<MaintenanceScheduleState> {
  final Dio dio;

  MaintenanceScheduleProvider(this.dio)
      : super(const MaintenanceScheduleState());

  // Load all maintenance schedules
  Future<void> loadMaintenanceSchedules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/maintenance-schedules');

      if (response.data['success'] == true) {
        final List<MaintenanceSchedule> schedules = (response.data['data']
                ['result']['schedules'] as List)
            .map((scheduleData) => MaintenanceSchedule.fromJson(scheduleData))
            .toList();

        state = state.copyWith(
          schedules: schedules,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to load maintenance schedules',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load maintenance schedules: $e',
        isLoading: false,
      );
    }
  }

  // Load maintenance schedule by ID
  Future<void> loadMaintenanceScheduleById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/maintenance-schedules/$id');

      if (response.data['success'] == true) {
        final schedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        state = state.copyWith(
          selectedSchedule: schedule,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error:
              response.data['message'] ?? 'Failed to load maintenance schedule',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load maintenance schedule: $e',
        isLoading: false,
      );
    }
  }

  // Create maintenance schedule
  Future<bool> createMaintenanceSchedule(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.post('/v1/nawassco/field_technician/maintenance-schedules', data: data);

      if (response.data['success'] == true) {
        final schedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        state = state.copyWith(
          schedules: [...state.schedules, schedule],
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to create maintenance schedule',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create maintenance schedule: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update maintenance schedule
  Future<bool> updateMaintenanceSchedule(
      String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.put('/v1/nawassco/field_technician/maintenance-schedules/$id', data: data);

      if (response.data['success'] == true) {
        final updatedSchedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        final updatedSchedules = state.schedules
            .map((schedule) => schedule.id == id ? updatedSchedule : schedule)
            .toList();

        final selectedSchedule = state.selectedSchedule?.id == id
            ? updatedSchedule
            : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to update maintenance schedule',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update maintenance schedule: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete maintenance schedule (soft delete)
  Future<bool> deleteMaintenanceSchedule(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.delete('/v1/nawassco/field_technician/maintenance-schedules/$id');

      if (response.data['success'] == true) {
        final updatedSchedules =
            state.schedules.where((schedule) => schedule.id != id).toList();
        final selectedSchedule =
            state.selectedSchedule?.id == id ? null : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to delete maintenance schedule',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete maintenance schedule: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update maintenance status
  Future<bool> updateMaintenanceStatus(String id, MaintenanceStatus status,
      {String? notes}) async {
    try {
      final response =
          await dio.patch('/v1/nawassco/field_technician/maintenance-schedules/$id/status', data: {
        'status': status.name,
        if (notes != null) 'notes': notes,
      });

      if (response.data['success'] == true) {
        final updatedSchedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        final updatedSchedules = state.schedules
            .map((schedule) => schedule.id == id ? updatedSchedule : schedule)
            .toList();

        final selectedSchedule = state.selectedSchedule?.id == id
            ? updatedSchedule
            : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Assign technicians
  Future<bool> assignTechnicians(String id, List<String> technicianIds) async {
    try {
      final response = await dio
          .patch('/v1/nawassco/field_technician/maintenance-schedules/$id/assign-technicians', data: {
        'technicianIds': technicianIds,
      });

      if (response.data['success'] == true) {
        final updatedSchedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        final updatedSchedules = state.schedules
            .map((schedule) => schedule.id == id ? updatedSchedule : schedule)
            .toList();

        final selectedSchedule = state.selectedSchedule?.id == id
            ? updatedSchedule
            : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update task status
  Future<bool> updateTaskStatus(
      String scheduleId, int taskIndex, TaskStatus status,
      {String? completedBy, double? actualTime}) async {
    try {
      final data = {
        'taskIndex': taskIndex,
        'status': status.name,
        if (completedBy != null) 'completedBy': completedBy,
        if (actualTime != null) 'actualTime': actualTime,
      };

      final response = await dio
          .patch('/v1/nawassco/field_technician/maintenance-schedules/$scheduleId/tasks/status', data: data);

      if (response.data['success'] == true) {
        final updatedSchedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        final updatedSchedules = state.schedules
            .map((schedule) =>
                schedule.id == scheduleId ? updatedSchedule : schedule)
            .toList();

        final selectedSchedule = state.selectedSchedule?.id == scheduleId
            ? updatedSchedule
            : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Record actual cost
  Future<bool> recordActualCost(String id, double actualCost) async {
    try {
      final response =
          await dio.patch('/v1/nawassco/field_technician/maintenance-schedules/$id/cost', data: {
        'actualCost': actualCost,
      });

      if (response.data['success'] == true) {
        final updatedSchedule = MaintenanceSchedule.fromJson(
            response.data['data']['maintenanceSchedule']);
        final updatedSchedules = state.schedules
            .map((schedule) => schedule.id == id ? updatedSchedule : schedule)
            .toList();

        final selectedSchedule = state.selectedSchedule?.id == id
            ? updatedSchedule
            : state.selectedSchedule;

        state = state.copyWith(
          schedules: updatedSchedules,
          selectedSchedule: selectedSchedule,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // // Load metrics
  // Future<void> loadMetrics() async {
  //   try {
  //     final response = await dio.get('/v1/nawassco/field_technician/maintenance-schedules/metrics');
  //
  //     if (response.data['success'] == true) {
  //       state = state.copyWith(metrics: response.data['data']['metrics'] ?? {});
  //     }
  //   } catch (e) {
  //     print('Failed to load metrics: $e');
  //   }
  // }

  // Enhanced metrics loading with better error handling
  Future<void> loadMetrics() async {
    try {
      final response = await dio.get('/v1/nawassco/field_technician/maintenance-schedules/metrics');

      if (response.data['success'] == true) {
        final metricsData = response.data['data']['metrics'] ?? {};

        // Process the metrics data to ensure it's in the expected format
        final processedMetrics = _processMetricsData(metricsData);

        state = state.copyWith(metrics: processedMetrics);
      } else {
        print('Failed to load metrics: ${response.data['message']}');
      }
    } catch (e) {
      print('Error loading metrics: $e');
      // Don't set error state for metrics since it's non-critical
    }
  }

  Map<String, dynamic> _processMetricsData(Map<String, dynamic> metricsData) {
    // Ensure all expected metric arrays exist and are properly formatted
    return {
      'statusCounts': metricsData['statusCounts'] ?? [],
      'targetTypeCounts': metricsData['targetTypeCounts'] ?? [],
      'scheduleTypeCounts': metricsData['scheduleTypeCounts'] ?? [],
      'costAnalysis': metricsData['costAnalysis'] ?? [],
      'completionStats': metricsData['completionStats'] ?? [],
    };
  }

  // Method to get cost analysis metrics
  Map<String, dynamic> getCostAnalysis() {
    final costAnalysis = state.metrics['costAnalysis'] ?? [];
    if (costAnalysis.isNotEmpty && costAnalysis[0] is Map) {
      return costAnalysis[0];
    }
    return {};
  }

  // Method to get completion statistics
  List<dynamic> getCompletionStats() {
    return state.metrics['completionStats'] ?? [];
  }

  // Load upcoming maintenance
  Future<List<MaintenanceSchedule>> loadUpcomingMaintenance(
      {int days = 7}) async {
    try {
      final response =
          await dio.get('/v1/nawassco/field_technician/maintenance-schedules/upcoming?days=$days');

      if (response.data['success'] == true) {
        return (response.data['data']['upcomingMaintenance'] as List)
            .map((scheduleData) => MaintenanceSchedule.fromJson(scheduleData))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Load overdue maintenance
  Future<List<MaintenanceSchedule>> loadOverdueMaintenance() async {
    try {
      final response = await dio.get('/v1/nawassco/field_technician/maintenance-schedules/overdue');

      if (response.data['success'] == true) {
        return (response.data['data']['overdueMaintenance'] as List)
            .map((scheduleData) => MaintenanceSchedule.fromJson(scheduleData))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Search maintenance schedules
  Future<void> searchMaintenanceSchedules(String query) async {
    state = state.copyWith(searchQuery: query);
  }

  // Set filters
  void setTargetTypeFilter(MaintenanceTargetType? type) {
    state = state.copyWith(targetTypeFilter: type);
  }

  void setStatusFilter(MaintenanceStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void setPriorityFilter(PriorityLevel? priority) {
    state = state.copyWith(priorityFilter: priority);
  }

  void setShowCompleted(bool show) {
    state = state.copyWith(showCompleted: show);
  }

  void setShowOverdue(bool show) {
    state = state.copyWith(showOverdue: show);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      targetTypeFilter: null,
      statusFilter: null,
      priorityFilter: null,
      showCompleted: true,
      showOverdue: true,
    );
  }

  // Select schedule
  void selectSchedule(MaintenanceSchedule? schedule) {
    state = state.copyWith(selectedSchedule: schedule);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final maintenanceScheduleProvider = StateNotifierProvider<
    MaintenanceScheduleProvider, MaintenanceScheduleState>((ref) {
  final dio = ref.read(dioProvider);
  return MaintenanceScheduleProvider(dio);
});
