import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/report.model.dart';

class ReportState {
  final bool isLoading;
  final List<Report> reports;
  final Report? selectedReport;
  final ReportFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ReportStats? stats;
  final ReportDashboardStats? dashboardStats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isSubmitting;
  final bool isApproving;
  final bool isRejecting;
  final bool isAddingComment;
  final String? error;
  final ViewMode viewMode;

  const ReportState({
    this.isLoading = false,
    this.reports = const [],
    this.selectedReport,
    this.filters = const ReportFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.stats,
    this.dashboardStats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isSubmitting = false,
    this.isApproving = false,
    this.isRejecting = false,
    this.isAddingComment = false,
    this.error,
    this.viewMode = ViewMode.list,
  });

  ReportState copyWith({
    bool? isLoading,
    List<Report>? reports,
    Report? selectedReport,
    ReportFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    ReportStats? stats,
    ReportDashboardStats? dashboardStats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isSubmitting,
    bool? isApproving,
    bool? isRejecting,
    bool? isAddingComment,
    String? error,
    ViewMode? viewMode,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      stats: stats ?? this.stats,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isApproving: isApproving ?? this.isApproving,
      isRejecting: isRejecting ?? this.isRejecting,
      isAddingComment: isAddingComment ?? this.isAddingComment,
      error: error ?? this.error,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

enum ViewMode {
  list,
  create,
  edit,
  details,
  stats,
}

class ReportProvider extends StateNotifier<ReportState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;
  final Ref _ref;

  ReportProvider(this._dio, this._scaffoldKey, this._ref)
      : super(const ReportState());

  static const String _baseUrl = '/v1/nawassco/sales/reports';

  Future<void> loadReports({bool refresh = false}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final query = {
        'page': state.currentPage.toString(),
        'limit': '15',
        ...state.filters.toQueryParams(),
      };

      final response = await _dio.get(_baseUrl, queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final pagination = response.data['pagination'] as Map<String, dynamic>;

        final reports = data
            .map<Report>((json) => Report.fromJson(json))
            .toList();

        state = state.copyWith(
          reports: refresh ? reports : [...state.reports, ...reports],
          totalPages: pagination['pages'] as int,
          totalItems: pagination['total'] as int,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load reports');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadReport(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('$_baseUrl/$id');

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);
        state = state.copyWith(
          selectedReport: report,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load report');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Report?> createReport(CreateReportData data) async {
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        _showError('You must be logged in to create a report');
        return null;
      }

      state = state.copyWith(isCreating: true, error: null);

      final reportData = {
        ...data.toJson(),
        'author': authState.user!['_id'],
        'createdBy': authState.user!['_id'],
      };

      final response = await _dio.post(_baseUrl, data: reportData);

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);

        state = state.copyWith(
          reports: [report, ...state.reports],
          selectedReport: report,
          isCreating: false,
          viewMode: ViewMode.details,
        );

        _showSuccess('Report created successfully');
        return report;
      } else {
        _showError(response.data['message'] ?? 'Failed to create report');
        state = state.copyWith(isCreating: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isCreating: false);
      return null;
    }
  }

  Future<Report?> updateReport(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.put('$_baseUrl/$id', data: data);

      if (response.data['success'] == true) {
        final updatedReport = Report.fromJson(response.data['data']);

        final updatedReports = state.reports.map((report) {
          return report.id == id ? updatedReport : report;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: updatedReport,
          isUpdating: false,
        );

        _showSuccess('Report updated successfully');
        return updatedReport;
      } else {
        _showError(response.data['message'] ?? 'Failed to update report');
        state = state.copyWith(isUpdating: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return null;
    }
  }

  Future<bool> deleteReport(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await _dio.delete('$_baseUrl/$id');

      if (response.data['success'] == true) {
        final updatedReports = state.reports
            .where((report) => report.id != id)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: null,
          isDeleting: false,
          viewMode: ViewMode.list,
        );

        _showSuccess('Report deleted successfully');
        return true;
      } else {
        _showError(response.data['message'] ?? 'Failed to delete report');
        state = state.copyWith(isDeleting: false);
        return false;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isDeleting: false);
      return false;
    }
  }

  Future<Report?> submitReportForReview(String id) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await _dio.put('$_baseUrl/$id/submit');

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);

