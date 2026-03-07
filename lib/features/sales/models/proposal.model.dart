import 'package:flutter/foundation.dart';

// ============================================
// ENUMS (Matching Backend)
// ============================================

enum ProposalStatus {
  draft('Draft'),
  submitted('Submitted'),
  under_review('Under Review'),
  revised('Revised'),
  negotiation('Negotiation'),
  accepted('Accepted'),
  rejected('Rejected'),
  expired('Expired'),
  signed('Signed'),
  converted_to_contract('Converted to Contract');

  final String displayName;
  const ProposalStatus(this.displayName);
}

enum PricingModel {
  fixed_price('Fixed Price'),
  time_and_materials('Time & Materials'),
  hybrid('Hybrid'),
  retainer('Retainer'),
  recurring('Recurring'),
  performance_based('Performance Based');

  final String displayName;
  const PricingModel(this.displayName);
}

enum ItemCategory {
  labor('Labor'),
  materials('Materials'),
  equipment('Equipment'),
  software('Software'),
  licenses('Licenses'),
  travel('Travel'),
  training('Training'),
  support('Support'),
  maintenance('Maintenance'),
  other('Other');

  final String displayName;
  const ItemCategory(this.displayName);
}

enum MilestoneStatus {
  pending('Pending'),
  completed('Completed'),
  approved('Approved'),
  paid('Paid'),
  overdue('Overdue');

  final String displayName;
  const MilestoneStatus(this.displayName);
}

enum ReviewStatus {
  pending('Pending'),
  in_progress('In Progress'),
  completed('Completed');

  final String displayName;
  const ReviewStatus(this.displayName);
}

enum ApprovalStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  requires_revision('Requires Revision');

  final String displayName;
  const ApprovalStatus(this.displayName);
}

// ============================================
// SUB-MODELS
// ============================================

@immutable
class TimelinePhase {
  final int? phaseNumber;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? duration;
  final List<String>? deliverables;
  final List<int>? dependencies;

  const TimelinePhase({
    this.phaseNumber,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.duration,
    this.deliverables,
    this.dependencies,
  });

  Map<String, dynamic> toJson() => {
    if (phaseNumber != null) 'phaseNumber': phaseNumber,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (startDate != null) 'startDate': startDate!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
    if (duration != null) 'duration': duration,
    if (deliverables != null) 'deliverables': deliverables,
    if (dependencies != null) 'dependencies': dependencies,
  };

  factory TimelinePhase.fromJson(Map<String, dynamic> json) => TimelinePhase(
    phaseNumber: json['phaseNumber'] as int?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
    duration: json['duration'] as int?,
    deliverables: (json['deliverables'] as List<dynamic>?)?.cast<String>(),
    dependencies: (json['dependencies'] as List<dynamic>?)?.cast<int>(),
  );
}

@immutable
class ProposalTimeline {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TimelinePhase>? phases;
  final int? totalDuration;

  const ProposalTimeline({
    this.startDate,
    this.endDate,
    this.phases,
    this.totalDuration,
  });

  Map<String, dynamic> toJson() => {
    if (startDate != null) 'startDate': startDate!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
    if (phases != null) 'phases': phases!.map((p) => p.toJson()).toList(),
    if (totalDuration != null) 'totalDuration': totalDuration,
  };

  factory ProposalTimeline.fromJson(Map<String, dynamic> json) => ProposalTimeline(
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
    phases: (json['phases'] as List<dynamic>?)
        ?.map((p) => TimelinePhase.fromJson(p as Map<String, dynamic>))
        .toList(),
    totalDuration: json['totalDuration'] as int?,
  );
}

@immutable
class ProposalResource {
  final String? role;
  final String? name;
  final String? experience;
  final double? hoursAllocated;
  final double? ratePerHour;
  final double? totalCost;
  final List<String>? responsibilities;

  const ProposalResource({
    this.role,
    this.name,
    this.experience,
    this.hoursAllocated,
    this.ratePerHour,
    this.totalCost,
    this.responsibilities,
  });

  Map<String, dynamic> toJson() => {
    if (role != null) 'role': role,
    if (name != null) 'name': name,
    if (experience != null) 'experience': experience,
    if (hoursAllocated != null) 'hoursAllocated': hoursAllocated,
    if (ratePerHour != null) 'ratePerHour': ratePerHour,
    if (totalCost != null) 'totalCost': totalCost,
    if (responsibilities != null) 'responsibilities': responsibilities,
  };

