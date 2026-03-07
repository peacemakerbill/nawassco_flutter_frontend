import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/opportunity.model.dart';
import 'sales_rep_provider.dart';


// ============================================
// STATE CLASS
// ============================================

class OpportunityState {
  final bool isLoading;
  final List<Opportunity> opportunities;
  final Opportunity? selectedOpportunity;
  final OpportunityFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final OpportunityStats? stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isUpdatingStage;
  final bool showForm;
  final bool showDetails;
  final bool showStats;
  final String? error;
  final bool isSalesRepView;
  final bool hasMore;

  const OpportunityState({
    this.isLoading = false,
    this.opportunities = const [],
    this.selectedOpportunity,
    this.filters = const OpportunityFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.stats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isUpdatingStage = false,
    this.showForm = false,
    this.showDetails = false,
    this.showStats = false,
    this.error,
    this.isSalesRepView = false,
    this.hasMore = true,
  });

  OpportunityState copyWith({
    bool? isLoading,
    List<Opportunity>? opportunities,
    Opportunity? selectedOpportunity,
    OpportunityFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    OpportunityStats? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isUpdatingStage,
    bool? showForm,
    bool? showDetails,
    bool? showStats,
    String? error,
    bool? isSalesRepView,
    bool? hasMore,
  }) {
    return OpportunityState(
      isLoading: isLoading ?? this.isLoading,
      opportunities: opportunities ?? this.opportunities,
      selectedOpportunity: selectedOpportunity ?? this.selectedOpportunity,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdatingStage: isUpdatingStage ?? this.isUpdatingStage,
      showForm: showForm ?? this.showForm,
      showDetails: showDetails ?? this.showDetails,
      showStats: showStats ?? this.showStats,
      error: error ?? this.error,
      isSalesRepView: isSalesRepView ?? this.isSalesRepView,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ============================================
// PROVIDER
// ============================================

class OpportunityProvider extends StateNotifier<OpportunityState> {
  final Dio _dio;
  final Ref _ref;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  OpportunityProvider(this._dio, this._ref, this._scaffoldKey)
      : super(const OpportunityState()) {
    // Initial load when provider is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Wait a bit to ensure provider is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));
    await loadOpportunities(refresh: true);
    await loadStats();
  }

  // Get current user from auth provider
  Map<String, dynamic>? get _currentUser {
    final authState = _ref.read(authProvider);
    return authState.user;
  }

  // Get current sales rep ID for filtering
  String? get _currentSalesRepId {
    final salesRepState = _ref.read(salesRepProvider);
    return salesRepState.currentSalesRep?.id;
  }

  // Check if current user is sales rep
  bool get _isSalesRep {
    final authState = _ref.read(authProvider);
    return authState.isSalesAgent;
  }

  // -----------------------------------------------------------------
  // CRUD OPERATIONS
  // -----------------------------------------------------------------

  Future<void> loadOpportunities({bool refresh = false}) async {
    // Prevent multiple concurrent loads
    if (state.isLoading && !refresh) return;

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final currentPage = refresh ? 1 : state.currentPage;

      // Build query parameters
      final query = {
        'page': currentPage.toString(),
        'limit': '10',
        ...state.filters.toQueryParams(),
      };

      // If sales rep view, only show assigned opportunities
      if (state.isSalesRepView && _currentSalesRepId != null) {
        query['assignedTo'] = _currentSalesRepId;
      }

      debugPrint('Loading opportunities - Page: $currentPage, Filters: ${state.filters.toQueryParams()}');

      final response = await _dio.get(
        '/v1/nawassco/sales/opportunities',
        queryParameters: query,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final data = response.data['data'] as List? ?? [];
        final pagination = response.data['pagination'] as Map<String, dynamic>? ?? {};

        debugPrint('Found ${data.length} opportunities in response');

        // Parse opportunities
        final List<Opportunity> opportunities = [];
        for (var json in data) {
          try {
            final opportunity = Opportunity.fromJson(json as Map<String, dynamic>);
            opportunities.add(opportunity);
          } catch (e) {
            debugPrint('Error parsing opportunity: $e');
            debugPrint('Problematic JSON: $json');
            continue;
          }
        }

        final totalPages = (pagination['pages'] ?? 1) as int;
        final totalItems = (pagination['total'] ?? 0) as int;
        final nextPage = (pagination['page'] ?? currentPage) as int;
        final hasMore = nextPage < totalPages;

        debugPrint('Pagination - Total: $totalItems, Pages: $totalPages, Current: $nextPage, Has More: $hasMore');

        state = state.copyWith(
          opportunities: refresh ? opportunities : [...state.opportunities, ...opportunities],
          totalPages: totalPages,
          totalItems: totalItems,
          currentPage: nextPage,
          isLoading: false,
          hasMore: hasMore,
          error: null,
        );

        debugPrint('Successfully loaded ${opportunities.length} opportunities. Total in state: ${state.opportunities.length}');
      } else {
        final errorMessage = response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Failed to load opportunities (Status: ${response.statusCode})';
        debugPrint('API Error: $errorMessage');
        _showError(errorMessage);
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in loadOpportunities: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in loadOpportunities: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error: ${e.toString()}',
      );
      ToastUtils.showErrorToast('Failed to load opportunities', key: _scaffoldKey);
    }
  }

  Future<void> loadOpportunity(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      debugPrint('Loading opportunity details for ID: $id');

      final response = await _dio.get('/v1/nawassco/sales/opportunities/$id');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final opportunityData = response.data['data'] as Map<String, dynamic>?;
        if (opportunityData != null) {
          final opportunity = Opportunity.fromJson(opportunityData);
          state = state.copyWith(
            selectedOpportunity: opportunity,
            isLoading: false,
            error: null,
          );
          debugPrint('Loaded opportunity: ${opportunity.opportunityNumber}');
        } else {
          _showError('Opportunity data is null');
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to load opportunity');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<Opportunity?> createOpportunity(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      debugPrint('Creating opportunity with data: $data');

      // Add createdBy information from current user
      final enrichedData = {
        ...data,
        'createdBy': _currentUser?['_id'],
        'createdByName': '${_currentUser?['firstName'] ?? ''} ${_currentUser?['lastName'] ?? ''}'.trim(),
        'createdByEmail': _currentUser?['email'],
      };

      final response = await _dio.post(
        '/v1/nawassco/sales/opportunities',
        data: enrichedData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 201 &&
          response.data != null &&
          response.data['success'] == true) {

        final opportunityData = response.data['data'] as Map<String, dynamic>?;
        if (opportunityData != null) {
          final opportunity = Opportunity.fromJson(opportunityData);

          state = state.copyWith(
            opportunities: [opportunity, ...state.opportunities],
            selectedOpportunity: opportunity,
            isCreating: false,
            error: null,
            showForm: false,
          );

          _showSuccess('Opportunity created successfully');
          debugPrint('Created opportunity: ${opportunity.opportunityNumber}');
          return opportunity;
        } else {
          _showError('Created opportunity data is null');
          return null;
        }
      } else {
        // Handle validation errors
        if (response.statusCode == 422) {
          final errors = response.data?['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              _showError(firstError.first.toString());
            } else {
              _showError('Validation failed');
            }
          } else {
            _showError(response.data?['message']?.toString() ?? 'Validation failed');
          }
        } else {
          _showError(response.data?['message']?.toString() ?? 'Failed to create opportunity');
        }
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }

  Future<Opportunity?> updateOpportunity(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      debugPrint('Updating opportunity $id with data: $data');

      // Add updatedBy information
      final enrichedData = {
        ...data,
        'updatedBy': _currentUser?['_id'],
        'updatedByName': '${_currentUser?['firstName'] ?? ''} ${_currentUser?['lastName'] ?? ''}'.trim(),
        'updatedByEmail': _currentUser?['email'],
      };

      final response = await _dio.put(
        '/v1/nawassco/sales/opportunities/$id',
        data: enrichedData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final updatedOpportunityData = response.data['data'] as Map<String, dynamic>?;
        if (updatedOpportunityData != null) {
          final updatedOpportunity = Opportunity.fromJson(updatedOpportunityData);

          final updatedOpportunities = state.opportunities.map((opportunity) {
            return opportunity.id == id ? updatedOpportunity : opportunity;
          }).toList();

          state = state.copyWith(
            opportunities: updatedOpportunities,
            selectedOpportunity: updatedOpportunity,
            isUpdating: false,
            error: null,
            showForm: false,
          );

          _showSuccess('Opportunity updated successfully');
          debugPrint('Updated opportunity: ${updatedOpportunity.opportunityNumber}');
          return updatedOpportunity;
        } else {
          _showError('Updated opportunity data is null');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update opportunity');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> deleteOpportunity(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      debugPrint('Deleting opportunity: $id');

      final response = await _dio.delete('/v1/nawassco/sales/opportunities/$id');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        // Remove from local state
        final updatedOpportunities = state.opportunities
            .where((opportunity) => opportunity.id != id)
            .toList();

        state = state.copyWith(
          opportunities: updatedOpportunities,
          selectedOpportunity: state.selectedOpportunity?.id == id ? null : state.selectedOpportunity,
          isDeleting: false,
          error: null,
          showDetails: state.selectedOpportunity?.id == id ? false : state.showDetails,
        );

        _showSuccess('Opportunity deleted successfully');
        debugPrint('Deleted opportunity: $id');
        return true;
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to delete opportunity');
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  // -----------------------------------------------------------------
  // SPECIFIC OPERATIONS (Matching backend routes)
  // -----------------------------------------------------------------

  Future<Opportunity?> updateStage(
      String id,
      SalesStage stage, {
        String? nextStep,
        DateTime? nextStepDate,
      }) async {
    try {
      state = state.copyWith(isUpdatingStage: true, error: null);

      final data = {
        'stage': stage.name,
        if (nextStep != null && nextStep.isNotEmpty) 'nextStep': nextStep,
        if (nextStepDate != null) 'nextStepDate': nextStepDate.toIso8601String(),
      };

      debugPrint('Updating stage for opportunity $id: $data');

      final response = await _dio.put(
        '/v1/nawassco/sales/opportunities/$id/stage',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final updatedOpportunityData = response.data['data'] as Map<String, dynamic>?;
        if (updatedOpportunityData != null) {
          final updatedOpportunity = Opportunity.fromJson(updatedOpportunityData);

          final updatedOpportunities = state.opportunities.map((opportunity) {
            return opportunity.id == id ? updatedOpportunity : opportunity;
          }).toList();

          state = state.copyWith(
            opportunities: updatedOpportunities,
            selectedOpportunity: state.selectedOpportunity?.id == id ? updatedOpportunity : state.selectedOpportunity,
            isUpdatingStage: false,
            error: null,
          );

          _showSuccess('Stage updated successfully');
          debugPrint('Updated stage for opportunity: ${updatedOpportunity.opportunityNumber}');
          return updatedOpportunity;
        } else {
          _showError('Updated opportunity data is null after stage update');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update stage');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdatingStage: false);
    }
  }

  Future<Opportunity?> addCompetitor(String id, Map<String, dynamic> competitorData) async {
    try {
      debugPrint('Adding competitor to opportunity: $id');

      final response = await _dio.post(
        '/v1/nawassco/sales/opportunities/$id/competitors',
        data: competitorData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final updatedOpportunityData = response.data['data'] as Map<String, dynamic>?;
        if (updatedOpportunityData != null) {
          final updatedOpportunity = Opportunity.fromJson(updatedOpportunityData);

          final updatedOpportunities = state.opportunities.map((opportunity) {
            return opportunity.id == id ? updatedOpportunity : opportunity;
          }).toList();

          state = state.copyWith(
            opportunities: updatedOpportunities,
            selectedOpportunity: state.selectedOpportunity?.id == id ? updatedOpportunity : state.selectedOpportunity,
            error: null,
          );

          _showSuccess('Competitor added successfully');
          debugPrint('Added competitor to opportunity: ${updatedOpportunity.opportunityNumber}');
          return updatedOpportunity;
        } else {
          _showError('Updated opportunity data is null after adding competitor');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to add competitor');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Opportunity?> addDecisionMaker(String id, Map<String, dynamic> decisionMakerData) async {
    try {
      debugPrint('Adding decision maker to opportunity: $id');

      final response = await _dio.post(
        '/v1/nawassco/sales/opportunities/$id/decision-makers',
        data: decisionMakerData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final updatedOpportunityData = response.data['data'] as Map<String, dynamic>?;
        if (updatedOpportunityData != null) {
          final updatedOpportunity = Opportunity.fromJson(updatedOpportunityData);

          final updatedOpportunities = state.opportunities.map((opportunity) {
            return opportunity.id == id ? updatedOpportunity : opportunity;
          }).toList();

          state = state.copyWith(
            opportunities: updatedOpportunities,
            selectedOpportunity: state.selectedOpportunity?.id == id ? updatedOpportunity : state.selectedOpportunity,
            error: null,
          );

          _showSuccess('Decision maker added successfully');
          debugPrint('Added decision maker to opportunity: ${updatedOpportunity.opportunityNumber}');
          return updatedOpportunity;
        } else {
          _showError('Updated opportunity data is null after adding decision maker');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to add decision maker');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<void> loadStats() async {
    try {
      debugPrint('Loading opportunity stats');

      final response = await _dio.get('/v1/nawassco/sales/opportunities/stats');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {

        final statsData = response.data['data'] as Map<String, dynamic>?;
        if (statsData != null) {
          final stats = OpportunityStats.fromJson(statsData);
          state = state.copyWith(stats: stats);
          debugPrint('Loaded opportunity stats');
        }
      } else {
        debugPrint('Failed to load stats: ${response.data?['message']}');
      }
    } catch (e) {
      // Silently fail for stats - it's not critical
      debugPrint('Failed to load stats: $e');
    }
  }

  // -----------------------------------------------------------------
  // STATE MANAGEMENT
  // -----------------------------------------------------------------

  void showOpportunityForm({Opportunity? opportunity}) {
    state = state.copyWith(
      showForm: true,
      showDetails: false,
      showStats: false,
      selectedOpportunity: opportunity,
    );
  }

  void showOpportunityDetails(Opportunity opportunity) {
    state = state.copyWith(
      showDetails: true,
      showForm: false,
      showStats: false,
      selectedOpportunity: opportunity,
    );
  }

  void showOpportunityStats() {
    state = state.copyWith(
      showStats: true,
      showForm: false,
      showDetails: false,
    );
  }

  void showOpportunityList() {
    state = state.copyWith(
      showForm: false,
      showDetails: false,
      showStats: false,
      selectedOpportunity: null,
    );
  }

  void selectOpportunity(Opportunity? opportunity) {
    state = state.copyWith(selectedOpportunity: opportunity);
  }

  void updateFilters(OpportunityFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      opportunities: [],
      hasMore: true,
    );
    loadOpportunities(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const OpportunityFilters(),
      currentPage: 1,
      opportunities: [],
      hasMore: true,
    );
    loadOpportunities(refresh: true);
  }

  Future<void> loadNextPage() async {
    if (state.currentPage < state.totalPages &&
        !state.isLoading &&
        state.hasMore) {
      debugPrint('Loading next page: ${state.currentPage + 1}');
      state = state.copyWith(currentPage: state.currentPage + 1);
      await loadOpportunities();
    }
  }

  void refreshData() {
    debugPrint('Refreshing opportunity data');
    state = state.copyWith(
      currentPage: 1,
      opportunities: [],
      hasMore: true,
    );
    loadOpportunities(refresh: true);
    loadStats();
  }

  void toggleSalesRepView() {
    final newView = !state.isSalesRepView;
    state = state.copyWith(
      isSalesRepView: newView,
      currentPage: 1,
      opportunities: [],
      hasMore: true,
      showForm: false,
      showDetails: false,
      showStats: false,
      selectedOpportunity: null,
    );
    loadOpportunities(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // -----------------------------------------------------------------
  // ERROR HANDLING
  // -----------------------------------------------------------------

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
      debugPrint('DioException: ${error.type}');
      debugPrint('Message: ${error.message}');
      debugPrint('Response: ${error.response?.data}');
      debugPrint('Status: ${error.response?.statusCode}');

      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Resource not found.';
      } else if (error.response?.statusCode == 409) {
        errorMessage = 'Opportunity already exists with this number.';
      } else if (error.response?.statusCode == 422) {
        final data = error.response!.data;
        if (data is Map && data['errors'] != null) {
          // Handle validation errors
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = 'Validation error: ${firstError.toString()}';
            }
          } else {
            errorMessage = data['message']?.toString() ?? 'Validation failed';
          }
        } else if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please check your connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (error.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error. Please try again later.';
      } else if (error.type == DioExceptionType.cancel) {
        errorMessage = 'Request was cancelled.';
      } else if (error.type == DioExceptionType.unknown) {
        errorMessage = 'Network error. Please check your connection.';
      }
    } else {
      errorMessage = error.toString();
    }

    debugPrint('OpportunityProvider Error: $errorMessage');

    state = state.copyWith(
        error: errorMessage,
        isLoading: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
        isUpdatingStage: false
    );

    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================

final opportunityProvider = StateNotifierProvider<OpportunityProvider, OpportunityState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return OpportunityProvider(dio, ref, scaffoldMessengerKey);
  },
);