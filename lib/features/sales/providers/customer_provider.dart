import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../models/customer.model.dart';

// ============================================
// PROVIDER STATE
// ============================================

class CustomerState {
  final bool isLoading;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final CustomerFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final CustomerStats? stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final bool hasMore;

  const CustomerState({
    this.isLoading = false,
    this.customers = const [],
    this.selectedCustomer,
    this.filters = const CustomerFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.stats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.hasMore = true,
  });

  CustomerState copyWith({
    bool? isLoading,
    List<Customer>? customers,
    Customer? selectedCustomer,
    CustomerFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    CustomerStats? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    bool? hasMore,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ============================================
// PROVIDER
// ============================================

class CustomerProvider extends StateNotifier<CustomerState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  CustomerProvider(this._dio, this._scaffoldKey)
      : super(const CustomerState()) {
    // Initial load when provider is created
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Wait a bit to ensure provider is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));
    await loadCustomers(refresh: true);
    await loadStats();
  }

  // -----------------------------------------------------------------
  // CRUD OPERATIONS
  // -----------------------------------------------------------------

  Future<void> loadCustomers({bool refresh = false}) async {
    // Prevent multiple concurrent loads
    if (state.isLoading && !refresh) return;

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final currentPage = refresh ? 1 : state.currentPage;
      final query = {
        'page': currentPage.toString(),
        'limit': '10',
        ...state.filters.toQueryParams(),
      };

      debugPrint('Loading customers - Page: $currentPage, Filters: ${state.filters.toQueryParams()}');

      final response = await _dio.get(
        '/v1/nawassco/sales/customers',
        queryParameters: query,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final data = response.data['data'] as List? ?? [];
        final pagination = response.data['pagination'] as Map<String, dynamic>? ?? {};

        debugPrint('Found ${data.length} customers in response');

        // Parse customers
        final List<Customer> customers = [];
        for (var json in data) {
          try {
            final customer = Customer.fromJson(json as Map<String, dynamic>);
            customers.add(customer);
          } catch (e) {
            debugPrint('Error parsing customer: $e');
            debugPrint('Problematic JSON: $json');
            continue;
          }
        }

        final totalPages = (pagination['pages'] ?? 1) as int;
        final totalItems = (pagination['total'] ?? 0) as int;
        final nextPage = (pagination['page'] ?? currentPage) as int;
        final hasMore = nextPage < totalPages;

        debugPrint('Pagination - Total: $totalItems, Pages: $totalPages, Current: $nextPage, Has More: $hasMore');

        state = state.copyWith(
          customers: refresh ? customers : [...state.customers, ...customers],
          totalPages: totalPages,
          totalItems: totalItems,
          currentPage: nextPage,
          isLoading: false,
          hasMore: hasMore,
          error: null,
        );

        debugPrint('Successfully loaded ${customers.length} customers. Total in state: ${state.customers.length}');
      } else {
        final errorMessage = response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Failed to load customers (Status: ${response.statusCode})';
        debugPrint('API Error: $errorMessage');
        _showError(errorMessage);
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in loadCustomers: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in loadCustomers: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error: ${e.toString()}',
      );
      ToastUtils.showErrorToast('Failed to load customers', key: _scaffoldKey);
    }
  }

  Future<void> loadCustomer(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      debugPrint('Loading customer details for ID: $id');

      final response = await _dio.get('/v1/nawassco/sales/customers/$id');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final customerData = response.data['data'] as Map<String, dynamic>?;
        if (customerData != null) {
          final customer = Customer.fromJson(customerData);
          state = state.copyWith(
            selectedCustomer: customer,
            isLoading: false,
            error: null,
          );
          debugPrint('Loaded customer: ${customer.displayName}');
        } else {
          _showError('Customer data is null');
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to load customer');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<Customer?> createCustomer(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      debugPrint('Creating customer with data: $data');

      final response = await _dio.post(
        '/v1/nawassco/sales/customers',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 201 && response.data != null && response.data['success'] == true) {
        final customerData = response.data['data'] as Map<String, dynamic>?;
        if (customerData != null) {
          final customer = Customer.fromJson(customerData);

          state = state.copyWith(
            customers: [customer, ...state.customers],
            selectedCustomer: customer,
            isCreating: false,
            error: null,
          );

          _showSuccess('Customer created successfully');
          debugPrint('Created customer: ${customer.displayName}');
          return customer;
        } else {
          _showError('Created customer data is null');
          return null;
        }
      } else {
        // Handle validation errors
        if (response.statusCode == 422) {
          final errors = response.data?['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              _showError(firstError.first.toString());
            } else {
              _showError('Validation failed');
            }
          } else {
            _showError(response.data?['message']?.toString() ?? 'Validation failed');
          }
        } else {
          _showError(response.data?['message']?.toString() ?? 'Failed to create customer');
        }
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }

  Future<Customer?> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      debugPrint('Updating customer $id with data: $data');

      final response = await _dio.put(
        '/v1/nawassco/sales/customers/$id',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedCustomerData = response.data['data'] as Map<String, dynamic>?;
        if (updatedCustomerData != null) {
          final updatedCustomer = Customer.fromJson(updatedCustomerData);

          final updatedCustomers = state.customers.map((customer) {
            return customer.id == id ? updatedCustomer : customer;
          }).toList();

          state = state.copyWith(
            customers: updatedCustomers,
            selectedCustomer: updatedCustomer,
            isUpdating: false,
            error: null,
          );

          _showSuccess('Customer updated successfully');
          debugPrint('Updated customer: ${updatedCustomer.displayName}');
          return updatedCustomer;
        } else {
          _showError('Updated customer data is null');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update customer');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      debugPrint('Deleting customer: $id');

      final response = await _dio.delete('/v1/nawassco/sales/customers/$id');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        // Remove from local state
        final updatedCustomers = state.customers
            .where((customer) => customer.id != id)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == id ? null : state.selectedCustomer,
          isDeleting: false,
          error: null,
        );

        _showSuccess('Customer deleted successfully');
        debugPrint('Deleted customer: $id');
        return true;
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to delete customer');
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  Future<void> loadStats() async {
    try {
      debugPrint('Loading customer stats');

      final response = await _dio.get('/v1/nawassco/sales/customers/stats');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final statsData = response.data['data'] as Map<String, dynamic>?;
        if (statsData != null) {
          final stats = CustomerStats.fromJson(statsData);
          state = state.copyWith(stats: stats);
          debugPrint('Loaded customer stats');
        }
      } else {
        debugPrint('Failed to load stats: ${response.data?['message']}');
      }
    } catch (e) {
      // Silently fail for stats - it's not critical
      debugPrint('Failed to load stats: $e');
    }
  }

  Future<Customer?> addService(String customerId, Map<String, dynamic> serviceData) async {
    try {
      debugPrint('Adding service to customer: $customerId');

      final response = await _dio.post(
        '/v1/nawassco/sales/customers/$customerId/services',
        data: serviceData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 201 && response.data != null && response.data['success'] == true) {
        final updatedCustomerData = response.data['data'] as Map<String, dynamic>?;
        if (updatedCustomerData != null) {
          final updatedCustomer = Customer.fromJson(updatedCustomerData);

          final updatedCustomers = state.customers.map((customer) {
            return customer.id == customerId ? updatedCustomer : customer;
          }).toList();

          state = state.copyWith(
            customers: updatedCustomers,
            selectedCustomer: state.selectedCustomer?.id == customerId ? updatedCustomer : state.selectedCustomer,
          );

          _showSuccess('Service added successfully');
          debugPrint('Added service to customer: ${updatedCustomer.displayName}');
          return updatedCustomer;
        } else {
          _showError('Updated customer data is null after adding service');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to add service');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Customer?> updateService(
      String customerId,
      String serviceId,
      Map<String, dynamic> serviceData,
      ) async {
    try {
      debugPrint('Updating service $serviceId for customer: $customerId');

      final response = await _dio.put(
        '/v1/nawassco/sales/customers/$customerId/services/$serviceId',
        data: serviceData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedCustomerData = response.data['data'] as Map<String, dynamic>?;
        if (updatedCustomerData != null) {
          final updatedCustomer = Customer.fromJson(updatedCustomerData);

          final updatedCustomers = state.customers.map((customer) {
            return customer.id == customerId ? updatedCustomer : customer;
          }).toList();

          state = state.copyWith(
            customers: updatedCustomers,
            selectedCustomer: state.selectedCustomer?.id == customerId ? updatedCustomer : state.selectedCustomer,
          );

          _showSuccess('Service updated successfully');
          debugPrint('Updated service for customer: ${updatedCustomer.displayName}');
          return updatedCustomer;
        } else {
          _showError('Updated customer data is null after updating service');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update service');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Customer?> deleteService(String customerId, String serviceId) async {
    try {
      debugPrint('Deleting service $serviceId from customer: $customerId');

      final response = await _dio.delete(
        '/v1/nawassco/sales/customers/$customerId/services/$serviceId',
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedCustomerData = response.data['data'] as Map<String, dynamic>?;
        if (updatedCustomerData != null) {
          final updatedCustomer = Customer.fromJson(updatedCustomerData);

          final updatedCustomers = state.customers.map((customer) {
            return customer.id == customerId ? updatedCustomer : customer;
          }).toList();

          state = state.copyWith(
            customers: updatedCustomers,
            selectedCustomer: state.selectedCustomer?.id == customerId ? updatedCustomer : state.selectedCustomer,
          );

          _showSuccess('Service deleted successfully');
          debugPrint('Deleted service from customer: ${updatedCustomer.displayName}');
          return updatedCustomer;
        } else {
          _showError('Updated customer data is null after deleting service');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to delete service');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // -----------------------------------------------------------------
  // STATE MANAGEMENT
  // -----------------------------------------------------------------

  void selectCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void updateFilters(CustomerFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      customers: [],
      hasMore: true,
    );
    loadCustomers(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const CustomerFilters(),
      currentPage: 1,
      customers: [],
      hasMore: true,
    );
    loadCustomers(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading && state.hasMore) {
      debugPrint('Loading next page: ${state.currentPage + 1}');
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadCustomers();
    }
  }

  void refreshData() {
    debugPrint('Refreshing customer data');
    state = state.copyWith(
      currentPage: 1,
      customers: [],
      hasMore: true,
    );
    loadCustomers(refresh: true);
    loadStats();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    debugPrint('Resetting customer provider state');
    state = const CustomerState();
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
      debugPrint('DioException: ${error.type}');
      debugPrint('Message: ${error.message}');
      debugPrint('Response: ${error.response?.data}');
      debugPrint('Status: ${error.response?.statusCode}');

      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Resource not found.';
      } else if (error.response?.statusCode == 409) {
        errorMessage = 'Customer already exists with this email or phone.';
      } else if (error.response?.statusCode == 422) {
        final data = error.response!.data;
        if (data is Map && data['errors'] != null) {
          // Handle validation errors
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = 'Validation error: ${firstError.toString()}';
            }
          } else {
            errorMessage = data['message']?.toString() ?? 'Validation failed';
          }
        } else if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
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
      } else if (error.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error. Please try again later.';
      } else if (error.type == DioExceptionType.cancel) {
        errorMessage = 'Request was cancelled.';
      } else if (error.type == DioExceptionType.unknown) {
        errorMessage = 'Network error. Please check your connection.';
      }
    } else {
      errorMessage = error.toString();
    }

    debugPrint('CustomerProvider Error: $errorMessage');

    state = state.copyWith(
        error: errorMessage,
        isLoading: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false
    );

    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================

final customerProvider = StateNotifierProvider<CustomerProvider, CustomerState>(
      (ref) {
    final dio = ref.read(dioProvider);

    // Use the global scaffoldMessengerKey from main.dart
    return CustomerProvider(dio, scaffoldMessengerKey);
  },
);