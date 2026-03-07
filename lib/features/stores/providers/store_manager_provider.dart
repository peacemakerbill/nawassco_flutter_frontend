import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../models/store_manager_model.dart';
import '../../../main.dart';

class StoreManagerState {
  final StoreManager? storeManager;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  StoreManagerState({
    this.storeManager,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  StoreManagerState copyWith({
    StoreManager? storeManager,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return StoreManagerState(
      storeManager: storeManager ?? this.storeManager,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class StoreManagerProvider extends StateNotifier<StoreManagerState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  StoreManagerProvider(this.dio, this.scaffoldMessengerKey)
      : super(StoreManagerState());

  bool get isMounted => mounted;

  // Get store manager profile by user ID
  Future<void> getStoreManagerProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Fetching store manager profile...');

      final response = await dio.get('/v1/nawassco/stores/store-managers/my-profile');

      if (response.data['success'] == true) {
        final storeManagerData = response.data['data'];
        final storeManager = StoreManager.fromJson(storeManagerData);

        state = state.copyWith(
          storeManager: storeManager,
          isLoading: false,
        );
        print('Store manager profile loaded successfully');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to load profile';
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error fetching store manager profile: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Update store manager profile
  Future<void> updateStoreManagerProfile(Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Updating store manager profile...');

      final response = await dio.patch(
        '/v1/nawassco/stores/store-managers/${state.storeManager?.id}',
        data: updateData,
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        state = state.copyWith(
          storeManager: updatedManager,
          isUpdating: false,
        );
        _showSuccessToast('Profile updated successfully');
        print('Store manager profile updated successfully');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update profile';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error updating store manager profile: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Update personal information
  Future<void> updatePersonalInformation(PersonalDetails personalDetails) async {
    await updateStoreManagerProfile({
      'personalDetails': personalDetails.toJson(),
    });
  }

  // Update contact information
  Future<void> updateContactInformation(ContactInformation contactInfo) async {
    await updateStoreManagerProfile({
      'contactInformation': contactInfo.toJson(),
    });
  }

  // Update emergency contacts
  Future<void> updateEmergencyContacts(List<EmergencyContact> contacts) async {
    await updateStoreManagerProfile({
      'emergencyContacts': contacts.map((e) => e.toJson()).toList(),
    });
  }

  // Update objective progress
  Future<void> updateObjectiveProgress(String objectiveId, double progress) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Updating objective progress...');

      final response = await dio.patch(
        '/v1/nawassco/stores/store-managers/${state.storeManager?.id}/objectives/$objectiveId/progress',
        data: {'progress': progress},
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        state = state.copyWith(
          storeManager: updatedManager,
          isUpdating: false,
        );
        _showSuccessToast('Objective progress updated successfully');
        print('Objective progress updated successfully');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to update objective progress';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error updating objective progress: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Add store objective
  Future<void> addStoreObjective(Map<String, dynamic> objectiveData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      print('Adding store objective...');

      final response = await dio.post(
        '/v1/nawassco/stores/store-managers/${state.storeManager?.id}/objectives',
        data: objectiveData,
      );

      if (response.data['success'] == true) {
        final updatedManagerData = response.data['data'];
        final updatedManager = StoreManager.fromJson(updatedManagerData);

        state = state.copyWith(
          storeManager: updatedManager,
          isUpdating: false,
        );
        _showSuccessToast('Objective added successfully');
        print('Store objective added successfully');
      } else {
        final errorMessage = response.data['message'] ?? 'Failed to add objective';
        state = state.copyWith(
          error: errorMessage,
          isUpdating: false,
        );
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Error adding store objective: $e');
      final errorMessage = _handleError(e);
      state = state.copyWith(
        error: errorMessage,
        isUpdating: false,
      );
      _showErrorToast(errorMessage);
    }
  }

  // Update development plan
  Future<void> updateDevelopmentPlan(StoreDevelopmentPlan developmentPlan) async {
    await updateStoreManagerProfile({
      'developmentPlan': developmentPlan.toJson(),
    });
  }

  // Add certification
  Future<void> addCertification(StoreCertification certification) async {
    final currentCertifications = state.storeManager?.certifications ?? [];
    final updatedCertifications = [...currentCertifications, certification];

    await updateStoreManagerProfile({
      'certifications': updatedCertifications.map((e) => e.toJson()).toList(),
    });
  }

  // Update technical training
  Future<void> updateTechnicalTraining(List<TechnicalTraining> training) async {
    await updateStoreManagerProfile({
      'technicalTraining': training.map((e) => e.toJson()).toList(),
    });
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  void _showSuccessToast(String message) {
    ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
  }

  void _showErrorToast(String message) {
    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (data is Map<String, dynamic>) {
            if (data['message'] is String && (data['message'] as String).isNotEmpty) {
              return data['message'];
            }
          }

          switch (statusCode) {
            case 401:
              return 'Unauthorized. Please login again.';
            case 403:
              return 'Access denied.';
            case 404:
              return 'Profile not found.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return 'Request failed. Please try again.';
          }
        case DioExceptionType.unknown:
          if (error.error?.toString().contains('SocketException') == true) {
            return 'No internet connection. Please check your network.';
          }
          return 'An unexpected error occurred.';
        default:
          return 'An unexpected error occurred.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

// Provider
final storeManagerProvider = StateNotifierProvider<StoreManagerProvider, StoreManagerState>((ref) {
  final dio = ref.read(dioProvider);
  return StoreManagerProvider(dio, scaffoldMessengerKey);
});