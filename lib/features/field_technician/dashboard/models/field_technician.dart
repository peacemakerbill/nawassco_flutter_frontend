import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TechnicianStatus {
  available('Available', Icons.check_circle, Colors.green),
  onJob('On Job', Icons.work, Colors.orange),
  onBreak('On Break', Icons.free_breakfast, Colors.blue),
  offDuty('Off Duty', Icons.beach_access, Colors.grey),
  onLeave('On Leave', Icons.airline_seat_individual_suite, Colors.purple),
  training('Training', Icons.school, Colors.indigo),
  onCall('On Call', Icons.phone, Colors.teal),
  emergencyResponse('Emergency Response', Icons.warning, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const TechnicianStatus(this.displayName, this.icon, this.color);
}

enum FieldTechnicianRole {
  fieldOperationsManager(
      'Field Operations Manager', Icons.engineering, Colors.deepPurple),
  seniorFieldSupervisor(
      'Senior Field Supervisor', Icons.supervisor_account, Colors.blue),
  fieldSupervisor('Field Supervisor', Icons.assignment_ind, Colors.lightBlue),
  seniorFieldTechnician('Senior Field Technician', Icons.build, Colors.green),
  fieldTechnician('Field Technician', Icons.handyman, Colors.lightGreen),
  juniorFieldTechnician(
      'Junior Field Technician', Icons.construction, Colors.orange),
  fieldTechnicianTrainee(
      'Field Technician Trainee', Icons.school, Colors.amber),
  specializedTechnician(
      'Specialized Technician', Icons.precision_manufacturing, Colors.pink),
  networkTechnician('Network Technician', Icons.lan, Colors.cyan),
  meterTechnician('Meter Technician', Icons.speed, Colors.deepOrange),
  waterQualityTechnician(
      'Water Quality Technician', Icons.water_drop, Colors.blue);

  final String displayName;
  final IconData icon;
  final Color color;

  const FieldTechnicianRole(this.displayName, this.icon, this.color);
}

class FieldTechnician extends Equatable {
  final String id;
  final String employeeNumber;
  final String userId;

  // Personal Information
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String nationalId;
  final String? profilePictureUrl;

  // Employment Details
  final DateTime hireDate;
  final String department;
  final FieldTechnicianRole jobTitle;
  final TechnicianStatus currentStatus;

  // Field Operations
  final String workZone;
  final List<String> assignedRegions;
  final List<String> specializedAreas;

  // Performance Metrics
  final int jobsCompleted;
  final double onTimeCompletionRate;
  final double customerSatisfaction;
  final double firstTimeFixRate;

  // Equipment
  final String? vehicleAssigned;
  final List<String> toolsAssigned;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FieldTechnician({
    required this.id,
    required this.employeeNumber,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    required this.nationalId,
    this.profilePictureUrl,
    required this.hireDate,
    required this.department,
    required this.jobTitle,
    required this.currentStatus,
    required this.workZone,
    required this.assignedRegions,
    required this.specializedAreas,
    required this.jobsCompleted,
    required this.onTimeCompletionRate,
    required this.customerSatisfaction,
    required this.firstTimeFixRate,
    this.vehicleAssigned,
    required this.toolsAssigned,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  double get performanceScore {
    return (onTimeCompletionRate + customerSatisfaction + firstTimeFixRate) / 3;
  }

  String get performanceLevel {
    if (performanceScore >= 90) return 'Excellent';
    if (performanceScore >= 80) return 'Good';
    if (performanceScore >= 70) return 'Average';
    return 'Needs Improvement';
  }

  Color get performanceColor {
    if (performanceScore >= 90) return Colors.green;
    if (performanceScore >= 80) return Colors.lightGreen;
    if (performanceScore >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  List<Object?> get props => [
        id,
        employeeNumber,
        userId,
        firstName,
        lastName,
        email,
        phone,
        dateOfBirth,
        nationalId,
        profilePictureUrl,
        hireDate,
        department,
        jobTitle,
        currentStatus,
        workZone,
        assignedRegions,
        specializedAreas,
        jobsCompleted,
        onTimeCompletionRate,
        customerSatisfaction,
        firstTimeFixRate,
        vehicleAssigned,
        toolsAssigned,
        isActive,
        createdAt,
        updatedAt,
      ];

  FieldTechnician copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? nationalId,
    String? profilePictureUrl,
    DateTime? hireDate,
    String? department,
    FieldTechnicianRole? jobTitle,
    TechnicianStatus? currentStatus,
    String? workZone,
    List<String>? assignedRegions,
    List<String>? specializedAreas,
    int? jobsCompleted,
    double? onTimeCompletionRate,
    double? customerSatisfaction,
    double? firstTimeFixRate,
    String? vehicleAssigned,
    List<String>? toolsAssigned,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldTechnician(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      hireDate: hireDate ?? this.hireDate,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      currentStatus: currentStatus ?? this.currentStatus,
      workZone: workZone ?? this.workZone,
      assignedRegions: assignedRegions ?? this.assignedRegions,
      specializedAreas: specializedAreas ?? this.specializedAreas,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      onTimeCompletionRate: onTimeCompletionRate ?? this.onTimeCompletionRate,
      customerSatisfaction: customerSatisfaction ?? this.customerSatisfaction,
      firstTimeFixRate: firstTimeFixRate ?? this.firstTimeFixRate,
      vehicleAssigned: vehicleAssigned ?? this.vehicleAssigned,
      toolsAssigned: toolsAssigned ?? this.toolsAssigned,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
