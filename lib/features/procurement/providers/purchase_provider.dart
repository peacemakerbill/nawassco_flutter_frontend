import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../domain/models/purchase_order.dart';
import '../domain/models/purchase_requisition.dart';

// Purchase Order Providers
final purchaseOrderProvider = StateNotifierProvider<PurchaseOrderNotifier, AsyncValue<List<PurchaseOrder>>>((ref) {
  return PurchaseOrderNotifier(ref.read(dioProvider));
});

final purchaseOrderDetailProvider = StateNotifierProvider.family<PurchaseOrderDetailNotifier, AsyncValue<PurchaseOrder?>, String>((ref, id) {
  return PurchaseOrderDetailNotifier(ref.read(dioProvider), id);
});

final purchaseOrderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/v1/nawassco/procurement/purchase-orders/stats');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('Failed to load purchase order statistics');
  } catch (e) {
    throw Exception('Failed to load purchase order statistics: $e');
  }
});

final overduePurchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/v1/nawassco/procurement/purchase-orders/overdue');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PurchaseOrder.fromJson(json)).toList();
    }
    throw Exception('Failed to load overdue purchase orders');
  } catch (e) {
    throw Exception('Failed to load overdue purchase orders: $e');
  }
});

class PurchaseOrderNotifier extends StateNotifier<AsyncValue<List<PurchaseOrder>>> {
  final Dio _dio;

  PurchaseOrderNotifier(this._dio) : super(const AsyncValue.loading()) {
    loadPurchaseOrders();
  }

  Future<void> loadPurchaseOrders({Map<String, dynamic>? queryParams}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(
        '/v1/nawassco/procurement/purchase-orders',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final purchaseOrders = data.map((json) => PurchaseOrder.fromJson(json)).toList();
        state = AsyncValue.data(purchaseOrders);
      } else {
        throw Exception('Failed to load purchase orders');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<PurchaseOrder> createPurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/purchase-orders',
        data: purchaseOrder.toJson(),
      );

      if (response.data['success'] == true) {
        final newPO = PurchaseOrder.fromJson(response.data['data']);

        // Update the list
        state.whenData((purchaseOrders) {
          state = AsyncValue.data([newPO, ...purchaseOrders]);
        });

        return newPO;
      }
      throw Exception('Failed to create purchase order');
    } catch (e) {
      throw Exception('Failed to create purchase order: $e');
    }
  }

  Future<void> deletePurchaseOrder(String id) async {
    try {
      final response = await _dio.delete('/v1/nawassco/procurement/purchase-orders/$id');

      if (response.data['success'] == true) {
        // Remove from the list
        state.whenData((purchaseOrders) {
          state = AsyncValue.data(purchaseOrders.where((po) => po.id != id).toList());
        });
      } else {
        throw Exception('Failed to delete purchase order');
      }
    } catch (e) {
      throw Exception('Failed to delete purchase order: $e');
    }
  }
}

class PurchaseOrderDetailNotifier extends StateNotifier<AsyncValue<PurchaseOrder?>> {
  final Dio _dio;
  final String _id;

  PurchaseOrderDetailNotifier(this._dio, this._id) : super(const AsyncValue.loading()) {
    loadPurchaseOrder();
  }

  Future<void> loadPurchaseOrder() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/v1/nawassco/procurement/purchase-orders/$_id');

      if (response.data['success'] == true) {
        final purchaseOrder = PurchaseOrder.fromJson(response.data['data']);
        state = AsyncValue.data(purchaseOrder);
      } else {
        throw Exception('Failed to load purchase order');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<PurchaseOrder> updatePurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/procurement/purchase-orders/$_id',
        data: purchaseOrder.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedPO = PurchaseOrder.fromJson(response.data['data']);
        state = AsyncValue.data(updatedPO);
        return updatedPO;
      }
      throw Exception('Failed to update purchase order');
    } catch (e) {
      throw Exception('Failed to update purchase order: $e');
    }
  }

  Future<PurchaseOrder> processPOAction(String action, {String? comments}) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/purchase-orders/$_id/action',
        data: {'action': action, 'comments': comments},
      );

      if (response.data['success'] == true) {
        final updatedPO = PurchaseOrder.fromJson(response.data['data']);
        state = AsyncValue.data(updatedPO);
        return updatedPO;
      }
      throw Exception('Failed to process PO action');
    } catch (e) {
      throw Exception('Failed to process PO action: $e');
    }
  }

  Future<PurchaseOrder> receiveItems(
      List<Map<String, dynamic>> items,
      DateTime receiptDate,
      String receivedBy,
      ) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/purchase-orders/$_id/receive',
        data: {
          'items': items,
          'receiptDate': receiptDate.toIso8601String(),
          'receivedBy': receivedBy,
        },
      );

      if (response.data['success'] == true) {
        final updatedPO = PurchaseOrder.fromJson(response.data['data']);
        state = AsyncValue.data(updatedPO);
        return updatedPO;
      }
      throw Exception('Failed to receive items');
    } catch (e) {
      throw Exception('Failed to receive items: $e');
    }
  }

  Future<PurchaseOrder> addInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/purchase-orders/$_id/invoices',
        data: invoiceData,
      );

      if (response.data['success'] == true) {
        final updatedPO = PurchaseOrder.fromJson(response.data['data']);
        state = AsyncValue.data(updatedPO);
        return updatedPO;
      }
      throw Exception('Failed to add invoice');
    } catch (e) {
      throw Exception('Failed to add invoice: $e');
    }
  }
}

