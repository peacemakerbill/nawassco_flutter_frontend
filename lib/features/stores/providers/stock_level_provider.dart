import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../models/stock/stock_level_model.dart';

class StockLevelState {
  final List<StockLevel> stockLevels;
  final bool isLoading;
  final String? error;
  final StockLevel? selectedStockLevel;

  StockLevelState({
    this.stockLevels = const [],
    this.isLoading = false,
    this.error,
    this.selectedStockLevel,
  });

  StockLevelState copyWith({
    List<StockLevel>? stockLevels,
    bool? isLoading,
    String? error,
    StockLevel? selectedStockLevel,
  }) {
    return StockLevelState(
      stockLevels: stockLevels ?? this.stockLevels,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedStockLevel: selectedStockLevel ?? this.selectedStockLevel,
    );
  }
}

class StockLevelProvider extends StateNotifier<StockLevelState> {
  final Ref ref;

  StockLevelProvider(this.ref) : super(StockLevelState());

  Future<void> getStockLevels({String? warehouse, String? item, String? search}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.get('/v1/nawassco/stores/stock-levels', queryParameters: {
        if (warehouse != null) 'warehouse': warehouse,
        if (item != null) 'item': item,
        if (search != null) 'search': search,
      });

      if (response.data['success'] == true) {
        final List<StockLevel> stockLevels = (response.data['data'] as List)
            .map((json) => StockLevel.fromJson(json))
            .toList();

        state = state.copyWith(stockLevels: stockLevels, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStockLevelById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.get('/v1/nawassco/stores/stock-levels/$id');

      if (response.data['success'] == true) {
        final StockLevel stockLevel = StockLevel.fromJson(response.data['data']);
        state = state.copyWith(selectedStockLevel: stockLevel, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateStockLevel(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-levels/$id', data: data);

      if (response.data['success'] == true) {
        final StockLevel updatedStockLevel = StockLevel.fromJson(response.data['data']);

        // Update in the list
        final List<StockLevel> updatedLevels = state.stockLevels.map((level) {
          return level.id == id ? updatedStockLevel : level;
        }).toList();

        state = state.copyWith(
          stockLevels: updatedLevels,
          selectedStockLevel: updatedStockLevel,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createStockLevel(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.post('/v1/nawassco/stores/stock-levels', data: data);

      if (response.data['success'] == true) {
        final StockLevel newStockLevel = StockLevel.fromJson(response.data['data']);

        state = state.copyWith(
          stockLevels: [...state.stockLevels, newStockLevel],
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
    state = state.copyWith(selectedStockLevel: null);
  }
}

final stockLevelProvider = StateNotifierProvider<StockLevelProvider, StockLevelState>((ref) {
  return StockLevelProvider(ref);
});