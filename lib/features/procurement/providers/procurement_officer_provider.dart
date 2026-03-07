import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../main.dart';
import '../domain/models/procurement_officer.dart';


class ProcurementOfficerState {
  final List<ProcurementOfficer> officers;
  final ProcurementOfficer? selectedOfficer;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalOfficers;
  final Map<String, dynamic>? stats;

  ProcurementOfficerState({
    this.officers = const [],
    this.selectedOfficer,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalOfficers = 0,
    this.stats,
  });

  ProcurementOfficerState copyWith({
    List<ProcurementOfficer>? officers,
    ProcurementOfficer? selectedOfficer,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalOfficers,
    Map<String, dynamic>? stats,
  }) {
    return ProcurementOfficerState(
      officers: officers ?? this.officers,
      selectedOfficer: selectedOfficer ?? this.selectedOfficer,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalOfficers: totalOfficers ?? this.totalOfficers,
      stats: stats ?? this.stats,
    );
  }
}

class ProcurementOfficerProvider extends StateNotifier<ProcurementOfficerState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  ProcurementOfficerProvider(this.dio, this.scaffoldMessengerKey)
      : super(ProcurementOfficerState());

  // -----------------------------------------------------------------
  // GET ALL PROCUREMENT OFFICERS
  // -----------------------------------------------------------------
  Future<void> getProcurementOfficers({Map<String, dynamic>? filters, int page = 1}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': 10,
        ...?filters,
        ...state.filters,
      };

      queryParams.removeWhere((key, value) => value == null);

      final response = await dio.get('/v1/nawassco/procurement/officers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<ProcurementOfficer> officers = (response.data['data'] as List)
            .map((officerJson) => ProcurementOfficer.fromJson(officerJson))
            .toList();

        final pagination = response.data['pagination'] ?? {};

        state = state.copyWith(
          officers: officers,
          isLoading: false,
          currentPage: pagination['page'] ?? page,
          totalPages: pagination['screens'] ?? 1,
          totalOfficers: pagination['total'] ?? 0,
          filters: filters ?? state.filters,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch procurement officers');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET SINGLE PROCUREMENT OFFICER
  // -----------------------------------------------------------------
  Future<void> getProcurementOfficer(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/officers/$id');

      if (response.data['success'] == true) {
        final officer = ProcurementOfficer.fromJson(response.data['data']);
        state = state.copyWith(
          selectedOfficer: officer,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch procurement officer');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // CREATE PROCUREMENT OFFICER
  // -----------------------------------------------------------------
  Future<bool> createProcurementOfficer(Map<String, dynamic> officerData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/procurement/officers', data: officerData);

      if (response.data['success'] == true) {
        final newOfficer = ProcurementOfficer.fromJson(response.data['data']);

        final updatedOfficers = [newOfficer, ...state.officers];

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: newOfficer,
          isLoading: false,
        );

        _showSuccess('Procurement officer created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create procurement officer');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE PROCUREMENT OFFICER
  // -----------------------------------------------------------------
  Future<bool> updateProcurementOfficer(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/procurement/officers/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedOfficer = ProcurementOfficer.fromJson(response.data['data']);

        final updatedOfficers = state.officers.map((officer) =>
        officer.id == id ? updatedOfficer : officer
        ).toList();

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: updatedOfficer,
          isLoading: false,
        );

        _showSuccess('Procurement officer updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update procurement officer');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // DELETE PROCUREMENT OFFICER
  // -----------------------------------------------------------------
  Future<bool> deleteProcurementOfficer(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/procurement/officers/$id');

      if (response.data['success'] == true) {
        final updatedOfficers = state.officers.where((officer) => officer.id != id).toList();

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: null,
          isLoading: false,
        );

        _showSuccess('Procurement officer deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete procurement officer');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // GET OFFICERS BY ROLE
  // -----------------------------------------------------------------
  Future<void> getOfficersByRole(String role, {Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/officers/role/$role', queryParameters: filters);

      if (response.data['success'] == true) {
        final List<ProcurementOfficer> officers = (response.data['data'] as List)
            .map((officerJson) => ProcurementOfficer.fromJson(officerJson))
            .toList();

        final pagination = response.data['pagination'] ?? {};

        state = state.copyWith(
          officers: officers,
          isLoading: false,
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['screens'] ?? 1,
          totalOfficers: pagination['total'] ?? 0,
          filters: {'role': role, ...?filters},
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch officers by role');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET OFFICERS BY CATEGORY
  // -----------------------------------------------------------------
  Future<void> getOfficersByCategory(String category, {Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/officers/category/$category', queryParameters: filters);

      if (response.data['success'] == true) {
        final List<ProcurementOfficer> officers = (response.data['data'] as List)
            .map((officerJson) => ProcurementOfficer.fromJson(officerJson))
            .toList();

        final pagination = response.data['pagination'] ?? {};

        state = state.copyWith(
          officers: officers,
          isLoading: false,
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['screens'] ?? 1,
          totalOfficers: pagination['total'] ?? 0,
          filters: {'category': category, ...?filters},
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch officers by category');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // UPDATE OFFICER PERFORMANCE
  // -----------------------------------------------------------------
  Future<bool> updateOfficerPerformance(String id, Map<String, dynamic> performanceData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/procurement/officers/$id/performance', data: performanceData);

      if (response.data['success'] == true) {
        final updatedOfficer = ProcurementOfficer.fromJson(response.data['data']);

        final updatedOfficers = state.officers.map((officer) =>
        officer.id == id ? updatedOfficer : officer
        ).toList();

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: updatedOfficer,
          isLoading: false,
        );

        _showSuccess('Officer performance updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update officer performance');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // GET PROCUREMENT OFFICER STATS
  // -----------------------------------------------------------------
  Future<void> getProcurementOfficerStats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/officers/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch procurement officer stats');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // ASSIGN SUPPLIER TO OFFICER
  // -----------------------------------------------------------------
  Future<bool> assignSupplier(String officerId, String supplierId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/procurement/officers/$officerId/suppliers/$supplierId');

      if (response.data['success'] == true) {
        final updatedOfficer = ProcurementOfficer.fromJson(response.data['data']);

        final updatedOfficers = state.officers.map((officer) =>
        officer.id == officerId ? updatedOfficer : officer
        ).toList();

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: updatedOfficer,
          isLoading: false,
        );

        _showSuccess('Supplier assigned to officer successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to assign supplier');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // REMOVE SUPPLIER FROM OFFICER
  // -----------------------------------------------------------------
  Future<bool> removeSupplier(String officerId, String supplierId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/procurement/officers/$officerId/suppliers/$supplierId');

      if (response.data['success'] == true) {
        final updatedOfficer = ProcurementOfficer.fromJson(response.data['data']);

        final updatedOfficers = state.officers.map((officer) =>
        officer.id == officerId ? updatedOfficer : officer
        ).toList();

        state = state.copyWith(
          officers: updatedOfficers,
          selectedOfficer: updatedOfficer,
          isLoading: false,
        );

        _showSuccess('Supplier removed from officer successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove supplier');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // CLEAR SELECTED OFFICER
  // -----------------------------------------------------------------
  void clearSelectedOfficer() {
    state = state.copyWith(selectedOfficer: null);
  }

  // -----------------------------------------------------------------
  // CLEAR ERROR
  // -----------------------------------------------------------------
  void clearError() {
    state = state.copyWith(error: null);
  }

  // -----------------------------------------------------------------
  // PRIVATE HELPERS
  // -----------------------------------------------------------------
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final procurementOfficerProvider = StateNotifierProvider<ProcurementOfficerProvider, ProcurementOfficerState>((ref) {
  final dio = ref.read(dioProvider);
  return ProcurementOfficerProvider(dio, scaffoldMessengerKey);
});