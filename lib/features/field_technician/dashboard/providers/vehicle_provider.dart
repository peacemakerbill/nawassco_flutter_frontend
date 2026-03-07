import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/vehicle.dart';

class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final VehicleStatus? statusFilter;
  final VehicleType? typeFilter;
  final Map<String, dynamic> metrics;

  const VehicleState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.statusFilter,
    this.typeFilter,
    this.metrics = const {},
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    bool? isLoading,
    String? error,
    String? searchQuery,
    VehicleStatus? statusFilter,
    VehicleType? typeFilter,
    Map<String, dynamic>? metrics,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      metrics: metrics ?? this.metrics,
    );
  }

  List<Vehicle> get filteredVehicles {
    var filtered = vehicles;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((vehicle) =>
      vehicle.registrationNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          vehicle.make.toLowerCase().contains(searchQuery.toLowerCase()) ||
          vehicle.model.toLowerCase().contains(searchQuery.toLowerCase()) ||
          vehicle.color.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    if (statusFilter != null) {
      filtered = filtered.where((vehicle) => vehicle.status == statusFilter).toList();
    }

    // Apply type filter
    if (typeFilter != null) {
      filtered = filtered.where((vehicle) => vehicle.vehicleType == typeFilter).toList();
    }

    return filtered;
  }
}

class VehicleProvider extends StateNotifier<VehicleState> {
  final Dio dio;

  VehicleProvider(this.dio) : super(const VehicleState());

  // Load all vehicles
  Future<void> loadVehicles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/vehicles');

      if (response.data['success'] == true) {
        final List<Vehicle> vehicles = (response.data['data']['result']['vehicles'] as List)
            .map((vehicleData) => Vehicle.fromJson(vehicleData))
            .toList();

        state = state.copyWith(
          vehicles: vehicles,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load vehicles',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load vehicles: $e',
        isLoading: false,
      );
    }
  }

  // Load vehicle by ID
  Future<void> loadVehicleById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/vehicles/$id');

      if (response.data['success'] == true) {
        final vehicle = Vehicle.fromJson(response.data['data']['vehicle']);
        state = state.copyWith(
          selectedVehicle: vehicle,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load vehicle',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load vehicle: $e',
        isLoading: false,
      );
    }
  }

  // Create vehicle
  Future<bool> createVehicle(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.post('/v1/nawassco/field_technician/vehicles', data: data);

      if (response.data['success'] == true) {
        await loadVehicles(); // Reload the list
        await loadMetrics(); // Reload metrics
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create vehicle',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create vehicle: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update vehicle
  Future<bool> updateVehicle(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.put('/v1/nawassco/field_technician/vehicles/$id', data: data);

      if (response.data['success'] == true) {
        final updatedVehicle = Vehicle.fromJson(response.data['data']['vehicle']);

        // Update in vehicles list
        final updatedVehicles = state.vehicles.map((vehicle) =>
        vehicle.id == id ? updatedVehicle : vehicle
        ).toList();

        // Update selected vehicle if it's the same
        final selectedVehicle = state.selectedVehicle?.id == id ? updatedVehicle : state.selectedVehicle;

        state = state.copyWith(
          vehicles: updatedVehicles,
          selectedVehicle: selectedVehicle,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update vehicle',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update vehicle: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.delete('/v1/nawassco/field_technician/vehicles/$id');

      if (response.data['success'] == true) {
        // Remove from vehicles list
        final updatedVehicles = state.vehicles.where((vehicle) => vehicle.id != id).toList();

        // Clear selected vehicle if it's the same
        final selectedVehicle = state.selectedVehicle?.id == id ? null : state.selectedVehicle;

        state = state.copyWith(
          vehicles: updatedVehicles,
          selectedVehicle: selectedVehicle,
          isLoading: false,
        );
        await loadMetrics(); // Reload metrics
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete vehicle',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete vehicle: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Assign vehicle to technician
  Future<bool> assignVehicle(String vehicleId, String technicianId) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/vehicles/$vehicleId/assign', data: {
        'technicianId': technicianId,
      });

      if (response.data['success'] == true) {
        final updatedVehicle = Vehicle.fromJson(response.data['data']['vehicle']);

        // Update in vehicles list
        final updatedVehicles = state.vehicles.map((vehicle) =>
        vehicle.id == vehicleId ? updatedVehicle : vehicle
        ).toList();

        // Update selected vehicle if it's the same
        final selectedVehicle = state.selectedVehicle?.id == vehicleId ? updatedVehicle : state.selectedVehicle;

        state = state.copyWith(
          vehicles: updatedVehicles,
          selectedVehicle: selectedVehicle,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Unassign vehicle
  Future<bool> unassignVehicle(String vehicleId) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/vehicles/$vehicleId/unassign');

      if (response.data['success'] == true) {
        final updatedVehicle = Vehicle.fromJson(response.data['data']['vehicle']);

        // Update in vehicles list
        final updatedVehicles = state.vehicles.map((vehicle) =>
        vehicle.id == vehicleId ? updatedVehicle : vehicle
        ).toList();

        // Update selected vehicle if it's the same
        final selectedVehicle = state.selectedVehicle?.id == vehicleId ? updatedVehicle : state.selectedVehicle;

        state = state.copyWith(
          vehicles: updatedVehicles,
          selectedVehicle: selectedVehicle,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update vehicle status
  Future<bool> updateVehicleStatus(String id, VehicleStatus status, OperationalStatus operationalStatus) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/vehicles/$id/status', data: {
        'status': status.name,
        'operationalStatus': operationalStatus.name,
      });

      if (response.data['success'] == true) {
        final updatedVehicle = Vehicle.fromJson(response.data['data']['vehicle']);

        // Update in vehicles list
        final updatedVehicles = state.vehicles.map((vehicle) =>
        vehicle.id == id ? updatedVehicle : vehicle
        ).toList();

        // Update selected vehicle if it's the same
        final selectedVehicle = state.selectedVehicle?.id == id ? updatedVehicle : state.selectedVehicle;

        state = state.copyWith(
          vehicles: updatedVehicles,
          selectedVehicle: selectedVehicle,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Load vehicle metrics
  Future<void> loadMetrics() async {
    try {
      final response = await dio.get('/v1/nawassco/field_technician/vehicles/metrics');

      if (response.data['success'] == true) {
        state = state.copyWith(metrics: response.data['data']['metrics']);
      }
    } catch (e) {
      // Silently fail metrics loading
    }
  }

  // Search vehicles
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set status filter
  void setStatusFilter(VehicleStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  // Set type filter
  void setTypeFilter(VehicleType? type) {
    state = state.copyWith(typeFilter: type);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: null,
      typeFilter: null,
    );
  }

  // Select vehicle
  void selectVehicle(Vehicle? vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final vehicleProvider = StateNotifierProvider<VehicleProvider, VehicleState>((ref) {
  final dio = ref.read(dioProvider);
  return VehicleProvider(dio);
});