  factory ProposalResource.fromJson(Map<String, dynamic> json) => ProposalResource(
    role: json['role'] as String?,
    name: json['name'] as String?,
    experience: json['experience'] as String?,
    hoursAllocated: json['hoursAllocated'] != null ? (json['hoursAllocated'] as num).toDouble() : null,
    ratePerHour: json['ratePerHour'] != null ? (json['ratePerHour'] as num).toDouble() : null,
    totalCost: json['totalCost'] != null ? (json['totalCost'] as num).toDouble() : null,
    responsibilities: (json['responsibilities'] as List<dynamic>?)?.cast<String>(),
  );
}

@immutable
class ProposalItem {
  final String? itemCode;
  final ItemCategory? category;
  final String? description;
  final double? quantity;
  final String? unit;
  final double? unitPrice;
  final double? totalPrice;
  final double? taxRate;
  final double? taxAmount;
  final double? discount;
  final String? notes;

  const ProposalItem({
    this.itemCode,
    this.category,
    this.description,
    this.quantity = 1,
    this.unit = 'pcs',
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.discount = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (itemCode != null) 'itemCode': itemCode,
    if (category != null) 'category': category!.name,
    if (description != null) 'description': description,
    'quantity': quantity,
    'unit': unit,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'taxRate': taxRate,
    'taxAmount': taxAmount,
    'discount': discount,
    if (notes != null) 'notes': notes,
  };

  factory ProposalItem.fromJson(Map<String, dynamic> json) => ProposalItem(
    itemCode: json['itemCode'] as String?,
    category: json['category'] != null
        ? ItemCategory.values.firstWhere(
          (e) => e.name == json['category'],
      orElse: () => ItemCategory.other,
    )
        : null,
    description: json['description'] as String?,
    quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : 1,
    unit: json['unit'] as String? ?? 'pcs',
    unitPrice: json['unitPrice'] != null ? (json['unitPrice'] as num).toDouble() : 0,
    totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : 0,
    taxRate: json['taxRate'] != null ? (json['taxRate'] as num).toDouble() : 0,
    taxAmount: json['taxAmount'] != null ? (json['taxAmount'] as num).toDouble() : 0,
    discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0,
    notes: json['notes'] as String?,
  );

  ProposalItem copyWith({
    String? itemCode,
    ItemCategory? category,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    double? taxRate,
    double? taxAmount,
    double? discount,
    String? notes,
  }) {
    return ProposalItem(
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
    );
  }
}

@immutable
class PaymentMilestone {
  final int? milestoneNumber;
  final String? name;
  final String? description;
  final double? amount;
  final double? percentage;
  final DateTime? dueDate;
  final String? triggerCondition;
  final MilestoneStatus? status;

  const PaymentMilestone({
    this.milestoneNumber,
    this.name,
    this.description,
    this.amount,
    this.percentage,
    this.dueDate,
    this.triggerCondition,
    this.status = MilestoneStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    if (milestoneNumber != null) 'milestoneNumber': milestoneNumber,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (amount != null) 'amount': amount,
    if (percentage != null) 'percentage': percentage,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (triggerCondition != null) 'triggerCondition': triggerCondition,
    if (status != null) 'status': status!.name,
  };

  factory PaymentMilestone.fromJson(Map<String, dynamic> json) => PaymentMilestone(
    milestoneNumber: json['milestoneNumber'] as int?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() : null,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    triggerCondition: json['triggerCondition'] as String?,
    status: json['status'] != null
        ? MilestoneStatus.values.firstWhere(
          (e) => e.name == json['status'],
      orElse: () => MilestoneStatus.pending,
    )
        : MilestoneStatus.pending,
  );
}

// ============================================
// MAIN PROPOSAL MODEL
// ============================================

@immutable
class Proposal {
  final String id;
  final String proposalNumber;
  final String? opportunity;
  final String? quote;
  final String customer;
  final DateTime proposalDate;
  final DateTime? validityDate;
  final ProposalStatus status;
  final int version;

  // Executive Summary
  final String executiveSummary;
  final List<String>? objectives;
  final String scopeOfWork;
  final List<String>? deliverables;

