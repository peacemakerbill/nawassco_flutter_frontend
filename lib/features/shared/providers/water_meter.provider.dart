import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/water_meter.model.dart';

// ============================================
// PROVIDER STATE
// ============================================

class WaterMeterState {
  final bool isLoading;
  final List<WaterMeter> waterMeters;
  final WaterMeter? selectedWaterMeter;
  final WaterMeterFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final WaterMeterStats? stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isAddingMaintenance;
  final bool isAddingAlert;
  final bool isAddingIssue;
  final String? error;
  final List<WaterMeter>? metersNeedingMaintenance;

  const WaterMeterState({
    this.isLoading = false,
    this.waterMeters = const [],
    this.selectedWaterMeter,
    this.filters = const WaterMeterFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.stats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isAddingMaintenance = false,
    this.isAddingAlert = false,
    this.isAddingIssue = false,
    this.error,
    this.metersNeedingMaintenance,
  });

  WaterMeterState copyWith({
    bool? isLoading,
    List<WaterMeter>? waterMeters,
    WaterMeter? selectedWaterMeter,
    WaterMeterFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    WaterMeterStats? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isAddingMaintenance,
    bool? isAddingAlert,
    bool? isAddingIssue,
    String? error,
    List<WaterMeter>? metersNeedingMaintenance,
  }) {
    return WaterMeterState(
      isLoading: isLoading ?? this.isLoading,
      waterMeters: waterMeters ?? this.waterMeters,
      selectedWaterMeter: selectedWaterMeter ?? this.selectedWaterMeter,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isAddingMaintenance: isAddingMaintenance ?? this.isAddingMaintenance,
      isAddingAlert: isAddingAlert ?? this.isAddingAlert,
      isAddingIssue: isAddingIssue ?? this.isAddingIssue,
      error: error ?? this.error,
      metersNeedingMaintenance:
          metersNeedingMaintenance ?? this.metersNeedingMaintenance,
    );
  }
}

// ============================================
// PROVIDER
// ============================================

