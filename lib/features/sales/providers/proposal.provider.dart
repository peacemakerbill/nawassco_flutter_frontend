import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../models/proposal.model.dart';

// ============================================
// PROVIDER STATE
// ============================================

class ProposalState {
  final bool isLoading;
  final List<Proposal> proposals;
  final Proposal? selectedProposal;
  final ProposalFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isSubmitting;
  final bool isApproving;
  final bool isRejecting;
  final bool isSigning;
  final String? error;
  final bool hasMore;

  const ProposalState({
    this.isLoading = false,
    this.proposals = const [],
    this.selectedProposal,
    this.filters = const ProposalFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isSubmitting = false,
    this.isApproving = false,
    this.isRejecting = false,
    this.isSigning = false,
    this.error,
    this.hasMore = true,
  });

  ProposalState copyWith({
    bool? isLoading,
    List<Proposal>? proposals,
    Proposal? selectedProposal,
    ProposalFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isSubmitting,
    bool? isApproving,
    bool? isRejecting,
    bool? isSigning,
    String? error,
    bool? hasMore,
  }) {
    return ProposalState(
      isLoading: isLoading ?? this.isLoading,
      proposals: proposals ?? this.proposals,
      selectedProposal: selectedProposal ?? this.selectedProposal,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isApproving: isApproving ?? this.isApproving,
      isRejecting: isRejecting ?? this.isRejecting,
      isSigning: isSigning ?? this.isSigning,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ============================================
// PROVIDER
// ============================================

class ProposalProvider extends StateNotifier<ProposalState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  ProposalProvider(this._dio, this._scaffoldKey)
      : super(const ProposalState()) {
    // Initial load when provider is created
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Wait a bit to ensure provider is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));
    await loadProposals(refresh: true);
  }

  // -----------------------------------------------------------------
  // CRUD OPERATIONS
  // -----------------------------------------------------------------

  Future<void> loadProposals({bool refresh = false}) async {
    // Prevent multiple concurrent loads
    if (state.isLoading && !refresh) return;

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final currentPage = refresh ? 1 : state.currentPage;
      final query = {
        'page': currentPage.toString(),
        'limit': '10',
        ...state.filters.toQueryParams(),
      };

      debugPrint('Loading proposals - Page: $currentPage');

      final response = await _dio.get(
        '/v1/nawassco/sales/proposals',
        queryParameters: query,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final data = response.data['data'] as List? ?? [];
        final pagination = response.data['pagination'] as Map<String, dynamic>? ?? {};

        debugPrint('Found ${data.length} proposals in response');

        // Parse proposals
        final List<Proposal> proposals = [];
        for (var json in data) {
          try {
            final proposal = Proposal.fromJson(json as Map<String, dynamic>);
            proposals.add(proposal);
          } catch (e) {
            debugPrint('Error parsing proposal: $e');
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
          proposals: refresh ? proposals : [...state.proposals, ...proposals],
          totalPages: totalPages,
          totalItems: totalItems,
          currentPage: nextPage,
          isLoading: false,
          hasMore: hasMore,
          error: null,
        );

        debugPrint('Successfully loaded ${proposals.length} proposals. Total in state: ${state.proposals.length}');
      } else {
        final errorMessage = response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Failed to load proposals (Status: ${response.statusCode})';
        debugPrint('API Error: $errorMessage');
        _showError(errorMessage);
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in loadProposals: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in loadProposals: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error: ${e.toString()}',
      );
      ToastUtils.showErrorToast('Failed to load proposals', key: _scaffoldKey);
    }
  }

