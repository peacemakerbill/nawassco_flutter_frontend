import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/service_request_model.dart';

class ServiceRequestState {
  final List<ServiceRequest> requests;
  final ServiceRequest? selectedRequest;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> stats;
  final Map<String, dynamic>? technicianPerformance;

  ServiceRequestState({
    this.requests = const [],
    this.selectedRequest,
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.filters = const {},
    this.stats = const {},
    this.technicianPerformance,
  });

  ServiceRequestState copyWith({
    List<ServiceRequest>? requests,
    ServiceRequest? selectedRequest,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? technicianPerformance,
  }) {
    return ServiceRequestState(
      requests: requests ?? this.requests,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      filters: filters ?? this.filters,
      stats: stats ?? this.stats,
      technicianPerformance:
          technicianPerformance ?? this.technicianPerformance,
    );
  }
}

class ServiceRequestProvider extends StateNotifier<ServiceRequestState> {
  final Dio _dio;
  final Ref _ref;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  CancelToken? _cancelToken;
  Timer? _debounceTimer;

  ServiceRequestProvider(
    this._dio,
    this._ref,
    this._scaffoldMessengerKey,
  ) : super(ServiceRequestState());

  // Helper method to show toast safely
  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
    } else {
      ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
    }
  }

  // Helper method to handle errors
  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      errorMessage = error.response?.data?['message'] ??
          error.response?.statusMessage ??
          error.message ??
          'Network error occurred';
    } else if (error is String) {
      errorMessage = error;
    }

    _showToast(errorMessage, isError: true);
    state = state.copyWith(error: errorMessage, isLoading: false);
  }

  // Fetch service requests with pagination and filtering
  Future<void> fetchServiceRequests({bool loadMore = false}) async {
    if (state.isLoading && !loadMore) return;

    try {
      if (!loadMore) {
        _cancelToken?.cancel();
        _cancelToken = CancelToken();
        state = state.copyWith(isLoading: true, error: null, page: 1);
      }

      final currentPage = loadMore ? state.page + 1 : 1;

      final queryParams = {
        'page': currentPage,
        'limit': 20,
        'sort': '-createdAt',
        ...state.filters,
      };

      final response = await _dio.get(
        '/v1/nawassco/services/service-requests',
        queryParameters: queryParams,
        cancelToken: _cancelToken,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final total = response.data['total'] ?? 0;
        final hasMoreData = (currentPage * 20) < total;

        final requests =
            data.map((json) => ServiceRequest.fromJson(json)).toList();

        state = state.copyWith(
          requests: loadMore ? [...state.requests, ...requests] : requests,
          isLoading: false,
          page: currentPage,
          hasMore: hasMoreData,
          error: null,
        );
      }
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.cancel) {
        return;
      }
      _handleError(error);
    }
  }

  // Fetch a single service request by ID
  Future<void> fetchServiceRequestById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/services/service-requests/$id');

      if (response.data['success'] == true) {
        final request = ServiceRequest.fromJson(response.data['data']);
        state = state.copyWith(
          selectedRequest: request,
          isLoading: false,
          error: null,
        );
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Create a new service request
  Future<void> createServiceRequest(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authState = _ref.read(authProvider);
      final requestData = {
        ...data,
        'createdBy': authState.user?['_id'],
      };

      final response = await _dio.post(
        '/v1/nawassco/services/service-requests',
        data: requestData,
      );

      if (response.data['success'] == true) {
        final newRequest = ServiceRequest.fromJson(response.data['data']);
        state = state.copyWith(
          requests: [newRequest, ...state.requests],
          selectedRequest: newRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Service request created successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Update an existing service request
  Future<void> updateServiceRequest(
      String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.put(
        '/v1/nawassco/services/service-requests/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        // Update in the list
        final updatedRequests = state.requests.map((req) {
          if (req.id == id) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Service request updated successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Delete a service request
  Future<void> deleteServiceRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/v1/nawassco/services/service-requests/$id');

      if (response.data['success'] == true) {
        final updatedRequests =
            state.requests.where((req) => req.id != id).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: null,
          isLoading: false,
          error: null,
        );
        _showToast('Service request deleted successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Assign technician to a request
  Future<void> assignTechnician(String requestId, String technicianId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/services/service-requests/$requestId/assign',
        data: {'technicianId': technicianId},
      );

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        // Update in the list
        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Technician assigned successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Reassign technician
  Future<void> reassignTechnician(
      String requestId, String newTechnicianId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/services/service-requests/$requestId/reassign',
        data: {'newTechnicianId': newTechnicianId},
      );

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Technician reassigned successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Unassign technician
  Future<void> unassignTechnician(String requestId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post('/v1/nawassco/services/service-requests/$requestId/unassign');

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Technician unassigned successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Bulk assign technicians
  Future<void> bulkAssignTechnicians(
      List<String> requestIds, String technicianId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/services/service-requests/bulk/assign',
        data: {
          'requestIds': requestIds,
          'technicianId': technicianId,
        },
      );

      if (response.data['success'] == true) {
        _showToast('${requestIds.length} requests assigned successfully!');
        // Refresh the list
        await fetchServiceRequests();
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Update request status
  Future<void> updateRequestStatus(
      String requestId, RequestStatus status) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.put(
        '/v1/nawassco/services/service-requests/$requestId/status',
        data: {'status': status.name},
      );

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Status updated successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Add note to request
  Future<void> addRequestNote(
      String requestId, Map<String, dynamic> noteData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/services/service-requests/$requestId/notes',
        data: noteData,
      );

      if (response.data['success'] == true) {
        final updatedRequest = ServiceRequest.fromJson(response.data['data']);

        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          selectedRequest: updatedRequest,
          isLoading: false,
          error: null,
        );
        _showToast('Note added successfully!');
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Fetch request statistics
  Future<void> fetchRequestStats(String timeframe) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get(
        '/v1/nawassco/services/service-requests/stats',
        queryParameters: {'timeframe': timeframe},
      );

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'] ?? {},
          isLoading: false,
          error: null,
        );
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Fetch technician performance
  Future<void> fetchTechnicianPerformance(
      String technicianId, String timeframe) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get(
        '/v1/nawassco/services/service-requests/technicians/$technicianId/performance',
        queryParameters: {'timeframe': timeframe},
      );

      if (response.data['success'] == true) {
        state = state.copyWith(
          technicianPerformance: response.data['data'] ?? {},
          isLoading: false,
          error: null,
        );
      }
    } catch (error) {
      _handleError(error);
    }
  }

  // Set filters with debounce
  void setFilters(Map<String, dynamic> filters) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(filters: filters, page: 1);
      fetchServiceRequests();
    });
  }

  // Clear selected request
  void clearSelectedRequest() {
    state = state.copyWith(selectedRequest: null);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(filters: {}, page: 1);
    fetchServiceRequests();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Provider
final serviceRequestProvider =
    StateNotifierProvider<ServiceRequestProvider, ServiceRequestState>(
  (ref) {
    final dio = ref.read(dioProvider);
    final scaffoldMessengerKey = ref.read(scaffoldMessengerKeyProvider);
    return ServiceRequestProvider(dio, ref, scaffoldMessengerKey);
  },
);

// Provider for scaffold messenger key (add this to your main.dart or providers file)
final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);
