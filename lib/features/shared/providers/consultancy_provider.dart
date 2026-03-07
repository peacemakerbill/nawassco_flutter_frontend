import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../main.dart';
import '../models/consultancy_model.dart';

class ConsultancyState {
  final List<Consultancy> consultancies;
  final Consultancy? selectedConsultancy;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;
  final ConsultancyStatus? filterStatus;
  final String? searchQuery;

  const ConsultancyState({
    this.consultancies = const [],
    this.selectedConsultancy,
    this.isLoading = false,
    this.error,
    this.stats,
    this.filterStatus,
    this.searchQuery,
  });

  ConsultancyState copyWith({
    List<Consultancy>? consultancies,
    Consultancy? selectedConsultancy,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    ConsultancyStatus? filterStatus,
    String? searchQuery,
  }) {
    return ConsultancyState(
      consultancies: consultancies ?? this.consultancies,
      selectedConsultancy: selectedConsultancy ?? this.selectedConsultancy,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stats: stats ?? this.stats,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Consultancy> get filteredConsultancies {
    var filtered = consultancies;

    if (filterStatus != null) {
      filtered = filtered.where((c) => c.status == filterStatus).toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((c) =>
      c.title.toLowerCase().contains(query) ||
          c.consultancyNumber.toLowerCase().contains(query) ||
          c.client.name.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

class ConsultancyProvider extends StateNotifier<ConsultancyState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  ConsultancyProvider(this.dio, this.scaffoldMessengerKey)
      : super(const ConsultancyState());

  bool get mounted => state != null;

  // CRUD Operations

  Future<void> fetchConsultancies() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      log('Fetching consultancies...');

      final response = await dio.get('/v1/nawassco/services/consultancies');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('consultancies')) {
          final consultancies = (data['consultancies'] as List)
              .map((json) => Consultancy.fromJson(json))
              .toList();

          state = state.copyWith(
            consultancies: consultancies,
            isLoading: false,
          );
          log('Fetched ${consultancies.length} consultancies');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch consultancies');
      }
    } catch (e) {
      log('Error fetching consultancies: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showError(e);
    }
  }

  Future<void> fetchConsultancyStats() async {
    try {
      final response = await dio.get('/v1/nawassco/services/consultancies/stats');

      if (response.data['success'] == true) {
        state = state.copyWith(stats: response.data['data']);
      }
    } catch (e) {
      log('Error fetching stats: $e');
    }
  }

  Future<void> createConsultancy(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);
      log('Creating consultancy: $data');

      final response = await dio.post('/v1/nawassco/services/consultancies', data: data);

      if (response.data['success'] == true) {
        final newConsultancy = Consultancy.fromJson(response.data['data']);
        state = state.copyWith(
          consultancies: [...state.consultancies, newConsultancy],
          isLoading: false,
          selectedConsultancy: newConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Consultancy created successfully!',
          key: scaffoldMessengerKey,
        );
        log('Consultancy created: ${newConsultancy.consultancyNumber}');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create consultancy');
      }
    } catch (e) {
      log('Error creating consultancy: $e');
      state = state.copyWith(isLoading: false);
      _showError(e);
    }
  }

  Future<void> updateConsultancy(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);
      log('Updating consultancy $id: $data');

      final response = await dio.put('/v1/nawassco/services/consultancies/$id', data: data);

      if (response.data['success'] == true) {
        final updatedConsultancy = Consultancy.fromJson(response.data['data']);
        final updatedList = state.consultancies.map((c) =>
        c.id == id ? updatedConsultancy : c
        ).toList();

        state = state.copyWith(
          consultancies: updatedList,
          isLoading: false,
          selectedConsultancy: updatedConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Consultancy updated successfully!',
          key: scaffoldMessengerKey,
        );
        log('Consultancy updated: $id');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update consultancy');
      }
    } catch (e) {
      log('Error updating consultancy: $e');
      state = state.copyWith(isLoading: false);
      _showError(e);
    }
  }

  Future<void> updateConsultancyStatus(String id, ConsultancyStatus status) async {
    try {
      log('Updating consultancy status for $id to $status');

      final response = await dio.patch(
        '/v1/nawassco/services/consultancies/$id/status',
        data: {'status': describeEnum(status).toLowerCase()},
      );

      if (response.data['success'] == true) {
        final updatedConsultancy = Consultancy.fromJson(response.data['data']);
        final updatedList = state.consultancies.map((c) =>
        c.id == id ? updatedConsultancy : c
        ).toList();

        state = state.copyWith(
          consultancies: updatedList,
          selectedConsultancy: updatedConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Status updated to ${status.displayName}',
          key: scaffoldMessengerKey,
        );
        log('Status updated for consultancy: $id');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      log('Error updating status: $e');
      _showError(e);
    }
  }

  Future<void> deleteConsultancy(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      log('Deleting consultancy: $id');

      final response = await dio.delete('/v1/nawassco/services/consultancies/$id');

      if (response.data['success'] == true) {
        final updatedList = state.consultancies.where((c) => c.id != id).toList();
        final shouldClearSelection = state.selectedConsultancy?.id == id;

        state = state.copyWith(
          consultancies: updatedList,
          isLoading: false,
          selectedConsultancy: shouldClearSelection ? null : state.selectedConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Consultancy deleted successfully',
          key: scaffoldMessengerKey,
        );
        log('Consultancy deleted: $id');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete consultancy');
      }
    } catch (e) {
      log('Error deleting consultancy: $e');
      state = state.copyWith(isLoading: false);
      _showError(e);
    }
  }

  Future<void> addTeamMember(String consultancyId, Map<String, dynamic> teamMember) async {
    try {
      log('Adding team member to consultancy: $consultancyId');

      final response = await dio.post(
        '/v1/nawassco/services/consultancies/$consultancyId/team',
        data: teamMember,
      );

      if (response.data['success'] == true) {
        final updatedConsultancy = Consultancy.fromJson(response.data['data']);
        final updatedList = state.consultancies.map((c) =>
        c.id == consultancyId ? updatedConsultancy : c
        ).toList();

        state = state.copyWith(
          consultancies: updatedList,
          selectedConsultancy: updatedConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Team member added successfully!',
          key: scaffoldMessengerKey,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add team member');
      }
    } catch (e) {
      log('Error adding team member: $e');
      _showError(e);
    }
  }

  Future<void> addMilestone(String consultancyId, Map<String, dynamic> milestone) async {
    try {
      log('Adding milestone to consultancy: $consultancyId');

      final response = await dio.post(
        '/v1/nawassco/services/consultancies/$consultancyId/milestones',
        data: milestone,
      );

      if (response.data['success'] == true) {
        final updatedConsultancy = Consultancy.fromJson(response.data['data']);
        final updatedList = state.consultancies.map((c) =>
        c.id == consultancyId ? updatedConsultancy : c
        ).toList();

        state = state.copyWith(
          consultancies: updatedList,
          selectedConsultancy: updatedConsultancy,
        );

        ToastUtils.showSuccessToast(
          'Milestone added successfully!',
          key: scaffoldMessengerKey,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add milestone');
      }
    } catch (e) {
      log('Error adding milestone: $e');
      _showError(e);
    }
  }

  Future<Consultancy?> fetchConsultancyById(String id) async {
    try {
      log('Fetching consultancy by ID: $id');

      final response = await dio.get('/v1/nawassco/services/consultancies/$id');

      if (response.data['success'] == true) {
        final consultancy = Consultancy.fromJson(response.data['data']);
        state = state.copyWith(selectedConsultancy: consultancy);
        return consultancy;
      } else {
        throw Exception(response.data['message'] ?? 'Consultancy not found');
      }
    } catch (e) {
      log('Error fetching consultancy by ID: $e');
      _showError(e);
      return null;
    }
  }

  Future<Consultancy?> fetchConsultancyByNumber(String number) async {
    try {
      log('Fetching consultancy by number: $number');

      final response = await dio.get('/v1/nawassco/services/consultancies/number/$number');

      if (response.data['success'] == true) {
        final consultancy = Consultancy.fromJson(response.data['data']);
        state = state.copyWith(selectedConsultancy: consultancy);
        return consultancy;
      } else {
        throw Exception(response.data['message'] ?? 'Consultancy not found');
      }
    } catch (e) {
      log('Error fetching consultancy by number: $e');
      _showError(e);
      return null;
    }
  }

  void selectConsultancy(Consultancy? consultancy) {
    state = state.copyWith(selectedConsultancy: consultancy);
  }

  void setFilterStatus(ConsultancyStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = state.copyWith(filterStatus: null, searchQuery: null);
  }

  // Private helper methods
  void _showError(dynamic error) {
    String errorMessage = 'An error occurred. Please try again.';

    if (error is DioException) {
      if (error.response?.data is Map) {
        errorMessage = error.response!.data['message'] ?? errorMessage;
      } else if (error.message != null) {
        errorMessage = error.message!;
      }
    } else if (error is String) {
      errorMessage = error;
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
  }
}

// Provider instance
final consultancyProvider = StateNotifierProvider<ConsultancyProvider, ConsultancyState>((ref) {
  final dio = ref.read(dioProvider);
  return ConsultancyProvider(dio, scaffoldMessengerKey);
});