  // Technical Solution
  final String technicalApproach;
  final String methodology;
  final ProposalTimeline? timeline;
  final List<ProposalResource>? resources;
  final List<String>? assumptions;
  final List<String>? constraints;

  // Pricing
  final PricingModel pricingModel;
  final List<ProposalItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final List<PaymentMilestone>? paymentSchedule;
  final String? currency;

  // Terms & Conditions
  final List<String>? termsAndConditions;

  // Review & Approval
  final ReviewStatus reviewStatus;
  final ApprovalStatus approvalStatus;
  final String? reviewedBy;
  final DateTime? reviewDate;
  final String? approvedBy;
  final DateTime? approvalDate;

  // Signature
  final String? signedByCustomer;
  final String? signedByCompany;
  final DateTime? signatureDate;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;

  // Metadata
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated data (for display)
  final String? customerName;
  final String? opportunityName;
  final String? quoteNumber;

  const Proposal({
    required this.id,
    required this.proposalNumber,
    this.opportunity,
    this.quote,
    required this.customer,
    required this.proposalDate,
    this.validityDate,
    required this.status,
    this.version = 1,
    required this.executiveSummary,
    this.objectives,
    required this.scopeOfWork,
    this.deliverables,
    required this.technicalApproach,
    required this.methodology,
    this.timeline,
    this.resources,
    this.assumptions,
    this.constraints,
    required this.pricingModel,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.paymentSchedule,
    this.currency = 'KES',
    this.termsAndConditions,
    required this.reviewStatus,
    required this.approvalStatus,
    this.reviewedBy,
    this.reviewDate,
    this.approvedBy,
    this.approvalDate,
    this.signedByCustomer,
    this.signedByCompany,
    this.signatureDate,
    this.contractStartDate,
    this.contractEndDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.opportunityName,
    this.quoteNumber,
  });

  String get formattedTotal => 'KES ${totalAmount.toStringAsFixed(2)}';

  bool get isDraft => status == ProposalStatus.draft;
  bool get isSubmitted => status == ProposalStatus.submitted;
  bool get isUnderReview => status == ProposalStatus.under_review;
  bool get isSigned => status == ProposalStatus.signed;
  bool get isExpired => status == ProposalStatus.expired;

  bool get canEdit {
    // Allow editing in all statuses
    return [
      ProposalStatus.draft,
      ProposalStatus.submitted,
      ProposalStatus.under_review,
      ProposalStatus.revised,
      ProposalStatus.negotiation,
      ProposalStatus.accepted,
      ProposalStatus.rejected,
      ProposalStatus.expired,
      ProposalStatus.signed,
      ProposalStatus.converted_to_contract,
    ].contains(status);
  }
  bool get canSubmit => isDraft || status == ProposalStatus.revised;
  bool get canApprove => isUnderReview || status == ProposalStatus.submitted;
  bool get canSign => status == ProposalStatus.accepted && approvalStatus == ApprovalStatus.approved;

