import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ToolType {
  handTool('Hand Tool', Icons.build, Colors.blue),
  powerTool('Power Tool', Icons.power, Colors.orange),
  measuringTool('Measuring Tool', Icons.straighten, Colors.green),
  testingEquipment('Testing Equipment', Icons.analytics, Colors.purple),
  safetyEquipment('Safety Equipment', Icons.security, Colors.red),
  specializedEquipment(
      'Specialized Equipment', Icons.precision_manufacturing, Colors.teal);

  final String displayName;
  final IconData icon;
  final Color color;

  const ToolType(this.displayName, this.icon, this.color);
}

enum ToolStatus {
  available('Available', Icons.check_circle, Colors.green),
  inUse('In Use', Icons.person, Colors.blue),
  underMaintenance('Under Maintenance', Icons.build_circle, Colors.orange),
  reserved('Reserved', Icons.schedule, Colors.purple),
  outOfService('Out of Service', Icons.warning, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const ToolStatus(this.displayName, this.icon, this.color);
}

enum RiskLevel {
  low('Low', Colors.green),
  medium('Medium', Colors.orange),
  high('High', Colors.red);

  final String displayName;
  final Color color;

  const RiskLevel(this.displayName, this.color);
}

class ToolSpecification extends Equatable {
  final String parameter;
  final String value;
  final String unit;

  const ToolSpecification({
    required this.parameter,
    required this.value,
    required this.unit,
  });

