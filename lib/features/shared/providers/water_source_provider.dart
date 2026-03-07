import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/water_source_model.dart';

class WaterSourceState {
  final List<WaterSource> waterSources;
  final WaterSource? selectedWaterSource;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final List<WaterSource> filteredSources;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> utilizationData;
  final List<WaterSource> activeAlerts;

  const WaterSourceState({
    this.waterSources = const [],
    this.selectedWaterSource,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.filteredSources = const [],
    this.stats = const {},
    this.utilizationData = const [],
    this.activeAlerts = const [],
  });

  WaterSourceState copyWith({
    List<WaterSource>? waterSources,
    WaterSource? selectedWaterSource,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    List<WaterSource>? filteredSources,
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? utilizationData,
    List<WaterSource>? activeAlerts,
  }) {
    return WaterSourceState(
      waterSources: waterSources ?? this.waterSources,
      selectedWaterSource: selectedWaterSource ?? this.selectedWaterSource,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      filteredSources: filteredSources ?? this.filteredSources,
      stats: stats ?? this.stats,
      utilizationData: utilizationData ?? this.utilizationData,
      activeAlerts: activeAlerts ?? this.activeAlerts,
    );
  }
}

class WaterSourceProvider extends StateNotifier<WaterSourceState> {
  final Dio dio;
  final Ref ref;

  WaterSourceProvider(this.dio, this.ref) : super(const WaterSourceState());

  // Apply filters to water sources
  void applyFilters(Map<String, dynamic> newFilters) {
    final filtered = _applyFilters(state.waterSources, newFilters);
    state = state.copyWith(
      filters: newFilters,
      filteredSources: filtered,
    );
  }

  // Clear all filters
  void clearFilters() {
    state = state.copyWith(
      filters: {},
      filteredSources: state.waterSources,
    );
  }

