class StoreManager {
  final String id;
  final String employeeNumber;
  final String userId;

  // Personal Information
  final PersonalDetails personalDetails;
  final ContactInformation contactInformation;
  final List<EmergencyContact> emergencyContacts;

  // Employment Details
  final StoreEmploymentDetails employmentDetails;
  final StoreJobInformation jobInformation;
  final StoreCompensation compensation;

  // Stores Management Specific Details
  final StoreManagerRole storeManagerRole;
  final StoreManagementLevel managementLevel;
  final List<String> assignedWarehouses;
  final String department;

  // Inventory Management Authority
  final InventoryAuthority inventoryAuthority;
  final StoreApprovalLimits approvalLimits;
  final List<StoreSystemAccess> systemAccess;

  // Team & Reporting
  final List<String> storeStaff;
  final List<StoreReportingStaff> reportingStaff;
  final StoreReportingStructure reportingStructure;

  // Performance & Objectives
  final StoreManagerPerformance performance;
  final List<StoreObjective> storeObjectives;
  final List<StoreKRA> keyResultAreas;

  // Operational Responsibilities
  final List<OperationalResponsibility> operationalResponsibilities;
  final List<QualityResponsibility> qualityResponsibilities;
  final List<SafetyResponsibility> safetyResponsibilities;

  // Procurement & Vendor Management
  final ProcurementAuthority procurementAuthority;
  final VendorManagement vendorManagement;
  final List<SupplierRelation> supplierRelations;

  // Stock Control & Management
  final StockControlAuthority stockControlAuthority;
  final List<InventoryAccuracyTarget> inventoryAccuracyTargets;
  final List<StockTakeResponsibility> stockTakeResponsibilities;

