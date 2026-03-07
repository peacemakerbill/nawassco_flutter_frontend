import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/supplier_model.dart';

class SupplierState {
  final List<Supplier> suppliers;
  final Supplier? selectedSupplier;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? filters;

  SupplierState({
    this.suppliers = const [],
    this.selectedSupplier,
    this.isLoading = false,
    this.error,
    this.filters,
  });

  SupplierState copyWith({
    List<Supplier>? suppliers,
    Supplier? selectedSupplier,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
  }) {
    return SupplierState(
      suppliers: suppliers ?? this.suppliers,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
    );
  }
}

class SupplierProvider extends StateNotifier<SupplierState> {
  final Dio dio;

  SupplierProvider(this.dio) : super(SupplierState());

  // Get all suppliers
  Future<void> getAllSuppliers({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/suppliers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<Supplier> suppliers = (response.data['data'] as List)
            .map((item) => Supplier.fromJson(item))
            .toList();

        state = state.copyWith(
          suppliers: suppliers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch suppliers',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch suppliers: $e',
        isLoading: false,
      );
    }
  }

  // Get supplier by ID
  Future<void> getSupplierById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/suppliers/$id');

      if (response.data['success'] == true) {
        final Supplier supplier = Supplier.fromJson(response.data['data']);

        state = state.copyWith(
          selectedSupplier: supplier,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch supplier',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch supplier: $e',
        isLoading: false,
      );
    }
  }

  // Create supplier
  Future<bool> createSupplier(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/suppliers', data: data);

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update supplier
  Future<bool> updateSupplier(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/supplier/suppliers/$id', data: data);

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete supplier
  Future<bool> deleteSupplier(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/supplier/suppliers/$id');

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Approve supplier
  Future<bool> approveSupplier(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/suppliers/$id/approve');

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to approve supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to approve supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Blacklist supplier
  Future<bool> blacklistSupplier(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/suppliers/$id/blacklist', data: data);

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to blacklist supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to blacklist supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Reinstate supplier
  Future<bool> reinstateSupplier(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/suppliers/$id/reinstate', data: data);

      if (response.data['success'] == true) {
        await getAllSuppliers();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to reinstate supplier',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reinstate supplier: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Get suppliers by category
  Future<void> getSuppliersByCategory(String category, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/suppliers/category/$category', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<Supplier> suppliers = (response.data['data'] as List)
            .map((item) => Supplier.fromJson(item))
            .toList();

        state = state.copyWith(
          suppliers: suppliers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch suppliers by category',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch suppliers by category: $e',
        isLoading: false,
      );
    }
  }

  // Get supplier statistics
  Future<Map<String, dynamic>?> getSupplierStats() async {
    try {
      final response = await dio.get('/v1/nawassco/supplier/suppliers/stats');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected supplier
  void clearSelectedSupplier() {
    state = state.copyWith(selectedSupplier: null);
  }
}

final supplierProvider = StateNotifierProvider<SupplierProvider, SupplierState>((ref) {
  final dio = ref.read(dioProvider);
  return SupplierProvider(dio);
});