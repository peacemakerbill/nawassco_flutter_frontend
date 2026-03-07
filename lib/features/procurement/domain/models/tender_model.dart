class Tender {
  final String id;
  final String tenderNumber;
  final String title;
  final String description;
  final String? referenceNumber;
  final TenderCategory category;
  final String? subCategory;
  final String department;
  final TenderType tenderType;
  final ProcurementMethod procurementMethod;
  final TenderStatus status;
  final TenderStage stage;
  final DateTime publishedDate;
  final DateTime advertisementDate;
  final DateTime closingDate;
  final DateTime openingDate;
  final DateTime? preBidMeetingDate;
  final DateTime? siteVisitDate;
  final DateTime? clarificationDeadline;
  final DateTime? evaluationStartDate;
  final DateTime? evaluationEndDate;
  final DateTime? awardDate;
  final DateTime? contractSigningDate;
  final DateTime? completionDate;
  final double estimatedBudget;
  final double tenderFee;
  final String tenderFeePaymentMethod;
  final double bidSecurityAmount;
  final BidSecurityType bidSecurityType;
  final double bidSecurityPercentage;
  final String currency;
  final String? budgetSource;
  final String tenderDocument;
  final List<String> biddingDocuments;
  final List<String> technicalSpecifications;
  final List<String> drawings;
  final String boq;
  final String termsAndConditions;
  final bool preQualificationRequired;
  final List<EligibilityCriterion> eligibilityCriteria;
  final List<TechnicalRequirement> technicalRequirements;
  final List<FinancialRequirement> financialRequirements;
  final List<ExperienceRequirement> experienceRequirements;
  final List<EvaluationCriterion> evaluationCriteria;
  final double technicalWeight;
  final double financialWeight;
  final double totalWeight;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String contactDepartment;
  final String bidOpeningVenue;
  final BidSubmissionMethod bidSubmissionMethod;
  final int bidValidityPeriod;
  final int contractDuration;
  final List<TenderAmendment> amendments;
  final List<TenderClarification> clarifications;
  final List<TenderExtension> extensions;
  final String? awardedTo;
  final String? awardedCompany;
  final double? awardedAmount;
  final String? awardRemarks;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final bool isActive;
  final bool isPublished;
  final int views;
  final int downloads;
  final int version;
  final String? workflowState;
  final String? nextAction;
  final DateTime? actionDeadline;

  Tender({
    required this.id,
    required this.tenderNumber,
    required this.title,
    required this.description,
    this.referenceNumber,
    required this.category,
    this.subCategory,
    required this.department,
    required this.tenderType,
    required this.procurementMethod,
    required this.status,
    required this.stage,
    required this.publishedDate,
    required this.advertisementDate,
    required this.closingDate,
    required this.openingDate,
    this.preBidMeetingDate,
    this.siteVisitDate,
    this.clarificationDeadline,
    this.evaluationStartDate,
    this.evaluationEndDate,
    this.awardDate,
    this.contractSigningDate,
    this.completionDate,
    required this.estimatedBudget,
    required this.tenderFee,
    required this.tenderFeePaymentMethod,
    required this.bidSecurityAmount,
    required this.bidSecurityType,
    required this.bidSecurityPercentage,
    required this.currency,
    this.budgetSource,
    required this.tenderDocument,
    required this.biddingDocuments,
    required this.technicalSpecifications,
    required this.drawings,
    required this.boq,
    required this.termsAndConditions,
    required this.preQualificationRequired,
    required this.eligibilityCriteria,
    required this.technicalRequirements,
    required this.financialRequirements,
    required this.experienceRequirements,
    required this.evaluationCriteria,
    required this.technicalWeight,
    required this.financialWeight,
    required this.totalWeight,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactDepartment,
    required this.bidOpeningVenue,
    required this.bidSubmissionMethod,
    required this.bidValidityPeriod,
    required this.contractDuration,
    required this.amendments,
    required this.clarifications,
    required this.extensions,
    this.awardedTo,
    this.awardedCompany,
    this.awardedAmount,
    this.awardRemarks,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.isActive,
    required this.isPublished,
    required this.views,
    required this.downloads,
    required this.version,
    this.workflowState,
    this.nextAction,
    this.actionDeadline,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: json['_id'] ?? json['id'] ?? '',
      tenderNumber: json['tenderNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      referenceNumber: json['referenceNumber'],
      category: TenderCategory.values.firstWhere(
            (e) => e.name == (json['category'] ?? ''),
        orElse: () => TenderCategory.WORKS,
      ),
      subCategory: json['subCategory'],
      department: json['department'] ?? '',
      tenderType: TenderType.values.firstWhere(
            (e) => e.name == (json['tenderType'] ?? ''),
        orElse: () => TenderType.NATIONAL,
      ),
      procurementMethod: ProcurementMethod.values.firstWhere(
            (e) => e.name == (json['procurementMethod'] ?? ''),
        orElse: () => ProcurementMethod.OPEN_TENDER,
      ),
      status: TenderStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? ''),
        orElse: () => TenderStatus.DRAFT,
      ),
      stage: TenderStage.values.firstWhere(
            (e) => e.name == (json['stage'] ?? ''),
        orElse: () => TenderStage.DRAFTING,
      ),
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toString()),
      advertisementDate: DateTime.parse(json['advertisementDate'] ?? DateTime.now().toString()),
      closingDate: DateTime.parse(json['closingDate'] ?? DateTime.now().toString()),
      openingDate: DateTime.parse(json['openingDate'] ?? DateTime.now().toString()),
      preBidMeetingDate: json['preBidMeetingDate'] != null ? DateTime.parse(json['preBidMeetingDate']) : null,
      siteVisitDate: json['siteVisitDate'] != null ? DateTime.parse(json['siteVisitDate']) : null,
      clarificationDeadline: json['clarificationDeadline'] != null ? DateTime.parse(json['clarificationDeadline']) : null,
      evaluationStartDate: json['evaluationStartDate'] != null ? DateTime.parse(json['evaluationStartDate']) : null,
      evaluationEndDate: json['evaluationEndDate'] != null ? DateTime.parse(json['evaluationEndDate']) : null,
      awardDate: json['awardDate'] != null ? DateTime.parse(json['awardDate']) : null,
      contractSigningDate: json['contractSigningDate'] != null ? DateTime.parse(json['contractSigningDate']) : null,
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      estimatedBudget: (json['estimatedBudget'] ?? 0).toDouble(),
      tenderFee: (json['tenderFee'] ?? 0).toDouble(),
      tenderFeePaymentMethod: json['tenderFeePaymentMethod'] ?? '',
      bidSecurityAmount: (json['bidSecurityAmount'] ?? 0).toDouble(),
      bidSecurityType: BidSecurityType.values.firstWhere(
            (e) => e.name == (json['bidSecurityType'] ?? ''),
        orElse: () => BidSecurityType.BANK_GUARANTEE,
      ),
      bidSecurityPercentage: (json['bidSecurityPercentage'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      budgetSource: json['budgetSource'],
      tenderDocument: json['tenderDocument'] ?? '',
      biddingDocuments: List<String>.from(json['biddingDocuments'] ?? []),
      technicalSpecifications: List<String>.from(json['technicalSpecifications'] ?? []),
      drawings: List<String>.from(json['drawings'] ?? []),
      boq: json['boq'] ?? '',
      termsAndConditions: json['termsAndConditions'] ?? '',
      preQualificationRequired: json['preQualificationRequired'] ?? false,
      eligibilityCriteria: List<EligibilityCriterion>.from(
        (json['eligibilityCriteria'] ?? []).map((x) => EligibilityCriterion.fromJson(x)),
      ),
      technicalRequirements: List<TechnicalRequirement>.from(
        (json['technicalRequirements'] ?? []).map((x) => TechnicalRequirement.fromJson(x)),
      ),
      financialRequirements: List<FinancialRequirement>.from(
        (json['financialRequirements'] ?? []).map((x) => FinancialRequirement.fromJson(x)),
      ),
      experienceRequirements: List<ExperienceRequirement>.from(
        (json['experienceRequirements'] ?? []).map((x) => ExperienceRequirement.fromJson(x)),
      ),
      evaluationCriteria: List<EvaluationCriterion>.from(
        (json['evaluationCriteria'] ?? []).map((x) => EvaluationCriterion.fromJson(x)),
      ),
      technicalWeight: (json['technicalWeight'] ?? 0).toDouble(),
      financialWeight: (json['financialWeight'] ?? 0).toDouble(),
      totalWeight: (json['totalWeight'] ?? 100).toDouble(),
      contactPerson: json['contactPerson'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      contactDepartment: json['contactDepartment'] ?? '',
      bidOpeningVenue: json['bidOpeningVenue'] ?? '',
      bidSubmissionMethod: BidSubmissionMethod.values.firstWhere(
            (e) => e.name == (json['bidSubmissionMethod'] ?? ''),
        orElse: () => BidSubmissionMethod.ONLINE,
      ),
      bidValidityPeriod: json['bidValidityPeriod'] ?? 0,
      contractDuration: json['contractDuration'] ?? 0,
      amendments: List<TenderAmendment>.from(
        (json['amendments'] ?? []).map((x) => TenderAmendment.fromJson(x)),
      ),
      clarifications: List<TenderClarification>.from(
        (json['clarifications'] ?? []).map((x) => TenderClarification.fromJson(x)),
      ),
      extensions: List<TenderExtension>.from(
        (json['extensions'] ?? []).map((x) => TenderExtension.fromJson(x)),
      ),
      awardedTo: json['awardedTo'],
      awardedCompany: json['awardedCompany'],
      awardedAmount: json['awardedAmount']?.toDouble(),
      awardRemarks: json['awardRemarks'],
      createdBy: json['createdBy']?['_id'] ?? json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedBy: json['updatedBy']?['_id'] ?? json['updatedBy'] ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      isActive: json['isActive'] ?? true,
      isPublished: json['isPublished'] ?? false,
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      version: json['version'] ?? 1,
      workflowState: json['workflowState'],
      nextAction: json['nextAction'],
      actionDeadline: json['actionDeadline'] != null ? DateTime.parse(json['actionDeadline']) : null,
    );
  }

  get estimatedValue => null;

  get reference => null;

  Map<String, dynamic> toJson() {
    return {
      'tenderNumber': tenderNumber,
      'title': title,
      'description': description,
      'referenceNumber': referenceNumber,
      'category': category.name,
      'subCategory': subCategory,
      'department': department,
      'tenderType': tenderType.name,
      'procurementMethod': procurementMethod.name,
      'status': status.name,
      'stage': stage.name,
      'publishedDate': publishedDate.toIso8601String(),
      'advertisementDate': advertisementDate.toIso8601String(),
      'closingDate': closingDate.toIso8601String(),
      'openingDate': openingDate.toIso8601String(),
      'preBidMeetingDate': preBidMeetingDate?.toIso8601String(),
      'siteVisitDate': siteVisitDate?.toIso8601String(),
      'clarificationDeadline': clarificationDeadline?.toIso8601String(),
      'evaluationStartDate': evaluationStartDate?.toIso8601String(),
      'evaluationEndDate': evaluationEndDate?.toIso8601String(),
      'awardDate': awardDate?.toIso8601String(),
      'contractSigningDate': contractSigningDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'estimatedBudget': estimatedBudget,
      'tenderFee': tenderFee,
      'tenderFeePaymentMethod': tenderFeePaymentMethod,
      'bidSecurityAmount': bidSecurityAmount,
      'bidSecurityType': bidSecurityType.name,
      'bidSecurityPercentage': bidSecurityPercentage,
      'currency': currency,
      'budgetSource': budgetSource,
      'tenderDocument': tenderDocument,
      'biddingDocuments': biddingDocuments,
      'technicalSpecifications': technicalSpecifications,
      'drawings': drawings,
      'boq': boq,
      'termsAndConditions': termsAndConditions,
      'preQualificationRequired': preQualificationRequired,
      'eligibilityCriteria': eligibilityCriteria.map((x) => x.toJson()).toList(),
      'technicalRequirements': technicalRequirements.map((x) => x.toJson()).toList(),
      'financialRequirements': financialRequirements.map((x) => x.toJson()).toList(),
      'experienceRequirements': experienceRequirements.map((x) => x.toJson()).toList(),
      'evaluationCriteria': evaluationCriteria.map((x) => x.toJson()).toList(),
      'technicalWeight': technicalWeight,
      'financialWeight': financialWeight,
      'totalWeight': totalWeight,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'contactDepartment': contactDepartment,
      'bidOpeningVenue': bidOpeningVenue,
      'bidSubmissionMethod': bidSubmissionMethod.name,
      'bidValidityPeriod': bidValidityPeriod,
      'contractDuration': contractDuration,
      'amendments': amendments.map((x) => x.toJson()).toList(),
      'clarifications': clarifications.map((x) => x.toJson()).toList(),
      'extensions': extensions.map((x) => x.toJson()).toList(),
      'awardedTo': awardedTo,
      'awardedCompany': awardedCompany,
      'awardedAmount': awardedAmount,
      'awardRemarks': awardRemarks,
    };
  }

  Tender copyWith({
    String? id,
    String? tenderNumber,
    String? title,
    String? description,
    String? referenceNumber,
    TenderCategory? category,
    String? subCategory,
    String? department,
    TenderType? tenderType,
    ProcurementMethod? procurementMethod,
    TenderStatus? status,
    TenderStage? stage,
    DateTime? publishedDate,
    DateTime? advertisementDate,
    DateTime? closingDate,
    DateTime? openingDate,
    DateTime? preBidMeetingDate,
    DateTime? siteVisitDate,
    DateTime? clarificationDeadline,
    DateTime? evaluationStartDate,
    DateTime? evaluationEndDate,
    DateTime? awardDate,
    DateTime? contractSigningDate,
    DateTime? completionDate,
    double? estimatedBudget,
    double? tenderFee,
    String? tenderFeePaymentMethod,
    double? bidSecurityAmount,
    BidSecurityType? bidSecurityType,
    double? bidSecurityPercentage,
    String? currency,
    String? budgetSource,
    String? tenderDocument,
    List<String>? biddingDocuments,
    List<String>? technicalSpecifications,
    List<String>? drawings,
    String? boq,
    String? termsAndConditions,
    bool? preQualificationRequired,
    List<EligibilityCriterion>? eligibilityCriteria,
    List<TechnicalRequirement>? technicalRequirements,
    List<FinancialRequirement>? financialRequirements,
    List<ExperienceRequirement>? experienceRequirements,
    List<EvaluationCriterion>? evaluationCriteria,
    double? technicalWeight,
    double? financialWeight,
    double? totalWeight,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? contactDepartment,
    String? bidOpeningVenue,
    BidSubmissionMethod? bidSubmissionMethod,
    int? bidValidityPeriod,
    int? contractDuration,
    List<TenderAmendment>? amendments,
    List<TenderClarification>? clarifications,
    List<TenderExtension>? extensions,
    String? awardedTo,
    String? awardedCompany,
    double? awardedAmount,
    String? awardRemarks,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    bool? isActive,
    bool? isPublished,
    int? views,
    int? downloads,
    int? version,
    String? workflowState,
    String? nextAction,
    DateTime? actionDeadline,
  }) {
    return Tender(
      id: id ?? this.id,
      tenderNumber: tenderNumber ?? this.tenderNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      department: department ?? this.department,
      tenderType: tenderType ?? this.tenderType,
      procurementMethod: procurementMethod ?? this.procurementMethod,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      publishedDate: publishedDate ?? this.publishedDate,
      advertisementDate: advertisementDate ?? this.advertisementDate,
      closingDate: closingDate ?? this.closingDate,
      openingDate: openingDate ?? this.openingDate,
      preBidMeetingDate: preBidMeetingDate ?? this.preBidMeetingDate,
      siteVisitDate: siteVisitDate ?? this.siteVisitDate,
      clarificationDeadline: clarificationDeadline ?? this.clarificationDeadline,
      evaluationStartDate: evaluationStartDate ?? this.evaluationStartDate,
      evaluationEndDate: evaluationEndDate ?? this.evaluationEndDate,
      awardDate: awardDate ?? this.awardDate,
      contractSigningDate: contractSigningDate ?? this.contractSigningDate,
      completionDate: completionDate ?? this.completionDate,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      tenderFee: tenderFee ?? this.tenderFee,
      tenderFeePaymentMethod: tenderFeePaymentMethod ?? this.tenderFeePaymentMethod,
      bidSecurityAmount: bidSecurityAmount ?? this.bidSecurityAmount,
      bidSecurityType: bidSecurityType ?? this.bidSecurityType,
      bidSecurityPercentage: bidSecurityPercentage ?? this.bidSecurityPercentage,
      currency: currency ?? this.currency,
      budgetSource: budgetSource ?? this.budgetSource,
      tenderDocument: tenderDocument ?? this.tenderDocument,
      biddingDocuments: biddingDocuments ?? this.biddingDocuments,
      technicalSpecifications: technicalSpecifications ?? this.technicalSpecifications,
      drawings: drawings ?? this.drawings,
      boq: boq ?? this.boq,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      preQualificationRequired: preQualificationRequired ?? this.preQualificationRequired,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      technicalRequirements: technicalRequirements ?? this.technicalRequirements,
      financialRequirements: financialRequirements ?? this.financialRequirements,
      experienceRequirements: experienceRequirements ?? this.experienceRequirements,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      technicalWeight: technicalWeight ?? this.technicalWeight,
      financialWeight: financialWeight ?? this.financialWeight,
      totalWeight: totalWeight ?? this.totalWeight,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactDepartment: contactDepartment ?? this.contactDepartment,
      bidOpeningVenue: bidOpeningVenue ?? this.bidOpeningVenue,
      bidSubmissionMethod: bidSubmissionMethod ?? this.bidSubmissionMethod,
      bidValidityPeriod: bidValidityPeriod ?? this.bidValidityPeriod,
      contractDuration: contractDuration ?? this.contractDuration,
      amendments: amendments ?? this.amendments,
      clarifications: clarifications ?? this.clarifications,
      extensions: extensions ?? this.extensions,
      awardedTo: awardedTo ?? this.awardedTo,
      awardedCompany: awardedCompany ?? this.awardedCompany,
      awardedAmount: awardedAmount ?? this.awardedAmount,
      awardRemarks: awardRemarks ?? this.awardRemarks,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isPublished: isPublished ?? this.isPublished,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      version: version ?? this.version,
      workflowState: workflowState ?? this.workflowState,
      nextAction: nextAction ?? this.nextAction,
      actionDeadline: actionDeadline ?? this.actionDeadline,
    );
  }
}

// Enums
enum TenderCategory {
  WATER_SUPPLY,
  SANITATION,
  SEWERAGE,
  INFRASTRUCTURE,
  CONSULTANCY,
  GOODS,
  SERVICES,
  WORKS,
  NON_CONSULTANCY_SERVICES
}

enum TenderType {
  NATIONAL,
  INTERNATIONAL,
  LOCAL
}

enum ProcurementMethod {
  OPEN_TENDER,
  RESTRICTED_TENDER,
  DIRECT_PROCUREMENT,
  REQUEST_FOR_PROPOSAL,
  REQUEST_FOR_QUOTATION
}

enum TenderStatus {
  DRAFT,
  UNDER_REVIEW,
  APPROVED,
  PUBLISHED,
  ACTIVE,
  CLOSED,
  UNDER_EVALUATION,
  TECHNICAL_EVALUATION,
  FINANCIAL_EVALUATION,
  AWARDED,
  CANCELLED,
  COMPLETED
}

enum TenderStage {
  DRAFTING,
  REVIEW,
  APPROVAL,
  ADVERTISEMENT,
  BID_RECEIPT,
  BID_OPENING,
  EVALUATION,
  AWARD,
  CONTRACT_SIGNING,
  IMPLEMENTATION
}

enum BidSecurityType {
  BANK_GUARANTEE,
  INSURANCE_BOND,
  CASH,
  CHECK,
  NONE
}

enum BidSubmissionMethod {
  PHYSICAL,
  ONLINE,
  EMAIL,
  HYBRID
}

enum ClarificationStatus {
  PENDING,
  ANSWERED,
  REJECTED
}

// Supporting Classes
class EligibilityCriterion {
  final String criterion;
  final String description;
  final bool isMandatory;
  final List<String> documentsRequired;

  EligibilityCriterion({
    required this.criterion,
    required this.description,
    required this.isMandatory,
    required this.documentsRequired,
  });

  factory EligibilityCriterion.fromJson(Map<String, dynamic> json) {
    return EligibilityCriterion(
      criterion: json['criterion'] ?? '',
      description: json['description'] ?? '',
      isMandatory: json['isMandatory'] ?? true,
      documentsRequired: List<String>.from(json['documentsRequired'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'description': description,
      'isMandatory': isMandatory,
      'documentsRequired': documentsRequired,
    };
  }
}

class TechnicalRequirement {
  final String requirement;
  final String description;
  final String standard;
  final bool isMandatory;

  TechnicalRequirement({
    required this.requirement,
    required this.description,
    required this.standard,
    required this.isMandatory,
  });

  factory TechnicalRequirement.fromJson(Map<String, dynamic> json) {
    return TechnicalRequirement(
      requirement: json['requirement'] ?? '',
      description: json['description'] ?? '',
      standard: json['standard'] ?? '',
      isMandatory: json['isMandatory'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'description': description,
      'standard': standard,
      'isMandatory': isMandatory,
    };
  }
}

class FinancialRequirement {
  final String requirement;
  final String description;
  final double? minimumValue;
  final List<String> documentsRequired;

  FinancialRequirement({
    required this.requirement,
    required this.description,
    this.minimumValue,
    required this.documentsRequired,
  });

  factory FinancialRequirement.fromJson(Map<String, dynamic> json) {
    return FinancialRequirement(
      requirement: json['requirement'] ?? '',
      description: json['description'] ?? '',
      minimumValue: json['minimumValue']?.toDouble(),
      documentsRequired: List<String>.from(json['documentsRequired'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'description': description,
      'minimumValue': minimumValue,
      'documentsRequired': documentsRequired,
    };
  }
}

class ExperienceRequirement {
  final String type;
  final String description;
  final int minimumYears;
  final int similarProjectsRequired;
  final double? annualTurnover;

  ExperienceRequirement({
    required this.type,
    required this.description,
    required this.minimumYears,
    required this.similarProjectsRequired,
    this.annualTurnover,
  });

  factory ExperienceRequirement.fromJson(Map<String, dynamic> json) {
    return ExperienceRequirement(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      minimumYears: json['minimumYears'] ?? 0,
      similarProjectsRequired: json['similarProjectsRequired'] ?? 0,
      annualTurnover: json['annualTurnover']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'minimumYears': minimumYears,
      'similarProjectsRequired': similarProjectsRequired,
      'annualTurnover': annualTurnover,
    };
  }
}

class EvaluationCriterion {
  final String criterion;
  final double weight;
  final String description;
  final List<SubCriterion>? subCriteria;

  EvaluationCriterion({
    required this.criterion,
    required this.weight,
    required this.description,
    this.subCriteria,
  });

  factory EvaluationCriterion.fromJson(Map<String, dynamic> json) {
    return EvaluationCriterion(
      criterion: json['criterion'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      subCriteria: json['subCriteria'] != null
          ? List<SubCriterion>.from(
        json['subCriteria'].map((x) => SubCriterion.fromJson(x)),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'weight': weight,
      'description': description,
      'subCriteria': subCriteria?.map((x) => x.toJson()).toList(),
    };
  }
}

class SubCriterion {
  final String subCriterion;
  final double weight;
  final String description;
  final String scoringMethod;

  SubCriterion({
    required this.subCriterion,
    required this.weight,
    required this.description,
    required this.scoringMethod,
  });

  factory SubCriterion.fromJson(Map<String, dynamic> json) {
    return SubCriterion(
      subCriterion: json['subCriterion'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      scoringMethod: json['scoringMethod'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCriterion': subCriterion,
      'weight': weight,
      'description': description,
      'scoringMethod': scoringMethod,
    };
  }
}

class TenderAmendment {
  final String amendmentNumber;
  final DateTime amendmentDate;
  final String description;
  final List<String> changes;
  final String documentUrl;
  final String issuedBy;
  final List<String> affects;

  TenderAmendment({
    required this.amendmentNumber,
    required this.amendmentDate,
    required this.description,
    required this.changes,
    required this.documentUrl,
    required this.issuedBy,
    required this.affects,
  });

  factory TenderAmendment.fromJson(Map<String, dynamic> json) {
    return TenderAmendment(
      amendmentNumber: json['amendmentNumber'] ?? '',
      amendmentDate: DateTime.parse(json['amendmentDate'] ?? DateTime.now().toString()),
      description: json['description'] ?? '',
      changes: List<String>.from(json['changes'] ?? []),
      documentUrl: json['documentUrl'] ?? '',
      issuedBy: json['issuedBy']?['_id'] ?? json['issuedBy'] ?? '',
      affects: List<String>.from(json['affects'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amendmentNumber': amendmentNumber,
      'amendmentDate': amendmentDate.toIso8601String(),
      'description': description,
      'changes': changes,
      'documentUrl': documentUrl,
      'issuedBy': issuedBy,
      'affects': affects,
    };
  }
}

class TenderClarification {
  final String question;
  final String questionBy;
  final DateTime questionDate;
  final String? answer;
  final String? answeredBy;
  final DateTime? answerDate;
  final bool isPublic;
  final ClarificationStatus status;

  TenderClarification({
    required this.question,
    required this.questionBy,
    required this.questionDate,
    this.answer,
    this.answeredBy,
    this.answerDate,
    required this.isPublic,
    required this.status,
  });

  factory TenderClarification.fromJson(Map<String, dynamic> json) {
    return TenderClarification(
      question: json['question'] ?? '',
      questionBy: json['questionBy'] ?? '',
      questionDate: DateTime.parse(json['questionDate'] ?? DateTime.now().toString()),
      answer: json['answer'],
      answeredBy: json['answeredBy']?['_id'] ?? json['answeredBy'],
      answerDate: json['answerDate'] != null ? DateTime.parse(json['answerDate']) : null,
      isPublic: json['isPublic'] ?? true,
      status: ClarificationStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? ''),
        orElse: () => ClarificationStatus.PENDING,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionBy': questionBy,
      'questionDate': questionDate.toIso8601String(),
      'answer': answer,
      'answeredBy': answeredBy,
      'answerDate': answerDate?.toIso8601String(),
      'isPublic': isPublic,
      'status': status.name,
    };
  }
}

class TenderExtension {
  final int extensionNumber;
  final DateTime previousDeadline;
  final DateTime newDeadline;
  final String reason;
  final bool notifiedBidders;
  final DateTime extensionDate;

  TenderExtension({
    required this.extensionNumber,
    required this.previousDeadline,
    required this.newDeadline,
    required this.reason,
    required this.notifiedBidders,
    required this.extensionDate,
  });

  factory TenderExtension.fromJson(Map<String, dynamic> json) {
    return TenderExtension(
      extensionNumber: json['extensionNumber'] ?? 0,
      previousDeadline: DateTime.parse(json['previousDeadline'] ?? DateTime.now().toString()),
      newDeadline: DateTime.parse(json['newDeadline'] ?? DateTime.now().toString()),
      reason: json['reason'] ?? '',
      notifiedBidders: json['notifiedBidders'] ?? false,
      extensionDate: DateTime.parse(json['extensionDate'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extensionNumber': extensionNumber,
      'previousDeadline': previousDeadline.toIso8601String(),
      'newDeadline': newDeadline.toIso8601String(),
      'reason': reason,
      'notifiedBidders': notifiedBidders,
      'extensionDate': extensionDate.toIso8601String(),
    };
  }
}