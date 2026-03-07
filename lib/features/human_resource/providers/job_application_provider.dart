import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';

import '../../public/auth/providers/auth_provider.dart';
import '../models/job_application_model.dart';
import '../models/job_model.dart';
import 'applicant_provider.dart';
import 'job_providers.dart';

// State Class
class JobApplicationState {
  final List<JobApplication> applications;
  final JobApplication? selectedApplication;
  final List<JobApplication> filteredApplications;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isUploading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalApplications;
  final Map<String, dynamic> stats;

  const JobApplicationState({
    this.applications = const [],
    this.selectedApplication,
    this.filteredApplications = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isUploading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalApplications = 0,
    this.stats = const {},
  });

  JobApplicationState copyWith({
    List<JobApplication>? applications,
    JobApplication? selectedApplication,
    List<JobApplication>? filteredApplications,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isUploading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalApplications,
    Map<String, dynamic>? stats,
  }) {
    return JobApplicationState(
      applications: applications ?? this.applications,
      selectedApplication: selectedApplication ?? this.selectedApplication,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalApplications: totalApplications ?? this.totalApplications,
      stats: stats ?? this.stats,
    );
  }
}

// Main Provider
class JobApplicationProvider extends StateNotifier<JobApplicationState> {
  final Dio _dio;
  final Ref _ref;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  JobApplicationProvider(
    this._dio,
    this._ref,
    this._scaffoldMessengerKey,
  ) : super(const JobApplicationState());

  // =================== APPLICANT METHODS ===================

  // Get my applications (for applicants)
  Future<void> getMyApplications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/human_resource/job-applications/my-applications');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final applications = data
            .map((app) => JobApplication.fromJson(app))
            .toList()
            .cast<JobApplication>();

        // Fetch job details for each application
        final jobIds = applications.map((app) => app.jobId).toSet();
        for (final jobId in jobIds) {
          try {
            final jobResponse = await _dio.get('/v1/nawassco/human_resource/jobs/$jobId');
            if (jobResponse.data['success'] == true) {
              final job = Job.fromJson(jobResponse.data['data']);
              // Update applications with job details
              for (int i = 0; i < applications.length; i++) {
                if (applications[i].jobId == jobId) {
                  applications[i] = applications[i].copyWith(jobDetails: job);
                }
              }
            }
          } catch (e) {
            // Continue even if job fetch fails
          }
        }