  factory ToolSpecification.fromJson(Map<String, dynamic> json) {
    return ToolSpecification(
      parameter: json['parameter'],
      value: json['value'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [parameter, value, unit];
}

class ToolMaintenance extends Equatable {
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final int maintenanceInterval;
  final List<String> maintenanceTasks;

  const ToolMaintenance({
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.maintenanceInterval,
    required this.maintenanceTasks,
  });

  factory ToolMaintenance.fromJson(Map<String, dynamic> json) {
    return ToolMaintenance(
      lastMaintenanceDate: DateTime.parse(json['lastMaintenanceDate']),
      nextMaintenanceDate: DateTime.parse(json['nextMaintenanceDate']),
      maintenanceInterval: json['maintenanceInterval'],
      maintenanceTasks: List<String>.from(json['maintenanceTasks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastMaintenanceDate': lastMaintenanceDate.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate.toIso8601String(),
      'maintenanceInterval': maintenanceInterval,
      'maintenanceTasks': maintenanceTasks,
    };
  }

  @override
  List<Object?> get props => [
        lastMaintenanceDate,
        nextMaintenanceDate,
        maintenanceInterval,
        maintenanceTasks,
      ];
}

class ToolServiceRecord extends Equatable {
  final DateTime serviceDate;
  final String serviceType;
  final String description;
  final double cost;
  final String serviceProvider;
  final DateTime nextServiceDate;

  const ToolServiceRecord({
    required this.serviceDate,
    required this.serviceType,
    required this.description,
    required this.cost,
    required this.serviceProvider,
    required this.nextServiceDate,
  });

  factory ToolServiceRecord.fromJson(Map<String, dynamic> json) {
    return ToolServiceRecord(
      serviceDate: DateTime.parse(json['serviceDate']),
      serviceType: json['serviceType'],
      description: json['description'],
      cost: (json['cost'] as num).toDouble(),
      serviceProvider: json['serviceProvider'],
      nextServiceDate: DateTime.parse(json['nextServiceDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceDate': serviceDate.toIso8601String(),
      'serviceType': serviceType,
      'description': description,
      'cost': cost,
      'serviceProvider': serviceProvider,
      'nextServiceDate': nextServiceDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        serviceDate,
        serviceType,
        description,
        cost,
        serviceProvider,
        nextServiceDate,
      ];
}

class CalibrationRecord extends Equatable {
  final DateTime calibrationDate;
  final DateTime nextCalibrationDate;
  final String calibratedBy;
  final String certificateNumber;
  final String accuracy;
  final String documentUrl;

  const CalibrationRecord({
    required this.calibrationDate,
    required this.nextCalibrationDate,
    required this.calibratedBy,
    required this.certificateNumber,
    required this.accuracy,
    required this.documentUrl,
  });

  factory CalibrationRecord.fromJson(Map<String, dynamic> json) {
    return CalibrationRecord(
      calibrationDate: DateTime.parse(json['calibrationDate']),
      nextCalibrationDate: DateTime.parse(json['nextCalibrationDate']),
      calibratedBy: json['calibratedBy'],
      certificateNumber: json['certificateNumber'],
      accuracy: json['accuracy'],
      documentUrl: json['documentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calibrationDate': calibrationDate.toIso8601String(),
      'nextCalibrationDate': nextCalibrationDate.toIso8601String(),
      'calibratedBy': calibratedBy,
      'certificateNumber': certificateNumber,
      'accuracy': accuracy,
      'documentUrl': documentUrl,
    };
  }

  @override
  List<Object?> get props => [
        calibrationDate,
        nextCalibrationDate,
        calibratedBy,
        certificateNumber,
        accuracy,
        documentUrl,
      ];
}

class Tool extends Equatable {
  final String id;
  final String toolCode;
  final String toolName;
  final String description;
  final ToolType toolType;
  final String category;
  final String brand;
  final String toolModel;
  final String serialNumber;
  final List<ToolSpecification> specifications;
  final ToolStatus currentStatus;
  final String currentLocation;
  final String? currentHolder;
  final ToolMaintenance maintenanceSchedule;
  final List<ToolServiceRecord> serviceHistory;
  final List<CalibrationRecord> calibrationHistory;
  final double totalUsageHours;
  final DateTime? lastUsed;
  final int usageCount;
  final double purchasePrice;
  final double currentValue;
  final double maintenanceCost;
  final List<String> safetyInstructions;
  final bool requiresTraining;
  final RiskLevel riskLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tool({
    required this.id,
    required this.toolCode,
    required this.toolName,
    required this.description,
    required this.toolType,
    required this.category,
    required this.brand,
    required this.toolModel,
    required this.serialNumber,
    required this.specifications,
    required this.currentStatus,
    required this.currentLocation,
    this.currentHolder,
    required this.maintenanceSchedule,
    required this.serviceHistory,
    required this.calibrationHistory,
    required this.totalUsageHours,
    this.lastUsed,
    required this.usageCount,
    required this.purchasePrice,
    required this.currentValue,
    required this.maintenanceCost,
    required this.safetyInstructions,
    required this.requiresTraining,
    required this.riskLevel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['_id'] ?? json['id'],
      toolCode: json['toolCode'],
      toolName: json['toolName'],
      description: json['description'],
      toolType: ToolType.values.firstWhere(
        (e) => e.name == json['toolType'],
        orElse: () => ToolType.handTool,
      ),
      category: json['category'],
      brand: json['brand'],
      toolModel: json['toolModel'],
      serialNumber: json['serialNumber'],
      specifications: (json['specifications'] as List?)
              ?.map((spec) => ToolSpecification.fromJson(spec))
              .toList() ??
          [],
      currentStatus: ToolStatus.values.firstWhere(
        (e) => e.name == json['currentStatus'],
        orElse: () => ToolStatus.available,
      ),
      currentLocation: json['currentLocation'],
      currentHolder: json['currentHolder']?['_id'] ?? json['currentHolder'],
      maintenanceSchedule:
          ToolMaintenance.fromJson(json['maintenanceSchedule']),
      serviceHistory: (json['serviceHistory'] as List?)
              ?.map((record) => ToolServiceRecord.fromJson(record))
              .toList() ??
          [],
      calibrationHistory: (json['calibrationHistory'] as List?)
              ?.map((record) => CalibrationRecord.fromJson(record))
              .toList() ??
          [],
      totalUsageHours: (json['totalUsageHours'] as num?)?.toDouble() ?? 0,
      lastUsed:
          json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
      usageCount: json['usageCount'] ?? 0,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      maintenanceCost: (json['maintenanceCost'] as num?)?.toDouble() ?? 0,
      safetyInstructions: List<String>.from(json['safetyInstructions'] ?? []),
      requiresTraining: json['requiresTraining'] ?? false,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolCode': toolCode,
      'toolName': toolName,
      'description': description,
      'toolType': toolType.name,
      'category': category,
      'brand': brand,
      'toolModel': toolModel,
      'serialNumber': serialNumber,
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'currentStatus': currentStatus.name,
      'currentLocation': currentLocation,
      'currentHolder': currentHolder,
      'maintenanceSchedule': maintenanceSchedule.toJson(),
      'serviceHistory':
          serviceHistory.map((record) => record.toJson()).toList(),
      'calibrationHistory':
          calibrationHistory.map((record) => record.toJson()).toList(),
      'totalUsageHours': totalUsageHours,
      'lastUsed': lastUsed?.toIso8601String(),
      'usageCount': usageCount,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'maintenanceCost': maintenanceCost,
      'safetyInstructions': safetyInstructions,
      'requiresTraining': requiresTraining,
      'riskLevel': riskLevel.name,
      'isActive': isActive,
    };
  }

  Tool copyWith({
    String? id,
    String? toolCode,
    String? toolName,
    String? description,
    ToolType? toolType,
    String? category,
    String? brand,
    String? toolModel,
    String? serialNumber,
    List<ToolSpecification>? specifications,
    ToolStatus? currentStatus,
    String? currentLocation,
    String? currentHolder,
    ToolMaintenance? maintenanceSchedule,
    List<ToolServiceRecord>? serviceHistory,
    List<CalibrationRecord>? calibrationHistory,
    double? totalUsageHours,
    DateTime? lastUsed,
    int? usageCount,
    double? purchasePrice,
    double? currentValue,
    double? maintenanceCost,
    List<String>? safetyInstructions,
    bool? requiresTraining,
    RiskLevel? riskLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tool(
      id: id ?? this.id,
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      description: description ?? this.description,
      toolType: toolType ?? this.toolType,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      toolModel: toolModel ?? this.toolModel,
      serialNumber: serialNumber ?? this.serialNumber,
      specifications: specifications ?? this.specifications,
      currentStatus: currentStatus ?? this.currentStatus,
      currentLocation: currentLocation ?? this.currentLocation,
      currentHolder: currentHolder ?? this.currentHolder,
      maintenanceSchedule: maintenanceSchedule ?? this.maintenanceSchedule,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      calibrationHistory: calibrationHistory ?? this.calibrationHistory,
      totalUsageHours: totalUsageHours ?? this.totalUsageHours,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      safetyInstructions: safetyInstructions ?? this.safetyInstructions,
      requiresTraining: requiresTraining ?? this.requiresTraining,
      riskLevel: riskLevel ?? this.riskLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get needsMaintenanceSoon {
    final daysUntilMaintenance = maintenanceSchedule.nextMaintenanceDate
        .difference(DateTime.now())
        .inDays;
    return daysUntilMaintenance <= 7;
  }

  bool get needsCalibrationSoon {
    for (final calibration in calibrationHistory) {
      final daysUntilCalibration =
          calibration.nextCalibrationDate.difference(DateTime.now()).inDays;
      if (daysUntilCalibration <= 30) return true;
    }
    return false;
  }

  double get depreciationRate {
    if (purchasePrice == 0) return 0;
    return ((purchasePrice - currentValue) / purchasePrice) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        toolCode,
        toolName,
        description,
        toolType,
        category,
        brand,
        toolModel,
        serialNumber,
        specifications,
        currentStatus,
        currentLocation,
        currentHolder,
        maintenanceSchedule,
        serviceHistory,
        calibrationHistory,
        totalUsageHours,
        lastUsed,
        usageCount,
        purchasePrice,
        currentValue,
        maintenanceCost,
        safetyInstructions,
        requiresTraining,
        riskLevel,
        isActive,
        createdAt,
        updatedAt,
      ];
}
