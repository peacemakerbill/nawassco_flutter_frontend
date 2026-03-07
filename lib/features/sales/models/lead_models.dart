import 'package:flutter/material.dart';

// Enums - Updated to match backend exactly
enum LeadStatus {
  newLead('new', 'New'),
  contacted('contacted', 'Contacted'),
  qualified('qualified', 'Qualified'),
  proposalSent('proposal_sent', 'Proposal Sent'),
  negotiation('negotiation', 'Negotiation'),
  converted('converted', 'Converted'),
  lost('lost', 'Lost'),
  unqualified('unqualified', 'Unqualified');

  final String value;
  final String displayName;

  const LeadStatus(this.value, this.displayName);

  String get name => value;

  static LeadStatus fromString(String value) {
    return LeadStatus.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LeadStatus.newLead,
    );
  }

  Color get color {
    return switch (this) {
      LeadStatus.newLead => Colors.blue,
      LeadStatus.contacted => Colors.orange,
      LeadStatus.qualified => Colors.purple,
      LeadStatus.proposalSent => Colors.indigo,
      LeadStatus.negotiation => Colors.deepOrange,
      LeadStatus.converted => Colors.green,
      LeadStatus.lost => Colors.red,
      LeadStatus.unqualified => Colors.grey,
    };
  }

  IconData get icon {
    return switch (this) {
      LeadStatus.newLead => Icons.new_releases,
      LeadStatus.contacted => Icons.phone,
      LeadStatus.qualified => Icons.star,
      LeadStatus.proposalSent => Icons.description,
      LeadStatus.negotiation => Icons.handshake,
      LeadStatus.converted => Icons.check_circle,
      LeadStatus.lost => Icons.cancel,
      LeadStatus.unqualified => Icons.block,
    };
  }
}

enum LeadSource {
  website('website', 'Website'),
  referral('referral', 'Referral'),
  socialMedia('social_media', 'Social Media'),
  emailCampaign('email_campaign', 'Email Campaign'),
  event('event', 'Event'),
  coldCall('cold_call', 'Cold Call'),
  partner('partner', 'Partner'),
  existingCustomer('existing_customer', 'Existing Customer');

  final String value;
  final String displayName;

  const LeadSource(this.value, this.displayName);

  String get name => value;

  static LeadSource fromString(String value) {
    return LeadSource.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LeadSource.website,
    );
  }

  IconData get icon {
    return switch (this) {
      LeadSource.website => Icons.web,
      LeadSource.referral => Icons.group,
      LeadSource.socialMedia => Icons.thumb_up,
      LeadSource.emailCampaign => Icons.email,
      LeadSource.event => Icons.event,
      LeadSource.coldCall => Icons.phone_callback,
      LeadSource.partner => Icons.handshake,
      LeadSource.existingCustomer => Icons.person,
    };
  }
}

enum LeadType {
  newConnection('new_connection', 'New Connection'),
  serviceUpgrade('service_upgrade', 'Service Upgrade'),
  additionalService('additional_service', 'Additional Service'),
  bulkWater('bulk_water', 'Bulk Water'),
  commercial('commercial', 'Commercial'),
  industrial('industrial', 'Industrial');

  final String value;
  final String displayName;

  const LeadType(this.value, this.displayName);

  String get name => value;

  static LeadType fromString(String value) {
    return LeadType.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LeadType.newConnection,
    );
  }

  IconData get icon {
    return switch (this) {
      LeadType.newConnection => Icons.add_circle,
      LeadType.serviceUpgrade => Icons.upgrade,
      LeadType.additionalService => Icons.add,
      LeadType.bulkWater => Icons.water_drop,
      LeadType.commercial => Icons.business,
      LeadType.industrial => Icons.factory,
    };
  }
}

enum PriorityLevel {
  low('low', 'Low', Colors.green),
  medium('medium', 'Medium', Colors.orange),
  high('high', 'High', Colors.red),
  urgent('urgent', 'Urgent', Colors.purple);

  final String value;
  final String displayName;
  final Color color;

