import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/chart_of_account_model.dart';
import '../../../core/services/api_service.dart';

class ChartOfAccountsState {
  final List<ChartOfAccount> accounts;
  final List<AccountHierarchy> accountHierarchy;
  final List<ChartOfAccount> bankAccounts;
  final ChartOfAccount? selectedAccount;
  final bool isLoading;
  final bool isLoadingHierarchy;
  final bool isLoadingBankAccounts;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchQuery;
  final String? accountTypeFilter;
  final bool? isActiveFilter;

  ChartOfAccountsState({
    this.accounts = const [],
    this.accountHierarchy = const [],
    this.bankAccounts = const [],
    this.selectedAccount,
    this.isLoading = false,
    this.isLoadingHierarchy = false,
    this.isLoadingBankAccounts = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.searchQuery = '',
    this.accountTypeFilter,
    this.isActiveFilter,
  });

  ChartOfAccountsState copyWith({
    List<ChartOfAccount>? accounts,
    List<AccountHierarchy>? accountHierarchy,
    List<ChartOfAccount>? bankAccounts,
    ChartOfAccount? selectedAccount,
    bool? isLoading,
    bool? isLoadingHierarchy,
    bool? isLoadingBankAccounts,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchQuery,
    String? accountTypeFilter,
    bool? isActiveFilter,
  }) {
    return ChartOfAccountsState(
      accounts: accounts ?? this.accounts,
      accountHierarchy: accountHierarchy ?? this.accountHierarchy,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHierarchy: isLoadingHierarchy ?? this.isLoadingHierarchy,
      isLoadingBankAccounts: isLoadingBankAccounts ?? this.isLoadingBankAccounts,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      accountTypeFilter: accountTypeFilter ?? this.accountTypeFilter,
      isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    );
  }
}

class ChartOfAccountsProvider extends StateNotifier<ChartOfAccountsState> {
  final Dio dio;

  ChartOfAccountsProvider(this.dio) : super(ChartOfAccountsState());

