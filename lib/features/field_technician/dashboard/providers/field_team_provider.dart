import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../models/field_team.dart';
import '../models/field_technician.dart';

class FieldTeamState {
  final List<FieldTeam> teams;
  final FieldTeam? currentTeam;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? departmentFilter;
  final String? workZoneFilter;
  final bool? activeFilter;

  const FieldTeamState({
    this.teams = const [],
    this.currentTeam,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.departmentFilter,
    this.workZoneFilter,
    this.activeFilter,
  });

  FieldTeamState copyWith({
    List<FieldTeam>? teams,
    FieldTeam? currentTeam,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? departmentFilter,
    String? workZoneFilter,
    bool? activeFilter,
  }) {
    return FieldTeamState(
      teams: teams ?? this.teams,
      currentTeam: currentTeam ?? this.currentTeam,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      workZoneFilter: workZoneFilter ?? this.workZoneFilter,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  List<FieldTeam> get filteredTeams {
    var filtered = teams;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((team) =>
              team.teamCode.toLowerCase().contains(searchQuery.toLowerCase()) ||
              team.teamName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              team.department
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              team.workZones.any((zone) =>
                  zone.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    }

    // Apply department filter
    if (departmentFilter != null) {
      filtered = filtered
          .where((team) => team.department == departmentFilter)
          .toList();
    }

    // Apply work zone filter
    if (workZoneFilter != null) {
      filtered = filtered
          .where((team) => team.workZones.contains(workZoneFilter))
          .toList();
    }

    // Apply active filter
    if (activeFilter != null) {
      filtered =
          filtered.where((team) => team.isActive == activeFilter).toList();
    }

    return filtered;
  }

  List<String> get availableDepartments {
    return teams.map((team) => team.department).toSet().toList();
  }

  List<String> get availableWorkZones {
    return teams.expand((team) => team.workZones).toSet().toList();
  }
}

class FieldTeamProvider extends StateNotifier<FieldTeamState> {
  final Dio dio;
  final Ref ref;

  FieldTeamProvider(this.dio, this.ref) : super(const FieldTeamState());

  // Load all field teams
  Future<void> loadFieldTeams() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/field-teams');

      if (response.data['success'] == true) {
        final List<FieldTeam> teams = (response.data['data']['teams'] as List)
            .map((teamData) => _parseTeamFromJson(teamData))
            .toList();

        state = state.copyWith(
          teams: teams,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load teams',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load teams: $e',
        isLoading: false,
      );
    }
  }

  // Get field team by ID
  Future<void> getFieldTeamById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/field-teams/$id');

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']['fieldTeam']);
        state = state.copyWith(
          currentTeam: team,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load team',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load team: $e',
        isLoading: false,
      );
    }
  }

  // Create field team
  Future<bool> createFieldTeam(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.post('/v1/nawassco/field_technician/field-teams', data: data);

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']['fieldTeam']);
        state = state.copyWith(
          teams: [...state.teams, team],
          currentTeam: team,
          isLoading: false,
        );
        ToastUtils.showSuccessToast('Team created successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create team',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to create team');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create team: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast('Failed to create team: $e');
      return false;
    }
  }

  // Update field team
  Future<bool> updateFieldTeam(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.put('/v1/nawassco/field_technician/field-teams/$id', data: data);

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']['fieldTeam']);
        final updatedTeams =
            state.teams.map((t) => t.id == id ? team : t).toList();

        state = state.copyWith(
          teams: updatedTeams,
          currentTeam: team,
          isLoading: false,
        );
        ToastUtils.showSuccessToast('Team updated successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update team',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to update team');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update team: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast('Failed to update team: $e');
      return false;
    }
  }

