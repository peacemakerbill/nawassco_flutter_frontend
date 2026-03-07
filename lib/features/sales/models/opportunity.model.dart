import 'package:flutter/material.dart';

// ============================================
// ENUMS (Must match backend exactly)
// ============================================

enum OpportunityType {
  new_business,
  existing_business,
  upsell,
  cross_sell,
  renewal;

  String get displayName {
    return switch (this) {
      OpportunityType.new_business => 'New Business',
      OpportunityType.existing_business => 'Existing Business',
      OpportunityType.upsell => 'Upsell',
      OpportunityType.cross_sell => 'Cross Sell',
      OpportunityType.renewal => 'Renewal',
    };
  }

  IconData get icon {
    return switch (this) {
      OpportunityType.new_business => Icons.business,
      OpportunityType.existing_business => Icons.business_center,
      OpportunityType.upsell => Icons.trending_up,
      OpportunityType.cross_sell => Icons.compare_arrows,
      OpportunityType.renewal => Icons.autorenew,
    };
  }

  Color get color {
    return switch (this) {
      OpportunityType.new_business => Colors.blue,
      OpportunityType.existing_business => Colors.green,
      OpportunityType.upsell => Colors.orange,
      OpportunityType.cross_sell => Colors.purple,
      OpportunityType.renewal => Colors.teal,
    };
  }
}

enum SalesStage {
  prospecting,
  qualification,
  needs_analysis,
  value_proposition,
  identify_decision_makers,
  perception_analysis,
  proposal_price_quote,
  negotiation_review,
  closed_won,
  closed_lost;

  String get displayName {
    return switch (this) {
      SalesStage.prospecting => 'Prospecting',
      SalesStage.qualification => 'Qualification',
      SalesStage.needs_analysis => 'Needs Analysis',
      SalesStage.value_proposition => 'Value Proposition',
      SalesStage.identify_decision_makers => 'Identify Decision Makers',
      SalesStage.perception_analysis => 'Perception Analysis',
      SalesStage.proposal_price_quote => 'Proposal/Quote',
      SalesStage.negotiation_review => 'Negotiation/Review',
      SalesStage.closed_won => 'Closed Won',
      SalesStage.closed_lost => 'Closed Lost',
    };
  }

  Color get color {
    return switch (this) {
      SalesStage.prospecting => Colors.blueGrey,
      SalesStage.qualification => Colors.blue,
      SalesStage.needs_analysis => Colors.lightBlue,
      SalesStage.value_proposition => Colors.cyan,
      SalesStage.identify_decision_makers => Colors.indigo,
      SalesStage.perception_analysis => Colors.deepPurple,
      SalesStage.proposal_price_quote => Colors.purple,
      SalesStage.negotiation_review => Colors.orange,
      SalesStage.closed_won => Colors.green,
      SalesStage.closed_lost => Colors.red,
    };
  }

  IconData get icon {
    return switch (this) {
      SalesStage.prospecting => Icons.search,
      SalesStage.qualification => Icons.star,
      SalesStage.needs_analysis => Icons.analytics,
      SalesStage.value_proposition => Icons.show_chart,
      SalesStage.identify_decision_makers => Icons.group,
      SalesStage.perception_analysis => Icons.psychology,
      SalesStage.proposal_price_quote => Icons.description,
      SalesStage.negotiation_review => Icons.handshake,
      SalesStage.closed_won => Icons.check_circle,
      SalesStage.closed_lost => Icons.cancel,
    };
  }

  bool get isClosed =>
      this == SalesStage.closed_won || this == SalesStage.closed_lost;

  bool get isWon => this == SalesStage.closed_won;

  bool get isLost => this == SalesStage.closed_lost;
}

enum InfluenceLevel {
  decision_maker,
  influencer,
  recommender,
  gatekeeper,
  end_user;

  String get displayName {
    return switch (this) {
      InfluenceLevel.decision_maker => 'Decision Maker',
      InfluenceLevel.influencer => 'Influencer',
      InfluenceLevel.recommender => 'Recommender',
      InfluenceLevel.gatekeeper => 'Gatekeeper',
      InfluenceLevel.end_user => 'End User',
    };
  }

