import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';

import '../models/quote.model.dart';

// ============================================
// STATE CLASS
// ============================================
class QuoteState {
  final bool isLoading;
  final List<Quote> quotes;
  final Quote? selectedQuote;
  final QuoteFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final QuoteStats? stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isSending;
  final bool isApproving;
  final bool showStats;
  final String? error;

  const QuoteState({
    this.isLoading = false,
    this.quotes = const [],
    this.selectedQuote,
    this.filters = const QuoteFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.stats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isSending = false,
    this.isApproving = false,
    this.showStats = false,
    this.error,
  });

  QuoteState copyWith({
    bool? isLoading,
    List<Quote>? quotes,
    Quote? selectedQuote,
    QuoteFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    QuoteStats? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isSending,
    bool? isApproving,
    bool? showStats,
    String? error,
  }) {
    return QuoteState(
      isLoading: isLoading ?? this.isLoading,
      quotes: quotes ?? this.quotes,
      selectedQuote: selectedQuote ?? this.selectedQuote,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isSending: isSending ?? this.isSending,
      isApproving: isApproving ?? this.isApproving,
      showStats: showStats ?? this.showStats,
      error: error ?? this.error,
    );
  }
}

// ============================================
// PROVIDER
// ============================================
class QuoteProvider extends StateNotifier<QuoteState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  QuoteProvider(this._dio, this._scaffoldKey) : super(const QuoteState());

  // -----------------------------------------------------------------
  // CRUD OPERATIONS
  // -----------------------------------------------------------------
  Future<void> loadQuotes({bool refresh = false}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final query = {
        'page': state.currentPage.toString(),
        'limit': '20',
        ...state.filters.toQueryParams(),
      };

      final response = await _dio.get('/v1/nawassco/sales/quotes', queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final pagination = response.data['pagination'] as Map<String, dynamic>;

        final quotes = data.map<Quote>((json) => Quote.fromJson(json)).toList();

        state = state.copyWith(
          quotes: refresh ? quotes : [...state.quotes, ...quotes],
          totalPages: (pagination['pages'] as num?)?.toInt() ?? 1,
          totalItems: (pagination['total'] as num?)?.toInt() ?? 0,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load quotes');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<Quote?> createQuote(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      // Prepare quote data with new fields
      final Map<String, dynamic> quoteData = Map.from(data);

      // Ensure required fields are present
      if (!quoteData.containsKey('status')) {
        quoteData['status'] = QuoteStatus.draft.name;
      }

      // Calculate totals if not provided
      if (!quoteData.containsKey('subtotal') && quoteData.containsKey('items')) {
        final items = quoteData['items'] as List<dynamic>;
        quoteData['subtotal'] = _calculateSubtotal(items);
      }

      if (!quoteData.containsKey('totalAmount') && quoteData.containsKey('items')) {
        quoteData['totalAmount'] = _calculateTotalAmount(quoteData);
      }

      // Add customerName and customerEmail if available in customer object
      if (quoteData['customer'] != null && quoteData['customer'] is Map<String, dynamic>) {
        final customer = quoteData['customer'] as Map<String, dynamic>;
        if (customer['name'] != null && !quoteData.containsKey('customerName')) {
          quoteData['customerName'] = customer['name'];
        }
        if (customer['email'] != null && !quoteData.containsKey('customerEmail')) {
          quoteData['customerEmail'] = customer['email'];
        }
      }

      // Add opportunityNumber if available in opportunity object
      if (quoteData['opportunity'] != null && quoteData['opportunity'] is Map<String, dynamic>) {
        final opportunity = quoteData['opportunity'] as Map<String, dynamic>;
        if (opportunity['opportunityNumber'] != null && !quoteData.containsKey('opportunityNumber')) {
          quoteData['opportunityNumber'] = opportunity['opportunityNumber'];
        }
      }

      final response = await _dio.post('/v1/nawassco/sales/quotes', data: quoteData);

      if (response.data['success'] == true) {
        final quote = Quote.fromJson(response.data['data']);

        state = state.copyWith(
          quotes: [quote, ...state.quotes],
          selectedQuote: quote,
          isCreating: false,
        );

        _showSuccess('Quote created successfully');
        return quote;
      } else {
        _showError(response.data['message'] ?? 'Failed to create quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }

  Future<Quote?> updateQuote(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      // Add updatedByUser information if current user is available
      // This should come from the Auth context
      // For now, we'll rely on backend to populate this

      final response = await _dio.put('/v1/nawassco/sales/quotes/$id', data: data);

      if (response.data['success'] == true) {
        final updatedQuote = Quote.fromJson(response.data['data']);

        final updatedQuotes = state.quotes.map((quote) {
          return quote.id == id ? updatedQuote : quote;
        }).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: updatedQuote,
          isUpdating: false,
        );

        _showSuccess('Quote updated successfully');
        return updatedQuote;
      } else {
        _showError(response.data['message'] ?? 'Failed to update quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  // -----------------------------------------------------------------
  // DELETE QUOTE METHOD
  // -----------------------------------------------------------------
  Future<bool> deleteQuote(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await _dio.delete('/v1/nawassco/sales/quotes/$id');

      if (response.data['success'] == true) {
        final updatedQuotes = state.quotes.where((quote) => quote.id != id).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: null,
          isDeleting: false,
        );

        _showSuccess('Quote deleted successfully');
        return true;
      } else {
        _showError(response.data['message'] ?? 'Failed to delete quote');
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  // -----------------------------------------------------------------
  // SEND QUOTE METHOD
  // -----------------------------------------------------------------
  Future<Quote?> sendQuote(String id) async {
    try {
      state = state.copyWith(isSending: true, error: null);

      // Update quote status to 'sent'
      final response = await _dio.put(
        '/v1/nawassco/sales/quotes/$id',
        data: {'status': QuoteStatus.sent.name},
      );

      if (response.data['success'] == true) {
        final updatedQuote = Quote.fromJson(response.data['data']);

        final updatedQuotes = state.quotes.map((quote) {
          return quote.id == id ? updatedQuote : quote;
        }).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: updatedQuote,
          isSending: false,
        );

        _showSuccess('Quote sent successfully');
        return updatedQuote;
      } else {
        _showError(response.data['message'] ?? 'Failed to send quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  Future<Quote?> approveQuote(String id, {String? comments}) async {
    try {
      state = state.copyWith(isApproving: true, error: null);

      final data = <String, dynamic>{};
      if (comments != null && comments.isNotEmpty) {
        data['comments'] = comments;
      }

      final response = await _dio.put('/v1/nawassco/sales/quotes/$id/approve', data: data);

      if (response.data['success'] == true) {
        final updatedQuote = Quote.fromJson(response.data['data']);

        final updatedQuotes = state.quotes.map((quote) {
          return quote.id == id ? updatedQuote : quote;
        }).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: updatedQuote,
          isApproving: false,
        );

        _showSuccess('Quote approved successfully');
        return updatedQuote;
      } else {
        _showError(response.data['message'] ?? 'Failed to approve quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isApproving: false);
    }
  }

  Future<Quote?> rejectQuote(String id, {String? comments}) async {
    try {
      state = state.copyWith(isApproving: true, error: null);

      final data = <String, dynamic>{};
      if (comments != null && comments.isNotEmpty) {
        data['comments'] = comments;
      }

      final response = await _dio.put('/v1/nawassco/sales/quotes/$id/reject', data: data);

      if (response.data['success'] == true) {
        final updatedQuote = Quote.fromJson(response.data['data']);

        final updatedQuotes = state.quotes.map((quote) {
          return quote.id == id ? updatedQuote : quote;
        }).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: updatedQuote,
          isApproving: false,
        );

        _showSuccess('Quote rejected');
        return updatedQuote;
      } else {
        _showError(response.data['message'] ?? 'Failed to reject quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isApproving: false);
    }
  }

  Future<Quote?> convertToProposal(String id, String proposalId) async {
    try {
      final response = await _dio.put(
        '/v1/nawassco/sales/quotes/$id/convert',
        data: {'proposalId': proposalId},
      );

      if (response.data['success'] == true) {
        final updatedQuote = Quote.fromJson(response.data['data']);

        final updatedQuotes = state.quotes.map((quote) {
          return quote.id == id ? updatedQuote : quote;
        }).toList();

        state = state.copyWith(
          quotes: updatedQuotes,
          selectedQuote: updatedQuote,
        );

        _showSuccess('Quote converted to proposal');
        return updatedQuote;
      } else {
        _showError(response.data['message'] ?? 'Failed to convert quote');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/quotes/stats');

      if (response.data['success'] == true) {
        final stats = QuoteStats.fromJson(response.data['data']);
        state = state.copyWith(stats: stats);
      }
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  // -----------------------------------------------------------------
  // HELPER METHODS
  // -----------------------------------------------------------------
  double _calculateSubtotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
        final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
        final discount = (item['discount'] as num?)?.toDouble() ?? 0;
        return sum + (quantity * unitPrice * (1 - discount / 100));
      }
      return sum;
    });
  }

  double _calculateTotalAmount(Map<String, dynamic> data) {
    final items = data['items'] as List<dynamic>? ?? [];
    final subtotal = _calculateSubtotal(items);

    final taxAmount = items.fold(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
        final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
        final discount = (item['discount'] as num?)?.toDouble() ?? 0;
        final taxRate = (item['taxRate'] as num?)?.toDouble() ?? 0;
        final itemTotal = quantity * unitPrice * (1 - discount / 100);
        return sum + (itemTotal * (taxRate / 100));
      }
      return sum;
    });

    final discountAmount = (data['discountAmount'] as num?)?.toDouble() ?? 0;

    return subtotal + taxAmount - discountAmount;
  }

  // -----------------------------------------------------------------
  // STATE MANAGEMENT
  // -----------------------------------------------------------------
  void showQuoteForm({Quote? quote}) {
    state = state.copyWith(
      selectedQuote: quote,
    );
  }

  void showQuoteDetails(Quote quote) {
    state = state.copyWith(
      selectedQuote: quote,
    );
  }

  void showQuoteStats() {
    state = state.copyWith(
      showStats: true,
    );
  }

  void showQuoteList() {
    state = state.copyWith(
      showStats: false,
    );
  }

  void selectQuote(Quote? quote) {
    state = state.copyWith(selectedQuote: quote);
  }

  void updateFilters(QuoteFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      quotes: [],
    );
    loadQuotes(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const QuoteFilters(),
      currentPage: 1,
      quotes: [],
    );
    loadQuotes(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadQuotes();
    }
  }

  void refreshData() {
    state = state.copyWith(
      currentPage: 1,
      quotes: [],
    );
    loadQuotes(refresh: true);
    loadStats();
  }

  // -----------------------------------------------------------------
  // ERROR HANDLING
  // -----------------------------------------------------------------
  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldKey);
  }

  void _showError(String message) {
    state = state.copyWith(error: message);
    ToastUtils.showErrorToast(message, key: _scaffoldKey);
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Quote not found.';
      } else if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please check your connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
    }

    state = state.copyWith(error: errorMessage);
    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================
final quoteProvider = StateNotifierProvider<QuoteProvider, QuoteState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return QuoteProvider(dio, scaffoldMessengerKey);
  },
);