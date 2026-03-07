import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/stock/stock_movement_model.dart';

class StockMovementState {
  final List<StockMovement> movements;
  final bool isLoading;
  final String? error;
  final StockMovement? selectedMovement;
  final Map<String, dynamic>? movementSummary;

  StockMovementState({
    this.movements = const [],
    this.isLoading = false,
    this.error,
    this.selectedMovement,
    this.movementSummary,
  });

  StockMovementState copyWith({
    List<StockMovement>? movements,
    bool? isLoading,
    String? error,
    StockMovement? selectedMovement,
    Map<String, dynamic>? movementSummary,
  }) {
    return StockMovementState(
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedMovement: selectedMovement ?? this.selectedMovement,
      movementSummary: movementSummary ?? this.movementSummary,
    );
  }
}

class StockMovementProvider extends StateNotifier<StockMovementState> {
  final Ref ref;

  StockMovementProvider(this.ref) : super(StockMovementState());

  Future<void> getStockMovements({
    int? page,
    int? limit,
    String? search,
    String? movementType,
    String? status,
    String? referenceType,
    String? referenceNumber,
    DateTime? fromDate,
    DateTime? toDate,
    String? warehouse,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final Map<String, dynamic> queryParams = {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (search != null) 'search': search,
        if (movementType != null) 'movementType': movementType,
        if (status != null) 'status': status,
        if (referenceType != null) 'referenceType': referenceType,
        if (referenceNumber != null) 'referenceNumber': referenceNumber,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
        if (warehouse != null) 'warehouse': warehouse,
      };

      final response = await dio.get('/v1/nawassco/stores/stock-movements', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<StockMovement> movements = (response.data['data']['movements'] as List)
            .map((json) => StockMovement.fromJson(json))
            .toList();

        state = state.copyWith(movements: movements, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStockMovementById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.get('/v1/nawassco/stores/stock-movements/$id');

      if (response.data['success'] == true) {
        final StockMovement movement = StockMovement.fromJson(response.data['data']);
        state = state.copyWith(selectedMovement: movement, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createStockMovement(Map<String, dynamic> data, String initiatedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.post('/v1/nawassco/stores/stock-movements', data: {
        ...data,
        'initiatedBy': initiatedBy,
      });

      if (response.data['success'] == true) {
        final StockMovement newMovement = StockMovement.fromJson(response.data['data']);

        state = state.copyWith(
          movements: [...state.movements, newMovement],
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateStockMovement(String id, Map<String, dynamic> data, String updatedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-movements/$id', data: data);

      if (response.data['success'] == true) {
        final StockMovement updatedMovement = StockMovement.fromJson(response.data['data']);

        // Update in the list
        final List<StockMovement> updatedMovements = state.movements.map((movement) {
          return movement.id == id ? updatedMovement : movement;
        }).toList();

        state = state.copyWith(
          movements: updatedMovements,
          selectedMovement: updatedMovement,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> approveStockMovement(String id, String approvedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-movements/$id/approve');

      if (response.data['success'] == true) {
        final StockMovement updatedMovement = StockMovement.fromJson(response.data['data']);

        // Update in the list
        final List<StockMovement> updatedMovements = state.movements.map((movement) {
          return movement.id == id ? updatedMovement : movement;
        }).toList();

        state = state.copyWith(
          movements: updatedMovements,
          selectedMovement: updatedMovement,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> completeStockMovement(String id, String receivedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-movements/$id/complete');

      if (response.data['success'] == true) {
        final StockMovement updatedMovement = StockMovement.fromJson(response.data['data']);

        // Update in the list
        final List<StockMovement> updatedMovements = state.movements.map((movement) {
          return movement.id == id ? updatedMovement : movement;
        }).toList();

        state = state.copyWith(
          movements: updatedMovements,
          selectedMovement: updatedMovement,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getMovementSummary({String? warehouse, DateTime? fromDate, DateTime? toDate}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final Map<String, dynamic> queryParams = {
        if (warehouse != null) 'warehouse': warehouse,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await dio.get('/v1/nawassco/stores/stock-movements/summary', queryParameters: queryParams);

      if (response.data['success'] == true) {
        state = state.copyWith(
          movementSummary: response.data['data'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelection() {
    state = state.copyWith(selectedMovement: null);
  }
}

final stockMovementProvider = StateNotifierProvider<StockMovementProvider, StockMovementState>((ref) {
  return StockMovementProvider(ref);
});