import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../domain/models/tender_model.dart';

class TenderState {
  final List<Tender> tenders;
  final Tender? selectedTender;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final List<Tender> activeTenders;
  final List<Tender> closingSoonTenders;
  final Map<String, dynamic>? stats;

  TenderState({
    this.tenders = const [],
    this.selectedTender,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.activeTenders = const [],
    this.closingSoonTenders = const [],
    this.stats,
  });

  TenderState copyWith({
    List<Tender>? tenders,
    Tender? selectedTender,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    List<Tender>? activeTenders,
    List<Tender>? closingSoonTenders,
    Map<String, dynamic>? stats,
  }) {
    return TenderState(
      tenders: tenders ?? this.tenders,
      selectedTender: selectedTender ?? this.selectedTender,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      activeTenders: activeTenders ?? this.activeTenders,
      closingSoonTenders: closingSoonTenders ?? this.closingSoonTenders,
      stats: stats ?? this.stats,
    );
  }
}

class TenderProvider extends StateNotifier<TenderState> {
  final Ref ref;
  final Dio dio;

  TenderProvider(this.ref, this.dio) : super(TenderState());

  // Get all tenders with filtering
  Future<void> getTenders({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/tenders', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<Tender> tenders = (response.data['data'] as List)
            .map((json) => Tender.fromJson(json))
            .toList();

        state = state.copyWith(
          tenders: tenders,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tenders');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get single tender by ID
  Future<void> getTenderById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/tenders/$id');

      if (response.data['success'] == true) {
        final Tender tender = Tender.fromJson(response.data['data']);

        state = state.copyWith(
          selectedTender: tender,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tender');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Create new tender
  Future<bool> createTender(Map<String, dynamic> tenderData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tenders',
        data: tenderData,
      );

      if (response.data['success'] == true) {
        final Tender newTender = Tender.fromJson(response.data['data']);

        state = state.copyWith(
          tenders: [newTender, ...state.tenders],
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Tender created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create tender');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Update tender
  Future<bool> updateTender(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/procurement/tenders/$id',
        data: updateData,
      );

      if (response.data['success'] == true) {
        final Tender updatedTender = Tender.fromJson(response.data['data']);

        // Update in tenders list
        final updatedTenders = state.tenders.map((tender) =>
        tender.id == id ? updatedTender : tender
        ).toList();

        state = state.copyWith(
          tenders: updatedTenders,
          selectedTender: state.selectedTender?.id == id ? updatedTender : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Tender updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update tender');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Process tender action (submit, approve, publish, etc.)
  Future<bool> processTenderAction(
      String id,
      String action, {
        String? comments,
        String? awardedTo,
        double? awardedAmount,
      }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> data = {'action': action};
      if (comments != null) data['comments'] = comments;
      if (awardedTo != null) data['awardedTo'] = awardedTo;
      if (awardedAmount != null) data['awardedAmount'] = awardedAmount;

      final response = await dio.post(
        '/v1/nawassco/procurement/tenders/$id/action',
        data: data,
      );

      if (response.data['success'] == true) {
        final Tender updatedTender = Tender.fromJson(response.data['data']);

        // Update in tenders list
        final updatedTenders = state.tenders.map((tender) =>
        tender.id == id ? updatedTender : tender
        ).toList();

        state = state.copyWith(
          tenders: updatedTenders,
          selectedTender: state.selectedTender?.id == id ? updatedTender : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(response.data['message'] ?? 'Action completed successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process action');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Add amendment to tender
  Future<bool> addAmendment(String id, Map<String, dynamic> amendmentData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tenders/$id/amendments',
        data: amendmentData,
      );

      if (response.data['success'] == true) {
        final Tender updatedTender = Tender.fromJson(response.data['data']);

        state = state.copyWith(
          selectedTender: state.selectedTender?.id == id ? updatedTender : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Amendment added successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add amendment');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Add clarification question
  Future<bool> addClarification(String id, Map<String, dynamic> clarificationData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tenders/$id/clarifications',
        data: clarificationData,
      );

      if (response.data['success'] == true) {
        final Tender updatedTender = Tender.fromJson(response.data['data']);

        state = state.copyWith(
          selectedTender: state.selectedTender?.id == id ? updatedTender : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Clarification submitted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit clarification');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Answer clarification
  Future<bool> answerClarification(
      String tenderId,
      int clarificationIndex,
      String answer,
      ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/tenders/$tenderId/clarifications/$clarificationIndex/answer',
        data: {'answer': answer},
      );

      if (response.data['success'] == true) {
        final Tender updatedTender = Tender.fromJson(response.data['data']);

        state = state.copyWith(
          selectedTender: state.selectedTender?.id == tenderId ? updatedTender : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Clarification answered successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to answer clarification');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Get active tenders (public)
  Future<void> getActiveTenders({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tenders/active',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<Tender> activeTenders = (response.data['data'] as List)
            .map((json) => Tender.fromJson(json))
            .toList();

        state = state.copyWith(
          activeTenders: activeTenders,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch active tenders');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get closing soon tenders
  Future<void> getClosingSoonTenders({int days = 7, int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tenders/closing-soon',
        queryParameters: {'days': days, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<Tender> closingSoonTenders = (response.data['data'] as List)
            .map((json) => Tender.fromJson(json))
            .toList();

        state = state.copyWith(
          closingSoonTenders: closingSoonTenders,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch closing soon tenders');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get tender statistics
  Future<void> getTenderStats({String timeframe = 'month'}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/procurement/tenders/stats',
        queryParameters: {'timeframe': timeframe},
      );

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tender statistics');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get applications count for a tender
  Future<int> getApplicationsCount(String tenderId) async {
    try {
      final response = await dio.get('/v1/nawassco/procurement/tenders/$tenderId/applications-count');

      if (response.data['success'] == true) {
        return response.data['data']['applicationsCount'] ?? 0;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch applications count');
      }
    } catch (e) {
      _showError(e);
      return 0;
    }
  }

  // Delete tender
  Future<bool> deleteTender(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/procurement/tenders/$id');

      if (response.data['success'] == true) {
        // Remove from tenders list
        final updatedTenders = state.tenders.where((tender) => tender.id != id).toList();

        state = state.copyWith(
          tenders: updatedTenders,
          selectedTender: state.selectedTender?.id == id ? null : state.selectedTender,
          isLoading: false,
        );

        ToastUtils.showSuccessToast('Tender deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete tender');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Clear selected tender
  void clearSelectedTender() {
    state = state.copyWith(selectedTender: null);
  }

  // Update filters
  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper method to show errors
  void _showError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data is Map) {
        errorMessage = response.data['message'] ?? error.message ?? errorMessage;
      } else {
        errorMessage = error.message ?? errorMessage;
      }
    } else if (error is String) {
      errorMessage = error;
    }

    ToastUtils.showErrorToast(errorMessage);
  }
}

// Provider
final tenderProvider = StateNotifierProvider<TenderProvider, TenderState>((ref) {
  final dio = ref.read(dioProvider);
  return TenderProvider(ref, dio);
});