import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../main.dart';
import '../domain/models/invoice.dart';

class InvoiceState {
  final List<Invoice> invoices;
  final Invoice? selectedInvoice;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalInvoices;

  InvoiceState({
    this.invoices = const [],
    this.selectedInvoice,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalInvoices = 0,
  });

  InvoiceState copyWith({
    List<Invoice>? invoices,
    Invoice? selectedInvoice,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalInvoices,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalInvoices: totalInvoices ?? this.totalInvoices,
    );
  }
}

class InvoiceProvider extends StateNotifier<InvoiceState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  InvoiceProvider(this.dio, this.scaffoldMessengerKey)
      : super(InvoiceState());

  // -----------------------------------------------------------------
  // GET ALL INVOICES
  // -----------------------------------------------------------------
  Future<void> getInvoices({Map<String, dynamic>? filters, int page = 1}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': 10,
        ...?filters,
        ...state.filters,
      };

      // Remove null values
      queryParams.removeWhere((key, value) => value == null);

      final response = await dio.get('/v1/nawassco/procurement/invoices', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<Invoice> invoices = (response.data['data'] as List)
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList();

        final pagination = response.data['pagination'] ?? {};

        state = state.copyWith(
          invoices: invoices,
          isLoading: false,
          currentPage: pagination['page'] ?? page,
          totalPages: pagination['screens'] ?? 1,
          totalInvoices: pagination['total'] ?? 0,
          filters: filters ?? state.filters,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch invoices');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET SINGLE INVOICE
  // -----------------------------------------------------------------
  Future<void> getInvoice(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/invoices/$id');

      if (response.data['success'] == true) {
        final invoice = Invoice.fromJson(response.data['data']);
        state = state.copyWith(
          selectedInvoice: invoice,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // CREATE INVOICE
  // -----------------------------------------------------------------
  Future<bool> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/procurement/invoices', data: invoiceData);

      if (response.data['success'] == true) {
        final newInvoice = Invoice.fromJson(response.data['data']);

        // Add to the beginning of the list
        final updatedInvoices = [newInvoice, ...state.invoices];

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: newInvoice,
          isLoading: false,
        );

        _showSuccess('Invoice created successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // UPDATE INVOICE
  // -----------------------------------------------------------------
  Future<bool> updateInvoice(String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/procurement/invoices/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess('Invoice updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // DELETE INVOICE
  // -----------------------------------------------------------------
  Future<bool> deleteInvoice(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/procurement/invoices/$id');

      if (response.data['success'] == true) {
        // Remove from the list
        final updatedInvoices = state.invoices.where((invoice) => invoice.id != id).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: null,
          isLoading: false,
        );

        _showSuccess('Invoice deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // SUBMIT INVOICE FOR APPROVAL
  // -----------------------------------------------------------------
  Future<bool> submitInvoice(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/procurement/invoices/$id/submit');

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess('Invoice submitted for approval');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // PROCESS APPROVAL
  // -----------------------------------------------------------------
  Future<bool> processApproval(String id, String action, {String? comments}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/invoices/$id/approval',
        data: {'action': action, 'comments': comments},
      );

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess(action == 'approve' ? 'Invoice approved' : 'Invoice rejected');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process approval');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // PROCESS PAYMENT
  // -----------------------------------------------------------------
  Future<bool> processPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/invoices/$id/payment',
        data: paymentData,
      );

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess('Payment processed successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process payment');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // MATCH INVOICE
  // -----------------------------------------------------------------
  Future<bool> matchInvoice(String id, bool isMatched, {List<String>? discrepancies}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/invoices/$id/match',
        data: {
          'isMatched': isMatched,
          'discrepancies': discrepancies,
        },
      );

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess(isMatched ? 'Invoice matched successfully' : 'Invoice matching failed');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to match invoice');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // ADD GRN REFERENCE
  // -----------------------------------------------------------------
  Future<bool> addGRNReference(String id, String grnReference) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/procurement/invoices/$id/grn',
        data: {'grnReference': grnReference},
      );

      if (response.data['success'] == true) {
        final updatedInvoice = Invoice.fromJson(response.data['data']);

        // Update in the list
        final updatedInvoices = state.invoices.map((invoice) =>
        invoice.id == id ? updatedInvoice : invoice
        ).toList();

        state = state.copyWith(
          invoices: updatedInvoices,
          selectedInvoice: updatedInvoice,
          isLoading: false,
        );

        _showSuccess('GRN reference added successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add GRN reference');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
      return false;
    }
  }

  // -----------------------------------------------------------------
  // GET OVERDUE INVOICES
  // -----------------------------------------------------------------
  Future<void> getOverdueInvoices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/procurement/invoices/overdue');

      if (response.data['success'] == true) {
        final List<Invoice> overdueInvoices = (response.data['data'] as List)
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList();

        state = state.copyWith(
          invoices: overdueInvoices,
          isLoading: false,
          filters: {'overdue': true},
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch overdue invoices');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e.toString());
    }
  }

  // -----------------------------------------------------------------
  // GET INVOICE STATS
  // -----------------------------------------------------------------
  Future<Map<String, dynamic>?> getInvoiceStats({String timeframe = 'month'}) async {
    try {
      final response = await dio.get('/v1/nawassco/procurement/invoices/stats', queryParameters: {
        'timeframe': timeframe,
      });

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch invoice stats');
      }
    } catch (e) {
      _showError(e.toString());
      return null;
    }
  }

  // -----------------------------------------------------------------
  // CLEAR SELECTED INVOICE
  // -----------------------------------------------------------------
  void clearSelectedInvoice() {
    state = state.copyWith(selectedInvoice: null);
  }

  // -----------------------------------------------------------------
  // CLEAR ERROR
  // -----------------------------------------------------------------
  void clearError() {
    state = state.copyWith(error: null);
  }

  // -----------------------------------------------------------------
  // PRIVATE HELPERS
  // -----------------------------------------------------------------
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final invoiceProvider = StateNotifierProvider<InvoiceProvider, InvoiceState>((ref) {
  final dio = ref.read(dioProvider);
  return InvoiceProvider(dio, scaffoldMessengerKey);
});