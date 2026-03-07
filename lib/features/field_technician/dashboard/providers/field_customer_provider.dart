import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/field_customer.dart';

class FieldCustomerState {
  final List<FieldCustomer> customers;
  final FieldCustomer? selectedCustomer;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final Map<String, dynamic>? customerMetrics;
  final bool showCreateForm;
  final bool showDetails;
  final String? searchQuery;
  final bool showEditForm;

  const FieldCustomerState({
    this.customers = const [],
    this.selectedCustomer,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.customerMetrics,
    this.showCreateForm = false,
    this.showDetails = false,
    this.searchQuery,
    this.showEditForm = false,
  });

  FieldCustomerState copyWith({
    List<FieldCustomer>? customers,
    FieldCustomer? selectedCustomer,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    Map<String, dynamic>? customerMetrics,
    bool? showCreateForm,
    bool? showDetails,
    String? searchQuery,
    bool? showEditForm,
  }) {
    return FieldCustomerState(
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      customerMetrics: customerMetrics ?? this.customerMetrics,
      showCreateForm: showCreateForm ?? this.showCreateForm,
      showDetails: showDetails ?? this.showDetails,
      searchQuery: searchQuery ?? this.searchQuery,
      showEditForm: showEditForm ?? this.showEditForm,
    );
  }
}