  Future<Proposal?> loadProposal(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      debugPrint('Loading proposal details for ID: $id');

      final response = await _dio.get('/v1/nawassco/sales/proposals/$id');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final proposalData = response.data['data'] as Map<String, dynamic>?;
        if (proposalData != null) {
          final proposal = Proposal.fromJson(proposalData);
          state = state.copyWith(
            selectedProposal: proposal,
            isLoading: false,
            error: null,
          );
          debugPrint('Loaded proposal: ${proposal.proposalNumber}');
          return proposal;
        } else {
          _showError('Proposal data is null');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to load proposal');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Proposal?> createProposal(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      debugPrint('Creating proposal with data: ${data.keys.toList()}');

      final response = await _dio.post(
        '/v1/nawassco/sales/proposals',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 201 && response.data != null && response.data['success'] == true) {
        final proposalData = response.data['data'] as Map<String, dynamic>?;
        if (proposalData != null) {
          final proposal = Proposal.fromJson(proposalData);

          state = state.copyWith(
            proposals: [proposal, ...state.proposals],
            selectedProposal: proposal,
            isCreating: false,
            error: null,
          );

          _showSuccess('Proposal created successfully');
          debugPrint('Created proposal: ${proposal.proposalNumber}');
          return proposal;
        } else {
          _showError('Created proposal data is null');
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
          _showError(response.data?['message']?.toString() ?? 'Failed to create proposal');
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

  Future<Proposal?> updateProposal(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      debugPrint('Updating proposal $id with data: ${data.keys.toList()}');

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: updatedProposal,
            isUpdating: false,
            error: null,
          );

          _showSuccess('Proposal updated successfully');
          debugPrint('Updated proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update proposal');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> deleteProposal(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      debugPrint('Deleting proposal: $id');

      final response = await _dio.delete('/v1/nawassco/sales/proposals/$id');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        // Remove from local state
        final updatedProposals = state.proposals
            .where((proposal) => proposal.id != id)
            .toList();

        state = state.copyWith(
          proposals: updatedProposals,
          selectedProposal: state.selectedProposal?.id == id ? null : state.selectedProposal,
          isDeleting: false,
          error: null,
        );

        _showSuccess('Proposal deleted successfully');
        debugPrint('Deleted proposal: $id');
        return true;
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to delete proposal');
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
  // WORKFLOW ACTIONS
  // -----------------------------------------------------------------

  Future<Proposal?> submitForReview(String id, {String? reviewedBy}) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      debugPrint('Submitting proposal $id for review');

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id/submit-review',
        data: reviewedBy != null ? {'reviewedBy': reviewedBy} : {},
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: updatedProposal,
            isSubmitting: false,
            error: null,
          );

          _showSuccess('Proposal submitted for review');
          debugPrint('Submitted proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after submission');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to submit proposal for review');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<Proposal?> approveProposal(String id, String approvedBy, {String? comments}) async {
    try {
      state = state.copyWith(isApproving: true, error: null);

      debugPrint('Approving proposal $id');

      final data = {
        'approvedBy': approvedBy,
        if (comments != null) 'comments': comments,
      };

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id/approve',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: updatedProposal,
            isApproving: false,
            error: null,
          );

          _showSuccess('Proposal approved successfully');
          debugPrint('Approved proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after approval');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to approve proposal');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isApproving: false);
    }
  }

  Future<Proposal?> rejectProposal(String id, String rejectedBy, String reason) async {
    try {
      state = state.copyWith(isRejecting: true, error: null);

      debugPrint('Rejecting proposal $id');

      final data = {
        'rejectedBy': rejectedBy,
        'reason': reason,
      };

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id/reject',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: updatedProposal,
            isRejecting: false,
            error: null,
          );

          _showSuccess('Proposal rejected');
          debugPrint('Rejected proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after rejection');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to reject proposal');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isRejecting: false);
    }
  }

  Future<Proposal?> signProposal(
      String id,
      String signedByCustomer,
      String signedByCompany,
      DateTime contractStartDate,
      DateTime contractEndDate,
      ) async {
    try {
      state = state.copyWith(isSigning: true, error: null);

      debugPrint('Signing proposal $id');

      final data = {
        'signedByCustomer': signedByCustomer,
        'signedByCompany': signedByCompany,
        'contractStartDate': contractStartDate.toIso8601String(),
        'contractEndDate': contractEndDate.toIso8601String(),
      };

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id/sign',
        data: data,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: updatedProposal,
            isSigning: false,
            error: null,
          );

          _showSuccess('Proposal signed successfully');
          debugPrint('Signed proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after signing');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to sign proposal');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isSigning: false);
    }
  }

  Future<Proposal?> addPaymentMilestone(String id, Map<String, dynamic> milestoneData) async {
    try {
      debugPrint('Adding payment milestone to proposal: $id');

      final response = await _dio.post(
        '/v1/nawassco/sales/proposals/$id/milestones',
        data: milestoneData,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: state.selectedProposal?.id == id ? updatedProposal : state.selectedProposal,
          );

          _showSuccess('Payment milestone added successfully');
          debugPrint('Added milestone to proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after adding milestone');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to add payment milestone');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Proposal?> updateMilestoneStatus(
      String id,
      int milestoneNumber,
      MilestoneStatus status,
      ) async {
    try {
      debugPrint('Updating milestone status for proposal: $id, milestone: $milestoneNumber');

      final response = await _dio.put(
        '/v1/nawassco/sales/proposals/$id/milestones/$milestoneNumber',
        data: {'status': status.name},
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final updatedProposalData = response.data['data'] as Map<String, dynamic>?;
        if (updatedProposalData != null) {
          final updatedProposal = Proposal.fromJson(updatedProposalData);

          final updatedProposals = state.proposals.map((proposal) {
            return proposal.id == id ? updatedProposal : proposal;
          }).toList();

          state = state.copyWith(
            proposals: updatedProposals,
            selectedProposal: state.selectedProposal?.id == id ? updatedProposal : state.selectedProposal,
          );

          _showSuccess('Milestone status updated successfully');
          debugPrint('Updated milestone status for proposal: ${updatedProposal.proposalNumber}');
          return updatedProposal;
        } else {
          _showError('Updated proposal data is null after updating milestone');
          return null;
        }
      } else {
        _showError(response.data?['message']?.toString() ?? 'Failed to update milestone status');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // -----------------------------------------------------------------
  // STATE MANAGEMENT
  // -----------------------------------------------------------------

  void selectProposal(Proposal? proposal) {
    state = state.copyWith(selectedProposal: proposal);
  }

  void updateFilters(ProposalFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      proposals: [],
      hasMore: true,
    );
    loadProposals(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const ProposalFilters(),
      currentPage: 1,
      proposals: [],
      hasMore: true,
    );
    loadProposals(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading && state.hasMore) {
      debugPrint('Loading next page: ${state.currentPage + 1}');
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadProposals();
    }
  }

  void refreshData() {
    debugPrint('Refreshing proposal data');
    state = state.copyWith(
      currentPage: 1,
      proposals: [],
      hasMore: true,
    );
    loadProposals(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    debugPrint('Resetting proposal provider state');
    state = const ProposalState();
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
        errorMessage = 'Proposal already exists with this number.';
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

    debugPrint('ProposalProvider Error: $errorMessage');

    state = state.copyWith(
      error: errorMessage,
      isLoading: false,
      isCreating: false,
      isUpdating: false,
      isDeleting: false,
      isSubmitting: false,
      isApproving: false,
      isRejecting: false,
      isSigning: false,
    );

    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================

final proposalProvider = StateNotifierProvider<ProposalProvider, ProposalState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return ProposalProvider(dio, scaffoldMessengerKey);
  },
);