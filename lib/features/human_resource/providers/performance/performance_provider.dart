import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../models/performance/performance_appraisal.model.dart';


class PerformanceState {
  final List<PerformanceAppraisal> appraisals;
  final List<PerformanceAppraisal> employeeAppraisals;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>>? employeeList;
  final List<Map<String, dynamic>>? reviewerList;

  PerformanceState({
    this.appraisals = const [],
    this.employeeAppraisals = const [],
    this.isLoading = false,
    this.error,
    this.stats,
    this.employeeList,
    this.reviewerList,
  });

  PerformanceState copyWith({
    List<PerformanceAppraisal>? appraisals,
    List<PerformanceAppraisal>? employeeAppraisals,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? employeeList,
    List<Map<String, dynamic>>? reviewerList,
  }) {
    return PerformanceState(
      appraisals: appraisals ?? this.appraisals,
      employeeAppraisals: employeeAppraisals ?? this.employeeAppraisals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      employeeList: employeeList ?? this.employeeList,
      reviewerList: reviewerList ?? this.reviewerList,
    );
  }
}

class PerformanceProvider extends StateNotifier<PerformanceState> {
  final Dio dio;
  final Ref ref;

  PerformanceProvider(this.dio, this.ref) : super(PerformanceState());

  // Get all appraisals (for HR/Managers)
  Future<void> fetchAppraisals({
    String? employeeId,
    String? appraisalPeriod,
    String? status,
    String? reviewerId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (employeeId != null && employeeId.isNotEmpty) 'employee': employeeId,
        if (appraisalPeriod != null && appraisalPeriod.isNotEmpty) 'appraisalPeriod': appraisalPeriod,
        if (status != null && status.isNotEmpty) 'status': status,
        if (reviewerId != null && reviewerId.isNotEmpty) 'reviewer': reviewerId,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await dio.get('/v1/nawassco/human_resource/performance', queryParameters: params);

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final appraisals = (data['appraisals'] as List)
            .map((e) => PerformanceAppraisal.fromJson(e))
            .toList();

        state = state.copyWith(
          appraisals: appraisals,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load appraisals',
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

  // Get employee's own appraisals
  Future<void> fetchEmployeeAppraisals(String employeeId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/performance/employee/$employeeId');

      if (response.data['success'] == true) {
        final data = response.data['data']['history'];
        final appraisals = (data['appraisals'] as List)
            .map((e) => PerformanceAppraisal.fromJson(e))
            .toList();

        state = state.copyWith(
          employeeAppraisals: appraisals,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load appraisals',
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

  // Get appraisal by ID
  Future<PerformanceAppraisal?> getAppraisalById(String id) async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/performance/$id');

      if (response.data['success'] == true) {
        return PerformanceAppraisal.fromJson(response.data['data']['appraisal']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create new appraisal
  Future<PerformanceAppraisal?> createAppraisal(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/v1/nawassco/human_resource/performance', data: data);

      if (response.data['success'] == true) {
        final appraisal = PerformanceAppraisal.fromJson(response.data['data']['appraisal']);

        // Update state
        state = state.copyWith(
          appraisals: [appraisal, ...state.appraisals],
        );

        return appraisal;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update appraisal
  Future<PerformanceAppraisal?> updateAppraisal(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/v1/nawassco/human_resource/performance/$id', data: data);

      if (response.data['success'] == true) {
        final updatedAppraisal = PerformanceAppraisal.fromJson(response.data['data']['appraisal']);

        // Update in appraisals list
        final updatedAppraisals = state.appraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        // Update in employee appraisals list
        final updatedEmployeeAppraisals = state.employeeAppraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        state = state.copyWith(
          appraisals: updatedAppraisals,
          employeeAppraisals: updatedEmployeeAppraisals,
        );

        return updatedAppraisal;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Submit for review
  Future<void> submitForReview(String id) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/performance/$id/submit');

      if (response.data['success'] == true) {
        final updatedAppraisal = PerformanceAppraisal.fromJson(response.data['data']['appraisal']);

        // Update in lists
        final updatedAppraisals = state.appraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        final updatedEmployeeAppraisals = state.employeeAppraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        state = state.copyWith(
          appraisals: updatedAppraisals,
          employeeAppraisals: updatedEmployeeAppraisals,
        );
      }
    } catch (e) {
      throw e;
    }
  }

  // Complete appraisal
  Future<void> completeAppraisal(String id, String reviewerComments) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/performance/$id/complete', data: {
        'reviewerComments': reviewerComments,
      });

      if (response.data['success'] == true) {
        final updatedAppraisal = PerformanceAppraisal.fromJson(response.data['data']['appraisal']);

        // Update in lists
        final updatedAppraisals = state.appraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        final updatedEmployeeAppraisals = state.employeeAppraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        state = state.copyWith(
          appraisals: updatedAppraisals,
          employeeAppraisals: updatedEmployeeAppraisals,
        );
      }
    } catch (e) {
      throw e;
    }
  }

  // Acknowledge appraisal (employee)
  Future<void> acknowledgeAppraisal(String id, String employeeComments) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/performance/$id/acknowledge', data: {
        'employeeComments': employeeComments,
      });

      if (response.data['success'] == true) {
        final updatedAppraisal = PerformanceAppraisal.fromJson(response.data['data']['appraisal']);

        // Update in employee appraisals list
        final updatedEmployeeAppraisals = state.employeeAppraisals.map((a) {
          return a.id == id ? updatedAppraisal : a;
        }).toList();

        state = state.copyWith(
          employeeAppraisals: updatedEmployeeAppraisals,
        );
      }
    } catch (e) {
      throw e;
    }
  }

  // Get performance statistics
  Future<void> fetchStatistics() async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/performance/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data']['stats'],
        );
      }
    } catch (e) {
      // Silently fail for stats
    }
  }

  // Get employee list for dropdowns
  Future<void> fetchEmployeeList() async {
    try {
      // This would typically come from your employees API
      // For now, we'll simulate or use a different endpoint
      final response = await dio.get('/v1/nawassco/human_resource/employees?limit=100&select=firstName,lastName,_id');

      if (response.data['success'] == true) {
        final employees = (response.data['data'] as List).cast<Map<String, dynamic>>();
        state = state.copyWith(employeeList: employees);
      }
    } catch (e) {
      // Silently fail
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear all data
  void clear() {
    state = PerformanceState();
  }
}

// Provider
final performanceProvider = StateNotifierProvider<PerformanceProvider, PerformanceState>((ref) {
  final dio = ref.read(dioProvider);
  return PerformanceProvider(dio, ref);
});