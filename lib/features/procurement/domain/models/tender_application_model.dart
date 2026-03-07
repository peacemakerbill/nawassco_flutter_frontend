import 'tender_model.dart';

class TenderApplication {
  final String id;
  final String applicationNumber;
  final String tender;
  final String applicant;
  final String company;
  final DateTime? submissionDate;
  final BidSubmissionMethod submissionMethod;
  final ApplicationStatus applicationStatus;
  final ApplicationStage applicationStage;
  final double? totalBidAmount;
  final List<BidAmountBreakdown> bidAmountBreakdown;
  final String currency;
  final int? bidValidityPeriod;
  final List<AlternativeProposal>? alternativeProposals;
  final String? technicalProposal;
  final List<TechnicalDocument> technicalDocuments;
  final String? methodology;
  final List<WorkPlanItem> workPlan;
  final List<KeyPersonnel> keyPersonnel;
  final List<FinancialDocument> financialDocuments;
  final BidSecurityDetails? bidSecurity;
  final TaxCompliance? taxCompliance;
  final CompanyProfile companyProfile;
  final List<PastExperience> pastExperience;
  final List<EquipmentItem> equipmentList;
  final List<EligibilityCompliance> eligibilityCompliance;
  final List<MandatoryRequirement> mandatoryRequirements;
  final List<StatutoryRequirement> statutoryRequirements;
  final double? technicalScore;
  final double? financialScore;
  final double? totalScore;
  final String? evaluationRemarks;
  final String? evaluatedBy;
  final DateTime? evaluationDate;
  final bool isAwarded;
  final double? awardAmount;
  final DateTime? awardDate;
  final String? contractNumber;
  final bool isWithdrawn;
  final DateTime? withdrawalDate;
  final String? withdrawalReason;
  final List<ApplicationClarification> clarifications;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ipAddress;
  final String? userAgent;
  final int version;
  final bool isDraft;
  final DateTime lastSaved;

  TenderApplication({
    required this.id,
    required this.applicationNumber,
    required this.tender,
    required this.applicant,
    required this.company,
    this.submissionDate,
    required this.submissionMethod,
    required this.applicationStatus,
    required this.applicationStage,
    this.totalBidAmount,
    required this.bidAmountBreakdown,
    required this.currency,
    this.bidValidityPeriod,
    this.alternativeProposals,
    this.technicalProposal,
    required this.technicalDocuments,
    this.methodology,
    required this.workPlan,
    required this.keyPersonnel,
    required this.financialDocuments,
    this.bidSecurity,
    this.taxCompliance,
    required this.companyProfile,
    required this.pastExperience,
    required this.equipmentList,
    required this.eligibilityCompliance,
    required this.mandatoryRequirements,
    required this.statutoryRequirements,
    this.technicalScore,
    this.financialScore,
    this.totalScore,
    this.evaluationRemarks,
    this.evaluatedBy,
    this.evaluationDate,
    required this.isAwarded,
    this.awardAmount,
    this.awardDate,
    this.contractNumber,
    required this.isWithdrawn,
    this.withdrawalDate,
    this.withdrawalReason,
    required this.clarifications,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.ipAddress,
    this.userAgent,
    required this.version,
    required this.isDraft,
    required this.lastSaved,
  });

