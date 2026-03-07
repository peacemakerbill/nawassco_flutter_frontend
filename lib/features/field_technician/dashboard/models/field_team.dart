import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'field_technician.dart';

enum TeamStatus {
  available('Available', Icons.check_circle, Colors.green),
  busy('Busy', Icons.work, Colors.orange),
  overloaded('Overloaded', Icons.warning, Colors.red),
  offline('Offline', Icons.offline_bolt, Colors.grey);

  final String displayName;
  final IconData icon;
  final Color color;

  const TeamStatus(this.displayName, this.icon, this.color);
}

class TeamPerformance extends Equatable {
  final int totalJobsCompleted;
  final double onTimeCompletionRate;
  final double qualityScore;
  final double customerSatisfaction;
  final double efficiency;

  const TeamPerformance({
    this.totalJobsCompleted = 0,
    this.onTimeCompletionRate = 0,
    this.qualityScore = 0,
    this.customerSatisfaction = 0,
    this.efficiency = 0,
  });

  double get overallScore {
    return (onTimeCompletionRate +
            qualityScore +
            customerSatisfaction +
            efficiency) /
        4;
  }

  String get performanceLevel {
    final score = overallScore;
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Average';
    return 'Needs Improvement';
  }

  Color get performanceColor {
    final score = overallScore;
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  List<Object?> get props => [
        totalJobsCompleted,
        onTimeCompletionRate,
        qualityScore,
        customerSatisfaction,
        efficiency,
      ];

  TeamPerformance copyWith({
    int? totalJobsCompleted,
    double? onTimeCompletionRate,
    double? qualityScore,
    double? customerSatisfaction,
    double? efficiency,
  }) {
    return TeamPerformance(
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      onTimeCompletionRate: onTimeCompletionRate ?? this.onTimeCompletionRate,
      qualityScore: qualityScore ?? this.qualityScore,
      customerSatisfaction: customerSatisfaction ?? this.customerSatisfaction,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}

class TeamSchedule extends Equatable {
  final String shift;
  final String startTime;
  final String endTime;
  final List<String> workingDays;

  const TeamSchedule({
    required this.shift,
    required this.startTime,
    required this.endTime,
    required this.workingDays,
  });

  @override
  List<Object?> get props => [shift, startTime, endTime, workingDays];
}

class TeamAvailability extends Equatable {
  final int availableMembers;
  final int totalMembers;
  final TeamStatus status;

  const TeamAvailability({
    required this.availableMembers,
    required this.totalMembers,
    required this.status,
  });

  double get availabilityPercentage {
    return totalMembers > 0 ? (availableMembers / totalMembers) * 100 : 0;
  }

  @override
  List<Object?> get props => [availableMembers, totalMembers, status];
}

class FieldTeam extends Equatable {
  final String id;
  final String teamCode;
  final String teamName;
  final String description;

  // Team Composition
  final String teamLeadId;
  final FieldTechnician? teamLead;
  final List<String> memberIds;
  final List<FieldTechnician> members;
  final String? supervisorId;

  // Team Details
  final String department;
  final List<String> specialization;
  final List<String> workZones;

  // Performance
  final TeamPerformance performance;
  final double currentWorkload;

  // Schedule
  final TeamSchedule workSchedule;
  final TeamAvailability availability;

  // Equipment
  final List<String> assignedVehicleIds;
  final List<String> assignedToolIds;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FieldTeam({
    required this.id,
    required this.teamCode,
    required this.teamName,
    required this.description,
    required this.teamLeadId,
    this.teamLead,
    required this.memberIds,
    this.members = const [],
    this.supervisorId,
    required this.department,
    required this.specialization,
    required this.workZones,
    required this.performance,
    required this.currentWorkload,
    required this.workSchedule,
    required this.availability,
    required this.assignedVehicleIds,
    required this.assignedToolIds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalMembers => memberIds.length;

  bool get hasAvailableCapacity => availability.availableMembers > 0;

  bool get isFullyStaffed => availability.availableMembers == totalMembers;

  String get workloadStatus {
    if (currentWorkload >= 90) return 'Overloaded';
    if (currentWorkload >= 70) return 'High';
    if (currentWorkload >= 50) return 'Moderate';
    return 'Low';
  }

  Color get workloadColor {
    if (currentWorkload >= 90) return Colors.red;
    if (currentWorkload >= 70) return Colors.orange;
    if (currentWorkload >= 50) return Colors.yellow;
    return Colors.green;
  }

  @override
  List<Object?> get props => [
        id,
        teamCode,
        teamName,
        description,
        teamLeadId,
        teamLead,
        memberIds,
        members,
        supervisorId,
        department,
        specialization,
        workZones,
        performance,
        currentWorkload,
        workSchedule,
        availability,
        assignedVehicleIds,
        assignedToolIds,
        isActive,
        createdAt,
        updatedAt,
      ];

  FieldTeam copyWith({
    String? id,
    String? teamCode,
    String? teamName,
    String? description,
    String? teamLeadId,
    FieldTechnician? teamLead,
    List<String>? memberIds,
    List<FieldTechnician>? members,
    String? supervisorId,
    String? department,
    List<String>? specialization,
    List<String>? workZones,
    TeamPerformance? performance,
    double? currentWorkload,
    TeamSchedule? workSchedule,
    TeamAvailability? availability,
    List<String>? assignedVehicleIds,
    List<String>? assignedToolIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldTeam(
      id: id ?? this.id,
      teamCode: teamCode ?? this.teamCode,
      teamName: teamName ?? this.teamName,
      description: description ?? this.description,
      teamLeadId: teamLeadId ?? this.teamLeadId,
      teamLead: teamLead ?? this.teamLead,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
      supervisorId: supervisorId ?? this.supervisorId,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
      workZones: workZones ?? this.workZones,
      performance: performance ?? this.performance,
      currentWorkload: currentWorkload ?? this.currentWorkload,
      workSchedule: workSchedule ?? this.workSchedule,
      availability: availability ?? this.availability,
      assignedVehicleIds: assignedVehicleIds ?? this.assignedVehicleIds,
      assignedToolIds: assignedToolIds ?? this.assignedToolIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
