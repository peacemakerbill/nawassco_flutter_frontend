import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../models/store_manager_model.dart';
import '../../../main.dart';

class StoreManagerAdminState {
  final List<StoreManager> storeManagers;
  final StoreManager? selectedStoreManager;
  final bool isLoading;
  final String? error;
  final bool isUpdating;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final Map<String, dynamic> filters;

  StoreManagerAdminState({
    this.storeManagers = const [],
    this.selectedStoreManager,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.filters = const {},
  });

  StoreManagerAdminState copyWith({
    List<StoreManager>? storeManagers,
    StoreManager? selectedStoreManager,
    bool? isLoading,
    String? error,
    bool? isUpdating,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    Map<String, dynamic>? filters,
  }) {
    return StoreManagerAdminState(
      storeManagers: storeManagers ?? this.storeManagers,
      selectedStoreManager: selectedStoreManager ?? this.selectedStoreManager,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      filters: filters ?? this.filters,
    );
  }
}

class StoreManagerAdminProvider extends StateNotifier<StoreManagerAdminState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  StoreManagerAdminProvider(this.dio, this.scaffoldMessengerKey)
      : super(StoreManagerAdminState());

  bool get isMounted => mounted;

  // Get all store managers with pagination and filters
  Future<void> getStoreManagers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? managementLevel,
    String? department,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Fetching store managers...');

      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        if (managementLevel != null && managementLevel.isNotEmpty)
          'managementLevel': managementLevel,
        if (department != null && department.isNotEmpty) 'department': department,
      };

      final response = await dio.get('/v1/nawassco/stores/store-managers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final managersData = response.data['data']['managers'] as List? ?? [];
        final paginationData = response.data['data']['pagination'] ?? {};

        final storeManagers = managersData
            .map((data) => StoreManager.fromJson(data))
            .toList();

        state = state.copyWith(
          storeManagers: storeManagers,
          isLoading: false,
          currentPage: paginationData['page'] ?? page,
          totalPages: paginationData['totalPages'] ?? 1,
          totalCount: paginationData['total'] ?? 0,
          filters: {
            'search': search,
            'role': role,
            'managementLevel': managementLevel,
            'department': department,
          },
        );
        print('Store managers loaded successfully: ${storeManagers.length} items');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to load store managers';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error fetching store managers: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Get store manager by ID
  Future<void> getStoreManagerById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Fetching store manager by ID: $id');

      final response = await dio.get('/v1/nawassco/stores/store-managers/$id');

      if (response.data['success'] == true) {
        final managerData = response.data['data'];
        final storeManager = StoreManager.fromJson(managerData);

        state = state.copyWith(
          selectedStoreManager: storeManager,
          isLoading: false,
        );
        print('Store manager loaded successfully');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to load store manager';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error fetching store manager: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Create store manager
  Future<bool> createStoreManager(Map<String, dynamic> storeManagerData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Creating store manager...');

      final response = await dio.post('/v1/nawassco/stores/store-managers', data: storeManagerData);

      if (response.data['success'] == true) {
        final newManagerData = response.data['data'];
        final newStoreManager = StoreManager.fromJson(newManagerData);

        // Add to current list
        final updatedManagers = [newStoreManager, ...state.storeManagers];

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: newStoreManager,
          isUpdating: false,
        );

        _showSuccessToast('Store manager created successfully');
        print('Store manager created successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to create store manager';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error creating store manager: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Update store manager
  Future<bool> updateStoreManager(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Updating store manager: $id');

      final response = await dio.patch('/v1/nawassco/stores/store-managers/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        // Update in list
        final updatedManagers = state.storeManagers.map((manager) =>
        manager.id == id ? updatedManager : manager
        ).toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: updatedManager,
          isUpdating: false,
        );

        _showSuccessToast('Store manager updated successfully');
        print('Store manager updated successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update store manager';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error updating store manager: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Delete store manager
  Future<bool> deleteStoreManager(String id) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Deleting store manager: $id');

      final response = await dio.delete('/v1/nawassco/stores/store-managers/$id');

      if (response.data['success'] == true) {
        // Remove from list
        final updatedManagers = state.storeManagers
            .where((manager) => manager.id != id)
            .toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: null,
          isUpdating: false,
        );

        _showSuccessToast('Store manager deleted successfully');
        print('Store manager deleted successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to delete store manager';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error deleting store manager: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Update store manager performance
  Future<bool> updatePerformance(String managerId, Map<String, dynamic> performanceData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Updating performance for store manager: $managerId');

      final response = await dio.patch(
        '/v1/nawassco/stores/store-managers/$managerId/performance',
        data: performanceData,
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        // Update in list
        final updatedManagers = state.storeManagers.map((manager) =>
        manager.id == managerId ? updatedManager : manager
        ).toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: updatedManager,
          isUpdating: false,
        );

        _showSuccessToast('Performance updated successfully');
        print('Performance updated successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update performance';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error updating performance: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Add store objective
  Future<bool> addStoreObjective(String managerId, Map<String, dynamic> objectiveData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Adding objective for store manager: $managerId');

      final response = await dio.post(
        '/v1/nawassco/stores/store-managers/$managerId/objectives',
        data: objectiveData,
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        // Update in list
        final updatedManagers = state.storeManagers.map((manager) =>
        manager.id == managerId ? updatedManager : manager
        ).toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: updatedManager,
          isUpdating: false,
        );

        _showSuccessToast('Objective added successfully');
        print('Objective added successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to add objective';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error adding objective: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Update objective progress
  Future<bool> updateObjectiveProgress(
      String managerId,
      String objectiveId,
      double progress
      ) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Updating objective progress: $objectiveId');

      final response = await dio.patch(
        '/v1/nawassco/stores/store-managers/$managerId/objectives/$objectiveId/progress',
        data: {'progress': progress},
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        // Update in list
        final updatedManagers = state.storeManagers.map((manager) =>
        manager.id == managerId ? updatedManager : manager
        ).toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: updatedManager,
          isUpdating: false,
        );

        _showSuccessToast('Objective progress updated successfully');
        print('Objective progress updated successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update objective progress';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error updating objective progress: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Toggle store manager active status
  Future<bool> toggleActiveStatus(String id, bool isActive) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Toggling active status for store manager: $id');

      final response = await dio.patch(
        '/v1/nawassco/stores/store-managers/$id',
        data: {'isActive': isActive},
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        // Update in list
        final updatedManagers = state.storeManagers.map((manager) =>
        manager.id == id ? updatedManager : manager
        ).toList();

        state = state.copyWith(
          storeManagers: updatedManagers,
          selectedStoreManager: updatedManager,
          isUpdating: false,
        );

        final status = isActive ? 'activated' : 'deactivated';
        _showSuccessToast('Store manager $status successfully');
        print('Store manager $status successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update status';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
        return false;
      }
    } catch (e) {
      print('Error toggling active status: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
      return false;
    }
  }

  // Clear selected store manager
  void clearSelectedStoreManager() {
    state = state.copyWith(selectedStoreManager: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  void _showSuccessToast(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showErrorToast(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (data is Map<String, dynamic>) {
            if (data['message'] is String && (data['message'] as String).isNotEmpty) {
              return data['message'];
            }
          }

          switch (statusCode) {
            case 401:
              return 'Unauthorized. Please login again.';
            case 403:
              return 'Access denied. You do not have permission to perform this action.';
            case 404:
              return 'Store manager not found.';
            case 409:
              return 'Employee number already exists.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return 'Request failed. Please try again.';
          }
        case DioExceptionType.unknown:
          if (error.error?.toString().contains('SocketException') == true) {
            return 'No internet connection. Please check your network.';
          }
          return 'An unexpected error occurred.';
        default:
          return 'An unexpected error occurred.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

// Provider
final storeManagerAdminProvider = StateNotifierProvider<StoreManagerAdminProvider, StoreManagerAdminState>((ref) {
  final dio = ref.read(dioProvider);
  return StoreManagerAdminProvider(dio, scaffoldMessengerKey);
});