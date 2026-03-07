import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/features/sales/providers/sales_rep_provider.dart';
import 'package:nawassco/main.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/lead_models.dart';

// State Classes
class LeadListState {
  final List<Lead> leads;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Map<String, dynamic> filters;
  final Lead? selectedLead;
  final bool showForm;
  final bool showDetails;
  final bool showStats;
  final bool isSalesRepView;

  LeadListState({
    this.leads = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.filters = const {},
    this.selectedLead,
    this.showForm = false,
    this.showDetails = false,
    this.showStats = false,
    this.isSalesRepView = false,
  });

  LeadListState copyWith({
    List<Lead>? leads,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    Map<String, dynamic>? filters,
    Lead? selectedLead,
    bool? showForm,
    bool? showDetails,
    bool? showStats,
    bool? isSalesRepView,
  }) {
    return LeadListState(
      leads: leads ?? this.leads,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      filters: filters ?? this.filters,
      selectedLead: selectedLead ?? this.selectedLead,
      showForm: showForm ?? this.showForm,
      showDetails: showDetails ?? this.showDetails,
      showStats: showStats ?? this.showStats,
      isSalesRepView: isSalesRepView ?? this.isSalesRepView,
    );
  }
}

class LeadStatsState {
  final LeadStats? stats;
  final bool isLoading;
  final String? error;

  LeadStatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  LeadStatsState copyWith({
    LeadStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return LeadStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Main Provider
class LeadProvider extends StateNotifier<LeadListState> {
  final Dio dio;
  final Ref ref;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  LeadProvider(this.dio, this.ref, this.scaffoldMessengerKey)
      : super(LeadListState());

  // Get current user from auth provider
  Map<String, dynamic>? get _currentUser {
    final authState = ref.read(authProvider);
    return authState.user;
  }

  // Get current sales rep ID
  String? get _currentSalesRepId {
    final salesRepState = ref.read(salesRepProvider);
    return salesRepState.currentSalesRep?.id;
  }

  // Show toast safely
  void _showToastSafely(VoidCallback showToast) {
    showToast();
  }

  // Fetch leads with pagination and filters
  Future<void> fetchLeads({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? customFilters,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get user role
      final authState = ref.read(authProvider);
      final isSalesRep = authState.isSalesAgent;

      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Add custom filters
      if (customFilters != null) {
        queryParams.addAll(customFilters);
      } else if (state.filters.isNotEmpty) {
        queryParams.addAll(state.filters);
      }

      // If sales rep, only fetch assigned leads
      if (isSalesRep && _currentSalesRepId != null) {
        queryParams['assignedTo'] = _currentSalesRepId;
      }

      final response = await dio.get(
        '/v1/nawassco/sales/leads',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final pagination = response.data['pagination'] ?? {};

        final leads = data.map((json) => Lead.fromJson(json)).toList();

        state = state.copyWith(
          leads: leads,
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['pages'] ?? 1,
          totalItems: pagination['total'] ?? 0,
          filters: customFilters ?? state.filters,
          isLoading: false,
          isSalesRepView: isSalesRep,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch leads',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to fetch leads',
            key: scaffoldMessengerKey,
          );
        });
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to fetch leads: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
    }
  }

  // Fetch single lead by ID
  Future<void> fetchLeadById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/sales/leads/$id');

      if (response.data['success'] == true) {
        final lead = Lead.fromJson(response.data['data']);
        state = state.copyWith(
          selectedLead: lead,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Lead not found',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Lead not found',
            key: scaffoldMessengerKey,
          );
        });
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to fetch lead: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
    }
  }

  Future<bool> createLead(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // The backend controller will add it automatically from the authenticated user
      final leadData = {...data};
      leadData.remove('createdBy');

      final response = await dio.post(
        '/v1/nawassco/sales/leads',
        data: leadData,
      );

      if (response.data['success'] == true) {
        final newLead = Lead.fromJson(response.data['data']);
        state = state.copyWith(
          leads: [newLead, ...state.leads],
          isLoading: false,
          showForm: false,
        );
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Lead created successfully!',
            key: scaffoldMessengerKey,
          );
        });
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create lead',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to create lead',
            key: scaffoldMessengerKey,
          );
        });
        return false;
      }
    } catch (e, stackTrace) {
      print('Error creating lead: $e');
      print('Stack trace: $stackTrace');

      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to create lead: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return false;
    }
  }

  // Update lead
  Future<bool> updateLead(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/sales/leads/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        final updatedLead = Lead.fromJson(response.data['data']);

        // Update in list
        final updatedList = state.leads.map((lead) {
          return lead.id == id ? updatedLead : lead;
        }).toList();

        state = state.copyWith(
          leads: updatedList,
          selectedLead:
          state.selectedLead?.id == id ? updatedLead : state.selectedLead,
          isLoading: false,
          showForm: false,
        );
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Lead updated successfully!',
            key: scaffoldMessengerKey,
          );
        });
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update lead',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to update lead',
            key: scaffoldMessengerKey,
          );
        });
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to update lead: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return false;
    }
  }

  // Delete lead
  Future<bool> deleteLead(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/sales/leads/$id');

      if (response.data['success'] == true) {
        // Remove from list
        final updatedList = state.leads.where((lead) => lead.id != id).toList();
        state = state.copyWith(
          leads: updatedList,
          selectedLead:
          state.selectedLead?.id == id ? null : state.selectedLead,
          isLoading: false,
          showDetails: state.selectedLead?.id == id ? false : state.showDetails,
        );
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Lead deleted successfully!',
            key: scaffoldMessengerKey,
          );
        });
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete lead',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to delete lead',
            key: scaffoldMessengerKey,
          );
        });
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to delete lead: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return false;
    }
  }

  // Convert lead to customer
  Future<bool> convertLead(String id, Map<String, dynamic> customerData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/sales/leads/$id/convert',
        data: customerData,
      );

      if (response.data['success'] == true) {
        // Update lead in list
        final updatedLead = Lead.fromJson(response.data['data']['lead']);
        final updatedList = state.leads.map((lead) {
          return lead.id == id ? updatedLead : lead;
        }).toList();

        state = state.copyWith(
          leads: updatedList,
          selectedLead:
          state.selectedLead?.id == id ? updatedLead : state.selectedLead,
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Lead converted to customer successfully!',
            key: scaffoldMessengerKey,
          );
        });
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to convert lead',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to convert lead',
            key: scaffoldMessengerKey,
          );
        });
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to convert lead: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return false;
    }
  }

  // Add follow-up to lead
  Future<bool> addFollowUp(String id, Map<String, dynamic> followUpData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/sales/leads/$id/follow-ups',
        data: followUpData,
      );

      if (response.data['success'] == true) {
        final updatedLead = Lead.fromJson(response.data['data']);
        final updatedList = state.leads.map((lead) {
          return lead.id == id ? updatedLead : lead;
        }).toList();

        state = state.copyWith(
          leads: updatedList,
          selectedLead:
          state.selectedLead?.id == id ? updatedLead : state.selectedLead,
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Follow-up added successfully!',
            key: scaffoldMessengerKey,
          );
        });
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to add follow-up',
          isLoading: false,
        );
        _showToastSafely(() {
          ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to add follow-up',
            key: scaffoldMessengerKey,
          );
        });
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to add follow-up: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return false;
    }
  }

  // Fetch lead statistics
  Future<LeadStats?> fetchLeadStats() async {
    try {
      final response = await dio.get('/v1/nawassco/sales/leads/stats');

      if (response.data['success'] == true) {
        return LeadStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _showToastSafely(() {
        ToastUtils.showErrorToast(
          'Failed to fetch statistics: ${e.toString()}',
          key: scaffoldMessengerKey,
        );
      });
      return null;
    }
  }

  // Search leads
  Future<void> searchLeads(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/sales/leads',
        queryParameters: {
          'search': query,
          'page': 1,
          'limit': 20,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final leads = data.map((json) => Lead.fromJson(json)).toList();
        state = state.copyWith(
          leads: leads,
          isLoading: false,
          filters: {'search': query},
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Search failed',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Filter leads
  Future<void> filterLeads(Map<String, dynamic> filters) async {
    await fetchLeads(page: 1, customFilters: filters);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await fetchLeads(page: 1, customFilters: {});
  }

  // UI Navigation Methods
  void showLeadForm({Lead? lead}) {
    state = state.copyWith(
      showForm: true,
      showDetails: false,
      showStats: false,
      selectedLead: lead, // Will be null for new leads
    );
  }

  void showLeadDetails(Lead lead) {
    state = state.copyWith(
      showDetails: true,
      showForm: false,
      showStats: false,
      selectedLead: lead,
    );
  }

  void showLeadStats() {
    state = state.copyWith(
      showStats: true,
      showForm: false,
      showDetails: false,
      selectedLead: null, // Clear selected lead when showing stats
    );
  }

  void showLeadList() {
    state = state.copyWith(
      showForm: false,
      showDetails: false,
      showStats: false,
      selectedLead: null, // Clear selected lead when going back to list
    );
  }

  void selectLead(Lead? lead) {
    state = state.copyWith(selectedLead: lead);
  }

  // Toggle sales rep view
  void toggleSalesRepView() {
    state = state.copyWith(
      isSalesRepView: !state.isSalesRepView,
      showForm: false,
      showDetails: false,
      showStats: false,
      selectedLead: null,
    );
    fetchLeads();
  }
}

// Provider instances
final leadProvider = StateNotifierProvider<LeadProvider, LeadListState>((ref) {
  final dio = ref.read(dioProvider);
  return LeadProvider(dio, ref, scaffoldMessengerKey);
});

final leadStatsProvider = FutureProvider<LeadStats?>((ref) async {
  final leadNotifier = ref.read(leadProvider.notifier);
  return await leadNotifier.fetchLeadStats();
});