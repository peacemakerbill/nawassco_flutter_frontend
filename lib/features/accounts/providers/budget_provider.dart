import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/budget_model.dart';
import '../models/chart_of_account_model.dart';
import 'chart_of_accounts_provider.dart';

class BudgetState {
  final List<Budget> budgets;
  final Budget? selectedBudget;
  final BudgetPerformance? performance;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchQuery;
  final String? fiscalYearFilter;
  final String? periodTypeFilter;
  final String? statusFilter;
  final bool isSubmitting;

  BudgetState({
    this.budgets = const [],
    this.selectedBudget,
    this.performance,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.searchQuery = '',
    this.fiscalYearFilter,
    this.periodTypeFilter,
    this.statusFilter,
    this.isSubmitting = false,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    Budget? selectedBudget,
    BudgetPerformance? performance,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchQuery,
    String? fiscalYearFilter,
    String? periodTypeFilter,
    String? statusFilter,
    bool? isSubmitting,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      selectedBudget: selectedBudget ?? this.selectedBudget,
      performance: performance ?? this.performance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      fiscalYearFilter: fiscalYearFilter ?? this.fiscalYearFilter,
      periodTypeFilter: periodTypeFilter ?? this.periodTypeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class BudgetProvider extends StateNotifier<BudgetState> {
  final Dio dio;
  final Ref ref;

  BudgetProvider(this.dio, this.ref) : super(BudgetState());

  // Fetch budgets with pagination and filters
  Future<void> fetchBudgets({
    int page = 1,
    int limit = 10,
    String? search,
    String? fiscalYear,
    String? periodType,
    String? status,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (fiscalYear != null && fiscalYear.isNotEmpty)
          'fiscalYear': fiscalYear,
        if (periodType != null && periodType.isNotEmpty)
          'periodType': periodType,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/budgets',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['result'] != null) {
          final budgetsResponse = BudgetsResponse.fromJson(data['result']);

          state = state.copyWith(
            budgets: budgetsResponse.budgets,
            currentPage: budgetsResponse.pagination.page,
            totalPages: budgetsResponse.pagination.pages,
            totalCount: budgetsResponse.pagination.total,
            isLoading: false,
            error: null,
          );
        } else {
          state = state.copyWith(
            error: 'Unexpected response format',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch budgets',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch budgets: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Fetch budget by ID
  Future<void> fetchBudgetById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/accounts/budgets/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['budget'] != null) {
          final budget = Budget.fromJson(data['budget']);
          state = state.copyWith(
            selectedBudget: budget,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: 'Budget data not found',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch budget',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch budget: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Create new budget
  Future<bool> createBudget(Map<String, dynamic> budgetData) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/budgets',
        data: budgetData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgets(page: 1);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create budget',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create budget: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Update budget
  Future<bool> updateBudget(String id, Map<String, dynamic> budgetData) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/budgets/$id',
        data: budgetData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(id);
        await fetchBudgets(page: state.currentPage);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update budget',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update budget: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Submit budget for review
  Future<bool> submitBudget(String id) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/budgets/$id/submit',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(id);
        await fetchBudgets(page: state.currentPage);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to submit budget',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to submit budget: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Approve budget
  Future<bool> approveBudget(String id) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/budgets/$id/approve',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(id);
        await fetchBudgets(page: state.currentPage);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to approve budget',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to approve budget: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Close budget
  Future<bool> closeBudget(String id) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/budgets/$id/close',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(id);
        await fetchBudgets(page: state.currentPage);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to close budget',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to close budget: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Add budget item
  Future<bool> addBudgetItem(String budgetId, Map<String, dynamic> itemData) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/budgets/$budgetId/items',
        data: itemData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(budgetId);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to add budget item',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to add budget item: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Update budget item
  Future<bool> updateBudgetItem(
      String budgetId, String itemId, Map<String, dynamic> itemData) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/budgets/$budgetId/items/$itemId',
        data: itemData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchBudgetById(budgetId);
        state = state.copyWith(isSubmitting: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update budget item',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update budget item: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Fetch budget performance
  Future<void> fetchBudgetPerformance(
      {String? fiscalYear, String? periodType}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = <String, dynamic>{
        if (fiscalYear != null && fiscalYear.isNotEmpty)
          'fiscalYear': fiscalYear,
        if (periodType != null && periodType.isNotEmpty)
          'periodType': periodType,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/budgets/performance',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['performance'] != null) {
          final performance =
          BudgetPerformance.fromJson(data['performance']);
          state = state.copyWith(
            performance: performance,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: 'Performance data not found',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch performance',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch performance: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Update filters
  void updateFilters({
    String? searchQuery,
    String? fiscalYear,
    String? periodType,
    String? status,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      fiscalYearFilter: fiscalYear ?? state.fiscalYearFilter,
      periodTypeFilter: periodType ?? state.periodTypeFilter,
      statusFilter: status ?? state.statusFilter,
      currentPage: 1,
    );

    fetchBudgets(
      page: 1,
      search: searchQuery ?? state.searchQuery,
      fiscalYear: fiscalYear ?? state.fiscalYearFilter,
      periodType: periodType ?? state.periodTypeFilter,
      status: status ?? state.statusFilter,
    );
  }

  // Get budget allowed accounts from Chart of Accounts provider
  List<ChartOfAccount> getBudgetAllowedAccounts() {
    final chartOfAccountsState = ref.read(chartOfAccountsProvider);
    return chartOfAccountsState.accounts
        .where((account) => account.budgetAllowed && account.isActive)
        .toList();
  }

  // Get bank accounts from Chart of Accounts provider
  List<ChartOfAccount> getBankAccounts() {
    final chartOfAccountsState = ref.read(chartOfAccountsProvider);
    return chartOfAccountsState.bankAccounts
        .where((account) => account.isActive)
        .toList();
  }

  // Refresh chart of accounts data
  Future<void> refreshChartOfAccounts() async {
    await ref.read(chartOfAccountsProvider.notifier).fetchAccounts();
    await ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();
  }

  // Clear selected budget
  void clearSelectedBudget() {
    state = state.copyWith(selectedBudget: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final budgetProvider = StateNotifierProvider<BudgetProvider, BudgetState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return BudgetProvider(dio, ref);
  },
);