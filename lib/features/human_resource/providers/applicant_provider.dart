import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/main.dart';
import '../models/applicant/applicant_model.dart';
import '../models/applicant/education_model.dart';
import '../models/applicant/skill_model.dart';
import '../models/applicant/work_experience_model.dart';

class ApplicantState {
  final ApplicantModel? applicant;
  final bool isLoading;
  final bool isSaving;
  final bool isUploading;
  final String? error;

  ApplicantState({
    this.applicant,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploading = false,
    this.error,
  });

  ApplicantState copyWith({
    ApplicantModel? applicant,
    bool? isLoading,
    bool? isSaving,
    bool? isUploading,
    String? error,
  }) {
    return ApplicantState(
      applicant: applicant ?? this.applicant,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
    );
  }
}

class ApplicantProvider extends StateNotifier<ApplicantState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final ImagePicker _imagePicker = ImagePicker();

  ApplicantProvider(this._dio, this._scaffoldMessengerKey)
      : super(ApplicantState());

  // Load applicant profile
  Future<void> loadApplicantProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/human_resource/applicants/my-profile');

      if (response.data['success'] == true) {
        final applicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: applicant,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load profile',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
          'Failed to load profile: ${response.data['message']}',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading profile: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast(
        'Error loading profile',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Create or get applicant
  Future<void> createOrGetApplicant(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post('/v1/nawassco/human_resource/applicants', data: {'email': email});

      if (response.data['success'] == true) {
        final applicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: applicant,
          isLoading: false,
        );
        ToastUtils.showSuccessToast(
          'Profile loaded successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create profile',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error creating profile: $e',
        isLoading: false,
      );
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo({
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    required String phoneNumber,
    required String address,
    required String city,
    required String country,
    String? postalCode,
    String? headline,
    String? summary,
  }) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/${state.applicant!.id}',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'nationality': nationality,
          'phoneNumber': phoneNumber,
          'address': address,
          'city': city,
          'country': country,
          'postalCode': postalCode,
          'headline': headline,
          'summary': summary,
        },
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Personal information updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update information',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating information: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Upload profile photo
  Future<void> uploadProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      state = state.copyWith(isUploading: true);

      final formData = FormData();
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(image.path, filename: 'profile_photo.jpg'),
      ));

      final response = await _dio.post(
        '/v1/nawassco/human_resource/applicants/upload-profile-photo',
        data: formData,
      );

      if (response.data['success'] == true) {
        final updatedApplicant = state.applicant!.copyWith(
          profilePhoto: response.data['data']['profilePhoto'],
        );
        state = state.copyWith(
          applicant: updatedApplicant,
          isUploading: false,
        );
        ToastUtils.showSuccessToast(
          'Profile photo updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isUploading: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to upload photo',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isUploading: false);
      ToastUtils.showErrorToast(
        'Error uploading photo: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Education CRUD
  Future<void> addEducation(EducationModel education) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/applicants/education',
        data: education.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Education added successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to add education',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error adding education: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> updateEducation(
      String educationId, EducationModel education) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/education/$educationId',
        data: education.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Education updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update education',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating education: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> deleteEducation(String educationId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.delete(
        '/v1/nawassco/human_resource/applicants/education/$educationId',
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Education deleted successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to delete education',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error deleting education: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Work Experience CRUD
  Future<void> addWorkExperience(WorkExperienceModel workExperience) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/applicants/work-experience',
        data: workExperience.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Work experience added successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to add work experience',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error adding work experience: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> updateWorkExperience(
      String experienceId, WorkExperienceModel workExperience) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/work-experience/$experienceId',
        data: workExperience.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Work experience updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update work experience',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating work experience: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> deleteWorkExperience(String experienceId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.delete(
        '/v1/nawassco/human_resource/applicants/work-experience/$experienceId',
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Work experience deleted successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to delete work experience',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error deleting work experience: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Skills CRUD
  Future<void> addSkill(SkillModel skill) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/applicants/skills',
        data: skill.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Skill added successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to add skill',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error adding skill: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> updateSkill(String skillId, SkillModel skill) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/skills/$skillId',
        data: skill.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Skill updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update skill',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating skill: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.delete(
        '/v1/nawassco/human_resource/applicants/skills/$skillId',
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Skill deleted successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to delete skill',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error deleting skill: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Upload document
  Future<void> uploadDocument({
    required String name,
    required List<int> fileBytes,
    required String fileType,
    required String fileExtension,
    String? description,
    bool isPrimary = false,
  }) async {
    try {
      state = state.copyWith(isUploading: true);

      final formData = FormData();

      // Create MultipartFile from bytes
      final multipartFile = MultipartFile.fromBytes(
        fileBytes,
        filename: name,
      );

      formData.files.add(MapEntry('document', multipartFile));

      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('type', fileType),
        if (description != null) MapEntry('description', description),
        MapEntry('isPrimary', isPrimary.toString()),
        MapEntry('fileSize', fileBytes.length.toString()),
        MapEntry('fileExtension', fileExtension),
      ]);

      final response = await _dio.post(
        '/v1/nawassco/human_resource/applicants/upload-document',
        data: formData,
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isUploading: false,
        );
        ToastUtils.showSuccessToast(
          'Document uploaded successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isUploading: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to upload document',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isUploading: false);
      ToastUtils.showErrorToast(
        'Error uploading document: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.delete(
        '/v1/nawassco/human_resource/applicants/documents/$documentId',
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Document deleted successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to delete document',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error deleting document: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Update job preferences
  Future<void> updateJobPreferences(JobPreferences preferences) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/job-preferences',
        data: preferences.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Job preferences updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update job preferences',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating job preferences: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Sync with user profile
  Future<void> syncWithUser() async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.post('/v1/nawassco/human_resource/applicants/sync-user');

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Profile synced successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to sync profile',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error syncing profile: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await _dio.put(
        '/v1/nawassco/human_resource/applicants/privacy-settings',
        data: settings.toJson(),
      );

      if (response.data['success'] == true) {
        final updatedApplicant = ApplicantModel.fromJson(response.data['data']);
        state = state.copyWith(
          applicant: updatedApplicant,
          isSaving: false,
        );
        ToastUtils.showSuccessToast(
          'Privacy settings updated successfully',
          key: _scaffoldMessengerKey,
        );
      } else {
        state = state.copyWith(isSaving: false);
        ToastUtils.showErrorToast(
          response.data['message'] ?? 'Failed to update privacy settings',
          key: _scaffoldMessengerKey,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      ToastUtils.showErrorToast(
        'Error updating privacy settings: $e',
        key: _scaffoldMessengerKey,
      );
    }
  }
}

// Provider
final applicantProvider =
StateNotifierProvider<ApplicantProvider, ApplicantState>((ref) {
  final dio = ref.read(dioProvider);
  return ApplicantProvider(dio, scaffoldMessengerKey);
});