  factory Proposal.fromJson(Map<String, dynamic> json) {
    try {
      return Proposal(
        id: json['_id']?.toString() ?? '',
        proposalNumber: json['proposalNumber'] as String? ?? '',
        opportunity: json['opportunity']?['_id']?.toString(),
        quote: json['quote']?['_id']?.toString(),
        customer: json['customer']?['_id']?.toString() ?? '',
        proposalDate: DateTime.parse(json['proposalDate'] as String),
        validityDate: json['validityDate'] != null ? DateTime.parse(json['validityDate'] as String) : null,
        status: ProposalStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => ProposalStatus.draft,
        ),
        version: json['version'] as int? ?? 1,
        executiveSummary: json['executiveSummary'] as String? ?? '',
        objectives: (json['objectives'] as List<dynamic>?)?.cast<String>(),
        scopeOfWork: json['scopeOfWork'] as String? ?? '',
        deliverables: (json['deliverables'] as List<dynamic>?)?.cast<String>(),
        technicalApproach: json['technicalApproach'] as String? ?? '',
        methodology: json['methodology'] as String? ?? '',
        timeline: json['timeline'] != null
            ? ProposalTimeline.fromJson(json['timeline'] as Map<String, dynamic>)
            : null,
        resources: (json['resources'] as List<dynamic>?)
            ?.map((r) => ProposalResource.fromJson(r as Map<String, dynamic>))
            .toList(),
        assumptions: (json['assumptions'] as List<dynamic>?)?.cast<String>(),
        constraints: (json['constraints'] as List<dynamic>?)?.cast<String>(),
        pricingModel: PricingModel.values.firstWhere(
              (e) => e.name == json['pricingModel'],
          orElse: () => PricingModel.fixed_price,
        ),
        items: (json['items'] as List<dynamic>?)
            ?.map((i) => ProposalItem.fromJson(i as Map<String, dynamic>))
            .toList() ?? [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        paymentSchedule: (json['paymentSchedule'] as List<dynamic>?)
            ?.map((p) => PaymentMilestone.fromJson(p as Map<String, dynamic>))
            .toList(),
        currency: json['currency'] as String? ?? 'KES',
        termsAndConditions: (json['termsAndConditions'] as List<dynamic>?)?.cast<String>(),
        reviewStatus: ReviewStatus.values.firstWhere(
              (e) => e.name == json['reviewStatus'],
          orElse: () => ReviewStatus.pending,
        ),
        approvalStatus: ApprovalStatus.values.firstWhere(
              (e) => e.name == json['approvalStatus'],
          orElse: () => ApprovalStatus.pending,
        ),
        reviewedBy: json['reviewedBy']?['_id']?.toString(),
        reviewDate: json['reviewDate'] != null ? DateTime.parse(json['reviewDate'] as String) : null,
        approvedBy: json['approvedBy']?['_id']?.toString(),
        approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate'] as String) : null,
        signedByCustomer: json['signedByCustomer']?['_id']?.toString(),
        signedByCompany: json['signedByCompany']?['_id']?.toString(),
        signatureDate: json['signatureDate'] != null ? DateTime.parse(json['signatureDate'] as String) : null,
        contractStartDate: json['contractStartDate'] != null ? DateTime.parse(json['contractStartDate'] as String) : null,
        contractEndDate: json['contractEndDate'] != null ? DateTime.parse(json['contractEndDate'] as String) : null,
        createdBy: json['createdBy']?['_id']?.toString() ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        customerName: json['customer']?['companyName']?.toString() ??
            '${json['customer']?['firstName'] ?? ''} ${json['customer']?['lastName'] ?? ''}',
        opportunityName: json['opportunity']?['opportunityNumber']?.toString(),
        quoteNumber: json['quote']?['quoteNumber']?.toString(),
      );
    } catch (e, stack) {
      print('Error parsing Proposal: $e');
      print('Stack: $stack');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      '_id': id,
      'proposalNumber': proposalNumber,
      if (opportunity != null) 'opportunity': opportunity,
      if (quote != null) 'quote': quote,
      'customer': customer,
      'proposalDate': proposalDate.toIso8601String(),
      if (validityDate != null) 'validityDate': validityDate!.toIso8601String(),
      'status': status.name,
      'version': version,
      'executiveSummary': executiveSummary,
      if (objectives != null) 'objectives': objectives,
      'scopeOfWork': scopeOfWork,
      if (deliverables != null) 'deliverables': deliverables,
      'technicalApproach': technicalApproach,
      'methodology': methodology,
      if (timeline != null) 'timeline': timeline!.toJson(),
      if (resources != null) 'resources': resources!.map((r) => r.toJson()).toList(),
      if (assumptions != null) 'assumptions': assumptions,
      if (constraints != null) 'constraints': constraints,
      'pricingModel': pricingModel.name,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      if (paymentSchedule != null) 'paymentSchedule': paymentSchedule!.map((p) => p.toJson()).toList(),
      'currency': currency,
      if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
      'reviewStatus': reviewStatus.name,
      'approvalStatus': approvalStatus.name,
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (reviewDate != null) 'reviewDate': reviewDate!.toIso8601String(),
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvalDate != null) 'approvalDate': approvalDate!.toIso8601String(),
      if (signedByCustomer != null) 'signedByCustomer': signedByCustomer,
      if (signedByCompany != null) 'signedByCompany': signedByCompany,
      if (signatureDate != null) 'signatureDate': signatureDate!.toIso8601String(),
      if (contractStartDate != null) 'contractStartDate': contractStartDate!.toIso8601String(),
      if (contractEndDate != null) 'contractEndDate': contractEndDate!.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    return json;
  }

