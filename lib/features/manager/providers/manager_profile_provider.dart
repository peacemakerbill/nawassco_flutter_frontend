import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/manager_model.dart';

class ManagerProfileState {
  final ManagerModel? manager;
  final bool hasProfile;
  final bool isLoading;
  final bool isSaving;
  final bool isCreating;
  final String? error;
  final String? success;

  const ManagerProfileState({
    this.manager,
    this.hasProfile = false,
    this.isLoading = false,
    this.isSaving = false,
    this.isCreating = false,
    this.error,
    this.success,
  });

  ManagerProfileState copyWith({
    ManagerModel? manager,
    bool? hasProfile,
    bool? isLoading,
    bool? isSaving,
    bool? isCreating,
    String? error,
    String? success,
  }) {
    return ManagerProfileState(
      manager: manager ?? this.manager,
      hasProfile: hasProfile ?? this.hasProfile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isCreating: isCreating ?? this.isCreating,
      error: error,
      success: success,
    );
  }
}

class ManagerProfileProvider extends StateNotifier<ManagerProfileState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  ManagerProfileProvider(this._dio, this._scaffoldMessengerKey)
      : super(const ManagerProfileState());

  // Load current user's manager profile
  Future<void> loadMyManagerProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/managers/me');

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          manager: manager,
          hasProfile: true,
          isLoading: false,
          success: 'Profile loaded successfully',
        );
      } else {
        state = state.copyWith(
          hasProfile: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        hasProfile: false,
        isLoading: false,
      );
    }
  }

  // Create manager profile (self-service)
  Future<bool> createManagerProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final response = await _dio.post('/v1/nawassco/managers', data: data);

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          manager: manager,
          hasProfile: true,
          isCreating: false,
          success: 'Profile created successfully',
        );
        ToastUtils.showSuccessToast(
          'Manager profile created successfully',
          key: _scaffoldMessengerKey,
        );
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.data['message'] ?? 'Failed to create profile',
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to create profile',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Error creating profile: $e',
      );
      ToastUtils.showErrorToast(
        'Error creating profile',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Update manager profile (self-service - limited fields)
  Future<bool> updateMyProfile(Map<String, dynamic> data) async {
    try {
      if (state.manager == null) return false;

      state = state.copyWith(isSaving: true, error: null);

      final response = await _dio.put(
        '/v1/nawassco/managers/${state.manager!.id}',
        data: data,
      );

      if (response.data['success'] == true) {
        final manager = ManagerModel.fromJson(response.data['data']);
        state = state.copyWith(
          manager: manager,
          isSaving: false,
          success: 'Profile updated successfully',
        );
        ToastUtils.showSuccessToast(
          'Profile updated successfully',
          key: _scaffoldMessengerKey,
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          error: response.data['message'] ?? 'Failed to update profile',
        );
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update profile',
          key: _scaffoldMessengerKey,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Error updating profile: $e',
      );
      ToastUtils.showErrorToast(
        'Error updating profile',
        key: _scaffoldMessengerKey,
      );
      return false;
    }
  }

  // Update personal information only
  Future<bool> updatePersonalInfo({
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? gender,
    required String nationalId,
    required String workEmail,
    required String personalEmail,
    required String workPhone,
    required String personalPhone,
    required String officeLocation,
  }) async {
    final data = {
      'personalDetails': {
        'firstName': firstName,
        'lastName': lastName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (gender != null) 'gender': gender,
        'nationalId': nationalId,
      },
      'contactInformation': {
        'workEmail': workEmail,
        'personalEmail': personalEmail,
        'workPhone': workPhone,
        'personalPhone': personalPhone,
        'officeLocation': officeLocation,
      },
    };

    return updateMyProfile(data);
  }

  // Update job information only
  Future<bool> updateJobInfo({
    required String jobTitle,
    required String department,
    required String division,
    required String location,
    required String costCenter,
  }) async {
    final data = {
      'jobInformation': {
        'jobTitle': jobTitle,
        'department': department,
        'division': division,
        'location': location,
        'costCenter': costCenter,
      },
    };

    return updateMyProfile(data);
  }

  // Update emergency contacts
  Future<bool> updateEmergencyContacts(
      List<Map<String, dynamic>> contacts) async {
    final data = {
      'emergencyContacts': contacts,
    };

    return updateMyProfile(data);
  }

  // Clear state
  void clear() {
    state = const ManagerProfileState();
  }
}

// Provider
final managerProfileProvider =
    StateNotifierProvider<ManagerProfileProvider, ManagerProfileState>((ref) {
  final dio = ref.read(dioProvider);
  return ManagerProfileProvider(dio, scaffoldMessengerKey);
});
