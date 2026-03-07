import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/water_bill_model.dart';

class WaterBillState {
  final List<WaterBill> bills;
  final WaterBill? selectedBill;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> stats;
  final bool isManagementView;

  WaterBillState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.stats = const {},
    this.isManagementView = false,
  });

  WaterBillState copyWith({
    List<WaterBill>? bills,
    WaterBill? selectedBill,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? stats,
    bool? isManagementView,
  }) {
    return WaterBillState(
      bills: bills ?? this.bills,
      selectedBill: selectedBill ?? this.selectedBill,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      stats: stats ?? this.stats,
      isManagementView: isManagementView ?? this.isManagementView,
    );
  }
}

class WaterBillProvider extends StateNotifier<WaterBillState> {
  final Ref ref;
  final Dio dio;

  WaterBillProvider(this.ref, this.dio) : super(WaterBillState());

  // Switch between user view and management view
  void toggleView(bool isManagement) {
    state = state.copyWith(isManagementView: isManagement);
    if (isManagement) {
      fetchAllBills();
    } else {
      fetchUserBills();
    }
  }

  // Fetch bills for current user (matches email)
  Future<void> fetchUserBills() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated || authState.user?['email'] == null) {
        throw Exception('User not authenticated');
      }

      final userEmail = authState.user!['email'];
      final response = await dio.get('/water-bills/customer/$userEmail');

      if (response.data['success'] == true) {
        final billsData = response.data['data'] as List;
        final bills = billsData.map((json) => WaterBill.fromJson(json)).toList();
        state = state.copyWith(bills: bills, isLoading: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bills');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        bills: [],
      );
    }
  }

  // Fetch all bills (for management)
  Future<void> fetchAllBills({Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      Map<String, dynamic> queryParams = {};
      if (filters != null) {
        queryParams.addAll(filters);
      }
      if (state.filters.isNotEmpty) {
        queryParams.addAll(state.filters);
      }

      final response = await dio.get('/water-bills', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final billsData = response.data['bills'] as List;
        final bills = billsData.map((json) => WaterBill.fromJson(json)).toList();
        state = state.copyWith(bills: bills, isLoading: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bills');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        bills: [],
      );
    }
  }

  // Fetch bill by ID
  Future<WaterBill?> fetchBillById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/water-bills/$id');

      if (response.data['success'] == true) {
        final bill = WaterBill.fromJson(response.data['data']);
        state = state.copyWith(selectedBill: bill, isLoading: false);
        return bill;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  // Create new bill
  Future<bool> createBill(WaterBill bill) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/water-bills', data: bill.toJson());

      if (response.data['success'] == true) {
        final newBill = WaterBill.fromJson(response.data['data']);
        state = state.copyWith(
          bills: [newBill, ...state.bills],
          isLoading: false,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Update bill
  Future<bool> updateBill(String id, WaterBill bill) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put('/water-bills/$id', data: bill.toJson());

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == id);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update bill');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Delete bill
  Future<bool> deleteBill(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/water-bills/$id');

      if (response.data['success'] == true) {
        state = state.copyWith(
          bills: state.bills.where((b) => b.id != id).toList(),
          selectedBill: state.selectedBill?.id == id ? null : state.selectedBill,
          isLoading: false,
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
      return false;
    }
  }

  // Add adjustment to bill
  Future<bool> addAdjustment(String billId, Adjustment adjustment) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/water-bills/$billId/adjustments',
        data: adjustment.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add adjustment');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Apply discount
  Future<bool> applyDiscount(String billId, double amount, String reason) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/water-bills/$billId/discount',
        data: {'discountAmount': amount, 'reason': reason},
      );

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to apply discount');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Mark as disputed
  Future<bool> markAsDisputed(String billId, String reason) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/water-bills/$billId/dispute',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark as disputed');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Resolve dispute
  Future<bool> resolveDispute(String billId, bool resolved, String notes) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/water-bills/$billId/dispute/resolve',
        data: {'resolved': resolved, 'notes': notes},
      );

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to resolve dispute');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Verify reading
  Future<bool> verifyReading(String billId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/water-bills/$billId/verify-reading');

      if (response.data['success'] == true) {
        final updatedBill = WaterBill.fromJson(response.data['data']);
        final index = state.bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          final newBills = List<WaterBill>.from(state.bills);
          newBills[index] = updatedBill;
          state = state.copyWith(
            bills: newBills,
            selectedBill: updatedBill,
            isLoading: false,
          );
        }
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to verify reading');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Get statistics
  Future<void> fetchStatistics({Map<String, dynamic>? filters}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/water-bills/stats/summary',
        queryParameters: filters,
      );

      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: response.data['data'],
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Filter bills
  void applyFilters(Map<String, dynamic> filters) {
    state = state.copyWith(filters: filters);
    if (state.isManagementView) {
      fetchAllBills(filters: filters);
    } else {
      fetchUserBills();
    }
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(filters: {});
    if (state.isManagementView) {
      fetchAllBills();
    } else {
      fetchUserBills();
    }
  }

  // Select bill
  void selectBill(WaterBill? bill) {
    state = state.copyWith(selectedBill: bill);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final waterBillProvider = StateNotifierProvider<WaterBillProvider, WaterBillState>((ref) {
  final dio = ref.read(dioProvider);
  return WaterBillProvider(ref, dio);
});