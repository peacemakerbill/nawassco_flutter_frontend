import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/services/api_service.dart';
import '../../../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/job_model.dart';

class JobState {
  final List<Job> jobs;
  final Job? selectedJob;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalJobs;

  const JobState({
    this.jobs = const [],
    this.selectedJob,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalJobs = 0,
  });

  JobState copyWith({
    List<Job>? jobs,
    Job? selectedJob,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalJobs,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalJobs: totalJobs ?? this.totalJobs,
    );
  }
}

class JobProvider extends StateNotifier<JobState> {
  final Dio dio;
  final Ref ref;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  JobProvider(this.dio, this.ref, this.scaffoldMessengerKey)
      : super(const JobState());

  // Fetch all jobs with pagination
  Future<void> fetchJobs({bool resetFilters = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final filters = resetFilters ? {} : state.filters;
      final queryParams = {
        ...filters,
        'page': state.currentPage,
        'limit': 20,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      };

      // Add public filter if not HR/Admin/Manager
      final authState = ref.read(authProvider);
      if (!authState.hasAnyRole(['HR', 'Admin', 'Manager'])) {
        queryParams['public'] = 'true';
      }

      final response = await dio.get('/v1/nawassco/human_resource/jobs');

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? response.data;
        final jobs =
            (data['jobs'] as List).map((job) => Job.fromJson(job)).toList();

        state = state.copyWith(
          jobs: state.currentPage == 1 ? jobs : [...state.jobs, ...jobs],
          isLoading: false,
          totalPages: data['totalPages'] ?? 1,
          totalJobs: data['total'] ?? jobs.length,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch jobs');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // Fetch job by ID
  Future<void> fetchJobById(String jobId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/jobs/$jobId');

      if (response.data['success'] == true) {
        final job = Job.fromJson(response.data['data'] ?? response.data);
        state = state.copyWith(
          selectedJob: job,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Job not found');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // Create job
  Future<bool> createJob(Map<String, dynamic> jobData) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final response = await dio.post('/v1/nawassco/human_resource/jobs', data: jobData);

      if (response.data['success'] == true) {
        final job = Job.fromJson(response.data['data'] ?? response.data);
        state = state.copyWith(
          jobs: [job, ...state.jobs],
          selectedJob: job,
          isCreating: false,
        );
        _showSuccess('Job created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create job');
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // Update job
  Future<bool> updateJob(String jobId, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.put('/v1/nawassco/human_resource/jobs/$jobId', data: updateData);

      if (response.data['success'] == true) {
        final updatedJob = Job.fromJson(response.data['data'] ?? response.data);
        final updatedJobs = state.jobs.map((job) {
          return job.id == jobId ? updatedJob : job;
        }).toList();

        state = state.copyWith(
          jobs: updatedJobs,
          selectedJob: updatedJob,
          isUpdating: false,
        );
        _showSuccess('Job updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update job');
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // Delete job
  Future<bool> deleteJob(String jobId) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await dio.delete('/v1/nawassco/human_resource/jobs/$jobId');

      if (response.data['success'] == true) {
        final updatedJobs = state.jobs.where((job) => job.id != jobId).toList();
        state = state.copyWith(
          jobs: updatedJobs,
          selectedJob: null,
          isDeleting: false,
        );
        _showSuccess('Job deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete job');
      }
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // Publish job
  Future<bool> publishJob(String jobId) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/jobs/$jobId/publish');

      if (response.data['success'] == true) {
        final updatedJob = Job.fromJson(response.data['data'] ?? response.data);
        final updatedJobs = state.jobs.map((job) {
          return job.id == jobId ? updatedJob : job;
        }).toList();

        state = state.copyWith(
          jobs: updatedJobs,
          selectedJob: updatedJob,
        );
        _showSuccess('Job published successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to publish job');
      }
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  // Close job
  Future<bool> closeJob(String jobId) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/jobs/$jobId/close');

      if (response.data['success'] == true) {
        final updatedJob = Job.fromJson(response.data['data'] ?? response.data);
        final updatedJobs = state.jobs.map((job) {
          return job.id == jobId ? updatedJob : job;
        }).toList();

        state = state.copyWith(
          jobs: updatedJobs,
          selectedJob: updatedJob,
        );
        _showSuccess('Job closed successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to close job');
      }
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  // Search jobs
  Future<void> searchJobs(Map<String, dynamic> searchFilters) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        filters: searchFilters,
        currentPage: 1,
      );

      await fetchJobs();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // Get job statistics
  Future<Map<String, dynamic>> getJobStats() async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/jobs/stats');

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

  // Get similar jobs
  Future<List<Job>> getSimilarJobs(String jobId) async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/jobs/$jobId/similar');

      if (response.data['success'] == true) {
        final jobs = (response.data['data'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        return jobs;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch similar jobs');
      }
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  // Get jobs by department
  Future<List<Job>> getJobsByDepartment(String departmentId) async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/jobs/department/$departmentId');

      if (response.data['success'] == true) {
        final jobs = (response.data['data'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        return jobs;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch department jobs');
      }
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  // Get featured jobs
  Future<List<Job>> getFeaturedJobs() async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/jobs/featured');

      if (response.data['success'] == true) {
        final jobs = (response.data['data'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        return jobs;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch featured jobs');
      }
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  // Get my posted jobs
  Future<void> getMyPostedJobs() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/jobs/my/posted');

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? response.data;
        final jobs =
            (data['jobs'] as List).map((job) => Job.fromJson(job)).toList();

        state = state.copyWith(
          jobs: jobs,
          isLoading: false,
        );
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch posted jobs');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // Set selected job
  void selectJob(Job? job) {
    state = state.copyWith(selectedJob: job);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      filters: {},
      currentPage: 1,
    );
    fetchJobs();
  }

  // Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      await fetchJobs();
    }
  }

  // Helper methods
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final jobProvider = StateNotifierProvider<JobProvider, JobState>((ref) {
  final dio = ref.read(dioProvider);
  final scaffoldMessengerKey = ref.read(scaffoldMessengerKeyProvider);
  return JobProvider(dio, ref, scaffoldMessengerKey);
});

// Provide scaffold messenger key
final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);
