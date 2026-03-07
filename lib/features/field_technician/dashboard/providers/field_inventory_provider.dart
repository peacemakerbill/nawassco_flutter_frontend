import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../main.dart';
import '../models/field_inventory.dart';

class FieldInventoryState {
  final List<FieldInventory> inventoryItems;
  final List<FieldInventory> filteredItems;
  final FieldInventory? selectedItem;
  final FieldInventoryMetrics? metrics;
  final bool isLoading;
  final String searchQuery;
  final String? categoryFilter;
  final String? statusFilter;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? error;
  final List<FieldInventory> lowStockItems;

  FieldInventoryState({
    this.inventoryItems = const [],
    this.filteredItems = const [],
    this.selectedItem,
    this.metrics,
    this.isLoading = false,
    this.searchQuery = '',
    this.categoryFilter,
    this.statusFilter,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.error,
    this.lowStockItems = const [],
  });

  FieldInventoryState copyWith({
    List<FieldInventory>? inventoryItems,
    List<FieldInventory>? filteredItems,
    FieldInventory? selectedItem,
    FieldInventoryMetrics? metrics,
    bool? isLoading,
    String? searchQuery,
    String? categoryFilter,
    String? statusFilter,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? error,
    List<FieldInventory>? lowStockItems,
  }) {
    return FieldInventoryState(
      inventoryItems: inventoryItems ?? this.inventoryItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedItem: selectedItem ?? this.selectedItem,
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      error: error ?? this.error,
      lowStockItems: lowStockItems ?? this.lowStockItems,
    );
  }
}

