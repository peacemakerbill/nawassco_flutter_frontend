import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/services/api_service.dart';


class CloudinaryProvider {
  final Dio dio;

  CloudinaryProvider(this.dio);

  // Get upload signature from backend
  Future<Map<String, dynamic>> getUploadSignature({String folder = 'nawasco/profiles'}) async {
    try {
      final response = await dio.post(
        '/profile/upload-signature',
        data: {'folder': folder},
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to get upload signature: $e');
    }
  }

  // Upload image directly to Cloudinary
  Future<String> uploadImageDirectly(XFile image, {String folder = 'nawasco/profiles'}) async {
    try {
      // Get upload signature from backend
      final signatureData = await getUploadSignature(folder: folder);

      // Create form data for Cloudinary
      final formData = FormData();

      // Add required parameters (must match exactly what was signed)
      formData.fields.addAll([
        MapEntry('api_key', signatureData['apiKey']),
        MapEntry('timestamp', signatureData['timestamp'].toString()),
        MapEntry('signature', signatureData['signature']),
        MapEntry('folder', folder),
        MapEntry('public_id', signatureData['publicId']), // Must match signed public_id
        MapEntry('overwrite', 'true'),
        MapEntry('invalidate', 'true'),
      ]);

      // Add the image file
      if (!kIsWeb) {
        // For mobile
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              image.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      } else {
        // For web
        final bytes = await image.readAsBytes();
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(
              bytes,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      // Upload directly to Cloudinary
      final response = await Dio().post(
        signatureData['uploadUrl'],
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Optional: Fallback upload through backend (requires multer on /profile/me)
  Future<String> uploadImageThroughBackend(XFile image) async {
    try {
      final formData = FormData();

      if (!kIsWeb) {
        formData.files.add(
          MapEntry(
            'profilePicture',
            await MultipartFile.fromFile(
              image.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      } else {
        final bytes = await image.readAsBytes();
        formData.files.add(
          MapEntry(
            'profilePicture',
            MultipartFile.fromBytes(
              bytes,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      final response = await dio.patch(
        '/profile/me',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['data']['profilePictureUrl'];
    } catch (e) {
      throw Exception('Failed to upload image through backend: $e');
    }
  }
}

final cloudinaryProvider = Provider<CloudinaryProvider>((ref) {
  final dio = ref.read(dioProvider);
  return CloudinaryProvider(dio);
});