  // Delete field team (soft delete)
  Future<bool> deleteFieldTeam(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.delete('/v1/nawassco/field_technician/field-teams/$id');

      if (response.data['success'] == true) {
        final updatedTeams =
            state.teams.where((team) => team.id != id).toList();
        state = state.copyWith(
          teams: updatedTeams,
          currentTeam: null,
          isLoading: false,
        );
        ToastUtils.showSuccessToast('Team deleted successfully');
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete team',
          isLoading: false,
        );
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to delete team');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete team: $e',
        isLoading: false,
      );
      ToastUtils.showErrorToast('Failed to delete team: $e');
      return false;
    }
  }

  // Add team member
  Future<bool> addTeamMember(String teamId, String technicianId) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/field-teams/$teamId/members', data: {
        'technicianId': technicianId,
      });

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']);
        final updatedTeams =
            state.teams.map((t) => t.id == teamId ? team : t).toList();

        state = state.copyWith(
          teams: updatedTeams,
          currentTeam:
              state.currentTeam?.id == teamId ? team : state.currentTeam,
        );
        ToastUtils.showSuccessToast('Team member added successfully');
        return true;
      } else {
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to add team member');
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to add team member: $e');
      return false;
    }
  }

  // Remove team member
  Future<bool> removeTeamMember(String teamId, String technicianId) async {
    try {
      final response =
          await dio.patch('/v1/nawassco/field_technician/field-teams/$teamId/members/remove', data: {
        'technicianId': technicianId,
      });

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']);
        final updatedTeams =
            state.teams.map((t) => t.id == teamId ? team : t).toList();

        state = state.copyWith(
          teams: updatedTeams,
          currentTeam:
              state.currentTeam?.id == teamId ? team : state.currentTeam,
        );
        ToastUtils.showSuccessToast('Team member removed successfully');
        return true;
      } else {
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to remove team member');
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to remove team member: $e');
      return false;
    }
  }

  // Assign vehicle to team
  Future<bool> assignVehicle(String teamId, String vehicleId) async {
    try {
      final response = await dio.patch('/v1/nawassco/field_technician/field-teams/$teamId/vehicles', data: {
        'vehicleId': vehicleId,
      });

      if (response.data['success'] == true) {
        final team = _parseTeamFromJson(response.data['data']);
        final updatedTeams =
            state.teams.map((t) => t.id == teamId ? team : t).toList();

        state = state.copyWith(
          teams: updatedTeams,
          currentTeam:
              state.currentTeam?.id == teamId ? team : state.currentTeam,
        );
        ToastUtils.showSuccessToast('Vehicle assigned successfully');
        return true;
      } else {
        ToastUtils.showErrorToast(
            response.data['message'] ?? 'Failed to assign vehicle');
        return false;
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to assign vehicle: $e');
      return false;
    }
  }

  // Get team workload
  Future<Map<String, dynamic>?> getTeamWorkload(String teamId) async {
    try {
      final response = await dio.get('/v1/nawassco/field_technician/field-teams/$teamId/workload');

      if (response.data['success'] == true) {
        return response.data['data']['workload'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search teams
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set department filter
  void setDepartmentFilter(String? department) {
    state = state.copyWith(departmentFilter: department);
  }

  // Set work zone filter
  void setWorkZoneFilter(String? workZone) {
    state = state.copyWith(workZoneFilter: workZone);
  }

  // Set active filter
  void setActiveFilter(bool? active) {
    state = state.copyWith(activeFilter: active);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      departmentFilter: null,
      workZoneFilter: null,
      activeFilter: null,
    );
  }

  // Clear current team
  void clearCurrentTeam() {
    state = state.copyWith(currentTeam: null);
  }

  // Helper method to parse team from JSON
  FieldTeam _parseTeamFromJson(Map<String, dynamic> json) {
    return FieldTeam(
      id: json['_id'] ?? json['id'],
      teamCode: json['teamCode'],
      teamName: json['teamName'],
      description: json['description'],
      teamLeadId: json['teamLead'] is String
          ? json['teamLead']
          : json['teamLead']?['_id'],
      teamLead: json['teamLead'] is Map
          ? _parseTechnicianFromJson(json['teamLead'])
          : null,
      memberIds: (json['members'] as List? ?? [])
          .map((member) => member is String ? member : member['_id'])
          .cast<String>()
          .toList(),
      members: (json['members'] as List? ?? [])
          .where((member) => member is Map)
          .map((member) => _parseTechnicianFromJson(member))
          .toList(),
      supervisorId: json['supervisor']?['_id'],
      department: json['department'],
      specialization: List<String>.from(json['specialization'] ?? []),
      workZones: List<String>.from(json['workZones'] ?? []),
      performance: TeamPerformance(
        totalJobsCompleted: json['performance']?['totalJobsCompleted'] ?? 0,
        onTimeCompletionRate:
            (json['performance']?['onTimeCompletionRate'] ?? 0).toDouble(),
        qualityScore: (json['performance']?['qualityScore'] ?? 0).toDouble(),
        customerSatisfaction:
            (json['performance']?['customerSatisfaction'] ?? 0).toDouble(),
        efficiency: (json['performance']?['efficiency'] ?? 0).toDouble(),
      ),
      currentWorkload: (json['currentWorkload'] ?? 0).toDouble(),
      workSchedule: TeamSchedule(
        shift: json['workSchedule']?['shift'] ?? 'Day',
        startTime: json['workSchedule']?['startTime'] ?? '08:00',
        endTime: json['workSchedule']?['endTime'] ?? '17:00',
        workingDays: List<String>.from(json['workSchedule']?['workingDays'] ??
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      ),
      availability: TeamAvailability(
        availableMembers: json['availability']?['availableMembers'] ?? 0,
        totalMembers: json['availability']?['totalMembers'] ?? 0,
        status: TeamStatus.values.firstWhere(
          (e) => e.name == json['availability']?['status'],
          orElse: () => TeamStatus.available,
        ),
      ),
      assignedVehicleIds: List<String>.from(
          json['assignedVehicles']?.map((v) => v is String ? v : v['_id']) ??
              []),
      assignedToolIds: List<String>.from(
          json['assignedTools']?.map((t) => t is String ? t : t['_id']) ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  FieldTechnician _parseTechnicianFromJson(Map<String, dynamic> json) {
    return FieldTechnician(
      id: json['_id'] ?? json['id'],
      employeeNumber: json['employeeNumber'] ?? '',
      userId: json['user'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      nationalId: json['nationalId'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      hireDate: DateTime.parse(json['hireDate']),
      department: json['department'] ?? '',
      jobTitle: FieldTechnicianRole.values.firstWhere(
        (e) => e.name == json['jobTitle'],
        orElse: () => FieldTechnicianRole.fieldTechnician,
      ),
      currentStatus: TechnicianStatus.values.firstWhere(
        (e) => e.name == json['currentStatus'],
        orElse: () => TechnicianStatus.available,
      ),
      workZone: json['workZone'] ?? '',
      assignedRegions: List<String>.from(json['assignedRegions'] ?? []),
      specializedAreas: List<String>.from(json['specializedAreas'] ?? []),
      jobsCompleted: json['performance']?['jobsCompleted'] ?? 0,
      onTimeCompletionRate:
          (json['performance']?['onTimeCompletion'] ?? 0).toDouble(),
      customerSatisfaction:
          (json['performance']?['customerSatisfaction'] ?? 0).toDouble(),
      firstTimeFixRate:
          (json['performance']?['firstTimeFixRate'] ?? 0).toDouble(),
      vehicleAssigned: json['vehicleAssigned']?['registrationNumber'],
      toolsAssigned: List<String>.from(
          json['toolsAssigned']?.map((t) => t['tool']?['toolName']).toList() ??
              []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Provider
final fieldTeamProvider =
    StateNotifierProvider<FieldTeamProvider, FieldTeamState>((ref) {
  final dio = ref.read(dioProvider);
  return FieldTeamProvider(dio, ref);
});