class GoodsReceiptNote {
  final String id;
  final String grnNumber;
  final String purchaseOrderId;
  final String purchaseOrderNumber;
  final String supplierId;
  final String supplierName;
  final DateTime receiptDate;
  final String receivedById;
  final String receivedByName; // Changed to non-nullable with default
  final String? deliveryNoteNumber;
  final String? vehicleNumber;
  final List<GRNItem> items;
  final int totalQuantity;
  final double totalValue;
  final String qualityStatus;
  final String? qualityRemarks;
  final String? inspectedById;
  final String? inspectedByName;
  final DateTime? inspectionDate;
  final String storageLocation;
  final String storekeeperId;
  final String storekeeperName; // Changed to non-nullable with default
  final String status;
  final bool hasReturns;
  final String? returnReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoodsReceiptNote({
    required this.id,
    required this.grnNumber,
    required this.purchaseOrderId,
    required this.purchaseOrderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.receiptDate,
    required this.receivedById,
    required this.receivedByName, // Now required
    this.deliveryNoteNumber,
    this.vehicleNumber,
    required this.items,
    required this.totalQuantity,
    required this.totalValue,
    required this.qualityStatus,
    this.qualityRemarks,
    this.inspectedById,
    this.inspectedByName,
    this.inspectionDate,
    required this.storageLocation,
    required this.storekeeperId,
    required this.storekeeperName, // Now required
    required this.status,
    required this.hasReturns,
    this.returnReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoodsReceiptNote.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptNote(
      id: json['id'] ?? json['_id'],
      grnNumber: json['grnNumber'],
      purchaseOrderId: json['purchaseOrder'] is String
          ? json['purchaseOrder']
          : json['purchaseOrder']?['_id'] ?? '',
      purchaseOrderNumber: _getPurchaseOrderNumber(json['purchaseOrder']),
      supplierId: json['supplier'] is String
          ? json['supplier']
          : json['supplier']?['_id'] ?? '',
      supplierName: _getSupplierName(json['supplier']),
      receiptDate: DateTime.parse(json['receiptDate']),
      receivedById: json['receivedBy'] is String
          ? json['receivedBy']
          : json['receivedBy']?['_id'] ?? '',
      receivedByName: _getUserName(json['receivedBy']) ?? 'Unknown User', // Provide default
      deliveryNoteNumber: json['deliveryNoteNumber'],
      vehicleNumber: json['vehicleNumber'],
      items: (json['items'] as List?)?.map((item) => GRNItem.fromJson(item)).toList() ?? [],
      totalQuantity: json['totalQuantity'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      qualityStatus: json['qualityStatus'] ?? 'pending',
      qualityRemarks: json['qualityRemarks'],
      inspectedById: json['inspectedBy'] is String
          ? json['inspectedBy']
          : json['inspectedBy']?['_id'],
      inspectedByName: _getUserName(json['inspectedBy']), // This can stay nullable
      inspectionDate: json['inspectionDate'] != null
          ? DateTime.parse(json['inspectionDate'])
          : null,
      storageLocation: json['storageLocation'] ?? '',
      storekeeperId: json['storekeeper'] is String
          ? json['storekeeper']
          : json['storekeeper']?['_id'] ?? '',
      storekeeperName: _getUserName(json['storekeeper']) ?? 'Unknown Storekeeper', // Provide default
      status: json['status'] ?? 'draft',
      hasReturns: json['hasReturns'] ?? false,
      returnReference: json['returnReference'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static String _getPurchaseOrderNumber(dynamic purchaseOrder) {
    if (purchaseOrder == null) return 'Unknown PO';
    if (purchaseOrder is String) return purchaseOrder;
    return purchaseOrder['poNumber'] ?? purchaseOrder['title'] ?? 'Unknown PO';
  }

  static String _getSupplierName(dynamic supplier) {
    if (supplier == null) return 'Unknown Supplier';
    if (supplier is String) return supplier;
    return supplier['companyName'] ?? supplier['tradingName'] ?? 'Unknown Supplier';
  }

  static String? _getUserName(dynamic user) {
    if (user == null) return null;
    if (user is String) return user;
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? null : fullName;
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrder': purchaseOrderId,
      'supplier': supplierId,
      'receiptDate': receiptDate.toIso8601String(),
      'receivedBy': receivedById,
      'deliveryNoteNumber': deliveryNoteNumber,
      'vehicleNumber': vehicleNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'storageLocation': storageLocation,
      'storekeeper': storekeeperId,
    };
  }
}

class GRNItem {
  final String poItem;
  final String description;
  final int orderedQuantity;
  final int receivedQuantity;
  final int acceptedQuantity;
  final int rejectedQuantity;
  final String unit;
  final double unitPrice;
  final double totalValue;
  final String? rejectionReason;
  final String status;

  GRNItem({
    required this.poItem,
    required this.description,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.acceptedQuantity,
    required this.rejectedQuantity,
    required this.unit,
    required this.unitPrice,
    required this.totalValue,
    this.rejectionReason,
    required this.status,
  });

  factory GRNItem.fromJson(Map<String, dynamic> json) {
    return GRNItem(
      poItem: json['poItem'] ?? '',
      description: json['description'] ?? '',
      orderedQuantity: json['orderedQuantity'] ?? 0,
      receivedQuantity: json['receivedQuantity'] ?? 0,
      acceptedQuantity: json['acceptedQuantity'] ?? 0,
      rejectedQuantity: json['rejectedQuantity'] ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      rejectionReason: json['rejectionReason'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'poItem': poItem,
      'description': description,
      'orderedQuantity': orderedQuantity,
      'receivedQuantity': receivedQuantity,
      'acceptedQuantity': acceptedQuantity,
      'rejectedQuantity': rejectedQuantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalValue': totalValue,
      'rejectionReason': rejectionReason,
    };
  }
}

class GRNStats {
  final int totalGRNs;
  final double totalValue;
  final List<QualityStatusStats> byQualityStatus;
  final String timeframe;

  GRNStats({
    required this.totalGRNs,
    required this.totalValue,
    required this.byQualityStatus,
    required this.timeframe,
  });

  factory GRNStats.fromJson(Map<String, dynamic> json) {
    return GRNStats(
      totalGRNs: json['totalGRNs'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      byQualityStatus: (json['byQualityStatus'] as List? ?? [])
          .map((e) => QualityStatusStats.fromJson(e))
          .toList(),
      timeframe: json['timeframe'] ?? 'month',
    );
  }
}

class QualityStatusStats {
  final String status;
  final int count;
  final double value;
  final double averageValue;

  QualityStatusStats({
    required this.status,
    required this.count,
    required this.value,
    required this.averageValue,
  });

  factory QualityStatusStats.fromJson(Map<String, dynamic> json) {
    return QualityStatusStats(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      averageValue: (json['averageValue'] ?? 0).toDouble(),
    );
  }
}