import 'package:flutter/material.dart';

class FieldInventory {
  final String id;
  final String itemCode;
  final String itemName;
  final String description;
  final String category;
  final String subcategory;

  // Stock Information
  final int currentStock;
  final int minimumStock;
  final int maximumStock;
  final String unit;
  final double unitCost;

  // Supplier Information
  final SupplierInfo supplier;
  final int reorderPoint;
  final int reorderQuantity;

  // Storage
  final String storageLocation;
  final String? shelfNumber;
  final String? binNumber;

  // Usage Tracking
  final int totalUsed;
  final DateTime? lastUsed;
  final double usageRate;

  // Specifications
  final List<InventorySpecification> specifications;
  final List<String> compatibleTools;

  // Status
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FieldInventory({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.unit,
    required this.unitCost,
    required this.supplier,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.storageLocation,
    this.shelfNumber,
    this.binNumber,
    required this.totalUsed,
    this.lastUsed,
    required this.usageRate,
    required this.specifications,
    required this.compatibleTools,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FieldInventory.fromJson(Map<String, dynamic> json) {
    return FieldInventory(
      id: json['_id'] ?? json['id'] ?? '',
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 0,
      maximumStock: json['maximumStock'] ?? 0,
      unit: json['unit'] ?? '',
      unitCost: (json['unitCost'] ?? 0).toDouble(),
      supplier: SupplierInfo.fromJson(json['supplier'] ?? {}),
      reorderPoint: json['reorderPoint'] ?? 0,
      reorderQuantity: json['reorderQuantity'] ?? 0,
      storageLocation: json['storageLocation'] ?? '',
      shelfNumber: json['shelfNumber'],
      binNumber: json['binNumber'],
      totalUsed: json['totalUsed'] ?? 0,
      lastUsed:
          json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
      usageRate: (json['usageRate'] ?? 0).toDouble(),
      specifications: List<InventorySpecification>.from(
          (json['specifications'] ?? [])
              .map((x) => InventorySpecification.fromJson(x))),
      compatibleTools: List<String>.from(
          json['compatibleTools']?.map((x) => x['toolName'] ?? x.toString()) ??
              []),
      status: json['status'] ?? 'in_stock',
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        'itemName': itemName,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'currentStock': currentStock,
        'minimumStock': minimumStock,
        'maximumStock': maximumStock,
        'unit': unit,
        'unitCost': unitCost,
        'supplier': supplier.toJson(),
        'reorderPoint': reorderPoint,
        'reorderQuantity': reorderQuantity,
        'storageLocation': storageLocation,
        'shelfNumber': shelfNumber,
        'binNumber': binNumber,
        'specifications': specifications.map((x) => x.toJson()).toList(),
        'isActive': isActive,
      };

  FieldInventory copyWith({
    String? itemCode,
    String? itemName,
    String? description,
    String? category,
    String? subcategory,
    int? currentStock,
    int? minimumStock,
    int? maximumStock,
    String? unit,
    double? unitCost,
    SupplierInfo? supplier,
    int? reorderPoint,
    int? reorderQuantity,
    String? storageLocation,
    String? shelfNumber,
    String? binNumber,
    List<InventorySpecification>? specifications,
    bool? isActive,
  }) {
    return FieldInventory(
      id: id,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      supplier: supplier ?? this.supplier,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      storageLocation: storageLocation ?? this.storageLocation,
      shelfNumber: shelfNumber ?? this.shelfNumber,
      binNumber: binNumber ?? this.binNumber,
      totalUsed: totalUsed,
      lastUsed: lastUsed,
      usageRate: usageRate,
      specifications: specifications ?? this.specifications,
      compatibleTools: compatibleTools,
      status: status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class SupplierInfo {
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final int leadTime;

  SupplierInfo({
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.leadTime,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    return SupplierInfo(
      name: json['name'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      leadTime: json['leadTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
        'leadTime': leadTime,
      };

  SupplierInfo copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    int? leadTime,
  }) {
    return SupplierInfo(
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      leadTime: leadTime ?? this.leadTime,
    );
  }
}

class InventorySpecification {
  final String parameter;
  final String value;
  final String unit;

  InventorySpecification({
    required this.parameter,
    required this.value,
    required this.unit,
  });

  factory InventorySpecification.fromJson(Map<String, dynamic> json) {
    return InventorySpecification(
      parameter: json['parameter'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'parameter': parameter,
        'value': value,
        'unit': unit,
      };

  InventorySpecification copyWith({
    String? parameter,
    String? value,
    String? unit,
  }) {
    return InventorySpecification(
      parameter: parameter ?? this.parameter,
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }
}

class FieldInventoryMetrics {
  final List<CategorySummary> categorySummary;
  final List<StatusSummary> statusSummary;
  final TotalValue totalValue;
  final List<ReorderAlert> reorderAlerts;

  FieldInventoryMetrics({
    required this.categorySummary,
    required this.statusSummary,
    required this.totalValue,
    required this.reorderAlerts,
  });

  factory FieldInventoryMetrics.fromJson(Map<String, dynamic> json) {
    return FieldInventoryMetrics(
      categorySummary: List<CategorySummary>.from(
          (json['categorySummary'] ?? [])
              .map((x) => CategorySummary.fromJson(x))),
      statusSummary: List<StatusSummary>.from(
          (json['statusSummary'] ?? []).map((x) => StatusSummary.fromJson(x))),
      totalValue: TotalValue.fromJson(json['totalValue']?.first ?? {}),
      reorderAlerts: List<ReorderAlert>.from(
          (json['reorderAlerts'] ?? []).map((x) => ReorderAlert.fromJson(x))),
    );
  }
}

class CategorySummary {
  final String category;
  final int totalItems;
  final double totalValue;
  final int lowStockItems;

  CategorySummary({
    required this.category,
    required this.totalItems,
    required this.totalValue,
    required this.lowStockItems,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['_id'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      lowStockItems: json['lowStockItems'] ?? 0,
    );
  }
}

class StatusSummary {
  final String status;
  final int count;
  final double totalValue;

  StatusSummary({
    required this.status,
    required this.count,
    required this.totalValue,
  });

  factory StatusSummary.fromJson(Map<String, dynamic> json) {
    return StatusSummary(
      status: json['_id'] ?? '',
      count: json['count'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
    );
  }
}

class TotalValue {
  final double totalInventoryValue;
  final int totalItems;
  final int itemsInStock;

  TotalValue({
    required this.totalInventoryValue,
    required this.totalItems,
    required this.itemsInStock,
  });

  factory TotalValue.fromJson(Map<String, dynamic> json) {
    return TotalValue(
      totalInventoryValue: (json['totalInventoryValue'] ?? 0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
      itemsInStock: json['itemsInStock'] ?? 0,
    );
  }
}

class ReorderAlert {
  final String itemCode;
  final String itemName;
  final int currentStock;
  final int reorderPoint;
  final int reorderQuantity;
  final double unitCost;

  ReorderAlert({
    required this.itemCode,
    required this.itemName,
    required this.currentStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unitCost,
  });

  factory ReorderAlert.fromJson(Map<String, dynamic> json) {
    return ReorderAlert(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      reorderPoint: json['reorderPoint'] ?? 0,
      reorderQuantity: json['reorderQuantity'] ?? 0,
      unitCost: (json['unitCost'] ?? 0).toDouble(),
    );
  }
}

enum StockAction { add, remove, set }

enum InventoryCategoryEnum {
  pipes_fittings('Pipes & Fittings', Icons.plumbing),
  valves('Valves', Icons.tap_and_play),
  meters('Meters', Icons.speed),
  tools_equipment('Tools & Equipment', Icons.build),
  safety_gear('Safety Gear', Icons.security),
  chemicals('Chemicals', Icons.science),
  electrical('Electrical', Icons.electrical_services),
  general_supplies('General Supplies', Icons.inventory);

  final String displayName;
  final IconData icon;

  const InventoryCategoryEnum(this.displayName, this.icon);
}

enum InventoryStatusEnum {
  in_stock('In Stock', Colors.green),
  low_stock('Low Stock', Colors.orange),
  out_of_stock('Out of Stock', Colors.red),
  discontinued('Discontinued', Colors.grey);

  final String displayName;
  final Color color;

  const InventoryStatusEnum(this.displayName, this.color);
}
