import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/strategic_plan_model.dart';

class StrategicPlanState {
  final List<StrategicPlan> strategicPlans;
  final StrategicPlan? selectedPlan;
  final ViewMode viewMode;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isSubmitting;
  final String? error;
  final String? searchQuery;
  final PlanStatus? filterStatus;
  final String? filterFiscalYear;

  StrategicPlanState({
    this.strategicPlans = const [],
    this.selectedPlan,
    this.viewMode = ViewMode.list,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isSubmitting = false,
    this.error,
    this.searchQuery,
    this.filterStatus,
    this.filterFiscalYear,
  });

  List<StrategicPlan> get filteredPlans {
    var plans = strategicPlans;

    // Apply search filter
    if (searchQuery?.isNotEmpty == true) {
      final query = searchQuery!.toLowerCase();
      plans = plans.where((plan) {
        return plan.title.toLowerCase().contains(query) ||
            plan.description.toLowerCase().contains(query) ||
            plan.fiscalYear.contains(query);
      }).toList();
    }

    // Apply status filter
    if (filterStatus != null) {
      plans = plans.where((plan) => plan.status == filterStatus).toList();
    }

    // Apply fiscal year filter
    if (filterFiscalYear != null && filterFiscalYear!.isNotEmpty) {
      plans = plans
          .where((plan) => plan.fiscalYear == filterFiscalYear)
          .toList();
    }

    return plans;
  }

  StrategicPlanState copyWith({
    List<StrategicPlan>? strategicPlans,
    StrategicPlan? selectedPlan,
    ViewMode? viewMode,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isSubmitting,
    String? error,
    String? searchQuery,
    PlanStatus? filterStatus,
    String? filterFiscalYear,
  }) {
    return StrategicPlanState(
      strategicPlans: strategicPlans ?? this.strategicPlans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      filterFiscalYear: filterFiscalYear ?? this.filterFiscalYear,
    );
  }
}

enum ViewMode { list, details, create, edit }

