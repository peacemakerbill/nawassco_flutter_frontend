import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/supplier_contact_model.dart';

class SupplierContactState {
  final List<SupplierContact> contacts;
  final SupplierContact? selectedContact;
  final bool isLoading;
  final String? error;

  SupplierContactState({
    this.contacts = const [],
    this.selectedContact,
    this.isLoading = false,
    this.error,
  });

  SupplierContactState copyWith({
    List<SupplierContact>? contacts,
    SupplierContact? selectedContact,
    bool? isLoading,
    String? error,
  }) {
    return SupplierContactState(
      contacts: contacts ?? this.contacts,
      selectedContact: selectedContact ?? this.selectedContact,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SupplierContactProvider extends StateNotifier<SupplierContactState> {
  final Dio dio;

  SupplierContactProvider(this.dio) : super(SupplierContactState());

  // Get all contacts
  Future<void> getAllContacts({Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/contacts', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierContact> contacts = (response.data['data'] as List)
            .map((item) => SupplierContact.fromJson(item))
            .toList();

        state = state.copyWith(
          contacts: contacts,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch contacts',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch contacts: $e',
        isLoading: false,
      );
    }
  }

  // Get contact by ID
  Future<void> getContactById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/contacts/$id');

      if (response.data['success'] == true) {
        final SupplierContact contact = SupplierContact.fromJson(response.data['data']);

        state = state.copyWith(
          selectedContact: contact,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch contact',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch contact: $e',
        isLoading: false,
      );
    }
  }

  // Create contact
  Future<bool> createContact(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/contacts', data: data);

      if (response.data['success'] == true) {
        await getAllContacts();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create contact',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create contact: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update contact
  Future<bool> updateContact(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/supplier/contacts/$id', data: data);

      if (response.data['success'] == true) {
        await getAllContacts();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update contact',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update contact: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete contact
  Future<bool> deleteContact(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.delete('/v1/nawassco/supplier/contacts/$id');

      if (response.data['success'] == true) {
        await getAllContacts();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete contact',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete contact: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Get contacts by supplier
  Future<void> getContactsBySupplier(String supplierId, {Map<String, dynamic>? queryParams}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/supplier/contacts/supplier/$supplierId', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<SupplierContact> contacts = (response.data['data'] as List)
            .map((item) => SupplierContact.fromJson(item))
            .toList();

        state = state.copyWith(
          contacts: contacts,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to fetch contacts by supplier',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch contacts by supplier: $e',
        isLoading: false,
      );
    }
  }

  // Set primary contact
  Future<bool> setPrimaryContact(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/supplier/contacts/$id/set-primary');

      if (response.data['success'] == true) {
        await getAllContacts();
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to set primary contact',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to set primary contact: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected contact
  void clearSelectedContact() {
    state = state.copyWith(selectedContact: null);
  }
}

final supplierContactProvider = StateNotifierProvider<SupplierContactProvider, SupplierContactState>((ref) {
  final dio = ref.read(dioProvider);
  return SupplierContactProvider(dio);
});