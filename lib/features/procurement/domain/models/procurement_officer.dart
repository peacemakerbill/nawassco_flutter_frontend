import 'package:flutter/foundation.dart';

class ProcurementOfficer {
  final String id;
  final String employeeNumber;
  final String userId;

  // Personal Information
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String nationalId;

  // Employment Details
  final DateTime hireDate;
  final String department;
  final ProcurementRole jobTitle;
  final EmploymentType employmentType;
  final EmploymentStatus employmentStatus;

  // Procurement Specific Details
  final List<ProcurementQualification> procurementQualifications;
  final List<ProcurementCategory> specializedCategories;
  final int vendorManagementExperience;

  // Authorization & Limits
  final ProcurementApprovalLimits approvalLimits;
  final TenderAuthority tenderAuthority;
  final NegotiationLimits negotiationLimits;

  // Work Details
  final String? supervisorId;
  final String? supervisorName;
  final String costCenter;
  final String workLocation;
  final List<String> assignedRegions;

  // Performance
  final ProcurementPerformance performance;
  final DateTime? lastEvaluationDate;

  // Supplier Relationships
  final List<String> managedSuppliers;
  final bool blacklistAuthority;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProcurementOfficer({
    required this.id,
    required this.employeeNumber,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.nationalId,
    required this.hireDate,
    required this.department,
    required this.jobTitle,
    required this.employmentType,
    required this.employmentStatus,
    required this.procurementQualifications,
    required this.specializedCategories,
    required this.vendorManagementExperience,
    required this.approvalLimits,
    required this.tenderAuthority,
    required this.negotiationLimits,
    this.supervisorId,
    this.supervisorName,
    required this.costCenter,
    required this.workLocation,
    required this.assignedRegions,
    required this.performance,
    this.lastEvaluationDate,
    required this.managedSuppliers,
    required this.blacklistAuthority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProcurementOfficer.fromJson(Map<String, dynamic> json) {
    return ProcurementOfficer(
      id: json['_id'] ?? json['id'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      userId: json['user'] is String ? json['user'] : json['user']?['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nationalId: json['nationalId'] ?? '',
      hireDate: DateTime.parse(json['hireDate']),
      department: json['department'] ?? 'Procurement',
      jobTitle: ProcurementRole.values.firstWhere(
            (e) => e.name == json['jobTitle'],
        orElse: () => ProcurementRole.procurement_officer,
      ),
      employmentType: EmploymentType.values.firstWhere(
            (e) => e.name == json['employmentType'],
        orElse: () => EmploymentType.full_time,
      ),
      employmentStatus: EmploymentStatus.values.firstWhere(
            (e) => e.name == json['employmentStatus'],
        orElse: () => EmploymentStatus.active,
      ),
      procurementQualifications: (json['procurementQualifications'] as List? ?? [])
          .map((qual) => ProcurementQualification.fromJson(qual))
          .toList(),
      specializedCategories: (json['specializedCategories'] as List? ?? [])
          .map((cat) => ProcurementCategory.values.firstWhere(
            (e) => e.name == cat,
        orElse: () => ProcurementCategory.office_supplies,
      ))
          .toList(),
      vendorManagementExperience: json['vendorManagementExperience'] ?? 0,
      approvalLimits: ProcurementApprovalLimits.fromJson(json['approvalLimits'] ?? {}),
      tenderAuthority: TenderAuthority.fromJson(json['tenderAuthority'] ?? {}),
      negotiationLimits: NegotiationLimits.fromJson(json['negotiationLimits'] ?? {}),
      supervisorId: json['supervisor'] is String ? json['supervisor'] : json['supervisor']?['_id'],
      supervisorName: json['supervisor'] is String ? null : json['supervisor']?['firstName'] + ' ' + json['supervisor']?['lastName'],
      costCenter: json['costCenter'] ?? '',
      workLocation: json['workLocation'] ?? '',
      assignedRegions: List<String>.from(json['assignedRegions'] ?? []),
      performance: ProcurementPerformance.fromJson(json['performance'] ?? {}),
      lastEvaluationDate: json['lastEvaluationDate'] != null ? DateTime.parse(json['lastEvaluationDate']) : null,
      managedSuppliers: (json['managedSuppliers'] as List? ?? [])
          .map<String>((supplier) => supplier is String ? supplier : supplier['_id']?.toString() ?? '')
          .toList(),
      blacklistAuthority: json['blacklistAuthority'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeNumber': employeeNumber,
      'user': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nationalId': nationalId,
      'hireDate': hireDate.toIso8601String(),
      'department': department,
      'jobTitle': jobTitle.name,
      'employmentType': employmentType.name,
      'employmentStatus': employmentStatus.name,
      'procurementQualifications': procurementQualifications.map((q) => q.toJson()).toList(),
      'specializedCategories': specializedCategories.map((c) => c.name).toList(),
      'vendorManagementExperience': vendorManagementExperience,
      'approvalLimits': approvalLimits.toJson(),
      'tenderAuthority': tenderAuthority.toJson(),
      'negotiationLimits': negotiationLimits.toJson(),
      'supervisor': supervisorId,
      'costCenter': costCenter,
      'workLocation': workLocation,
      'assignedRegions': assignedRegions,
      'performance': performance.toJson(),
      'managedSuppliers': managedSuppliers,
      'blacklistAuthority': blacklistAuthority,
    };
  }

  String get fullName => '$firstName $lastName';

  ProcurementOfficer copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? nationalId,
    DateTime? hireDate,
    String? department,
    ProcurementRole? jobTitle,
    EmploymentType? employmentType,
    EmploymentStatus? employmentStatus,
    List<ProcurementQualification>? procurementQualifications,
    List<ProcurementCategory>? specializedCategories,
    int? vendorManagementExperience,
    ProcurementApprovalLimits? approvalLimits,
    TenderAuthority? tenderAuthority,
    NegotiationLimits? negotiationLimits,
    String? supervisorId,
    String? supervisorName,
    String? costCenter,
    String? workLocation,
    List<String>? assignedRegions,
    ProcurementPerformance? performance,
    DateTime? lastEvaluationDate,
    List<String>? managedSuppliers,
    bool? blacklistAuthority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProcurementOfficer(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      hireDate: hireDate ?? this.hireDate,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      employmentType: employmentType ?? this.employmentType,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      procurementQualifications: procurementQualifications ?? this.procurementQualifications,
      specializedCategories: specializedCategories ?? this.specializedCategories,
      vendorManagementExperience: vendorManagementExperience ?? this.vendorManagementExperience,
      approvalLimits: approvalLimits ?? this.approvalLimits,
      tenderAuthority: tenderAuthority ?? this.tenderAuthority,
      negotiationLimits: negotiationLimits ?? this.negotiationLimits,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      costCenter: costCenter ?? this.costCenter,
      workLocation: workLocation ?? this.workLocation,
      assignedRegions: assignedRegions ?? this.assignedRegions,
      performance: performance ?? this.performance,
      lastEvaluationDate: lastEvaluationDate ?? this.lastEvaluationDate,
      managedSuppliers: managedSuppliers ?? this.managedSuppliers,
      blacklistAuthority: blacklistAuthority ?? this.blacklistAuthority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProcurementQualification {
  final String qualification;
  final String issuingBody;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String documentUrl;
  final QualificationStatus status;

  ProcurementQualification({
    required this.qualification,
    required this.issuingBody,
    required this.certificateNumber,
    required this.issueDate,
    this.expiryDate,
    required this.documentUrl,
    required this.status,
  });

  factory ProcurementQualification.fromJson(Map<String, dynamic> json) {
    return ProcurementQualification(
      qualification: json['qualification'] ?? '',
      issuingBody: json['issuingBody'] ?? '',
      certificateNumber: json['certificateNumber'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      documentUrl: json['documentUrl'] ?? '',
      status: QualificationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => QualificationStatus.valid,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualification': qualification,
      'issuingBody': issuingBody,
      'certificateNumber': certificateNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'documentUrl': documentUrl,
      'status': status.name,
    };
  }
}

class ProcurementApprovalLimits {
  final double purchaseRequisition;
  final double purchaseOrder;
  final double contract;
  final double emergencyProcurement;
  final double spotPurchase;

  ProcurementApprovalLimits({
    required this.purchaseRequisition,
    required this.purchaseOrder,
    required this.contract,
    required this.emergencyProcurement,
    required this.spotPurchase,
  });

  factory ProcurementApprovalLimits.fromJson(Map<String, dynamic> json) {
    return ProcurementApprovalLimits(
      purchaseRequisition: (json['purchaseRequisition'] ?? 0).toDouble(),
      purchaseOrder: (json['purchaseOrder'] ?? 0).toDouble(),
      contract: (json['contract'] ?? 0).toDouble(),
      emergencyProcurement: (json['emergencyProcurement'] ?? 0).toDouble(),
      spotPurchase: (json['spotPurchase'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseRequisition': purchaseRequisition,
      'purchaseOrder': purchaseOrder,
      'contract': contract,
      'emergencyProcurement': emergencyProcurement,
      'spotPurchase': spotPurchase,
    };
  }
}

class TenderAuthority {
  final bool canOpenTenders;
  final bool canEvaluateTenders;
  final bool canAwardTenders;
  final double tenderValueLimit;
  final bool canApproveBidders;

  TenderAuthority({
    required this.canOpenTenders,
    required this.canEvaluateTenders,
    required this.canAwardTenders,
    required this.tenderValueLimit,
    required this.canApproveBidders,
  });

  factory TenderAuthority.fromJson(Map<String, dynamic> json) {
    return TenderAuthority(
      canOpenTenders: json['canOpenTenders'] ?? false,
      canEvaluateTenders: json['canEvaluateTenders'] ?? false,
      canAwardTenders: json['canAwardTenders'] ?? false,
      tenderValueLimit: (json['tenderValueLimit'] ?? 0).toDouble(),
      canApproveBidders: json['canApproveBidders'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canOpenTenders': canOpenTenders,
      'canEvaluateTenders': canEvaluateTenders,
      'canAwardTenders': canAwardTenders,
      'tenderValueLimit': tenderValueLimit,
      'canApproveBidders': canApproveBidders,
    };
  }
}

class NegotiationLimits {
  final double priceNegotiation;
  final bool termsNegotiation;
  final bool contractModification;

  NegotiationLimits({
    required this.priceNegotiation,
    required this.termsNegotiation,
    required this.contractModification,
  });

  factory NegotiationLimits.fromJson(Map<String, dynamic> json) {
    return NegotiationLimits(
      priceNegotiation: (json['priceNegotiation'] ?? 0).toDouble(),
      termsNegotiation: json['termsNegotiation'] ?? false,
      contractModification: json['contractModification'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceNegotiation': priceNegotiation,
      'termsNegotiation': termsNegotiation,
      'contractModification': contractModification,
    };
  }
}

class ProcurementPerformance {
  final double costSavings;
  final double procurementCycleTime;
  final double supplierPerformance;
  final double complianceRate;
  final double contractManagement;
  final double overallRating;

  ProcurementPerformance({
    required this.costSavings,
    required this.procurementCycleTime,
    required this.supplierPerformance,
    required this.complianceRate,
    required this.contractManagement,
    required this.overallRating,
  });

  factory ProcurementPerformance.fromJson(Map<String, dynamic> json) {
    return ProcurementPerformance(
      costSavings: (json['costSavings'] ?? 0).toDouble(),
      procurementCycleTime: (json['procurementCycleTime'] ?? 0).toDouble(),
      supplierPerformance: (json['supplierPerformance'] ?? 0).toDouble(),
      complianceRate: (json['complianceRate'] ?? 0).toDouble(),
      contractManagement: (json['contractManagement'] ?? 0).toDouble(),
      overallRating: (json['overallRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'costSavings': costSavings,
      'procurementCycleTime': procurementCycleTime,
      'supplierPerformance': supplierPerformance,
      'complianceRate': complianceRate,
      'contractManagement': contractManagement,
      'overallRating': overallRating,
    };
  }
}

enum ProcurementRole {
  procurement_manager,
  senior_procurement_officer,
  procurement_officer,
  junior_procurement_officer,
  buyer,
  contracts_officer,
  tender_officer,
  supplier_relationship_manager,
  inventory_controller
}

enum ProcurementCategory {
  water_treatment_chemicals,
  pipes_fittings,
  pumping_equipment,
  construction_materials,
  office_supplies,
  vehicles_equipment,
  it_equipment,
  consultancy_services,
  maintenance_services,
  facilities_management
}

enum EmploymentType {
  full_time,
  part_time,
  contract,
  temporary,
  intern,
  consultant
}

enum EmploymentStatus {
  active,
  inactive,
  suspended,
  terminated,
  retired,
  on_leave
}

enum QualificationStatus {
  valid,
  expired,
  renewal_pending,
  suspended,
  revoked
}