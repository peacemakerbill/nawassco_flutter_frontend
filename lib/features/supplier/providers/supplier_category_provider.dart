import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/supplier_category_model.dart';

class SupplierCategoryState {
  final List<SupplierCategory> categories;
  final SupplierCategory? selectedCategory;
  final bool isLoading;
  final String? error;
  final List<dynamic> categoryHierarchy;

  SupplierCategoryState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.categoryHierarchy = const [],
  });

  SupplierCategoryState copyWith({
    List<SupplierCategory>? categories,
    SupplierCategory? selectedCategory,
    bool? isLoading,
    String? error,
    List<dynamic>? categoryHierarchy,
  }) {
    return SupplierCategoryState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      categoryHierarchy: categoryHierarchy ?? this.categoryHierarchy,
    );
  }
}

class SupplierCategoryProvider extends StateNotifier<SupplierCategoryState> {
  final Dio dio;

  SupplierCategoryProvider(this.dio) : super(SupplierCategoryState());

  // Get all categories
  Future<void> getAllCategories({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/categories', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierCategory> categories = (response.data['data'] as List)
            .map((item) => SupplierCategory.fromJson(item))
            .toList();

        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch categories',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch categories: $e',
        isLoading: false,
      );
    }
  }

  // Get category by ID
  Future<void> getCategoryById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/categories/$id');

      if (response.data['success'] == true) {
        final SupplierCategory category = SupplierCategory.fromJson(response.data['data']);

        state = state.copyWith(
          selectedCategory: category,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch category',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch category: $e',
        isLoading: false,
      );
    }
  }

  // Create category
  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/categories', data: data);

      if (response.data['success'] == true) {
        await getAllCategories();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create category',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create category: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update category
  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/supplier/categories/$id', data: data);

      if (response.data['success'] == true) {
        await getAllCategories();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update category',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update category: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/supplier/categories/$id');

      if (response.data['success'] == true) {
        await getAllCategories();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete category',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete category: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Get categories by level
  Future<void> getCategoriesByLevel(int level, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/categories/level/$level', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierCategory> categories = (response.data['data'] as List)
            .map((item) => SupplierCategory.fromJson(item))
            .toList();

        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch categories by level',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch categories by level: $e',
        isLoading: false,
      );
    }
  }

  // Get subcategories
  Future<void> getSubcategories(String parentId, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/categories/$parentId/subcategories', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierCategory> categories = (response.data['data'] as List)
            .map((item) => SupplierCategory.fromJson(item))
            .toList();

        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch subcategories',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch subcategories: $e',
        isLoading: false,
      );
    }
  }

  // Get category hierarchy
  Future<void> getCategoryHierarchy() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/categories/hierarchy');

      if (response.data['success'] == true) {
        state = state.copyWith(
          categoryHierarchy: response.data['data'] ?? [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch category hierarchy',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch category hierarchy: $e',
        isLoading: false,
      );
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

final supplierCategoryProvider = StateNotifierProvider<SupplierCategoryProvider, SupplierCategoryState>((ref) {
  final dio = ref.read(dioProvider);
  return SupplierCategoryProvider(dio);
});