        state = state.copyWith(
          applications: applications,
          filteredApplications: applications,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load applications',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to load applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading applications: $e',
        isLoading: false,
      );
      _showError('Error loading applications');
    }
  }

  // Apply for a job
  Future<bool> applyForJob({
    required String jobId,
    String? customCoverLetter,
    String? customMessage,
    List<ApplicationDocument> selectedDocuments = const [],
    ApplicationSource applicationSource = ApplicationSource.COMPANY_WEBSITE,
  }) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      // Get applicant profile data
      final applicantState = _ref.read(applicantProvider);
      final applicant = applicantState.applicant;

      if (applicant == null) {
        _showError('Please complete your applicant profile first');
        state = state.copyWith(isCreating: false);
        return false;
      }

      // Get job details
      final jobState = _ref.read(jobProvider);
      final job = jobState.jobs.firstWhere((j) => j.id == jobId);

      final applicationData = {
        'customCoverLetter': customCoverLetter,
        'customMessage': customMessage,
        'selectedDocuments':
            selectedDocuments.map((doc) => doc.toJson()).toList(),
        'applicationSource': applicationSource.name.toLowerCase(),
      };

      final response = await _dio.post(
        '/v1/nawassco/human_resource/job-applications/job/$jobId',
        data: applicationData,
      );

      if (response.data['success'] == true) {
        final newApplication = JobApplication.fromJson(response.data['data'])
            .copyWith(jobDetails: job);

        // Update applicant's applications count
        final updatedApplicant = applicant.copyWith(
          totalApplications: applicant.totalApplications + 1,
          activeApplications: applicant.activeApplications + 1,
          applications: [...applicant.applications, newApplication.id],
        );

        _ref.read(applicantProvider.notifier).state =
            _ref.read(applicantProvider).copyWith(applicant: updatedApplicant);

        // Update job applications count
        final updatedJob = job.copyWith(
          numberOfApplications: job.numberOfApplications + 1,
        );

        _ref.read(jobProvider.notifier).state = _ref.read(jobProvider).copyWith(
              jobs: jobState.jobs
                  .map((j) => j.id == jobId ? updatedJob : j)
                  .toList(),
            );

        state = state.copyWith(
          applications: [newApplication, ...state.applications],
          filteredApplications: [newApplication, ...state.filteredApplications],
          isCreating: false,
        );

        _showSuccess('Application submitted successfully!');
        return true;
      } else {
        state = state.copyWith(isCreating: false);
        _showError(response.data['message'] ?? 'Failed to submit application');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Error submitting application: $e',
      );
      _showError('Error submitting application');
      return false;
    }
  }

  // Withdraw application
  Future<bool> withdrawApplication(String applicationId, String reason) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/job-applications/$applicationId/withdraw',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        final updatedApplication =
            JobApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        // Update applicant's active applications count
        final applicantState = _ref.read(applicantProvider);
        if (applicantState.applicant != null) {
          final updatedApplicant = applicantState.applicant!.copyWith(
            activeApplications:
                applicantState.applicant!.activeApplications - 1,
          );
          _ref.read(applicantProvider.notifier).state =
              applicantState.copyWith(applicant: updatedApplicant);
        }

        state = state.copyWith(
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: updatedApplication,
          isUpdating: false,
        );

        _showSuccess('Application withdrawn successfully');
        return true;
      } else {
        state = state.copyWith(isUpdating: false);
        _showError(
            response.data['message'] ?? 'Failed to withdraw application');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showError('Error withdrawing application');
      return false;
    }
  }

  // =================== HR/ADMIN METHODS ===================

  // Get all applications (for HR/Admin)
  Future<void> getAllApplications({Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        ...(filters ?? state.filters),
        'page': state.currentPage,
        'limit': 20,
      };

      final response = await _dio.get(
        '/v1/nawassco/human_resource/job-applications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data;
        final applications = (data['applications'] as List)
            .map((app) => JobApplication.fromJson(app))
            .toList()
            .cast<JobApplication>();

        state = state.copyWith(
          applications: applications,
          filteredApplications: applications,
          isLoading: false,
          totalPages: data['totalPages'] ?? 1,
          totalApplications: data['total'] ?? applications.length,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load applications',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to load applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading applications: $e',
        isLoading: false,
      );
      _showError('Error loading applications');
    }
  }

  // Get applications by job ID
  Future<void> getApplicationsByJob(String jobId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/human_resource/job-applications/job/$jobId');

      if (response.data['success'] == true) {
        final data = response.data;
        final applications = (data['applications'] as List)
            .map((app) => JobApplication.fromJson(app))
            .toList()
            .cast<JobApplication>();

        state = state.copyWith(
          applications: applications,
          filteredApplications: applications,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load applications',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to load applications');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading applications: $e',
        isLoading: false,
      );
      _showError('Error loading applications');
    }
  }

  // Get application by ID
  Future<void> getApplicationById(String applicationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/human_resource/job-applications/$applicationId');

      if (response.data['success'] == true) {
        final application = JobApplication.fromJson(response.data['data']);

        // Mark as viewed if HR/Admin
        final authState = _ref.read(authProvider);
        if (authState.hasAnyRole(['HR', 'Admin', 'Manager'])) {
          await _markAsViewed(applicationId);
        }

        state = state.copyWith(
          selectedApplication: application,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Application not found',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Application not found');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading application: $e',
        isLoading: false,
      );
      _showError('Error loading application');
    }
  }

  // Update application status
  Future<bool> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/job-applications/$applicationId',
        data: {'status': status.name.toLowerCase()},
      );

      if (response.data['success'] == true) {
        final updatedApplication =
            JobApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        state = state.copyWith(
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: updatedApplication,
          isUpdating: false,
        );

        _showSuccess('Application status updated successfully');
        return true;
      } else {
        state = state.copyWith(isUpdating: false);
        _showError(response.data['message'] ?? 'Failed to update status');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showError('Error updating application status');
      return false;
    }
  }

  // Add interview details
  Future<bool> addInterviewDetails({
    required String applicationId,
    required InterviewDetails interviewDetails,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/job-applications/$applicationId/interview',
        data: interviewDetails.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplication =
            JobApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        state = state.copyWith(
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: updatedApplication,
          isUpdating: false,
        );

        _showSuccess('Interview details added successfully');
        return true;
      } else {
        state = state.copyWith(isUpdating: false);
        _showError(
            response.data['message'] ?? 'Failed to add interview details');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showError('Error adding interview details');
      return false;
    }
  }

  // Add review
  Future<bool> addReview({
    required String applicationId,
    required ReviewHistory review,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/job-applications/$applicationId/review',
        data: review.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplication =
            JobApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        state = state.copyWith(
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: updatedApplication,
          isUpdating: false,
        );

        _showSuccess('Review added successfully');
        return true;
      } else {
        state = state.copyWith(isUpdating: false);
        _showError(response.data['message'] ?? 'Failed to add review');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showError('Error adding review');
      return false;
    }
  }

  // Update application stage
  Future<bool> updateApplicationStage({
    required String applicationId,
    required int stageNumber,
    required String stageName,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/human_resource/job-applications/$applicationId/stage',
        data: {
          'stageNumber': stageNumber,
          'stageName': stageName,
        },
      );

      if (response.data['success'] == true) {
        final updatedApplication =
            JobApplication.fromJson(response.data['data']);

        // Update in applications list
        final updatedApplications = state.applications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        state = state.copyWith(
          applications: updatedApplications,
          filteredApplications: updatedApplications,
          selectedApplication: updatedApplication,
          isUpdating: false,
        );

        _showSuccess('Application stage updated successfully');
        return true;
      } else {
        state = state.copyWith(isUpdating: false);
        _showError(response.data['message'] ?? 'Failed to update stage');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showError('Error updating application stage');
      return false;
    }
  }

  // Search applications
  Future<void> searchApplications(Map<String, dynamic> filters) async {
    try {
      state = state.copyWith(isLoading: true, error: null, filters: filters);

      final queryParams = {
        ...filters,
        'page': 1,
        'limit': 50,
      };

      final response = await _dio.get(
        '/v1/nawassco/human_resource/job-applications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data;
        final applications = (data['applications'] as List)
            .map((app) => JobApplication.fromJson(app))
            .toList()
            .cast<JobApplication>();

        state = state.copyWith(
          filteredApplications: applications,
          isLoading: false,
          totalPages: data['totalPages'] ?? 1,
          totalApplications: data['total'] ?? applications.length,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Search failed',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Search failed');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error searching applications: $e',
        isLoading: false,
      );
      _showError('Error searching applications');
    }
  }

  // Get application statistics
  Future<Map<String, dynamic>> getApplicationStats({String? jobId}) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (jobId != null) {
        queryParams['jobId'] = jobId;
      }

      final response = await _dio.get(
        '/v1/nawassco/human_resource/job-applications/stats',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch stats');
      }
    } catch (e) {
      _showError(e.toString());
      return {};
    }
  }

  // Get top applicants
  Future<List<JobApplication>> getTopApplicants({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/v1/nawassco/human_resource/job-applications/top-applicants',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final applications = (response.data['data'] as List)
            .map((app) => JobApplication.fromJson(app))
            .toList()
            .cast<JobApplication>();
        return applications;
      }
    } catch (e) {
      // Silently fail
    }
    return [];
  }

  // =================== HELPER METHODS ===================

  // Mark application as viewed
  Future<void> _markAsViewed(String applicationId) async {
    try {
      await _dio.post('/v1/nawassco/human_resource/job-applications/$applicationId/view');
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Filter applications
  void filterApplications({
    ApplicationStatus? status,
    String? jobId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    List<JobApplication> filtered = state.applications;

    if (status != null) {
      filtered = filtered.where((app) => app.status == status).toList();
    }

    if (jobId != null && jobId.isNotEmpty) {
      filtered = filtered.where((app) => app.jobId == jobId).toList();
    }

    if (startDate != null) {
      filtered = filtered
          .where((app) => app.applicationDate.isAfter(startDate))
          .toList();
    }

    if (endDate != null) {
      filtered = filtered
          .where((app) => app.applicationDate.isBefore(endDate))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((app) {
        return app.applicant.fullName.toLowerCase().contains(query) ||
            app.applicant.email.toLowerCase().contains(query) ||
            app.applicationNumber.toLowerCase().contains(query) ||
            (app.jobDetails?.title.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    state = state.copyWith(filteredApplications: filtered);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      filters: {},
      filteredApplications: state.applications,
    );
  }

  // Select application
  void selectApplication(JobApplication? application) {
    state = state.copyWith(selectedApplication: application);
  }

  // Clear selected application
  void clearSelectedApplication() {
    state = state.copyWith(selectedApplication: null);
  }

  // Load more applications (pagination)
  Future<void> loadMoreApplications() async {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      await getAllApplications();
    }
  }

  // =================== UTILITY METHODS ===================

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }
}

// Provider
final jobApplicationProvider =
    StateNotifierProvider<JobApplicationProvider, JobApplicationState>((ref) {
  final dio = ref.read(dioProvider);
  final scaffoldMessengerKey = ref.read(scaffoldMessengerKeyProvider);
  return JobApplicationProvider(dio, ref, scaffoldMessengerKey);
});