  Color get color {
    return switch (this) {
      InfluenceLevel.decision_maker => Colors.green,
      InfluenceLevel.influencer => Colors.blue,
      InfluenceLevel.recommender => Colors.orange,
      InfluenceLevel.gatekeeper => Colors.red,
      InfluenceLevel.end_user => Colors.grey,
    };
  }

  IconData get icon {
    return switch (this) {
      InfluenceLevel.decision_maker => Icons.gavel,
      InfluenceLevel.influencer => Icons.star,
      InfluenceLevel.recommender => Icons.thumb_up,
      InfluenceLevel.gatekeeper => Icons.block,
      InfluenceLevel.end_user => Icons.person,
    };
  }

  static InfluenceLevel fromString(String value) {
    return InfluenceLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InfluenceLevel.influencer,
    );
  }
}

enum Attitude {
  champion,
  supporter,
  neutral,
  blocker,
  unknown;

  String get displayName {
    return switch (this) {
      Attitude.champion => 'Champion',
      Attitude.supporter => 'Supporter',
      Attitude.neutral => 'Neutral',
      Attitude.blocker => 'Blocker',
      Attitude.unknown => 'Unknown',
    };
  }

  Color get color {
    return switch (this) {
      Attitude.champion => Colors.green,
      Attitude.supporter => Colors.lightGreen,
      Attitude.neutral => Colors.grey,
      Attitude.blocker => Colors.red,
      Attitude.unknown => Colors.blueGrey,
    };
  }

  IconData get icon {
    return switch (this) {
      Attitude.champion => Icons.emoji_events,
      Attitude.supporter => Icons.thumb_up,
      Attitude.neutral => Icons.remove_circle,
      Attitude.blocker => Icons.block,
      Attitude.unknown => Icons.help,
    };
  }

  static Attitude fromString(String value) {
    return Attitude.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Attitude.unknown,
    );
  }
}

enum ServiceType {
  residential_water,
  commercial_water,
  industrial_water,
  water_treatment,
  bulk_water_supply,
  water_quality_testing,
  equipment_installation,
  maintenance_service,
  infrastructure_development,
  consultation_service;

  String get displayName {
    return switch (this) {
      ServiceType.residential_water => 'Residential Water',
      ServiceType.commercial_water => 'Commercial Water',
      ServiceType.industrial_water => 'Industrial Water',
      ServiceType.water_treatment => 'Water Treatment',
      ServiceType.bulk_water_supply => 'Bulk Water Supply',
      ServiceType.water_quality_testing => 'Water Quality Testing',
      ServiceType.equipment_installation => 'Equipment Installation',
      ServiceType.maintenance_service => 'Maintenance Service',
      ServiceType.infrastructure_development => 'Infrastructure Development',
      ServiceType.consultation_service => 'Consultation Service',
    };
  }

  IconData get icon {
    return switch (this) {
      ServiceType.residential_water => Icons.home,
      ServiceType.commercial_water => Icons.business,
      ServiceType.industrial_water => Icons.factory,
      ServiceType.water_treatment => Icons.clean_hands,
      ServiceType.bulk_water_supply => Icons.water,
      ServiceType.water_quality_testing => Icons.science,
      ServiceType.equipment_installation => Icons.build,
      ServiceType.maintenance_service => Icons.engineering,
      ServiceType.infrastructure_development => Icons.construction,
      ServiceType.consultation_service => Icons.school,
    };
  }

  Color get color {
    return switch (this) {
      ServiceType.residential_water => Colors.blue,
      ServiceType.commercial_water => Colors.green,
      ServiceType.industrial_water => Colors.orange,
      ServiceType.water_treatment => Colors.teal,
      ServiceType.bulk_water_supply => Colors.cyan,
      ServiceType.water_quality_testing => Colors.purple,
      ServiceType.equipment_installation => Colors.red,
      ServiceType.maintenance_service => Colors.brown,
      ServiceType.infrastructure_development => Colors.indigo,
      ServiceType.consultation_service => Colors.pink,
    };
  }

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServiceType.residential_water,
    );
  }
}

// ============================================
// SUB-MODELS (Matching backend)
// ============================================

