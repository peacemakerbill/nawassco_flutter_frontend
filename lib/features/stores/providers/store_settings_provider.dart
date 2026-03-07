import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/store_settings_model.dart';
import '../../../core/services/api_service.dart';

class StoreSettingsState {
  final StoreSettings? settings;
  final bool isLoading;
  final String? error;
  final bool isSaving;
  final Map<String, dynamic>? systemStatistics;

  StoreSettingsState({
    this.settings,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
    this.systemStatistics,
  });

  StoreSettingsState copyWith({
    StoreSettings? settings,
    bool? isLoading,
    String? error,
    bool? isSaving,
    Map<String, dynamic>? systemStatistics,
  }) {
    return StoreSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
      systemStatistics: systemStatistics ?? this.systemStatistics,
    );
  }
}

class StoreSettingsProvider extends StateNotifier<StoreSettingsState> {
  final Dio dio;

  StoreSettingsProvider(this.dio) : super(StoreSettingsState());

  // Get store settings
  Future<void> getStoreSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/stores/store-settings');

      if (response.data['success'] == true) {
        final settings = StoreSettings.fromJson(response.data['data']);
        state = state.copyWith(settings: settings, isLoading: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load settings');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Update store settings
  Future<void> updateStoreSettings(Map<String, dynamic> updates) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.patch('/v1/nawassco/stores/store-settings', data: updates);

      if (response.data['success'] == true) {
        final settings = StoreSettings.fromJson(response.data['data']);
        state = state.copyWith(settings: settings, isSaving: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update settings');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Update specific setting by path
  Future<void> updateSetting(String path, dynamic value) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.patch('/v1/nawassco/stores/store-settings/$path', data: {'value': value});

      if (response.data['success'] == true) {
        final settings = StoreSettings.fromJson(response.data['data']);
        state = state.copyWith(settings: settings, isSaving: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update setting');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      final response = await dio.post('/v1/nawassco/stores/store-settings/reset');

      if (response.data['success'] == true) {
        final settings = StoreSettings.fromJson(response.data['data']);
        state = state.copyWith(settings: settings, isSaving: false);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to reset settings');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  // Get system statistics
  Future<void> getSystemStatistics() async {
    try {
      final response = await dio.get('/v1/nawassco/stores/store-settings/statistics');

      if (response.data['success'] == true) {
        state = state.copyWith(systemStatistics: response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final storeSettingsProvider = StateNotifierProvider<StoreSettingsProvider, StoreSettingsState>((ref) {
  final dio = ref.read(dioProvider);
  return StoreSettingsProvider(dio);
});