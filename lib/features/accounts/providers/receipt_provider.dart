import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../models/receipt_model.dart';
import '../../../main.dart';

class ReceiptState {
  final List<Receipt> receipts;
  final Receipt? selectedReceipt;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalReceipts;

  ReceiptState({
    this.receipts = const [],
    this.selectedReceipt,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalReceipts = 0,
  });

  ReceiptState copyWith({
    List<Receipt>? receipts,
    Receipt? selectedReceipt,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalReceipts,
  }) {
    return ReceiptState(
      receipts: receipts ?? this.receipts,
      selectedReceipt: selectedReceipt ?? this.selectedReceipt,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalReceipts: totalReceipts ?? this.totalReceipts,
    );
  }
}

class ReceiptProvider extends StateNotifier<ReceiptState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  ReceiptProvider(this.dio, this.scaffoldMessengerKey) : super(ReceiptState());

  bool get isMounted => mounted;

  // -----------------------------------------------------------------
  // FETCH RECEIPTS
  // -----------------------------------------------------------------
  Future<void> fetchReceipts({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
      };

      // Remove null values
      queryParams.removeWhere((key, value) => value == null);

      final response = await dio.get('/v1/nawassco/accounts/receipts', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final receipts = (data['receipts'] as List)
            .map((json) => Receipt.fromJson(json))
            .toList();

        final pagination = data['pagination'];

        state = state.copyWith(
          receipts: receipts,
          currentPage: pagination['page'],
          totalPages: pagination['pages'],
          totalReceipts: pagination['total'],
          filters: filters ?? state.filters,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch receipts';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // GET RECEIPT BY ID
  // -----------------------------------------------------------------
  Future<void> getReceiptById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/receipts/$id');

      if (response.data['success'] == true) {
        final receipt = Receipt.fromJson(response.data['data']['receipt']);
        state = state.copyWith(
          selectedReceipt: receipt,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to fetch receipt';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
    }
  }

  // -----------------------------------------------------------------
  // CREATE RECEIPT
  // -----------------------------------------------------------------
  Future<bool> createReceipt(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final response = await dio.post('/v1/nawassco/accounts/receipts', data: data);

      if (response.data['success'] == true) {
        final receipt = Receipt.fromJson(response.data['data']['receipt']);

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Receipt created successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: [receipt, ...state.receipts],
          isCreating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to create receipt';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isCreating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE RECEIPT
  // -----------------------------------------------------------------
  Future<bool> updateReceipt(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.put('/v1/nawassco/accounts/receipts/$id', data: data);

      if (response.data['success'] == true) {
        final updatedReceipt =
        Receipt.fromJson(response.data['data']['receipt']);

        final updatedReceipts = state.receipts
            .map((receipt) => receipt.id == id ? updatedReceipt : receipt)
            .toList();

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Receipt updated successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: updatedReceipts,
          selectedReceipt: updatedReceipt,
          isUpdating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to update receipt';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // CONFIRM RECEIPT
  // -----------------------------------------------------------------
  Future<bool> confirmReceipt(String id) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch('/v1/nawassco/accounts/receipts/$id/confirm');

      if (response.data['success'] == true) {
        final confirmedReceipt =
        Receipt.fromJson(response.data['data']['receipt']);

        final updatedReceipts = state.receipts
            .map((receipt) => receipt.id == id ? confirmedReceipt : receipt)
            .toList();

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Receipt confirmed successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: updatedReceipts,
          selectedReceipt: confirmedReceipt,
          isUpdating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to confirm receipt';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // ALLOCATE RECEIPT
  // -----------------------------------------------------------------
  Future<bool> allocateReceipt(String id, double allocatedAmount) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/receipts/$id/allocate',
        data: {'allocatedAmount': allocatedAmount},
      );

      if (response.data['success'] == true) {
        final allocatedReceipt =
        Receipt.fromJson(response.data['data']['receipt']);

        final updatedReceipts = state.receipts
            .map((receipt) => receipt.id == id ? allocatedReceipt : receipt)
            .toList();

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Receipt allocated successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: updatedReceipts,
          selectedReceipt: allocatedReceipt,
          isUpdating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to allocate receipt';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPLOAD RECEIPT DOCUMENT
  // -----------------------------------------------------------------
  Future<bool> uploadReceiptDocument(String id, String filePath) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        '/v1/nawassco/accounts/receipts/$id/upload',
        data: formData,
      );

      if (response.data['success'] == true) {
        final updatedReceipt =
        Receipt.fromJson(response.data['data']['receipt']);

        final updatedReceipts = state.receipts
            .map((receipt) => receipt.id == id ? updatedReceipt : receipt)
            .toList();

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Document uploaded successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: updatedReceipts,
          selectedReceipt: updatedReceipt,
          isUpdating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to upload document';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // DELETE RECEIPT DOCUMENT
  // -----------------------------------------------------------------
  Future<bool> deleteReceiptDocument(String id) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.delete('/v1/nawassco/accounts/receipts/$id/document');

      if (response.data['success'] == true) {
        final updatedReceipt = Receipt.fromJson(response.data['data']['receipt']);

        final updatedReceipts = state.receipts
            .map((receipt) => receipt.id == id ? updatedReceipt : receipt)
            .toList();

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Document deleted successfully',
            key: scaffoldMessengerKey,
          );
        });

        state = state.copyWith(
          receipts: updatedReceipts,
          selectedReceipt: updatedReceipt,
          isUpdating: false,
        );

        return true;
      } else {
        throw response.data['message'] ?? 'Failed to delete document';
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // -----------------------------------------------------------------
  // GET RECEIPT SUMMARY
  // -----------------------------------------------------------------
  Future<Map<String, dynamic>?> getReceiptSummary({
    String? startDate,
    String? endDate,
    String? receiptType,
  }) async {
    try {
      final queryParams = {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (receiptType != null) 'receiptType': receiptType,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/receipts/summary',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return response.data['data']['summary'];
      } else {
        throw response.data['message'] ?? 'Failed to fetch summary';
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // -----------------------------------------------------------------
  // FILTER RECEIPTS
  // -----------------------------------------------------------------
  void setFilters(Map<String, dynamic> filters) {
    state = state.copyWith(filters: filters, currentPage: 1);
    fetchReceipts(page: 1, filters: filters);
  }

  // -----------------------------------------------------------------
  // CLEAR SELECTED RECEIPT
  // -----------------------------------------------------------------
  void clearSelectedReceipt() {
    state = state.copyWith(selectedReceipt: null);
  }

  // -----------------------------------------------------------------
  // PRIVATE HELPERS
  // -----------------------------------------------------------------
  void _showToastSafely(VoidCallback showToast) {
    if (isMounted) {
      showToast();
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    _showToastSafely(() {
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    });

    state = state.copyWith(error: errorMessage);
  }
}

// Provider
final receiptProvider =
StateNotifierProvider<ReceiptProvider, ReceiptState>((ref) {
  final dio = ref.read(dioProvider);
  return ReceiptProvider(dio, scaffoldMessengerKey);
});