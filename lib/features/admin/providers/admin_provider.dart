import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class AdminProvider {
  final Dio dio;
  AdminProvider(this.dio);

  Future<List<dynamic>> getUsers({int page = 1, String? search, String? filter}) async {
    try {
      final params = {'page': page.toString(), 'limit': '50'};
      if (search != null && search.isNotEmpty) params['search'] = search;

      // Handle filter parameters properly
      if (filter != null && filter.isNotEmpty && filter != 'all') {
        final parts = filter.split(':');
        if (parts.length == 2) {
          final key = parts[0];
          final value = parts[1];

          // For role filters, use 'role' parameter as expected by backend
          if (key == 'roles') {
            params['role'] = value;
          } else {
            // For other filters like isActive, isArchived, isEmailVerified
            params[key] = value;
          }
        }
      }

      print('GET Users - Params: $params');
      final res = await dio.get('/users', queryParameters: params);
      print('Users Response received: ${res.data}');

      // Debug the response structure
      print('Response keys: ${res.data.keys}');
      if (res.data['data'] != null) {
        print('Data keys: ${res.data['data'].keys}');
        if (res.data['data']['users'] != null) {
          print('Users count: ${res.data['data']['users'].length}');
          return res.data['data']['users'];
        } else {
          print('Users key is null, checking for direct array...');
          // Check if users array is directly in data
          if (res.data['data'] is List) {
            print('Data is directly a list, returning it');
            return res.data['data'];
          }
        }
      }

      // Fallback: return empty list
      print('No users found in response, returning empty list');
      return [];

    } on DioException catch (e) {
      print('GET Users DioError: ${e.response?.data}');
      print('Status: ${e.response?.statusCode}');
      print('Headers: ${e.response?.headers}');
      throw Exception('Failed to load users: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('GET Users Error: $e');
      throw Exception('Failed to load users: $e');
    }
  }


  Future<Map<String, dynamic>> getUser(String id) async {
    try {
      print('GET User - ID: $id');
      final res = await dio.get('/users/$id');
      print('User Detail Response received: ${res.data}');

      if (res.data['data'] != null) {
        return res.data['data'];
      } else {
        return res.data;
      }
    } on DioException catch (e) {
      print('GET User DioError: ${e.response?.data}');
      throw Exception('Failed to load user: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('GET User Error: $e');
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      print('CREATE User - Data: $data');
      final response = await dio.post('/users', data: data);
      print('User created successfully: ${response.data}');
    } on DioException catch (e) {
      print('CREATE User DioError: ${e.response?.data}');
      throw Exception('Failed to create user: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('CREATE User Error: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      print('UPDATE User - ID: $id, Data: $data');
      final response = await dio.patch('/users/$id', data: data);
      print('User updated successfully: ${response.data}');
    } on DioException catch (e) {
      print('UPDATE User DioError: ${e.response?.data}');
      throw Exception('Failed to update user: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('UPDATE User Error: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      print('DELETE User - ID: $id');
      final response = await dio.delete('/users/$id');
      print('User deleted successfully: ${response.data}');
    } on DioException catch (e) {
      print('DELETE User DioError: ${e.response?.data}');
      throw Exception('Failed to delete user: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('DELETE User Error: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> toggleArchive(String id, bool archive) async {
    try {
      final endpoint = '/users/$id/${archive ? 'archive' : 'unarchive'}';
      print('Archive User - ID: $id, Archive: $archive');
      final response = await dio.post(endpoint);
      print('Archive action completed: ${response.data}');
    } on DioException catch (e) {
      print('Archive User DioError: ${e.response?.data}');
      throw Exception('Failed to toggle archive: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Archive User Error: $e');
      throw Exception('Failed to toggle archive: $e');
    }
  }

  Future<void> toggleActive(String id, bool active) async {
    try {
      final endpoint = '/users/$id/${active ? 'activate' : 'deactivate'}';
      print('Active User - ID: $id, Active: $active');
      final response = await dio.post(endpoint);
      print('Active action completed: ${response.data}');
    } on DioException catch (e) {
      print('Active User DioError: ${e.response?.data}');
      throw Exception('Failed to toggle active status: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Active User Error: $e');
      throw Exception('Failed to toggle active status: $e');
    }
  }

  Future<void> verifyEmail(String id) async {
    try {
      print('Verify Email - ID: $id');
      final response = await dio.post('/users/$id/verify');
      print('Email verified: ${response.data}');
    } on DioException catch (e) {
      print('Verify Email DioError: ${e.response?.data}');
      throw Exception('Failed to verify user email: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Verify Email Error: $e');
      throw Exception('Failed to verify user email: $e');
    }
  }

  Future<void> unverifyEmail(String id) async {
    try {
      print('Unverify Email - ID: $id');
      final response = await dio.post('/users/$id/unverify');
      print('Email unverified: ${response.data}');
    } on DioException catch (e) {
      print('Unverify Email DioError: ${e.response?.data}');
      throw Exception('Failed to unverify user email: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Unverify Email Error: $e');
      throw Exception('Failed to unverify user email: $e');
    }
  }

  Future<void> bulkAction(List<String> userIds, String action) async {
    try {
      print('Bulk Action - Users: $userIds, Action: $action');
      final response = await dio.post('/users/bulk/actions', data: {
        'userIds': userIds,
        'action': action,
      });
      print('Bulk action completed: ${response.data}');
    } on DioException catch (e) {
      print('Bulk Action DioError: ${e.response?.data}');
      throw Exception('Failed to perform bulk action: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Bulk Action Error: $e');
      throw Exception('Failed to perform bulk action: $e');
    }
  }
}

final adminProvider = Provider<AdminProvider>((ref) {
  final dio = ref.read(dioProvider);
  return AdminProvider(dio);
});