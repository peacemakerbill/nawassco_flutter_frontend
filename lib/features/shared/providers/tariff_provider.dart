import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../main.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/tariff_model.dart';

class TariffState {
  final List<Tariff> tariffs;
  final Tariff? selectedTariff;
  final TariffFilter filter;
  final TariffStatistics? statistics;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final BillCalculationResult? calculationResult;
  final List<Tariff>? expiringTariffs;
  final List<Tariff>? tariffHistory;

  TariffState({
    this.tariffs = const [],
    this.selectedTariff,
    TariffFilter? filter,
    this.statistics,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.totalCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.calculationResult,
    this.expiringTariffs,
    this.tariffHistory,
  }) : filter = filter ?? TariffFilter();

  TariffState copyWith({
    List<Tariff>? tariffs,
    Tariff? selectedTariff,
    TariffFilter? filter,
    TariffStatistics? statistics,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    BillCalculationResult? calculationResult,
    List<Tariff>? expiringTariffs,
    List<Tariff>? tariffHistory,
  }) {
    return TariffState(
      tariffs: tariffs ?? this.tariffs,
      selectedTariff: selectedTariff ?? this.selectedTariff,
      filter: filter ?? this.filter,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      calculationResult: calculationResult ?? this.calculationResult,
      expiringTariffs: expiringTariffs ?? this.expiringTariffs,
      tariffHistory: tariffHistory ?? this.tariffHistory,
    );
  }
}

