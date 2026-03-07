import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';

import '../../../main.dart';
import '../models/sales_representative_model.dart';
import '../presentation/widgets/sub_widgets/sales_rep/custom_widgets.dart';

class SalesRepState {
  final List<SalesRepresentative> salesReps;
  final SalesRepresentative? currentSalesRep;
  final SalesRepresentative? selectedSalesRep;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Map<String, dynamic> filters;

  SalesRepState({
    this.salesReps = const [],
    this.currentSalesRep,
    this.selectedSalesRep,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.filters = const {},
  });

  SalesRepState copyWith({
    List<SalesRepresentative>? salesReps,
    SalesRepresentative? currentSalesRep,
    SalesRepresentative? selectedSalesRep,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    Map<String, dynamic>? filters,
  }) {
    return SalesRepState(
      salesReps: salesReps ?? this.salesReps,
      currentSalesRep: currentSalesRep ?? this.currentSalesRep,
      selectedSalesRep: selectedSalesRep ?? this.selectedSalesRep,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      filters: filters ?? this.filters,
    );
  }
}

class SalesRepProvider extends StateNotifier<SalesRepState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  SalesRepProvider(this.dio, this.scaffoldMessengerKey)
      : super(SalesRepState());

  // Fetch all sales representatives with pagination
  Future<void> fetchSalesReps(
      {int page = 1, int limit = 10, Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
      };

      final response = await dio.get(
        '/v1/nawassco/sales/sales-representatives',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final pagination = response.data['pagination'];

        final salesReps =
            data.map((json) => SalesRepresentative.fromJson(json)).toList();

        state = state.copyWith(
          salesReps: salesReps,
          currentPage: pagination['page'],
          totalPages: pagination['screens'],
          totalItems: pagination['total'],
          filters: filters ?? state.filters,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to fetch sales representatives',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to fetch sales representatives: ${e.toString()}',
          key: scaffoldMessengerKey);
    }
  }

  // Fetch current user's sales rep profile
  Future<void> fetchCurrentUserProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/sales/sales-representatives/me');

      if (response.data['success'] == true) {
        final salesRep = SalesRepresentative.fromJson(response.data['data']);
        state = state.copyWith(
          currentSalesRep: salesRep,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Profile not found',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Fetch single sales rep by ID
  Future<void> fetchSalesRepById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/sales/sales-representatives/$id');

      if (response.data['success'] == true) {
        final salesRep = SalesRepresentative.fromJson(response.data['data']);
        state = state.copyWith(
          selectedSalesRep: salesRep,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Sales representative not found',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to fetch sales representative: ${e.toString()}',
          key: scaffoldMessengerKey);
    }
  }

  // Create new sales representative
  Future<bool> createSalesRep(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/sales/sales-representatives',
        data: data,
      );

      if (response.data['success'] == true) {
        final newSalesRep = SalesRepresentative.fromJson(response.data['data']);
        state = state.copyWith(
          salesReps: [newSalesRep, ...state.salesReps],
          isLoading: false,
        );
        showSuccessToast('Sales representative created successfully!',
            key: scaffoldMessengerKey);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to create sales representative',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to create sales representative: ${e.toString()}',
          key: scaffoldMessengerKey);
      return false;
    }
  }

  // Update sales representative
  Future<bool> updateSalesRep(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/sales/sales-representatives/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        final updatedSalesRep =
            SalesRepresentative.fromJson(response.data['data']);

        // Update in list
        final updatedList = state.salesReps.map((rep) {
          return rep.id == id ? updatedSalesRep : rep;
        }).toList();

        // Update current or selected if applicable
        SalesRepresentative? currentRep = state.currentSalesRep;
        SalesRepresentative? selectedRep = state.selectedSalesRep;

        if (currentRep?.id == id) {
          currentRep = updatedSalesRep;
        }
        if (selectedRep?.id == id) {
          selectedRep = updatedSalesRep;
        }

        state = state.copyWith(
          salesReps: updatedList,
          currentSalesRep: currentRep,
          selectedSalesRep: selectedRep,
          isLoading: false,
        );
        showSuccessToast('Sales representative updated successfully!',
            key: scaffoldMessengerKey);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to update sales representative',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to update sales representative: ${e.toString()}',
          key: scaffoldMessengerKey);
      return false;
    }
  }

  // Update current user's profile (self-service)
  Future<bool> updateCurrentProfile(Map<String, dynamic> data) async {
    try {
      if (state.currentSalesRep == null) {
        // Create profile if doesn't exist
        return await createSalesRep(data);
      }

      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/sales/sales-representatives/${state.currentSalesRep!.id}',
        data: data,
      );

      if (response.data['success'] == true) {
        final updatedSalesRep =
            SalesRepresentative.fromJson(response.data['data']);
        state = state.copyWith(
          currentSalesRep: updatedSalesRep,
          isLoading: false,
        );
        showSuccessToast('Profile updated successfully!',
            key: scaffoldMessengerKey);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update profile',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to update profile: ${e.toString()}',
          key: scaffoldMessengerKey);
      return false;
    }
  }

  // Delete sales representative (soft delete)
  Future<bool> deleteSalesRep(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/sales/sales-representatives/$id');

      if (response.data['success'] == true) {
        // Remove from list
        final updatedList =
            state.salesReps.where((rep) => rep.id != id).toList();
        state = state.copyWith(
          salesReps: updatedList,
          selectedSalesRep:
              state.selectedSalesRep?.id == id ? null : state.selectedSalesRep,
          isLoading: false,
        );
        showSuccessToast('Sales representative deleted successfully!',
            key: scaffoldMessengerKey);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ??
              'Failed to delete sales representative',
          isLoading: false,
        );
        showErrorToast(response.data['message'], key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      showErrorToast('Failed to delete sales representative: ${e.toString()}',
          key: scaffoldMessengerKey);
      return false;
    }
  }

  // Search sales representatives
  Future<void> searchSalesReps(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/sales/sales-representatives',
        queryParameters: {
          'search': query,
          'page': 1,
          'limit': 20,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final salesReps =
            data.map((json) => SalesRepresentative.fromJson(json)).toList();
        state = state.copyWith(
          salesReps: salesReps,
          isLoading: false,
          filters: {'search': query},
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Search failed',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Filter by status
  Future<void> filterByStatus(String? status) async {
    final newFilters = Map<String, dynamic>.from(state.filters);
    if (status != null) {
      newFilters['status'] = status;
    } else {
      newFilters.remove('status');
    }
    await fetchSalesReps(page: 1, filters: newFilters);
  }

  // Clear selected sales rep
  void clearSelectedSalesRep() {
    state = state.copyWith(selectedSalesRep: null);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await fetchSalesReps(page: 1, filters: {});
  }
}

// Provider
final salesRepProvider =
    StateNotifierProvider<SalesRepProvider, SalesRepState>((ref) {
  final dio = ref.read(dioProvider);
  return SalesRepProvider(dio, scaffoldMessengerKey);
});