@immutable
class Competitor {
  final String? name;
  final String? strength;
  final String? weakness;
  final String? ourAdvantage;

  const Competitor({
    this.name,
    this.strength,
    this.weakness,
    this.ourAdvantage,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) => Competitor(
        name: json['name'] as String?,
        strength: json['strength'] as String?,
        weakness: json['weakness'] as String?,
        ourAdvantage: json['ourAdvantage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        if (strength != null && strength!.isNotEmpty) 'strength': strength,
        if (weakness != null && weakness!.isNotEmpty) 'weakness': weakness,
        if (ourAdvantage != null && ourAdvantage!.isNotEmpty)
          'ourAdvantage': ourAdvantage,
      };

  Competitor copyWith({
    String? name,
    String? strength,
    String? weakness,
    String? ourAdvantage,
  }) {
    return Competitor(
      name: name ?? this.name,
      strength: strength ?? this.strength,
      weakness: weakness ?? this.weakness,
      ourAdvantage: ourAdvantage ?? this.ourAdvantage,
    );
  }
}

@immutable
class ProposedService {
  final ServiceType serviceType;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String specifications;

  const ProposedService({
    required this.serviceType,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.specifications,
  });

  factory ProposedService.fromJson(Map<String, dynamic> json) =>
      ProposedService(
        serviceType: ServiceType.values.firstWhere(
          (e) => e.name == json['serviceType'],
          orElse: () => ServiceType.residential_water,
        ),
        description: json['description'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        specifications: json['specifications'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'serviceType': serviceType.name,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'specifications': specifications,
      };

  ProposedService copyWith({
    ServiceType? serviceType,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? specifications,
  }) {
    return ProposedService(
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      specifications: specifications ?? this.specifications,
    );
  }
}

@immutable
class DecisionMaker {
  final String? name;
  final String? title;
  final InfluenceLevel influence;
  final Attitude attitude;
  final String? contactInfo;

  const DecisionMaker({
    this.name,
    this.title,
    required this.influence,
    required this.attitude,
    this.contactInfo,
  });

  factory DecisionMaker.fromJson(Map<String, dynamic> json) => DecisionMaker(
        name: json['name'] as String?,
        title: json['title'] as String?,
        influence: InfluenceLevel.fromString(
            json['influence'] as String? ?? 'influencer'),
        attitude: Attitude.fromString(json['attitude'] as String? ?? 'unknown'),
        contactInfo: json['contactInfo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        if (title != null && title!.isNotEmpty) 'title': title,
        'influence': influence.name,
        'attitude': attitude.name,
        if (contactInfo != null && contactInfo!.isNotEmpty)
          'contactInfo': contactInfo,
      };

  DecisionMaker copyWith({
    String? name,
    String? title,
    InfluenceLevel? influence,
    Attitude? attitude,
    String? contactInfo,
  }) {
    return DecisionMaker(
      name: name ?? this.name,
      title: title ?? this.title,
      influence: influence ?? this.influence,
      attitude: attitude ?? this.attitude,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

@immutable
class DecisionProcess {
  final String? process;
  final String? timeline;
  final DateTime? decisionDate;
  final bool approvalRequired;
  final int approvalLevels;

  const DecisionProcess({
    this.process,
    this.timeline,
    this.decisionDate,
    this.approvalRequired = false,
    this.approvalLevels = 1,
  });

  factory DecisionProcess.fromJson(Map<String, dynamic> json) =>
      DecisionProcess(
        process: json['process'] as String?,
        timeline: json['timeline'] as String?,
        decisionDate: json['decisionDate'] != null
            ? DateTime.parse(json['decisionDate'] as String)
            : null,
        approvalRequired: json['approvalRequired'] as bool? ?? false,
        approvalLevels: (json['approvalLevels'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        if (process != null && process!.isNotEmpty) 'process': process,
        if (timeline != null && timeline!.isNotEmpty) 'timeline': timeline,
        if (decisionDate != null)
          'decisionDate': decisionDate!.toIso8601String(),
        'approvalRequired': approvalRequired,
        'approvalLevels': approvalLevels,
      };

  DecisionProcess copyWith({
    String? process,
    String? timeline,
    DateTime? decisionDate,
    bool? approvalRequired,
    int? approvalLevels,
  }) {
    return DecisionProcess(
      process: process ?? this.process,
      timeline: timeline ?? this.timeline,
      decisionDate: decisionDate ?? this.decisionDate,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      approvalLevels: approvalLevels ?? this.approvalLevels,
    );
  }
}

// ============================================
// MAIN OPPORTUNITY MODEL
// ============================================

@immutable
class Opportunity {
  final String id;
  final String opportunityNumber;

  // Relationships (can be IDs or populated objects)
  final String? leadId;
  final dynamic lead;
  final String? leadNumber;
  final String? customerId;
  final dynamic customer;
  final String? customerName;
  final String? customerEmail;

  // Opportunity Details
  final OpportunityType opportunityType;
  final String description;
  final double estimatedValue;
  final int probability;
  final double expectedRevenue;

  // Sales Process
  final SalesStage salesStage;
  final String nextStep;
  final DateTime? nextStepDate;
  final DateTime? closeDate;

  // Competition
  final List<Competitor> competitors;
  final String? competitiveAdvantage;

  // Products & Services
  final List<ProposedService> proposedServices;
  final List<String> customRequirements;

  // Decision Making
  final List<DecisionMaker> decisionMakers;
  final DecisionProcess decisionProcess;
  final List<String> keyFactors;

  // Quotes & Proposals
  final List<String>? quoteNumbers;
  final String? finalProposal;
  final String? proposalNumber;

  // Win/Loss Analysis
  final String? winLossReason;
  final List<String> lessonsLearned;

  // Metadata
  final String assignedToId;
  final dynamic assignedTo;
  final String assignedToName;
  final String createdById;
  final String createdByName;
  final String createdByEmail;
  final String? updatedById;
  final String? updatedByName;
  final String? updatedByEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Opportunity({
    required this.id,
    required this.opportunityNumber,
    this.leadId,
    this.lead,
    this.leadNumber,
    this.customerId,
    this.customer,
    this.customerName,
    this.customerEmail,
    required this.opportunityType,
    required this.description,
    required this.estimatedValue,
    required this.probability,
    required this.expectedRevenue,
    required this.salesStage,
    required this.nextStep,
    this.nextStepDate,
    this.closeDate,
    this.competitors = const [],
    this.competitiveAdvantage,
    this.proposedServices = const [],
    this.customRequirements = const [],
    this.decisionMakers = const [],
    required this.decisionProcess,
    this.keyFactors = const [],
    this.quoteNumbers,
    this.finalProposal,
    this.proposalNumber,
    this.winLossReason,
    this.lessonsLearned = const [],
    required this.assignedToId,
    this.assignedTo,
    required this.assignedToName,
    required this.createdById,
    required this.createdByName,
    required this.createdByEmail,
    this.updatedById,
    this.updatedByName,
    this.updatedByEmail,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Helper methods for UI
  String get displayName => 'Opportunity $opportunityNumber';

  String get valueFormatted => 'KES ${estimatedValue.toStringAsFixed(2)}';

  String get revenueFormatted => 'KES ${expectedRevenue.toStringAsFixed(2)}';

  bool get isClosed => salesStage.isClosed;

  bool get isWon => salesStage.isWon;

  bool get isLost => salesStage.isLost;

  int get daysInPipeline {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inDays;
  }

  String get pipelineAge => '$daysInPipeline days';

  Color get probabilityColor {
    if (probability >= 80) return Colors.green;
    if (probability >= 50) return Colors.orange;
    return Colors.red;
  }

  String get probabilityText => '$probability%';

  String get leadDisplayName {
    if (lead is Map<String, dynamic>) {
      final contact = lead!['contactDetails'] ?? {};
      final firstName = contact['firstName'] ?? '';
      final lastName = contact['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return leadNumber ?? leadId ?? 'Unknown Lead';
  }

  String get customerDisplayName {
    if (customerName != null && customerName!.isNotEmpty) return customerName!;
    if (customer is Map<String, dynamic>) {
      if (customer!['companyName'] != null) {
        return customer!['companyName'] as String;
      }
      final firstName = customer!['firstName'] ?? '';
      final lastName = customer!['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return customerId ?? 'No Customer';
  }

  double get totalServicesValue {
    return proposedServices.fold(
        0.0, (sum, service) => sum + service.totalPrice);
  }

  // Factory constructor from JSON
  factory Opportunity.fromJson(Map<String, dynamic> json) {
    try {
      // Helper to parse IDs from either string or object
      String parseId(dynamic field) {
        if (field == null) return '';
        if (field is String) return field;
        if (field is Map) return field['_id']?.toString() ?? '';
        return field.toString();
      }

      // Helper to parse name from object
      String parseName(dynamic field) {
        if (field == null) return '';
        if (field is String) return field;
        if (field is Map) {
          return field['name']?.toString() ??
              field['firstName']?.toString() ??
              field['fullName']?.toString() ??
              field['email']?.toString() ??
              '';
        }
        return '';
      }

      // Parse date safely
      DateTime? parseDate(dynamic date) {
        if (date == null) return null;
        if (date is DateTime) return date;
        if (date is String) {
          try {
            return DateTime.parse(date);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      return Opportunity(
        id: json['_id']?.toString() ?? '',
        opportunityNumber: json['opportunityNumber'] as String? ?? '',
        leadId: parseId(json['lead']),
        lead: json['lead'],
        leadNumber: json['leadNumber'] as String?,
        customerId: parseId(json['customer']),
        customer: json['customer'],
        customerName: json['customerName'] as String?,
        customerEmail: json['customerEmail'] as String?,
        opportunityType: OpportunityType.values.firstWhere(
          (e) => e.name == json['opportunityType'],
          orElse: () => OpportunityType.new_business,
        ),
        description: json['description'] as String? ?? '',
        estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 0.0,
        probability: (json['probability'] as num?)?.toInt() ?? 0,
        expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble() ?? 0.0,
        salesStage: SalesStage.values.firstWhere(
          (e) => e.name == json['salesStage'],
          orElse: () => SalesStage.prospecting,
        ),
        nextStep: json['nextStep'] as String? ?? '',
        nextStepDate: parseDate(json['nextStepDate']),
        closeDate: parseDate(json['closeDate']),
        competitors: (json['competitors'] as List<dynamic>?)
                ?.map((c) => Competitor.fromJson(c as Map<String, dynamic>))
                .toList() ??
            const [],
        competitiveAdvantage: json['competitiveAdvantage'] as String?,
        proposedServices: (json['proposedServices'] as List<dynamic>?)
                ?.map(
                    (s) => ProposedService.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
        customRequirements: List<String>.from(json['customRequirements'] ?? []),
        decisionMakers: (json['decisionMakers'] as List<dynamic>?)
                ?.map(
                    (dm) => DecisionMaker.fromJson(dm as Map<String, dynamic>))
                .toList() ??
            const [],
        decisionProcess:
            DecisionProcess.fromJson(json['decisionProcess'] ?? {}),
        keyFactors: List<String>.from(json['keyFactors'] ?? []),
        quoteNumbers: json['quoteNumbers'] != null
            ? List<String>.from(json['quoteNumbers'])
            : null,
        finalProposal: json['finalProposal'] as String?,
        proposalNumber: json['proposalNumber'] as String?,
        winLossReason: json['winLossReason'] as String?,
        lessonsLearned: List<String>.from(json['lessonsLearned'] ?? []),
        assignedToId: parseId(json['assignedTo']),
        assignedTo: json['assignedTo'],
        assignedToName: json['assignedToName'] as String? ??
            parseName(json['assignedTo']) ??
            json['assignedTo']?['personalDetails']?['firstName']?.toString() ??
            '',
        createdById: parseId(json['createdBy']),
        createdByName: json['createdByName'] as String? ??
            parseName(json['createdBy']) ??
            json['createdBy']?['firstName']?.toString() ??
            '',
        createdByEmail: json['createdByEmail'] as String? ??
            json['createdBy']?['email']?.toString() ??
            '',
        updatedById: parseId(json['updatedBy']),
        updatedByName: json['updatedByName'] as String?,
        updatedByEmail: json['updatedByEmail'] as String?,
        createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseDate(json['updatedAt']) ?? DateTime.now(),
        isActive: json['isActive'] as bool? ?? true,
      );
    } catch (e, stack) {
      print('Error parsing Opportunity: $e');
      print('Stack: $stack');
      print('JSON: $json');
      rethrow;
    }
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'opportunityNumber': opportunityNumber,
      if (leadId != null && leadId!.isNotEmpty) 'lead': leadId,
      if (leadNumber != null) 'leadNumber': leadNumber,
      if (customerId != null && customerId!.isNotEmpty) 'customer': customerId,
      if (customerName != null) 'customerName': customerName,
      if (customerEmail != null) 'customerEmail': customerEmail,
      'opportunityType': opportunityType.name,
      'description': description,
      'estimatedValue': estimatedValue,
      'probability': probability,
      'expectedRevenue': expectedRevenue,
      'salesStage': salesStage.name,
      'nextStep': nextStep,
      if (nextStepDate != null) 'nextStepDate': nextStepDate!.toIso8601String(),
      if (closeDate != null) 'closeDate': closeDate!.toIso8601String(),
      'competitors': competitors.map((c) => c.toJson()).toList(),
      if (competitiveAdvantage != null && competitiveAdvantage!.isNotEmpty)
        'competitiveAdvantage': competitiveAdvantage,
      'proposedServices': proposedServices.map((s) => s.toJson()).toList(),
      'customRequirements': customRequirements,
      'decisionMakers': decisionMakers.map((dm) => dm.toJson()).toList(),
      'decisionProcess': decisionProcess.toJson(),
      'keyFactors': keyFactors,
      if (quoteNumbers != null) 'quoteNumbers': quoteNumbers,
      if (finalProposal != null && finalProposal!.isNotEmpty)
        'finalProposal': finalProposal,
      if (proposalNumber != null) 'proposalNumber': proposalNumber,
      if (winLossReason != null && winLossReason!.isNotEmpty)
        'winLossReason': winLossReason,
      'lessonsLearned': lessonsLearned,
      'assignedTo': assignedToId,
      'assignedToName': assignedToName,
      'createdBy': createdById,
      'createdByName': createdByName,
      'createdByEmail': createdByEmail,
      if (updatedById != null) 'updatedBy': updatedById,
      if (updatedByName != null) 'updatedByName': updatedByName,
      if (updatedByEmail != null) 'updatedByEmail': updatedByEmail,
    };

    return json;
  }

  Opportunity copyWith({
    String? id,
    String? opportunityNumber,
    String? leadId,
    dynamic lead,
    String? leadNumber,
    String? customerId,
    dynamic customer,
    String? customerName,
    String? customerEmail,
    OpportunityType? opportunityType,
    String? description,
    double? estimatedValue,
    int? probability,
    double? expectedRevenue,
    SalesStage? salesStage,
    String? nextStep,
    DateTime? nextStepDate,
    DateTime? closeDate,
    List<Competitor>? competitors,
    String? competitiveAdvantage,
    List<ProposedService>? proposedServices,
    List<String>? customRequirements,
    List<DecisionMaker>? decisionMakers,
    DecisionProcess? decisionProcess,
    List<String>? keyFactors,
    List<String>? quoteNumbers,
    String? finalProposal,
    String? proposalNumber,
    String? winLossReason,
    List<String>? lessonsLearned,
    String? assignedToId,
    dynamic assignedTo,
    String? assignedToName,
    String? createdById,
    String? createdByName,
    String? createdByEmail,
    String? updatedById,
    String? updatedByName,
    String? updatedByEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Opportunity(
      id: id ?? this.id,
      opportunityNumber: opportunityNumber ?? this.opportunityNumber,
      leadId: leadId ?? this.leadId,
      lead: lead ?? this.lead,
      leadNumber: leadNumber ?? this.leadNumber,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      opportunityType: opportunityType ?? this.opportunityType,
      description: description ?? this.description,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      probability: probability ?? this.probability,
      expectedRevenue: expectedRevenue ?? this.expectedRevenue,
      salesStage: salesStage ?? this.salesStage,
      nextStep: nextStep ?? this.nextStep,
      nextStepDate: nextStepDate ?? this.nextStepDate,
      closeDate: closeDate ?? this.closeDate,
      competitors: competitors ?? this.competitors,
      competitiveAdvantage: competitiveAdvantage ?? this.competitiveAdvantage,
      proposedServices: proposedServices ?? this.proposedServices,
      customRequirements: customRequirements ?? this.customRequirements,
      decisionMakers: decisionMakers ?? this.decisionMakers,
      decisionProcess: decisionProcess ?? this.decisionProcess,
      keyFactors: keyFactors ?? this.keyFactors,
      quoteNumbers: quoteNumbers ?? this.quoteNumbers,
      finalProposal: finalProposal ?? this.finalProposal,
      proposalNumber: proposalNumber ?? this.proposalNumber,
      winLossReason: winLossReason ?? this.winLossReason,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      updatedById: updatedById ?? this.updatedById,
      updatedByName: updatedByName ?? this.updatedByName,
      updatedByEmail: updatedByEmail ?? this.updatedByEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Opportunity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          opportunityNumber == other.opportunityNumber;

  @override
  int get hashCode => id.hashCode ^ opportunityNumber.hashCode;
}

// ============================================
// FILTERS AND STATS
// ============================================

class OpportunityFilters {
  final SalesStage? stage;
  final OpportunityType? type;
  final String? assignedTo;
  final int? probabilityMin;
  final int? probabilityMax;
  final String? search;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const OpportunityFilters({
    this.stage,
    this.type,
    this.assignedTo,
    this.probabilityMin,
    this.probabilityMax,
    this.search,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (stage != null) params['stage'] = stage!.name;
    if (type != null) params['type'] = type!.name;
    if (assignedTo != null) params['assignedTo'] = assignedTo;
    if (probabilityMin != null) params['probabilityMin'] = probabilityMin;
    if (probabilityMax != null) params['probabilityMax'] = probabilityMax;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (dateFrom != null) params['dateFrom'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo!.toIso8601String();
    return params;
  }

  OpportunityFilters copyWith({
    SalesStage? stage,
    OpportunityType? type,
    String? assignedTo,
    int? probabilityMin,
    int? probabilityMax,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return OpportunityFilters(
      stage: stage ?? this.stage,
      type: type ?? this.type,
      assignedTo: assignedTo ?? this.assignedTo,
      probabilityMin: probabilityMin ?? this.probabilityMin,
      probabilityMax: probabilityMax ?? this.probabilityMax,
      search: search ?? this.search,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  bool get hasFilters =>
      stage != null ||
      type != null ||
      assignedTo != null ||
      probabilityMin != null ||
      probabilityMax != null ||
      (search != null && search!.isNotEmpty) ||
      dateFrom != null ||
      dateTo != null;
}

class OpportunityStats {
  final int total;
  final double totalValue;
  final double expectedRevenue;
  final List<StageStat> byStage;
  final double winRate;

  const OpportunityStats({
    required this.total,
    required this.totalValue,
    required this.expectedRevenue,
    required this.byStage,
    required this.winRate,
  });

  factory OpportunityStats.fromJson(Map<String, dynamic> json) {
    final byStageList = (json['byStage'] as List?) ?? [];
    final byStage = byStageList.map((item) {
      final data = item as Map<String, dynamic>;
      return StageStat(
        stage: SalesStage.values.firstWhere(
          (e) => e.name == data['stage'],
          orElse: () => SalesStage.prospecting,
        ),
        count: (data['count'] as num?)?.toInt() ?? 0,
        value: (data['value'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return OpportunityStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble() ?? 0.0,
      byStage: byStage,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get totalValueFormatted => 'KES ${totalValue.toStringAsFixed(2)}';

  String get expectedRevenueFormatted =>
      'KES ${expectedRevenue.toStringAsFixed(2)}';

  String get winRateFormatted => '${winRate.toStringAsFixed(1)}%';
}

class StageStat {
  final SalesStage stage;
  final int count;
  final double value;

  const StageStat({
    required this.stage,
    required this.count,
    required this.value,
  });

  String get valueFormatted => 'KES ${value.toStringAsFixed(2)}';
}
