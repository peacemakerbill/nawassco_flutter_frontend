import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/bank_reconciliation_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../models/chart_of_account_model.dart';

class BankReconciliationState {
  final List<BankReconciliation> reconciliations;
  final BankReconciliation? selectedReconciliation;
  final bool isLoading;
  final bool isLoadingBankAccounts;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final ReconciliationFilters filters;
  final List<ChartOfAccount> bankAccounts;

  BankReconciliationState({
    this.reconciliations = const [],
    this.selectedReconciliation,
    this.isLoading = false,
    this.isLoadingBankAccounts = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    ReconciliationFilters? filters,
    this.bankAccounts = const [],
  }) : filters = filters ?? ReconciliationFilters();

  BankReconciliationState copyWith({
    List<BankReconciliation>? reconciliations,
    BankReconciliation? selectedReconciliation,
    bool? isLoading,
    bool? isLoadingBankAccounts,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    ReconciliationFilters? filters,
    List<ChartOfAccount>? bankAccounts,
  }) {
    return BankReconciliationState(
      reconciliations: reconciliations ?? this.reconciliations,
      selectedReconciliation:
      selectedReconciliation ?? this.selectedReconciliation,
      isLoading: isLoading ?? this.isLoading,
      isLoadingBankAccounts: isLoadingBankAccounts ?? this.isLoadingBankAccounts,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      filters: filters ?? this.filters,
      bankAccounts: bankAccounts ?? this.bankAccounts,
    );
  }
}

