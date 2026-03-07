import 'package:flutter/material.dart';

import 'chart_of_account_model.dart';

enum AssetCategory {
  land,
  buildings,
  vehicles,
  equipment,
  furniture,
  computers,
  office_equipment
}

enum DepreciationMethod {
  straight_line,
  declining_balance,
  units_of_production,
  none
}

enum AssetStatus {
  active,
  idle,
  under_maintenance,
  disposed,
  sold,
  written_off
}

class FixedAsset {
  final String id;
  final String assetNumber;
  final String assetName;
  final String description;
  final AssetCategory assetCategory;
  final DateTime acquisitionDate;
  final double acquisitionCost;
  final String? supplierName;           // Changed from supplierId
  final String? purchaseOrderNumber;    // Changed from purchaseOrderId
  final DepreciationMethod depreciationMethod;
  final int usefulLife;
  final double salvageValue;
  final double currentBookValue;
  final double accumulatedDepreciation;
  final String location;
  final String department;
  final AssetStatus status;
  final DateTime? disposalDate;
  final double? disposalAmount;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final bool insured;
  final double? insuranceValue;
  final DateTime? insuranceExpiry;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final Map<String, dynamic>? createdBy;

  FixedAsset({
    required this.id,
    required this.assetNumber,
    required this.assetName,
    required this.description,
    required this.assetCategory,
    required this.acquisitionDate,
    required this.acquisitionCost,
    this.supplierName,
    this.purchaseOrderNumber,
    required this.depreciationMethod,
    required this.usefulLife,
    required this.salvageValue,
    required this.currentBookValue,
    required this.accumulatedDepreciation,
    required this.location,
    required this.department,
    required this.status,
    this.disposalDate,
    this.disposalAmount,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    required this.insured,
    this.insuranceValue,
    this.insuranceExpiry,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory FixedAsset.fromJson(Map<String, dynamic> json) {
    return FixedAsset(
      id: json['_id'] ?? json['id'],
      assetNumber: json['assetNumber'],
      assetName: json['assetName'],
      description: json['description'],
      assetCategory: AssetCategory.values.firstWhere(
            (e) => e.name == json['assetCategory'],
        orElse: () => AssetCategory.equipment,
      ),
      acquisitionDate: DateTime.parse(json['acquisitionDate']),
      acquisitionCost: (json['acquisitionCost'] as num).toDouble(),
      supplierName: json['supplierName'],                    // Changed
      purchaseOrderNumber: json['purchaseOrderNumber'],      // Changed
      depreciationMethod: DepreciationMethod.values.firstWhere(
            (e) => e.name == json['depreciationMethod'],
        orElse: () => DepreciationMethod.straight_line,
      ),
      usefulLife: json['usefulLife'],
      salvageValue: (json['salvageValue'] as num).toDouble(),
      currentBookValue: (json['currentBookValue'] as num).toDouble(),
      accumulatedDepreciation:
      (json['accumulatedDepreciation'] as num).toDouble(),
      location: json['location'],
      department: json['department'],
      status: AssetStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => AssetStatus.active,
      ),
      disposalDate: json['disposalDate'] != null
          ? DateTime.parse(json['disposalDate'])
          : null,
      disposalAmount: json['disposalAmount']?.toDouble(),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'])
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'])
          : null,
      insured: json['insured'] ?? false,
      insuranceValue: json['insuranceValue']?.toDouble(),
      insuranceExpiry: json['insuranceExpiry'] != null
          ? DateTime.parse(json['insuranceExpiry'])
          : null,
      createdById: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'] is Map
          ? Map<String, dynamic>.from(json['createdBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetName': assetName,
      'description': description,
      'assetCategory': assetCategory.name,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'acquisitionCost': acquisitionCost,
      'supplierName': supplierName,               // Changed
      'purchaseOrderNumber': purchaseOrderNumber, // Changed
      'depreciationMethod': depreciationMethod.name,
      'usefulLife': usefulLife,
      'salvageValue': salvageValue,
      'location': location,
      'department': department,
      'insured': insured,
      'insuranceValue': insuranceValue,
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
    };
  }

  FixedAsset copyWith({
    String? assetName,
    String? description,
    AssetCategory? assetCategory,
    DateTime? acquisitionDate,
    double? acquisitionCost,
    String? supplierName,           // Changed
    String? purchaseOrderNumber,    // Changed
    DepreciationMethod? depreciationMethod,
    int? usefulLife,
    double? salvageValue,
    String? location,
    String? department,
    bool? insured,
    double? insuranceValue,
    DateTime? insuranceExpiry,
  }) {
    return FixedAsset(
      id: id,
      assetNumber: assetNumber,
      assetName: assetName ?? this.assetName,
      description: description ?? this.description,
      assetCategory: assetCategory ?? this.assetCategory,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      supplierName: supplierName ?? this.supplierName,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
      usefulLife: usefulLife ?? this.usefulLife,
      salvageValue: salvageValue ?? this.salvageValue,
      currentBookValue: currentBookValue,
      accumulatedDepreciation: accumulatedDepreciation,
      location: location ?? this.location,
      department: department ?? this.department,
      status: status,
      disposalDate: disposalDate,
      disposalAmount: disposalAmount,
      lastMaintenanceDate: lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate,
      insured: insured ?? this.insured,
      insuranceValue: insuranceValue ?? this.insuranceValue,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (assetCategory) {
      case AssetCategory.land:
        return 'Land';
      case AssetCategory.buildings:
        return 'Buildings';
      case AssetCategory.vehicles:
        return 'Vehicles';
      case AssetCategory.equipment:
        return 'Equipment';
      case AssetCategory.furniture:
        return 'Furniture';
      case AssetCategory.computers:
        return 'Computers';
      case AssetCategory.office_equipment:
        return 'Office Equipment';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AssetStatus.active:
        return 'Active';
      case AssetStatus.idle:
        return 'Idle';
      case AssetStatus.under_maintenance:
        return 'Under Maintenance';
      case AssetStatus.disposed:
        return 'Disposed';
      case AssetStatus.sold:
        return 'Sold';
      case AssetStatus.written_off:
        return 'Written Off';
    }
  }

  Color get statusColor {
    switch (status) {
      case AssetStatus.active:
        return Colors.green;
      case AssetStatus.idle:
        return Colors.orange;
      case AssetStatus.under_maintenance:
        return Colors.blue;
      case AssetStatus.disposed:
        return Colors.red;
      case AssetStatus.sold:
        return Colors.purple;
      case AssetStatus.written_off:
        return Colors.grey;
    }
  }

  bool get isDepreciable => depreciationMethod != DepreciationMethod.none;
}

class FixedAssetsResponse {
  final List<FixedAsset> assets;
  final PaginationInfo pagination;

  FixedAssetsResponse({
    required this.assets,
    required this.pagination,
  });

  factory FixedAssetsResponse.fromJson(Map<String, dynamic> json) {
    return FixedAssetsResponse(
      assets: (json['assets'] as List<dynamic>)
          .map((asset) => FixedAsset.fromJson(asset))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class DepreciationResult {
  final FixedAsset asset;
  final double depreciationAmount;
  final double newBookValue;
  final double newAccumulatedDepreciation;

  DepreciationResult({
    required this.asset,
    required this.depreciationAmount,
    required this.newBookValue,
    required this.newAccumulatedDepreciation,
  });

  factory DepreciationResult.fromJson(Map<String, dynamic> json) {
    return DepreciationResult(
      asset: FixedAsset.fromJson(json['asset']),
      depreciationAmount: (json['depreciationAmount'] as num).toDouble(),
      newBookValue: (json['newBookValue'] as num).toDouble(),
      newAccumulatedDepreciation:
      (json['newAccumulatedDepreciation'] as num).toDouble(),
    );
  }
}

class DepreciationSchedule {
  final Map<String, dynamic> asset;
  final List<Map<String, dynamic>> schedule;

  DepreciationSchedule({
    required this.asset,
    required this.schedule,
  });

  factory DepreciationSchedule.fromJson(Map<String, dynamic> json) {
    return DepreciationSchedule(
      asset: Map<String, dynamic>.from(json['asset']),
      schedule: (json['schedule'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }
}

class FixedAssetsSummary {
  final int totalAssets;
  final double totalAcquisitionCost;
  final double totalBookValue;
  final double totalDepreciation;
  final Map<String, dynamic> byCategory;
  final Map<String, dynamic> byStatus;
  final Map<String, dynamic> byDepartment;
  final double depreciationRate;

  FixedAssetsSummary({
    required this.totalAssets,
    required this.totalAcquisitionCost,
    required this.totalBookValue,
    required this.totalDepreciation,
    required this.byCategory,
    required this.byStatus,
    required this.byDepartment,
    required this.depreciationRate,
  });

  factory FixedAssetsSummary.fromJson(Map<String, dynamic> json) {
    return FixedAssetsSummary(
      totalAssets: json['totalAssets'],
      totalAcquisitionCost: (json['totalAcquisitionCost'] as num).toDouble(),
      totalBookValue: (json['totalBookValue'] as num).toDouble(),
      totalDepreciation: (json['totalDepreciation'] as num).toDouble(),
      byCategory: Map<String, dynamic>.from(json['byCategory']),
      byStatus: Map<String, dynamic>.from(json['byStatus']),
      byDepartment: Map<String, dynamic>.from(json['byDepartment']),
      depreciationRate: (json['depreciationRate'] as num).toDouble(),
    );
  }
}