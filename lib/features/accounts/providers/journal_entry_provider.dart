import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../main.dart';
import '../models/journal_entry_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';

class JournalEntryState {
  final List<JournalEntry> journalEntries;
  final JournalEntry? selectedEntry;
  final TrialBalance? trialBalance;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? statusFilter;
  final String? sourceDocumentFilter;

  JournalEntryState({
    this.journalEntries = const [],
    this.selectedEntry,
    this.trialBalance,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.statusFilter,
    this.sourceDocumentFilter,
  });

  JournalEntryState copyWith({
    List<JournalEntry>? journalEntries,
    JournalEntry? selectedEntry,
    TrialBalance? trialBalance,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? statusFilter,
    String? sourceDocumentFilter,
  }) {
    return JournalEntryState(
      journalEntries: journalEntries ?? this.journalEntries,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      trialBalance: trialBalance ?? this.trialBalance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      statusFilter: statusFilter ?? this.statusFilter,
      sourceDocumentFilter: sourceDocumentFilter ?? this.sourceDocumentFilter,
    );
  }
}

class JournalEntryProvider extends StateNotifier<JournalEntryState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  JournalEntryProvider(this.dio, this.scaffoldMessengerKey)
      : super(JournalEntryState());

  // Fetch journal entries with filters
  Future<void> fetchJournalEntries({
    int page = 1,
    int limit = 10,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? sourceDocument,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        if (status != null && status.isNotEmpty) 'status': status,
        if (sourceDocument != null && sourceDocument.isNotEmpty)
          'sourceDocument': sourceDocument,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/journal-entries',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final journalEntries = (data['journalEntries'] as List)
            .map((entry) => JournalEntry.fromJson(entry))
            .toList();

        final pagination = data['pagination'];

        state = state.copyWith(
          journalEntries: journalEntries,
          currentPage: pagination['page'],
          totalPages: pagination['pages'],
          totalCount: pagination['total'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch journal entries',
          isLoading: false,
        );
        _showError(
            response.data['message'] ?? 'Failed to fetch journal entries');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch journal entries: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to fetch journal entries');
    }
  }

  // Fetch journal entry by ID
  Future<void> fetchJournalEntryById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/journal-entries/$id');

      if (response.data['success'] == true) {
        final entry =
        JournalEntry.fromJson(response.data['data']['journalEntry']);
        state = state.copyWith(
          selectedEntry: entry,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch journal entry',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to fetch journal entry');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch journal entry: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to fetch journal entry');
    }
  }

  // Create journal entry
  Future<bool> createJournalEntry(Map<String, dynamic> entryData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/journal-entries',
        data: entryData,
      );

      if (response.data['success'] == true) {
        await fetchJournalEntries(page: state.currentPage);
        state = state.copyWith(isLoading: false);
        _showSuccess('Journal entry created successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create journal entry',
          isLoading: false,
        );
        _showError(
            response.data['message'] ?? 'Failed to create journal entry');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create journal entry: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to create journal entry');
      return false;
    }
  }

  // Update journal entry
  Future<bool> updateJournalEntry(String id, Map<String, dynamic> entryData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/journal-entries/$id',
        data: entryData,
      );

      if (response.data['success'] == true) {
        await fetchJournalEntries(page: state.currentPage);
        state = state.copyWith(isLoading: false);
        _showSuccess('Journal entry updated successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update journal entry',
          isLoading: false,
        );
        _showError(
            response.data['message'] ?? 'Failed to update journal entry');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update journal entry: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to update journal entry');
      return false;
    }
  }

  // Approve journal entry
  Future<bool> approveJournalEntry(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/accounts/journal-entries/$id/approve');

      if (response.data['success'] == true) {
        await fetchJournalEntries(page: state.currentPage);
        state = state.copyWith(isLoading: false);
        _showSuccess('Journal entry approved successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to approve journal entry',
          isLoading: false,
        );
        _showError(
            response.data['message'] ?? 'Failed to approve journal entry');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to approve journal entry: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to approve journal entry');
      return false;
    }
  }

  // Reverse journal entry
  Future<bool> reverseJournalEntry(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/accounts/journal-entries/$id/reverse');

      if (response.data['success'] == true) {
        await fetchJournalEntries(page: state.currentPage);
        state = state.copyWith(isLoading: false);
        _showSuccess('Journal entry reversed successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to reverse journal entry',
          isLoading: false,
        );
        _showError(
            response.data['message'] ?? 'Failed to reverse journal entry');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reverse journal entry: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to reverse journal entry');
      return false;
    }
  }

  // Fetch trial balance
  Future<void> fetchTrialBalance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = <String, dynamic>{
        if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/journal-entries/trial-balance',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final trialBalance =
        TrialBalance.fromJson(response.data['data']['trialBalance']);
        state = state.copyWith(
          trialBalance: trialBalance,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch trial balance',
          isLoading: false,
        );
        _showError(response.data['message'] ?? 'Failed to fetch trial balance');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch trial balance: ${e.toString()}',
        isLoading: false,
      );
      _showError('Failed to fetch trial balance');
    }
  }

  // Update filters
  void updateFilters({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? sourceDocument,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      statusFilter: status ?? state.statusFilter,
      sourceDocumentFilter: sourceDocument ?? state.sourceDocumentFilter,
      currentPage: 1, // Reset to first page when filters change
    );
  }

  // Clear selected entry
  void clearSelectedEntry() {
    state = state.copyWith(selectedEntry: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods for toast messages
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final journalEntryProvider =
StateNotifierProvider<JournalEntryProvider, JournalEntryState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return JournalEntryProvider(dio, scaffoldMessengerKey);
  },
);