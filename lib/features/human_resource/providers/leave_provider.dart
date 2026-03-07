import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/leave/leave_application.dart';
import '../models/leave/leave_balance.dart';
import '../models/leave/leave_statistics.dart';
import 'employee_provider.dart';

class LeaveState {
  final List<LeaveApplication> applications;
  final List<LeaveApplication> filteredApplications;
  final LeaveApplication? selectedApplication;
  final LeaveBalance? leaveBalance;
  final LeaveStatistics? statistics;
  final bool isLoading;
  final bool isApplying;
  final bool isUpdating;
  final String? error;
  final String? success;

  // Filtering
  final String searchQuery;
  final LeaveType? selectedLeaveType;
  final LeaveStatus? selectedStatus;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final String? selectedDepartment;
  final String? selectedEmployee;

  // Pagination
  final int currentPage;
  final bool hasMore;

  LeaveState({
    this.applications = const [],
    List<LeaveApplication>? filteredApplications,
    this.selectedApplication,
    this.leaveBalance,
    this.statistics,
    this.isLoading = false,
    this.isApplying = false,
    this.isUpdating = false,
    this.error,
    this.success,
    this.searchQuery = '',
    this.selectedLeaveType,
    this.selectedStatus,
    this.startDateFilter,
    this.endDateFilter,
    this.selectedDepartment,
    this.selectedEmployee,
    this.currentPage = 1,
    this.hasMore = true,
  }) : filteredApplications = filteredApplications ?? applications;

  LeaveState copyWith({
    List<LeaveApplication>? applications,
    List<LeaveApplication>? filteredApplications,
    LeaveApplication? selectedApplication,
    LeaveBalance? leaveBalance,
    LeaveStatistics? statistics,
    bool? isLoading,
    bool? isApplying,
    bool? isUpdating,
    String? error,
    String? success,
    String? searchQuery,
    LeaveType? selectedLeaveType,
    LeaveStatus? selectedStatus,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? selectedDepartment,
    String? selectedEmployee,
    int? currentPage,
    bool? hasMore,
  }) {
    return LeaveState(
      applications: applications ?? this.applications,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      selectedApplication: selectedApplication ?? this.selectedApplication,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      success: success,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class LeaveProvider extends StateNotifier<LeaveState> {
  final Ref ref;
  final Dio dio;

  LeaveProvider(this.ref, this.dio) : super(LeaveState());

  // Get current user's employee ID
  String? get _currentEmployeeId {
    final authState = ref.read(authProvider);
    final employeeState = ref.read(employeeProvider);
    return employeeState.currentEmployee?.id ?? authState.user?['_id'];
  }

  // Check if user can manage leave (HR/Admin/Manager)
  bool get _canManageLeave {
    final authState = ref.read(authProvider);
    return authState.isAdmin || authState.isHR || authState.isManager;
  }

  // Load leave applications
  Future<void> loadApplications({bool loadMore = false}) async {
    if (!loadMore) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
      );
    }

    try {
      final page = loadMore ? state.currentPage + 1 : 1;

      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': 20,
      };

      // Add filters
      if (state.searchQuery.isNotEmpty) {
        queryParams['search'] = state.searchQuery;
      }
      if (state.selectedLeaveType != null) {
        queryParams['leaveType'] = describeEnum(state.selectedLeaveType!);
      }
      if (state.selectedStatus != null) {
        queryParams['status'] = describeEnum(state.selectedStatus!);
      }
      if (state.startDateFilter != null) {
        queryParams['startDate'] = state.startDateFilter!.toIso8601String();
      }
      if (state.endDateFilter != null) {
        queryParams['endDate'] = state.endDateFilter!.toIso8601String();
      }
      if (state.selectedDepartment != null && state.selectedDepartment!.isNotEmpty) {
        queryParams['department'] = state.selectedDepartment;
      }
      if (state.selectedEmployee != null && state.selectedEmployee!.isNotEmpty) {
        queryParams['employee'] = state.selectedEmployee;
      }

      // If not HR/Admin/Manager, only show user's applications
      if (!_canManageLeave && _currentEmployeeId != null) {
        queryParams['employee'] = _currentEmployeeId;
      }

      final response = await dio.get(
        '/v1/nawassco/human_resource/leave',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final List<dynamic> applicationsData = data['leaveApplications'] ?? [];
        final applications = applicationsData
            .map((e) => LeaveApplication.fromJson(e))
            .toList();

        final total = data['pagination']['total'] ?? 0;
        final hasMore = applications.length < total;

        state = state.copyWith(
          applications: loadMore
              ? [...state.applications, ...applications]
              : applications,
          filteredApplications: loadMore
              ? [...state.applications, ...applications]
              : applications,
          isLoading: false,
          currentPage: page,
          hasMore: hasMore,
          error: null,
        );

        _applyFilters();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to load leave applications',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading leave applications: ${e.toString()}',
      );
    }
  }