class BankReconciliationProvider
    extends StateNotifier<BankReconciliationState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  BankReconciliationProvider(this.dio, this.scaffoldMessengerKey)
      : super(BankReconciliationState()) {
    // Initialize by fetching bank accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await fetchBankAccounts();
    await fetchReconciliations();
  }

  // Fetch all reconciliations with filters
  Future<void> fetchReconciliations({ReconciliationFilters? filters}) async {
    try {
      final currentFilters = filters ?? state.filters;
      state = state.copyWith(
        isLoading: true,
        error: null,
        filters: currentFilters,
      );

      final response = await dio.get(
        '/v1/nawassco/accounts/bank-reconciliations',
        queryParameters: currentFilters.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final reconciliationResponse =
        ReconciliationResponse.fromJson(response.data['data']);

        state = state.copyWith(
          reconciliations: reconciliationResponse.reconciliations,
          currentPage: reconciliationResponse.pagination.page,
          totalPages: reconciliationResponse.pagination.pages,
          totalCount: reconciliationResponse.pagination.total,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch reconciliations',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to fetch reconciliations',
          key: scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch reconciliations: ${e.toString()}',
        isLoading: false,
      );
      ToastUtils.showErrorToast(
        'Failed to fetch reconciliations: ${e.toString()}',
        key: scaffoldMessengerKey,
      );
    }
  }

  // Fetch reconciliation by ID
  Future<void> fetchReconciliationById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/accounts/bank-reconciliations/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final reconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);
        state = state.copyWith(
          selectedReconciliation: reconciliation,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch reconciliation',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to fetch reconciliation',
          key: scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch reconciliation: ${e.toString()}',
        isLoading: false,
      );
      ToastUtils.showErrorToast(
        'Failed to fetch reconciliation: ${e.toString()}',
        key: scaffoldMessengerKey,
      );
    }
  }

  // Create new reconciliation
  Future<bool> createReconciliation(CreateReconciliationData data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/bank-reconciliations',
        data: data.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final reconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);

        final updatedReconciliations = [
          reconciliation,
          ...state.reconciliations
        ];

        state = state.copyWith(
          reconciliations: updatedReconciliations,
          selectedReconciliation: reconciliation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Bank reconciliation created successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to create reconciliation';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to create reconciliation: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Update reconciliation
  Future<bool> updateReconciliation(
      String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/bank-reconciliations/$id',
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final updatedReconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);

        final updatedReconciliations = state.reconciliations
            .map((rec) => rec.id == id ? updatedReconciliation : rec)
            .toList();

        state = state.copyWith(
          reconciliations: updatedReconciliations,
          selectedReconciliation: updatedReconciliation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Bank reconciliation updated successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to update reconciliation';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to update reconciliation: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Complete reconciliation
  Future<bool> completeReconciliation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/bank-reconciliations/$id/complete',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final completedReconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);

        final updatedReconciliations = state.reconciliations
            .map((rec) => rec.id == id ? completedReconciliation : rec)
            .toList();

        state = state.copyWith(
          reconciliations: updatedReconciliations,
          selectedReconciliation: completedReconciliation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Bank reconciliation completed successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to complete reconciliation';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to complete reconciliation: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Add outstanding item
  Future<bool> addOutstandingItem(
      String reconciliationId, OutstandingItemData itemData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/bank-reconciliations/$reconciliationId/outstanding-items',
        data: itemData.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final updatedReconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);

        final updatedReconciliations = state.reconciliations
            .map((rec) =>
        rec.id == reconciliationId ? updatedReconciliation : rec)
            .toList();

        state = state.copyWith(
          reconciliations: updatedReconciliations,
          selectedReconciliation: updatedReconciliation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Outstanding item added successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to add outstanding item';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to add outstanding item: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Clear outstanding item
  Future<bool> clearOutstandingItem(
      String reconciliationId, String itemId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/bank-reconciliations/$reconciliationId/outstanding-items/$itemId/clear',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final updatedReconciliation = BankReconciliation.fromJson(
            response.data['data']['reconciliation']);

        final updatedReconciliations = state.reconciliations
            .map((rec) =>
        rec.id == reconciliationId ? updatedReconciliation : rec)
            .toList();

        state = state.copyWith(
          reconciliations: updatedReconciliations,
          selectedReconciliation: updatedReconciliation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Outstanding item cleared successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to clear outstanding item';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to clear outstanding item: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Fetch bank accounts for dropdown - CRITICAL FIX
  Future<void> fetchBankAccounts() async {
    try {
      state = state.copyWith(isLoadingBankAccounts: true, error: null);

      print('🔵 Fetching bank accounts from API...');

      final response = await dio.get(
        '/v1/nawassco/accounts/chart-of-accounts/bank-accounts',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('🟢 Bank accounts API response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final bankAccountsData = response.data['data']['bankAccounts'] as List<dynamic>?;

        if (bankAccountsData != null) {
          print('🟢 Found ${bankAccountsData.length} bank accounts');

          final bankAccounts = bankAccountsData
              .map((item) => ChartOfAccount.fromJson(item))
              .where((account) => account.isActive && account.isBankAccount)
              .toList();

          print('🟢 Active bank accounts: ${bankAccounts.length}');

          state = state.copyWith(
            bankAccounts: bankAccounts,
            isLoadingBankAccounts: false,
            error: null,
          );
        } else {
          print('🟡 No bank accounts data in response');
          state = state.copyWith(
            bankAccounts: [],
            isLoadingBankAccounts: false,
            error: null,
          );
        }
      } else {
        final error = response.data['message'] ?? 'Failed to fetch bank accounts';
        print('🔴 Error fetching bank accounts: $error');
        state = state.copyWith(
          error: error,
          isLoadingBankAccounts: false,
        );
        ToastUtils.showErrorToast(error, key: scaffoldMessengerKey);
      }
    } catch (e) {
      print('🔴 Exception fetching bank accounts: $e');
      state = state.copyWith(
        error: 'Failed to fetch bank accounts: ${e.toString()}',
        isLoadingBankAccounts: false,
      );
      ToastUtils.showErrorToast(
        'Failed to fetch bank accounts: ${e.toString()}',
        key: scaffoldMessengerKey,
      );
    }
  }

  // Update filters
  void updateFilters(ReconciliationFilters newFilters) {
    state = state.copyWith(
      filters: newFilters.copyWith(page: 1), // Reset to page 1
      reconciliations: [], // Clear existing data
      currentPage: 1,
    );
    fetchReconciliations();
  }

  // Clear selected reconciliation
  void clearSelectedReconciliation() {
    state = state.copyWith(selectedReconciliation: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data - ensures bank accounts are fetched
  Future<void> refresh() async {
    print('🔄 Refreshing bank reconciliation data...');
    await fetchBankAccounts();
    await fetchReconciliations();
  }

  // Get bank accounts for form
  List<ChartOfAccount> get availableBankAccounts {
    return state.bankAccounts
        .where((account) => account.isActive && account.isBankAccount)
        .toList();
  }

  // Check if bank accounts are loading
  bool get isBankAccountsLoading => state.isLoadingBankAccounts;

  // Check if bank accounts are loaded
  bool get areBankAccountsLoaded => state.bankAccounts.isNotEmpty && !state.isLoadingBankAccounts;
}

final bankReconciliationProvider =
StateNotifierProvider<BankReconciliationProvider, BankReconciliationState>(
      (ref) {
    final dio = ref.read(dioProvider);
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    final provider = BankReconciliationProvider(dio, scaffoldMessengerKey);
    return provider;
  },
);