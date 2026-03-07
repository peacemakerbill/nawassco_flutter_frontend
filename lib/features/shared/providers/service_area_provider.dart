import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../models/service_area_model.dart';
import '../../../core/services/api_service.dart';

class ServiceAreaState {
  final List<ServiceArea> serviceAreas;
  final ServiceArea? selectedServiceArea;
  final bool isLoading;
  final String? error;
  final Map<AreaType, int> typeStats;
  final Map<String, dynamic>? totalStats;
  final String searchQuery;
  final AreaType? filterType;
  final ServiceStatus? filterStatus;
  final double? minCoverage;

  ServiceAreaState({
    this.serviceAreas = const [],
    this.selectedServiceArea,
    this.isLoading = false,
    this.error,
    this.typeStats = const {},
    this.totalStats,
    this.searchQuery = '',
    this.filterType,
    this.filterStatus,
    this.minCoverage,
  });

  ServiceAreaState copyWith({
    List<ServiceArea>? serviceAreas,
    ServiceArea? selectedServiceArea,
    bool? isLoading,
    String? error,
    Map<AreaType, int>? typeStats,
    Map<String, dynamic>? totalStats,
    String? searchQuery,
    AreaType? filterType,
    ServiceStatus? filterStatus,
    double? minCoverage,
  }) {
    return ServiceAreaState(
      serviceAreas: serviceAreas ?? this.serviceAreas,
      selectedServiceArea: selectedServiceArea ?? this.selectedServiceArea,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      typeStats: typeStats ?? this.typeStats,
      totalStats: totalStats ?? this.totalStats,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
      minCoverage: minCoverage ?? this.minCoverage,
    );
  }

  // Add filteredServiceAreas getter
  List<ServiceArea> get filteredServiceAreas {
    var filtered = serviceAreas;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((area) {
        return area.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            area.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
            area.contact.manager.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply type filter
    if (filterType != null) {
      filtered = filtered.where((area) => area.type == filterType).toList();
    }

    // Apply status filter
    if (filterStatus != null) {
      filtered = filtered.where((area) => area.status == filterStatus).toList();
    }

    // Apply coverage filter
    if (minCoverage != null) {
      filtered = filtered
          .where((area) => area.coverage.waterCoverage >= minCoverage!)
          .toList();
    }

    return filtered;
  }
}

class ServiceAreaProvider extends StateNotifier<ServiceAreaState> {
  final Dio dio;
  final Ref ref;

  ServiceAreaProvider(this.dio, this.ref) : super(ServiceAreaState()) {
    loadServiceAreas();
    loadStats();
  }

  // Load all service areas
  Future<void> loadServiceAreas() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/service-areas');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final serviceAreas = data
            .map((item) => ServiceArea.fromJson(item))
            .cast<ServiceArea>()
            .toList();

        state = state.copyWith(
          serviceAreas: serviceAreas,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load service areas',
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

  // Get service area by ID
  Future<ServiceArea?> getServiceAreaById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/service-areas/$id');

      if (response.data['success'] == true) {
        final serviceArea = ServiceArea.fromJson(response.data['data']);
        state = state.copyWith(
          selectedServiceArea: serviceArea,
          isLoading: false,
        );
        return serviceArea;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load service area',
          isLoading: false,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  // Create new service area
  Future<bool> createServiceArea(ServiceArea serviceArea) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/services/service-areas',
        data: serviceArea.toJson(),
      );

      if (response.data['success'] == true) {
        final newServiceArea = ServiceArea.fromJson(response.data['data']);
        final updatedList = [...state.serviceAreas, newServiceArea];
        state = state.copyWith(
          serviceAreas: updatedList,
          isLoading: false,
        );
        await loadStats(); // Refresh stats
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create service area',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Update existing service area
  Future<bool> updateServiceArea(String id, ServiceArea serviceArea) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/services/service-areas/$id',
        data: serviceArea.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedServiceArea = ServiceArea.fromJson(response.data['data']);
        final updatedList = state.serviceAreas.map((area) {
          return area.id == id ? updatedServiceArea : area;
        }).toList();

        state = state.copyWith(
          serviceAreas: updatedList,
          selectedServiceArea: updatedServiceArea,
          isLoading: false,
        );
        await loadStats(); // Refresh stats
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update service area',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Delete service area
  Future<bool> deleteServiceArea(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/services/service-areas/$id');

      if (response.data['success'] == true) {
        final updatedList =
        state.serviceAreas.where((area) => area.id != id).toList();
        state = state.copyWith(
          serviceAreas: updatedList,
          selectedServiceArea: null,
          isLoading: false,
        );
        await loadStats(); // Refresh stats
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete service area',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Load statistics
  Future<void> loadStats() async {
    try {
      final response = await dio.get('/v1/nawassco/services/service-areas/stats');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final byType = data['byType'] as List;
        final totals = data['totals'] as Map<String, dynamic>;

        final typeStats = <AreaType, int>{};
        for (final item in byType) {
          final type = AreaType.values.firstWhere(
                (e) => e.name == item['_id'],
            orElse: () => AreaType.urban,
          );
          typeStats[type] = item['count'] as int;
        }

        state = state.copyWith(
          typeStats: typeStats,
          totalStats: totals,
        );
      }
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  // Set filters
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(AreaType? type) {
    state = state.copyWith(filterType: type);
  }

  void setFilterStatus(ServiceStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  void setMinCoverage(double? coverage) {
    state = state.copyWith(minCoverage: coverage);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      filterType: null,
      filterStatus: null,
      minCoverage: null,
    );
  }

  void selectServiceArea(ServiceArea? area) {
    state = state.copyWith(selectedServiceArea: area);
  }
}

// Provider
final serviceAreaProvider =
StateNotifierProvider<ServiceAreaProvider, ServiceAreaState>((ref) {
  final dio = ref.read(dioProvider);
  return ServiceAreaProvider(dio, ref);
});