        final updatedReports = state.reports.map((r) {
          return r.id == id ? report : r;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: report,
          isSubmitting: false,
        );

        _showSuccess('Report submitted for review successfully');
        return report;
      } else {
        _showError(response.data['message'] ?? 'Failed to submit report');
        state = state.copyWith(isSubmitting: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isSubmitting: false);
      return null;
    }
  }

  Future<Report?> addCommentToReport(
      String id,
      String comment, {
        bool isInternal = false,
      }) async {
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        _showError('You must be logged in to add comments');
        return null;
      }

      state = state.copyWith(isAddingComment: true, error: null);

      final data = {
        'comment': comment,
        'isInternal': isInternal,
      };

      final response = await _dio.post('$_baseUrl/$id/comments', data: data);

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);

        state = state.copyWith(
          selectedReport: report,
          isAddingComment: false,
        );

        _showSuccess('Comment added successfully');
        return report;
      } else {
        _showError(response.data['message'] ?? 'Failed to add comment');
        state = state.copyWith(isAddingComment: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isAddingComment: false);
      return null;
    }
  }

  Future<Report?> approveReport(String id, {String? comments}) async {
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        _showError('You must be logged in to approve reports');
        return null;
      }

      state = state.copyWith(isApproving: true, error: null);

      final data = {
        'approvedBy': authState.user!['_id'],
        if (comments != null && comments.isNotEmpty) 'comments': comments,
      };

      final response = await _dio.put('$_baseUrl/$id/approve', data: data);

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);

        final updatedReports = state.reports.map((r) {
          return r.id == id ? report : r;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: report,
          isApproving: false,
        );

        _showSuccess('Report approved successfully');
        return report;
      } else {
        _showError(response.data['message'] ?? 'Failed to approve report');
        state = state.copyWith(isApproving: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isApproving: false);
      return null;
    }
  }

  Future<Report?> rejectReport(String id, String reason) async {
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        _showError('You must be logged in to reject reports');
        return null;
      }

      state = state.copyWith(isRejecting: true, error: null);

      final data = {
        'rejectedBy': authState.user!['_id'],
        'reason': reason,
      };

      final response = await _dio.put('$_baseUrl/$id/reject', data: data);

      if (response.data['success'] == true) {
        final report = Report.fromJson(response.data['data']);

        final updatedReports = state.reports.map((r) {
          return r.id == id ? report : r;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: report,
          isRejecting: false,
        );

        _showSuccess('Report rejected successfully');
        return report;
      } else {
        _showError(response.data['message'] ?? 'Failed to reject report');
        state = state.copyWith(isRejecting: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isRejecting: false);
      return null;
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _dio.get('$_baseUrl/stats');

      if (response.data['success'] == true) {
        final stats = ReportStats.fromJson(response.data['data']);
        state = state.copyWith(stats: stats);
      }
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      final response = await _dio.get('$_baseUrl/dashboard/stats');

      if (response.data['success'] == true) {
        final dashboardStats = ReportDashboardStats.fromJson(response.data['data']);
        state = state.copyWith(dashboardStats: dashboardStats);
      }
    } catch (e) {
      print('Failed to load dashboard stats: $e');
    }
  }

  Future<List<Report>> getReportsByAuthor(String authorId) async {
    try {
      final response = await _dio.get('$_baseUrl/author/$authorId');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<Report>((json) => Report.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load author reports: $e');
      return [];
    }
  }

  Future<List<Report>> getReportsByDateRange(
      DateTime startDate,
      DateTime endDate, {
        String? authorId,
      }) async {
    try {
      final query = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (authorId != null) 'authorId': authorId,
      };

      final response = await _dio.get('$_baseUrl/date-range', queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<Report>((json) => Report.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load reports by date range: $e');
      return [];
    }
  }

  Future<List<Report>> getTeamReports(
      String team,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final query = {
        'team': team,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get('$_baseUrl/team', queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<Report>((json) => Report.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load team reports: $e');
      return [];
    }
  }

  void selectReport(Report? report) {
    state = state.copyWith(
      selectedReport: report,
      viewMode: report != null ? ViewMode.details : ViewMode.list,
    );
  }

  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void updateFilters(ReportFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      reports: [],
      viewMode: ViewMode.list,
    );
    loadReports(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const ReportFilters(),
      currentPage: 1,
      reports: [],
    );
    loadReports(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadReports();
    }
  }

  void refreshData() {
    state = state.copyWith(
      currentPage: 1,
      reports: [],
    );
    loadReports(refresh: true);
    loadStats();
    loadDashboardStats();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

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
      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Report not found.';
      } else if (error.response?.statusCode == 409) {
        errorMessage = 'Report already exists with this number.';
      } else if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please check your connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
    }

    state = state.copyWith(error: errorMessage);
    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

final reportProvider = StateNotifierProvider<ReportProvider, ReportState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return ReportProvider(dio, scaffoldMessengerKey, ref);
  },
);