class FieldCustomerProvider extends StateNotifier<FieldCustomerState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  FieldCustomerProvider(this._dio, this._scaffoldMessengerKey)
      : super(const FieldCustomerState());

  // ============ CORE CRUD OPERATIONS ============

  Future<void> getFieldCustomers({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: page,
      );

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
        ...state.filters,
      };

      final response =
          await _dio.get('/v1/nawassco/field_technician/field-customers', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final customersData = data['customers'] as List? ?? [];
        final pagination = data['pagination'] ?? {};

        final customers =
            customersData.map((c) => FieldCustomer.fromJson(c)).toList();

        final newCustomers =
            loadMore ? [...state.customers, ...customers] : customers;

        state = state.copyWith(
          customers: newCustomers,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) <
              (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load customers');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load customers: $error');
    }
  }

  Future<void> getFieldCustomerById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/field-customers/$id');

      if (response.data['success'] == true) {
        final customerData = response.data['data']['fieldCustomer'];
        final customer = FieldCustomer.fromJson(customerData);

        state = state.copyWith(
          selectedCustomer: customer,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load customer');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load customer: $error');
    }
  }

  Future<bool> createFieldCustomer(FieldCustomer customer) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.post('/v1/nawassco/field_technician/field-customers', data: customer.toJson());

      if (response.data['success'] == true) {
        final newCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        state = state.copyWith(
          customers: [newCustomer, ...state.customers],
          isLoading: false,
          showCreateForm: false,
        );

        _showSuccess('Customer created successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to create customer');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to create customer: $error');
      return false;
    }
  }

  Future<bool> updateFieldCustomer(
      String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.put('/v1/nawassco/field_technician/field-customers/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == id ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == id
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
          showEditForm: false,
        );

        _showSuccess('Customer updated successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to update customer');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update customer: $error');
      return false;
    }
  }

  Future<bool> deleteFieldCustomer(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/v1/nawassco/field_technician/field-customers/$id');

      if (response.data['success'] == true) {
        final updatedCustomers =
            state.customers.where((c) => c.id != id).toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer:
              state.selectedCustomer?.id == id ? null : state.selectedCustomer,
          showDetails:
              state.selectedCustomer?.id == id ? false : state.showDetails,
          isLoading: false,
        );

        _showSuccess('Customer deleted successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to delete customer');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to delete customer: $error');
      return false;
    }
  }

  // ============ SPECIFIC OPERATIONS ============

  Future<bool> updateAccountStatus(
      String id, AccountStatus status, String? reason) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-customers/$id/status',
        data: {
          'status': status.name,
          'reason': reason,
        },
      );

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == id ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == id
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
        );

        _showSuccess('Account status updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update status: $error');
      return false;
    }
  }

  Future<bool> recordPayment(String customerId, PaymentRecord payment) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-customers/$customerId/payments',
        data: payment.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == customerId ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == customerId
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
        );

        _showSuccess('Payment recorded successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to record payment');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to record payment: $error');
      return false;
    }
  }

  Future<bool> addServiceHistory(
      String customerId, ServiceHistory service) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-customers/$customerId/service-history',
        data: {
          'serviceDate': service.serviceDate.toIso8601String(),
          'serviceType': service.serviceType,
          'description': service.description,
          'technician': service.technicianId,
          'workOrder': service.workOrderId,
          if (service.rating != null) 'rating': service.rating,
          if (service.feedback != null) 'feedback': service.feedback,
        },
      );

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == customerId ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == customerId
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
        );

        _showSuccess('Service history added successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to add service history');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to add service history: $error');
      return false;
    }
  }

  Future<bool> updateBillingInformation(
      String customerId, BillingInformation billing) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-customers/$customerId/controller',
        data: billing.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == customerId ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == customerId
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
        );

        _showSuccess('Billing information updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update controller');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update controller: $error');
      return false;
    }
  }

  Future<bool> updateCommunicationPreferences(
      String customerId, CommunicationPreferences preferences) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-customers/$customerId/communication-preferences',
        data: preferences.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedCustomer =
            FieldCustomer.fromJson(response.data['data']['fieldCustomer']);

        final updatedCustomers = state.customers
            .map((c) => c.id == customerId ? updatedCustomer : c)
            .toList();

        state = state.copyWith(
          customers: updatedCustomers,
          selectedCustomer: state.selectedCustomer?.id == customerId
              ? updatedCustomer
              : state.selectedCustomer,
          isLoading: false,
        );

        _showSuccess('Communication preferences updated successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to update preferences');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to update preferences: $error');
      return false;
    }
  }

  Future<void> getCustomerMetrics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/field-customers/metrics');

      if (response.data['success'] == true) {
        state = state.copyWith(
          customerMetrics: response.data['data']['metrics'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load metrics');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load metrics: $error');
    }
  }

  Future<void> searchFieldCustomers(String query,
      {int page = 1, int limit = 20}) async {
    try {
      state = state.copyWith(isLoading: true, error: null, searchQuery: query);

      final response =
          await _dio.get('/v1/nawassco/field_technician/field-customers/search', queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final customersData = data['customers'] as List? ?? [];
        final pagination = data['pagination'] ?? {};

        final customers =
            customersData.map((c) => FieldCustomer.fromJson(c)).toList();

        state = state.copyWith(
          customers: customers,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) <
              (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Search failed');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Search failed: $error');
    }
  }

  Future<void> getCustomersByZone(String zone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.get('/v1/nawassco/field_technician/field-customers/by-zone', queryParameters: {
        'zone': zone,
      });

      if (response.data['success'] == true) {
        final customersData = response.data['data']['customers'] as List? ?? [];
        final customers =
            customersData.map((c) => FieldCustomer.fromJson(c)).toList();

        state = state.copyWith(
          customers: customers,
          isLoading: false,
          filters: {'zone': zone},
        );
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load zone customers');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load zone customers: $error');
    }
  }

  // ============ UI STATE MANAGEMENT ============

  void showCreateCustomerForm() {
    state = state.copyWith(
      showCreateForm: true,
      showDetails: false,
      showEditForm: false,
    );
  }

  void showCustomerDetails(FieldCustomer customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      showDetails: true,
      showCreateForm: false,
      showEditForm: false,
    );
  }

  void showEditCustomerForm(FieldCustomer customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      showEditForm: true,
      showDetails: false,
      showCreateForm: false,
    );
  }

  void closeAllForms() {
    state = state.copyWith(
      showCreateForm: false,
      showDetails: false,
      showEditForm: false,
      selectedCustomer: null,
    );
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: null);
    getFieldCustomers();
  }

  void setFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
    getFieldCustomers(page: 1);
  }

  void clearFilters() {
    state = state.copyWith(filters: {});
    getFieldCustomers(page: 1);
  }

  Future<void> refreshCustomers() async {
    state = state.copyWith(isLoading: true);
    await getFieldCustomers();
  }

  Future<void> loadMoreCustomers() async {
    if (state.hasMore && !state.isLoading) {
      await getFieldCustomers(
        page: state.currentPage + 1,
        loadMore: true,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // ============ HELPER METHODS ============

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }

  // ============ STATISTICS METHODS ============

  int getTotalCustomers() => state.customers.length;

  int getActiveCustomers() => state.customers
      .where((c) => c.accountStatus == AccountStatus.active)
      .length;

  int getSuspendedCustomers() => state.customers
      .where((c) => c.accountStatus == AccountStatus.suspended)
      .length;

  int getDisconnectedCustomers() => state.customers
      .where((c) => c.accountStatus == AccountStatus.disconnected)
      .length;

  double getTotalOutstandingBalance() =>
      state.customers.fold<double>(0, (sum, c) => sum + c.currentBalance);

  List<FieldCustomer> getTopDebtors() =>
      state.customers.where((c) => c.currentBalance > 0).toList()
        ..sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
}

// ============ PROVIDER DECLARATIONS ============

final fieldCustomerProvider =
    StateNotifierProvider<FieldCustomerProvider, FieldCustomerState>((ref) {
  final dio = ref.read(dioProvider);
  return FieldCustomerProvider(dio, scaffoldMessengerKey);
});

final selectedCustomerProvider = Provider<FieldCustomer?>((ref) {
  return ref.watch(fieldCustomerProvider).selectedCustomer;
});

final customerMetricsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final provider = ref.read(fieldCustomerProvider.notifier);
  if (ref.watch(fieldCustomerProvider).customerMetrics == null) {
    await provider.getCustomerMetrics();
  }
  return ref.watch(fieldCustomerProvider).customerMetrics ?? {};
});
