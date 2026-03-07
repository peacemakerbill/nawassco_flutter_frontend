import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../models/stock/stock_take_model.dart';

class StockTakeState {
  final List<StockTake> stockTakes;
  final bool isLoading;
  final String? error;
  final StockTake? selectedStockTake;
  final Map<String, dynamic>? performance;

  StockTakeState({
    this.stockTakes = const [],
    this.isLoading = false,
    this.error,
    this.selectedStockTake,
    this.performance,
  });

  StockTakeState copyWith({
    List<StockTake>? stockTakes,
    bool? isLoading,
    String? error,
    StockTake? selectedStockTake,
    Map<String, dynamic>? performance,
  }) {
    return StockTakeState(
      stockTakes: stockTakes ?? this.stockTakes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedStockTake: selectedStockTake ?? this.selectedStockTake,
      performance: performance ?? this.performance,
    );
  }
}

class StockTakeProvider extends StateNotifier<StockTakeState> {
  final Ref ref;

  StockTakeProvider(this.ref) : super(StockTakeState());

  Future<void> getStockTakes({
    int? page,
    int? limit,
    String? search,
    String? stockTakeType,
    String? status,
    String? warehouse,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final Map<String, dynamic> queryParams = {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (search != null) 'search': search,
        if (stockTakeType != null) 'stockTakeType': stockTakeType,
        if (status != null) 'status': status,
        if (warehouse != null) 'warehouse': warehouse,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await dio.get('/v1/nawassco/stores/stock-takes', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<StockTake> stockTakes = (response.data['data']['stockTakes'] as List)
            .map((json) => StockTake.fromJson(json))
            .toList();

        state = state.copyWith(stockTakes: stockTakes, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStockTakeById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.get('/v1/nawassco/stores/stock-takes/$id');

      if (response.data['success'] == true) {
        final StockTake stockTake = StockTake.fromJson(response.data['data']);
        state = state.copyWith(selectedStockTake: stockTake, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createStockTake(Map<String, dynamic> data, String createdBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.post('/v1/nawassco/stores/stock-takes', data: {
        ...data,
        'supervisor': createdBy,
      });

      if (response.data['success'] == true) {
        final StockTake newStockTake = StockTake.fromJson(response.data['data']);

        state = state.copyWith(
          stockTakes: [...state.stockTakes, newStockTake],
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> startStockTake(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-takes/$id/start');

      if (response.data['success'] == true) {
        final StockTake updatedStockTake = StockTake.fromJson(response.data['data']);

        // Update in the list
        final List<StockTake> updatedStockTakes = state.stockTakes.map((stockTake) {
          return stockTake.id == id ? updatedStockTake : stockTake;
        }).toList();

        state = state.copyWith(
          stockTakes: updatedStockTakes,
          selectedStockTake: updatedStockTake,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addCountedItem(String stockTakeId, Map<String, dynamic> countedItem, String countedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.post('/v1/nawassco/stores/stock-takes/$stockTakeId/count', data: {
        ...countedItem,
        'countedBy': countedBy,
      });

      if (response.data['success'] == true) {
        final StockTake updatedStockTake = StockTake.fromJson(response.data['data']);

        // Update in the list
        final List<StockTake> updatedStockTakes = state.stockTakes.map((stockTake) {
          return stockTake.id == stockTakeId ? updatedStockTake : stockTake;
        }).toList();

        state = state.copyWith(
          stockTakes: updatedStockTakes,
          selectedStockTake: updatedStockTake,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> completeCounting(String stockTakeId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-takes/$stockTakeId/complete');

      if (response.data['success'] == true) {
        final StockTake updatedStockTake = StockTake.fromJson(response.data['data']);

        // Update in the list
        final List<StockTake> updatedStockTakes = state.stockTakes.map((stockTake) {
          return stockTake.id == stockTakeId ? updatedStockTake : stockTake;
        }).toList();

        state = state.copyWith(
          stockTakes: updatedStockTakes,
          selectedStockTake: updatedStockTake,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addAdjustment(String stockTakeId, Map<String, dynamic> adjustment, String approvedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.post('/v1/nawassco/stores/stock-takes/$stockTakeId/adjust', data: {
        ...adjustment,
        'approvedBy': approvedBy,
      });

      if (response.data['success'] == true) {
        final StockTake updatedStockTake = StockTake.fromJson(response.data['data']);

        // Update in the list
        final List<StockTake> updatedStockTakes = state.stockTakes.map((stockTake) {
          return stockTake.id == stockTakeId ? updatedStockTake : stockTake;
        }).toList();

        state = state.copyWith(
          stockTakes: updatedStockTakes,
          selectedStockTake: updatedStockTake,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> approveStockTake(String stockTakeId, String approvedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-takes/$stockTakeId/approve');

      if (response.data['success'] == true) {
        final StockTake updatedStockTake = StockTake.fromJson(response.data['data']);

        // Update in the list
        final List<StockTake> updatedStockTakes = state.stockTakes.map((stockTake) {
          return stockTake.id == stockTakeId ? updatedStockTake : stockTake;
        }).toList();

        state = state.copyWith(
          stockTakes: updatedStockTakes,
          selectedStockTake: updatedStockTake,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStockTakePerformance({String? warehouse, String? period}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final Map<String, dynamic> queryParams = {
        if (warehouse != null) 'warehouse': warehouse,
        if (period != null) 'period': period,
      };

      final response = await dio.get('/v1/nawassco/stores/stock-takes/performance', queryParameters: queryParams);

      if (response.data['success'] == true) {
        state = state.copyWith(
          performance: response.data['data'],
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
    state = state.copyWith(selectedStockTake: null);
  }
}

final stockTakeProvider = StateNotifierProvider<StockTakeProvider, StockTakeState>((ref) {
  return StockTakeProvider(ref);
});