  // Fetch accounts with pagination and filters
  Future<void> fetchAccounts({
    int page = 1,
    int limit = 10,
    String? search,
    String? accountType,
    bool? isActive,
  }) async {
    try {
      print('Fetching accounts - Page: $page, Search: $search, Type: $accountType');

      state = state.copyWith(
        isLoading: true,
        error: null,
        accounts: page == 1 ? [] : state.accounts,
      );

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (accountType != null && accountType.isNotEmpty)
          'accountType': accountType,
        if (isActive != null) 'isActive': isActive.toString(),
      };

      print('API Request: /v1/nawassco/accounts/chart-of-accounts');
      print('Query Params: $queryParams');

      final response = await dio.get(
        '/v1/nawassco/accounts/chart-of-accounts',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('API Response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        print('Response data: $data');

        if (data != null && data['result'] != null) {
          final accountsResponse = AccountsResponse.fromJson(data['result']);

          final combinedAccounts = page == 1
              ? accountsResponse.accounts
              : [...state.accounts, ...accountsResponse.accounts];

          print('Parsed ${accountsResponse.accounts.length} accounts');
          print('Pagination: ${accountsResponse.pagination.page}/${accountsResponse.pagination.pages}');

          state = state.copyWith(
            accounts: combinedAccounts,
            currentPage: accountsResponse.pagination.page,
            totalPages: accountsResponse.pagination.pages,
            totalCount: accountsResponse.pagination.total,
            isLoading: false,
            error: null,
          );
        } else {
          print('Unexpected response structure');
          state = state.copyWith(
            error: 'Unexpected response format',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch accounts',
          isLoading: false,
        );
      }
    } catch (e) {
      print('Error fetching accounts: $e');
      state = state.copyWith(
        error: 'Failed to fetch accounts: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Fetch account by ID
  Future<void> fetchAccountById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/chart-of-accounts/$id');

      if (response.data['success'] == true) {
        final account = ChartOfAccount.fromJson(response.data['data']['account']);
        state = state.copyWith(
          selectedAccount: account,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch account',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch account: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Create new account
  Future<bool> createAccount(ChartOfAccount account) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final accountData = account.toJson();
      accountData.remove('id');
      accountData.remove('createdAt');
      accountData.remove('updatedAt');
      accountData.remove('createdById');

      final response = await dio.post(
        '/v1/nawassco/accounts/chart-of-accounts',
        data: accountData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchAccounts(page: 1);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create account',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create account: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Update account
  Future<bool> updateAccount(String id, ChartOfAccount account) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updateData = {
        'accountCode': account.accountCode,
        'accountName': account.accountName,
        'accountType': account.accountType.name,
        'accountCategory': account.accountCategory.name,
        'description': account.description,
        'normalBalance': account.normalBalance.name,
        'isActive': account.isActive,
        'budgetAllowed': account.budgetAllowed,
        'requiresApproval': account.requiresApproval,
        'approvalLimit': account.approvalLimit,
        'taxApplicable': account.taxApplicable,
        'taxRate': account.taxRate,
        'isBankAccount': account.isBankAccount,
        'bankAccountNumber': account.bankAccountNumber,
        'bankName': account.bankName,
      };

      final response = await dio.put(
        '/v1/nawassco/accounts/chart-of-accounts/$id',
        data: updateData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchAccounts(page: state.currentPage);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update account',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update account: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete(
        '/v1/nawassco/accounts/chart-of-accounts/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final updatedAccounts = state.accounts.where((a) => a.id != id).toList();
        state = state.copyWith(
          accounts: updatedAccounts,
          isLoading: false,
        );

        await fetchAccounts(page: state.currentPage);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete account',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete account: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Fetch account hierarchy
  Future<void> fetchAccountHierarchy() async {
    try {
      state = state.copyWith(isLoadingHierarchy: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/accounts/chart-of-accounts/hierarchy',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final hierarchyData = response.data['data']['hierarchy'] as List<dynamic>;
        final hierarchy = hierarchyData
            .map((item) => AccountHierarchy.fromJson(item))
            .toList();

        state = state.copyWith(
          accountHierarchy: hierarchy,
          isLoadingHierarchy: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch hierarchy',
          isLoadingHierarchy: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch hierarchy: ${e.toString()}',
        isLoadingHierarchy: false,
      );
    }
  }

  // Fetch bank accounts
  Future<void> fetchBankAccounts() async {
    try {
      state = state.copyWith(isLoadingBankAccounts: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/accounts/chart-of-accounts/bank-accounts',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final bankAccountsData = response.data['data']['bankAccounts'] as List<dynamic>;
        final bankAccounts = bankAccountsData
            .map((item) => ChartOfAccount.fromJson(item))
            .toList();

        state = state.copyWith(
          bankAccounts: bankAccounts,
          isLoadingBankAccounts: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch bank accounts',
          isLoadingBankAccounts: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch bank accounts: ${e.toString()}',
        isLoadingBankAccounts: false,
      );
    }
  }

  // Update filters - Fixed to properly update state
  void updateFilters({
    String? searchQuery,
    String? accountType,
    bool? isActive,
  }) {
    // Handle the case where searchQuery is explicitly set to empty string
    final newSearchQuery = searchQuery ?? state.searchQuery;

    state = state.copyWith(
      searchQuery: newSearchQuery,
      accountTypeFilter: accountType,
      isActiveFilter: isActive,
      currentPage: 1,
      accounts: [], // Clear accounts when filters change
    );

    fetchAccounts(
      page: 1,
      search: newSearchQuery.isEmpty ? null : newSearchQuery,
      accountType: accountType,
      isActive: isActive,
    );
  }

  // Clear all filters - Fixed to properly reset state
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      accountTypeFilter: null,
      isActiveFilter: null,
      currentPage: 1,
      accounts: [],
    );

    fetchAccounts(
      page: 1,
      search: null,
      accountType: null,
      isActive: null,
    );
  }

  // Clear selected account
  void clearSelectedAccount() {
    state = state.copyWith(selectedAccount: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final chartOfAccountsProvider = StateNotifierProvider<ChartOfAccountsProvider, ChartOfAccountsState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return ChartOfAccountsProvider(dio);
  },
);