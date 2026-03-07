// features/managers/data/models/manager_model.dart
import 'package:flutter/foundation.dart';

@immutable
class ManagerModel {
  final String id;
  final String employeeNumber;
  final String userId;

  // Personal Information
  final PersonalDetails personalDetails;
  final ContactInformation contactInformation;
  final List<EmergencyContact> emergencyContacts;

  // Employment Details
  final ManagerEmploymentDetails employmentDetails;
  final ManagerJobInformation jobInformation;
  final ManagerCompensation compensation;

  // Management Specific
  final String managementRole;
  final String managementLevel;
  final String department;
  final SpanOfControl spanOfControl;

  // Authorization & Approvals
  final ManagerApprovalLimits approvalLimits;
  final SigningAuthority signingAuthority;

  // Team & Reporting
  final List<String> directReports;
  final ReportingStructure reportingStructure;

  // Performance
  final ManagerPerformance performance;
  final List<ManagementObjective> objectives;

  // Decision Making
  final DecisionAuthority decisionAuthority;
  final BudgetAuthority budgetAuthority;
  final HiringAuthority hiringAuthority;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calculated properties
  String get fullName =>
      '${personalDetails.firstName} ${personalDetails.lastName}';

  String get jobTitle => jobInformation.jobTitle;

  String get email => contactInformation.workEmail;

  int get teamSize => spanOfControl.totalEmployees;

