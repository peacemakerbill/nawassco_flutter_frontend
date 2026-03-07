import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/sewerage_bill_model.dart';

class SewerageBillState {
  final List<SewerageBill> bills;
  final SewerageBill? selectedBill;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isApplyingPayment;
  final String? error;
  final BillingStatistics? statistics;
  final Map<String, dynamic> filters;

  SewerageBillState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isApplyingPayment = false,
    this.error,
    this.statistics,
    this.filters = const {},
  });

  SewerageBillState copyWith({
    List<SewerageBill>? bills,
    SewerageBill? selectedBill,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isApplyingPayment,
    String? error,
    BillingStatistics? statistics,
    Map<String, dynamic>? filters,
  }) {
    return SewerageBillState(
      bills: bills ?? this.bills,
      selectedBill: selectedBill ?? this.selectedBill,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isApplyingPayment: isApplyingPayment ?? this.isApplyingPayment,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
      filters: filters ?? this.filters,
    );
  }
}

class SewerageBillProvider extends StateNotifier<SewerageBillState> {
  final Dio dio;
  final Ref ref;

  SewerageBillProvider(this.dio, this.ref) : super(SewerageBillState());

  bool get isMounted => mounted;

  // Get authenticated user email
  String? get _currentUserEmail {
    final authState = ref.read(authProvider);
    return authState.user?['email'];
  }

  // Check if user is staff
  bool get _isStaff {
    final authState = ref.read(authProvider);
    return authState.hasAnyRole([
      'Admin',
      'Manager',
      'Accounts',
      'SalesAgent',
    ]);
  }

  // Get all bills (filtered by email for non-staff users)
  Future<void> getBills({Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Build query parameters
      final queryParams = <String, dynamic>{};

      // If user is not staff, only show their bills
      if (!_isStaff && _currentUserEmail != null) {
        queryParams['customerEmail'] = _currentUserEmail;
      }

      // Apply additional filters
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response =
          await dio.get('/v1/nawassco/billing/sewerage_bill', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final billsData = response.data['data'] as List;
        final bills =
            billsData.map((bill) => SewerageBill.fromJson(bill)).toList();

        state = state.copyWith(
          bills: bills,
          isLoading: false,
          filters: filters ?? {},
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bills');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e.toString());
    }
  }

  // Get bill by ID
  Future<SewerageBill?> getBillById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/billing/sewerage_bill/$id');

      if (response.data['success'] == true) {
        final bill = SewerageBill.fromJson(response.data['data']);
        state = state.copyWith(
          selectedBill: bill,
          isLoading: false,
        );
        return bill;
      } else {
        throw Exception(response.data['message'] ?? 'Bill not found');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e.toString());
      return null;
    }
  }

