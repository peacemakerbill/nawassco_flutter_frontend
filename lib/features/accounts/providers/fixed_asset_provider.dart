import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/fixed_asset_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';

class FixedAssetsState {
  final List<FixedAsset> allAssets; // All assets from backend
  final List<FixedAsset> displayedAssets; // Assets after local filtering
  final FixedAsset? selectedAsset;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchQuery;
  final AssetCategory? categoryFilter;
  final AssetStatus? statusFilter;
  final String? departmentFilter;
  final FixedAssetsSummary? summary;
  final DepreciationSchedule? depreciationSchedule;
  final bool hasLoadedAllAssets; // Track if all assets are loaded

  FixedAssetsState({
    this.allAssets = const [],
    this.displayedAssets = const [],
    this.selectedAsset,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.searchQuery = '',
    this.categoryFilter,
    this.statusFilter,
    this.departmentFilter,
    this.summary,
    this.depreciationSchedule,
    this.hasLoadedAllAssets = false,
  });

  FixedAssetsState copyWith({
    List<FixedAsset>? allAssets,
    List<FixedAsset>? displayedAssets,
    FixedAsset? selectedAsset,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchQuery,
    AssetCategory? categoryFilter,
    AssetStatus? statusFilter,
    String? departmentFilter,
    FixedAssetsSummary? summary,
    DepreciationSchedule? depreciationSchedule,
    bool? hasLoadedAllAssets,
  }) {
    return FixedAssetsState(
      allAssets: allAssets ?? this.allAssets,
      displayedAssets: displayedAssets ?? this.displayedAssets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      summary: summary ?? this.summary,
      depreciationSchedule: depreciationSchedule ?? this.depreciationSchedule,
      hasLoadedAllAssets: hasLoadedAllAssets ?? this.hasLoadedAllAssets,
    );
  }
}

class FixedAssetsProvider extends StateNotifier<FixedAssetsState> {
  final Dio dio;

  FixedAssetsProvider(this.dio) : super(FixedAssetsState());

