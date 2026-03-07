// features/managers/providers/manager_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/manager_model.dart';

class ManagerState {
  final List<ManagerModel> managers;
  final ManagerModel? selectedManager;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final String? success;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String searchQuery;
  final String? filterDepartment;
  final String? filterLevel;
  final String? filterStatus;

  const ManagerState({
    this.managers = const [],
    this.selectedManager,
    this.stats,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.success,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.searchQuery = '',
    this.filterDepartment,
    this.filterLevel,
    this.filterStatus,
  });

  ManagerState copyWith({
    List<ManagerModel>? managers,
    ManagerModel? selectedManager,
    Map<String, dynamic>? stats,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    String? success,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? searchQuery,
    String? filterDepartment,
    String? filterLevel,
    String? filterStatus,
  }) {
    return ManagerState(
      managers: managers ?? this.managers,
      selectedManager: selectedManager ?? this.selectedManager,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error,
      success: success,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      filterDepartment: filterDepartment,
      filterLevel: filterLevel,
      filterStatus: filterStatus,
    );
  }
}

class ManagerProvider extends StateNotifier<ManagerState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  Timer? _searchDebounce;

  ManagerProvider(this._dio, this._scaffoldMessengerKey)
      : super(const ManagerState());

  // Clear all state
  void clear() {
    state = const ManagerState();
  }

  // Set selected manager
  void selectManager(ManagerModel? manager) {
    state = state.copyWith(selectedManager: manager);
  }

  // Set filters
  void setFilters({
    String? department,
    String? level,
    String? status,
  }) {
    state = state.copyWith(
      filterDepartment: department,
      filterLevel: level,
      filterStatus: status,
      currentPage: 1,
    );
    _loadManagers();
  }

  // Set search query with debounce
  void setSearchQuery(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query, currentPage: 1);
      _loadManagers();
    });
  }

  // Navigate to page
  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    _loadManagers();
  }

  // Load all managers with pagination and filters
  Future<void> loadManagers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': state.currentPage,
        'limit': 20,
        if (state.searchQuery.isNotEmpty) 'search': state.searchQuery,
        if (state.filterDepartment != null)
          'department': state.filterDepartment,
        if (state.filterLevel != null) 'managementLevel': state.filterLevel,
        if (state.filterStatus != null) 'employmentStatus': state.filterStatus,
      };

      final response =
          await _dio.get('/v1/nawassco/manager/managers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final managers = (data['managers'] as List)
            .map((json) => ManagerModel.fromJson(json))
            .toList();

        state = state.copyWith(
          managers: managers,
          totalPages: data['pagination']['screens'] ?? 1,
          totalItems: data['pagination']['total'] ?? 0,
          isLoading: false,
          success: 'Managers loaded successfully',
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load managers',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
          'Failed to load managers',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading managers: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast(
        'Error loading managers',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Load manager by ID
  Future<void> loadManagerById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/manager/managers/$id');

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          selectedManager: manager,
          isLoading: false,
          success: 'Manager loaded successfully',
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load manager',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
          'Failed to load manager',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading manager: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast(
        'Error loading manager',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Load manager by user ID
  Future<void> loadManagerByUserId(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/manager/managers/user/$userId');

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          selectedManager: manager,
          isLoading: false,
          success: 'Manager profile loaded',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
        );
        // Don't show error - manager might not exist yet
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  // Create manager
  Future<bool> createManager(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final response = await _dio.post('/v1/nawassco/manager/managers', data: data);

      if (response.data['success'] == true) {
        state = state.copyWith(
          isCreating: false,
          success: 'Manager created successfully',
        );
        ToastUtils.showSuccessToast(
          'Manager created successfully',
          key: _scaffoldMessengerKey,
        );
        // Reload managers
        _loadManagers();
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.data['message'] ?? 'Failed to create manager',
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to create manager',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Error creating manager: $e',
      );
      ToastUtils.showErrorToast(
        'Error creating manager',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Update manager
  Future<bool> updateManager(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.put('/v1/nawassco/manager/managers/$id', data: data);

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          selectedManager: manager,
          isUpdating: false,
          success: 'Manager updated successfully',
        );
        ToastUtils.showSuccessToast(
          'Manager updated successfully',
          key: _scaffoldMessengerKey,
        );
        // Update in list if exists
        final updatedManagers = state.managers.map((m) {
          if (m.id == id) return manager;
          return m;
        }).toList();
        state = state.copyWith(managers: updatedManagers);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'Failed to update manager',
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update manager',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error updating manager: $e',
      );
      ToastUtils.showErrorToast(
        'Error updating manager',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Delete manager (soft delete)
  Future<bool> deleteManager(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await _dio.delete('/v1/nawassco/manager/managers/$id');

      if (response.data['success'] == true) {
        state = state.copyWith(
          isDeleting: false,
          success: 'Manager deleted successfully',
          selectedManager: null,
        );
        ToastUtils.showSuccessToast(
          'Manager deleted successfully',
          key: _scaffoldMessengerKey,
        );
        // Remove from list
        final updatedManagers =
            state.managers.where((m) => m.id != id).toList();
        state = state.copyWith(managers: updatedManagers);
        return true;
      } else {
        state = state.copyWith(
          isDeleting: false,
          error: response.data['message'] ?? 'Failed to delete manager',
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to delete manager',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Error deleting manager: $e',
      );
      ToastUtils.showErrorToast(
        'Error deleting manager',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Load manager statistics
  Future<void> loadManagerStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/manager/managers/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(stats: response.data['data']);
      }
    } catch (e) {
      // Silently fail for stats
    }
  }

  // Update approval limits
  Future<bool> updateApprovalLimits(
      String id, Map<String, dynamic> limits) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/manager/managers/$id/approval-limits',
        data: limits,
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast(
          'Approval limits updated',
          key: _scaffoldMessengerKey,
        );
        // Reload manager
        loadManagerById(id);
        return true;
      } else {
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update approval limits',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Error updating approval limits',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Add direct report
  Future<bool> addDirectReport(String managerId, String employeeId) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/manager/managers/$managerId/direct-reports',
        data: {'employeeId': employeeId},
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast(
          'Direct report added',
          key: _scaffoldMessengerKey,
        );
        // Reload manager
        loadManagerById(managerId);
        return true;
      } else {
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to add direct report',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Error adding direct report',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Reactivate manager
  Future<bool> reactivateManager(String id) async {
    try {
      final response = await _dio.post('/v1/nawassco/manager/managers/$id/reactivate');

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast(
          'Manager reactivated',
          key: _scaffoldMessengerKey,
        );
        // Reload managers
        _loadManagers();
        return true;
      } else {
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to reactivate manager',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Error reactivating manager',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Private method to load managers
  Future<void> _loadManagers() async {
    try {
      state = state.copyWith(isLoading: true);

      final queryParams = {
        'page': state.currentPage,
        'limit': 20,
        if (state.searchQuery.isNotEmpty) 'search': state.searchQuery,
        if (state.filterDepartment != null)
          'department': state.filterDepartment,
        if (state.filterLevel != null) 'managementLevel': state.filterLevel,
        if (state.filterStatus != null) 'employmentStatus': state.filterStatus,
      };

      final response =
          await _dio.get('/v1/nawassco/manager/managers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final managers = (data['managers'] as List)
            .map((json) => ManagerModel.fromJson(json))
            .toList();

        state = state.copyWith(
          managers: managers,
          totalPages: data['pagination']['screens'] ?? 1,
          totalItems: data['pagination']['total'] ?? 0,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

// Provider
final managerProvider =
    StateNotifierProvider<ManagerProvider, ManagerState>((ref) {
  final dio = ref.read(dioProvider);
  return ManagerProvider(dio, scaffoldMessengerKey);
});