  // Get bill by service number
  Future<SewerageBill?> getBillByServiceNumber(String serviceNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/billing/sewerage_bill/service/$serviceNumber');

      if (response.data['success'] == true) {
        final bill = SewerageBill.fromJson(response.data['data']);
        state = state.copyWith(
          selectedBill: bill,
          isLoading: false,
        );
        return bill;
      } else {
        throw Exception(response.data['message'] ?? 'Bill not found');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e.toString());
      return null;
    }
  }

  // Create new bill (staff only)
  Future<bool> createBill(CreateBillDto billData) async {
    if (!_isStaff) {
      _showError('Only staff members can create bills');
      return false;
    }

    try {
      state = state.copyWith(isCreating: true, error: null);

      final response =
          await dio.post('/v1/nawassco/billing/sewerage_bill', data: billData.toJson());

      if (response.data['success'] == true) {
        final newBill = SewerageBill.fromJson(response.data['data']);
        state = state.copyWith(
          bills: [newBill, ...state.bills],
          isCreating: false,
        );
        ToastUtils.showSuccessToast(
          'Bill created successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isCreating: false,
      );
      _showError(e.toString());
      return false;
    }
  }

  // Update bill (staff only)
  Future<bool> updateBill(String id, UpdateBillDto billData) async {
    if (!_isStaff) {
      _showError('Only staff members can update bills');
      return false;
    }

    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response =
          await dio.put('/v1/nawassco/billing/sewerage_bill/$id', data: billData.toJson());

      if (response.data['success'] == true) {
        final updatedBill = SewerageBill.fromJson(response.data['data']);

        // Update in bills list
        final updatedBills = state.bills.map((bill) {
          return bill.id == id ? updatedBill : bill;
        }).toList();

        state = state.copyWith(
          bills: updatedBills,
          selectedBill:
              state.selectedBill?.id == id ? updatedBill : state.selectedBill,
          isUpdating: false,
        );

        ToastUtils.showSuccessToast(
          'Bill updated successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isUpdating: false,
      );
      _showError(e.toString());
      return false;
    }
  }

  // Apply payment to bill
  Future<bool> applyPayment(String id, PaymentDto payment) async {
    try {
      state = state.copyWith(isApplyingPayment: true, error: null);

      final response = await dio.patch('/v1/nawassco/billing/sewerage_bill/$id/payment',
          data: payment.toJson());

      if (response.data['success'] == true) {
        final updatedBill = SewerageBill.fromJson(response.data['data']);

        // Update in bills list
        final updatedBills = state.bills.map((bill) {
          return bill.id == id ? updatedBill : bill;
        }).toList();

        state = state.copyWith(
          bills: updatedBills,
          selectedBill:
              state.selectedBill?.id == id ? updatedBill : state.selectedBill,
          isApplyingPayment: false,
        );

        ToastUtils.showSuccessToast(
          'Payment applied successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to apply payment');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isApplyingPayment: false,
      );
      _showError(e.toString());
      return false;
    }
  }

  // Calculate penalty
  Future<double> calculatePenalty(String id,
      [double penaltyRate = 0.02]) async {
    try {
      final response = await dio.post(
        '/v1/nawassco/billing/sewerage_bill/$id/calculate-penalty',
        data: {'penaltyRate': penaltyRate},
      );

      if (response.data['success'] == true) {
        return (response.data['data']['penalty'] ?? 0).toDouble();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to calculate penalty');
      }
    } catch (e) {
      _showError(e.toString());
      return 0;
    }
  }

  // Cancel bill (staff only)
  Future<bool> cancelBill(String id) async {
    if (!_isStaff) {
      _showError('Only staff members can cancel bills');
      return false;
    }

    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch('/v1/nawassco/billing/sewerage_bill/$id/cancel');

      if (response.data['success'] == true) {
        final cancelledBill = SewerageBill.fromJson(response.data['data']);

        // Update in bills list
        final updatedBills = state.bills.map((bill) {
          return bill.id == id ? cancelledBill : bill;
        }).toList();

        state = state.copyWith(
          bills: updatedBills,
          selectedBill:
              state.selectedBill?.id == id ? cancelledBill : state.selectedBill,
          isUpdating: false,
        );

        ToastUtils.showSuccessToast(
          'Bill cancelled successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to cancel bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isUpdating: false,
      );
      _showError(e.toString());
      return false;
    }
  }

  // Delete bill (admin/manager only)
  Future<bool> deleteBill(String id) async {
    final authState = ref.read(authProvider);
    if (!authState.hasAnyRole(['Admin', 'Manager'])) {
      _showError('Only administrators and managers can delete bills');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/billing/sewerage_bill/$id');

      if (response.data['success'] == true) {
        // Remove from bills list
        final updatedBills =
            state.bills.where((bill) => bill.id != id).toList();

        state = state.copyWith(
          bills: updatedBills,
          selectedBill:
              state.selectedBill?.id == id ? null : state.selectedBill,
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Bill deleted successfully',
          key: scaffoldMessengerKey,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e.toString());
      return false;
    }
  }

  // Get billing statistics (staff only)
  Future<void> getStatistics() async {
    if (!_isStaff) return;

    try {
      final response = await dio.get('/v1/nawassco/billing/sewerage_bill/statistics');

      if (response.data['success'] == true) {
        final stats = BillingStatistics.fromJson(response.data['data']);
        state = state.copyWith(statistics: stats);
      }
    } catch (e) {
      print('Failed to fetch statistics: $e');
    }
  }

  // Get overdue bills (staff only)
  Future<List<SewerageBill>> getOverdueBills() async {
    if (!_isStaff) return [];

    try {
      final response = await dio.get('/v1/nawassco/billing/sewerage_bill/overdue');

      if (response.data['success'] == true) {
        final billsData = response.data['data'] as List;
        return billsData.map((bill) => SewerageBill.fromJson(bill)).toList();
      }
      return [];
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  // Search bills
  Future<List<SewerageBill>> searchBills(String query) async {
    try {
      final response = await dio.get('/v1/nawassco/billing/sewerage_bill/search/$query');

      if (response.data['success'] == true) {
        final billsData = response.data['data'] as List;
        return billsData.map((bill) => SewerageBill.fromJson(bill)).toList();
      }
      return [];
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  // Clear selected bill
  void clearSelectedBill() {
    state = state.copyWith(selectedBill: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final sewerageBillProvider =
    StateNotifierProvider<SewerageBillProvider, SewerageBillState>((ref) {
  final dio = ref.read(dioProvider);
  return SewerageBillProvider(dio, ref);
});
