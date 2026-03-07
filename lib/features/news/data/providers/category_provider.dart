import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/services/api_service.dart';
import '../models/news_category.dart';

class CategoryProvider extends StateNotifier<CategoryState> {
  final Dio dio;
  final Ref ref;

  CategoryProvider(this.dio, this.ref) : super(CategoryState.initial());

  Future<void> fetchCategories({CategoryQuery? query}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-categories',
        queryParameters: query?.toQueryParams(),
      );

      final data = response.data['data'];
      final categories = (data['categories'] as List).map((item) => NewsCategory.fromJson(item)).toList();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
        pagination: PaginationInfo(
          page: data['pagination']['page'] ?? 1,
          limit: data['pagination']['limit'] ?? 20,
          total: data['pagination']['total'] ?? 0,
          pages: data['pagination']['screens'] ?? 1,
        ),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch categories',
      );
      ToastUtils.showErrorToast('Failed to load categories');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch categories',
      );
      ToastUtils.showErrorToast('Failed to load categories');
    }
  }

  Future<void> fetchCategoryHierarchy() async {
    try {
      final response = await dio.get('/v1/nawassco/news/news-categories/hierarchy');
      final hierarchyData = response.data['data']['hierarchy'] as List;
      state = state.copyWith(hierarchy: hierarchyData);
    } catch (e) {
      // Silently fail for hierarchy
    }
  }

  Future<NewsCategory?> fetchCategoryById(String id, {bool includeStats = false}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-categories/$id',
        queryParameters: {'includeStats': includeStats.toString()},
      );
      final data = response.data['data']['category'];
      return NewsCategory.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch category');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch category');
      return null;
    }
  }

  Future<NewsCategory?> fetchCategoryBySlug(String slug, {bool includeStats = false}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-categories/slug/$slug',
        queryParameters: {'includeStats': includeStats.toString()},
      );
      final data = response.data['data']['category'];
      return NewsCategory.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch category');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch category');
      return null;
    }
  }

  Future<NewsCategory?> createCategory(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/news/news-categories',
        data: data,
      );

      final categoryData = response.data['data']['category'];
      final newCategory = NewsCategory.fromJson(categoryData);

      state = state.copyWith(
        categories: [...state.categories, newCategory],
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Category created successfully');
      return newCategory;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to create category',
      );
      ToastUtils.showErrorToast('Failed to create category');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create category',
      );
      ToastUtils.showErrorToast('Failed to create category');
      return null;
    }
  }

  Future<NewsCategory?> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/news/news-categories/$id',
        data: data,
      );

      final categoryData = response.data['data']['category'];
      final updatedCategory = NewsCategory.fromJson(categoryData);

      state = state.copyWith(
        categories: state.categories.map((c) => c.id == id ? updatedCategory : c).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Category updated successfully');
      return updatedCategory;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to update category',
      );
      ToastUtils.showErrorToast('Failed to update category');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update category',
      );
      ToastUtils.showErrorToast('Failed to update category');
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/v1/nawassco/news/news-categories/$id');

      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Category deleted successfully');
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to delete category',
      );
      ToastUtils.showErrorToast('Failed to delete category');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete category',
      );
      ToastUtils.showErrorToast('Failed to delete category');
      return false;
    }
  }

  Future<bool> toggleCategoryActive(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news-categories/$id/toggle-active');

      final categoryData = response.data['data']['category'];
      final updatedCategory = NewsCategory.fromJson(categoryData);

      state = state.copyWith(
        categories: state.categories.map((c) => c.id == id ? updatedCategory : c).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
          updatedCategory.isActive ? 'Category activated' : 'Category deactivated'
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to toggle category',
      );
      ToastUtils.showErrorToast('Failed to toggle category');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle category',
      );
      ToastUtils.showErrorToast('Failed to toggle category');
      return false;
    }
  }

  List<NewsCategory> getActiveCategories() {
    return state.categories.where((c) => c.isActive).toList();
  }

  List<NewsCategory> getFeaturedCategories() {
    return state.categories.where((c) => c.isFeatured).toList();
  }

  List<NewsCategory> getRootCategories() {
    return state.categories.where((c) => c.parentCategoryId == null).toList();
  }

  List<NewsCategory> getSubcategories(String parentId) {
    return state.categories.where((c) => c.parentCategoryId == parentId).toList();
  }

  void searchCategories(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredCategories: null);
      return;
    }

    final filtered = state.categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(filteredCategories: filtered);
  }

  void clearFilters() {
    state = state.copyWith(filteredCategories: null);
  }
}

class CategoryState {
  final List<NewsCategory> categories;
  final List<NewsCategory>? filteredCategories;
  final List<dynamic>? hierarchy;
  final bool isLoading;
  final String? error;
  final PaginationInfo? pagination;

  const CategoryState({
    this.categories = const [],
    this.filteredCategories,
    this.hierarchy,
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  CategoryState.initial() : this();

  CategoryState copyWith({
    List<NewsCategory>? categories,
    List<NewsCategory>? filteredCategories,
    List<dynamic>? hierarchy,
    bool? isLoading,
    String? error,
    PaginationInfo? pagination,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      hierarchy: hierarchy ?? this.hierarchy,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }

  List<NewsCategory> get displayCategories => filteredCategories ?? categories;
}

class CategoryQuery {
  final int? page;
  final int? limit;
  final bool? isActive;
  final bool? isFeatured;
  final String? parentCategory;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const CategoryQuery({
    this.page,
    this.limit,
    this.isActive,
    this.isFeatured,
    this.parentCategory,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (isActive != null) params['isActive'] = isActive;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (parentCategory != null) params['parentCategory'] = parentCategory;
    if (search != null) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;

    return params;
  }
}

final categoryProvider = StateNotifierProvider<CategoryProvider, CategoryState>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoryProvider(dio, ref);
});