  // Filter logic
  List<WaterSource> _applyFilters(
      List<WaterSource> sources, Map<String, dynamic> filters) {
    var filtered = List<WaterSource>.from(sources);

    if (filters['type'] != null) {
      filtered =
          filtered.where((source) => source.type == filters['type']).toList();
    }

    if (filters['status'] != null) {
      filtered = filtered
          .where((source) => source.status == filters['status'])
          .toList();
    }

    if (filters['quality'] != null) {
      filtered = filtered
          .where((source) => source.quality.qualityGrade == filters['quality'])
          .toList();
    }

    if (filters['minCapacity'] != null) {
      filtered = filtered
          .where(
              (source) => source.capacity.dailyYield >= filters['minCapacity'])
          .toList();
    }

    if (filters['searchQuery'] != null && filters['searchQuery'].isNotEmpty) {
      final query = filters['searchQuery'].toLowerCase();
      filtered = filtered
          .where((source) =>
              source.name.toLowerCase().contains(query) ||
              source.location.address.toLowerCase().contains(query) ||
              source.location.catchmentArea.toLowerCase().contains(query))
          .toList();
    }

    // Sort by selected criteria
    if (filters['sort'] != null) {
      switch (filters['sort']) {
        case 'name':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case '-name':
          filtered.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'capacity':
          filtered.sort(
              (a, b) => a.capacity.dailyYield.compareTo(b.capacity.dailyYield));
          break;
        case '-capacity':
          filtered.sort(
              (a, b) => b.capacity.dailyYield.compareTo(a.capacity.dailyYield));
          break;
        case 'createdAt':
          filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case '-createdAt':
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    return filtered;
  }

  // Set selected water source
  void selectWaterSource(WaterSource? source) {
    state = state.copyWith(selectedWaterSource: source);
  }

  // CRUD Operations
  Future<void> fetchWaterSources() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/water-sources');

      if (response.data['success'] == true) {
        final List<WaterSource> sources =
            (response.data['data']['docs'] as List)
                .map((json) => WaterSource.fromJson(json))
                .toList();

        state = state.copyWith(
          waterSources: sources,
          filteredSources: _applyFilters(sources, state.filters),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch water sources',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError('Failed to fetch water sources: $e');
    }
  }

  Future<void> fetchWaterSourceById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/water-sources/$id');

      if (response.data['success'] == true) {
        final waterSource = WaterSource.fromJson(response.data['data']);
        state = state.copyWith(
          selectedWaterSource: waterSource,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch water source',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError('Failed to fetch water source: $e');
    }
  }

  Future<void> createWaterSource(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final authState = ref.read(authProvider);
      final createdData = {
        ...data,
        'createdBy': authState.user?['id'],
      };

      final response = await dio.post('/v1/nawassco/services/water-sources', data: createdData);

      if (response.data['success'] == true) {
        final newSource = WaterSource.fromJson(response.data['data']);
        final updatedSources = [...state.waterSources, newSource];

        state = state.copyWith(
          waterSources: updatedSources,
          filteredSources: _applyFilters(updatedSources, state.filters),
          selectedWaterSource: newSource,
          isLoading: false,
        );

        _showSuccess('Water source created successfully!');
      } else {
        state = state.copyWith(isLoading: false);
        _showError(response.data['message'] ?? 'Failed to create water source');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showError('Failed to create water source: $e');
    }
  }

  Future<void> updateWaterSource(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.put('/v1/nawassco/services/water-sources/$id', data: data);

      if (response.data['success'] == true) {
        final updatedSource = WaterSource.fromJson(response.data['data']);
        final updatedSources = state.waterSources
            .map((source) => source.id == id ? updatedSource : source)
            .toList();

        state = state.copyWith(
          waterSources: updatedSources,
          filteredSources: _applyFilters(updatedSources, state.filters),
          selectedWaterSource: updatedSource,
          isLoading: false,
        );

        _showSuccess('Water source updated successfully!');
      } else {
        state = state.copyWith(isLoading: false);
        _showError(response.data['message'] ?? 'Failed to update water source');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showError('Failed to update water source: $e');
    }
  }

  Future<void> deleteWaterSource(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.delete('/v1/nawassco/services/water-sources/$id');

      if (response.data['success'] == true) {
        final updatedSources =
            state.waterSources.where((source) => source.id != id).toList();

        state = state.copyWith(
          waterSources: updatedSources,
          filteredSources: _applyFilters(updatedSources, state.filters),
          selectedWaterSource: null,
          isLoading: false,
        );

        _showSuccess('Water source deleted successfully!');
      } else {
        state = state.copyWith(isLoading: false);
        _showError(response.data['message'] ?? 'Failed to delete water source');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showError('Failed to delete water source: $e');
    }
  }

  Future<void> updateStatus(String id, SourceStatus status) async {
    try {
      final response = await dio.put('/v1/nawassco/services/water-sources/$id/status', data: {
        'status': status.value,
      });

      if (response.data['success'] == true) {
        final updatedSource = WaterSource.fromJson(response.data['data']);
        final updatedSources = state.waterSources
            .map((source) => source.id == id ? updatedSource : source)
            .toList();

        state = state.copyWith(
          waterSources: updatedSources,
          filteredSources: _applyFilters(updatedSources, state.filters),
          selectedWaterSource: updatedSource,
        );

        _showSuccess('Status updated successfully!');
      }
    } catch (e) {
      _showError('Failed to update status: $e');
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await dio.get('/v1/nawassco/services/water-sources/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(stats: response.data['data']);
      }
    } catch (e) {
      _showError('Failed to fetch statistics: $e');
    }
  }

  Future<void> fetchUtilization() async {
    try {
      final response = await dio.get('/v1/nawassco/services/water-sources/utilization');

      if (response.data['success'] == true) {
        state = state.copyWith(
            utilizationData:
                List<Map<String, dynamic>>.from(response.data['data']));
      }
    } catch (e) {
      _showError('Failed to fetch utilization data: $e');
    }
  }

  Future<void> fetchActiveAlerts() async {
    try {
      final response = await dio.get('/v1/nawassco/services/water-sources/alerts/active');

      if (response.data['success'] == true) {
        final alerts = (response.data['data'] as List)
            .map((json) => WaterSource.fromJson(json))
            .toList();

        state = state.copyWith(activeAlerts: alerts);
      }
    } catch (e) {
      _showError('Failed to fetch alerts: $e');
    }
  }

  Future<void> addAlert(String id, Map<String, dynamic> alertData) async {
    try {
      final response =
          await dio.post('/v1/nawassco/services/water-sources/$id/alerts', data: alertData);

      if (response.data['success'] == true) {
        final updatedSource = WaterSource.fromJson(response.data['data']);
        final updatedSources = state.waterSources
            .map((source) => source.id == id ? updatedSource : source)
            .toList();

        state = state.copyWith(
          waterSources: updatedSources,
          selectedWaterSource: updatedSource,
        );

        _showSuccess('Alert added successfully!');
      }
    } catch (e) {
      _showError('Failed to add alert: $e');
    }
  }

  Future<void> resolveAlert(
      String id, int alertIndex, String resolution) async {
    try {
      final response = await dio.put('/v1/nawassco/services/water-sources/$id/alerts', data: {
        'alertIndex': alertIndex,
        'resolution': resolution,
      });

      if (response.data['success'] == true) {
        final updatedSource = WaterSource.fromJson(response.data['data']);
        final updatedSources = state.waterSources
            .map((source) => source.id == id ? updatedSource : source)
            .toList();

        state = state.copyWith(
          waterSources: updatedSources,
          selectedWaterSource: updatedSource,
        );

        _showSuccess('Alert resolved successfully!');
      }
    } catch (e) {
      _showError('Failed to resolve alert: $e');
    }
  }

  // Helper methods
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message);
  }
}

// Provider
final waterSourceProvider =
    StateNotifierProvider<WaterSourceProvider, WaterSourceState>((ref) {
  final dio = ref.read(dioProvider);
  return WaterSourceProvider(dio, ref);
});
