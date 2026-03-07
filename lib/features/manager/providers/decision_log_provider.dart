import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/decision_log_model.dart';

class DecisionLogState {
  final List<DecisionLog> decisionLogs;
  final DecisionLog? selectedLog;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const DecisionLogState({
    this.decisionLogs = const [],
    this.selectedLog,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });

  DecisionLogState copyWith({
    List<DecisionLog>? decisionLogs,
    DecisionLog? selectedLog,
    bool? isLoading,
    bool? isSaving,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return DecisionLogState(
      decisionLogs: decisionLogs ?? this.decisionLogs,
      selectedLog: selectedLog ?? this.selectedLog,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

class DecisionLogProvider extends StateNotifier<DecisionLogState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  DecisionLogProvider(this._dio, this._scaffoldMessengerKey)
      : super(const DecisionLogState());

  // Fetch all decision logs with pagination and filtering
  Future<void> fetchDecisionLogs({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get('/v1/nawassco/manager/decision-logs',
          queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final decisionLogs = (data['decisionLogs'] as List)
            .map((log) => DecisionLog.fromJson(log))
            .toList();

        final pagination = data['pagination'] ?? {};

        state = state.copyWith(
          decisionLogs: decisionLogs,
          isLoading: false,
          currentPage: page,
          totalPages: (pagination['screens'] as num?)?.toInt() ?? 1,
          totalItems: (pagination['total'] as num?)?.toInt() ?? 0,
          filters: {
            'status': status,
            'search': search,
            'startDate': startDate,
            'endDate': endDate,
          },
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch decision logs',
          isLoading: false,
        );
        _showErrorToast(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error fetching decision logs: $e',
        isLoading: false,
      );
      _showErrorToast('Failed to load decision logs');
    }
  }

  // Fetch single decision log by ID
  Future<void> fetchDecisionLogById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/manager/decision-logs/$id');

      if (response.data['success'] == true) {
        final decisionLog = DecisionLog.fromJson(response.data['data']);
        state = state.copyWith(
          selectedLog: decisionLog,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch decision log',
          isLoading: false,
        );
        _showErrorToast(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error fetching decision log: $e',
        isLoading: false,
      );
      _showErrorToast('Failed to load decision log details');
    }
  }

  // Create new decision log
  Future<bool> createDecisionLog(DecisionLog log) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/decision-logs',
        data: log.toJson(),
      );

      if (response.data['success'] == true) {
        final newLog =
            DecisionLog.fromJson(response.data['data']['decisionLog']);

        state = state.copyWith(
          decisionLogs: [newLog, ...state.decisionLogs],
          selectedLog: newLog,
          isSaving: false,
        );

        _showSuccessToast('Decision log created successfully');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(
            response.data['message'] ?? 'Failed to create decision log');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error creating decision log: $e');
      return false;
    }
  }

  // Update existing decision log
  Future<bool> updateDecisionLog(String id, DecisionLog log) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/manager/decision-logs/$id',
        data: log.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedLog =
            DecisionLog.fromJson(response.data['data']['decisionLog']);

        final updatedLogs =
            state.decisionLogs.map((l) => l.id == id ? updatedLog : l).toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: updatedLog,
          isSaving: false,
        );

        _showSuccessToast('Decision log updated successfully');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(
            response.data['message'] ?? 'Failed to update decision log');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error updating decision log: $e');
      return false;
    }
  }

  // Delete decision log
  Future<bool> deleteDecisionLog(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _dio.delete('/v1/nawassco/manager/decision-logs/$id');

      if (response.data['success'] == true) {
        final updatedLogs =
            state.decisionLogs.where((log) => log.id != id).toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: state.selectedLog?.id == id ? null : state.selectedLog,
          isLoading: false,
        );

        _showSuccessToast('Decision log deleted successfully');
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        _showErrorToast(
            response.data['message'] ?? 'Failed to delete decision log');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showErrorToast('Error deleting decision log: $e');
      return false;
    }
  }

  // Add implementation step
  Future<bool> addImplementationStep(
      String decisionId, ImplementationStep step) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/decision-logs/$decisionId/implementation-steps',
        data: step.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedLog =
            DecisionLog.fromJson(response.data['data']['decisionLog']);

        final updatedLogs = state.decisionLogs
            .map((l) => l.id == decisionId ? updatedLog : l)
            .toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: updatedLog,
          isSaving: false,
        );

        _showSuccessToast('Implementation step added successfully');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(response.data['message'] ?? 'Failed to add step');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error adding step: $e');
      return false;
    }
  }

  // Update step status
  Future<bool> updateStepStatus(
      String decisionId, int stepIndex, StepStatus status) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.patch(
        '/v1/nawassco/manager/decision-logs/$decisionId/implementation-steps/$stepIndex/status',
        data: {'status': status.name},
      );

      if (response.data['success'] == true) {
        final updatedLog =
            DecisionLog.fromJson(response.data['data']['decisionLog']);

        final updatedLogs = state.decisionLogs
            .map((l) => l.id == decisionId ? updatedLog : l)
            .toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: updatedLog,
          isSaving: false,
        );

        _showSuccessToast('Step status updated successfully');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(
            response.data['message'] ?? 'Failed to update step status');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error updating step status: $e');
      return false;
    }
  }

  // Update decision status
  Future<bool> updateDecisionStatus(String id, DecisionStatus status) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.patch(
        '/v1/nawassco/manager/decision-logs/$id/status',
        data: {'status': status.name},
      );

      if (response.data['success'] == true) {
        final updatedLog = DecisionLog.fromJson(response.data['data']);

        final updatedLogs =
            state.decisionLogs.map((l) => l.id == id ? updatedLog : l).toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: updatedLog,
          isSaving: false,
        );

        _showSuccessToast('Decision status updated to ${status.label}');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(response.data['message'] ?? 'Failed to update status');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error updating status: $e');
      return false;
    }
  }

  // Add actual outcome
  Future<bool> addActualOutcome(
      String decisionId, Map<String, dynamic> outcome) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/decision-logs/$decisionId/outcomes',
        data: outcome,
      );

      if (response.data['success'] == true) {
        final updatedLog = DecisionLog.fromJson(response.data['data']);

        final updatedLogs = state.decisionLogs
            .map((l) => l.id == decisionId ? updatedLog : l)
            .toList();

        state = state.copyWith(
          decisionLogs: updatedLogs,
          selectedLog: updatedLog,
          isSaving: false,
        );

        _showSuccessToast('Outcome recorded successfully');
        return true;
      } else {
        state = state.copyWith(isSaving: false);
        _showErrorToast(response.data['message'] ?? 'Failed to record outcome');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      _showErrorToast('Error recording outcome: $e');
      return false;
    }
  }

  // Clear selected log
  void clearSelection() {
    state = state.copyWith(selectedLog: null);
  }

  // Helper methods for toasts
  void _showSuccessToast(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showErrorToast(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }
}

// Provider
final decisionLogProvider =
    StateNotifierProvider<DecisionLogProvider, DecisionLogState>((ref) {
  final dio = ref.read(dioProvider);
  return DecisionLogProvider(dio, scaffoldMessengerKey);
});
