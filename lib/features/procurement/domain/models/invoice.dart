import 'package:flutter/foundation.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String supplierId;
  final String supplierName;
  final String purchaseOrderId;
  final String purchaseOrderNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double totalAmount;
  final double taxAmount;
  final String currency;
  final List<InvoiceItem> items;
  final PaymentStatus paymentStatus;
  final double paidAmount;
  final double balanceDue;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? paymentReference;
  final ApprovalStatus approvalStatus;
  final String? approvedBy;
  final DateTime? approvedDate;
  final List<String> grnReferences;
  final bool isMatched;
  final List<String> matchingDiscrepancies;
  final InvoiceStatus status;
  final int age;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseOrderId,
    required this.purchaseOrderNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.totalAmount,
    required this.taxAmount,
    required this.currency,
    required this.items,
    required this.paymentStatus,
    required this.paidAmount,
    required this.balanceDue,
    this.paymentDate,
    this.paymentMethod,
    this.paymentReference,
    required this.approvalStatus,
    this.approvedBy,
    this.approvedDate,
    required this.grnReferences,
    required this.isMatched,
    required this.matchingDiscrepancies,
    required this.status,
    required this.age,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      supplierId: json['supplier'] is String
          ? json['supplier']
          : json['supplier']?['_id'] ?? '',
      supplierName: json['supplier'] is String
          ? ''
          : json['supplier']?['companyName'] ?? '',
      purchaseOrderId: json['purchaseOrder'] is String
          ? json['purchaseOrder']
          : json['purchaseOrder']?['_id'] ?? '',
      purchaseOrderNumber: json['purchaseOrder'] is String
          ? ''
          : json['purchaseOrder']?['poNumber'] ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      items: (json['items'] as List? ?? []).map((item) => InvoiceItem.fromJson(item)).toList(),
      paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      balanceDue: (json['balanceDue'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
      paymentMethod: json['paymentMethod'],
      paymentReference: json['paymentReference'],
      approvalStatus: ApprovalStatus.values.firstWhere(
            (e) => e.name == json['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),
      approvedBy: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'],
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate']) : null,
      grnReferences: List<String>.from(json['grnReferences'] ?? []),
      isMatched: json['isMatched'] ?? false,
      matchingDiscrepancies: List<String>.from(json['matchingDiscrepancies'] ?? []),
      status: InvoiceStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      age: json['age'] ?? 0,
      createdBy: json['createdBy'] is String ? json['createdBy'] : json['createdBy']?['_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'supplier': supplierId,
      'purchaseOrder': purchaseOrderId,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'currency': currency,
      'items': items.map((item) => item.toJson()).toList(),
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? supplierId,
    String? supplierName,
    String? purchaseOrderId,
    String? purchaseOrderNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? totalAmount,
    double? taxAmount,
    String? currency,
    List<InvoiceItem>? items,
    PaymentStatus? paymentStatus,
    double? paidAmount,
    double? balanceDue,
    DateTime? paymentDate,
    String? paymentMethod,
    String? paymentReference,
    ApprovalStatus? approvalStatus,
    String? approvedBy,
    DateTime? approvedDate,
    List<String>? grnReferences,
    bool? isMatched,
    List<String>? matchingDiscrepancies,
    InvoiceStatus? status,
    int? age,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      grnReferences: grnReferences ?? this.grnReferences,
      isMatched: isMatched ?? this.isMatched,
      matchingDiscrepancies: matchingDiscrepancies ?? this.matchingDiscrepancies,
      status: status ?? this.status,
      age: age ?? this.age,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String glAccount;
  final String costCenter;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.glAccount,
    required this.costCenter,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      glAccount: json['glAccount'] ?? '',
      costCenter: json['costCenter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'glAccount': glAccount,
      'costCenter': costCenter,
    };
  }
}

enum PaymentStatus {
  pending,
  partially_paid,
  paid,
  overdue,
  cancelled
}

enum InvoiceStatus {
  draft,
  submitted,
  verified,
  approved,
  paid,
  disputed,
  cancelled
}

enum ApprovalStatus {
  pending,
  approved,
  rejected
}