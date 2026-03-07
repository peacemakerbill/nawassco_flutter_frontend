import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/accountant.model.dart';

// Accountant Profile Provider
class AccountantProfileProvider extends StateNotifier<AsyncValue<Accountant?>> {
  final Ref ref;
  final Dio dio;
  bool _isLoading = false;

  AccountantProfileProvider(this.ref, this.dio)
      : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      // Get current user from auth provider
      final authState = ref.read(authProvider);

      if (!authState.isAuthenticated) {
        print('User not authenticated');
        state = const AsyncValue.data(null);
        return;
      }

      final user = authState.user;

      if (user == null) {
        print('No user data in auth state');
        state = const AsyncValue.data(null);
        return;
      }

      final email = user['email'];

      if (email == null || email.isEmpty) {
        print('No email found in user data');
        state = const AsyncValue.data(null);
        return;
      }

      print('LOADING ACCOUNTANT PROFILE FOR EMAIL: $email');
      print('User roles: ${authState.activeRoles}');

      // Try to get accountant by email
      try {
        final response = await dio.get('/v1/nawassco/accounts/accountants/email/$email');

        print('API RESPONSE STATUS: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = response.data;
          print('API RESPONSE DATA TYPE: ${data.runtimeType}');

          if (data is Map<String, dynamic> && data['success'] == true) {
            final accountantData = data['data'];
            if (accountantData != null) {
              final accountant = Accountant.fromJson(accountantData);
              print('PROFILE FOUND: ${accountant.fullName}');
              state = AsyncValue.data(accountant);
            } else {
              print('No data in response');
              state = const AsyncValue.data(null);
            }
          } else {
            print('Response indicates failure: $data');
            state = const AsyncValue.data(null);
          }
        } else if (response.statusCode == 404) {
          print('Profile not found for email: $email');
          state = const AsyncValue.data(null);
        } else {
          print('Unexpected status code: ${response.statusCode}');
          print('Response: ${response.data}');
          state = const AsyncValue.data(null);
        }
      } on DioException catch (error) {
        print('DioException while fetching profile: ${error.type}');
        print('Error message: ${error.message}');

        if (error.response != null) {
          print('Response status: ${error.response!.statusCode}');
          print('Response data: ${error.response!.data}');

          if (error.response!.statusCode == 404) {
            print('Profile not found (404)');
            state = const AsyncValue.data(null);
            return;
          }

          if (error.response!.statusCode == 403) {
            print('Access forbidden (403) - Checking permissions...');
            print('Your roles: ${authState.activeRoles}');
            print('Required roles: Admin, Manager, HR, Accounts');

            // If user has Accounts role, they should have access
            if (authState.hasRole('Accounts')) {
              print('User has Accounts role but still got 403 - API issue');
            }
            state = const AsyncValue.data(null);
            return;
          }
        }

        // Re-throw other Dio errors
        state = AsyncValue.error(error, StackTrace.current);
        return;
      } catch (error) {
        print('Other error fetching profile: $error');
        state = AsyncValue.error(error, StackTrace.current);
        return;
      }
    } catch (error) {
      print('Unexpected error in _loadProfile: $error');
      state = AsyncValue.error(error, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  Future<Accountant> createBasicProfileFromCurrentUser() async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final email = user['email'];
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';

      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }

      // Create only the most basic profile - this is for emergency use only
      // Most users should use the form to fill in all details
      final accountant = Accountant(
        id: null,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: user['phoneNumber'] ?? user['phone'] ?? '',
        employeeNumber: null,
        jobTitle: 'accountant',
        department: 'Accounts',
        employmentType: 'full_time',
        employmentStatus: 'active',
        dateOfBirth: null,
        gender: user['gender'],
        address: user['address'],
        profilePictureUrl: null,
        hireDate: DateTime.now(),
        createdAt: null,
        updatedAt: null,
        isActive: true,
        supervisorId: null,
        performance: null,
        lastEvaluationDate: null,
        systemAccess: null,
        accountingQualifications: null,
        documents: null,
        salary: null,
        bankName: null,
        bankAccountNumber: null,
        taxNumber: null,
        socialSecurityNumber: null,
        emergencyContactName: null,
        emergencyContactPhone: null,
        emergencyContactRelationship: null,
        nationalId: user['nationalId'],
        workLocation: 'Head Office',
        costCenter: 'FIN-001',
        softwareProficiencies: null,
        specializedAreas: null,
        approvalLimits: null,
        workSchedule: null,
        isAuthorizedSignatory: false,
      );

      print('Creating basic profile with minimal data');
      print('Note: User should fill in complete details through the form');

      return await _createAccountant(accountant);
    } catch (error) {
      print('Error creating basic profile from user: $error');
      rethrow;
    }
  }

  Future<Accountant> _createAccountant(Accountant accountant) async {
    try {
      final data = accountant.toJson();

      print('CREATING ACCOUNTANT PROFILE');
      print('Data being sent: $data');

      final response = await dio.post(
        '/v1/nawassco/accounts/accountants',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('CREATE PROFILE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          final newAccountant = Accountant.fromJson(responseData['data']);
          state = AsyncValue.data(newAccountant);
          print('Profile created successfully: ${newAccountant.fullName}');
          return newAccountant;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create profile');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (error) {
      print('DioException creating accountant: ${error.type}');
      print('Error message: ${error.message}');
      if (error.response != null) {
        print('Response status: ${error.response!.statusCode}');
        print('Response data: ${error.response!.data}');
      }
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Error creating accountant profile: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<Accountant> getProfile() async {
    final current = state.value;
    if (current != null) return current;

    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user != null) {
      final email = user['email'];

      if (email != null) {
        final response = await dio.get('/v1/nawassco/accounts/accountants/email/$email');
        if (response.data['success'] == true) {
          return Accountant.fromJson(response.data['data']);
        }
      }
    }

    throw Exception('No accountant profile found');
  }

  Future<Accountant> updateProfile(Map<String, dynamic> data) async {
    try {
      final current = state.value;
      if (current == null) throw Exception('No profile loaded');

      final response = await dio.put('/v1/nawassco/accounts/accountants/${current.id}', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAccountant = Accountant.fromJson(response.data['data']);
        state = AsyncValue.data(updatedAccountant);
        return updatedAccountant;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (error) {
      print('DioException updating profile: ${error.type}');
      print('Error message: ${error.message}');
      if (error.response != null) {
        print('Response status: ${error.response!.statusCode}');
        print('Response data: ${error.response!.data}');
      }
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Update profile error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<String> uploadProfilePicture(List<int> imageBytes, String fileName) async {
    try {
      final current = state.value;
      if (current == null) throw Exception('No profile loaded');

      final formData = FormData.fromMap({
        'profilePicture': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await dio.post(
        '/v1/nawassco/accounts/accountants/${current.id}/profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAccountant = Accountant.fromJson(response.data['data']);
        state = AsyncValue.data(updatedAccountant);
        return updatedAccountant.profilePictureUrl!;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload profile picture');
      }
    } on DioException catch (error) {
      print('DioException uploading profile picture: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Upload profile picture error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<Accountant> addQualification(Map<String, dynamic> data, List<int>? documentBytes, String? fileName) async {
    try {
      final current = state.value;
      if (current == null) throw Exception('No profile loaded');

      final formData = FormData();
      formData.fields.addAll(data.entries.map((e) => MapEntry(e.key, e.value.toString())));

      if (documentBytes != null && fileName != null) {
        formData.files.add(MapEntry(
          'document',
          MultipartFile.fromBytes(documentBytes, filename: fileName),
        ));
      }

      final response = await dio.post(
        '/v1/nawassco/accounts/accountants/${current.id}/qualifications',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAccountant = Accountant.fromJson(response.data['data']);
        state = AsyncValue.data(updatedAccountant);
        return updatedAccountant;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add qualification');
      }
    } on DioException catch (error) {
      print('DioException adding qualification: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Add qualification error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  // Debug methods
  Future<bool> checkProfileExists(String email) async {
    try {
      print('CHECKING PROFILE EXISTENCE FOR: $email');

      final response = await dio.get('/v1/nawassco/accounts/accountants/email/$email');

      print('Check response status: ${response.statusCode}');
      print('Check response data: ${response.data}');

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (error) {
      print('DioException checking profile: ${error.type}');
      if (error.response != null) {
        print('Response status: ${error.response!.statusCode}');
        if (error.response!.statusCode == 404) {
          return false;
        }
      }
      return false;
    } catch (error) {
      print('Error checking profile existence: $error');
      return false;
    }
  }

  Future<void> refreshProfile() async {
    print('FORCE REFRESHING PROFILE');
    await _loadProfile();
  }

  void refresh() => _loadProfile();
}

final accountantProfileProvider = StateNotifierProvider<AccountantProfileProvider, AsyncValue<Accountant?>>(
      (ref) => AccountantProfileProvider(ref, ref.read(dioProvider)),
);

// Accountants Management Provider
class AccountantsManagementProvider extends StateNotifier<AsyncValue<List<Accountant>>> {
  final Ref ref;
  final Dio dio;
  final List<Accountant> _allAccountants = [];
  AccountantFilters _filters = AccountantFilters();
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;
  bool _isLoading = false;

  AccountantsManagementProvider(this.ref, this.dio)
      : super(const AsyncValue.loading()) {
    _loadAccountants();
  }

  List<Accountant> get accountants => _allAccountants;

  AccountantFilters get filters => _filters;

  int get currentPage => _currentPage;

  int get totalPages => (_totalCount / _pageSize).ceil();

  int get totalCount => _totalCount;

  bool get hasNextPage => _currentPage < totalPages;

  bool get hasPreviousPage => _currentPage > 1;

  bool get isLoading => _isLoading;

  Future<void> _loadAccountants() async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      final params = _filters.toQueryParams();
      params['page'] = _currentPage.toString();
      params['limit'] = _pageSize.toString();

      print('Loading accountants with params: $params');

      final response = await dio.get(
          '/v1/nawassco/accounts/accountants',
          queryParameters: params
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        _allAccountants.clear();

        if (data['accountants'] is List && data['accountants'].isNotEmpty) {
          _allAccountants.addAll((data['accountants'] as List)
              .map((json) => Accountant.fromJson(json))
              .toList());
        }

        _totalCount = data['total'] ?? 0;
        state = AsyncValue.data(_allAccountants);
        print('Loaded ${_allAccountants.length} accountants');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load accountants');
      }
    } on DioException catch (error) {
      print('DioException loading accountants: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
    } catch (error) {
      print('Load accountants error: $error');
      state = AsyncValue.error(error, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  Future<Accountant> createAccountant(Accountant accountant) async {
    try {
      final data = accountant.toJson();

      print('CREATING ACCOUNTANT');
      print('Data being sent: $data');

      final response = await dio.post(
        '/v1/nawassco/accounts/accountants',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('CREATE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final newAccountant = Accountant.fromJson(responseData['data']);
          _allAccountants.insert(0, newAccountant);
          state = AsyncValue.data([..._allAccountants]);
          print('Accountant created successfully: ${newAccountant.id}');
          return newAccountant;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create accountant');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (error) {
      print('DioException creating accountant: ${error.type}');
      print('Error message: ${error.message}');
      if (error.response != null) {
        print('Response status: ${error.response!.statusCode}');
        print('Response data: ${error.response!.data}');
      }
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('CREATE ERROR: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<Accountant> updateAccountant(String id, Accountant accountant) async {
    try {
      final data = accountant.toJson();

      print('UPDATING ACCOUNTANT');
      print('ID: $id');
      print('Data: $data');

      final response = await dio.put(
          '/v1/nawassco/accounts/accountants/$id',
          data: data
      );

      print('UPDATE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAccountant = Accountant.fromJson(response.data['data']);

        final index = _allAccountants.indexWhere((a) => a.id == id);
        if (index != -1) {
          _allAccountants[index] = updatedAccountant;
          state = AsyncValue.data([..._allAccountants]);
        }

        return updatedAccountant;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update accountant');
      }
    } on DioException catch (error) {
      print('DioException updating accountant: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Update accountant error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteAccountant(String id) async {
    try {
      print('DELETING ACCOUNTANT');
      print('ID: $id');

      final response = await dio.patch(
          '/v1/nawassco/accounts/accountants/$id/delete'
      );

      print('DELETE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        _allAccountants.removeWhere((a) => a.id == id);
        state = AsyncValue.data([..._allAccountants]);
        print('Accountant deleted successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete accountant');
      }
    } on DioException catch (error) {
      print('DioException deleting accountant: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Delete accountant error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> restoreAccountant(String id) async {
    try {
      print('RESTORING ACCOUNTANT');
      print('ID: $id');

      final response = await dio.patch(
          '/v1/nawassco/accounts/accountants/$id/restore'
      );

      print('RESTORE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _loadAccountants(); // Reload to get updated status
        print('Accountant restored successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore accountant');
      }
    } on DioException catch (error) {
      print('DioException restoring accountant: ${error.type}');
      print('Error message: ${error.message}');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    } catch (error) {
      print('Restore accountant error: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  void setFilters(AccountantFilters filters) {
    _filters = filters;
    _currentPage = 1;
    _loadAccountants();
  }

  void clearFilters() {
    _filters = AccountantFilters();
    _currentPage = 1;
    _loadAccountants();
  }

  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      _loadAccountants();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      _loadAccountants();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      _loadAccountants();
    }
  }

  void refresh() => _loadAccountants();
}

final accountantsManagementProvider = StateNotifierProvider<AccountantsManagementProvider, AsyncValue<List<Accountant>>>(
      (ref) => AccountantsManagementProvider(ref, ref.read(dioProvider)),
);