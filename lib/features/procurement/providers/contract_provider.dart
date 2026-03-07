import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../domain/models/contract.dart';

class ContractNotifier extends StateNotifier<AsyncValue<List<Contract>>> {
  final Ref ref;
  final Dio _dio;

  ContractNotifier(this.ref)
      : _dio = ref.read(dioProvider),
        super(const AsyncValue.loading());

  // Get all contracts
  Future<void> getContracts({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
    String? category,
    String? supplier,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/v1/nawassco/procurement/contracts', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'status': status,
        'type': type,
        'category': category,
        'supplier': supplier,
      });

      final data = response.data['data'];
      List<Contract> contracts = [];

      if (data is Map && data.containsKey('contracts')) {
        contracts = (data['contracts'] as List)
            .map((json) => Contract.fromJson(json))
            .toList();
      } else if (data is List) {
        contracts = data.map((json) => Contract.fromJson(json)).toList();
      }

      state = AsyncValue.data(contracts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Get contract by ID
  Future<Contract> getContractById(String id) async {
    try {
      final response = await _dio.get('/v1/nawassco/procurement/contracts/$id');
      return Contract.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Create contract
  Future<Contract> createContract(Contract contract) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/contracts',
        data: contract.toJson(),
      );
      final newContract = Contract.fromJson(response.data['data']);

      // Update state with new contract
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        state = AsyncValue.data([newContract, ...currentContracts]);
      }

      return newContract;
    } catch (e) {
      rethrow;
    }
  }

  // Update contract
  Future<Contract> updateContract(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '/v1/nawassco/procurement/contracts/$id',
        data: data,
      );
      final updatedContract = Contract.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        final index = currentContracts.indexWhere((c) => c.id == id);
        if (index != -1) {
          final newContracts = List<Contract>.from(currentContracts);
          newContracts[index] = updatedContract;
          state = AsyncValue.data(newContracts);
        }
      }

      return updatedContract;
    } catch (e) {
      rethrow;
    }
  }

  // Approve contract
  Future<Contract> approveContract(String id) async {
    try {
      final response = await _dio.post('/v1/nawassco/procurement/contracts/$id/approve');
      final approvedContract = Contract.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        final index = currentContracts.indexWhere((c) => c.id == id);
        if (index != -1) {
          final newContracts = List<Contract>.from(currentContracts);
          newContracts[index] = approvedContract;
          state = AsyncValue.data(newContracts);
        }
      }

      return approvedContract;
    } catch (e) {
      rethrow;
    }
  }

  // Terminate contract
  Future<Contract> terminateContract(
      String contractId, {
        required String terminationReason,
        required DateTime terminationDate,
      }) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/contracts/$contractId/terminate',
        data: {
          'terminationReason': terminationReason,
          'terminationDate': terminationDate.toIso8601String(),
        },
      );
      final terminatedContract = Contract.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        final index = currentContracts.indexWhere((c) => c.id == contractId);
        if (index != -1) {
          final newContracts = List<Contract>.from(currentContracts);
          newContracts[index] = terminatedContract;
          state = AsyncValue.data(newContracts);
        }
      }

      return terminatedContract;
    } catch (e) {
      rethrow;
    }
  }

  // Renew contract
  Future<Contract> renewContract(
      String contractId, {
        required DateTime newEndDate,
        String? renewalTerms,
      }) async {
    try {
      final response = await _dio.post(
        '/v1/nawassco/procurement/contracts/$contractId/renew',
        data: {
          'newEndDate': newEndDate.toIso8601String(),
          'renewalTerms': renewalTerms,
        },
      );
      final renewedContract = Contract.fromJson(response.data['data']);

      // Update state
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        final index = currentContracts.indexWhere((c) => c.id == contractId);
        if (index != -1) {
          final newContracts = List<Contract>.from(currentContracts);
          newContracts[index] = renewedContract;
          state = AsyncValue.data(newContracts);
        }
      }

      return renewedContract;
    } catch (e) {
      rethrow;
    }
  }

  // Delete contract
  Future<void> deleteContract(String id) async {
    try {
      await _dio.delete('/v1/nawassco/procurement/contracts/$id');

      // Update state
      if (state.hasValue) {
        final currentContracts = state.value ?? [];
        final newContracts = currentContracts.where((c) => c.id != id).toList();
        state = AsyncValue.data(newContracts);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get expiring contracts
  Future<List<Contract>> getExpiringContracts({int days = 30, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/nawassco/procurement/contracts/expiring', queryParameters: {
        'days': days,
        'limit': limit,
      });
      final data = response.data['data'] as List;
      return data.map((json) => Contract.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get contract statistics
  Future<ContractStats> getContractStats({String timeframe = 'month'}) async {
    try {
      final response = await _dio.get('/v1/nawassco/procurement/contracts/stats', queryParameters: {
        'timeframe': timeframe,
      });
      return ContractStats.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Refresh contracts
  Future<void> refreshContracts() async {
    await getContracts();
  }
}

// Providers
final contractsProvider = StateNotifierProvider<ContractNotifier, AsyncValue<List<Contract>>>(
      (ref) => ContractNotifier(ref),
);

// Individual contract provider
final contractProvider = FutureProvider.family<Contract, String>((ref, id) async {
  final notifier = ref.read(contractsProvider.notifier);
  return await notifier.getContractById(id);
});

// Expiring contracts provider
final expiringContractsProvider = FutureProvider<List<Contract>>((ref) async {
  final notifier = ref.read(contractsProvider.notifier);
  return await notifier.getExpiringContracts();
});

// Contract stats provider
final contractStatsProvider = FutureProvider.family<ContractStats, String>((ref, timeframe) async {
  final notifier = ref.read(contractsProvider.notifier);
  return await notifier.getContractStats(timeframe: timeframe);
});