class WaterMeterProvider extends StateNotifier<WaterMeterState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;
  final Ref _ref;

  WaterMeterProvider(this._dio, this._scaffoldKey, this._ref)
      : super(const WaterMeterState());

  // -----------------------------------------------------------------
  // CRUD OPERATIONS
  // -----------------------------------------------------------------

  Future<void> loadWaterMeters({bool refresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = {
        'page': state.currentPage.toString(),
        'limit': '20',
        ...state.filters.toQueryParams(),
      };

      final response = await _dio.get('/v1/nawassco/meters/water-meters', queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final pagination = response.data['pagination'] as Map<String, dynamic>;

        final waterMeters =
            data.map<WaterMeter>((json) => WaterMeter.fromJson(json)).toList();

        state = state.copyWith(
          waterMeters:
              refresh ? waterMeters : [...state.waterMeters, ...waterMeters],
          totalPages: pagination['screens'] as int,
          totalItems: pagination['total'] as int,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load water meters');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadWaterMeterById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/meters/water-meters/id/$id');

      if (response.data['success'] == true) {
        final waterMeter = WaterMeter.fromJson(response.data['data']);
        state = state.copyWith(
          selectedWaterMeter: waterMeter,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load water meter');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<WaterMeter?> createWaterMeter(Map<String, dynamic> data) async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) {
        _showError('Authentication required');
        return null;
      }

      state = state.copyWith(isCreating: true, error: null);

      // Add installedBy from authenticated user
      final user = auth.user;
      if (user != null && user['_id'] != null) {
        data['installedBy'] = user['_id'];
      }

      final response = await _dio.post('/v1/nawassco/meters/water-meters', data: data);

      if (response.data['success'] == true) {
        final waterMeter = WaterMeter.fromJson(response.data['data']);

        state = state.copyWith(
          waterMeters: [waterMeter, ...state.waterMeters],
          selectedWaterMeter: waterMeter,
          isCreating: false,
        );

        _showSuccess('Water meter created successfully');
        return waterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to create water meter');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }

  Future<WaterMeter?> updateWaterMeter(
      String id, Map<String, dynamic> data) async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) {
        _showError('Authentication required');
        return null;
      }

      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.put('/v1/nawassco/meters/water-meters/$id', data: data);

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == id ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isUpdating: false,
        );

        _showSuccess('Water meter updated successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to update water meter');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> deleteWaterMeter(String id) async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) {
        _showError('Authentication required');
        return false;
      }

      state = state.copyWith(isDeleting: true, error: null);

      final response = await _dio.delete('/v1/nawassco/meters/water-meters/$id');

      if (response.data['success'] == true) {
        final updatedWaterMeters =
            state.waterMeters.where((meter) => meter.id != id).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: null,
          isDeleting: false,
        );

        _showSuccess('Water meter deleted successfully');
        return true;
      } else {
        _showError(response.data['message'] ?? 'Failed to delete water meter');
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  // -----------------------------------------------------------------
  // SPECIALIZED OPERATIONS
  // -----------------------------------------------------------------

  Future<WaterMeter?> updateWaterMeterStatus(
      String id, MeterStatus status) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/meters/water-meters/$id/status',
        data: {'status': status.name},
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == id ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isUpdating: false,
        );

        _showSuccess('Water meter status updated successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to update status');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<WaterMeter?> updateWaterMeterConnectivity(
    String id,
    ConnectivityStatus connectivity,
    double? signalStrength,
  ) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final data = {
        'connectivity': connectivity.name,
        if (signalStrength != null) 'signalStrength': signalStrength,
      };

      final response = await _dio.patch(
        '/v1/nawassco/meters/water-meters/$id/connectivity',
        data: data,
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == id ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isUpdating: false,
        );

        _showSuccess('Water meter connectivity updated successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to update connectivity');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<WaterMeter?> addMaintenanceRecord(
    String meterId,
    Map<String, dynamic> recordData,
  ) async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) {
        _showError('Authentication required');
        return null;
      }

      state = state.copyWith(isAddingMaintenance: true, error: null);

      // Add technician from authenticated user if not provided
      final user = auth.user;
      if (user != null && !recordData.containsKey('technician')) {
        recordData['technician'] = '${user['firstName']} ${user['lastName']}';
      }

      final response = await _dio.post(
        '/v1/nawassco/meters/water-meters/$meterId/maintenance',
        data: recordData,
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == meterId ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isAddingMaintenance: false,
        );

        _showSuccess('Maintenance record added successfully');
        return updatedWaterMeter;
      } else {
        _showError(
            response.data['message'] ?? 'Failed to add maintenance record');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isAddingMaintenance: false);
    }
  }

  Future<WaterMeter?> addAlert(
      String meterId, Map<String, dynamic> alertData) async {
    try {
      state = state.copyWith(isAddingAlert: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/meters/water-meters/$meterId/alerts',
        data: alertData,
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == meterId ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isAddingAlert: false,
        );

        _showSuccess('Alert added successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to add alert');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isAddingAlert: false);
    }
  }

  Future<WaterMeter?> resolveAlert(
    String meterId,
    int alertIndex,
    String resolvedBy,
    String? notes,
  ) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/meters/water-meters/$meterId/alerts/$alertIndex/resolve',
        data: {
          'resolvedBy': resolvedBy,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == meterId ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isUpdating: false,
        );

        _showSuccess('Alert resolved successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to resolve alert');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<WaterMeter?> addIssue(
      String meterId, Map<String, dynamic> issueData) async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) {
        _showError('Authentication required');
        return null;
      }

      state = state.copyWith(isAddingIssue: true, error: null);

      // Add reportedBy from authenticated user if not provided
      final user = auth.user;
      if (user != null && !issueData.containsKey('reportedBy')) {
        issueData['reportedBy'] = '${user['firstName']} ${user['lastName']}';
      }

      final response = await _dio.post(
        '/v1/nawassco/meters/water-meters/$meterId/issues',
        data: issueData,
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == meterId ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isAddingIssue: false,
        );

        _showSuccess('Issue reported successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to report issue');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isAddingIssue: false);
    }
  }

  Future<WaterMeter?> updateBatteryInfo(
    String meterId,
    Map<String, dynamic> batteryData,
  ) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/meters/water-meters/$meterId/battery',
        data: batteryData,
      );

      if (response.data['success'] == true) {
        final updatedWaterMeter = WaterMeter.fromJson(response.data['data']);

        final updatedWaterMeters = state.waterMeters.map((meter) {
          return meter.id == meterId ? updatedWaterMeter : meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          selectedWaterMeter: updatedWaterMeter,
          isUpdating: false,
        );

        _showSuccess('Battery information updated successfully');
        return updatedWaterMeter;
      } else {
        _showError(response.data['message'] ?? 'Failed to update battery info');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  // -----------------------------------------------------------------
  // BULK OPERATIONS
  // -----------------------------------------------------------------

  Future<int> bulkUpdateStatus(
      List<String> meterIds, MeterStatus status) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/meters/water-meters/bulk/status',
        data: {
          'meterIds': meterIds,
          'status': status.name,
        },
      );

      if (response.data['success'] == true) {
        final updatedCount = response.data['updatedCount'] as int;

        // Update local state
        final updatedWaterMeters = state.waterMeters.map((meter) {
          if (meterIds.contains(meter.id)) {
            return meter.copyWith(status: status);
          }
          return meter;
        }).toList();

        state = state.copyWith(
          waterMeters: updatedWaterMeters,
          isUpdating: false,
        );

        _showSuccess('Status updated for $updatedCount meter(s)');
        return updatedCount;
      } else {
        _showError(response.data['message'] ?? 'Failed to bulk update status');
        return 0;
      }
    } catch (e) {
      _handleError(e);
      return 0;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  // -----------------------------------------------------------------
  // STATISTICS AND ANALYTICS
  // -----------------------------------------------------------------

  Future<void> loadStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/meters/water-meters/stats/summary');

      if (response.data['success'] == true) {
        final stats = WaterMeterStats.fromJson(response.data['data']);
        state = state.copyWith(stats: stats);
      }
    } catch (e) {
      // Silently fail for stats
      print('Failed to load stats: $e');
    }
  }

  Future<void> loadMetersNeedingMaintenance() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/meters/water-meters/maintenance/needed');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final meters =
            data.map<WaterMeter>((json) => WaterMeter.fromJson(json)).toList();

        state = state.copyWith(
          metersNeedingMaintenance: meters,
          isLoading: false,
        );
      } else {
        _showError(
            response.data['message'] ?? 'Failed to load maintenance data');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadServiceRegionSummary() async {
    try {
      final response = await _dio.get('/v1/nawassco/meters/water-meters/stats/region-summary');

      if (response.data['success'] == true) {
        // Handle regional summary data
        print('Regional summary loaded: ${response.data['data']}');
      }
    } catch (e) {
      print('Failed to load regional summary: $e');
    }
  }

  Future<Map<String, dynamic>?> getRegionalStats(
      NakuruServiceRegion region) async {
    try {
      final response =
          await _dio.get('/v1/nawassco/meters/water-meters/stats/region/${region.name}');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Failed to load regional stats: $e');
      return null;
    }
  }

  // -----------------------------------------------------------------
  // UTILITY METHODS
  // -----------------------------------------------------------------

  Future<bool> checkMeterNumberAvailability(String meterNumber) async {
    try {
      final response = await _dio.get(
        '/v1/nawassco/meters/water-meters/check/meter-number/${Uri.encodeComponent(meterNumber)}',
      );

      if (response.data['success'] == true) {
        return response.data['available'] as bool;
      }
      return false;
    } catch (e) {
      print('Failed to check meter number availability: $e');
      return false;
    }
  }

  Future<bool> checkSerialNumberAvailability(String serialNumber) async {
    try {
      final response = await _dio.get(
        '/v1/nawassco/meters/water-meters/check/serial-number/${Uri.encodeComponent(serialNumber)}',
      );

      if (response.data['success'] == true) {
        return response.data['available'] as bool;
      }
      return false;
    } catch (e) {
      print('Failed to check serial number availability: $e');
      return false;
    }
  }

  Future<WaterMeter?> getMeterByCustomerAndRegion(
    String customerId,
    NakuruServiceRegion region,
  ) async {
    try {
      final response = await _dio.get(
        '/v1/nawassco/meters/water-meters/customer/$customerId/region/${region.name}',
      );

      if (response.data['success'] == true) {
        final waterMeter = WaterMeter.fromJson(response.data['data']);
        state = state.copyWith(selectedWaterMeter: waterMeter);
        return waterMeter;
      } else {
        return null;
      }
    } catch (e) {
      print('Failed to get meter by customer and region: $e');
      return null;
    }
  }

  // -----------------------------------------------------------------
  // STATE MANAGEMENT
  // -----------------------------------------------------------------

  void selectWaterMeter(WaterMeter? waterMeter) {
    state = state.copyWith(selectedWaterMeter: waterMeter);
  }

  void updateFilters(WaterMeterFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      waterMeters: [],
    );
    loadWaterMeters(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const WaterMeterFilters(),
      currentPage: 1,
      waterMeters: [],
    );
    loadWaterMeters(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadWaterMeters();
    }
  }

  void refreshData() {
    state = state.copyWith(
      currentPage: 1,
      waterMeters: [],
    );
    loadWaterMeters(refresh: true);
    loadStats();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // -----------------------------------------------------------------
  // ERROR HANDLING
  // -----------------------------------------------------------------

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldKey);
  }

  void _showError(String message) {
    state = state.copyWith(error: message);
    ToastUtils.showErrorToast(message, key: _scaffoldKey);
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Resource not found.';
      } else if (error.response?.statusCode == 409) {
        errorMessage = 'Water meter with this number or serial already exists.';
      } else if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please check your connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    state = state.copyWith(error: errorMessage);
    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================

final waterMeterProvider =
    StateNotifierProvider<WaterMeterProvider, WaterMeterState>(
  (ref) {
    final dio = ref.read(dioProvider);
    return WaterMeterProvider(dio, scaffoldMessengerKey, ref);
  },
);
