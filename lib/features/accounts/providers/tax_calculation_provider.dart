import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/tax_calculation_model.dart';
import '../../../../core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';

class TaxCalculationState {
  final List<TaxCalculation> calculations;
  final TaxCalculation? selectedCalculation;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final Map<String, dynamic>? summary;

  TaxCalculationState({
    this.calculations = const [],
    this.selectedCalculation,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.summary,
  });

  TaxCalculationState copyWith({
    List<TaxCalculation>? calculations,
    TaxCalculation? selectedCalculation,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? summary,
  }) {
    return TaxCalculationState(
      calculations: calculations ?? this.calculations,
      selectedCalculation: selectedCalculation ?? this.selectedCalculation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      summary: summary ?? this.summary,
    );
  }
}

class TaxCalculationProvider extends StateNotifier<TaxCalculationState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  TaxCalculationProvider(this.dio, this.scaffoldMessengerKey)
      : super(TaxCalculationState());

  // =============== GET OPERATIONS ===============

  // Get all tax calculations with filters
  Future<void> getTaxCalculations({
    int page = 1,
    int limit = 20,
    String? taxType,
    String? status,
    String? taxPeriod,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (taxType != null && taxType.isNotEmpty) 'taxType': taxType,
        if (status != null && status.isNotEmpty) 'status': status,
        if (taxPeriod != null && taxPeriod.isNotEmpty) 'taxPeriod': taxPeriod,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/tax-calculations',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['result'];
        final calculations = (data['taxCalculations'] as List)
            .map((json) => TaxCalculation.fromJson(json))
            .toList();

        state = state.copyWith(
          calculations: calculations,
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch tax calculations');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // Get tax calculation by ID
  Future<void> getTaxCalculationById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/accounts/tax-calculations/$id');

      if (response.data['success'] == true) {
        final calculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);
        state = state.copyWith(
          selectedCalculation: calculation,
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch tax calculation');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // =============== CREATE OPERATIONS ===============

  // Create tax calculation
  Future<bool> createTaxCalculation(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/accounts/tax-calculations', data: data);

      if (response.data['success'] == true) {
        final calculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        state = state.copyWith(
          calculations: [calculation, ...state.calculations],
          selectedCalculation: calculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax calculation created successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to create tax calculation');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // =============== UPDATE OPERATIONS ===============

  // Update tax calculation
  Future<bool> updateTaxCalculation(
      String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put('/v1/nawassco/accounts/tax-calculations/$id', data: data);

      if (response.data['success'] == true) {
        final updatedCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? updatedCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: updatedCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax calculation updated successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to update tax calculation');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Calculate tax
  Future<bool> calculateTax(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/accounts/tax-calculations/$id/calculate');

      if (response.data['success'] == true) {
        final calculatedCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? calculatedCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: calculatedCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax calculated successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to calculate tax');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Approve tax calculation
  Future<bool> approveTaxCalculation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/accounts/tax-calculations/$id/approve');

      if (response.data['success'] == true) {
        final approvedCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? approvedCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: approvedCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax calculation approved!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to approve tax calculation');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // File tax
  Future<bool> fileTax(String id, String filingReference) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/accounts/tax-calculations/$id/file', data: {
        'filingReference': filingReference,
      });

      if (response.data['success'] == true) {
        final filedCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? filedCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: filedCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax filed successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to file tax');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Record payment
  Future<bool> recordPayment(
      String id, double paidAmount, DateTime paymentDate) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
      await dio.patch('/v1/nawassco/accounts/tax-calculations/$id/record-payment', data: {
        'paidAmount': paidAmount,
        'paymentDate': paymentDate.toIso8601String(),
      });

      if (response.data['success'] == true) {
        final paidCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? paidCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: paidCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Payment recorded successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to record payment');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // =============== TRANSACTION OPERATIONS ===============

  // Add transaction to calculation
  Future<bool> addTransaction(String calculationId, Map<String, dynamic> transactionData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current calculation
      final calculation = state.calculations.firstWhere(
            (calc) => calc.id == calculationId,
        orElse: () => throw Exception('Calculation not found'),
      );

      // Create updated calculation with new transaction
      final newTransaction = TaxTransaction.fromJson(transactionData);
      final updatedTransactions = [...calculation.transactions, newTransaction];

      // Update via API - only send transactions
      final response = await dio.put(
        '/v1/nawassco/accounts/tax-calculations/$calculationId',
        data: {
          'transactions': updatedTransactions.map((tx) => tx.toJson()).toList(),
        },
      );

      if (response.data['success'] == true) {
        final updatedCalc = TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == calculationId ? updatedCalc : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: updatedCalc,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Transaction added successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add transaction');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Update transaction
  Future<bool> updateTransaction(String calculationId, String transactionId, Map<String, dynamic> transactionData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current calculation
      final calculation = state.calculations.firstWhere(
            (calc) => calc.id == calculationId,
        orElse: () => throw Exception('Calculation not found'),
      );

      // Update transaction in list
      final updatedTransactions = calculation.transactions.map((tx) {
        // Create unique ID for comparison
        final txId = '${tx.transactionDate.millisecondsSinceEpoch}-${tx.reference.hashCode}';
        return txId == transactionId ? TaxTransaction.fromJson(transactionData) : tx;
      }).toList();

      // Update via API
      final response = await dio.put(
        '/v1/nawassco/accounts/tax-calculations/$calculationId',
        data: {
          'transactions': updatedTransactions.map((tx) => tx.toJson()).toList(),
        },
      );

      if (response.data['success'] == true) {
        final updatedCalc = TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == calculationId ? updatedCalc : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: updatedCalc,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Transaction updated successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update transaction');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String calculationId, String transactionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current calculation
      final calculation = state.calculations.firstWhere(
            (calc) => calc.id == calculationId,
        orElse: () => throw Exception('Calculation not found'),
      );

      // Remove transaction from list
      final updatedTransactions = calculation.transactions.where((tx) {
        final txId = '${tx.transactionDate.millisecondsSinceEpoch}-${tx.reference.hashCode}';
        return txId != transactionId;
      }).toList();

      // Update via API
      final response = await dio.put(
        '/v1/nawassco/accounts/tax-calculations/$calculationId',
        data: {
          'transactions': updatedTransactions.map((tx) => tx.toJson()).toList(),
        },
      );

      if (response.data['success'] == true) {
        final updatedCalc = TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == calculationId ? updatedCalc : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: updatedCalc,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Transaction deleted successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete transaction');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // =============== DELETE OPERATIONS ===============

  // Delete tax calculation
  Future<bool> deleteTaxCalculation(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/accounts/tax-calculations/$id');

      if (response.data['success'] == true) {
        final updatedCalculations = state.calculations
            .where((calc) => calc.id != id)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: null,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Tax calculation deleted successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to delete tax calculation');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // =============== SUMMARY OPERATIONS ===============

  // Get tax summary
  Future<void> getTaxSummary(
      {String? startDate, String? endDate, String? taxType}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
        if (taxType != null && taxType.isNotEmpty) 'taxType': taxType,
      };

      final response = await dio.get(
        '/v1/nawassco/accounts/tax-calculations/summary',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final summary = response.data['data']['summary'] as Map<String, dynamic>;
        state = state.copyWith(
          summary: summary,
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch tax summary');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  // =============== DOCUMENT OPERATIONS ===============

  // Upload tax document
  Future<bool> uploadTaxDocument(
      String id, List<int> fileBytes, String fileName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final formData = FormData.fromMap({
        'document': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response =
      await dio.post('/v1/nawassco/accounts/tax-calculations/$id/upload', data: formData);

      if (response.data['success'] == true) {
        final updatedCalculation =
        TaxCalculation.fromJson(response.data['data']['taxCalculation']);

        final updatedCalculations = state.calculations
            .map((calc) => calc.id == id ? updatedCalculation : calc)
            .toList();

        state = state.copyWith(
          calculations: updatedCalculations,
          selectedCalculation: updatedCalculation,
          isLoading: false,
          error: null,
        );

        ToastUtils.showSuccessToast(
          'Document uploaded successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to upload document');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? e.message,
        isLoading: false,
      );
      _showError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
      return false;
    }
  }

  // =============== UTILITY METHODS ===============

  // Clear selected calculation
  void clearSelectedCalculation() {
    state = state.copyWith(selectedCalculation: null);
  }

  // Update filters
  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await getTaxCalculations();
    await getTaxSummary();
  }

  // Helper method to show errors
  void _showError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        errorMessage = responseData['message'];
      } else {
        errorMessage = error.message ?? 'Network error occurred';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
  }

  // Helper to get calculation by ID from local state
  TaxCalculation? getCalculationById(String id) {
    try {
      return state.calculations.firstWhere((calc) => calc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to validate if calculation can be edited
  bool canEditCalculation(String id) {
    final calculation = getCalculationById(id);
    return calculation != null && calculation.canEdit;
  }

  // Helper to validate if calculation can be calculated
  bool canCalculateTax(String id) {
    final calculation = getCalculationById(id);
    return calculation != null && calculation.canCalculate;
  }

  // Helper to validate if calculation can be approved
  bool canApproveCalculation(String id) {
    final calculation = getCalculationById(id);
    return calculation != null && calculation.canApprove;
  }

  // Helper to validate if calculation can be filed
  bool canFileTax(String id) {
    final calculation = getCalculationById(id);
    return calculation != null && calculation.canFile;
  }

  // Helper to validate if payment can be recorded
  bool canRecordPayment(String id) {
    final calculation = getCalculationById(id);
    return calculation != null && calculation.canRecordPayment;
  }
}

// Provider
final taxCalculationProvider =
StateNotifierProvider<TaxCalculationProvider, TaxCalculationState>((ref) {
  final dio = ref.read(dioProvider);
  return TaxCalculationProvider(dio, scaffoldMessengerKey);
});