  const PriorityLevel(this.value, this.displayName, this.color);

  String get name => value;

  static PriorityLevel fromString(String value) {
    return PriorityLevel.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PriorityLevel.medium,
    );
  }
}

enum UrgencyLevel {
  low('low', 'Low', Colors.green),
  medium('medium', 'Medium', Colors.orange),
  high('high', 'High', Colors.red),
  urgent('urgent', 'Urgent', Colors.purple);

  final String value;
  final String displayName;
  final Color color;

  const UrgencyLevel(this.value, this.displayName, this.color);

  String get name => value;

  static UrgencyLevel fromString(String value) {
    return UrgencyLevel.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => UrgencyLevel.medium,
    );
  }
}

enum ContactMethod {
  email('email', 'Email', Icons.email),
  phone('phone', 'Phone', Icons.phone),
  sms('sms', 'SMS', Icons.sms),
  inPerson('in_person', 'In Person', Icons.person),
  videoCall('video_call', 'Video Call', Icons.videocam);

  final String value;
  final String displayName;
  final IconData icon;

  const ContactMethod(this.value, this.displayName, this.icon);

  String get name => value;

  static ContactMethod fromString(String value) {
    return ContactMethod.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ContactMethod.email,
    );
  }
}

enum FollowUpOutcome {
  positive('positive', 'Positive', Colors.green),
  neutral('neutral', 'Neutral', Colors.blueGrey),
  negative('negative', 'Negative', Colors.red),
  noResponse('no_response', 'No Response', Colors.orange),
  rescheduled('rescheduled', 'Rescheduled', Colors.blue);

  final String value;
  final String displayName;
  final Color color;

  const FollowUpOutcome(this.value, this.displayName, this.color);

  String get name => value;

  static FollowUpOutcome fromString(String value) {
    return FollowUpOutcome.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FollowUpOutcome.neutral,
    );
  }
}

enum ServiceType {
  residentialWater('residential_water', 'Residential Water', Icons.home),
  commercialWater('commercial_water', 'Commercial Water', Icons.business),
  industrialWater('industrial_water', 'Industrial Water', Icons.factory),
  waterTreatment('water_treatment', 'Water Treatment', Icons.clean_hands),
  bulkWaterSupply('bulk_water_supply', 'Bulk Water Supply', Icons.water),
  waterQualityTesting('water_quality_testing', 'Water Quality Testing', Icons.science),
  equipmentInstallation('equipment_installation', 'Equipment Installation', Icons.build),
  maintenanceService('maintenance_service', 'Maintenance Service', Icons.engineering);

  final String value;
  final String displayName;
  final IconData icon;

  const ServiceType(this.value, this.displayName, this.icon);

  String get name => value;

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ServiceType.residentialWater,
    );
  }
}

enum CompanySize {
  micro('micro', 'Micro (1-9 employees)'),
  small('small', 'Small (10-49 employees)'),
  medium('medium', 'Medium (50-249 employees)'),
  large('large', 'Large (250+ employees)'),
  enterprise('enterprise', 'Enterprise (1000+ employees)');

  final String value;
  final String displayName;

  const CompanySize(this.value, this.displayName);

  String get name => value;

  static CompanySize fromString(String value) {
    return CompanySize.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => CompanySize.small,
    );
  }
}

// Helper functions for safe type conversions
String _safeToString(dynamic value) => value?.toString() ?? '';

double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _safeToBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  if (value is int) return value == 1;
  return false;
}

String _safeParseId(dynamic idField) {
  if (idField == null) return '';
  if (idField is String) return idField;
  if (idField is int) return idField.toString();
  if (idField is Map) {
    final id = idField['_id'] ?? idField['id'];
    return _safeToString(id);
  }
  return idField.toString();
}

DateTime? _safeParseDate(dynamic dateValue) {
  if (dateValue == null) return null;
  try {
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.parse(dateValue);
    if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
    return null;
  } catch (e) {
    return null;
  }
}

// Models
class LeadContactDetails {
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final ContactMethod communicationPreference;

