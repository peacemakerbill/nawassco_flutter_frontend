import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/inventory/inventory_item_model.dart';

class InventoryItemState {
  final List<InventoryItem> items;
  final InventoryItem? selectedItem;
  final bool isLoading;
  final String? error;
  final List<InventoryItem> lowStockItems;
  final List<Map<String, dynamic>> inventoryValuation;
  final Map<String, dynamic> filters;

  InventoryItemState({
    this.items = const [],
    this.selectedItem,
    this.isLoading = false,
    this.error,
    this.lowStockItems = const [],
    this.inventoryValuation = const [],
    this.filters = const {},
  });

  InventoryItemState copyWith({
    List<InventoryItem>? items,
    InventoryItem? selectedItem,
    bool? isLoading,
    String? error,
    List<InventoryItem>? lowStockItems,
    List<Map<String, dynamic>>? inventoryValuation,
    Map<String, dynamic>? filters,
  }) {
    return InventoryItemState(
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      inventoryValuation: inventoryValuation ?? this.inventoryValuation,
      filters: filters ?? this.filters,
    );
  }
}

class InventoryItemProvider extends StateNotifier<InventoryItemState> {
  final Ref ref;
  final Dio dio;

  InventoryItemProvider(this.ref, this.dio) : super(InventoryItemState());

  // Create inventory item
  Future<void> createInventoryItem(InventoryItem item) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/api/inventory',
        data: item.toJson(),
      );

      if (response.data['success'] == true) {
        final newItem = InventoryItem.fromJson(response.data['data']);
        state = state.copyWith(
          items: [...state.items, newItem],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create inventory item');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Get all inventory items with filters
  Future<void> getInventoryItems({
    int page = 1,
    int limit = 50,
    String? search,
    String? category,
    String? itemType,
    String? status,
    String? movementClass,
    String? warehouse,
    bool? lowStock,
    bool? outOfStock,
    String sortBy = 'itemName',
    String sortOrder = 'asc',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (itemType != null && itemType.isNotEmpty) queryParams['itemType'] = itemType;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (movementClass != null && movementClass.isNotEmpty) queryParams['movementClass'] = movementClass;
      if (warehouse != null && warehouse.isNotEmpty) queryParams['warehouse'] = warehouse;
      if (lowStock != null) queryParams['lowStock'] = lowStock;
      if (outOfStock != null) queryParams['outOfStock'] = outOfStock;

      final response = await dio.get(
        '/api/inventory',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final items = List<InventoryItem>.from(
          (response.data['data'] as List).map((x) => InventoryItem.fromJson(x)),
        );

        state = state.copyWith(
          items: items,
          isLoading: false,
          filters: queryParams,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch inventory items');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get inventory item by ID
  Future<void> getInventoryItemById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/api/inventory/$id');

      if (response.data['success'] == true) {
        final item = InventoryItem.fromJson(response.data['data']);
        state = state.copyWith(
          selectedItem: item,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch inventory item');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get inventory item by code
  Future<void> getInventoryItemByCode(String itemCode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/api/inventory/code/$itemCode');

      if (response.data['success'] == true) {
        final item = InventoryItem.fromJson(response.data['data']);
        state = state.copyWith(
          selectedItem: item,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch inventory item');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Update inventory item
  Future<void> updateInventoryItem(String id, InventoryItem item) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/api/inventory/$id',
        data: item.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedItem = InventoryItem.fromJson(response.data['data']);
        final updatedItems = state.items.map((existingItem) =>
        existingItem.id == id ? updatedItem : existingItem).toList();

        state = state.copyWith(
          items: updatedItems,
          selectedItem: updatedItem,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update inventory item');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Delete inventory item
  Future<void> deleteInventoryItem(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/api/inventory/$id');

      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
        selectedItem: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Bulk update inventory items
  Future<void> bulkUpdateInventory(List<String> itemIds, Map<String, dynamic> updates) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/api/inventory/bulk-update',
        data: {
          'itemIds': itemIds,
          'updates': updates,
        },
      );

      if (response.data['success'] == true) {
        // Refresh the items list
        await getInventoryItems();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to bulk update inventory');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Get inventory valuation
  Future<void> getInventoryValuation({String? warehouse}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> queryParams = {};
      if (warehouse != null && warehouse.isNotEmpty) {
        queryParams['warehouse'] = warehouse;
      }

      final response = await dio.get(
        '/api/inventory/valuation',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final valuation = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        state = state.copyWith(
          inventoryValuation: valuation,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch inventory valuation');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get low stock items
  Future<void> getLowStockItems({String? warehouse}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> queryParams = {};
      if (warehouse != null && warehouse.isNotEmpty) {
        queryParams['warehouse'] = warehouse;
      }

      final response = await dio.get(
        '/api/inventory/low-stock',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final lowStockItems = List<InventoryItem>.from(
          (response.data['data'] as List).map((x) => InventoryItem.fromJson(x)),
        );
        state = state.copyWith(
          lowStockItems: lowStockItems,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch low stock items');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected item
  void clearSelectedItem() {
    state = state.copyWith(selectedItem: null);
  }

  // Apply filters
  void applyFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(filters: {});
    getInventoryItems();
  }
}

// Provider
final inventoryItemProvider = StateNotifierProvider<InventoryItemProvider, InventoryItemState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return InventoryItemProvider(ref, dio);
  },
);