  // Apply leave
  Future<bool> applyForLeave(Map<String, dynamic> data) async {
    state = state.copyWith(isApplying: true, error: null, success: null);

    try {
      // Calculate total days
      final startDate = DateTime.parse(data['startDate']);
      final endDate = DateTime.parse(data['endDate']);
      final totalDays = endDate.difference(startDate).inDays + 1;

      final leaveData = {
        ...data,
        'totalDays': totalDays,
      };

      final response = await dio.post('/v1/nawassco/human_resource/leave/apply', data: leaveData);

      if (response.data['success'] == true) {
        final newApplication = LeaveApplication.fromJson(
          response.data['data']['leaveApplication'],
        );

        state = state.copyWith(
          isApplying: false,
          success: 'Leave application submitted successfully',
          applications: [newApplication, ...state.applications],
          filteredApplications: [newApplication, ...state.filteredApplications],
        );

        // Refresh leave balance
        // await _loadLeaveBalance();
        return true;
      } else {
        state = state.copyWith(
          isApplying: false,
          error: response.data['message'] ?? 'Failed to apply for leave',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: 'Error applying for leave: ${e.toString()}',
      );
      return false;
    }
  }

  // Update leave status (approve/reject)
  Future<bool> updateLeaveStatus({
    required String applicationId,
    required LeaveStatus status,
    String? rejectionReason,
  }) async {
    state = state.copyWith(isUpdating: true, error: null, success: null);

    try {
      final response = await dio.patch(
        '/v1/nawassco/human_resource/leave/$applicationId/status',
        data: {
          'status': describeEnum(status),
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );

      if (response.data['success'] == true) {
        final updatedApplication = LeaveApplication.fromJson(
          response.data['data']['leaveApplication'],
        );

        // Update in list
        final updatedApplications = state.applications
            .map((app) => app.id == applicationId ? updatedApplication : app)
            .toList();

        state = state.copyWith(
          isUpdating: false,
          success: 'Leave application ${describeEnum(status)} successfully',
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: state.selectedApplication?.id == applicationId
              ? updatedApplication
              : state.selectedApplication,
        );

        // Refresh statistics if user is HR/Admin/Manager
        if (_canManageLeave) {
          await loadStatistics();
        }

        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'Failed to update leave status',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error updating leave status: ${e.toString()}',
      );
      return false;
    }
  }

  // Cancel leave application
  Future<bool> cancelLeave(String applicationId) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/leave/$applicationId/cancel');

      if (response.data['success'] == true) {
        await loadApplications();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'Error cancelling leave: ${e.toString()}',
      );
      return false;
    }
  }

  // Load leave balance
  Future<void> loadLeaveBalance({String? employeeId}) async {
    try {
      String id = employeeId ?? _currentEmployeeId ?? '';
      if (id.isEmpty) return;

      final response = await dio.get('/v1/nawassco/human_resource/leave/balance/$id');

      if (response.data['success'] == true) {
        final balanceData = response.data['data']['balance'];
        final leaveBalance = LeaveBalance.fromJson(balanceData);

        state = state.copyWith(leaveBalance: leaveBalance);
      }
    } catch (e) {
      print('Error loading leave balance: $e');
    }
  }

