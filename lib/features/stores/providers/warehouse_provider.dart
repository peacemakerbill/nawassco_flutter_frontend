import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/warehouse_model.dart';
import '../../../core/services/api_service.dart';

enum WarehouseView {
  list,
  details,
  create,
  edit,
  utilization
}

class WarehouseState {
  final List<Warehouse> warehouses;
  final Warehouse? selectedWarehouse;
  final bool isLoading;
  final String? error;
  final bool isSaving;
  final Map<String, dynamic>? utilizationData;
  final Map<String, dynamic>? performanceData;
  final String searchQuery;
  final WarehouseStatus? statusFilter;
  final String? cityFilter;
  final WarehouseView currentView;

  WarehouseState({
    this.warehouses = const [],
    this.selectedWarehouse,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
    this.utilizationData,
    this.performanceData,
    this.searchQuery = '',
    this.statusFilter,
    this.cityFilter,
    this.currentView = WarehouseView.list,
  });

  WarehouseState copyWith({
    List<Warehouse>? warehouses,
    Warehouse? selectedWarehouse,
    bool? isLoading,
    String? error,
    bool? isSaving,
    Map<String, dynamic>? utilizationData,
    Map<String, dynamic>? performanceData,
    String? searchQuery,
    WarehouseStatus? statusFilter,
    String? cityFilter,
    WarehouseView? currentView,
  }) {
    return WarehouseState(
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
      utilizationData: utilizationData ?? this.utilizationData,
      performanceData: performanceData ?? this.performanceData,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      cityFilter: cityFilter ?? this.cityFilter,
      currentView: currentView ?? this.currentView,
    );
  }
}

class WarehouseProvider extends StateNotifier<WarehouseState> {
  final Dio dio;

  WarehouseProvider(this.dio) : super(WarehouseState());

  // Navigation
  void showListView() {
    state = state.copyWith(
      currentView: WarehouseView.list,
      selectedWarehouse: null,
    );
  }

  void showCreateView() {
    state = state.copyWith(currentView: WarehouseView.create);
  }

  void showEditView(Warehouse warehouse) {
    state = state.copyWith(
      currentView: WarehouseView.edit,
      selectedWarehouse: warehouse,
    );
  }

  void showDetailsView(Warehouse warehouse) {
    state = state.copyWith(
      currentView: WarehouseView.details,
      selectedWarehouse: warehouse,
    );
  }

  void showUtilizationView(Warehouse warehouse) {
    state = state.copyWith(
      currentView: WarehouseView.utilization,
      selectedWarehouse: warehouse,
    );
  }

  // Get all warehouses
  Future<void> getWarehouses() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final params = <String, dynamic>{};
      if (state.searchQuery.isNotEmpty) {
        params['search'] = state.searchQuery;
      }
      if (state.statusFilter != null) {
        params['status'] = state.statusFilter!.name;
      }
      if (state.cityFilter != null && state.cityFilter!.isNotEmpty) {
        params['city'] = state.cityFilter;
      }

      final response = await dio.get('/v1/nawassco/stores/warehouses', queryParameters: params);

      if (response.data['success'] == true) {
        final warehouses = List<Warehouse>.from(
            response.data['data'].map((x) => Warehouse.fromJson(x))
        );
        state = state.copyWith(warehouses: warehouses, isLoading: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load warehouses');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Get warehouse by ID
  Future<void> getWarehouseById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/stores/warehouses/$id');

      if (response.data['success'] == true) {
        final warehouse = Warehouse.fromJson(response.data['data']);
        state = state.copyWith(selectedWarehouse: warehouse, isLoading: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load warehouse');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Create warehouse
  Future<void> createWarehouse(Warehouse data) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.post('/v1/nawassco/stores/warehouses', data: data.toJson());

      if (response.data['success'] == true) {
        final warehouse = Warehouse.fromJson(response.data['data']);
        state = state.copyWith(
          warehouses: [...state.warehouses, warehouse],
          isSaving: false,
          currentView: WarehouseView.list,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create warehouse');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Update warehouse
  Future<void> updateWarehouse(String id, Warehouse data) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.patch('/v1/nawassco/stores/warehouses/$id', data: data.toJson());

      if (response.data['success'] == true) {
        final updatedWarehouse = Warehouse.fromJson(response.data['data']);
        final updatedWarehouses = state.warehouses.map((w) =>
        w.id == id ? updatedWarehouse : w
        ).toList();

        state = state.copyWith(
          warehouses: updatedWarehouses,
          selectedWarehouse: updatedWarehouse,
          isSaving: false,
          currentView: WarehouseView.details,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update warehouse');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Add zone to warehouse
  Future<void> addZone(String warehouseId, WarehouseZone zone) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/stores/warehouses/$warehouseId/zones',
        data: zone.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedWarehouse = Warehouse.fromJson(response.data['data']);
        final updatedWarehouses = state.warehouses.map((w) =>
        w.id == warehouseId ? updatedWarehouse : w
        ).toList();

        state = state.copyWith(
          warehouses: updatedWarehouses,
          selectedWarehouse: updatedWarehouse,
          isSaving: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add zone');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Get warehouse utilization
  Future<void> getWarehouseUtilization(String warehouseId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await dio.get('/v1/nawassco/stores/warehouses/$warehouseId/utilization');

      if (response.data['success'] == true) {
        state = state.copyWith(
          utilizationData: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load utilization data');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set status filter
  void setStatusFilter(WarehouseStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  // Set city filter
  void setCityFilter(String? city) {
    state = state.copyWith(cityFilter: city);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: null,
      cityFilter: null,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final warehouseProvider = StateNotifierProvider<WarehouseProvider, WarehouseState>((ref) {
  final dio = ref.read(dioProvider);
  return WarehouseProvider(dio);
});