class StrategicPlanProvider extends StateNotifier<StrategicPlanState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  StrategicPlanProvider(this._dio, this._scaffoldMessengerKey)
      : super(StrategicPlanState());

  // Helper method to show toasts safely
  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
    } else {
      ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
    }
  }

  // Change view mode
  void changeViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  // Select a plan
  void selectPlan(StrategicPlan plan) {
    state = state.copyWith(
      selectedPlan: plan,
      viewMode: ViewMode.details,
    );
  }

  // Clear selection
  void clearSelection() {
    state = state.copyWith(
      selectedPlan: null,
      viewMode: ViewMode.list,
    );
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set filters
  void setFilterStatus(PlanStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  void setFilterFiscalYear(String? year) {
    state = state.copyWith(filterFiscalYear: year);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      filterStatus: null,
      filterFiscalYear: null,
      searchQuery: null,
    );
  }

  // REMOVED the filteredPlans getter from here since it's now in StrategicPlanState

  // Load all strategic plans
  Future<void> loadStrategicPlans() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/manager/strategic-plans');

      if (response.data['success'] == true) {
        final plans = (response.data['data']['strategicPlans'] as List)
            .map((plan) => StrategicPlan.fromJson(plan))
            .toList();

        state = state.copyWith(
          strategicPlans: plans,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load strategic plans',
          isLoading: false,
        );
        _showToast('Failed to load strategic plans', isError: true);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading strategic plans: $e',
        isLoading: false,
      );
      _showToast('Error loading strategic plans', isError: true);
    }
  }

  // Create new strategic plan
  Future<void> createStrategicPlan(StrategicPlan plan) async {
    try {
      state = state.copyWith(isCreating: true);

      final response = await _dio.post(
        '/v1/nawassco/manager/strategic-plans',
        data: plan.toJson(),
      );

      if (response.data['success'] == true) {
        final newPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        state = state.copyWith(
          strategicPlans: [...state.strategicPlans, newPlan],
          selectedPlan: newPlan,
          viewMode: ViewMode.details,
          isCreating: false,
        );
        _showToast('Strategic plan created successfully');
      } else {
        state = state.copyWith(isCreating: false);
        _showToast(
          response.data['message'] ?? 'Failed to create strategic plan',
          isError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isCreating: false);
      _showToast('Error creating strategic plan: $e', isError: true);
    }
  }

  // Update strategic plan
  Future<void> updateStrategicPlan(String id, StrategicPlan plan) async {
    try {
      state = state.copyWith(isUpdating: true);

      final response = await _dio.put(
        '/v1/nawassco/manager/strategic-plans/$id',
        data: plan.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == id ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
          isUpdating: false,
        );
        _showToast('Strategic plan updated successfully');
      } else {
        state = state.copyWith(isUpdating: false);
        _showToast(
          response.data['message'] ?? 'Failed to update strategic plan',
          isError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      _showToast('Error updating strategic plan: $e', isError: true);
    }
  }

  // Delete strategic plan
  Future<void> deleteStrategicPlan(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _dio.delete('/v1/nawassco/manager/strategic-plans/$id');

      if (response.data['success'] == true) {
        final updatedPlans =
        state.strategicPlans.where((p) => p.id != id).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan:
          state.selectedPlan?.id == id ? null : state.selectedPlan,
          viewMode:
          state.selectedPlan?.id == id ? ViewMode.list : state.viewMode,
          isLoading: false,
        );
        _showToast('Strategic plan deleted successfully');
      } else {
        state = state.copyWith(isLoading: false);
        _showToast(
          response.data['message'] ?? 'Failed to delete strategic plan',
          isError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Error deleting strategic plan: $e', isError: true);
    }
  }

  // Add strategic goal
  Future<void> addStrategicGoal(String planId, StrategicGoal goal) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/manager/strategic-plans/$planId/goals',
        data: goal.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Strategic goal added successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to add strategic goal',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error adding strategic goal: $e', isError: true);
    }
  }

  // Update goal progress
  Future<void> updateGoalProgress(
      String planId,
      String goalNumber,
      double progress,
      GoalStatus status,
      ) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/manager/strategic-plans/$planId/goals/progress',
        data: {
          'goalNumber': goalNumber,
          'progress': progress,
          'status': status.toString().split('.').last,
        },
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Goal progress updated successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to update goal progress',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error updating goal progress: $e', isError: true);
    }
  }

  // Add strategic initiative
  Future<void> addStrategicInitiative(
      String planId,
      StrategicInitiative initiative,
      ) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/manager/strategic-plans/$planId/initiatives',
        data: initiative.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Strategic initiative added successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to add strategic initiative',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error adding strategic initiative: $e', isError: true);
    }
  }

  // Update initiative progress
  Future<void> updateInitiativeProgress(
      String planId,
      String initiativeNumber,
      double progress,
      InitiativeStatus status,
      ) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/manager/strategic-plans/$planId/initiatives/progress',
        data: {
          'initiativeNumber': initiativeNumber,
          'progress': progress,
          'status': status.toString().split('.').last,
        },
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Initiative progress updated successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to update initiative progress',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error updating initiative progress: $e', isError: true);
    }
  }

  // Submit plan for approval
  Future<void> submitForApproval(String planId) async {
    try {
      state = state.copyWith(isSubmitting: true);

      final response = await _dio.post('/v1/nawassco/manager/strategic-plans/$planId/submit');

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
          isSubmitting: false,
        );
        _showToast('Strategic plan submitted for approval');
      } else {
        state = state.copyWith(isSubmitting: false);
        _showToast(
          response.data['message'] ?? 'Failed to submit for approval',
          isError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      _showToast('Error submitting for approval: $e', isError: true);
    }
  }

  // Approve strategic plan
  Future<void> approveStrategicPlan(String planId, String approverId) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/manager/strategic-plans/$planId/approve',
        data: {'approvedBy': approverId},
      );

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Strategic plan approved successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to approve strategic plan',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error approving strategic plan: $e', isError: true);
    }
  }

  // Activate strategic plan
  Future<void> activateStrategicPlan(String planId) async {
    try {
      final response = await _dio.post('/v1/nawassco/manager/strategic-plans/$planId/activate');

      if (response.data['success'] == true) {
        final updatedPlan =
        StrategicPlan.fromJson(response.data['data']['strategicPlan']);

        final updatedPlans = state.strategicPlans.map((p) {
          return p.id == planId ? updatedPlan : p;
        }).toList();

        state = state.copyWith(
          strategicPlans: updatedPlans,
          selectedPlan: updatedPlan,
        );
        _showToast('Strategic plan activated successfully');
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to activate strategic plan',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Error activating strategic plan: $e', isError: true);
    }
  }

  // Load plan statistics
  Future<Map<String, dynamic>> loadPlanStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/manager/strategic-plans/stats');

      if (response.data['success'] == true) {
        return response.data['data']['stats'];
      } else {
        _showToast(
          response.data['message'] ?? 'Failed to load plan statistics',
          isError: true,
        );
        return {};
      }
    } catch (e) {
      _showToast('Error loading plan statistics: $e', isError: true);
      return {};
    }
  }
}

// Provider
final strategicPlanProvider =
StateNotifierProvider<StrategicPlanProvider, StrategicPlanState>((ref) {
  final dio = ref.read(dioProvider);
  return StrategicPlanProvider(dio, scaffoldMessengerKey);
});