class TariffProvider extends StateNotifier<TariffState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Ref ref;

  TariffProvider(this.dio, this.scaffoldMessengerKey, this.ref)
      : super(TariffState());

  bool get isMounted => mounted;

  // Get current user from auth provider
  Map<String, dynamic>? get currentUser {
    final authState = ref.read(authProvider);
    return authState.user;
  }

  String? get currentUserId {
    final user = currentUser;
    return user?['_id']?.toString();
  }

  bool get canManageTariffs {
    final authState = ref.read(authProvider);
    return authState.isAdmin || authState.isManager;
  }

  bool get canApproveTariffs {
    final authState = ref.read(authProvider);
    return authState.isAdmin;
  }

  // Helper method to show toast safely
  void _showToastSafely(VoidCallback showToast) {
    showToast();
  }

  // Helper method to show error
  void _showError(String message) {
    _showToastSafely(() {
      ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
    });
  }

  // Helper method to show success
  void _showSuccess(String message) {
    _showToastSafely(() {
      ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
    });
  }

  // -----------------------------------------------------------------
  // FETCH TARIFFS
  // -----------------------------------------------------------------
  Future<void> fetchTariffs({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final response = await dio.get(
        '/v1/nawassco/billing/tariffs',
        queryParameters: state.filter.toQueryParams(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final tariffs = data.map((json) => Tariff.fromJson(json)).toList();

        state = state.copyWith(
          tariffs: tariffs,
          isLoading: false,
          error: null,
          totalCount: response.data['pagination']?['total'] ?? 0,
          currentPage: response.data['pagination']?['page'] ?? 1,
          totalPages: response.data['pagination']?['totalPages'] ?? 1,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch tariffs';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET TARIFF BY ID
  // -----------------------------------------------------------------
  Future<Tariff?> getTariffById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/billing/tariffs/$id');

      if (response.data['success'] == true) {
        final tariff = Tariff.fromJson(response.data['data']);
        state = state.copyWith(
          selectedTariff: tariff,
          isLoading: false,
          error: null,
        );
        return tariff;
      } else {
        throw response.data['message'] ?? 'Failed to fetch tariff';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
      return null;
    }
  }

  // -----------------------------------------------------------------
  // CREATE TARIFF
  // -----------------------------------------------------------------
  Future<bool> createTariff(Tariff tariff) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      // Add createdBy from current user
      final userId = currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final tariffData = tariff.toJson();
      tariffData['createdBy'] = userId;

      final response = await dio.post(
        '/v1/nawassco/billing/tariffs',
        data: tariffData,
      );

      if (response.data['success'] == true) {
        final newTariff = Tariff.fromJson(response.data['data']);

        // Add to list
        final updatedTariffs = [newTariff, ...state.tariffs];

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: newTariff,
          isCreating: false,
          error: null,
        );

        _showSuccess('Tariff created successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to create tariff';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isCreating: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE TARIFF
  // -----------------------------------------------------------------
  Future<bool> updateTariff(String id, Tariff tariff) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      // Add updatedBy from current user
      final userId = currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final tariffData = tariff.toJson();
      tariffData['updatedBy'] = userId;

      final response = await dio.put(
        '/v1/nawassco/billing/tariffs/$id',
        data: tariffData,
      );

      if (response.data['success'] == true) {
        final updatedTariff = Tariff.fromJson(response.data['data']);

        // Update in list
        final updatedTariffs = state.tariffs.map((t) {
          return t.id == id ? updatedTariff : t;
        }).toList();

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: updatedTariff,
          isUpdating: false,
          error: null,
        );

        _showSuccess('Tariff updated successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to update tariff';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isUpdating: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // DELETE TARIFF (Soft Delete)
  // -----------------------------------------------------------------
  Future<bool> deleteTariff(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await dio.delete('/v1/nawassco/billing/tariffs/$id');

      if (response.data['success'] == true) {
        // Remove from list
        final updatedTariffs = state.tariffs.where((t) => t.id != id).toList();

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: null,
          isDeleting: false,
          error: null,
        );

        _showSuccess('Tariff deleted successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to delete tariff';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isDeleting: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // APPROVE TARIFF
  // -----------------------------------------------------------------
  Future<bool> approveTariff(String id) async {
    try {
      if (!canApproveTariffs) {
        throw 'You do not have permission to approve tariffs';
      }

      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch('/v1/nawassco/billing/tariffs/$id/approve');

      if (response.data['success'] == true) {
        final approvedTariff = Tariff.fromJson(response.data['data']);

        // Update in list
        final updatedTariffs = state.tariffs.map((t) {
          return t.id == id ? approvedTariff : t;
        }).toList();

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: approvedTariff,
          isUpdating: false,
          error: null,
        );

        _showSuccess('Tariff approved successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to approve tariff';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isUpdating: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // ACTIVATE/DEACTIVATE TARIFF
  // -----------------------------------------------------------------
  Future<bool> toggleTariffStatus(String id, bool isActive) async {
    try {
      if (!canManageTariffs) {
        throw 'You do not have permission to manage tariffs';
      }

      state = state.copyWith(isUpdating: true, error: null);

      final endpoint =
          isActive ? '/v1/nawassco/billing/tariffs/$id/activate' : '/v1/nawassco/billing/tariffs/$id/deactivate';
      final response = await dio.patch(endpoint);

      if (response.data['success'] == true) {
        final updatedTariff = Tariff.fromJson(response.data['data']);

        // Update in list
        final updatedTariffs = state.tariffs.map((t) {
          return t.id == id ? updatedTariff : t;
        }).toList();

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: updatedTariff,
          isUpdating: false,
          error: null,
        );

        _showSuccess(isActive
            ? 'Tariff activated successfully'
            : 'Tariff deactivated successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to update tariff status';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isUpdating: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // CREATE NEW VERSION
  // -----------------------------------------------------------------
  Future<Tariff?> createNewVersion(String id) async {
    try {
      if (!canManageTariffs) {
        throw 'You do not have permission to create new versions';
      }

      state = state.copyWith(isCreating: true, error: null);

      final response = await dio.post('/v1/nawassco/billing/tariffs/$id/version');

      if (response.data['success'] == true) {
        final newVersion = Tariff.fromJson(response.data['data']);

        // Add to list
        final updatedTariffs = [newVersion, ...state.tariffs];

        state = state.copyWith(
          tariffs: updatedTariffs,
          selectedTariff: newVersion,
          isCreating: false,
          error: null,
        );

        _showSuccess('New tariff version created successfully');
        return newVersion;
      } else {
        throw response.data['message'] ?? 'Failed to create new version';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isCreating: false, error: error.toString());
      return null;
    }
  }

  // -----------------------------------------------------------------
  // CALCULATE BILL
  // -----------------------------------------------------------------
  Future<BillCalculationResult?> calculateBill(
    String tariffId,
    double consumption,
    NakuruServiceRegion serviceRegion,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/billing/tariffs/$tariffId/calculate',
        data: {
          'consumption': consumption,
          'serviceRegion': serviceRegion.code,
        },
      );

      if (response.data['success'] == true) {
        final result = BillCalculationResult.fromJson(response.data['data']);
        state = state.copyWith(
          calculationResult: result,
          isLoading: false,
          error: null,
        );
        return result;
      } else {
        throw response.data['message'] ?? 'Failed to calculate bill';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
      return null;
    }
  }

  // -----------------------------------------------------------------
  // GET TARIFF HISTORY
  // -----------------------------------------------------------------
  Future<void> getTariffHistory(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/billing/tariffs/history/$code');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final history = data.map((json) => Tariff.fromJson(json)).toList();

        state = state.copyWith(
          tariffHistory: history,
          isLoading: false,
          error: null,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch tariff history';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET EXPIRING TARIFFS
  // -----------------------------------------------------------------
  Future<void> getExpiringTariffs({int daysThreshold = 30}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/billing/tariffs/expiring',
        queryParameters: {'daysThreshold': daysThreshold.toString()},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final expiring = data.map((json) => Tariff.fromJson(json)).toList();

        state = state.copyWith(
          expiringTariffs: expiring,
          isLoading: false,
          error: null,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch expiring tariffs';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET STATISTICS
  // -----------------------------------------------------------------
  Future<void> getStatistics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/billing/tariffs/statistics');

      if (response.data['success'] == true) {
        final stats = TariffStatistics.fromJson(response.data['data']);
        state = state.copyWith(
          statistics: stats,
          isLoading: false,
          error: null,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch statistics';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  // -----------------------------------------------------------------
  // BULK UPDATE STATUS
  // -----------------------------------------------------------------
  Future<bool> bulkUpdateStatus(List<String> ids, bool isActive) async {
    try {
      if (!canManageTariffs) {
        throw 'You do not have permission to bulk update tariffs';
      }

      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/billing/tariffs/bulk/status',
        data: {
          'tariffIds': ids,
          'isActive': isActive,
        },
      );

      if (response.data['success'] == true) {
        // Refresh the list
        await fetchTariffs(showLoading: false);

        state = state.copyWith(
          isUpdating: false,
          error: null,
        );

        _showSuccess('${ids.length} tariff(s) updated successfully');
        return true;
      } else {
        throw response.data['message'] ?? 'Failed to bulk update tariffs';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isUpdating: false, error: error.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // FILTER MANAGEMENT
  // -----------------------------------------------------------------
  void updateFilter(TariffFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void clearFilter() {
    state = state.copyWith(filter: TariffFilter());
  }

  void setSearchQuery(String query) {
    final newFilter = state.filter.copyWith(search: query);
    state = state.copyWith(filter: newFilter);
  }

  void setPage(int page) {
    final newFilter = state.filter.copyWith(page: page);
    state = state.copyWith(filter: newFilter);
  }

  // -----------------------------------------------------------------
  // SELECTION MANAGEMENT
  // -----------------------------------------------------------------
  void selectTariff(Tariff? tariff) {
    state = state.copyWith(selectedTariff: tariff);
  }

  void clearSelection() {
    state = state.copyWith(selectedTariff: null);
  }

  void clearCalculationResult() {
    state = state.copyWith(calculationResult: null);
  }

  // -----------------------------------------------------------------
  // ERROR HANDLING
  // -----------------------------------------------------------------
  void _handleError(dynamic error) {
    print('Tariff Provider Error: $error');

    String errorMessage = 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['message'] is String &&
            (data['message'] as String).isNotEmpty) {
          errorMessage = data['message'];
        } else if (data['error'] is String &&
            (data['error'] as String).isNotEmpty) {
          errorMessage = data['error'];
        }
      }

      if (statusCode == 401) {
        errorMessage = 'Authentication required. Please login again.';
      } else if (statusCode == 403) {
        errorMessage = 'You do not have permission to perform this action.';
      } else if (statusCode == 404) {
        errorMessage = 'Tariff not found.';
      } else if (statusCode == 409) {
        errorMessage = 'Tariff with this code already exists.';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    _showError(errorMessage);
  }
}

// -----------------------------------------------------------------
// PROVIDER DEFINITION
// -----------------------------------------------------------------
final tariffProvider =
    StateNotifierProvider<TariffProvider, TariffState>((ref) {
  final dio = ref.read(dioProvider);
  return TariffProvider(dio, scaffoldMessengerKey, ref);
});