// Purchase Requisition Providers
final purchaseRequisitionProvider = StateNotifierProvider<PurchaseRequisitionNotifier, AsyncValue<List<PurchaseRequisition>>>((ref) {
  return PurchaseRequisitionNotifier(ref.read(dioProvider));
});

final purchaseRequisitionDetailProvider = StateNotifierProvider.family<PurchaseRequisitionDetailNotifier, AsyncValue<PurchaseRequisition?>, String>((ref, id) {
  return PurchaseRequisitionDetailNotifier(ref.read(dioProvider), id);
});

final myRequisitionsProvider = StateNotifierProvider<MyRequisitionsNotifier, AsyncValue<List<PurchaseRequisition>>>((ref) {
  return MyRequisitionsNotifier(ref.read(dioProvider));
});

final requisitionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/v1/nawassco/procurement/requisitions/stats');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('Failed to load requisition statistics');
  } catch (e) {
    throw Exception('Failed to load requisition statistics: $e');
  }
});

final urgentRequisitionsProvider = FutureProvider<List<PurchaseRequisition>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/v1/nawassco/procurement/requisitions/urgent');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PurchaseRequisition.fromJson(json)).toList();
    }
    throw Exception('Failed to load urgent requisitions');
  } catch (e) {
    throw Exception('Failed to load urgent requisitions: $e');
  }
});

class PurchaseRequisitionNotifier extends StateNotifier<AsyncValue<List<PurchaseRequisition>>> {
  final Dio _dio;

  PurchaseRequisitionNotifier(this._dio) : super(const AsyncValue.loading()) {
    loadRequisitions();
  }

  Future<void> loadRequisitions({Map<String, dynamic>? queryParams}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(
        '/v1/nawassco/procurement/requisitions',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final requisitions = data.map((json) => PurchaseRequisition.fromJson(json)).toList();
        state = AsyncValue.data(requisitions);
      } else {
        throw Exception('Failed to load requisitions');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<PurchaseRequisition> createRequisition(PurchaseRequisition requisition) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/requisitions',
        data: requisition.toJson(),
      );

      if (response.data['success'] == true) {
        final newRequisition = PurchaseRequisition.fromJson(response.data['data']);

        // Update the list
        state.whenData((requisitions) {
          state = AsyncValue.data([newRequisition, ...requisitions]);
        });

        return newRequisition;
      }
      throw Exception('Failed to create requisition');
    } catch (e) {
      throw Exception('Failed to create requisition: $e');
    }
  }

  Future<void> deleteRequisition(String id) async {
    try {
      final response = await _dio.delete('/v1/nawassco/procurement/requisitions/$id');

      if (response.data['success'] == true) {
        // Remove from the list
        state.whenData((requisitions) {
          state = AsyncValue.data(requisitions.where((req) => req.id != id).toList());
        });
      } else {
        throw Exception('Failed to delete requisition');
      }
    } catch (e) {
      throw Exception('Failed to delete requisition: $e');
    }
  }
}

class PurchaseRequisitionDetailNotifier extends StateNotifier<AsyncValue<PurchaseRequisition?>> {
  final Dio _dio;
  final String _id;

  PurchaseRequisitionDetailNotifier(this._dio, this._id) : super(const AsyncValue.loading()) {
    loadRequisition();
  }

  Future<void> loadRequisition() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/v1/nawassco/procurement/requisitions/$_id');

      if (response.data['success'] == true) {
        final requisition = PurchaseRequisition.fromJson(response.data['data']);
        state = AsyncValue.data(requisition);
      } else {
        throw Exception('Failed to load requisition');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<PurchaseRequisition> updateRequisition(PurchaseRequisition requisition) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/procurement/requisitions/$_id',
        data: requisition.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedRequisition = PurchaseRequisition.fromJson(response.data['data']);
        state = AsyncValue.data(updatedRequisition);
        return updatedRequisition;
      }
      throw Exception('Failed to update requisition');
    } catch (e) {
      throw Exception('Failed to update requisition: $e');
    }
  }

  Future<PurchaseRequisition> submitForApproval() async {
    try {
      final response = await _dio.post('/v1/nawassco/procurement/requisitions/$_id/submit');

      if (response.data['success'] == true) {
        final updatedRequisition = PurchaseRequisition.fromJson(response.data['data']);
        state = AsyncValue.data(updatedRequisition);
        return updatedRequisition;
      }
      throw Exception('Failed to submit requisition for approval');
    } catch (e) {
      throw Exception('Failed to submit requisition for approval: $e');
    }
  }

  Future<PurchaseRequisition> processApproval(String action, {String? comments}) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/requisitions/$_id/action',
        data: {'action': action, 'comments': comments},
      );

      if (response.data['success'] == true) {
        final updatedRequisition = PurchaseRequisition.fromJson(response.data['data']);
        state = AsyncValue.data(updatedRequisition);
        return updatedRequisition;
      }
      throw Exception('Failed to process approval');
    } catch (e) {
      throw Exception('Failed to process approval: $e');
    }
  }
}

class MyRequisitionsNotifier extends StateNotifier<AsyncValue<List<PurchaseRequisition>>> {
  final Dio _dio;

  MyRequisitionsNotifier(this._dio) : super(const AsyncValue.loading()) {
    loadMyRequisitions();
  }

  Future<void> loadMyRequisitions({Map<String, dynamic>? queryParams}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(
        '/v1/nawassco/procurement/requisitions/my-requisitions',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final requisitions = data.map((json) => PurchaseRequisition.fromJson(json)).toList();
        state = AsyncValue.data(requisitions);
      } else {
        throw Exception('Failed to load my requisitions');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}