  LeadContactDetails({
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.communicationPreference,
  });

  factory LeadContactDetails.fromJson(Map<String, dynamic> json) {
    return LeadContactDetails(
      salutation: _safeToString(json['salutation']),
      firstName: _safeToString(json['firstName']),
      lastName: _safeToString(json['lastName']),
      email: _safeToString(json['email']),
      phone: _safeToString(json['phone']),
      address: _safeToString(json['address']),
      city: _safeToString(json['city']),
      country: _safeToString(json['country']),
      communicationPreference: ContactMethod.fromString(
          _safeToString(json['communicationPreference'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'communicationPreference': communicationPreference.name,
    };
  }

  String get fullName => '$firstName $lastName';
  String get location => '$city, $country';
}

class CompanyDetails {
  final String companyName;
  final String industry;
  final CompanySize size;
  final double annualRevenue;
  final String website;

  CompanyDetails({
    required this.companyName,
    required this.industry,
    required this.size,
    required this.annualRevenue,
    required this.website,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      companyName: _safeToString(json['companyName']),
      industry: _safeToString(json['industry']),
      size: CompanySize.fromString(_safeToString(json['size'])),
      annualRevenue: _safeToDouble(json['annualRevenue']),
      website: _safeToString(json['website']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'industry': industry,
      'size': size.name,
      'annualRevenue': annualRevenue,
      'website': website,
    };
  }
}

class ServiceRequirement {
  final ServiceType serviceType;
  final String description;
  final UrgencyLevel urgency;
  final List<String> specificNeeds;

  ServiceRequirement({
    required this.serviceType,
    required this.description,
    required this.urgency,
    required this.specificNeeds,
  });

  factory ServiceRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceRequirement(
      serviceType: ServiceType.fromString(_safeToString(json['serviceType'])),
      description: _safeToString(json['description']),
      urgency: UrgencyLevel.fromString(_safeToString(json['urgency'])),
      specificNeeds: (json['specificNeeds'] as List? ?? [])
          .map((item) => _safeToString(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType.name,
      'description': description,
      'urgency': urgency.name,
      'specificNeeds': specificNeeds,
    };
  }
}

class Timeline {
  final String expectedTimeframe;
  final UrgencyLevel urgency;
  final DateTime? specificDate;

  Timeline({
    required this.expectedTimeframe,
    required this.urgency,
    this.specificDate,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      expectedTimeframe: _safeToString(json['expectedTimeframe']),
      urgency: UrgencyLevel.fromString(_safeToString(json['urgency'])),
      specificDate: _safeParseDate(json['specificDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expectedTimeframe': expectedTimeframe,
      'urgency': urgency.name,
      'specificDate': specificDate?.toIso8601String(),
    };
  }
}

class FollowUp {
  final DateTime date;
  final ContactMethod method;
  final String summary;
  final FollowUpOutcome outcome;
  final String nextSteps;
  final DateTime? nextFollowUpDate;

  FollowUp({
    required this.date,
    required this.method,
    required this.summary,
    required this.outcome,
    required this.nextSteps,
    this.nextFollowUpDate,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      date: _safeParseDate(json['date']) ?? DateTime.now(),
      method: ContactMethod.fromString(_safeToString(json['method'])),
      summary: _safeToString(json['summary']),
      outcome: FollowUpOutcome.fromString(_safeToString(json['outcome'])),
      nextSteps: _safeToString(json['nextSteps']),
      nextFollowUpDate: _safeParseDate(json['nextFollowUpDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'method': method.name,
      'summary': summary,
      'outcome': outcome.name,
      'nextSteps': nextSteps,
      'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
    };
  }
}

class QualificationCriteria {
  final bool budgetAvailable;
  final bool decisionMaker;
  final bool timeframe;
  final bool needIdentified;
  final bool authority;

  QualificationCriteria({
    required this.budgetAvailable,
    required this.decisionMaker,
    required this.timeframe,
    required this.needIdentified,
    required this.authority,
  });

  factory QualificationCriteria.fromJson(Map<String, dynamic> json) {
    return QualificationCriteria(
      budgetAvailable: _safeToBool(json['budgetAvailable']),
      decisionMaker: _safeToBool(json['decisionMaker']),
      timeframe: _safeToBool(json['timeframe']),
      needIdentified: _safeToBool(json['needIdentified']),
      authority: _safeToBool(json['authority']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetAvailable': budgetAvailable,
      'decisionMaker': decisionMaker,
      'timeframe': timeframe,
      'needIdentified': needIdentified,
      'authority': authority,
    };
  }

  double get score {
    final total = 5;
    final met = [
      budgetAvailable,
      decisionMaker,
      timeframe,
      needIdentified,
      authority
    ].where((element) => element).length;
    return (met / total) * 100;
  }

  bool get isQualified => score >= 60;
}

class Lead {
  final String id;
  final String leadNumber;
  final LeadSource source;
  final String? campaign;
  final String? referralSource;
  final LeadContactDetails contactDetails;
  final CompanyDetails? companyDetails;
  final LeadType leadType;
  final PriorityLevel priority;
  final LeadStatus status;
  final double estimatedValue;
  final List<ServiceRequirement> serviceRequirements;
  final Timeline timeline;
  final double? budget;
  final String? assignedTo;
  final List<FollowUp> followUpHistory;
  final DateTime? nextFollowUp;
  final double qualificationScore;
  final QualificationCriteria qualificationCriteria;
  final bool isQualified;
  final String? convertedToCustomer;
  final DateTime? conversionDate;
  final double conversionValue;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead({
    required this.id,
    required this.leadNumber,
    required this.source,
    this.campaign,
    this.referralSource,
    required this.contactDetails,
    this.companyDetails,
    required this.leadType,
    required this.priority,
    required this.status,
    required this.estimatedValue,
    required this.serviceRequirements,
    required this.timeline,
    this.budget,
    this.assignedTo,
    required this.followUpHistory,
    this.nextFollowUp,
    required this.qualificationScore,
    required this.qualificationCriteria,
    required this.isQualified,
    this.convertedToCustomer,
    this.conversionDate,
    required this.conversionValue,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: _safeParseId(json['_id'] ?? json['id']),
      leadNumber: _safeToString(json['leadNumber']),
      source: LeadSource.fromString(_safeToString(json['source'])),
      campaign: json['campaign'] != null ? _safeToString(json['campaign']) : null,
      referralSource: json['referralSource'] != null ? _safeToString(json['referralSource']) : null,
      contactDetails: LeadContactDetails.fromJson(json['contactDetails'] ?? {}),
      companyDetails: json['companyDetails'] != null
          ? CompanyDetails.fromJson(json['companyDetails'])
          : null,
      leadType: LeadType.fromString(_safeToString(json['leadType'])),
      priority: PriorityLevel.fromString(_safeToString(json['priority'])),
      status: LeadStatus.fromString(_safeToString(json['status'])),
      estimatedValue: _safeToDouble(json['estimatedValue']),
      serviceRequirements: (json['serviceRequirements'] as List? ?? [])
          .map((item) => ServiceRequirement.fromJson(item ?? {}))
          .toList(),
      timeline: Timeline.fromJson(json['timeline'] ?? {}),
      budget: json['budget'] != null ? _safeToDouble(json['budget']) : null,
      assignedTo: json['assignedTo'] != null ? _safeParseId(json['assignedTo']) : null,
      followUpHistory: (json['followUpHistory'] as List? ?? [])
          .map((item) => FollowUp.fromJson(item ?? {}))
          .toList(),
      nextFollowUp: _safeParseDate(json['nextFollowUp']),
      qualificationScore: _safeToDouble(json['qualificationScore']),
      qualificationCriteria: QualificationCriteria.fromJson(json['qualificationCriteria'] ?? {}),
      isQualified: _safeToBool(json['isQualified']),
      convertedToCustomer: json['convertedToCustomer'] != null
          ? _safeParseId(json['convertedToCustomer'])
          : null,
      conversionDate: _safeParseDate(json['conversionDate']),
      conversionValue: _safeToDouble(json['conversionValue']),
      createdBy: _safeParseId(json['createdBy']),
      createdAt: _safeParseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _safeParseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leadNumber': leadNumber,
      'source': source.name,
      'campaign': campaign,
      'referralSource': referralSource,
      'contactDetails': contactDetails.toJson(),
      'companyDetails': companyDetails?.toJson(),
      'leadType': leadType.name,
      'priority': priority.name,
      'status': status.name,
      'estimatedValue': estimatedValue,
      'serviceRequirements':
      serviceRequirements.map((item) => item.toJson()).toList(),
      'timeline': timeline.toJson(),
      'budget': budget,
      'assignedTo': assignedTo,
      'followUpHistory': followUpHistory.map((item) => item.toJson()).toList(),
      'nextFollowUp': nextFollowUp?.toIso8601String(),
      'qualificationScore': qualificationScore,
      'qualificationCriteria': qualificationCriteria.toJson(),
      'isQualified': isQualified,
      'convertedToCustomer': convertedToCustomer,
      'conversionValue': conversionValue,
    };
  }

  Lead copyWith({
    String? id,
    String? leadNumber,
    LeadSource? source,
    String? campaign,
    String? referralSource,
    LeadContactDetails? contactDetails,
    CompanyDetails? companyDetails,
    LeadType? leadType,
    PriorityLevel? priority,
    LeadStatus? status,
    double? estimatedValue,
    List<ServiceRequirement>? serviceRequirements,
    Timeline? timeline,
    double? budget,
    String? assignedTo,
    List<FollowUp>? followUpHistory,
    DateTime? nextFollowUp,
    double? qualificationScore,
    QualificationCriteria? qualificationCriteria,
    bool? isQualified,
    String? convertedToCustomer,
    DateTime? conversionDate,
    double? conversionValue,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lead(
      id: id ?? this.id,
      leadNumber: leadNumber ?? this.leadNumber,
      source: source ?? this.source,
      campaign: campaign ?? this.campaign,
      referralSource: referralSource ?? this.referralSource,
      contactDetails: contactDetails ?? this.contactDetails,
      companyDetails: companyDetails ?? this.companyDetails,
      leadType: leadType ?? this.leadType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      serviceRequirements: serviceRequirements ?? this.serviceRequirements,
      timeline: timeline ?? this.timeline,
      budget: budget ?? this.budget,
      assignedTo: assignedTo ?? this.assignedTo,
      followUpHistory: followUpHistory ?? this.followUpHistory,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      qualificationScore: qualificationScore ?? this.qualificationScore,
      qualificationCriteria: qualificationCriteria ?? this.qualificationCriteria,
      isQualified: isQualified ?? this.isQualified,
      convertedToCustomer: convertedToCustomer ?? this.convertedToCustomer,
      conversionDate: conversionDate ?? this.conversionDate,
      conversionValue: conversionValue ?? this.conversionValue,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => contactDetails.fullName;
  String get email => contactDetails.email;
  String get phone => contactDetails.phone;
  String get location => contactDetails.location;
}

class LeadStats {
  final int total;
  final int converted;
  final List<Map<String, dynamic>> byStatus;
  final List<Map<String, dynamic>> bySource;
  final List<Map<String, dynamic>> byPriority;

  LeadStats({
    required this.total,
    required this.converted,
    required this.byStatus,
    required this.bySource,
    required this.byPriority,
  });

  factory LeadStats.fromJson(Map<String, dynamic> json) {
    int safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    List<Map<String, dynamic>> safeParseList(List<dynamic>? list) {
      if (list == null) return [];
      return list.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }

    return LeadStats(
      total: safeToInt(json['total']),
      converted: safeToInt(json['converted']),
      byStatus: safeParseList(json['byStatus'] as List?),
      bySource: safeParseList(json['bySource'] as List?),
      byPriority: safeParseList(json['byPriority'] as List?),
    );
  }

  double get conversionRate => total > 0 ? (converted / total) * 100 : 0;
}