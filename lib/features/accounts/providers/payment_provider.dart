import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/services/api_service.dart';
import '../models/payment_model.dart';

class PaymentState {
  final List<Payment> payments;
  final Payment? selectedPayment;
  final PaymentSummary? summary;
  final bool isLoading;
  final bool isLoadingSummary;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isUploadingDocument;
  final bool isProcessing;

  PaymentState({
    this.payments = const [],
    this.selectedPayment,
    this.summary,
    this.isLoading = false,
    this.isLoadingSummary = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.isUploadingDocument = false,
    this.isProcessing = false,
  });

  PaymentState copyWith({
    List<Payment>? payments,
    Payment? selectedPayment,
    PaymentSummary? summary,
    bool? isLoading,
    bool? isLoadingSummary,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? isUploadingDocument,
    bool? isProcessing,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      isUploadingDocument: isUploadingDocument ?? this.isUploadingDocument,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class PaymentProvider extends StateNotifier<PaymentState> {
  final Dio dio;
  bool _isFetchingPayments = false;
  bool _isFetchingSummary = false;

  PaymentProvider(this.dio) : super(PaymentState());

  // Fetch payments with pagination only (no filters)
  Future<void> fetchPayments({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // Prevent multiple simultaneous calls
    if (_isFetchingPayments && !forceRefresh) {
      return;
    }

    try {
      _isFetchingPayments = true;
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      print('Fetching payments page $page...');

      final response = await dio.get(
        '/v1/nawassco/accounts/payments',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Payments response received');

      if (response.data['success'] == true) {
        final paymentsResponse = PaymentsResponse.fromJson(response.data['data']['result']);

        state = state.copyWith(
          payments: paymentsResponse.payments,
          currentPage: paymentsResponse.pagination.page,
          totalPages: paymentsResponse.pagination.pages,
          totalCount: paymentsResponse.pagination.total,
          isLoading: false,
          error: null,
        );
        print('Loaded ${paymentsResponse.payments.length} payments');
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch payments',
          isLoading: false,
        );
        print('Error: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception fetching payments: $e');
      state = state.copyWith(
        error: 'Failed to fetch payments: ${e.toString()}',
        isLoading: false,
      );
    } finally {
      _isFetchingPayments = false;
    }
  }

  // Fetch payment by ID
  Future<void> fetchPaymentById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/accounts/payments/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final payment = Payment.fromJson(response.data['data']['payment']);
        state = state.copyWith(
          selectedPayment: payment,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch payment',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch payment: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Create payment
  Future<bool> createPayment(Payment payment) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/accounts/payments',
        data: payment.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: 1, forceRefresh: true);
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create payment',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create payment: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Update payment
  Future<bool> updatePayment(String id, Payment payment) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/accounts/payments/$id',
        data: payment.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: state.currentPage, forceRefresh: true);
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update payment',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update payment: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Approve payment
  Future<bool> approvePayment(String id) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/payments/$id/approve',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: state.currentPage, forceRefresh: true);
        state = state.copyWith(isProcessing: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to approve payment',
          isProcessing: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to approve payment: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // Process payment
  Future<bool> processPayment(String id) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/payments/$id/process',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: state.currentPage, forceRefresh: true);
        state = state.copyWith(isProcessing: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to process payment',
          isProcessing: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to process payment: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // Cancel payment
  Future<bool> cancelPayment(String id, {String? reason}) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/accounts/payments/$id/cancel',
        data: reason != null ? {'reason': reason} : null,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: state.currentPage, forceRefresh: true);
        state = state.copyWith(isProcessing: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to cancel payment',
          isProcessing: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to cancel payment: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // Delete payment
  Future<bool> deletePayment(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete(
        '/v1/nawassco/accounts/payments/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPayments(page: state.currentPage, forceRefresh: true);
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete payment',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete payment: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Fetch payment summary (no filters)
  Future<void> fetchPaymentSummary() async {
    // Prevent multiple simultaneous calls
    if (_isFetchingSummary) {
      return;
    }

    try {
      _isFetchingSummary = true;
      state = state.copyWith(isLoadingSummary: true, error: null);

      print('Fetching payment summary...');

      final response = await dio.get(
        '/v1/nawassco/accounts/payments/summary',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Summary response received');

      if (response.data['success'] == true) {
        final summary = PaymentSummary.fromJson(response.data['data']['summary']);
        state = state.copyWith(
          summary: summary,
          isLoadingSummary: false,
          error: null,
        );
        print('Loaded payment summary');
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch summary',
          isLoadingSummary: false,
        );
      }
    } catch (e) {
      print('Exception fetching summary: $e');
      state = state.copyWith(
        error: 'Failed to fetch summary: ${e.toString()}',
        isLoadingSummary: false,
      );
    } finally {
      _isFetchingSummary = false;
    }
  }

  // Upload payment document
  Future<bool> uploadPaymentDocument(String paymentId, PlatformFile file) async {
    try {
      state = state.copyWith(isUploadingDocument: true, error: null);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await dio.post(
        '/v1/nawassco/accounts/payments/$paymentId/upload',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPaymentById(paymentId);
        state = state.copyWith(isUploadingDocument: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to upload document',
          isUploadingDocument: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to upload document: ${e.toString()}',
        isUploadingDocument: false,
      );
      return false;
    }
  }

  // Download payment document
  Future<bool> downloadPaymentDocument(PaymentDocument document) async {
    try {
      final response = await dio.get(
        document.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final bytes = response.data as List<int>;

      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/${document.originalName ?? document.fileName}');

      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to download document: ${e.toString()}',
      );
      return false;
    }
  }

  // Delete payment document
  Future<bool> deletePaymentDocument(String paymentId, String documentId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete(
        '/v1/nawassco/accounts/payments/$paymentId/documents/$documentId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        await fetchPaymentById(paymentId);
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete document',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete document: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Clear selected payment
  void clearSelectedPayment() {
    state = state.copyWith(selectedPayment: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void reset() {
    _isFetchingPayments = false;
    _isFetchingSummary = false;
    state = PaymentState();
  }
}

// Provider
final paymentProvider = StateNotifierProvider<PaymentProvider, PaymentState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return PaymentProvider(dio);
  },
);