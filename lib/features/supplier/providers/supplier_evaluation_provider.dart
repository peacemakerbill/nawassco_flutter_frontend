import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/supplier_evaluation_model.dart';

class SupplierEvaluationState {
  final List<SupplierEvaluation> evaluations;
  final SupplierEvaluation? selectedEvaluation;
  final bool isLoading;
  final String? error;

  SupplierEvaluationState({
    this.evaluations = const [],
    this.selectedEvaluation,
    this.isLoading = false,
    this.error,
  });

  SupplierEvaluationState copyWith({
    List<SupplierEvaluation>? evaluations,
    SupplierEvaluation? selectedEvaluation,
    bool? isLoading,
    String? error,
  }) {
    return SupplierEvaluationState(
      evaluations: evaluations ?? this.evaluations,
      selectedEvaluation: selectedEvaluation ?? this.selectedEvaluation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SupplierEvaluationProvider extends StateNotifier<SupplierEvaluationState> {
  final Dio dio;

  SupplierEvaluationProvider(this.dio) : super(SupplierEvaluationState());

  // Get all evaluations
  Future<void> getAllEvaluations({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/evaluations', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierEvaluation> evaluations = (response.data['data'] as List)
            .map((item) => SupplierEvaluation.fromJson(item))
            .toList();

        state = state.copyWith(
          evaluations: evaluations,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch evaluations',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch evaluations: $e',
        isLoading: false,
      );
    }
  }

  // Get evaluation by ID
  Future<void> getEvaluationById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/evaluations/$id');

      if (response.data['success'] == true) {
        final SupplierEvaluation evaluation = SupplierEvaluation.fromJson(response.data['data']);

        state = state.copyWith(
          selectedEvaluation: evaluation,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch evaluation',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch evaluation: $e',
        isLoading: false,
      );
    }
  }

  // Create evaluation
  Future<bool> createEvaluation(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/evaluations', data: data);

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update evaluation
  Future<bool> updateEvaluation(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/supplier/evaluations/$id', data: data);

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete evaluation
  Future<bool> deleteEvaluation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/supplier/evaluations/$id');

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Submit evaluation for review
  Future<bool> submitEvaluation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/evaluations/$id/submit');

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to submit evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to submit evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Approve evaluation
  Future<bool> approveEvaluation(String id, {String? comments}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/evaluations/$id/approve', data: {
        if (comments != null) 'comments': comments,
      });

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to approve evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to approve evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Reject evaluation
  Future<bool> rejectEvaluation(String id, {String? comments}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/evaluations/$id/reject', data: {
        if (comments != null) 'comments': comments,
      });

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to reject evaluation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reject evaluation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Get evaluations by supplier
  Future<void> getEvaluationsBySupplier(String supplierId, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/evaluations/supplier/$supplierId', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierEvaluation> evaluations = (response.data['data'] as List)
            .map((item) => SupplierEvaluation.fromJson(item))
            .toList();

        state = state.copyWith(
          evaluations: evaluations,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch evaluations by supplier',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch evaluations by supplier: $e',
        isLoading: false,
      );
    }
  }

  // Update follow-up action
  Future<bool> updateFollowUpAction(String evaluationId, String actionId, String status, {String? comments}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/supplier/evaluations/$evaluationId/actions/$actionId', data: {
        'status': status,
        if (comments != null) 'comments': comments,
      });

      if (response.data['success'] == true) {
        await getAllEvaluations();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update follow-up action',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update follow-up action: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected evaluation
  void clearSelectedEvaluation() {
    state = state.copyWith(selectedEvaluation: null);
  }
}

final supplierEvaluationProvider = StateNotifierProvider<SupplierEvaluationProvider, SupplierEvaluationState>((ref) {
  final dio = ref.read(dioProvider);
  return SupplierEvaluationProvider(dio);
});