  // Load statistics (for HR/Admin/Manager)
  Future<void> loadStatistics() async {
    if (!_canManageLeave) return;

    try {
      final response = await dio.get('/v1/nawassco/human_resource/leave/stats');

      if (response.data['success'] == true) {
        final statsData = response.data['data']['stats'];
        final statistics = LeaveStatistics.fromJson(statsData);

        state = state.copyWith(statistics: statistics);
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Load leave calendar
  Future<Map<String, dynamic>> loadCalendar({
    required int month,
    required int year,
    String? department,
  }) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/human_resource/leave/calendar',
        queryParameters: {
          'month': month,
          'year': year,
          if (department != null && department.isNotEmpty) 'department': department,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['calendar'];
      }
      return {};
    } catch (e) {
      print('Error loading calendar: $e');
      return {};
    }
  }

  // Update leave entitlement (HR/Admin only)
  Future<bool> updateLeaveEntitlement({
    required String employeeId,
    required Map<String, int> entitlements,
  }) async {
    try {
      final response = await dio.patch(
        '/v1/nawassco/human_resource/leave/entitlement/$employeeId',
        data: entitlements,
      );

      if (response.data['success'] == true) {
        // Refresh leave balance
        await loadLeaveBalance(employeeId: employeeId);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'Error updating leave entitlement: ${e.toString()}',
      );
      return false;
    }
  }

  // Filter applications
  void _applyFilters() {
    List<LeaveApplication> filtered = state.applications.where((app) {
      bool matchesSearch = state.searchQuery.isEmpty ||
          app.employeeName.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          app.leaveNumber.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          app.reason.toLowerCase().contains(state.searchQuery.toLowerCase());

      bool matchesType = state.selectedLeaveType == null ||
          app.leaveType == state.selectedLeaveType;

      bool matchesStatus = state.selectedStatus == null ||
          app.status == state.selectedStatus;

      bool matchesDepartment = state.selectedDepartment == null ||
          state.selectedDepartment!.isEmpty ||
          app.department == state.selectedDepartment;

      bool matchesEmployee = state.selectedEmployee == null ||
          state.selectedEmployee!.isEmpty ||
          app.employeeId == state.selectedEmployee;

      bool matchesDate = true;
      if (state.startDateFilter != null) {
        matchesDate = matchesDate && app.startDate.isAfter(state.startDateFilter!);
      }
      if (state.endDateFilter != null) {
        matchesDate = matchesDate && app.endDate.isBefore(state.endDateFilter!);
      }

      return matchesSearch &&
          matchesType &&
          matchesStatus &&
          matchesDepartment &&
          matchesEmployee &&
          matchesDate;
    }).toList();

    state = state.copyWith(filteredApplications: filtered);
  }

  // Set filter
  void setFilter({
    String? searchQuery,
    LeaveType? leaveType,
    LeaveStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? employee,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      selectedLeaveType: leaveType ?? state.selectedLeaveType,
      selectedStatus: status ?? state.selectedStatus,
      startDateFilter: startDate ?? state.startDateFilter,
      endDateFilter: endDate ?? state.endDateFilter,
      selectedDepartment: department ?? state.selectedDepartment,
      selectedEmployee: employee ?? state.selectedEmployee,
    );

    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedLeaveType: null,
      selectedStatus: null,
      startDateFilter: null,
      endDateFilter: null,
      selectedDepartment: null,
      selectedEmployee: null,
      filteredApplications: state.applications,
    );
  }

  // Select application
  void selectApplication(LeaveApplication application) {
    state = state.copyWith(selectedApplication: application);
  }

  // Clear selected application
  void clearSelectedApplication() {
    state = state.copyWith(selectedApplication: null);
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, success: null);
  }

  // Initialize data
  Future<void> initialize() async {
    await loadApplications();
    await loadLeaveBalance();
    if (_canManageLeave) {
      await loadStatistics();
    }
  }
}

// Provider
final leaveProvider = StateNotifierProvider<LeaveProvider, LeaveState>((ref) {
  final dio = ref.read(dioProvider);
  return LeaveProvider(ref, dio);
});