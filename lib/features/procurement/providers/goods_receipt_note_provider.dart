import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../domain/models/goods_receipt_note.dart';

class GoodsReceiptNoteNotifier
    extends StateNotifier<AsyncValue<List<GoodsReceiptNote>>> {
  final Ref ref;
  final Dio _dio;

  GoodsReceiptNoteNotifier(this.ref)
      : _dio = ref.read(dioProvider),
        super(const AsyncValue.loading());

  // Get all GRNs
  Future<void> getGRNs({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? purchaseOrder,
    String? supplier,
    String? qualityStatus,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/v1/nawassco/procurement/goods-receipt-notes', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'status': status,
        'purchaseOrder': purchaseOrder,
        'supplier': supplier,
        'qualityStatus': qualityStatus,
      });

      final data = response.data['data'];
      List<GoodsReceiptNote> grns = [];

      if (data is List) {
        grns = data.map((json) => GoodsReceiptNote.fromJson(json)).toList();
      }

      state = AsyncValue.data(grns);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Get GRN by ID
  Future<GoodsReceiptNote> getGRNById(String id) async {
    try {
      final response = await _dio.get('/v1/nawassco/procurement/goods-receipt-notes/$id');
      return GoodsReceiptNote.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Create GRN
  Future<GoodsReceiptNote> createGRN(GoodsReceiptNote grn) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/goods-receipt-notes',
        data: grn.toJson(),
      );
      final newGRN = GoodsReceiptNote.fromJson(response.data['data']);

      // Update state with new GRN
      if (state.hasValue) {
        final currentGRNs = state.value ?? [];
        state = AsyncValue.data([newGRN, ...currentGRNs]);
      }

      return newGRN;
    } catch (e) {
      rethrow;
    }
  }

  // Update GRN
  Future<GoodsReceiptNote> updateGRN(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/procurement/goods-receipt-notes/$id',
        data: data,
      );
      final updatedGRN = GoodsReceiptNote.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentGRNs = state.value ?? [];
        final index = currentGRNs.indexWhere((g) => g.id == id);
        if (index != -1) {
          final newGRNs = List<GoodsReceiptNote>.from(currentGRNs);
          newGRNs[index] = updatedGRN;
          state = AsyncValue.data(newGRNs);
        }
      }

      return updatedGRN;
    } catch (e) {
      rethrow;
    }
  }

// Inspect GRN (quality check)
  Future<GoodsReceiptNote> inspectGRN(
      String id, {
        required String qualityStatus,
        String? qualityRemarks, // Changed from required String to String?
        required String inspectedBy,
      }) async {
    try {
      final data = {
        'qualityStatus': qualityStatus,
        'inspectedBy': inspectedBy,
      };

      // Only add qualityRemarks if it's not null
      if (qualityRemarks != null) {
        data['qualityRemarks'] = qualityRemarks;
      }

      final response = await _dio.post(
        '/v1/nawassco/procurement/goods-receipt-notes/$id/inspect',
        data: data,
      );
      final inspectedGRN = GoodsReceiptNote.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentGRNs = state.value ?? [];
        final index = currentGRNs.indexWhere((g) => g.id == id);
        if (index != -1) {
          final newGRNs = List<GoodsReceiptNote>.from(currentGRNs);
          newGRNs[index] = inspectedGRN;
          state = AsyncValue.data(newGRNs);
        }
      }

      return inspectedGRN;
    } catch (e) {
      rethrow;
    }
  }

  // Approve GRN
  Future<GoodsReceiptNote> approveGRN(String id) async {
    try {
      final response = await _dio.post('/v1/nawassco/procurement/goods-receipt-notes/$id/approve');
      final approvedGRN = GoodsReceiptNote.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentGRNs = state.value ?? [];
        final index = currentGRNs.indexWhere((g) => g.id == id);
        if (index != -1) {
          final newGRNs = List<GoodsReceiptNote>.from(currentGRNs);
          newGRNs[index] = approvedGRN;
          state = AsyncValue.data(newGRNs);
        }
      }

      return approvedGRN;
    } catch (e) {
      rethrow;
    }
  }

  // Get GRNs by purchase order
  Future<List<GoodsReceiptNote>> getGRNsByPurchaseOrder(String poId) async {
    try {
      final response =
          await _dio.get('/v1/nawassco/procurement/goods-receipt-notes/purchase-order/$poId');
      final data = response.data['data'] as List;
      return data.map((json) => GoodsReceiptNote.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get pending inspections
  Future<List<GoodsReceiptNote>> getPendingInspections() async {
    try {
      final response =
          await _dio.get('/v1/nawassco/procurement/goods-receipt-notes/pending-inspections');
      final data = response.data['data'] as List;
      return data.map((json) => GoodsReceiptNote.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get GRN statistics
  Future<GRNStats> getGRNStats({String timeframe = 'month'}) async {
    try {
      final response =
          await _dio.get('/v1/nawassco/procurement/goods-receipt-notes/stats', queryParameters: {
        'timeframe': timeframe,
      });
      return GRNStats.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Delete GRN
  Future<void> deleteGRN(String id) async {
    try {
      await _dio.delete('/v1/nawassco/procurement/goods-receipt-notes/$id');

      // Update state
      if (state.hasValue) {
        final currentGRNs = state.value ?? [];
        final newGRNs = currentGRNs.where((g) => g.id != id).toList();
        state = AsyncValue.data(newGRNs);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refresh GRNs
  Future<void> refreshGRNs() async {
    await getGRNs();
  }
}

// Providers
final goodsReceiptNotesProvider = StateNotifierProvider<
    GoodsReceiptNoteNotifier, AsyncValue<List<GoodsReceiptNote>>>(
  (ref) => GoodsReceiptNoteNotifier(ref),
);

// Individual GRN provider
final goodsReceiptNoteProvider =
    FutureProvider.family<GoodsReceiptNote, String>((ref, id) async {
  final notifier = ref.read(goodsReceiptNotesProvider.notifier);
  return await notifier.getGRNById(id);
});

// Pending inspections provider
final pendingInspectionsProvider =
    FutureProvider<List<GoodsReceiptNote>>((ref) async {
  final notifier = ref.read(goodsReceiptNotesProvider.notifier);
  return await notifier.getPendingInspections();
});

// GRN stats provider
final grnStatsProvider =
    FutureProvider.family<GRNStats, String>((ref, timeframe) async {
  final notifier = ref.read(goodsReceiptNotesProvider.notifier);
  return await notifier.getGRNStats(timeframe: timeframe);
});
