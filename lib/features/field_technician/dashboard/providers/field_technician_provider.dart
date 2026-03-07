import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/field_technician.dart';

class FieldTechnicianState {
  final List<FieldTechnician> technicians;
  final FieldTechnician? currentTechnician;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final TechnicianStatus? statusFilter;
  final FieldTechnicianRole? roleFilter;

  const FieldTechnicianState({
    this.technicians = const [],
    this.currentTechnician,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.statusFilter,
    this.roleFilter,
  });

  FieldTechnicianState copyWith({
    List<FieldTechnician>? technicians,
    FieldTechnician? currentTechnician,
    bool? isLoading,
    String? error,
    String? searchQuery,
    TechnicianStatus? statusFilter,
    FieldTechnicianRole? roleFilter,
  }) {
    return FieldTechnicianState(
      technicians: technicians ?? this.technicians,
      currentTechnician: currentTechnician ?? this.currentTechnician,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      roleFilter: roleFilter ?? this.roleFilter,
    );
  }

  List<FieldTechnician> get filteredTechnicians {
    var filtered = technicians;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((tech) =>
      tech.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tech.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tech.employeeNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tech.workZone.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    if (statusFilter != null) {
      filtered = filtered.where((tech) => tech.currentStatus == statusFilter).toList();
    }

    // Apply role filter
    if (roleFilter != null) {
      filtered = filtered.where((tech) => tech.jobTitle == roleFilter).toList();
    }

    return filtered;
  }
}

class FieldTechnicianProvider extends StateNotifier<FieldTechnicianState> {
  final Dio dio;

  FieldTechnicianProvider(this.dio) : super(const FieldTechnicianState());

  // Load all field technicians
  Future<void> loadFieldTechnicians() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/field-technicians');

      if (response.data['success'] == true) {
        final List<FieldTechnician> technicians = (response.data['data']['technicians'] as List)
            .map((techData) => _parseTechnicianFromJson(techData))
            .toList();

        state = state.copyWith(
          technicians: technicians,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load technicians',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load technicians: $e',
        isLoading: false,
      );
    }
  }

  // Load current user's technician profile
  Future<void> loadCurrentTechnicianProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/field-technicians/my-profile');

      if (response.data['success'] == true) {
        final technician = _parseTechnicianFromJson(response.data['data']);
        state = state.copyWith(
          currentTechnician: technician,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load profile',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load profile: $e',
        isLoading: false,
      );
    }
  }

  // Create field technician profile
  Future<bool> createTechnicianProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.post('/v1/nawassco/field_technician/field-technicians', data: data);

      if (response.data['success'] == true) {
        final technician = _parseTechnicianFromJson(response.data['data']['fieldTechnician']);
        state = state.copyWith(
          currentTechnician: technician,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create profile',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create profile: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update field technician profile
  Future<bool> updateTechnicianProfile(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.put('/v1/nawassco/field_technician/field-technicians/$id', data: data);

      if (response.data['success'] == true) {
        final technician = _parseTechnicianFromJson(response.data['data']['fieldTechnician']);

        // Update in technicians list
        final updatedTechnicians = state.technicians.map((tech) =>
        tech.id == id ? technician : tech
        ).toList();

        // Update current technician if it's the same
        final currentTech = state.currentTechnician?.id == id ? technician : state.currentTechnician;

        state = state.copyWith(
          technicians: updatedTechnicians,
          currentTechnician: currentTech,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update profile',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update profile: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update technician status
  Future<bool> updateTechnicianStatus(String id, TechnicianStatus status) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/field-technicians/$id/status', data: {
        'status': status.name,
      });

      if (response.data['success'] == true) {
        // Update in state
        final updatedTechnicians = state.technicians.map((tech) =>
        tech.id == id ? tech.copyWith(currentStatus: status) : tech
        ).toList();

        final currentTech = state.currentTechnician?.id == id
            ? state.currentTechnician!.copyWith(currentStatus: status)
            : state.currentTechnician;

        state = state.copyWith(
          technicians: updatedTechnicians,
          currentTechnician: currentTech,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Search technicians
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set status filter
  void setStatusFilter(TechnicianStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  // Set role filter
  void setRoleFilter(FieldTechnicianRole? role) {
    state = state.copyWith(roleFilter: role);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: null,
      roleFilter: null,
    );
  }

  // Helper method to parse technician from JSON
  FieldTechnician _parseTechnicianFromJson(Map<String, dynamic> json) {
    return FieldTechnician(
      id: json['_id'] ?? json['id'],
      employeeNumber: json['employeeNumber'],
      userId: json['user'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      nationalId: json['nationalId'],
      profilePictureUrl: json['profilePictureUrl'],
      hireDate: DateTime.parse(json['hireDate']),
      department: json['department'],
      jobTitle: FieldTechnicianRole.values.firstWhere(
            (e) => e.name == json['jobTitle'],
        orElse: () => FieldTechnicianRole.fieldTechnician,
      ),
      currentStatus: TechnicianStatus.values.firstWhere(
            (e) => e.name == json['currentStatus'],
        orElse: () => TechnicianStatus.available,
      ),
      workZone: json['workZone'],
      assignedRegions: List<String>.from(json['assignedRegions'] ?? []),
      specializedAreas: List<String>.from(json['specializedAreas'] ?? []),
      jobsCompleted: json['performance']?['jobsCompleted'] ?? 0,
      onTimeCompletionRate: (json['performance']?['onTimeCompletion'] ?? 0).toDouble(),
      customerSatisfaction: (json['performance']?['customerSatisfaction'] ?? 0).toDouble(),
      firstTimeFixRate: (json['performance']?['firstTimeFixRate'] ?? 0).toDouble(),
      vehicleAssigned: json['vehicleAssigned']?['registrationNumber'],
      toolsAssigned: List<String>.from(json['toolsAssigned']?.map((t) => t['tool']?['toolName']).toList() ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Provider
final fieldTechnicianProvider = StateNotifierProvider<FieldTechnicianProvider, FieldTechnicianState>((ref) {
  final dio = ref.read(dioProvider);
  return FieldTechnicianProvider(dio);
});