  // Development & Training
  final StoreDevelopmentPlan developmentPlan;
  final List<TechnicalTraining> technicalTraining;
  final List<StoreCertification> certifications;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreManager({
    required this.id,
    required this.employeeNumber,
    required this.userId,
    required this.personalDetails,
    required this.contactInformation,
    required this.emergencyContacts,
    required this.employmentDetails,
    required this.jobInformation,
    required this.compensation,
    required this.storeManagerRole,
    required this.managementLevel,
    required this.assignedWarehouses,
    required this.department,
    required this.inventoryAuthority,
    required this.approvalLimits,
    required this.systemAccess,
    required this.storeStaff,
    required this.reportingStaff,
    required this.reportingStructure,
    required this.performance,
    required this.storeObjectives,
    required this.keyResultAreas,
    required this.operationalResponsibilities,
    required this.qualityResponsibilities,
    required this.safetyResponsibilities,
    required this.procurementAuthority,
    required this.vendorManagement,
    required this.supplierRelations,
    required this.stockControlAuthority,
    required this.inventoryAccuracyTargets,
    required this.stockTakeResponsibilities,
    required this.developmentPlan,
    required this.technicalTraining,
    required this.certifications,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreManager.fromJson(Map<String, dynamic> json) {
    return StoreManager(
      id: json['_id'] ?? json['id'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      userId: json['user'] is String ? json['user'] : json['user']?['_id'] ?? '',
      personalDetails: PersonalDetails.fromJson(json['personalDetails'] ?? {}),
      contactInformation: ContactInformation.fromJson(json['contactInformation'] ?? {}),
      emergencyContacts: (json['emergencyContacts'] as List? ?? [])
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
      employmentDetails: StoreEmploymentDetails.fromJson(json['employmentDetails'] ?? {}),
      jobInformation: StoreJobInformation.fromJson(json['jobInformation'] ?? {}),
      compensation: StoreCompensation.fromJson(json['compensation'] ?? {}),
      storeManagerRole: StoreManagerRole.values.firstWhere(
            (e) => e.name == (json['storeManagerRole'] ?? '').toUpperCase(),
        orElse: () => StoreManagerRole.STORES_MANAGER,
      ),
      managementLevel: StoreManagementLevel.values.firstWhere(
            (e) => e.name == (json['managementLevel'] ?? '').toUpperCase(),
        orElse: () => StoreManagementLevel.OPERATIONAL_MANAGEMENT,
      ),
      assignedWarehouses: List<String>.from(json['assignedWarehouses'] ?? []),
      department: json['department'] ?? 'Stores',
      inventoryAuthority: InventoryAuthority.fromJson(json['inventoryAuthority'] ?? {}),
      approvalLimits: StoreApprovalLimits.fromJson(json['approvalLimits'] ?? {}),
      systemAccess: (json['systemAccess'] as List? ?? [])
          .map((e) => StoreSystemAccess.fromJson(e))
          .toList(),
      storeStaff: List<String>.from(json['storeStaff'] ?? []),
      reportingStaff: (json['reportingStaff'] as List? ?? [])
          .map((e) => StoreReportingStaff.fromJson(e))
          .toList(),
      reportingStructure: StoreReportingStructure.fromJson(json['reportingStructure'] ?? {}),
      performance: StoreManagerPerformance.fromJson(json['performance'] ?? {}),
      storeObjectives: (json['storeObjectives'] as List? ?? [])
          .map((e) => StoreObjective.fromJson(e))
          .toList(),
      keyResultAreas: (json['keyResultAreas'] as List? ?? [])
          .map((e) => StoreKRA.fromJson(e))
          .toList(),
      operationalResponsibilities: (json['operationalResponsibilities'] as List? ?? [])
          .map((e) => OperationalResponsibility.fromJson(e))
          .toList(),
      qualityResponsibilities: (json['qualityResponsibilities'] as List? ?? [])
          .map((e) => QualityResponsibility.fromJson(e))
          .toList(),
      safetyResponsibilities: (json['safetyResponsibilities'] as List? ?? [])
          .map((e) => SafetyResponsibility.fromJson(e))
          .toList(),
      procurementAuthority: ProcurementAuthority.fromJson(json['procurementAuthority'] ?? {}),
      vendorManagement: VendorManagement.fromJson(json['vendorManagement'] ?? {}),
      supplierRelations: (json['supplierRelations'] as List? ?? [])
          .map((e) => SupplierRelation.fromJson(e))
          .toList(),
      stockControlAuthority: StockControlAuthority.fromJson(json['stockControlAuthority'] ?? {}),
      inventoryAccuracyTargets: (json['inventoryAccuracyTargets'] as List? ?? [])
          .map((e) => InventoryAccuracyTarget.fromJson(e))
          .toList(),
      stockTakeResponsibilities: (json['stockTakeResponsibilities'] as List? ?? [])
          .map((e) => StockTakeResponsibility.fromJson(e))
          .toList(),
      developmentPlan: StoreDevelopmentPlan.fromJson(json['developmentPlan'] ?? {}),
      technicalTraining: (json['technicalTraining'] as List? ?? [])
          .map((e) => TechnicalTraining.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
          .map((e) => StoreCertification.fromJson(e))
          .toList(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeNumber': employeeNumber,
      'user': userId,
      'personalDetails': personalDetails.toJson(),
      'contactInformation': contactInformation.toJson(),
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'employmentDetails': employmentDetails.toJson(),
      'jobInformation': jobInformation.toJson(),
      'compensation': compensation.toJson(),
      'storeManagerRole': storeManagerRole.name,
      'managementLevel': managementLevel.name,
      'assignedWarehouses': assignedWarehouses,
      'department': department,
      'inventoryAuthority': inventoryAuthority.toJson(),
      'approvalLimits': approvalLimits.toJson(),
      'systemAccess': systemAccess.map((e) => e.toJson()).toList(),
      'storeStaff': storeStaff,
      'reportingStaff': reportingStaff.map((e) => e.toJson()).toList(),
      'reportingStructure': reportingStructure.toJson(),
      'performance': performance.toJson(),
      'storeObjectives': storeObjectives.map((e) => e.toJson()).toList(),
      'keyResultAreas': keyResultAreas.map((e) => e.toJson()).toList(),
      'operationalResponsibilities': operationalResponsibilities.map((e) => e.toJson()).toList(),
      'qualityResponsibilities': qualityResponsibilities.map((e) => e.toJson()).toList(),
      'safetyResponsibilities': safetyResponsibilities.map((e) => e.toJson()).toList(),
      'procurementAuthority': procurementAuthority.toJson(),
      'vendorManagement': vendorManagement.toJson(),
      'supplierRelations': supplierRelations.map((e) => e.toJson()).toList(),
      'stockControlAuthority': stockControlAuthority.toJson(),
      'inventoryAccuracyTargets': inventoryAccuracyTargets.map((e) => e.toJson()).toList(),
      'stockTakeResponsibilities': stockTakeResponsibilities.map((e) => e.toJson()).toList(),
      'developmentPlan': developmentPlan.toJson(),
      'technicalTraining': technicalTraining.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StoreManager copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    PersonalDetails? personalDetails,
    ContactInformation? contactInformation,
    List<EmergencyContact>? emergencyContacts,
    StoreEmploymentDetails? employmentDetails,
    StoreJobInformation? jobInformation,
    StoreCompensation? compensation,
    StoreManagerRole? storeManagerRole,
    StoreManagementLevel? managementLevel,
    List<String>? assignedWarehouses,
    String? department,
    InventoryAuthority? inventoryAuthority,
    StoreApprovalLimits? approvalLimits,
    List<StoreSystemAccess>? systemAccess,
    List<String>? storeStaff,
    List<StoreReportingStaff>? reportingStaff,
    StoreReportingStructure? reportingStructure,
    StoreManagerPerformance? performance,
    List<StoreObjective>? storeObjectives,
    List<StoreKRA>? keyResultAreas,
    List<OperationalResponsibility>? operationalResponsibilities,
    List<QualityResponsibility>? qualityResponsibilities,
    List<SafetyResponsibility>? safetyResponsibilities,
    ProcurementAuthority? procurementAuthority,
    VendorManagement? vendorManagement,
    List<SupplierRelation>? supplierRelations,
    StockControlAuthority? stockControlAuthority,
    List<InventoryAccuracyTarget>? inventoryAccuracyTargets,
    List<StockTakeResponsibility>? stockTakeResponsibilities,
    StoreDevelopmentPlan? developmentPlan,
    List<TechnicalTraining>? technicalTraining,
    List<StoreCertification>? certifications,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreManager(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      userId: userId ?? this.userId,
      personalDetails: personalDetails ?? this.personalDetails,
      contactInformation: contactInformation ?? this.contactInformation,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      employmentDetails: employmentDetails ?? this.employmentDetails,
      jobInformation: jobInformation ?? this.jobInformation,
      compensation: compensation ?? this.compensation,
      storeManagerRole: storeManagerRole ?? this.storeManagerRole,
      managementLevel: managementLevel ?? this.managementLevel,
      assignedWarehouses: assignedWarehouses ?? this.assignedWarehouses,
      department: department ?? this.department,
      inventoryAuthority: inventoryAuthority ?? this.inventoryAuthority,
      approvalLimits: approvalLimits ?? this.approvalLimits,
      systemAccess: systemAccess ?? this.systemAccess,
      storeStaff: storeStaff ?? this.storeStaff,
      reportingStaff: reportingStaff ?? this.reportingStaff,
      reportingStructure: reportingStructure ?? this.reportingStructure,
      performance: performance ?? this.performance,
      storeObjectives: storeObjectives ?? this.storeObjectives,
      keyResultAreas: keyResultAreas ?? this.keyResultAreas,
      operationalResponsibilities: operationalResponsibilities ?? this.operationalResponsibilities,
      qualityResponsibilities: qualityResponsibilities ?? this.qualityResponsibilities,
      safetyResponsibilities: safetyResponsibilities ?? this.safetyResponsibilities,
      procurementAuthority: procurementAuthority ?? this.procurementAuthority,
      vendorManagement: vendorManagement ?? this.vendorManagement,
      supplierRelations: supplierRelations ?? this.supplierRelations,
      stockControlAuthority: stockControlAuthority ?? this.stockControlAuthority,
      inventoryAccuracyTargets: inventoryAccuracyTargets ?? this.inventoryAccuracyTargets,
      stockTakeResponsibilities: stockTakeResponsibilities ?? this.stockTakeResponsibilities,
      developmentPlan: developmentPlan ?? this.developmentPlan,
      technicalTraining: technicalTraining ?? this.technicalTraining,
      certifications: certifications ?? this.certifications,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Enums
enum StoreManagerRole {
  CHIEF_STORES_OFFICER,
  SENIOR_STORES_MANAGER,
  STORES_MANAGER,
  ASSISTANT_STORES_MANAGER,
  WAREHOUSE_MANAGER,
  INVENTORY_MANAGER
}

enum StoreManagementLevel {
  EXECUTIVE,
  SENIOR_MANAGEMENT,
  MIDDLE_MANAGEMENT,
  OPERATIONAL_MANAGEMENT
}

enum StoreSystem {
  INVENTORY_MANAGEMENT,
  WAREHOUSE_MANAGEMENT,
  PROCUREMENT_SYSTEM,
  ERP_SYSTEM,
  QUALITY_MANAGEMENT,
  SAFETY_MANAGEMENT
}

enum StoreAccessLevel {
  VIEW,
  OPERATOR,
  SUPERVISOR,
  ADMIN
}

enum StoreStaffRole {
  STORE_KEEPER,
  STORE_CLERK,
  WAREHOUSE_OPERATOR,
  INVENTORY_CONTROLLER,
  QUALITY_INSPECTOR
}

enum ObjectiveStatus {
  NOT_STARTED,
  IN_PROGRESS,
  ON_TRACK,
  AT_RISK,
  COMPLETED
}

enum Gender {
  MALE,
  FEMALE,
  OTHER
}

enum EmploymentType {
  FULL_TIME,
  PART_TIME,
  CONTRACT,
  TEMPORARY,
  INTERNSHIP
}

enum EmploymentStatus {
  ACTIVE,
  ON_LEAVE,
  SUSPENDED,
  TERMINATED,
  RETIRED
}

// Sub-models
class PersonalDetails {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String nationalId;

  PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationalId,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      gender: Gender.values.firstWhere(
            (e) => e.name == (json['gender'] ?? '').toUpperCase(),
        orElse: () => Gender.OTHER,
      ),
      nationalId: json['nationalId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'nationalId': nationalId,
    };
  }

  PersonalDetails copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? nationalId,
  }) {
    return PersonalDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationalId: nationalId ?? this.nationalId,
    );
  }
}

class ContactInformation {
  final String workEmail;
  final String personalEmail;
  final String workPhone;
  final String personalPhone;
  final String officeLocation;

  ContactInformation({
    required this.workEmail,
    required this.personalEmail,
    required this.workPhone,
    required this.personalPhone,
    required this.officeLocation,
  });

  factory ContactInformation.fromJson(Map<String, dynamic> json) {
    return ContactInformation(
      workEmail: json['workEmail'] ?? '',
      personalEmail: json['personalEmail'] ?? '',
      workPhone: json['workPhone'] ?? '',
      personalPhone: json['personalPhone'] ?? '',
      officeLocation: json['officeLocation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workEmail': workEmail,
      'personalEmail': personalEmail,
      'workPhone': workPhone,
      'personalPhone': personalPhone,
      'officeLocation': officeLocation,
    };
  }

  ContactInformation copyWith({
    String? workEmail,
    String? personalEmail,
    String? workPhone,
    String? personalPhone,
    String? officeLocation,
  }) {
    return ContactInformation(
      workEmail: workEmail ?? this.workEmail,
      personalEmail: personalEmail ?? this.personalEmail,
      workPhone: workPhone ?? this.workPhone,
      personalPhone: personalPhone ?? this.personalPhone,
      officeLocation: officeLocation ?? this.officeLocation,
    );
  }
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String? email;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      if (email != null) 'email': email,
    };
  }
}

class StoreEmploymentDetails {
  final DateTime hireDate;
  final DateTime? promotionDate;
  final EmploymentType employmentType;
  final EmploymentStatus employmentStatus;
  final double storesExperience;
  final List<PreviousStoresRole> previousStoresRoles;

  StoreEmploymentDetails({
    required this.hireDate,
    this.promotionDate,
    required this.employmentType,
    required this.employmentStatus,
    required this.storesExperience,
    required this.previousStoresRoles,
  });

  factory StoreEmploymentDetails.fromJson(Map<String, dynamic> json) {
    return StoreEmploymentDetails(
      hireDate: DateTime.parse(json['hireDate'] ?? DateTime.now().toIso8601String()),
      promotionDate: json['promotionDate'] != null ? DateTime.parse(json['promotionDate']) : null,
      employmentType: EmploymentType.values.firstWhere(
            (e) => e.name == (json['employmentType'] ?? '').toUpperCase(),
        orElse: () => EmploymentType.FULL_TIME,
      ),
      employmentStatus: EmploymentStatus.values.firstWhere(
            (e) => e.name == (json['employmentStatus'] ?? '').toUpperCase(),
        orElse: () => EmploymentStatus.ACTIVE,
      ),
      storesExperience: (json['storesExperience'] ?? 0).toDouble(),
      previousStoresRoles: (json['previousStoresRoles'] as List? ?? [])
          .map((e) => PreviousStoresRole.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hireDate': hireDate.toIso8601String(),
      if (promotionDate != null) 'promotionDate': promotionDate!.toIso8601String(),
      'employmentType': employmentType.name,
      'employmentStatus': employmentStatus.name,
      'storesExperience': storesExperience,
      'previousStoresRoles': previousStoresRoles.map((e) => e.toJson()).toList(),
    };
  }
}

class PreviousStoresRole {
  final String role;
  final String company;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> achievements;

  PreviousStoresRole({
    required this.role,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.achievements,
  });

  factory PreviousStoresRole.fromJson(Map<String, dynamic> json) {
    return PreviousStoresRole(
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'achievements': achievements,
    };
  }
}

class StoreJobInformation {
  final String jobTitle;
  final StoreManagerRole storeManagerRole;
  final String department;
  final String location;
  final String costCenter;
  final String reportingTo;
  final List<String> storesManaged;

  StoreJobInformation({
    required this.jobTitle,
    required this.storeManagerRole,
    required this.department,
    required this.location,
    required this.costCenter,
    required this.reportingTo,
    required this.storesManaged,
  });

  factory StoreJobInformation.fromJson(Map<String, dynamic> json) {
    return StoreJobInformation(
      jobTitle: json['jobTitle'] ?? '',
      storeManagerRole: StoreManagerRole.values.firstWhere(
            (e) => e.name == (json['storeManagerRole'] ?? '').toUpperCase(),
        orElse: () => StoreManagerRole.STORES_MANAGER,
      ),
      department: json['department'] ?? 'Stores',
      location: json['location'] ?? '',
      costCenter: json['costCenter'] ?? '',
      reportingTo: json['reportingTo'] ?? '',
      storesManaged: List<String>.from(json['storesManaged'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'storeManagerRole': storeManagerRole.name,
      'department': department,
      'location': location,
      'costCenter': costCenter,
      'reportingTo': reportingTo,
      'storesManaged': storesManaged,
    };
  }
}

class StoreCompensation {
  final double baseSalary;
  final double storesAllowance;
  final double performanceBonus;
  final double inventoryAccuracyBonus;
  final List<StoreBenefit> benefits;
  final DateTime compensationReviewDate;

  StoreCompensation({
    required this.baseSalary,
    required this.storesAllowance,
    required this.performanceBonus,
    required this.inventoryAccuracyBonus,
    required this.benefits,
    required this.compensationReviewDate,
  });

  factory StoreCompensation.fromJson(Map<String, dynamic> json) {
    return StoreCompensation(
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      storesAllowance: (json['storesAllowance'] ?? 0).toDouble(),
      performanceBonus: (json['performanceBonus'] ?? 0).toDouble(),
      inventoryAccuracyBonus: (json['inventoryAccuracyBonus'] ?? 0).toDouble(),
      benefits: (json['benefits'] as List? ?? [])
          .map((e) => StoreBenefit.fromJson(e))
          .toList(),
      compensationReviewDate: DateTime.parse(json['compensationReviewDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseSalary': baseSalary,
      'storesAllowance': storesAllowance,
      'performanceBonus': performanceBonus,
      'inventoryAccuracyBonus': inventoryAccuracyBonus,
      'benefits': benefits.map((e) => e.toJson()).toList(),
      'compensationReviewDate': compensationReviewDate.toIso8601String(),
    };
  }
}

class StoreBenefit {
  final String benefit;
  final double value;
  final String description;

  StoreBenefit({
    required this.benefit,
    required this.value,
    required this.description,
  });

  factory StoreBenefit.fromJson(Map<String, dynamic> json) {
    return StoreBenefit(
      benefit: json['benefit'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'benefit': benefit,
      'value': value,
      'description': description,
    };
  }
}

class InventoryAuthority {
  final bool inventoryManagement;
  final double stockAdjustments;
  final double writeOffAuthority;
  final bool stockTransfer;
  final bool qualityHold;
  final bool disposalAuthority;

  InventoryAuthority({
    required this.inventoryManagement,
    required this.stockAdjustments,
    required this.writeOffAuthority,
    required this.stockTransfer,
    required this.qualityHold,
    required this.disposalAuthority,
  });

  factory InventoryAuthority.fromJson(Map<String, dynamic> json) {
    return InventoryAuthority(
      inventoryManagement: json['inventoryManagement'] ?? true,
      stockAdjustments: (json['stockAdjustments'] ?? 0).toDouble(),
      writeOffAuthority: (json['writeOffAuthority'] ?? 0).toDouble(),
      stockTransfer: json['stockTransfer'] ?? true,
      qualityHold: json['qualityHold'] ?? true,
      disposalAuthority: json['disposalAuthority'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryManagement': inventoryManagement,
      'stockAdjustments': stockAdjustments,
      'writeOffAuthority': writeOffAuthority,
      'stockTransfer': stockTransfer,
      'qualityHold': qualityHold,
      'disposalAuthority': disposalAuthority,
    };
  }
}

class StoreApprovalLimits {
  final double purchaseRequisitions;
  final double purchaseOrders;
  final double stockIssues;
  final double stockReturns;
  final double inventoryAdjustments;
  final double emergencyProcurement;

  StoreApprovalLimits({
    required this.purchaseRequisitions,
    required this.purchaseOrders,
    required this.stockIssues,
    required this.stockReturns,
    required this.inventoryAdjustments,
    required this.emergencyProcurement,
  });

  factory StoreApprovalLimits.fromJson(Map<String, dynamic> json) {
    return StoreApprovalLimits(
      purchaseRequisitions: (json['purchaseRequisitions'] ?? 0).toDouble(),
      purchaseOrders: (json['purchaseOrders'] ?? 0).toDouble(),
      stockIssues: (json['stockIssues'] ?? 0).toDouble(),
      stockReturns: (json['stockReturns'] ?? 0).toDouble(),
      inventoryAdjustments: (json['inventoryAdjustments'] ?? 0).toDouble(),
      emergencyProcurement: (json['emergencyProcurement'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseRequisitions': purchaseRequisitions,
      'purchaseOrders': purchaseOrders,
      'stockIssues': stockIssues,
      'stockReturns': stockReturns,
      'inventoryAdjustments': inventoryAdjustments,
      'emergencyProcurement': emergencyProcurement,
    };
  }
}

class StoreSystemAccess {
  final StoreSystem system;
  final StoreAccessLevel accessLevel;
  final List<String> permissions;
  final DateTime grantedDate;
  final DateTime reviewDate;

  StoreSystemAccess({
    required this.system,
    required this.accessLevel,
    required this.permissions,
    required this.grantedDate,
    required this.reviewDate,
  });

  factory StoreSystemAccess.fromJson(Map<String, dynamic> json) {
    return StoreSystemAccess(
      system: StoreSystem.values.firstWhere(
            (e) => e.name == (json['system'] ?? '').toUpperCase(),
        orElse: () => StoreSystem.INVENTORY_MANAGEMENT,
      ),
      accessLevel: StoreAccessLevel.values.firstWhere(
            (e) => e.name == (json['accessLevel'] ?? '').toUpperCase(),
        orElse: () => StoreAccessLevel.VIEW,
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      grantedDate: DateTime.parse(json['grantedDate'] ?? DateTime.now().toIso8601String()),
      reviewDate: DateTime.parse(json['reviewDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system.name,
      'accessLevel': accessLevel.name,
      'permissions': permissions,
      'grantedDate': grantedDate.toIso8601String(),
      'reviewDate': reviewDate.toIso8601String(),
    };
  }
}

class StoreReportingStaff {
  final String staff;
  final StoreStaffRole role;
  final String reportingLine;
  final double performance;

  StoreReportingStaff({
    required this.staff,
    required this.role,
    required this.reportingLine,
    required this.performance,
  });

  factory StoreReportingStaff.fromJson(Map<String, dynamic> json) {
    return StoreReportingStaff(
      staff: json['staff'] ?? '',
      role: StoreStaffRole.values.firstWhere(
            (e) => e.name == (json['role'] ?? '').toUpperCase(),
        orElse: () => StoreStaffRole.STORE_KEEPER,
      ),
      reportingLine: json['reportingLine'] ?? '',
      performance: (json['performance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff': staff,
      'role': role.name,
      'reportingLine': reportingLine,
      'performance': performance,
    };
  }
}

class StoreReportingStructure {
  final int level;
  final String reportsTo;
  final List<String> dottedLineReports;
  final String storeHierarchy;

  StoreReportingStructure({
    required this.level,
    required this.reportsTo,
    required this.dottedLineReports,
    required this.storeHierarchy,
  });

  factory StoreReportingStructure.fromJson(Map<String, dynamic> json) {
    return StoreReportingStructure(
      level: json['level'] ?? 1,
      reportsTo: json['reportsTo'] ?? '',
      dottedLineReports: List<String>.from(json['dottedLineReports'] ?? []),
      storeHierarchy: json['storeHierarchy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'reportsTo': reportsTo,
      'dottedLineReports': dottedLineReports,
      'storeHierarchy': storeHierarchy,
    };
  }
}

class StoreManagerPerformance {
  final double inventoryAccuracy;
  final double stockTurnover;
  final double orderFulfillment;
  final double costSavings;
  final double teamPerformance;
  final double safetyCompliance;
  final double overallRating;
  final DateTime lastReviewDate;
  final DateTime nextReviewDate;

  StoreManagerPerformance({
    required this.inventoryAccuracy,
    required this.stockTurnover,
    required this.orderFulfillment,
    required this.costSavings,
    required this.teamPerformance,
    required this.safetyCompliance,
    required this.overallRating,
    required this.lastReviewDate,
    required this.nextReviewDate,
  });

  factory StoreManagerPerformance.fromJson(Map<String, dynamic> json) {
    return StoreManagerPerformance(
      inventoryAccuracy: (json['inventoryAccuracy'] ?? 0).toDouble(),
      stockTurnover: (json['stockTurnover'] ?? 0).toDouble(),
      orderFulfillment: (json['orderFulfillment'] ?? 0).toDouble(),
      costSavings: (json['costSavings'] ?? 0).toDouble(),
      teamPerformance: (json['teamPerformance'] ?? 0).toDouble(),
      safetyCompliance: (json['safetyCompliance'] ?? 0).toDouble(),
      overallRating: (json['overallRating'] ?? 0).toDouble(),
      lastReviewDate: DateTime.parse(json['lastReviewDate'] ?? DateTime.now().toIso8601String()),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryAccuracy': inventoryAccuracy,
      'stockTurnover': stockTurnover,
      'orderFulfillment': orderFulfillment,
      'costSavings': costSavings,
      'teamPerformance': teamPerformance,
      'safetyCompliance': safetyCompliance,
      'overallRating': overallRating,
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }
}

class StoreObjective {
  final String id;
  final String objective;
  final String description;
  final double weight;
  final double progress;
  final ObjectiveStatus status;
  final DateTime dueDate;
  final List<ObjectiveMetric> metrics;

  StoreObjective({
    required this.id,
    required this.objective,
    required this.description,
    required this.weight,
    required this.progress,
    required this.status,
    required this.dueDate,
    required this.metrics,
  });

  factory StoreObjective.fromJson(Map<String, dynamic> json) {
    return StoreObjective(
      id: json['_id'] ?? json['id'] ?? '',
      objective: json['objective'] ?? '',
      description: json['description'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      progress: (json['progress'] ?? 0).toDouble(),
      status: ObjectiveStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? '').toUpperCase(),
        orElse: () => ObjectiveStatus.NOT_STARTED,
      ),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      metrics: (json['metrics'] as List? ?? [])
          .map((e) => ObjectiveMetric.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'objective': objective,
      'description': description,
      'weight': weight,
      'progress': progress,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'metrics': metrics.map((e) => e.toJson()).toList(),
    };
  }
}

class ObjectiveMetric {
  final String metric;
  final double target;
  final double current;
  final String unit;

  ObjectiveMetric({
    required this.metric,
    required this.target,
    required this.current,
    required this.unit,
  });

  factory ObjectiveMetric.fromJson(Map<String, dynamic> json) {
    return ObjectiveMetric(
      metric: json['metric'] ?? '',
      target: (json['target'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'target': target,
      'current': current,
      'unit': unit,
    };
  }
}

class StoreKRA {
  final String area;
  final List<StoreMetric> metrics;
  final double weight;
  final double performance;

  StoreKRA({
    required this.area,
    required this.metrics,
    required this.weight,
    required this.performance,
  });

  factory StoreKRA.fromJson(Map<String, dynamic> json) {
    return StoreKRA(
      area: json['area'] ?? '',
      metrics: (json['metrics'] as List? ?? [])
          .map((e) => StoreMetric.fromJson(e))
          .toList(),
      weight: (json['weight'] ?? 0).toDouble(),
      performance: (json['performance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'metrics': metrics.map((e) => e.toJson()).toList(),
      'weight': weight,
      'performance': performance,
    };
  }
}

class StoreMetric {
  final String metric;
  final double target;
  final double actual;
  final String frequency;

  StoreMetric({
    required this.metric,
    required this.target,
    required this.actual,
    required this.frequency,
  });

  factory StoreMetric.fromJson(Map<String, dynamic> json) {
    return StoreMetric(
      metric: json['metric'] ?? '',
      target: (json['target'] ?? 0).toDouble(),
      actual: (json['actual'] ?? 0).toDouble(),
      frequency: json['frequency'] ?? '',
    );
  }

  get unit => null;

  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'target': target,
      'actual': actual,
      'frequency': frequency,
    };
  }
}

class OperationalResponsibility {
  final String responsibility;
  final String description;
  final String frequency;
  final bool critical;
  final double performance;

  OperationalResponsibility({
    required this.responsibility,
    required this.description,
    required this.frequency,
    required this.critical,
    required this.performance,
  });

  factory OperationalResponsibility.fromJson(Map<String, dynamic> json) {
    return OperationalResponsibility(
      responsibility: json['responsibility'] ?? '',
      description: json['description'] ?? '',
      frequency: json['frequency'] ?? '',
      critical: json['critical'] ?? false,
      performance: (json['performance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responsibility': responsibility,
      'description': description,
      'frequency': frequency,
      'critical': critical,
      'performance': performance,
    };
  }
}

class QualityResponsibility {
  final String area;
  final List<String> standards;
  final double compliance;
  final List<AuditResult> auditResults;

  QualityResponsibility({
    required this.area,
    required this.standards,
    required this.compliance,
    required this.auditResults,
  });

  factory QualityResponsibility.fromJson(Map<String, dynamic> json) {
    return QualityResponsibility(
      area: json['area'] ?? '',
      standards: List<String>.from(json['standards'] ?? []),
      compliance: (json['compliance'] ?? 0).toDouble(),
      auditResults: (json['auditResults'] as List? ?? [])
          .map((e) => AuditResult.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'standards': standards,
      'compliance': compliance,
      'auditResults': auditResults.map((e) => e.toJson()).toList(),
    };
  }
}

class AuditResult {
  final DateTime auditDate;
  final String area;
  final double score;
  final List<String> findings;
  final String status;

  AuditResult({
    required this.auditDate,
    required this.area,
    required this.score,
    required this.findings,
    required this.status,
  });

  factory AuditResult.fromJson(Map<String, dynamic> json) {
    return AuditResult(
      auditDate: DateTime.parse(json['auditDate'] ?? DateTime.now().toIso8601String()),
      area: json['area'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      findings: List<String>.from(json['findings'] ?? []),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auditDate': auditDate.toIso8601String(),
      'area': area,
      'score': score,
      'findings': findings,
      'status': status,
    };
  }
}

class SafetyResponsibility {
  final String area;
  final List<String> procedures;
  final double compliance;
  final int incidents;

  SafetyResponsibility({
    required this.area,
    required this.procedures,
    required this.compliance,
    required this.incidents,
  });

  factory SafetyResponsibility.fromJson(Map<String, dynamic> json) {
    return SafetyResponsibility(
      area: json['area'] ?? '',
      procedures: List<String>.from(json['procedures'] ?? []),
      compliance: (json['compliance'] ?? 0).toDouble(),
      incidents: json['incidents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'procedures': procedures,
      'compliance': compliance,
      'incidents': incidents,
    };
  }
}

class ProcurementAuthority {
  final bool canApprovePR;
  final double prValueLimit;
  final bool canApprovePO;
  final double poValueLimit;
  final bool canSelectSuppliers;
  final double negotiationAuthority;

  ProcurementAuthority({
    required this.canApprovePR,
    required this.prValueLimit,
    required this.canApprovePO,
    required this.poValueLimit,
    required this.canSelectSuppliers,
    required this.negotiationAuthority,
  });

  factory ProcurementAuthority.fromJson(Map<String, dynamic> json) {
    return ProcurementAuthority(
      canApprovePR: json['canApprovePR'] ?? false,
      prValueLimit: (json['prValueLimit'] ?? 0).toDouble(),
      canApprovePO: json['canApprovePO'] ?? false,
      poValueLimit: (json['poValueLimit'] ?? 0).toDouble(),
      canSelectSuppliers: json['canSelectSuppliers'] ?? false,
      negotiationAuthority: (json['negotiationAuthority'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canApprovePR': canApprovePR,
      'prValueLimit': prValueLimit,
      'canApprovePO': canApprovePO,
      'poValueLimit': poValueLimit,
      'canSelectSuppliers': canSelectSuppliers,
      'negotiationAuthority': negotiationAuthority,
    };
  }
}

class VendorManagement {
  final bool vendorEvaluation;
  final bool vendorPerformance;
  final bool contractManagement;
  final bool supplierDevelopment;

  VendorManagement({
    required this.vendorEvaluation,
    required this.vendorPerformance,
    required this.contractManagement,
    required this.supplierDevelopment,
  });

  factory VendorManagement.fromJson(Map<String, dynamic> json) {
    return VendorManagement(
      vendorEvaluation: json['vendorEvaluation'] ?? false,
      vendorPerformance: json['vendorPerformance'] ?? false,
      contractManagement: json['contractManagement'] ?? false,
      supplierDevelopment: json['supplierDevelopment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorEvaluation': vendorEvaluation,
      'vendorPerformance': vendorPerformance,
      'contractManagement': contractManagement,
      'supplierDevelopment': supplierDevelopment,
    };
  }
}

class SupplierRelation {
  final String supplier;
  final String relationshipLevel;
  final double performance;
  final int issues;

  SupplierRelation({
    required this.supplier,
    required this.relationshipLevel,
    required this.performance,
    required this.issues,
  });

  factory SupplierRelation.fromJson(Map<String, dynamic> json) {
    return SupplierRelation(
      supplier: json['supplier'] ?? '',
      relationshipLevel: json['relationshipLevel'] ?? '',
      performance: (json['performance'] ?? 0).toDouble(),
      issues: json['issues'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier': supplier,
      'relationshipLevel': relationshipLevel,
      'performance': performance,
      'issues': issues,
    };
  }
}

class StockControlAuthority {
  final bool stockLevelManagement;
  final bool reorderPointSetting;
  final bool safetyStockSetting;
  final bool obsolescenceManagement;
  final bool cycleCounting;

  StockControlAuthority({
    required this.stockLevelManagement,
    required this.reorderPointSetting,
    required this.safetyStockSetting,
    required this.obsolescenceManagement,
    required this.cycleCounting,
  });

  factory StockControlAuthority.fromJson(Map<String, dynamic> json) {
    return StockControlAuthority(
      stockLevelManagement: json['stockLevelManagement'] ?? true,
      reorderPointSetting: json['reorderPointSetting'] ?? true,
      safetyStockSetting: json['safetyStockSetting'] ?? true,
      obsolescenceManagement: json['obsolescenceManagement'] ?? true,
      cycleCounting: json['cycleCounting'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockLevelManagement': stockLevelManagement,
      'reorderPointSetting': reorderPointSetting,
      'safetyStockSetting': safetyStockSetting,
      'obsolescenceManagement': obsolescenceManagement,
      'cycleCounting': cycleCounting,
    };
  }
}

class InventoryAccuracyTarget {
  final String warehouse;
  final double targetAccuracy;
  final double currentAccuracy;
  final double variance;

  InventoryAccuracyTarget({
    required this.warehouse,
    required this.targetAccuracy,
    required this.currentAccuracy,
    required this.variance,
  });

  factory InventoryAccuracyTarget.fromJson(Map<String, dynamic> json) {
    return InventoryAccuracyTarget(
      warehouse: json['warehouse'] ?? '',
      targetAccuracy: (json['targetAccuracy'] ?? 0).toDouble(),
      currentAccuracy: (json['currentAccuracy'] ?? 0).toDouble(),
      variance: (json['variance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse': warehouse,
      'targetAccuracy': targetAccuracy,
      'currentAccuracy': currentAccuracy,
      'variance': variance,
    };
  }
}

class StockTakeResponsibility {
  final String type;
  final String frequency;
  final String responsibility;
  final double performance;

  StockTakeResponsibility({
    required this.type,
    required this.frequency,
    required this.responsibility,
    required this.performance,
  });

  factory StockTakeResponsibility.fromJson(Map<String, dynamic> json) {
    return StockTakeResponsibility(
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      responsibility: json['responsibility'] ?? '',
      performance: (json['performance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'frequency': frequency,
      'responsibility': responsibility,
      'performance': performance,
    };
  }
}

class StoreDevelopmentPlan {
  final List<StoreDevelopmentArea> developmentAreas;
  final List<StoreTraining> trainingPrograms;
  final List<TechnicalSkill> technicalSkills;
  final List<String> targetPositions;
  final StoreDevelopmentTimeline timeline;

  StoreDevelopmentPlan({
    required this.developmentAreas,
    required this.trainingPrograms,
    required this.technicalSkills,
    required this.targetPositions,
    required this.timeline,
  });

  factory StoreDevelopmentPlan.fromJson(Map<String, dynamic> json) {
    return StoreDevelopmentPlan(
      developmentAreas: (json['developmentAreas'] as List? ?? [])
          .map((e) => StoreDevelopmentArea.fromJson(e))
          .toList(),
      trainingPrograms: (json['trainingPrograms'] as List? ?? [])
          .map((e) => StoreTraining.fromJson(e))
          .toList(),
      technicalSkills: (json['technicalSkills'] as List? ?? [])
          .map((e) => TechnicalSkill.fromJson(e))
          .toList(),
      targetPositions: List<String>.from(json['targetPositions'] ?? []),
      timeline: StoreDevelopmentTimeline.fromJson(json['timeline'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'developmentAreas': developmentAreas.map((e) => e.toJson()).toList(),
      'trainingPrograms': trainingPrograms.map((e) => e.toJson()).toList(),
      'technicalSkills': technicalSkills.map((e) => e.toJson()).toList(),
      'targetPositions': targetPositions,
      'timeline': timeline.toJson(),
    };
  }
}

class StoreDevelopmentArea {
  final String area;
  final String currentLevel;
  final String targetLevel;
  final List<String> actions;
  final DateTime deadline;
  final double progress;

  StoreDevelopmentArea({
    required this.area,
    required this.currentLevel,
    required this.targetLevel,
    required this.actions,
    required this.deadline,
    required this.progress,
  });

  factory StoreDevelopmentArea.fromJson(Map<String, dynamic> json) {
    return StoreDevelopmentArea(
      area: json['area'] ?? '',
      currentLevel: json['currentLevel'] ?? '',
      targetLevel: json['targetLevel'] ?? '',
      actions: List<String>.from(json['actions'] ?? []),
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'currentLevel': currentLevel,
      'targetLevel': targetLevel,
      'actions': actions,
      'deadline': deadline.toIso8601String(),
      'progress': progress,
    };
  }
}

class StoreTraining {
  final String program;
  final String provider;
  final int duration;
  final String status;
  final DateTime? completionDate;
  final double impact;

  StoreTraining({
    required this.program,
    required this.provider,
    required this.duration,
    required this.status,
    this.completionDate,
    required this.impact,
  });

  factory StoreTraining.fromJson(Map<String, dynamic> json) {
    return StoreTraining(
      program: json['program'] ?? '',
      provider: json['provider'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      impact: (json['impact'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': program,
      'provider': provider,
      'duration': duration,
      'status': status,
      if (completionDate != null) 'completionDate': completionDate!.toIso8601String(),
      'impact': impact,
    };
  }
}

class TechnicalSkill {
  final String skill;
  final String category;
  final String proficiency;
  final DateTime lastUsed;
  final String? certification;

  TechnicalSkill({
    required this.skill,
    required this.category,
    required this.proficiency,
    required this.lastUsed,
    this.certification,
  });

  factory TechnicalSkill.fromJson(Map<String, dynamic> json) {
    return TechnicalSkill(
      skill: json['skill'] ?? '',
      category: json['category'] ?? '',
      proficiency: json['proficiency'] ?? '',
      lastUsed: DateTime.parse(json['lastUsed'] ?? DateTime.now().toIso8601String()),
      certification: json['certification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill': skill,
      'category': category,
      'proficiency': proficiency,
      'lastUsed': lastUsed.toIso8601String(),
      if (certification != null) 'certification': certification,
    };
  }
}

class StoreDevelopmentTimeline {
  final List<StoreDevelopmentGoal> shortTerm;
  final List<StoreDevelopmentGoal> mediumTerm;
  final List<StoreDevelopmentGoal> longTerm;

  StoreDevelopmentTimeline({
    required this.shortTerm,
    required this.mediumTerm,
    required this.longTerm,
  });

  factory StoreDevelopmentTimeline.fromJson(Map<String, dynamic> json) {
    return StoreDevelopmentTimeline(
      shortTerm: (json['shortTerm'] as List? ?? [])
          .map((e) => StoreDevelopmentGoal.fromJson(e))
          .toList(),
      mediumTerm: (json['mediumTerm'] as List? ?? [])
          .map((e) => StoreDevelopmentGoal.fromJson(e))
          .toList(),
      longTerm: (json['longTerm'] as List? ?? [])
          .map((e) => StoreDevelopmentGoal.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortTerm': shortTerm.map((e) => e.toJson()).toList(),
      'mediumTerm': mediumTerm.map((e) => e.toJson()).toList(),
      'longTerm': longTerm.map((e) => e.toJson()).toList(),
    };
  }
}

class StoreDevelopmentGoal {
  final String goal;
  final DateTime timeline;
  final List<String> successCriteria;
  final String status;

  StoreDevelopmentGoal({
    required this.goal,
    required this.timeline,
    required this.successCriteria,
    required this.status,
  });

  factory StoreDevelopmentGoal.fromJson(Map<String, dynamic> json) {
    return StoreDevelopmentGoal(
      goal: json['goal'] ?? '',
      timeline: DateTime.parse(json['timeline'] ?? DateTime.now().toIso8601String()),
      successCriteria: List<String>.from(json['successCriteria'] ?? []),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'timeline': timeline.toIso8601String(),
      'successCriteria': successCriteria,
      'status': status,
    };
  }
}

class TechnicalTraining {
  final String program;
  final String provider;
  final int duration;
  final String status;
  final DateTime? completionDate;
  final double impact;
  final String category;
  final List<String> skillsCovered;
  final String? certification;

  TechnicalTraining({
    required this.program,
    required this.provider,
    required this.duration,
    required this.status,
    this.completionDate,
    required this.impact,
    required this.category,
    required this.skillsCovered,
    this.certification,
  });

  factory TechnicalTraining.fromJson(Map<String, dynamic> json) {
    return TechnicalTraining(
      program: json['program'] ?? '',
      provider: json['provider'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      impact: (json['impact'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      skillsCovered: List<String>.from(json['skillsCovered'] ?? []),
      certification: json['certification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': program,
      'provider': provider,
      'duration': duration,
      'status': status,
      if (completionDate != null) 'completionDate': completionDate!.toIso8601String(),
      'impact': impact,
      'category': category,
      'skillsCovered': skillsCovered,
      if (certification != null) 'certification': certification,
    };
  }
}

class StoreCertification {
  final String name;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String documentUrl;
  final String status;

  StoreCertification({
    required this.name,
    required this.issuingAuthority,
    required this.issueDate,
    this.expiryDate,
    required this.documentUrl,
    required this.status,
  });

  factory StoreCertification.fromJson(Map<String, dynamic> json) {
    return StoreCertification(
      name: json['name'] ?? '',
      issuingAuthority: json['issuingAuthority'] ?? '',
      issueDate: DateTime.parse(json['issueDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      documentUrl: json['documentUrl'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuingAuthority': issuingAuthority,
      'issueDate': issueDate.toIso8601String(),
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'documentUrl': documentUrl,
      'status': status,
    };
  }
}