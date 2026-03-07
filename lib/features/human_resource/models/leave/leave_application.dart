import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LeaveType {
  annual_leave,
  sick_leave,
  maternity_leave,
  paternity_leave,
  compassionate_leave,
  study_leave,
  unpaid_leave,
  other_leave
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
  in_progress,
  completed
}

class LeaveApplication {
  final String id;
  final String leaveNumber;
  final String employeeId;
  final String employeeName;
  final String employeeNumber;
  final String department;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String? emergencyContact;
  final String? handoverNotes;
  final String? handoverToId;
  final String? handoverToName;
  final List<String> urgentTasks;
  final LeaveStatus status;
  final DateTime appliedDate;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvedDate;
  final String? rejectionReason;
  final int leaveBalanceBefore;
  final int leaveBalanceAfter;
  final int entitlementYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveApplication({
    required this.id,
    required this.leaveNumber,
    required this.employeeId,
    required this.employeeName,
    required this.employeeNumber,
    required this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.emergencyContact,
    this.handoverNotes,
    this.handoverToId,
    this.handoverToName,
    this.urgentTasks = const [],
    required this.status,
    required this.appliedDate,
    this.approvedById,
    this.approvedByName,
    this.approvedDate,
    this.rejectionReason,
    required this.leaveBalanceBefore,
    required this.leaveBalanceAfter,
    required this.entitlementYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      id: json['_id'] ?? json['id'] ?? '',
      leaveNumber: json['leaveNumber'] ?? '',
      employeeId: json['employee'] is String
          ? json['employee']
          : json['employee']?['_id'] ?? '',
      employeeName: json['employee'] is Map
          ? '${json['employee']['personalDetails']['firstName']} ${json['employee']['personalDetails']['lastName']}'
          : json['employeeName'] ?? '',
      employeeNumber: json['employee'] is Map
          ? json['employee']['employeeNumber'] ?? ''
          : json['employeeNumber'] ?? '',
      department: json['employee'] is Map
          ? json['employee']['jobInformation']['department'] ?? ''
          : json['department'] ?? '',
      leaveType: LeaveType.values.firstWhere(
            (e) => describeEnum(e) == json['leaveType'],
        orElse: () => LeaveType.other_leave,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: json['totalDays'] ?? 0,
      reason: json['reason'] ?? '',
      emergencyContact: json['emergencyContact'],
      handoverNotes: json['handoverNotes'],
      handoverToId: json['handoverTo'] is String
          ? json['handoverTo']
          : json['handoverTo']?['_id'],
      handoverToName: json['handoverTo'] is Map
          ? '${json['handoverTo']['personalDetails']['firstName']} ${json['handoverTo']['personalDetails']['lastName']}'
          : json['handoverToName'],
      urgentTasks: List<String>.from(json['urgentTasks'] ?? []),
      status: LeaveStatus.values.firstWhere(
            (e) => describeEnum(e) == json['status'],
        orElse: () => LeaveStatus.pending,
      ),
      appliedDate: DateTime.parse(json['appliedDate']),
      approvedById: json['approvedBy'] is String
          ? json['approvedBy']
          : json['approvedBy']?['_id'],
      approvedByName: json['approvedBy'] is Map
          ? '${json['approvedBy']['personalDetails']['firstName']} ${json['approvedBy']['personalDetails']['lastName']}'
          : json['approvedByName'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      rejectionReason: json['rejectionReason'],
      leaveBalanceBefore: json['leaveBalanceBefore'] ?? 0,
      leaveBalanceAfter: json['leaveBalanceAfter'] ?? 0,
      entitlementYear: json['entitlementYear'] ?? DateTime.now().year,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employeeId,
      'leaveType': describeEnum(leaveType),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (handoverNotes != null) 'handoverNotes': handoverNotes,
      if (handoverToId != null) 'handoverTo': handoverToId,
      if (urgentTasks.isNotEmpty) 'urgentTasks': urgentTasks,
    };
  }

  String get formattedStartDate => DateFormat('dd MMM yyyy').format(startDate);

  String get formattedEndDate => DateFormat('dd MMM yyyy').format(endDate);

  String get formattedAppliedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(appliedDate);

  String get formattedApprovedDate => approvedDate != null
      ? DateFormat('dd MMM yyyy, HH:mm').format(approvedDate!)
      : '';

  String get displayPeriod => '$formattedStartDate - $formattedEndDate';

  Color get statusColor {
    switch (status) {
      case LeaveStatus.approved:
        return const Color(0xFF10B981);
      case LeaveStatus.rejected:
        return const Color(0xFFEF4444);
      case LeaveStatus.pending:
        return const Color(0xFFF59E0B);
      case LeaveStatus.cancelled:
        return const Color(0xFF6B7280);
      case LeaveStatus.in_progress:
        return const Color(0xFF3B82F6);
      case LeaveStatus.completed:
        return const Color(0xFF8B5CF6);
    }
  }

  String get statusText {
    switch (status) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.cancelled:
        return 'Cancelled';
      case LeaveStatus.in_progress:
        return 'In Progress';
      case LeaveStatus.completed:
        return 'Completed';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.pending:
        return Icons.pending;
      case LeaveStatus.cancelled:
        return Icons.block;
      case LeaveStatus.in_progress:
        return Icons.timelapse;
      case LeaveStatus.completed:
        return Icons.done_all;
    }
  }

  bool get isPending => status == LeaveStatus.pending;

  bool get isApproved => status == LeaveStatus.approved;

  bool get isRejected => status == LeaveStatus.rejected;

  bool get isCancelled => status == LeaveStatus.cancelled;

  bool get canCancel => isPending;

  bool get canEdit => isPending;
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.annual_leave:
        return 'Annual Leave';
      case LeaveType.sick_leave:
        return 'Sick Leave';
      case LeaveType.maternity_leave:
        return 'Maternity Leave';
      case LeaveType.paternity_leave:
        return 'Paternity Leave';
      case LeaveType.compassionate_leave:
        return 'Compassionate Leave';
      case LeaveType.study_leave:
        return 'Study Leave';
      case LeaveType.unpaid_leave:
        return 'Unpaid Leave';
      case LeaveType.other_leave:
        return 'Other Leave';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaveType.annual_leave:
        return Icons.beach_access;
      case LeaveType.sick_leave:
        return Icons.medical_services;
      case LeaveType.maternity_leave:
        return Icons.family_restroom;
      case LeaveType.paternity_leave:
        return Icons.child_care;
      case LeaveType.compassionate_leave:
        return Icons.emoji_emotions;
      case LeaveType.study_leave:
        return Icons.school;
      case LeaveType.unpaid_leave:
        return Icons.money_off;
      case LeaveType.other_leave:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case LeaveType.annual_leave:
        return const Color(0xFF3B82F6);
      case LeaveType.sick_leave:
        return const Color(0xFF10B981);
      case LeaveType.maternity_leave:
        return const Color(0xFF8B5CF6);
      case LeaveType.paternity_leave:
        return const Color(0xFFEC4899);
      case LeaveType.compassionate_leave:
        return const Color(0xFFF59E0B);
      case LeaveType.study_leave:
        return const Color(0xFF6366F1);
      case LeaveType.unpaid_leave:
        return const Color(0xFF6B7280);
      case LeaveType.other_leave:
        return const Color(0xFF374151);
    }
  }
}

extension LeaveStatusExtension on LeaveStatus {
  Color get color {
    switch (this) {
      case LeaveStatus.approved:
        return const Color(0xFF10B981);
      case LeaveStatus.rejected:
        return const Color(0xFFEF4444);
      case LeaveStatus.pending:
        return const Color(0xFFF59E0B);
      case LeaveStatus.cancelled:
        return const Color(0xFF6B7280);
      case LeaveStatus.in_progress:
        return const Color(0xFF3B82F6);
      case LeaveStatus.completed:
        return const Color(0xFF8B5CF6);
    }
  }

  String get displayName {
    switch (this) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.cancelled:
        return 'Cancelled';
      case LeaveStatus.in_progress:
        return 'In Progress';
      case LeaveStatus.completed:
        return 'Completed';
    }
  }
}