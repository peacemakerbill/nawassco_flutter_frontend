import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/supplier_contact_model.dart';
import '../models/supplier_evaluation_model.dart';
import '../models/supplier_model.dart';

class SupplierProfileState {
  final Supplier? supplier;
  final List<SupplierContact> contacts;
  final List<SupplierEvaluation> evaluations;
  final bool isLoading;
  final String? error;
  final bool isUpdating;
  final int selectedTab;

  SupplierProfileState({
    this.supplier,
    this.contacts = const [],
    this.evaluations = const [],
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
    this.selectedTab = 0,
  });

  SupplierProfileState copyWith({
    Supplier? supplier,
    List<SupplierContact>? contacts,
    List<SupplierEvaluation>? evaluations,
    bool? isLoading,
    String? error,
    bool? isUpdating,
    int? selectedTab,
  }) {
    return SupplierProfileState(
      supplier: supplier ?? this.supplier,
      contacts: contacts ?? this.contacts,
      evaluations: evaluations ?? this.evaluations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class SupplierProfileProvider extends StateNotifier<SupplierProfileState> {
  final Dio dio;
  final Ref ref;

  SupplierProfileProvider(this.dio, this.ref) : super(SupplierProfileState());

  // Get supplier profile by email from auth
  Future<void> getSupplierProfileByEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // First, find supplier by email
      final searchResponse = await dio.get('/v1/nawassco/supplier/suppliers', queryParameters: {
        'search': email,
      });

      if (searchResponse.data['success'] == true && searchResponse.data['data'].isNotEmpty) {
        final supplierData = searchResponse.data['data'].firstWhere(
              (item) => item['contactDetails']['primaryEmail'] == email,
          orElse: () => searchResponse.data['data'].first,
        );

        final Supplier supplier = Supplier.fromJson(supplierData);

        state = state.copyWith(
          supplier: supplier,
          isLoading: false,
        );

        // Load related data
        await Future.wait([
          getSupplierContacts(supplier.id),
          getSupplierEvaluations(supplier.id),
        ]);
      } else {
        state = state.copyWith(
          error: 'Supplier profile not found for email: $email',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch profile: $e',
        isLoading: false,
      );
    }
  }

  // Get supplier contacts
  Future<void> getSupplierContacts(String supplierId) async {
    try {
      final response = await dio.get('/v1/nawassco/supplier/contacts/supplier/$supplierId');

      if (response.data['success'] == true) {
        final List<SupplierContact> contacts = (response.data['data'] as List)
            .map((item) => SupplierContact.fromJson(item))
            .toList();

        state = state.copyWith(contacts: contacts);
      }
    } catch (e) {
      print('Failed to fetch contacts: $e');
    }
  }

  // Get supplier evaluations
  Future<void> getSupplierEvaluations(String supplierId) async {
    try {
      final response = await dio.get('/v1/nawassco/supplier/evaluations/supplier/$supplierId');

      if (response.data['success'] == true) {
        final List<SupplierEvaluation> evaluations = (response.data['data'] as List)
            .map((item) => SupplierEvaluation.fromJson(item))
            .toList();

        state = state.copyWith(evaluations: evaluations);
      }
    } catch (e) {
      print('Failed to fetch evaluations: $e');
    }
  }

  // Update supplier basic information
  Future<bool> updateSupplierProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      if (state.supplier == null) {
        state = state.copyWith(
          error: 'No supplier profile loaded',
          isUpdating: false,
        );
        return false;
      }

      final response = await dio.patch(
        '/v1/nawassco/supplier/suppliers/${state.supplier!.id}',
        data: data,
      );

      if (response.data['success'] == true) {
        // Refresh the profile
        final authState = ref.read(authProvider);
        if (authState.user?['email'] != null) {
          await getSupplierProfileByEmail(authState.user!['email']);
        }
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update profile',
          isUpdating: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update profile: $e',
        isUpdating: false,
      );
      return false;
    }
  }

  // Update contact information
  Future<bool> updateContact(String contactId, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.patch(
        '/v1/nawassco/supplier/contacts/$contactId',
        data: data,
      );

      if (response.data['success'] == true) {
        // Refresh contacts
        if (state.supplier != null) {
          await getSupplierContacts(state.supplier!.id);
        }
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update contact',
          isUpdating: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update contact: $e',
        isUpdating: false,
      );
      return false;
    }
  }

  // Add new contact
  Future<bool> addContact(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/contacts', data: data);

      if (response.data['success'] == true) {
        // Refresh contacts
        if (state.supplier != null) {
          await getSupplierContacts(state.supplier!.id);
        }
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to add contact',
          isUpdating: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to add contact: $e',
        isUpdating: false,
      );
      return false;
    }
  }

  // Set primary contact
  Future<bool> setPrimaryContact(String contactId) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/contacts/$contactId/set-primary');

      if (response.data['success'] == true) {
        // Refresh contacts
        if (state.supplier != null) {
          await getSupplierContacts(state.supplier!.id);
        }
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to set primary contact',
          isUpdating: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to set primary contact: $e',
        isUpdating: false,
      );
      return false;
    }
  }

  // Delete contact
  Future<bool> deleteContact(String contactId) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await dio.delete('/v1/nawassco/supplier/contacts/$contactId');

      if (response.data['success'] == true) {
        // Refresh contacts
        if (state.supplier != null) {
          await getSupplierContacts(state.supplier!.id);
        }
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete contact',
          isUpdating: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete contact: $e',
        isUpdating: false,
      );
      return false;
    }
  }

  // Change tab
  void setSelectedTab(int tabIndex) {
    state = state.copyWith(selectedTab: tabIndex);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final supplierProfileProvider = StateNotifierProvider<SupplierProfileProvider, SupplierProfileState>((ref) {
  final dio = ref.read(dioProvider);
  return SupplierProfileProvider(dio, ref);
});