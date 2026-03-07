import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../models/stock/stock_alert_model.dart';


class StockAlertState {
  final List<StockAlert> alerts;
  final bool isLoading;
  final String? error;
  final StockAlert? selectedAlert;
  final int unacknowledgedCount;
  final int criticalCount;

  StockAlertState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
    this.selectedAlert,
    this.unacknowledgedCount = 0,
    this.criticalCount = 0,
  });

  StockAlertState copyWith({
    List<StockAlert>? alerts,
    bool? isLoading,
    String? error,
    StockAlert? selectedAlert,
    int? unacknowledgedCount,
    int? criticalCount,
  }) {
    return StockAlertState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedAlert: selectedAlert ?? this.selectedAlert,
      unacknowledgedCount: unacknowledgedCount ?? this.unacknowledgedCount,
      criticalCount: criticalCount ?? this.criticalCount,
    );
  }
}

class StockAlertProvider extends StateNotifier<StockAlertState> {
  final Ref ref;

  StockAlertProvider(this.ref) : super(StockAlertState());

  Future<void> getStockAlerts({
    String? alertType,
    String? priority,
    bool? acknowledged,
    bool? resolved,
    String? warehouse,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final Map<String, dynamic> queryParams = {
        if (alertType != null) 'alertType': alertType,
        if (priority != null) 'priority': priority,
        if (acknowledged != null) 'acknowledged': acknowledged,
        if (resolved != null) 'resolved': resolved,
        if (warehouse != null) 'warehouse': warehouse,
      };

      final response = await dio.get('/v1/nawassco/stores/stock-alerts', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<StockAlert> alerts = (response.data['data'] as List)
            .map((json) => StockAlert.fromJson(json))
            .toList();

        final unacknowledgedCount = alerts.where((alert) => !alert.acknowledged).length;
        final criticalCount = alerts.where((alert) => alert.isCritical).length;

        state = state.copyWith(
          alerts: alerts,
          unacknowledgedCount: unacknowledgedCount,
          criticalCount: criticalCount,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStockAlertById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.get('/v1/nawassco/stores/stock-alerts/$id');

      if (response.data['success'] == true) {
        final StockAlert alert = StockAlert.fromJson(response.data['data']);
        state = state.copyWith(selectedAlert: alert, isLoading: false);
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> acknowledgeAlert(String id, String acknowledgedBy) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-alerts/$id/acknowledge', data: {
        'acknowledgedBy': acknowledgedBy,
      });

      if (response.data['success'] == true) {
        final StockAlert updatedAlert = StockAlert.fromJson(response.data['data']);

        // Update in the list
        final List<StockAlert> updatedAlerts = state.alerts.map((alert) {
          return alert.id == id ? updatedAlert : alert;
        }).toList();

        final unacknowledgedCount = updatedAlerts.where((alert) => !alert.acknowledged).length;

        state = state.copyWith(
          alerts: updatedAlerts,
          selectedAlert: updatedAlert,
          unacknowledgedCount: unacknowledgedCount,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> resolveAlert(String id, String resolvedBy, String resolutionNotes) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.patch('/v1/nawassco/stores/stock-alerts/$id/resolve', data: {
        'resolvedBy': resolvedBy,
        'resolutionNotes': resolutionNotes,
      });

      if (response.data['success'] == true) {
        final StockAlert updatedAlert = StockAlert.fromJson(response.data['data']);

        // Update in the list
        final List<StockAlert> updatedAlerts = state.alerts.map((alert) {
          return alert.id == id ? updatedAlert : alert;
        }).toList();

        state = state.copyWith(
          alerts: updatedAlerts,
          selectedAlert: updatedAlert,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteAlert(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final dio = ref.read(dioProvider);
      final response = await dio.delete('/v1/nawassco/stores/stock-alerts/$id');

      if (response.data['success'] == true) {
        final List<StockAlert> updatedAlerts = state.alerts.where((alert) => alert.id != id).toList();
        final unacknowledgedCount = updatedAlerts.where((alert) => !alert.acknowledged).length;
        final criticalCount = updatedAlerts.where((alert) => alert.isCritical).length;

        state = state.copyWith(
          alerts: updatedAlerts,
          unacknowledgedCount: unacknowledgedCount,
          criticalCount: criticalCount,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.data['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelection() {
    state = state.copyWith(selectedAlert: null);
  }
}

final stockAlertProvider = StateNotifierProvider<StockAlertProvider, StockAlertState>((ref) {
  return StockAlertProvider(ref);
});