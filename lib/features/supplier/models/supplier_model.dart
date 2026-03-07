import 'package:flutter/material.dart';

class Supplier {
  final String id;
  final String supplierNumber;
  final String companyName;
  final String? tradingName;
  final String registrationNumber;
  final String taxIdentificationNumber;
  final int yearEstablished;
  final String businessType;
  final String ownershipType;
  final String companyType;
  final List<String> industrySectors;
  final List<String> nawasscoCategories;
  final String supplierTier;
  final String riskRating;
  final Map<String, dynamic> contactDetails;
  final List<dynamic> addresses;
  final List<dynamic> contactPersons;
  final Map<String, dynamic> financialInformation;
  final List<dynamic> bankingDetails;
  final Map<String, dynamic> creditInformation;
  final Map<String, dynamic> workforce;
  final List<dynamic> equipment;
  final List<dynamic> technicalCapabilities;
  final List<dynamic> pastProjects;
  final List<dynamic> certifications;
  final List<dynamic> licenses;
  final Map<String, dynamic> statutoryCompliance;
  final Map<String, dynamic> blacklistStatus;
  final double complianceScore;
  final Map<String, dynamic> performanceMetrics;
  final List<dynamic> evaluationHistory;
  final List<dynamic> awards;
  final List<dynamic> documents;
  final String status;
  final DateTime registrationDate;
  final DateTime? approvalDate;
  final DateTime? lastEvaluationDate;
  final DateTime? nextEvaluationDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isActive;
  final List<String> notes;

  Supplier({
    required this.id,
    required this.supplierNumber,
    required this.companyName,
    this.tradingName,
    required this.registrationNumber,
    required this.taxIdentificationNumber,
    required this.yearEstablished,
    required this.businessType,
    required this.ownershipType,
    required this.companyType,
    required this.industrySectors,
    required this.nawasscoCategories,
    required this.supplierTier,
    required this.riskRating,
    required this.contactDetails,
    required this.addresses,
    required this.contactPersons,
    required this.financialInformation,
    required this.bankingDetails,
    required this.creditInformation,
    required this.workforce,
    required this.equipment,
    required this.technicalCapabilities,
    required this.pastProjects,
    required this.certifications,
    required this.licenses,
    required this.statutoryCompliance,
    required this.blacklistStatus,
    required this.complianceScore,
    required this.performanceMetrics,
    required this.evaluationHistory,
    required this.awards,
    required this.documents,
    required this.status,
    required this.registrationDate,
    this.approvalDate,
    this.lastEvaluationDate,
    this.nextEvaluationDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isActive,
    required this.notes,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id'] ?? json['id'] ?? '',
      supplierNumber: json['supplierNumber'] ?? '',
      companyName: json['companyName'] ?? '',
      tradingName: json['tradingName'],
      registrationNumber: json['registrationNumber'] ?? '',
      taxIdentificationNumber: json['taxIdentificationNumber'] ?? '',
      yearEstablished: json['yearEstablished'] ?? 0,
      businessType: json['businessType'] ?? 'manufacturer',
      ownershipType: json['ownershipType'] ?? 'private_limited',
      companyType: json['companyType'] ?? 'local',
      industrySectors: List<String>.from(json['industrySectors'] ?? []),
      nawasscoCategories: List<String>.from(json['nawasscoCategories'] ?? []),
      supplierTier: json['supplierTier'] ?? 'tier_3',
      riskRating: json['riskRating'] ?? 'medium',
      contactDetails: Map<String, dynamic>.from(json['contactDetails'] ?? {}),
      addresses: List<dynamic>.from(json['addresses'] ?? []),
      contactPersons: List<dynamic>.from(json['contactPersons'] ?? []),
      financialInformation: Map<String, dynamic>.from(json['financialInformation'] ?? {}),
      bankingDetails: List<dynamic>.from(json['bankingDetails'] ?? []),
      creditInformation: Map<String, dynamic>.from(json['creditInformation'] ?? {}),
      workforce: Map<String, dynamic>.from(json['workforce'] ?? {}),
      equipment: List<dynamic>.from(json['equipment'] ?? []),
      technicalCapabilities: List<dynamic>.from(json['technicalCapabilities'] ?? []),
      pastProjects: List<dynamic>.from(json['pastProjects'] ?? []),
      certifications: List<dynamic>.from(json['certifications'] ?? []),
      licenses: List<dynamic>.from(json['licenses'] ?? []),
      statutoryCompliance: Map<String, dynamic>.from(json['statutoryCompliance'] ?? {}),
      blacklistStatus: Map<String, dynamic>.from(json['blacklistStatus'] ?? {}),
      complianceScore: (json['complianceScore'] ?? 0).toDouble(),
      performanceMetrics: Map<String, dynamic>.from(json['performanceMetrics'] ?? {}),
      evaluationHistory: List<dynamic>.from(json['evaluationHistory'] ?? []),
      awards: List<dynamic>.from(json['awards'] ?? []),
      documents: List<dynamic>.from(json['documents'] ?? []),
      status: json['status'] ?? 'pending',
      registrationDate: DateTime.parse(json['registrationDate'] ?? DateTime.now().toIso8601String()),
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
      lastEvaluationDate: json['lastEvaluationDate'] != null ? DateTime.parse(json['lastEvaluationDate']) : null,
      nextEvaluationDate: json['nextEvaluationDate'] != null ? DateTime.parse(json['nextEvaluationDate']) : null,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      version: json['version'] ?? 1,
      isActive: json['isActive'] ?? true,
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierNumber': supplierNumber,
      'companyName': companyName,
      'tradingName': tradingName,
      'registrationNumber': registrationNumber,
      'taxIdentificationNumber': taxIdentificationNumber,
      'yearEstablished': yearEstablished,
      'businessType': businessType,
      'ownershipType': ownershipType,
      'companyType': companyType,
      'industrySectors': industrySectors,
      'nawasscoCategories': nawasscoCategories,
      'supplierTier': supplierTier,
      'riskRating': riskRating,
      'contactDetails': contactDetails,
      'addresses': addresses,
      'contactPersons': contactPersons,
      'financialInformation': financialInformation,
      'bankingDetails': bankingDetails,
      'creditInformation': creditInformation,
      'workforce': workforce,
      'equipment': equipment,
      'technicalCapabilities': technicalCapabilities,
      'pastProjects': pastProjects,
      'certifications': certifications,
      'licenses': licenses,
      'statutoryCompliance': statutoryCompliance,
      'blacklistStatus': blacklistStatus,
      'complianceScore': complianceScore,
      'performanceMetrics': performanceMetrics,
      'status': status,
      'isActive': isActive,
    };
  }
}