  Proposal copyWith({
    String? id,
    String? proposalNumber,
    String? opportunity,
    String? quote,
    String? customer,
    DateTime? proposalDate,
    DateTime? validityDate,
    ProposalStatus? status,
    int? version,
    String? executiveSummary,
    List<String>? objectives,
    String? scopeOfWork,
    List<String>? deliverables,
    String? technicalApproach,
    String? methodology,
    ProposalTimeline? timeline,
    List<ProposalResource>? resources,
    List<String>? assumptions,
    List<String>? constraints,
    PricingModel? pricingModel,
    List<ProposalItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    List<PaymentMilestone>? paymentSchedule,
    String? currency,
    List<String>? termsAndConditions,
    ReviewStatus? reviewStatus,
    ApprovalStatus? approvalStatus,
    String? reviewedBy,
    DateTime? reviewDate,
    String? approvedBy,
    DateTime? approvalDate,
    String? signedByCustomer,
    String? signedByCompany,
    DateTime? signatureDate,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? opportunityName,
    String? quoteNumber,
  }) {
    return Proposal(
      id: id ?? this.id,
      proposalNumber: proposalNumber ?? this.proposalNumber,
      opportunity: opportunity ?? this.opportunity,
      quote: quote ?? this.quote,
      customer: customer ?? this.customer,
      proposalDate: proposalDate ?? this.proposalDate,
      validityDate: validityDate ?? this.validityDate,
      status: status ?? this.status,
      version: version ?? this.version,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      objectives: objectives ?? this.objectives,
      scopeOfWork: scopeOfWork ?? this.scopeOfWork,
      deliverables: deliverables ?? this.deliverables,
      technicalApproach: technicalApproach ?? this.technicalApproach,
      methodology: methodology ?? this.methodology,
      timeline: timeline ?? this.timeline,
      resources: resources ?? this.resources,
      assumptions: assumptions ?? this.assumptions,
      constraints: constraints ?? this.constraints,
      pricingModel: pricingModel ?? this.pricingModel,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      currency: currency ?? this.currency,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewDate: reviewDate ?? this.reviewDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      signedByCustomer: signedByCustomer ?? this.signedByCustomer,
      signedByCompany: signedByCompany ?? this.signedByCompany,
      signatureDate: signatureDate ?? this.signatureDate,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      opportunityName: opportunityName ?? this.opportunityName,
      quoteNumber: quoteNumber ?? this.quoteNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Proposal &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              proposalNumber == other.proposalNumber;

  @override
  int get hashCode => id.hashCode ^ proposalNumber.hashCode;
}

// ============================================
// UTILITY CLASSES
// ============================================

class ProposalFilters {
  final ProposalStatus? status;
  final ApprovalStatus? approvalStatus;
  final String? customerId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortDesc;

  const ProposalFilters({
    this.status,
    this.approvalStatus,
    this.customerId,
    this.fromDate,
    this.toDate,
    this.searchQuery,
    this.sortBy,
    this.sortDesc = false,
  });

  ProposalFilters copyWith({
    ProposalStatus? status,
    ApprovalStatus? approvalStatus,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
    String? sortBy,
    bool? sortDesc,
  }) {
    return ProposalFilters(
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      customerId: customerId ?? this.customerId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortDesc: sortDesc ?? this.sortDesc,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (status != null) {
      params['status'] = status!.name;
    }

    if (approvalStatus != null) {
      params['approvalStatus'] = approvalStatus!.name;
    }

    if (customerId != null && customerId!.isNotEmpty) {
      params['customer'] = customerId!;
    }

    if (fromDate != null) {
      params['fromDate'] = fromDate!.toIso8601String();
    }

    if (toDate != null) {
      params['toDate'] = toDate!.toIso8601String();
    }

    // Add search query parameter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }

    if (sortBy != null) {
      params['sortBy'] = sortBy!;
    }

    if (sortDesc != null) {
      params['sortDesc'] = sortDesc.toString();
    }

    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProposalFilters &&
        other.status == status &&
        other.approvalStatus == approvalStatus &&
        other.customerId == customerId &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.sortDesc == sortDesc;
  }

  @override
  int get hashCode {
    return status.hashCode ^
    approvalStatus.hashCode ^
    customerId.hashCode ^
    fromDate.hashCode ^
    toDate.hashCode ^
    searchQuery.hashCode ^
    sortBy.hashCode ^
    sortDesc.hashCode;
  }
}