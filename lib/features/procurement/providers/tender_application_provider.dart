import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../domain/models/tender_application_model.dart';


class TenderApplicationState {
  final List<TenderApplication> applications;
  final TenderApplication? selectedApplication;
  final List<TenderApplication> myApplications;
  final List<TenderApplication> awardedApplications;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final Map<String, dynamic>? stats;

  TenderApplicationState({
    this.applications = const [],
    this.selectedApplication,
    this.myApplications = const [],
    this.awardedApplications = const [],
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.stats,
  });

  TenderApplicationState copyWith({
    List<TenderApplication>? applications,
    TenderApplication? selectedApplication,
    List<TenderApplication>? myApplications,
    List<TenderApplication>? awardedApplications,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? stats,
  }) {
    return TenderApplicationState(
      applications: applications ?? this.applications,
      selectedApplication: selectedApplication ?? this.selectedApplication,
      myApplications: myApplications ?? this.myApplications,
      awardedApplications: awardedApplications ?? this.awardedApplications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      stats: stats ?? this.stats,
    );
  }
}

class TenderApplicationProvider extends StateNotifier<TenderApplicationState> {
  final Ref ref;
  final Dio dio;

  TenderApplicationProvider(this.ref, this.dio) : super(TenderApplicationState());

  // Get all applications (for procurement staff)
  Future<void> getAllApplications({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tender-applications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<TenderApplication> applications = (response.data['data'] as List)
            .map((json) => TenderApplication.fromJson(json))
            .toList();

        state = state.copyWith(
          applications: applications,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get single application by ID
  Future<void> getApplicationById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/tender-applications/$id');

      if (response.data['success'] == true) {
        final TenderApplication application = TenderApplication.fromJson(response.data['data']);

        state = state.copyWith(
          selectedApplication: application,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get user's applications (for suppliers)
  Future<void> getMyApplications({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tender-applications/my-applications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<TenderApplication> myApplications = (response.data['data'] as List)
            .map((json) => TenderApplication.fromJson(json))
            .toList();

        state = state.copyWith(
          myApplications: myApplications,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch your applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get applications by tender ID
  Future<void> getTenderApplications(String tenderId, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tender-applications/tender/$tenderId',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<TenderApplication> applications = (response.data['data'] as List)
            .map((json) => TenderApplication.fromJson(json))
            .toList();

        state = state.copyWith(
          applications: applications,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tender applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Create new application
  Future<bool> createApplication(Map<String, dynamic> applicationData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tender-applications',
        data: applicationData,
      );

      if (response.data['success'] == true) {
        final TenderApplication newApplication = TenderApplication.fromJson(response.data['data']);

        state = state.copyWith(
          myApplications: [newApplication, ...state.myApplications],
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Application created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Update application
  Future<bool> updateApplication(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/procurement/tender-applications/$id',
        data: updateData,
      );

      if (response.data['success'] == true) {
        final TenderApplication updatedApplication = TenderApplication.fromJson(response.data['data']);

        // Update in my applications list
        final updatedMyApplications = state.myApplications.map((app) =>
        app.id == id ? updatedApplication : app
        ).toList();

        // Update in all applications list
        final updatedApplications = state.applications.map((app) =>
        app.id == id ? updatedApplication : app
        ).toList();

        state = state.copyWith(
          myApplications: updatedMyApplications,
          applications: updatedApplications,
          selectedApplication: state.selectedApplication?.id == id ? updatedApplication : state.selectedApplication,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Application updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Submit application
  Future<bool> submitApplication(String id, DateTime submissionDate) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tender-applications/$id/submit',
        data: {'submissionDate': submissionDate.toIso8601String()},
      );

      if (response.data['success'] == true) {
        final TenderApplication submittedApplication = TenderApplication.fromJson(response.data['data']);

        // Update in my applications list
        final updatedMyApplications = state.myApplications.map((app) =>
        app.id == id ? submittedApplication : app
        ).toList();

        state = state.copyWith(
          myApplications: updatedMyApplications,
          selectedApplication: state.selectedApplication?.id == id ? submittedApplication : state.selectedApplication,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Application submitted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Evaluate application
  Future<bool> evaluateApplication(
      String id,
      Map<String, dynamic> evaluationData,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tender-applications/$id/evaluate',
        data: evaluationData,
      );

      if (response.data['success'] == true) {
        final TenderApplication evaluatedApplication = TenderApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) =>
        app.id == id ? evaluatedApplication : app
        ).toList();

        state = state.copyWith(
          applications: updatedApplications,
          selectedApplication: state.selectedApplication?.id == id ? evaluatedApplication : state.selectedApplication,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Application evaluated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to evaluate application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Withdraw application
  Future<bool> withdrawApplication(String id, String withdrawalReason) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tender-applications/$id/withdraw',
        data: {'withdrawalReason': withdrawalReason},
      );

      if (response.data['success'] == true) {
        final TenderApplication withdrawnApplication = TenderApplication.fromJson(response.data['data']);

        // Update in my applications list
        final updatedMyApplications = state.myApplications.map((app) =>
        app.id == id ? withdrawnApplication : app
        ).toList();

        state = state.copyWith(
          myApplications: updatedMyApplications,
          selectedApplication: state.selectedApplication?.id == id ? withdrawnApplication : state.selectedApplication,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Application withdrawn successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to withdraw application');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Upload document to application
  Future<bool> uploadDocument(String id, Map<String, dynamic> documentData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tender-applications/$id/documents',
        data: documentData,
      );

      if (response.data['success'] == true) {
        final TenderApplication updatedApplication = TenderApplication.fromJson(response.data['data']);

        state = state.copyWith(
          selectedApplication: state.selectedApplication?.id == id ? updatedApplication : state.selectedApplication,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Document uploaded successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload document');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Get application statistics
  Future<void> getApplicationStats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/tender-applications/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch application statistics');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get awarded applications
  Future<void> getAwardedApplications({int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tender-applications/awarded',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<TenderApplication> awardedApplications = (response.data['data'] as List)
            .map((json) => TenderApplication.fromJson(json))
            .toList();

        state = state.copyWith(
          awardedApplications: awardedApplications,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch awarded applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Clear selected application
  void clearSelectedApplication() {
    state = state.copyWith(selectedApplication: null);
  }

  // Update filters
  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper method to show errors
  void _showError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data is Map) {
        errorMessage = response.data['message'] ?? error.message ?? errorMessage;
      } else {
        errorMessage = error.message ?? errorMessage;
      }
    } else if (error is String) {
      errorMessage = error;
    }

    ToastUtils.showErrorToast(errorMessage);
  }
}

// Provider
final tenderApplicationProvider = StateNotifierProvider<TenderApplicationProvider, TenderApplicationState>((ref) {
  final dio = ref.read(dioProvider);
  return TenderApplicationProvider(ref, dio);
});