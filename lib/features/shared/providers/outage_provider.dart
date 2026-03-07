import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/outage.dart';

class OutageState {
  final List<Outage> outages;
  final Outage? selectedOutage;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalOutages;
  final Map<String, dynamic> stats;

  OutageState({
    this.outages = const [],
    this.selectedOutage,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalOutages = 0,
    this.stats = const {},
  });

  OutageState copyWith({
    List<Outage>? outages,
    Outage? selectedOutage,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalOutages,
    Map<String, dynamic>? stats,
  }) {
    return OutageState(
      outages: outages ?? this.outages,
      selectedOutage: selectedOutage ?? this.selectedOutage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalOutages: totalOutages ?? this.totalOutages,
      stats: stats ?? this.stats,
    );
  }
}

class OutageProvider extends StateNotifier<OutageState> {
  final Dio dio;
  final Ref ref;

  OutageProvider(this.dio, this.ref) : super(OutageState());

  // Fetch all outages with pagination and filtering
  Future<void> fetchOutages({
    Map<String, dynamic> filters = const {},
    int page = 1,
    int limit = 20,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': limit,
        ...filters,
      };

      // Remove null values
      queryParams.removeWhere((key, value) => value == null);

      final response = await dio.get('/v1/nawassco/services/outages', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final outages = (data['outages'] as List<dynamic>)
            .map((item) => Outage.fromJson(item))
            .toList();

        state = state.copyWith(
          outages: outages,
          filters: filters,
          currentPage: page,
          totalPages: data['screens'] ?? 1,
          totalOutages: data['total'] ?? 0,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch outages');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Fetch outage by ID
  Future<void> fetchOutageById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/outages/$id');

      if (response.data['success'] == true) {
        final outage = Outage.fromJson(response.data['data']);
        state = state.copyWith(
          selectedOutage: outage,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Outage not found');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Create new outage
  Future<Outage> createOutage(Outage outage) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/services/outages', data: outage.toJson());

      if (response.data['success'] == true) {
        final newOutage = Outage.fromJson(response.data['data']);

        // Add to list
        state = state.copyWith(
          outages: [newOutage, ...state.outages],
          selectedOutage: newOutage,
          isLoading: false,
        );

        return newOutage;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create outage');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Update outage
  Future<Outage> updateOutage(String id, Outage outage) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put('/v1/nawassco/services/outages/$id', data: outage.toJson());

      if (response.data['success'] == true) {
        final updatedOutage = Outage.fromJson(response.data['data']);

        // Update in list
        final updatedOutages = state.outages.map((o) {
          return o.id == id ? updatedOutage : o;
        }).toList();

        state = state.copyWith(
          outages: updatedOutages,
          selectedOutage: updatedOutage,
          isLoading: false,
        );

        return updatedOutage;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update outage');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Update outage status
  Future<Outage> updateOutageStatus(String id, OutageStatus status) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/services/outages/$id/status',
        data: {'status': status.toString().split('.').last.toLowerCase()},
      );

      if (response.data['success'] == true) {
        final updatedOutage = Outage.fromJson(response.data['data']);

        // Update in list
        final updatedOutages = state.outages.map((o) {
          return o.id == id ? updatedOutage : o;
        }).toList();

        state = state.copyWith(
          outages: updatedOutages,
          selectedOutage: updatedOutage,
          isLoading: false,
        );

        return updatedOutage;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Add customer update
  Future<Outage> addCustomerUpdate(
      String outageId,
      String message,
      String postedBy,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/services/outages/$outageId/customer-updates',
        data: {
          'message': message,
          'postedBy': postedBy,
        },
      );

      if (response.data['success'] == true) {
        final updatedOutage = Outage.fromJson(response.data['data']);

        // Update in list
        final updatedOutages = state.outages.map((o) {
          return o.id == outageId ? updatedOutage : o;
        }).toList();

        state = state.copyWith(
          outages: updatedOutages,
          selectedOutage: updatedOutage,
          isLoading: false,
        );

        return updatedOutage;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add update');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Add internal communication
  Future<Outage> addInternalCommunication(
      String outageId,
      String message,
      String from,
      List<String> to,
      PriorityLevel priority,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/services/outages/$outageId/communications',
        data: {
          'message': message,
          'from': from,
          'to': to,
          'priority': priority.toString().split('.').last.toLowerCase(),
        },
      );

      if (response.data['success'] == true) {
        final updatedOutage = Outage.fromJson(response.data['data']);

        // Update in list
        final updatedOutages = state.outages.map((o) {
          return o.id == outageId ? updatedOutage : o;
        }).toList();

        state = state.copyWith(
          outages: updatedOutages,
          selectedOutage: updatedOutage,
          isLoading: false,
        );

        return updatedOutage;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add communication');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Mark communication as read
  Future<void> markCommunicationAsRead(
      String outageId,
      String communicationId,
      String userId,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.patch(
        '/v1/nawassco/services/outages/$outageId/communications/$communicationId/read',
        data: {'userId': userId},
      );

      // Refresh the outage to get updated communication status
      await fetchOutageById(outageId);
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Fetch outage statistics
  Future<void> fetchOutageStats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/outages/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch stats');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Fetch outages by zone
  Future<List<Outage>> fetchOutagesByZone(String zone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/services/outages/zone/$zone');

      if (response.data['success'] == true) {
        final outages = (response.data['data'] as List<dynamic>)
            .map((item) => Outage.fromJson(item))
            .toList();

        state = state.copyWith(
          outages: outages,
          isLoading: false,
        );

        return outages;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch outages by zone');
      }
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Clear selected outage
  void clearSelectedOutage() {
    state = state.copyWith(selectedOutage: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final outageProvider = StateNotifierProvider<OutageProvider, OutageState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return OutageProvider(dio, ref);
  },
);