  factory TenderApplication.fromJson(Map<String, dynamic> json) {
    return TenderApplication(
      id: json['_id'] ?? json['id'] ?? '',
      applicationNumber: json['applicationNumber'] ?? '',
      tender: json['tender']?['_id'] ?? json['tender'] ?? '',
      applicant: json['applicant']?['_id'] ?? json['applicant'] ?? '',
      company: json['company']?['_id'] ?? json['company'] ?? '',
      submissionDate: json['submissionDate'] != null ? DateTime.parse(json['submissionDate']) : null,
      submissionMethod: BidSubmissionMethod.values.firstWhere(
            (e) => e.name == (json['submissionMethod'] ?? ''),
        orElse: () => BidSubmissionMethod.ONLINE,
      ),
      applicationStatus: ApplicationStatus.values.firstWhere(
            (e) => e.name == (json['applicationStatus'] ?? ''),
        orElse: () => ApplicationStatus.DRAFT,
      ),
      applicationStage: ApplicationStage.values.firstWhere(
            (e) => e.name == (json['applicationStage'] ?? ''),
        orElse: () => ApplicationStage.DRAFT,
      ),
      totalBidAmount: json['totalBidAmount']?.toDouble(),
      bidAmountBreakdown: List<BidAmountBreakdown>.from(
        (json['bidAmountBreakdown'] ?? []).map((x) => BidAmountBreakdown.fromJson(x)),
      ),
      currency: json['currency'] ?? 'KES',
      bidValidityPeriod: json['bidValidityPeriod'],
      alternativeProposals: json['alternativeProposals'] != null
          ? List<AlternativeProposal>.from(
        json['alternativeProposals'].map((x) => AlternativeProposal.fromJson(x)),
      )
          : null,
      technicalProposal: json['technicalProposal'],
      technicalDocuments: List<TechnicalDocument>.from(
        (json['technicalDocuments'] ?? []).map((x) => TechnicalDocument.fromJson(x)),
      ),
      methodology: json['methodology'],
      workPlan: List<WorkPlanItem>.from(
        (json['workPlan'] ?? []).map((x) => WorkPlanItem.fromJson(x)),
      ),
      keyPersonnel: List<KeyPersonnel>.from(
        (json['keyPersonnel'] ?? []).map((x) => KeyPersonnel.fromJson(x)),
      ),
      financialDocuments: List<FinancialDocument>.from(
        (json['financialDocuments'] ?? []).map((x) => FinancialDocument.fromJson(x)),
      ),
      bidSecurity: json['bidSecurity'] != null ? BidSecurityDetails.fromJson(json['bidSecurity']) : null,
      taxCompliance: json['taxCompliance'] != null ? TaxCompliance.fromJson(json['taxCompliance']) : null,
      companyProfile: CompanyProfile.fromJson(json['companyProfile'] ?? {}),
      pastExperience: List<PastExperience>.from(
        (json['pastExperience'] ?? []).map((x) => PastExperience.fromJson(x)),
      ),
      equipmentList: List<EquipmentItem>.from(
        (json['equipmentList'] ?? []).map((x) => EquipmentItem.fromJson(x)),
      ),
      eligibilityCompliance: List<EligibilityCompliance>.from(
        (json['eligibilityCompliance'] ?? []).map((x) => EligibilityCompliance.fromJson(x)),
      ),
      mandatoryRequirements: List<MandatoryRequirement>.from(
        (json['mandatoryRequirements'] ?? []).map((x) => MandatoryRequirement.fromJson(x)),
      ),
      statutoryRequirements: List<StatutoryRequirement>.from(
        (json['statutoryRequirements'] ?? []).map((x) => StatutoryRequirement.fromJson(x)),
      ),
      technicalScore: json['technicalScore']?.toDouble(),
      financialScore: json['financialScore']?.toDouble(),
      totalScore: json['totalScore']?.toDouble(),
      evaluationRemarks: json['evaluationRemarks'],
      evaluatedBy: json['evaluatedBy']?['_id'] ?? json['evaluatedBy'],
      evaluationDate: json['evaluationDate'] != null ? DateTime.parse(json['evaluationDate']) : null,
      isAwarded: json['isAwarded'] ?? false,
      awardAmount: json['awardAmount']?.toDouble(),
      awardDate: json['awardDate'] != null ? DateTime.parse(json['awardDate']) : null,
      contractNumber: json['contractNumber'],
      isWithdrawn: json['isWithdrawn'] ?? false,
      withdrawalDate: json['withdrawalDate'] != null ? DateTime.parse(json['withdrawalDate']) : null,
      withdrawalReason: json['withdrawalReason'],
      clarifications: List<ApplicationClarification>.from(
        (json['clarifications'] ?? []).map((x) => ApplicationClarification.fromJson(x)),
      ),
      createdBy: json['createdBy']?['_id'] ?? json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      version: json['version'] ?? 1,
      isDraft: json['isDraft'] ?? true,
      lastSaved: DateTime.parse(json['lastSaved'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationNumber': applicationNumber,
      'tender': tender,
      'applicant': applicant,
      'company': company,
      'submissionDate': submissionDate?.toIso8601String(),
      'submissionMethod': submissionMethod.name,
      'applicationStatus': applicationStatus.name,
      'applicationStage': applicationStage.name,
      'totalBidAmount': totalBidAmount,
      'bidAmountBreakdown': bidAmountBreakdown.map((x) => x.toJson()).toList(),
      'currency': currency,
      'bidValidityPeriod': bidValidityPeriod,
      'alternativeProposals': alternativeProposals?.map((x) => x.toJson()).toList(),
      'technicalProposal': technicalProposal,
      'technicalDocuments': technicalDocuments.map((x) => x.toJson()).toList(),
      'methodology': methodology,
      'workPlan': workPlan.map((x) => x.toJson()).toList(),
      'keyPersonnel': keyPersonnel.map((x) => x.toJson()).toList(),
      'financialDocuments': financialDocuments.map((x) => x.toJson()).toList(),
      'bidSecurity': bidSecurity?.toJson(),
      'taxCompliance': taxCompliance?.toJson(),
      'companyProfile': companyProfile.toJson(),
      'pastExperience': pastExperience.map((x) => x.toJson()).toList(),
      'equipmentList': equipmentList.map((x) => x.toJson()).toList(),
      'eligibilityCompliance': eligibilityCompliance.map((x) => x.toJson()).toList(),
      'mandatoryRequirements': mandatoryRequirements.map((x) => x.toJson()).toList(),
      'statutoryRequirements': statutoryRequirements.map((x) => x.toJson()).toList(),
      'technicalScore': technicalScore,
      'financialScore': financialScore,
      'totalScore': totalScore,
      'evaluationRemarks': evaluationRemarks,
      'evaluatedBy': evaluatedBy,
      'evaluationDate': evaluationDate?.toIso8601String(),
      'isAwarded': isAwarded,
      'awardAmount': awardAmount,
      'awardDate': awardDate?.toIso8601String(),
      'contractNumber': contractNumber,
      'isWithdrawn': isWithdrawn,
      'withdrawalDate': withdrawalDate?.toIso8601String(),
      'withdrawalReason': withdrawalReason,
      'clarifications': clarifications.map((x) => x.toJson()).toList(),
    };
  }

  TenderApplication copyWith({
    String? id,
    String? applicationNumber,
    String? tender,
    String? applicant,
    String? company,
    DateTime? submissionDate,
    BidSubmissionMethod? submissionMethod,
    ApplicationStatus? applicationStatus,
    ApplicationStage? applicationStage,
    double? totalBidAmount,
    List<BidAmountBreakdown>? bidAmountBreakdown,
    String? currency,
    int? bidValidityPeriod,
    List<AlternativeProposal>? alternativeProposals,
    String? technicalProposal,
    List<TechnicalDocument>? technicalDocuments,
    String? methodology,
    List<WorkPlanItem>? workPlan,
    List<KeyPersonnel>? keyPersonnel,
    List<FinancialDocument>? financialDocuments,
    BidSecurityDetails? bidSecurity,
    TaxCompliance? taxCompliance,
    CompanyProfile? companyProfile,
    List<PastExperience>? pastExperience,
    List<EquipmentItem>? equipmentList,
    List<EligibilityCompliance>? eligibilityCompliance,
    List<MandatoryRequirement>? mandatoryRequirements,
    List<StatutoryRequirement>? statutoryRequirements,
    double? technicalScore,
    double? financialScore,
    double? totalScore,
    String? evaluationRemarks,
    String? evaluatedBy,
    DateTime? evaluationDate,
    bool? isAwarded,
    double? awardAmount,
    DateTime? awardDate,
    String? contractNumber,
    bool? isWithdrawn,
    DateTime? withdrawalDate,
    String? withdrawalReason,
    List<ApplicationClarification>? clarifications,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ipAddress,
    String? userAgent,
    int? version,
    bool? isDraft,
    DateTime? lastSaved,
  }) {
    return TenderApplication(
      id: id ?? this.id,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      tender: tender ?? this.tender,
      applicant: applicant ?? this.applicant,
      company: company ?? this.company,
      submissionDate: submissionDate ?? this.submissionDate,
      submissionMethod: submissionMethod ?? this.submissionMethod,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      applicationStage: applicationStage ?? this.applicationStage,
      totalBidAmount: totalBidAmount ?? this.totalBidAmount,
      bidAmountBreakdown: bidAmountBreakdown ?? this.bidAmountBreakdown,
      currency: currency ?? this.currency,
      bidValidityPeriod: bidValidityPeriod ?? this.bidValidityPeriod,
      alternativeProposals: alternativeProposals ?? this.alternativeProposals,
      technicalProposal: technicalProposal ?? this.technicalProposal,
      technicalDocuments: technicalDocuments ?? this.technicalDocuments,
      methodology: methodology ?? this.methodology,
      workPlan: workPlan ?? this.workPlan,
      keyPersonnel: keyPersonnel ?? this.keyPersonnel,
      financialDocuments: financialDocuments ?? this.financialDocuments,
      bidSecurity: bidSecurity ?? this.bidSecurity,
      taxCompliance: taxCompliance ?? this.taxCompliance,
      companyProfile: companyProfile ?? this.companyProfile,
      pastExperience: pastExperience ?? this.pastExperience,
      equipmentList: equipmentList ?? this.equipmentList,
      eligibilityCompliance: eligibilityCompliance ?? this.eligibilityCompliance,
      mandatoryRequirements: mandatoryRequirements ?? this.mandatoryRequirements,
      statutoryRequirements: statutoryRequirements ?? this.statutoryRequirements,
      technicalScore: technicalScore ?? this.technicalScore,
      financialScore: financialScore ?? this.financialScore,
      totalScore: totalScore ?? this.totalScore,
      evaluationRemarks: evaluationRemarks ?? this.evaluationRemarks,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      isAwarded: isAwarded ?? this.isAwarded,
      awardAmount: awardAmount ?? this.awardAmount,
      awardDate: awardDate ?? this.awardDate,
      contractNumber: contractNumber ?? this.contractNumber,
      isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      withdrawalDate: withdrawalDate ?? this.withdrawalDate,
      withdrawalReason: withdrawalReason ?? this.withdrawalReason,
      clarifications: clarifications ?? this.clarifications,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      version: version ?? this.version,
      isDraft: isDraft ?? this.isDraft,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }
}

// Enums for Tender Application
enum ApplicationStatus {
  DRAFT,
  SUBMITTED,
  UNDER_REVIEW,
  TECHNICAL_EVALUATION,
  FINANCIAL_EVALUATION,
  QUALIFIED,
  DISQUALIFIED,
  AWARDED,
  REJECTED,
  WITHDRAWN,
  PENDING_CLARIFICATION
}

enum ApplicationStage {
  DRAFT,
  DOCUMENT_UPLOAD,
  TECHNICAL_PROPOSAL,
  FINANCIAL_PROPOSAL,
  SUBMISSION,
  EVALUATION,
  CLARIFICATION,
  AWARD,
  COMPLETED
}

enum BidSecurityType {
  BANK_GUARANTEE,
  INSURANCE_BOND,
  CASH_DEPOSIT,
  CHECK,
  LETTER_OF_CREDIT,
  PERFORMANCE_BOND,
  BID_BOND
}

enum ClarificationStatus {
  PENDING,
  ANSWERED,
  CLARIFIED,
  REJECTED,
  EXPIRED,
  UNDER_REVIEW
}

enum DocumentType {
  TECHNICAL_PROPOSAL,
  FINANCIAL_PROPOSAL,
  COMPANY_REGISTRATION,
  TAX_COMPLIANCE,
  BID_SECURITY,
  PAST_EXPERIENCE,
  PERSONNEL_CV,
  EQUIPMENT_CERTIFICATION,
  FINANCIAL_STATEMENT,
  OTHER
}

// Supporting Classes for Tender Application
class BidAmountBreakdown {
  final String item;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String? remarks;

  BidAmountBreakdown({
    required this.item,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.remarks,
  });

  factory BidAmountBreakdown.fromJson(Map<String, dynamic> json) {
    return BidAmountBreakdown(
      item: json['item'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'remarks': remarks,
    };
  }
}

class AlternativeProposal {
  final String description;
  final String technicalDetails;
  final String financialImplications;
  final List<String> advantages;

  AlternativeProposal({
    required this.description,
    required this.technicalDetails,
    required this.financialImplications,
    required this.advantages,
  });

  factory AlternativeProposal.fromJson(Map<String, dynamic> json) {
    return AlternativeProposal(
      description: json['description'] ?? '',
      technicalDetails: json['technicalDetails'] ?? '',
      financialImplications: json['financialImplications'] ?? '',
      advantages: List<String>.from(json['advantages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'technicalDetails': technicalDetails,
      'financialImplications': financialImplications,
      'advantages': advantages,
    };
  }
}

class TechnicalDocument {
  final String documentType;
  final String documentName;
  final String documentUrl;
  final DateTime uploadDate;
  final double fileSize;
  final bool isVerified;
  final String? mimeType;
  final String? originalName;
  final String? firebasePath;

  TechnicalDocument({
    required this.documentType,
    required this.documentName,
    required this.documentUrl,
    required this.uploadDate,
    required this.fileSize,
    required this.isVerified,
    this.mimeType,
    this.originalName,
    this.firebasePath,
  });

  factory TechnicalDocument.fromJson(Map<String, dynamic> json) {
    return TechnicalDocument(
      documentType: json['documentType'] ?? '',
      documentName: json['documentName'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      uploadDate: DateTime.parse(json['uploadDate'] ?? DateTime.now().toString()),
      fileSize: (json['fileSize'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      mimeType: json['mimeType'],
      originalName: json['originalName'],
      firebasePath: json['firebasePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'uploadDate': uploadDate.toIso8601String(),
      'fileSize': fileSize,
      'isVerified': isVerified,
      'mimeType': mimeType,
      'originalName': originalName,
      'firebasePath': firebasePath,
    };
  }
}

class FinancialDocument {
  final String documentType;
  final String documentName;
  final String documentUrl;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final double? fileSize;
  final DateTime? uploadDate;

  FinancialDocument({
    required this.documentType,
    required this.documentName,
    required this.documentUrl,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.fileSize,
    this.uploadDate,
  });

  factory FinancialDocument.fromJson(Map<String, dynamic> json) {
    return FinancialDocument(
      documentType: json['documentType'] ?? '',
      documentName: json['documentName'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      issuingAuthority: json['issuingAuthority'],
      fileSize: json['fileSize']?.toDouble(),
      uploadDate: json['uploadDate'] != null ? DateTime.parse(json['uploadDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'issuingAuthority': issuingAuthority,
      'fileSize': fileSize,
      'uploadDate': uploadDate?.toIso8601String(),
    };
  }
}

class BidSecurityDetails {
  final BidSecurityType type;
  final double amount;
  final String issuer;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String documentUrl;
  final String referenceNumber;
  final double? fileSize;

  BidSecurityDetails({
    required this.type,
    required this.amount,
    required this.issuer,
    required this.issueDate,
    required this.expiryDate,
    required this.documentUrl,
    required this.referenceNumber,
    this.fileSize,
  });

  factory BidSecurityDetails.fromJson(Map<String, dynamic> json) {
    return BidSecurityDetails(
      type: BidSecurityType.values.firstWhere(
            (e) => e.name == (json['type'] ?? ''),
        orElse: () => BidSecurityType.BANK_GUARANTEE,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      issuer: json['issuer'] ?? '',
      issueDate: DateTime.parse(json['issueDate'] ?? DateTime.now().toString()),
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toString()),
      documentUrl: json['documentUrl'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      fileSize: json['fileSize']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'amount': amount,
      'issuer': issuer,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'documentUrl': documentUrl,
      'referenceNumber': referenceNumber,
      'fileSize': fileSize,
    };
  }
}

class TaxCompliance {
  final String pinCertificate;
  final String taxComplianceUrl;
  final String validityPeriod;
  final List<String>? issues;
  final double? certificateFileSize;

  TaxCompliance({
    required this.pinCertificate,
    required this.taxComplianceUrl,
    required this.validityPeriod,
    this.issues,
    this.certificateFileSize,
  });

  factory TaxCompliance.fromJson(Map<String, dynamic> json) {
    return TaxCompliance(
      pinCertificate: json['pinCertificate'] ?? '',
      taxComplianceUrl: json['taxComplianceUrl'] ?? '',
      validityPeriod: json['validityPeriod'] ?? '',
      issues: List<String>.from(json['issues'] ?? []),
      certificateFileSize: json['certificateFileSize']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pinCertificate': pinCertificate,
      'taxComplianceUrl': taxComplianceUrl,
      'validityPeriod': validityPeriod,
      'issues': issues,
      'certificateFileSize': certificateFileSize,
    };
  }
}

class CompanyProfile {
  final String companyName;
  final String registrationNumber;
  final int yearEstablished;
  final String physicalAddress;
  final String postalAddress;
  final String? website;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String? companyLogo;

  CompanyProfile({
    required this.companyName,
    required this.registrationNumber,
    required this.yearEstablished,
    required this.physicalAddress,
    required this.postalAddress,
    this.website,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    this.companyLogo,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      companyName: json['companyName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      yearEstablished: json['yearEstablished'] ?? 0,
      physicalAddress: json['physicalAddress'] ?? '',
      postalAddress: json['postalAddress'] ?? '',
      website: json['website'],
      contactPerson: json['contactPerson'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      companyLogo: json['companyLogo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'registrationNumber': registrationNumber,
      'yearEstablished': yearEstablished,
      'physicalAddress': physicalAddress,
      'postalAddress': postalAddress,
      'website': website,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'companyLogo': companyLogo,
    };
  }
}

class PastExperience {
  final String projectName;
  final String client;
  final double contractAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String scopeOfWork;
  final String referenceContact;
  final String referenceEmail;
  final String referencePhone;
  final String completionCertificate;
  final double? certificateFileSize;

  PastExperience({
    required this.projectName,
    required this.client,
    required this.contractAmount,
    required this.startDate,
    required this.endDate,
    required this.scopeOfWork,
    required this.referenceContact,
    required this.referenceEmail,
    required this.referencePhone,
    required this.completionCertificate,
    this.certificateFileSize,
  });

  factory PastExperience.fromJson(Map<String, dynamic> json) {
    return PastExperience(
      projectName: json['projectName'] ?? '',
      client: json['client'] ?? '',
      contractAmount: (json['contractAmount'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toString()),
      scopeOfWork: json['scopeOfWork'] ?? '',
      referenceContact: json['referenceContact'] ?? '',
      referenceEmail: json['referenceEmail'] ?? '',
      referencePhone: json['referencePhone'] ?? '',
      completionCertificate: json['completionCertificate'] ?? '',
      certificateFileSize: json['certificateFileSize']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'client': client,
      'contractAmount': contractAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'scopeOfWork': scopeOfWork,
      'referenceContact': referenceContact,
      'referenceEmail': referenceEmail,
      'referencePhone': referencePhone,
      'completionCertificate': completionCertificate,
      'certificateFileSize': certificateFileSize,
    };
  }
}

class EquipmentItem {
  final String equipmentName;
  final String model;
  final double quantity;
  final String condition;
  final String ownership;
  final String location;
  final String? certificationDocument;

  EquipmentItem({
    required this.equipmentName,
    required this.model,
    required this.quantity,
    required this.condition,
    required this.ownership,
    required this.location,
    this.certificationDocument,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      equipmentName: json['equipmentName'] ?? '',
      model: json['model'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      ownership: json['ownership'] ?? '',
      location: json['location'] ?? '',
      certificationDocument: json['certificationDocument'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentName': equipmentName,
      'model': model,
      'quantity': quantity,
      'condition': condition,
      'ownership': ownership,
      'location': location,
      'certificationDocument': certificationDocument,
    };
  }
}

class WorkPlanItem {
  final String activity;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final List<String>? dependencies;
  final String responsible;
  final List<String> milestones;
  final List<String>? deliverables;

  WorkPlanItem({
    required this.activity,
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.dependencies,
    required this.responsible,
    required this.milestones,
    this.deliverables,
  });

  factory WorkPlanItem.fromJson(Map<String, dynamic> json) {
    return WorkPlanItem(
      activity: json['activity'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toString()),
      duration: json['duration'] ?? 0,
      dependencies: List<String>.from(json['dependencies'] ?? []),
      responsible: json['responsible'] ?? '',
      milestones: List<String>.from(json['milestones'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration,
      'dependencies': dependencies,
      'responsible': responsible,
      'milestones': milestones,
      'deliverables': deliverables,
    };
  }
}

class KeyPersonnel {
  final String name;
  final String position;
  final String role;
  final String qualifications;
  final int experience;
  final String cvDocument;
  final String availability;
  final int similarProjects;
  final double? cvFileSize;
  final List<String>? professionalCertificates;

  KeyPersonnel({
    required this.name,
    required this.position,
    required this.role,
    required this.qualifications,
    required this.experience,
    required this.cvDocument,
    required this.availability,
    required this.similarProjects,
    this.cvFileSize,
    this.professionalCertificates,
  });

  factory KeyPersonnel.fromJson(Map<String, dynamic> json) {
    return KeyPersonnel(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      role: json['role'] ?? '',
      qualifications: json['qualifications'] ?? '',
      experience: json['experience'] ?? 0,
      cvDocument: json['cvDocument'] ?? '',
      availability: json['availability'] ?? '',
      similarProjects: json['similarProjects'] ?? 0,
      cvFileSize: json['cvFileSize']?.toDouble(),
      professionalCertificates: List<String>.from(json['professionalCertificates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'role': role,
      'qualifications': qualifications,
      'experience': experience,
      'cvDocument': cvDocument,
      'availability': availability,
      'similarProjects': similarProjects,
      'cvFileSize': cvFileSize,
      'professionalCertificates': professionalCertificates,
    };
  }
}

class EligibilityCompliance {
  final String criterion;
  final bool isCompliant;
  final List<String> supportingDocuments;
  final String? remarks;
  final String? verifiedBy;
  final DateTime? verifiedDate;

  EligibilityCompliance({
    required this.criterion,
    required this.isCompliant,
    required this.supportingDocuments,
    this.remarks,
    this.verifiedBy,
    this.verifiedDate,
  });

  factory EligibilityCompliance.fromJson(Map<String, dynamic> json) {
    return EligibilityCompliance(
      criterion: json['criterion'] ?? '',
      isCompliant: json['isCompliant'] ?? false,
      supportingDocuments: List<String>.from(json['supportingDocuments'] ?? []),
      remarks: json['remarks'],
      verifiedBy: json['verifiedBy']?['_id'] ?? json['verifiedBy'],
      verifiedDate: json['verifiedDate'] != null ? DateTime.parse(json['verifiedDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'isCompliant': isCompliant,
      'supportingDocuments': supportingDocuments,
      'remarks': remarks,
      'verifiedBy': verifiedBy,
      'verifiedDate': verifiedDate?.toIso8601String(),
    };
  }
}

class MandatoryRequirement {
  final String requirement;
  final bool isCompliant;
  final List<String> supportingDocuments;
  final String? remarks;
  final String? verifiedBy;
  final DateTime? verifiedDate;

  MandatoryRequirement({
    required this.requirement,
    required this.isCompliant,
    required this.supportingDocuments,
    this.remarks,
    this.verifiedBy,
    this.verifiedDate,
  });

  factory MandatoryRequirement.fromJson(Map<String, dynamic> json) {
    return MandatoryRequirement(
      requirement: json['requirement'] ?? '',
      isCompliant: json['isCompliant'] ?? false,
      supportingDocuments: List<String>.from(json['supportingDocuments'] ?? []),
      remarks: json['remarks'],
      verifiedBy: json['verifiedBy']?['_id'] ?? json['verifiedBy'],
      verifiedDate: json['verifiedDate'] != null ? DateTime.parse(json['verifiedDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'isCompliant': isCompliant,
      'supportingDocuments': supportingDocuments,
      'remarks': remarks,
      'verifiedBy': verifiedBy,
      'verifiedDate': verifiedDate?.toIso8601String(),
    };
  }
}

class StatutoryRequirement {
  final String requirement;
  final String documentUrl;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isCompliant;
  final double? fileSize;
  final String? verifiedBy;

  StatutoryRequirement({
    required this.requirement,
    required this.documentUrl,
    required this.issueDate,
    required this.expiryDate,
    required this.isCompliant,
    this.fileSize,
    this.verifiedBy,
  });

  factory StatutoryRequirement.fromJson(Map<String, dynamic> json) {
    return StatutoryRequirement(
      requirement: json['requirement'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      issueDate: DateTime.parse(json['issueDate'] ?? DateTime.now().toString()),
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toString()),
      isCompliant: json['isCompliant'] ?? false,
      fileSize: json['fileSize']?.toDouble(),
      verifiedBy: json['verifiedBy']?['_id'] ?? json['verifiedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'documentUrl': documentUrl,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isCompliant': isCompliant,
      'fileSize': fileSize,
      'verifiedBy': verifiedBy,
    };
  }
}

class ApplicationClarification {
  final String question;
  final DateTime questionDate;
  final String? answer;
  final DateTime? answerDate;
  final String askedBy;
  final String? answeredBy;
  final ClarificationStatus status;
  final List<String>? attachments;
  final bool isUrgent;

  ApplicationClarification({
    required this.question,
    required this.questionDate,
    this.answer,
    this.answerDate,
    required this.askedBy,
    this.answeredBy,
    required this.status,
    this.attachments,
    required this.isUrgent,
  });

  factory ApplicationClarification.fromJson(Map<String, dynamic> json) {
    return ApplicationClarification(
      question: json['question'] ?? '',
      questionDate: DateTime.parse(json['questionDate'] ?? DateTime.now().toString()),
      answer: json['answer'],
      answerDate: json['answerDate'] != null ? DateTime.parse(json['answerDate']) : null,
      askedBy: json['askedBy']?['_id'] ?? json['askedBy'] ?? '',
      answeredBy: json['answeredBy']?['_id'] ?? json['answeredBy'],
      status: ClarificationStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? ''),
        orElse: () => ClarificationStatus.PENDING,
      ),
      attachments: List<String>.from(json['attachments'] ?? []),
      isUrgent: json['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionDate': questionDate.toIso8601String(),
      'answer': answer,
      'answerDate': answerDate?.toIso8601String(),
      'askedBy': askedBy,
      'answeredBy': answeredBy,
      'status': status.name,
      'attachments': attachments,
      'isUrgent': isUrgent,
    };
  }
}