class PurchaseRequisition {
  final String id;
  final String requisitionNumber;
  final String title;
  final String description;
  final String department;
  final String costCenter;
  final String budgetCode;
  final List<RequisitionItem> items;
  final double totalAmount;
  final String currency;
  final DateTime requiredDate;
  final String urgency;
  final String justification;
  final String expectedOutcomes;
  final String alternativeConsidered;
  final String status;
  final String? currentApproverId;
  final String? currentApproverName;
  final List<ApprovalStep> approvalHistory;
  final String? nextAction;
  final String procurementType;
  final String category;
  final double estimatedValue;
  final String? relatedProject;
  final String? relatedTenderId;
  final String requestedById;
  final String requestedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseRequisition({
    required this.id,
    required this.requisitionNumber,
    required this.title,
    required this.description,
    required this.department,
    required this.costCenter,
    required this.budgetCode,
    required this.items,
    required this.totalAmount,
    this.currency = 'KES',
    required this.requiredDate,
    required this.urgency,
    required this.justification,
    required this.expectedOutcomes,
    required this.alternativeConsidered,
    required this.status,
    this.currentApproverId,
    this.currentApproverName,
    required this.approvalHistory,
    this.nextAction,
    required this.procurementType,
    required this.category,
    required this.estimatedValue,
    this.relatedProject,
    this.relatedTenderId,
    required this.requestedById,
    required this.requestedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseRequisition.fromJson(Map<String, dynamic> json) {
    return PurchaseRequisition(
      id: json['_id'] ?? json['id'] ?? '',
      requisitionNumber: json['requisitionNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      department: json['department'] ?? '',
      costCenter: json['costCenter'] ?? '',
      budgetCode: json['budgetCode'] ?? '',
      items: (json['items'] as List<dynamic>? ?? []).map((item) => RequisitionItem.fromJson(item)).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? 'KES',
      requiredDate: DateTime.parse(json['requiredDate'] ?? DateTime.now().toIso8601String()),
      urgency: json['urgency'] ?? 'medium',
      justification: json['justification'] ?? '',
      expectedOutcomes: json['expectedOutcomes'] ?? '',
      alternativeConsidered: json['alternativeConsidered'] ?? '',
      status: json['status'] ?? 'draft',
      currentApproverId: json['currentApprover'] is String ? json['currentApprover'] : json['currentApprover']?['_id'],
      currentApproverName: json['currentApprover'] is String ? '' : '${json['currentApprover']?['firstName'] ?? ''} ${json['currentApprover']?['lastName'] ?? ''}',
      approvalHistory: (json['approvalHistory'] as List<dynamic>? ?? []).map((step) => ApprovalStep.fromJson(step)).toList(),
      nextAction: json['nextAction'],
      procurementType: json['procurementType'] ?? 'direct_purchase',
      category: json['category'] ?? '',
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 0,
      relatedProject: json['relatedProject'],
      relatedTenderId: json['relatedTender'] is String ? json['relatedTender'] : json['relatedTender']?['_id'],
      requestedById: json['requestedBy'] is String ? json['requestedBy'] : json['requestedBy']?['_id'] ?? '',
      requestedByName: json['requestedBy'] is String ? '' : '${json['requestedBy']?['firstName'] ?? ''} ${json['requestedBy']?['lastName'] ?? ''}',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requisitionNumber': requisitionNumber,
      'title': title,
      'description': description,
      'department': department,
      'costCenter': costCenter,
      'budgetCode': budgetCode,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'currency': currency,
      'requiredDate': requiredDate.toIso8601String(),
      'urgency': urgency,
      'justification': justification,
      'expectedOutcomes': expectedOutcomes,
      'alternativeConsidered': alternativeConsidered,
      'status': status,
      'currentApprover': currentApproverId,
      'approvalHistory': approvalHistory.map((step) => step.toJson()).toList(),
      'nextAction': nextAction,
      'procurementType': procurementType,
      'category': category,
      'estimatedValue': estimatedValue,
      'relatedProject': relatedProject,
      'relatedTender': relatedTenderId,
      'requestedBy': requestedById,
    };
  }

  PurchaseRequisition copyWith({
    String? id,
    String? requisitionNumber,
    String? title,
    String? description,
    String? department,
    String? costCenter,
    String? budgetCode,
    List<RequisitionItem>? items,
    double? totalAmount,
    String? currency,
    DateTime? requiredDate,
    String? urgency,
    String? justification,
    String? expectedOutcomes,
    String? alternativeConsidered,
    String? status,
    String? currentApproverId,
    String? currentApproverName,
    List<ApprovalStep>? approvalHistory,
    String? nextAction,
    String? procurementType,
    String? category,
    double? estimatedValue,
    String? relatedProject,
    String? relatedTenderId,
    String? requestedById,
    String? requestedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseRequisition(
      id: id ?? this.id,
      requisitionNumber: requisitionNumber ?? this.requisitionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      department: department ?? this.department,
      costCenter: costCenter ?? this.costCenter,
      budgetCode: budgetCode ?? this.budgetCode,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      requiredDate: requiredDate ?? this.requiredDate,
      urgency: urgency ?? this.urgency,
      justification: justification ?? this.justification,
      expectedOutcomes: expectedOutcomes ?? this.expectedOutcomes,
      alternativeConsidered: alternativeConsidered ?? this.alternativeConsidered,
      status: status ?? this.status,
      currentApproverId: currentApproverId ?? this.currentApproverId,
      currentApproverName: currentApproverName ?? this.currentApproverName,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      nextAction: nextAction ?? this.nextAction,
      procurementType: procurementType ?? this.procurementType,
      category: category ?? this.category,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      relatedProject: relatedProject ?? this.relatedProject,
      relatedTenderId: relatedTenderId ?? this.relatedTenderId,
      requestedById: requestedById ?? this.requestedById,
      requestedByName: requestedByName ?? this.requestedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RequisitionItem {
  final String itemCode;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String specifications;
  final String? preferredSupplierId;
  final DateTime deliveryDate;

  RequisitionItem({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.specifications,
    this.preferredSupplierId,
    required this.deliveryDate,
  });

  factory RequisitionItem.fromJson(Map<String, dynamic> json) {
    return RequisitionItem(
      itemCode: json['itemCode'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      specifications: json['specifications'] ?? '',
      preferredSupplierId: json['preferredSupplier'] is String ? json['preferredSupplier'] : json['preferredSupplier']?['_id'],
      deliveryDate: DateTime.parse(json['deliveryDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'specifications': specifications,
      'preferredSupplier': preferredSupplierId,
      'deliveryDate': deliveryDate.toIso8601String(),
    };
  }
}

class ApprovalStep {
  final String approverId;
  final String approverName;
  final String role;
  final String status;
  final String? comments;
  final DateTime? approvedAt;
  final int sequence;

  ApprovalStep({
    required this.approverId,
    required this.approverName,
    required this.role,
    required this.status,
    this.comments,
    this.approvedAt,
    required this.sequence,
  });

  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    return ApprovalStep(
      approverId: json['approver'] is String ? json['approver'] : json['approver']?['_id'] ?? '',
      approverName: json['approver'] is String ? '' : '${json['approver']?['firstName'] ?? ''} ${json['approver']?['lastName'] ?? ''}',
      role: json['role'] ?? '',
      status: json['status'] ?? 'pending',
      comments: json['comments'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approver': approverId,
      'role': role,
      'status': status,
      'comments': comments,
      'approvedAt': approvedAt?.toIso8601String(),
      'sequence': sequence,
    };
  }
}