  // Helper method for local filtering
  List<FixedAsset> _filterAssetsLocally(List<FixedAsset> allAssets) {
    var filteredAssets = allAssets;

    // Apply search query filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredAssets = filteredAssets.where((asset) {
        return asset.assetName.toLowerCase().contains(query) ||
            asset.assetNumber.toLowerCase().contains(query) ||
            (asset.description?.toLowerCase() ?? '').contains(query) ||
            asset.location.toLowerCase().contains(query) ||
            asset.department.toLowerCase().contains(query) ||
            (asset.supplierName?.toLowerCase() ?? '').contains(query) ||
            (asset.purchaseOrderNumber?.toLowerCase() ?? '').contains(query);
      }).toList();
    }

    // Apply category filter
    if (state.categoryFilter != null) {
      filteredAssets = filteredAssets
          .where((asset) => asset.assetCategory == state.categoryFilter)
          .toList();
    }

    // Apply status filter
    if (state.statusFilter != null) {
      filteredAssets = filteredAssets
          .where((asset) => asset.status == state.statusFilter)
          .toList();
    }

    // Apply department filter
    if (state.departmentFilter != null && state.departmentFilter!.isNotEmpty) {
      filteredAssets = filteredAssets
          .where((asset) => asset.department == state.departmentFilter)
          .toList();
    }

    return filteredAssets;
  }

  // Fetch all assets for local filtering
  Future<void> fetchAllAssetsForLocalFiltering() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Fetch all assets at once for local filtering
      final response = await dio.get(
        '/v1/nawassco/accounts/fixed-assets',
        queryParameters: {
          'page': 1,
          'limit': 1000, // Fetch a large number for local filtering
        },
      );

      if (response.data['success'] == true) {
        final assetsResponse = FixedAssetsResponse.fromJson(response.data['data']['result']);

        state = state.copyWith(
          allAssets: assetsResponse.assets,
          displayedAssets: assetsResponse.assets, // Initially show all
          currentPage: assetsResponse.pagination.page,
          totalPages: assetsResponse.pagination.pages,
          totalCount: assetsResponse.pagination.total,
          isLoading: false,
          hasLoadedAllAssets: true,
        );
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to fetch assets';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      }
    } catch (e) {
      final errorMessage = 'Failed to fetch assets: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    }
  }

  // Fetch assets with pagination (original method - kept for compatibility)
  Future<void> fetchAssets({
    int? page,
    int limit = 10,
    bool append = false,
  }) async {
    // Use the new method that loads all assets for local filtering
    if (!state.hasLoadedAllAssets) {
      await fetchAllAssetsForLocalFiltering();
    }
  }

  // Search assets immediately (client-side only)
  Future<void> searchAssetsImmediately(String query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
    );

    // Filter locally
    final filteredAssets = _filterAssetsLocally(state.allAssets);

    state = state.copyWith(
      displayedAssets: filteredAssets,
    );
  }

  // Clear search and show all assets
  Future<void> clearSearchAndFetch() async {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      displayedAssets: state.allAssets,
      isLoading: false,
      error: null,
    );
  }

  // Fetch asset by ID
  Future<void> fetchAssetById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/fixed-assets/$id');

      if (response.data['success'] == true) {
        final asset = FixedAsset.fromJson(response.data['data']['asset']);
        state = state.copyWith(
          selectedAsset: asset,
          isLoading: false,
        );
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to fetch asset';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      }
    } catch (e) {
      final errorMessage = 'Failed to fetch asset: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    }
  }

  // Create new asset
  Future<bool> createAsset(FixedAsset asset) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/fixed-assets',
        data: asset.toJson(),
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast('Asset created successfully', key: scaffoldMessengerKey);

        // Refresh the list to include the new asset
        await fetchAllAssetsForLocalFiltering();
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to create asset';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to create asset: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Update asset
  Future<bool> updateAsset(String id, FixedAsset asset) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/fixed-assets/$id',
        data: asset.toJson(),
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast('Asset updated successfully', key: scaffoldMessengerKey);

        // Update the asset in the local list
        final updatedAllAssets = state.allAssets.map((existingAsset) {
          return existingAsset.id == id ? asset : existingAsset;
        }).toList();

        // Update displayed assets
        final updatedDisplayedAssets = _filterAssetsLocally(updatedAllAssets);

        // Update selected asset if it's the one being edited
        final updatedSelectedAsset = state.selectedAsset?.id == id
            ? asset
            : state.selectedAsset;

        state = state.copyWith(
          allAssets: updatedAllAssets,
          displayedAssets: updatedDisplayedAssets,
          selectedAsset: updatedSelectedAsset,
          isLoading: false,
        );

        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update asset';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to update asset: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Calculate depreciation
  Future<DepreciationResult?> calculateDepreciation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/fixed-assets/$id/calculate-depreciation');

      if (response.data['success'] == true) {
        final depreciation = DepreciationResult.fromJson(response.data['data']['depreciation']);
        state = state.copyWith(isLoading: false);
        return depreciation;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to calculate depreciation';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return null;
      }
    } catch (e) {
      final errorMessage = 'Failed to calculate depreciation: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return null;
    }
  }

  // Post depreciation
  Future<bool> postDepreciation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/accounts/fixed-assets/$id/post-depreciation');

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast('Depreciation posted successfully', key: scaffoldMessengerKey);

        // Refresh the asset data
        await fetchAssetById(id);

        // Also update the asset in the local list
        await fetchAllAssetsForLocalFiltering();

        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to post depreciation';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to post depreciation: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Dispose asset
  Future<bool> disposeAsset(String id, DateTime disposalDate, double disposalAmount) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/fixed-assets/$id/dispose',
        data: {
          'disposalDate': disposalDate.toIso8601String(),
          'disposalAmount': disposalAmount,
        },
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast('Asset disposed successfully', key: scaffoldMessengerKey);

        // Remove the disposed asset from the local lists
        final updatedAllAssets = state.allAssets.where((asset) => asset.id != id).toList();
        final updatedDisplayedAssets = state.displayedAssets.where((asset) => asset.id != id).toList();

        state = state.copyWith(
          allAssets: updatedAllAssets,
          displayedAssets: updatedDisplayedAssets,
          totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
          isLoading: false,
        );

        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to dispose asset';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to dispose asset: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Fetch depreciation schedule
  Future<void> fetchDepreciationSchedule(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/fixed-assets/$id/depreciation-schedule');

      if (response.data['success'] == true) {
        final schedule = DepreciationSchedule.fromJson(response.data['data']['schedule']);
        state = state.copyWith(
          depreciationSchedule: schedule,
          isLoading: false,
        );
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to fetch depreciation schedule';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      }
    } catch (e) {
      final errorMessage = 'Failed to fetch depreciation schedule: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    }
  }

  // Fetch assets summary
  Future<void> fetchAssetsSummary() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/fixed-assets/summary');

      if (response.data['success'] == true) {
        final summary = FixedAssetsSummary.fromJson(response.data['data']['summary']);
        state = state.copyWith(
          summary: summary,
          isLoading: false,
        );
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to fetch assets summary';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      }
    } catch (e) {
      final errorMessage = 'Failed to fetch assets summary: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    }
  }

  // Upload asset document
  Future<bool> uploadAssetDocument(String id, List<int> fileBytes, String fileName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final formData = FormData.fromMap({
        'document': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await dio.post(
        '/v1/nawassco/accounts/fixed-assets/$id/upload',
        data: formData,
      );

      if (response.data['success'] == true) {
        ToastUtils.showSuccessToast('Document uploaded successfully', key: scaffoldMessengerKey);
        await fetchAssetById(id);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to upload document';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Failed to upload document: ${e.toString()}';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
      return false;
    }
  }

  // Update filters (client-side only)
  void updateFilters({
    String? searchQuery,
    AssetCategory? category,
    AssetStatus? status,
    String? department,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      categoryFilter: category ?? state.categoryFilter,
      statusFilter: status ?? state.statusFilter,
      departmentFilter: department ?? state.departmentFilter,
      currentPage: 1,
    );

    // Apply filters locally
    final filteredAssets = _filterAssetsLocally(state.allAssets);

    state = state.copyWith(
      displayedAssets: filteredAssets,
    );
  }

  // Clear all filters
  void clearAllFilters() {
    state = state.copyWith(
      searchQuery: '',
      categoryFilter: null,
      statusFilter: null,
      departmentFilter: null,
      currentPage: 1,
      displayedAssets: state.allAssets, // Show all assets when filters are cleared
    );
  }

  // Clear selected asset
  void clearSelectedAsset() {
    state = state.copyWith(selectedAsset: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear depreciation schedule
  void clearDepreciationSchedule() {
    state = state.copyWith(depreciationSchedule: null);
  }

  // Clear assets (useful when logging out or changing views)
  void clearAssets() {
    state = state.copyWith(
      allAssets: [],
      displayedAssets: [],
      currentPage: 1,
      totalPages: 1,
      totalCount: 0,
      searchQuery: '',
      categoryFilter: null,
      statusFilter: null,
      departmentFilter: null,
      hasLoadedAllAssets: false,
    );
  }

  // Refresh current page
  Future<void> refreshCurrentPage() async {
    await fetchAllAssetsForLocalFiltering();
  }

  // Load more assets (for infinite scroll - not needed with local filtering)
  Future<void> loadMoreAssets() async {
    // Not needed with local filtering
  }
}

// Provider
final fixedAssetsProvider = StateNotifierProvider<FixedAssetsProvider, FixedAssetsState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return FixedAssetsProvider(dio);
  },
);