  const ManagerModel({
    required this.id,
    required this.employeeNumber,
    required this.userId,
    required this.personalDetails,
    required this.contactInformation,
    required this.emergencyContacts,
    required this.employmentDetails,
    required this.jobInformation,
    required this.compensation,
    required this.managementRole,
    required this.managementLevel,
    required this.department,
    required this.spanOfControl,
    required this.approvalLimits,
    required this.signingAuthority,
    required this.directReports,
    required this.reportingStructure,
    required this.performance,
    required this.objectives,
    required this.decisionAuthority,
    required this.budgetAuthority,
    required this.hiringAuthority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['_id'] ?? json['id'],
      employeeNumber: json['employeeNumber'],
      userId: json['user'] is String ? json['user'] : json['user']['_id'],
      personalDetails: PersonalDetails.fromJson(json['personalDetails']),
      contactInformation:
          ContactInformation.fromJson(json['contactInformation']),
      emergencyContacts: (json['emergencyContacts'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
      employmentDetails:
          ManagerEmploymentDetails.fromJson(json['employmentDetails']),
      jobInformation: ManagerJobInformation.fromJson(json['jobInformation']),
      compensation: ManagerCompensation.fromJson(json['compensation']),
      managementRole: json['managementRole'],
      managementLevel: json['managementLevel'],
      department: json['department'],
      spanOfControl: SpanOfControl.fromJson(json['spanOfControl']),
      approvalLimits: ManagerApprovalLimits.fromJson(json['approvalLimits']),
      signingAuthority: SigningAuthority.fromJson(json['signingAuthority']),
      directReports: List<String>.from(json['directReports'] ?? []),
      reportingStructure:
          ReportingStructure.fromJson(json['reportingStructure']),
      performance: ManagerPerformance.fromJson(json['performance']),
      objectives: (json['objectives'] as List)
          .map((e) => ManagementObjective.fromJson(e))
          .toList(),
      decisionAuthority: DecisionAuthority.fromJson(json['decisionAuthority']),
      budgetAuthority: BudgetAuthority.fromJson(json['budgetAuthority']),
      hiringAuthority: HiringAuthority.fromJson(json['hiringAuthority']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeNumber': employeeNumber,
      'user': userId,
      'personalDetails': personalDetails.toJson(),
      'contactInformation': contactInformation.toJson(),
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'employmentDetails': employmentDetails.toJson(),
      'jobInformation': jobInformation.toJson(),
      'compensation': compensation.toJson(),
      'managementRole': managementRole,
      'managementLevel': managementLevel,
      'department': department,
      'spanOfControl': spanOfControl.toJson(),
      'approvalLimits': approvalLimits.toJson(),
      'signingAuthority': signingAuthority.toJson(),
      'directReports': directReports,
      'reportingStructure': reportingStructure.toJson(),
      'performance': performance.toJson(),
      'objectives': objectives.map((e) => e.toJson()).toList(),
      'decisionAuthority': decisionAuthority.toJson(),
      'budgetAuthority': budgetAuthority.toJson(),
      'hiringAuthority': hiringAuthority.toJson(),
      'isActive': isActive,
    };
  }

  ManagerModel copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    PersonalDetails? personalDetails,
    ContactInformation? contactInformation,
    List<EmergencyContact>? emergencyContacts,
    ManagerEmploymentDetails? employmentDetails,
    ManagerJobInformation? jobInformation,
    ManagerCompensation? compensation,
    String? managementRole,
    String? managementLevel,
    String? department,
    SpanOfControl? spanOfControl,
    ManagerApprovalLimits? approvalLimits,
    SigningAuthority? signingAuthority,
    List<String>? directReports,
    ReportingStructure? reportingStructure,
    ManagerPerformance? performance,
    List<ManagementObjective>? objectives,
    DecisionAuthority? decisionAuthority,
    BudgetAuthority? budgetAuthority,
    HiringAuthority? hiringAuthority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagerModel(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      userId: userId ?? this.userId,
      personalDetails: personalDetails ?? this.personalDetails,
      contactInformation: contactInformation ?? this.contactInformation,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      employmentDetails: employmentDetails ?? this.employmentDetails,
      jobInformation: jobInformation ?? this.jobInformation,
      compensation: compensation ?? this.compensation,
      managementRole: managementRole ?? this.managementRole,
      managementLevel: managementLevel ?? this.managementLevel,
      department: department ?? this.department,
      spanOfControl: spanOfControl ?? this.spanOfControl,
      approvalLimits: approvalLimits ?? this.approvalLimits,
      signingAuthority: signingAuthority ?? this.signingAuthority,
      directReports: directReports ?? this.directReports,
      reportingStructure: reportingStructure ?? this.reportingStructure,
      performance: performance ?? this.performance,
      objectives: objectives ?? this.objectives,
      decisionAuthority: decisionAuthority ?? this.decisionAuthority,
      budgetAuthority: budgetAuthority ?? this.budgetAuthority,
      hiringAuthority: hiringAuthority ?? this.hiringAuthority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManagerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Sub-models
@immutable
class PersonalDetails {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String nationalId;

  const PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationalId,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      nationalId: json['nationalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'nationalId': nationalId,
    };
  }

  PersonalDetails copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
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

@immutable
class ContactInformation {
  final String workEmail;
  final String personalEmail;
  final String workPhone;
  final String personalPhone;
  final String officeLocation;

  const ContactInformation({
    required this.workEmail,
    required this.personalEmail,
    required this.workPhone,
    required this.personalPhone,
    required this.officeLocation,
  });

  factory ContactInformation.fromJson(Map<String, dynamic> json) {
    return ContactInformation(
      workEmail: json['workEmail'],
      personalEmail: json['personalEmail'],
      workPhone: json['workPhone'],
      personalPhone: json['personalPhone'],
      officeLocation: json['officeLocation'],
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
}

@immutable
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String? email;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relationship: json['relationship'],
      phone: json['phone'],
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

@immutable
class ManagerEmploymentDetails {
  final DateTime hireDate;
  final DateTime? promotionDate;
  final String employmentType;
  final String employmentStatus;
  final int managementTenure;

  const ManagerEmploymentDetails({
    required this.hireDate,
    this.promotionDate,
    required this.employmentType,
    required this.employmentStatus,
    required this.managementTenure,
  });

  factory ManagerEmploymentDetails.fromJson(Map<String, dynamic> json) {
    return ManagerEmploymentDetails(
      hireDate: DateTime.parse(json['hireDate']),
      promotionDate: json['promotionDate'] != null
          ? DateTime.parse(json['promotionDate'])
          : null,
      employmentType: json['employmentType'],
      employmentStatus: json['employmentStatus'],
      managementTenure: json['managementTenure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hireDate': hireDate.toIso8601String(),
      if (promotionDate != null)
        'promotionDate': promotionDate!.toIso8601String(),
      'employmentType': employmentType,
      'employmentStatus': employmentStatus,
      'managementTenure': managementTenure,
    };
  }
}

@immutable
class ManagerJobInformation {
  final String jobTitle;
  final String managementRole;
  final String department;
  final String division;
  final String location;
  final String costCenter;
  final String? reportingTo;
  final String? matrixReporting;

  const ManagerJobInformation({
    required this.jobTitle,
    required this.managementRole,
    required this.department,
    required this.division,
    required this.location,
    required this.costCenter,
    this.reportingTo,
    this.matrixReporting,
  });

  factory ManagerJobInformation.fromJson(Map<String, dynamic> json) {
    return ManagerJobInformation(
      jobTitle: json['jobTitle'],
      managementRole: json['managementRole'],
      department: json['department'],
      division: json['division'],
      location: json['location'],
      costCenter: json['costCenter'],
      reportingTo: json['reportingTo'],
      matrixReporting: json['matrixReporting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'managementRole': managementRole,
      'department': department,
      'division': division,
      'location': location,
      'costCenter': costCenter,
      if (reportingTo != null) 'reportingTo': reportingTo,
      if (matrixReporting != null) 'matrixReporting': matrixReporting,
    };
  }
}

@immutable
class ManagerCompensation {
  final double baseSalary;
  final double managementAllowance;
  final double performanceBonus;
  final double? stockOptions;
  final List<ManagerBenefit> benefits;
  final DateTime compensationReviewDate;

  const ManagerCompensation({
    required this.baseSalary,
    required this.managementAllowance,
    required this.performanceBonus,
    this.stockOptions,
    required this.benefits,
    required this.compensationReviewDate,
  });

  factory ManagerCompensation.fromJson(Map<String, dynamic> json) {
    return ManagerCompensation(
      baseSalary: (json['baseSalary'] as num).toDouble(),
      managementAllowance: (json['managementAllowance'] as num).toDouble(),
      performanceBonus: (json['performanceBonus'] as num).toDouble(),
      stockOptions: json['stockOptions'] != null
          ? (json['stockOptions'] as num).toDouble()
          : null,
      benefits: (json['benefits'] as List)
          .map((e) => ManagerBenefit.fromJson(e))
          .toList(),
      compensationReviewDate: DateTime.parse(json['compensationReviewDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseSalary': baseSalary,
      'managementAllowance': managementAllowance,
      'performanceBonus': performanceBonus,
      if (stockOptions != null) 'stockOptions': stockOptions,
      'benefits': benefits.map((e) => e.toJson()).toList(),
      'compensationReviewDate': compensationReviewDate.toIso8601String(),
    };
  }

  double get totalCompensation =>
      baseSalary + managementAllowance + performanceBonus;
}

@immutable
class ManagerBenefit {
  final String benefit;
  final double value;
  final String description;

  const ManagerBenefit({
    required this.benefit,
    required this.value,
    required this.description,
  });

  factory ManagerBenefit.fromJson(Map<String, dynamic> json) {
    return ManagerBenefit(
      benefit: json['benefit'],
      value: (json['value'] as num).toDouble(),
      description: json['description'],
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

@immutable
class SpanOfControl {
  final int totalEmployees;
  final int directReports;
  final int indirectReports;
  final int teams;
  final int departments;
  final double budgetSize;

  const SpanOfControl({
    required this.totalEmployees,
    required this.directReports,
    required this.indirectReports,
    required this.teams,
    required this.departments,
    required this.budgetSize,
  });

  factory SpanOfControl.fromJson(Map<String, dynamic> json) {
    return SpanOfControl(
      totalEmployees: json['totalEmployees'],
      directReports: json['directReports'],
      indirectReports: json['indirectReports'],
      teams: json['teams'],
      departments: json['departments'],
      budgetSize: (json['budgetSize'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmployees': totalEmployees,
      'directReports': directReports,
      'indirectReports': indirectReports,
      'teams': teams,
      'departments': departments,
      'budgetSize': budgetSize,
    };
  }
}

@immutable
class ManagerApprovalLimits {
  final FinancialApprovalLimits financial;
  final OperationalApprovalLimits operational;
  final HRApprovalLimits humanResources;
  final ProcurementApprovalLimits procurement;

  const ManagerApprovalLimits({
    required this.financial,
    required this.operational,
    required this.humanResources,
    required this.procurement,
  });

  factory ManagerApprovalLimits.fromJson(Map<String, dynamic> json) {
    return ManagerApprovalLimits(
      financial: FinancialApprovalLimits.fromJson(json['financial']),
      operational: OperationalApprovalLimits.fromJson(json['operational']),
      humanResources: HRApprovalLimits.fromJson(json['humanResources']),
      procurement: ProcurementApprovalLimits.fromJson(json['procurement']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financial': financial.toJson(),
      'operational': operational.toJson(),
      'humanResources': humanResources.toJson(),
      'procurement': procurement.toJson(),
    };
  }
}

@immutable
class FinancialApprovalLimits {
  final double expenseApproval;
  final double capitalExpenditure;
  final double budgetAdjustment;
  final double contractSigning;
  final double investmentApproval;

  const FinancialApprovalLimits({
    required this.expenseApproval,
    required this.capitalExpenditure,
    required this.budgetAdjustment,
    required this.contractSigning,
    required this.investmentApproval,
  });

  factory FinancialApprovalLimits.fromJson(Map<String, dynamic> json) {
    return FinancialApprovalLimits(
      expenseApproval: (json['expenseApproval'] as num).toDouble(),
      capitalExpenditure: (json['capitalExpenditure'] as num).toDouble(),
      budgetAdjustment: (json['budgetAdjustment'] as num).toDouble(),
      contractSigning: (json['contractSigning'] as num).toDouble(),
      investmentApproval: (json['investmentApproval'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseApproval': expenseApproval,
      'capitalExpenditure': capitalExpenditure,
      'budgetAdjustment': budgetAdjustment,
      'contractSigning': contractSigning,
      'investmentApproval': investmentApproval,
    };
  }
}

@immutable
class OperationalApprovalLimits {
  final double projectApproval;
  final double resourceAllocation;
  final double operationalChanges;
  final bool qualityStandards;
  final bool safetyWaivers;

  const OperationalApprovalLimits({
    required this.projectApproval,
    required this.resourceAllocation,
    required this.operationalChanges,
    required this.qualityStandards,
    required this.safetyWaivers,
  });

  factory OperationalApprovalLimits.fromJson(Map<String, dynamic> json) {
    return OperationalApprovalLimits(
      projectApproval: (json['projectApproval'] as num).toDouble(),
      resourceAllocation: (json['resourceAllocation'] as num).toDouble(),
      operationalChanges: (json['operationalChanges'] as num).toDouble(),
      qualityStandards: json['qualityStandards'],
      safetyWaivers: json['safetyWaivers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectApproval': projectApproval,
      'resourceAllocation': resourceAllocation,
      'operationalChanges': operationalChanges,
      'qualityStandards': qualityStandards,
      'safetyWaivers': safetyWaivers,
    };
  }
}

@immutable
class HRApprovalLimits {
  final double hiring;
  final double salaryAdjustment;
  final double promotion;
  final bool termination;
  final double trainingBudget;

  const HRApprovalLimits({
    required this.hiring,
    required this.salaryAdjustment,
    required this.promotion,
    required this.termination,
    required this.trainingBudget,
  });

  factory HRApprovalLimits.fromJson(Map<String, dynamic> json) {
    return HRApprovalLimits(
      hiring: (json['hiring'] as num).toDouble(),
      salaryAdjustment: (json['salaryAdjustment'] as num).toDouble(),
      promotion: (json['promotion'] as num).toDouble(),
      termination: json['termination'],
      trainingBudget: (json['trainingBudget'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hiring': hiring,
      'salaryAdjustment': salaryAdjustment,
      'promotion': promotion,
      'termination': termination,
      'trainingBudget': trainingBudget,
    };
  }
}

@immutable
class ProcurementApprovalLimits {
  final double purchaseOrders;
  final double supplierContracts;
  final double tenderAwards;
  final double emergencyProcurement;

  const ProcurementApprovalLimits({
    required this.purchaseOrders,
    required this.supplierContracts,
    required this.tenderAwards,
    required this.emergencyProcurement,
  });

  factory ProcurementApprovalLimits.fromJson(Map<String, dynamic> json) {
    return ProcurementApprovalLimits(
      purchaseOrders: (json['purchaseOrders'] as num).toDouble(),
      supplierContracts: (json['supplierContracts'] as num).toDouble(),
      tenderAwards: (json['tenderAwards'] as num).toDouble(),
      emergencyProcurement: (json['emergencyProcurement'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrders': purchaseOrders,
      'supplierContracts': supplierContracts,
      'tenderAwards': tenderAwards,
      'emergencyProcurement': emergencyProcurement,
    };
  }
}

@immutable
class SigningAuthority {
  final bool canSignContracts;
  final double contractValueLimit;
  final bool canSignFinancials;
  final bool canSignLegal;
  final bool canRepresentCompany;

  const SigningAuthority({
    required this.canSignContracts,
    required this.contractValueLimit,
    required this.canSignFinancials,
    required this.canSignLegal,
    required this.canRepresentCompany,
  });

  factory SigningAuthority.fromJson(Map<String, dynamic> json) {
    return SigningAuthority(
      canSignContracts: json['canSignContracts'],
      contractValueLimit: (json['contractValueLimit'] as num).toDouble(),
      canSignFinancials: json['canSignFinancials'],
      canSignLegal: json['canSignLegal'],
      canRepresentCompany: json['canRepresentCompany'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canSignContracts': canSignContracts,
      'contractValueLimit': contractValueLimit,
      'canSignFinancials': canSignFinancials,
      'canSignLegal': canSignLegal,
      'canRepresentCompany': canRepresentCompany,
    };
  }
}

@immutable
class ReportingStructure {
  final int level;
  final String reportsTo;
  final List<String> dottedLineReports;
  final List<String> committeeReports;
  final bool boardReporting;

  const ReportingStructure({
    required this.level,
    required this.reportsTo,
    required this.dottedLineReports,
    required this.committeeReports,
    required this.boardReporting,
  });

  factory ReportingStructure.fromJson(Map<String, dynamic> json) {
    return ReportingStructure(
      level: json['level'],
      reportsTo: json['reportsTo'],
      dottedLineReports: List<String>.from(json['dottedLineReports'] ?? []),
      committeeReports: List<String>.from(json['committeeReports'] ?? []),
      boardReporting: json['boardReporting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'reportsTo': reportsTo,
      'dottedLineReports': dottedLineReports,
      'committeeReports': committeeReports,
      'boardReporting': boardReporting,
    };
  }
}

@immutable
class ManagerPerformance {
  final double leadershipScore;
  final double strategicContribution;
  final double teamPerformance;
  final double financialPerformance;
  final double operationalPerformance;
  final double overallRating;
  final DateTime? lastReviewDate;
  final DateTime nextReviewDate;

  const ManagerPerformance({
    required this.leadershipScore,
    required this.strategicContribution,
    required this.teamPerformance,
    required this.financialPerformance,
    required this.operationalPerformance,
    required this.overallRating,
    this.lastReviewDate,
    required this.nextReviewDate,
  });

  factory ManagerPerformance.fromJson(Map<String, dynamic> json) {
    return ManagerPerformance(
      leadershipScore: (json['leadershipScore'] as num).toDouble(),
      strategicContribution: (json['strategicContribution'] as num).toDouble(),
      teamPerformance: (json['teamPerformance'] as num).toDouble(),
      financialPerformance: (json['financialPerformance'] as num).toDouble(),
      operationalPerformance:
          (json['operationalPerformance'] as num).toDouble(),
      overallRating: (json['overallRating'] as num).toDouble(),
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'])
          : null,
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leadershipScore': leadershipScore,
      'strategicContribution': strategicContribution,
      'teamPerformance': teamPerformance,
      'financialPerformance': financialPerformance,
      'operationalPerformance': operationalPerformance,
      'overallRating': overallRating,
      if (lastReviewDate != null)
        'lastReviewDate': lastReviewDate!.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }
}

@immutable
class ManagementObjective {
  final String objective;
  final String description;
  final double weight;
  final double progress;
  final String status;
  final DateTime dueDate;

  const ManagementObjective({
    required this.objective,
    required this.description,
    required this.weight,
    required this.progress,
    required this.status,
    required this.dueDate,
  });

  factory ManagementObjective.fromJson(Map<String, dynamic> json) {
    return ManagementObjective(
      objective: json['objective'],
      description: json['description'],
      weight: (json['weight'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objective': objective,
      'description': description,
      'weight': weight,
      'progress': progress,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

@immutable
class DecisionAuthority {
  final String operationalDecisions;
  final String financialDecisions;
  final String strategicDecisions;
  final String personnelDecisions;

  const DecisionAuthority({
    required this.operationalDecisions,
    required this.financialDecisions,
    required this.strategicDecisions,
    required this.personnelDecisions,
  });

  factory DecisionAuthority.fromJson(Map<String, dynamic> json) {
    return DecisionAuthority(
      operationalDecisions: json['operationalDecisions'],
      financialDecisions: json['financialDecisions'],
      strategicDecisions: json['strategicDecisions'],
      personnelDecisions: json['personnelDecisions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operationalDecisions': operationalDecisions,
      'financialDecisions': financialDecisions,
      'strategicDecisions': strategicDecisions,
      'personnelDecisions': personnelDecisions,
    };
  }
}

@immutable
class BudgetAuthority {
  final double departmentBudget;
  final double projectBudget;
  final double capitalBudget;
  final double discretionaryBudget;
  final double budgetTransferLimit;

  const BudgetAuthority({
    required this.departmentBudget,
    required this.projectBudget,
    required this.capitalBudget,
    required this.discretionaryBudget,
    required this.budgetTransferLimit,
  });

  factory BudgetAuthority.fromJson(Map<String, dynamic> json) {
    return BudgetAuthority(
      departmentBudget: (json['departmentBudget'] as num).toDouble(),
      projectBudget: (json['projectBudget'] as num).toDouble(),
      capitalBudget: (json['capitalBudget'] as num).toDouble(),
      discretionaryBudget: (json['discretionaryBudget'] as num).toDouble(),
      budgetTransferLimit: (json['budgetTransferLimit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentBudget': departmentBudget,
      'projectBudget': projectBudget,
      'capitalBudget': capitalBudget,
      'discretionaryBudget': discretionaryBudget,
      'budgetTransferLimit': budgetTransferLimit,
    };
  }
}

@immutable
class HiringAuthority {
  final bool canHire;
  final List<String> hiringLevels;
  final double salaryBandAuthority;
  final bool canApproveJobRequisitions;
  final bool canTerminate;

  const HiringAuthority({
    required this.canHire,
    required this.hiringLevels,
    required this.salaryBandAuthority,
    required this.canApproveJobRequisitions,
    required this.canTerminate,
  });

  factory HiringAuthority.fromJson(Map<String, dynamic> json) {
    return HiringAuthority(
      canHire: json['canHire'],
      hiringLevels: List<String>.from(json['hiringLevels'] ?? []),
      salaryBandAuthority: (json['salaryBandAuthority'] as num).toDouble(),
      canApproveJobRequisitions: json['canApproveJobRequisitions'],
      canTerminate: json['canTerminate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canHire': canHire,
      'hiringLevels': hiringLevels,
      'salaryBandAuthority': salaryBandAuthority,
      'canApproveJobRequisitions': canApproveJobRequisitions,
      'canTerminate': canTerminate,
    };
  }
}

// Enums
class ManagementRole {
  static const String ceo = 'ceo';
  static const String managingDirector = 'managing_director';
  static const String executiveDirector = 'executive_director';
  static const String departmentDirector = 'department_director';
  static const String seniorManager = 'senior_manager';
  static const String manager = 'manager';
  static const String teamLead = 'team_lead';
  static const String supervisor = 'supervisor';

  static const List<String> all = [
    ceo,
    managingDirector,
    executiveDirector,
    departmentDirector,
    seniorManager,
    manager,
    teamLead,
    supervisor
  ];

  static String display(String role) {
    switch (role) {
      case ceo:
        return 'CEO';
      case managingDirector:
        return 'Managing Director';
      case executiveDirector:
        return 'Executive Director';
      case departmentDirector:
        return 'Department Director';
      case seniorManager:
        return 'Senior Manager';
      case manager:
        return 'Manager';
      case teamLead:
        return 'Team Lead';
      case supervisor:
        return 'Supervisor';
      default:
        return role;
    }
  }
}

class ManagementLevel {
  static const String cSuite = 'c_suite';
  static const String executive = 'executive';
  static const String seniorManagement = 'senior_management';
  static const String middleManagement = 'middle_management';
  static const String firstLineManagement = 'first_line_management';

  static const List<String> all = [
    cSuite,
    executive,
    seniorManagement,
    middleManagement,
    firstLineManagement
  ];

  static String display(String level) {
    switch (level) {
      case cSuite:
        return 'C-Suite';
      case executive:
        return 'Executive';
      case seniorManagement:
        return 'Senior Management';
      case middleManagement:
        return 'Middle Management';
      case firstLineManagement:
        return 'First Line Management';
      default:
        return level;
    }
  }
}

class Department {
  static const String executive = 'executive';
  static const String finance = 'finance';
  static const String operations = 'operations';
  static const String humanResources = 'human_resources';
  static const String salesMarketing = 'sales_marketing';
  static const String it = 'it';
  static const String procurement = 'procurement';
  static const String customerService = 'customer_service';
  static const String technicalServices = 'technical_services';

  static const List<String> all = [
    executive,
    finance,
    operations,
    humanResources,
    salesMarketing,
    it,
    procurement,
    customerService,
    technicalServices
  ];

  static String display(String department) {
    switch (department) {
      case executive:
        return 'Executive';
      case finance:
        return 'Finance';
      case operations:
        return 'Operations';
      case humanResources:
        return 'Human Resources';
      case salesMarketing:
        return 'Sales & Marketing';
      case it:
        return 'IT';
      case procurement:
        return 'Procurement';
      case customerService:
        return 'Customer Service';
      case technicalServices:
        return 'Technical Services';
      default:
        return department;
    }
  }
}

class EmploymentType {
  static const String fullTime = 'full_time';
  static const String partTime = 'part_time';
  static const String contract = 'contract';

  static const List<String> all = [fullTime, partTime, contract];

  static String display(String type) {
    switch (type) {
      case fullTime:
        return 'Full Time';
      case partTime:
        return 'Part Time';
      case contract:
        return 'Contract';
      default:
        return type;
    }
  }
}

class EmploymentStatus {
  static const String active = 'active';
  static const String onLeave = 'on_leave';
  static const String suspended = 'suspended';
  static const String terminated = 'terminated';

  static const List<String> all = [active, onLeave, suspended, terminated];

  static String display(String status) {
    switch (status) {
      case active:
        return 'Active';
      case onLeave:
        return 'On Leave';
      case suspended:
        return 'Suspended';
      case terminated:
        return 'Terminated';
      default:
        return status;
    }
  }
}
