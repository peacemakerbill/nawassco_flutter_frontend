import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/inventory/inventory_category_model.dart';

class InventoryCategoryState {
  final List<InventoryCategory> categories;
  final InventoryCategory? selectedCategory;
  final bool isLoading;
  final String? error;
  final Map<String, List<InventoryCategory>> hierarchy;

  InventoryCategoryState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.hierarchy = const {},
  });

  InventoryCategoryState copyWith({
    List<InventoryCategory>? categories,
    InventoryCategory? selectedCategory,
    bool? isLoading,
    String? error,
    Map<String, List<InventoryCategory>>? hierarchy,
  }) {
    return InventoryCategoryState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hierarchy: hierarchy ?? this.hierarchy,
    );
  }
}

class InventoryCategoryProvider extends StateNotifier<InventoryCategoryState> {
  final Ref ref;
  final Dio dio;

  InventoryCategoryProvider(this.ref, this.dio) : super(InventoryCategoryState());

  // Create category
  Future<void> createCategory(InventoryCategory category) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/stores/inventory-categories',
        data: category.toJson(),
      );

      if (response.data['success'] == true) {
        final newCategory = InventoryCategory.fromJson(response.data['data']);
        state = state.copyWith(
          categories: [...state.categories, newCategory],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Get all categories
  Future<void> getCategories({String? search, String? parentCategory}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (parentCategory != null && parentCategory.isNotEmpty) {
        queryParams['parentCategory'] = parentCategory;
      }

      final response = await dio.get(
        '/v1/nawassco/stores/inventory-categories',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final categories = List<InventoryCategory>.from(
          (response.data['data'] as List).map((x) => InventoryCategory.fromJson(x)),
        );
        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get category by ID
  Future<void> getCategoryById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/stores/inventory-categories/$id');

      if (response.data['success'] == true) {
        final category = InventoryCategory.fromJson(response.data['data']);
        state = state.copyWith(
          selectedCategory: category,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch category');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get category by code
  Future<void> getCategoryByCode(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/stores/inventory-categories/code/$code');

      if (response.data['success'] == true) {
        final category = InventoryCategory.fromJson(response.data['data']);
        state = state.copyWith(
          selectedCategory: category,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch category');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Update category
  Future<void> updateCategory(String id, InventoryCategory category) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/stores/inventory-categories/$id',
        data: category.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedCategory = InventoryCategory.fromJson(response.data['data']);
        final updatedCategories = state.categories.map((cat) =>
        cat.id == id ? updatedCategory : cat).toList();

        state = state.copyWith(
          categories: updatedCategories,
          selectedCategory: updatedCategory,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/v1/nawassco/stores/inventory-categories/$id');

      state = state.copyWith(
        categories: state.categories.where((cat) => cat.id != id).toList(),
        selectedCategory: null,
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

  // Get category hierarchy
  Future<void> getCategoryHierarchy() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/stores/inventory-categories/hierarchy');

      if (response.data['success'] == true) {
        final hierarchyData = response.data['data'] as List;
        final hierarchy = <String, List<InventoryCategory>>{};

        for (final item in hierarchyData) {
          final category = InventoryCategory.fromJson(item);
          final parent = category.parentCategory ?? 'Root';
          if (!hierarchy.containsKey(parent)) {
            hierarchy[parent] = [];
          }
          hierarchy[parent]!.add(category);
        }

        state = state.copyWith(
          hierarchy: hierarchy,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch hierarchy');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get category statistics
  Future<Map<String, dynamic>> getCategoryStatistics() async {
    try {
      final response = await dio.get('/v1/nawassco/stores/inventory-categories/statistics');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected category
  void clearSelectedCategory() {
    state = state.copyWith(selectedCategory: null);
  }
}

// Provider
final inventoryCategoryProvider = StateNotifierProvider<InventoryCategoryProvider, InventoryCategoryState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return InventoryCategoryProvider(ref, dio);
  },
);