class FieldInventoryProvider extends StateNotifier<FieldInventoryState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  FieldInventoryProvider(this.dio, this.scaffoldMessengerKey)
      : super(FieldInventoryState());

  // Fetch all inventory items
  Future<void> fetchInventoryItems({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        state = state.copyWith(isLoading: true);
      }

      final response = await dio.get('/v1/nawassco/field_technician/field-inventory', queryParameters: {
        'page': page,
        'limit': limit,
        if (state.categoryFilter != null) 'category': state.categoryFilter,
        if (state.statusFilter != null) 'status': state.statusFilter,
      });

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final List<FieldInventory> items = List<FieldInventory>.from(
            data['inventory'].map((x) => FieldInventory.fromJson(x)));

        final filtered = _applyFilters(items, state.searchQuery);

        state = state.copyWith(
          inventoryItems:
              loadMore ? [...state.inventoryItems, ...items] : items,
          filteredItems: filtered,
          currentPage: page,
          totalPages: data['pagination']['totalPages'],
          totalItems: data['pagination']['totalItems'],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _handleError(e);
    }
  }

  // Search inventory
  void searchInventory(String query) {
    final filtered = _applyFilters(state.inventoryItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: filtered,
    );
  }

  // Filter by category
  void filterByCategory(String? category) {
    final filtered =
        _applyFilters(state.inventoryItems, state.searchQuery, category);
    state = state.copyWith(
      categoryFilter: category,
      filteredItems: filtered,
    );
  }

  // Filter by status
  void filterByStatus(String? status) {
    final filtered = _applyFilters(
        state.inventoryItems, state.searchQuery, state.categoryFilter, status);
    state = state.copyWith(
      statusFilter: status,
      filteredItems: filtered,
    );
  }

  // Get inventory item by ID
  Future<FieldInventory?> getInventoryItemById(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.get('/v1/nawassco/field_technician/field-inventory/$id');

      if (response.data['success'] == true) {
        final item =
            FieldInventory.fromJson(response.data['data']['fieldInventory']);
        state = state.copyWith(selectedItem: item, isLoading: false);
        return item;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return null;
  }

  // Create inventory item
  Future<bool> createInventoryItem(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post('/v1/nawassco/field_technician/field-inventory', data: data);

      if (response.data['success'] == true) {
        final item =
            FieldInventory.fromJson(response.data['data']['fieldInventory']);

        // Add to state
        final newItems = [item, ...state.inventoryItems];
        final filtered = _applyFilters(newItems, state.searchQuery);

        state = state.copyWith(
          inventoryItems: newItems,
          filteredItems: filtered,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Inventory item created successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }

  // Update inventory item
  Future<bool> updateInventoryItem(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.put('/v1/nawassco/field_technician/field-inventory/$id', data: data);

      if (response.data['success'] == true) {
        final updatedItem =
            FieldInventory.fromJson(response.data['data']['fieldInventory']);

        // Update in state
        final newItems = state.inventoryItems.map((item) {
          return item.id == id ? updatedItem : item;
        }).toList();

        final filtered = _applyFilters(newItems, state.searchQuery);

        state = state.copyWith(
          inventoryItems: newItems,
          filteredItems: filtered,
          selectedItem: updatedItem,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Inventory item updated successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }

  // Update stock level
  Future<bool> updateStockLevel(
      String id, int quantity, StockAction action) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.patch(
        '/v1/nawassco/field_technician/field-inventory/$id/stock',
        data: {
          'quantity': quantity,
          'action': action.name,
        },
      );

      if (response.data['success'] == true) {
        final updatedItem =
            FieldInventory.fromJson(response.data['data']['fieldInventory']);

        // Update in state
        final newItems = state.inventoryItems.map((item) {
          return item.id == id ? updatedItem : item;
        }).toList();

        final filtered = _applyFilters(newItems, state.searchQuery);

        state = state.copyWith(
          inventoryItems: newItems,
          filteredItems: filtered,
          selectedItem: updatedItem,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Stock level ${action.name}ed successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }

  // Record usage
  Future<bool> recordUsage(String id, int quantity,
      {String? workOrderId}) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.patch(
        '/v1/nawassco/field_technician/field-inventory/$id/usage',
        data: {
          'quantity': quantity,
          if (workOrderId != null) 'workOrderId': workOrderId,
        },
      );

      if (response.data['success'] == true) {
        final updatedItem =
            FieldInventory.fromJson(response.data['data']['fieldInventory']);

        // Update in state
        final newItems = state.inventoryItems.map((item) {
          return item.id == id ? updatedItem : item;
        }).toList();

        final filtered = _applyFilters(newItems, state.searchQuery);

        state = state.copyWith(
          inventoryItems: newItems,
          filteredItems: filtered,
          selectedItem: updatedItem,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Usage recorded successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }

  // Delete inventory item (soft delete)
  Future<bool> deleteInventoryItem(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      await dio.delete('/v1/nawassco/field_technician/field-inventory/$id');

      // Remove from state
      final newItems =
          state.inventoryItems.where((item) => item.id != id).toList();
      final filtered = _applyFilters(newItems, state.searchQuery);

      state = state.copyWith(
        inventoryItems: newItems,
        filteredItems: filtered,
        selectedItem: null,
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
        'Inventory item deleted successfully!',
        key: scaffoldMessengerKey,
      );
      return true;
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }

  // Get inventory metrics
  Future<void> fetchMetrics() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.get('/v1/nawassco/field_technician/field-inventory/metrics');

      if (response.data['success'] == true) {
        final metrics =
            FieldInventoryMetrics.fromJson(response.data['data']['metrics']);
        state = state.copyWith(metrics: metrics, isLoading: false);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Get low stock items
  Future<void> fetchLowStockItems({int? threshold}) async {
    try {
      final response =
          await dio.get('/v1/nawassco/field_technician/field-inventory/low-stock', queryParameters: {
        if (threshold != null) 'threshold': threshold,
      });

      if (response.data['success'] == true) {
        final items = List<FieldInventory>.from(response.data['data']
                ['lowStockItems']
            .map((x) => FieldInventory.fromJson(x)));
        state = state.copyWith(lowStockItems: items);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      categoryFilter: null,
      statusFilter: null,
      filteredItems: state.inventoryItems,
    );
  }

  // Clear selected item
  void clearSelectedItem() {
    state = state.copyWith(selectedItem: null);
  }

  // Helper method to apply filters
  List<FieldInventory> _applyFilters(
    List<FieldInventory> items,
    String searchQuery, [
    String? category,
    String? status,
  ]) {
    var filtered = items;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.itemCode
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            item.itemName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((item) => item.category == category).toList();
    }

    // Apply status filter
    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((item) => item.status == status).toList();
    }

    return filtered;
  }

  // Error handling
  void _handleError(dynamic error) {
    String errorMessage = 'An error occurred. Please try again.';

    if (error is DioException) {
      if (error.response?.data is Map) {
        errorMessage = error.response?.data['message'] ?? errorMessage;
      }
    }

    ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
  }
}

// Provider
final fieldInventoryProvider =
    StateNotifierProvider<FieldInventoryProvider, FieldInventoryState>(
  (ref) {
    final dio = ref.read(dioProvider);
    return FieldInventoryProvider(dio, scaffoldMessengerKey);
  },
);
