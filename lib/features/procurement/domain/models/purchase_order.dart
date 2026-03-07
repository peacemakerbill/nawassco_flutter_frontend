class PurchaseOrder {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final String supplierContactId;
  final String? requisitionId;
  final String? rfqId;
  final String? tenderId;
  final List<POItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String paymentTerms;
  final String deliveryTerms;
  final String deliveryAddress;
  final String? incoterms;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String status;
  final String approvalStatus;
  final String shippingMethod;
  final String? trackingNumber;
  final double shippingCost;
  final double receivedQuantity;
  final String? receivedById;
  final DateTime? receiptDate;
  final List<POInvoice> invoices;
  final double totalPaid;
  final double balanceDue;
  final String createdById;
  final String createdByName;
  final String? approvedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.supplierContactId,
    this.requisitionId,
    this.rfqId,
    this.tenderId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.currency = 'KES',
    required this.paymentTerms,
    required this.deliveryTerms,
    required this.deliveryAddress,
    this.incoterms,
    required this.orderDate,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.status,
    required this.approvalStatus,
    required this.shippingMethod,
    this.trackingNumber,
    this.shippingCost = 0,
    this.receivedQuantity = 0,
    this.receivedById,
    this.receiptDate,
    required this.invoices,
    this.totalPaid = 0,
    this.balanceDue = 0,
    required this.createdById,
    required this.createdByName,
    this.approvedById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['_id'] ?? json['id'] ?? '',
      poNumber: json['poNumber'] ?? '',
      supplierId: json['supplier'] is String ? json['supplier'] : json['supplier']?['_id'] ?? '',
      supplierName: json['supplier'] is String ? '' : json['supplier']?['companyName'] ?? '',
      supplierContactId: json['supplierContact'] is String ? json['supplierContact'] : json['supplierContact']?['_id'] ?? '',
      requisitionId: json['requisition'] is String ? json['requisition'] : json['requisition']?['_id'],
      rfqId: json['rfq'] is String ? json['rfq'] : json['rfq']?['_id'],
      tenderId: json['tender'] is String ? json['tender'] : json['tender']?['_id'],
      items: (json['items'] as List<dynamic>? ?? []).map((item) => POItem.fromJson(item)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? 'KES',
      paymentTerms: json['paymentTerms'] ?? '',
      deliveryTerms: json['deliveryTerms'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      incoterms: json['incoterms'],
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate'] ?? DateTime.now().toIso8601String()),
      actualDeliveryDate: json['actualDeliveryDate'] != null ? DateTime.parse(json['actualDeliveryDate']) : null,
      status: json['status'] ?? 'draft',
      approvalStatus: json['approvalStatus'] ?? 'pending',
      shippingMethod: json['shippingMethod'] ?? '',
      trackingNumber: json['trackingNumber'],
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0,
      receivedById: json['receivedBy'] is String ? json['receivedBy'] : json['receivedBy']?['_id'],
      receiptDate: json['receiptDate'] != null ? DateTime.parse(json['receiptDate']) : null,
      invoices: (json['invoices'] as List<dynamic>? ?? []).map((invoice) => POInvoice.fromJson(invoice)).toList(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balanceDue'] as num?)?.toDouble() ?? 0,
      createdById: json['createdBy'] is String ? json['createdBy'] : json['createdBy']?['_id'] ?? '',
      createdByName: json['createdBy'] is String ? '' : '${json['createdBy']?['firstName'] ?? ''} ${json['createdBy']?['lastName'] ?? ''}',
      approvedById: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'poNumber': poNumber,
      'supplier': supplierId,
      'supplierContact': supplierContactId,
      'requisition': requisitionId,
      'rfq': rfqId,
      'tender': tenderId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'paymentTerms': paymentTerms,
      'deliveryTerms': deliveryTerms,
      'deliveryAddress': deliveryAddress,
      'incoterms': incoterms,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'status': status,
      'approvalStatus': approvalStatus,
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'shippingCost': shippingCost,
      'receivedQuantity': receivedQuantity,
      'receivedBy': receivedById,
      'receiptDate': receiptDate?.toIso8601String(),
      'invoices': invoices.map((invoice) => invoice.toJson()).toList(),
      'totalPaid': totalPaid,
      'balanceDue': balanceDue,
      'createdBy': createdById,
    };
  }

  PurchaseOrder copyWith({
    String? id,
    String? poNumber,
    String? supplierId,
    String? supplierName,
    String? supplierContactId,
    String? requisitionId,
    String? rfqId,
    String? tenderId,
    List<POItem>? items,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    String? paymentTerms,
    String? deliveryTerms,
    String? deliveryAddress,
    String? incoterms,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? status,
    String? approvalStatus,
    String? shippingMethod,
    String? trackingNumber,
    double? shippingCost,
    double? receivedQuantity,
    String? receivedById,
    DateTime? receiptDate,
    List<POInvoice>? invoices,
    double? totalPaid,
    double? balanceDue,
    String? createdById,
    String? createdByName,
    String? approvedById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierContactId: supplierContactId ?? this.supplierContactId,
      requisitionId: requisitionId ?? this.requisitionId,
      rfqId: rfqId ?? this.rfqId,
      tenderId: tenderId ?? this.tenderId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      incoterms: incoterms ?? this.incoterms,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippingCost: shippingCost ?? this.shippingCost,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      receivedById: receivedById ?? this.receivedById,
      receiptDate: receiptDate ?? this.receiptDate,
      invoices: invoices ?? this.invoices,
      totalPaid: totalPaid ?? this.totalPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      approvedById: approvedById ?? this.approvedById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class POItem {
  final String itemCode;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double receivedQuantity;
  final double rejectedQuantity;
  final String status;

  POItem({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.receivedQuantity = 0,
    this.rejectedQuantity = 0,
    this.status = 'pending',
  });

  factory POItem.fromJson(Map<String, dynamic> json) {
    return POItem(
      itemCode: json['itemCode'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0,
      rejectedQuantity: (json['rejectedQuantity'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
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
      'receivedQuantity': receivedQuantity,
      'rejectedQuantity': rejectedQuantity,
      'status': status,
    };
  }

  POItem copyWith({
    String? itemCode,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    double? receivedQuantity,
    double? rejectedQuantity,
    String? status,
  }) {
    return POItem(
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      rejectedQuantity: rejectedQuantity ?? this.rejectedQuantity,
      status: status ?? this.status,
    );
  }
}

class POInvoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double amount;
  final String status;
  final DateTime? paidDate;
  final String? paymentReference;

  POInvoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.amount,
    required this.status,
    this.paidDate,
    this.paymentReference,
  });

  factory POInvoice.fromJson(Map<String, dynamic> json) {
    return POInvoice(
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      paymentReference: json['paymentReference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'amount': amount,
      'status': status,
      'paidDate': paidDate?.toIso8601String(),
      'paymentReference': paymentReference,
    };
  }
}