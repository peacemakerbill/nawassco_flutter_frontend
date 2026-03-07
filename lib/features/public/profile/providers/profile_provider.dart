import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';


class ProfileProvider {
  final Dio dio;
  ProfileProvider(this.dio);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await dio.get('/profile/me');
      return _sanitizeProfileData(res.data['data'] ?? res.data);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Map<String, dynamic> _sanitizeProfileData(Map<String, dynamic> data) {
    return {
      'firstName': data['firstName'] ?? '',
      'lastName': data['lastName'] ?? '',
      'middleName': data['middleName'] ?? '',
      'username': data['username'] ?? '',
      'email': data['email'] ?? '',
      'phoneNumber': data['phoneNumber'] ?? '',
      'profilePictureUrl': data['profilePictureUrl'],
      'profileCompletion': data['profileCompletion'] ?? 0,
      'location': data['location'] ?? '',
      'address': data['address'] ?? '',
      'gender': data['gender'] ?? 'Other',
      'dateOfBirth': data['dateOfBirth'],
      'nationalId': data['nationalId'] ?? '',
      'roles': data['roles'] ?? [],
      'leadsAssigned': data['leadsAssigned'] ?? 0,
      'conversionsCount': data['conversionsCount'] ?? 0,
      'accountNumber': data['accountNumber'] ?? '',
      'meterNumber': data['meterNumber'] ?? '',
      'billingBalance': data['billingBalance'] ?? 0.0,
      'serviceZone': data['serviceZone'] ?? '',
      'customerType': data['customerType'] ?? 'Residential',
      'preferredLanguage': data['preferredLanguage'] ?? 'en',
    };
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.patch('/profile/me', data: data);
      final responseData = response.data['data'] ?? response.data;
      return _sanitizeProfileData(responseData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    try {
      final response = await dio.patch(
        '/profile/change-password',
        data: {'oldPassword': oldPass, 'newPassword': newPass},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Simple method to update profile with image URL
  Future<Map<String, dynamic>> updateProfileWithImageUrl(String imageUrl, Map<String, dynamic> otherData) async {
    final data = {
      ...otherData,
      'profilePictureUrl': imageUrl,
    };
    return await updateProfile(data);
  }
}

final profileProvider = Provider<ProfileProvider>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileProvider(dio);
});