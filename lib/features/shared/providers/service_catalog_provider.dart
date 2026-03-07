import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';

import '../models/service_catalog_model.dart';

class ServiceCatalogState {
  final List<ServiceCatalog> services;
  final List<ServiceCatalog> filteredServices;
  final ServiceCatalog? selectedService;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> stats;
  final List<ServiceCatalog> popularServices;
  final Map<String, dynamic>? availabilityCheck;

  const ServiceCatalogState({
    this.services = const [],
    this.filteredServices = const [],
    this.selectedService,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.stats = const {},
    this.popularServices = const [],
    this.availabilityCheck,
  });

  ServiceCatalogState copyWith({
    List<ServiceCatalog>? services,
    List<ServiceCatalog>? filteredServices,
    ServiceCatalog? selectedService,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? stats,
    List<ServiceCatalog>? popularServices,
    Map<String, dynamic>? availabilityCheck,
  }) {
    return ServiceCatalogState(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedService: selectedService ?? this.selectedService,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      stats: stats ?? this.stats,
      popularServices: popularServices ?? this.popularServices,
      availabilityCheck: availabilityCheck ?? this.availabilityCheck,
    );
  }
}

class ServiceCatalogProvider extends StateNotifier<ServiceCatalogState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  ServiceCatalogProvider(this.dio, this.scaffoldMessengerKey)
      : super(const ServiceCatalogState());

  // Check if provider is mounted
  bool get isMounted => mounted;

  // -----------------------------------------------------------------
  // FETCH ALL SERVICES
  // -----------------------------------------------------------------
  Future<void> fetchServices({Map<String, dynamic>? filter}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': 1,
        'limit': 100,
        ...?filter,
      };

      final response =
          await dio.get('/v1/nawassco/services/service-catalog', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<dynamic> data =
            response.data['data']?['data'] ?? response.data['data'] ?? [];
        final services =
            data.map((json) => ServiceCatalog.fromJson(json)).toList();

        state = state.copyWith(
          services: services,
          filteredServices: _applyFilters(services, state.filters),
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch services';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // FETCH SERVICE BY ID
  // -----------------------------------------------------------------
  Future<void> fetchServiceById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/service-catalog/$id');

      if (response.data['success'] == true) {
        final service = ServiceCatalog.fromJson(response.data['data']);
        state = state.copyWith(
          selectedService: service,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch service';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // CREATE SERVICE
  // -----------------------------------------------------------------
  Future<ServiceCatalog?> createService(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/services/service-catalog', data: data);

      if (response.data['success'] == true) {
        final service = ServiceCatalog.fromJson(response.data['data']);

        _showSuccessToast('Service created successfully!');

        // Update state
        state = state.copyWith(
          services: [service, ...state.services],
          filteredServices: [service, ...state.filteredServices],
          selectedService: service,
          isLoading: false,
        );

        return service;
      } else {
        throw response.data['message'] ?? 'Failed to create service';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE SERVICE
  // -----------------------------------------------------------------
  Future<ServiceCatalog?> updateService(
      String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put('/v1/nawassco/services/service-catalog/$id', data: data);

      if (response.data['success'] == true) {
        final updatedService = ServiceCatalog.fromJson(response.data['data']);

        _showSuccessToast('Service updated successfully!');

        // Update in lists
        final updatedServices = state.services.map((service) {
          return service.id == id ? updatedService : service;
        }).toList();

        state = state.copyWith(
          services: updatedServices,
          filteredServices: _applyFilters(updatedServices, state.filters),
          selectedService: updatedService,
          isLoading: false,
        );

        return updatedService;
      } else {
        throw response.data['message'] ?? 'Failed to update service';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  // -----------------------------------------------------------------
  // DELETE SERVICE
  // -----------------------------------------------------------------
  Future<bool> deleteService(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/services/service-catalog/$id');

      if (response.data['success'] == true) {
        _showSuccessToast('Service deleted successfully!');

        // Remove from lists
        final updatedServices =
            state.services.where((s) => s.id != id).toList();

        state = state.copyWith(
          services: updatedServices,
          filteredServices: _applyFilters(updatedServices, state.filters),
          selectedService:
              state.selectedService?.id == id ? null : state.selectedService,
          isLoading: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to delete service';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE SERVICE STATUS
  // -----------------------------------------------------------------
  Future<void> updateServiceStatus(String id, String status) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio
          .put('/v1/nawassco/services/service-catalog/$id/status', data: {'status': status});

      if (response.data['success'] == true) {
        final updatedService = ServiceCatalog.fromJson(response.data['data']);

        _showSuccessToast('Service status updated!');

        // Update in lists
        final updatedServices = state.services.map((service) {
          return service.id == id ? updatedService : service;
        }).toList();

        state = state.copyWith(
          services: updatedServices,
          filteredServices: _applyFilters(updatedServices, state.filters),
          selectedService: updatedService,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to update service status';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // FETCH STATISTICS
  // -----------------------------------------------------------------
  Future<void> fetchStatistics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/service-catalog/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'] ?? {},
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch statistics';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // FETCH POPULAR SERVICES
  // -----------------------------------------------------------------
  Future<void> fetchPopularServices({int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio
          .get('/v1/nawassco/services/service-catalog/popular', queryParameters: {'limit': limit});

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final services =
            data.map((json) => ServiceCatalog.fromJson(json)).toList();

        state = state.copyWith(
          popularServices: services,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch popular services';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // VALIDATE SERVICE AVAILABILITY
  // -----------------------------------------------------------------
  Future<void> validateAvailability(
      String serviceId, String areaId, String customerType) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await dio.post('/v1/nawassco/services/service-catalog/availability/validate', data: {
        'serviceId': serviceId,
        'areaId': areaId,
        'customerType': customerType,
      });

      if (response.data['success'] == true) {
        state = state.copyWith(
          availabilityCheck: response.data['data'],
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to validate availability';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // FILTER SERVICES
  // -----------------------------------------------------------------
  void applyFilters(Map<String, dynamic> filters) {
    final filtered = _applyFilters(state.services, filters);
    state = state.copyWith(
      filters: filters,
      filteredServices: filtered,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      filters: {},
      filteredServices: state.services,
    );
  }

  List<ServiceCatalog> _applyFilters(
      List<ServiceCatalog> services, Map<String, dynamic> filters) {
    if (filters.isEmpty) return services;

    var filtered = List<ServiceCatalog>.from(services);

    // Filter by category
    if (filters.containsKey('category') && filters['category'] != null) {
      filtered = filtered
          .where((s) => s.category.name == filters['category'])
          .toList();
    }

    // Filter by status
    if (filters.containsKey('status') && filters['status'] != null) {
      filtered =
          filtered.where((s) => s.status.name == filters['status']).toList();
    }

    // Filter by price range
    if (filters.containsKey('minPrice') && filters['minPrice'] != null) {
      filtered = filtered
          .where((s) => s.pricing.basePrice >= (filters['minPrice'] as double))
          .toList();
    }

    if (filters.containsKey('maxPrice') && filters['maxPrice'] != null) {
      filtered = filtered
          .where((s) => s.pricing.basePrice <= (filters['maxPrice'] as double))
          .toList();
    }

    // Filter by search term
    if (filters.containsKey('search') && filters['search'] != null) {
      final search = (filters['search'] as String).toLowerCase();
      filtered = filtered
          .where((s) =>
              s.name.toLowerCase().contains(search) ||
              s.description.toLowerCase().contains(search) ||
              s.serviceCode.toLowerCase().contains(search))
          .toList();
    }

    // Filter by customer type
    if (filters.containsKey('customerType') &&
        filters['customerType'] != null) {
      final customerType = (filters['customerType'] as String).toLowerCase();
      filtered = filtered
          .where((s) =>
              s.eligibility.customerTypes
                  .any((ct) => ct.name == customerType) ||
              s.eligibility.customerTypes.contains(CustomerType.all))
          .toList();
    }

    return filtered;
  }

  // -----------------------------------------------------------------
  // DUPLICATE SERVICE
  // -----------------------------------------------------------------
  Future<void> duplicateService(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/services/service-catalog/$id/duplicate');

      if (response.data['success'] == true) {
        final duplicated = ServiceCatalog.fromJson(response.data['data']);

        _showSuccessToast('Service duplicated successfully!');

        state = state.copyWith(
          services: [duplicated, ...state.services],
          filteredServices: [duplicated, ...state.filteredServices],
          selectedService: duplicated,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to duplicate service';
      }
    } catch (error) {
      _handleError(error);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // SELECT SERVICE
  // -----------------------------------------------------------------
  void selectService(ServiceCatalog service) {
    state = state.copyWith(selectedService: service);
  }

  void clearSelection() {
    state = state.copyWith(selectedService: null);
  }

  // -----------------------------------------------------------------
  // HELPER METHODS
  // -----------------------------------------------------------------
  void _showSuccessToast(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
    });
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred.';

    if (error is DioException) {
      if (error.response?.data != null && error.response!.data is Map) {
        errorMessage = error.response!.data['message'] ?? errorMessage;
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    });
  }
}

// -----------------------------------------------------------------
// PROVIDER INSTANCE
// -----------------------------------------------------------------
final serviceCatalogProvider =
    StateNotifierProvider<ServiceCatalogProvider, ServiceCatalogState>((ref) {
  final dio = ref.read(dioProvider);
  return ServiceCatalogProvider(dio, scaffoldMessengerKey);
});
