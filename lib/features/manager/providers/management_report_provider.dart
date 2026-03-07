import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/reports/management_report_model.dart';
import '../models/reports/report_action_item_model.dart';

class ManagementReportState {
  final List<ManagementReport> reports;
  final ManagementReport? selectedReport;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final Map<String, dynamic> filters;
  final int totalPages;
  final int currentPage;
  final int totalReports;
  final Map<String, dynamic>? stats;

  ManagementReportState({
    this.reports = const [],
    this.selectedReport,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    Map<String, dynamic>? filters,
    this.totalPages = 1,
    this.currentPage = 1,
    this.totalReports = 0,
    this.stats,
  }) : filters = filters ??
            {
              'page': 1,
              'limit': 10,
              'sort': 'createdAt:desc',
            };

  ManagementReportState copyWith({
    List<ManagementReport>? reports,
    ManagementReport? selectedReport,
    bool? isLoading,
    bool? isSaving,
    String? error,
    Map<String, dynamic>? filters,
    int? totalPages,
    int? currentPage,
    int? totalReports,
    Map<String, dynamic>? stats,
  }) {
    return ManagementReportState(
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalReports: totalReports ?? this.totalReports,
      stats: stats ?? this.stats,
    );
  }
}

class ManagementReportProvider extends StateNotifier<ManagementReportState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  ManagementReportProvider(this._dio, this._scaffoldMessengerKey)
      : super(ManagementReportState());

  // Load all reports with filters
  Future<void> loadReports({Map<String, dynamic>? additionalFilters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final filters = {
        ...state.filters,
        ...?additionalFilters,
      };

      final response =
          await _dio.get('/v1/nawassco/manager/reports', queryParameters: filters);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final reports = (data['reports'] as List)
            .map((json) => ManagementReport.fromJson(json))
            .toList();

        state = state.copyWith(
          reports: reports,
          isLoading: false,
          totalPages: data['pagination']['screens'] ?? 1,
          currentPage: data['pagination']['page'] ?? 1,
          totalReports: data['pagination']['total'] ?? 0,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load reports',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to load reports');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading reports: $e',
        isLoading: false,
      );
      _showError('Error loading reports');
    }
  }

  // Load report statistics
  Future<void> loadReportStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/manager/reports/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data']['stats'],
        );
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  // Create new report
  Future<void> createReport(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post('/v1/nawassco/manager/reports', data: data);

      if (response.data['success'] == true) {
        final newReport =
            ManagementReport.fromJson(response.data['data']['report']);

        state = state.copyWith(
          reports: [newReport, ...state.reports],
          isSaving: false,
          selectedReport: newReport,
        );

        _showSuccess('Report created successfully');
        await loadReportStats(); // Refresh stats
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to create report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error creating report: $e');
    }
  }

  // Update report
  Future<void> updateReport(String reportId, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put('/v1/nawassco/manager/reports/$reportId', data: data);

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Report updated successfully');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to update report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error updating report: $e');
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.delete('/v1/nawassco/manager/reports/$reportId');

      if (response.data['success'] == true) {
        final updatedReports =
            state.reports.where((r) => r.id != reportId).toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: state.selectedReport?.id == reportId
              ? null
              : state.selectedReport,
        );

        _showSuccess('Report deleted successfully');
        await loadReportStats(); // Refresh stats
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to delete report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error deleting report: $e');
    }
  }

  // Submit report for review
  Future<void> submitForReview(String reportId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post('/v1/nawassco/manager/reports/$reportId/submit');

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Report submitted for review');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to submit report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error submitting report: $e');
    }
  }

  // Approve report
  Future<void> approveReport(String reportId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post('/v1/nawassco/manager/reports/$reportId/approve');

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Report approved successfully');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to approve report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error approving report: $e');
    }
  }

  // Publish report
  Future<void> publishReport(String reportId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post('/v1/nawassco/manager/reports/$reportId/publish');

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Report published successfully');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to publish report');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error publishing report: $e');
    }
  }

  // Add feedback
  Future<void> addFeedback(
      String reportId, String comment, bool actionRequired) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/reports/$reportId/feedback',
        data: {
          'comment': comment,
          'actionRequired': actionRequired,
        },
      );

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Feedback added successfully');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to add feedback');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error adding feedback: $e');
    }
  }

  // Add action item
  Future<void> addActionItem(
    String reportId,
    String item,
    String ownerId,
    DateTime dueDate,
    PriorityLevel priority,
  ) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/reports/$reportId/action-items',
        data: {
          'item': item,
          'owner': ownerId,
          'dueDate': dueDate.toIso8601String(),
          'priority': priority.name,
        },
      );

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Action item added successfully');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to add action item');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error adding action item: $e');
    }
  }

  // Update action item status
  Future<void> updateActionItemStatus(
    String reportId,
    String actionItemId,
    ActionItemStatus status,
  ) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.patch(
        '/v1/nawassco/manager/reports/$reportId/action-items/$actionItemId/status',
        data: {'status': status.name},
      );

      if (response.data['success'] == true) {
        final updatedReport =
            ManagementReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          isSaving: false,
          selectedReport: updatedReport,
        );

        _showSuccess('Action item status updated');
      } else {
        state = state.copyWith(isSaving: false);
        _showError(response.data['message'] ?? 'Failed to update action item');
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showError('Error updating action item: $e');
    }
  }

  // Set selected report
  void selectReport(ManagementReport? report) {
    state = state.copyWith(selectedReport: report);
  }

  // Update filters
  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: {...state.filters, ...newFilters});
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(filters: {
      'page': 1,
      'limit': 10,
      'sort': 'createdAt:desc',
    });
  }

  // Helper methods for toasts
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }
}

// Provider
final managementReportProvider =
    StateNotifierProvider<ManagementReportProvider, ManagementReportState>(
        (ref) {
  final dio = ref.read(dioProvider);
  return ManagementReportProvider(dio, scaffoldMessengerKey);
});
