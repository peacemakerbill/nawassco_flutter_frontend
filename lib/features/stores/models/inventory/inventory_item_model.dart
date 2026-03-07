class InventoryItem {
  final String id;
  final String itemCode;
  final String itemName;
  final String description;
  final String category;
  final String subCategory;
  final String itemType;
  final String unitOfMeasure;
  final List<ItemSpecification> specifications;
  final List<TechnicalDetail> technicalDetails;
  final List<String> compatibility;
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final double reorderPoint;
  final double reorderQuantity;
  final double economicOrderQuantity;
  final StorageLocation storageLocation;
  final String binLocation;
  final List<StorageRequirement> storageRequirements;
  final double costPrice;
  final double sellingPrice;
  final double averageCost;
  final double lastPurchasePrice;
  final String currency;
  final String preferredSupplier;
  final List<String> alternativeSuppliers;
  final int leadTime;
  final double usageRate;
  final String movementClass;
  final DateTime? lastMovementDate;
  final double annualUsage;
  final List<QualityRequirement> qualityRequirements;
  final List<ItemCertification> certifications;
  final ExpiryManagement expiryManagement;
  final String status;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.itemType,
    required this.unitOfMeasure,
    required this.specifications,
    required this.technicalDetails,
    required this.compatibility,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.economicOrderQuantity,
    required this.storageLocation,
    required this.binLocation,
    required this.storageRequirements,
    required this.costPrice,
    required this.sellingPrice,
    required this.averageCost,
    required this.lastPurchasePrice,
    required this.currency,
    required this.preferredSupplier,
    required this.alternativeSuppliers,
    required this.leadTime,
    required this.usageRate,
    required this.movementClass,
    this.lastMovementDate,
    required this.annualUsage,
    required this.qualityRequirements,
    required this.certifications,
    required this.expiryManagement,
    required this.status,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['_id'] ?? json['id'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      description: json['description'],
      category: json['category'],
      subCategory: json['subCategory'],
      itemType: json['itemType'],
      unitOfMeasure: json['unitOfMeasure'],
      specifications: List<ItemSpecification>.from(
          (json['specifications'] ?? []).map((x) => ItemSpecification.fromJson(x))),
      technicalDetails: List<TechnicalDetail>.from(
          (json['technicalDetails'] ?? []).map((x) => TechnicalDetail.fromJson(x))),
      compatibility: List<String>.from(json['compatibility'] ?? []),
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      minimumStock: (json['minimumStock'] ?? 0).toDouble(),
      maximumStock: (json['maximumStock'] ?? 0).toDouble(),
      reorderPoint: (json['reorderPoint'] ?? 0).toDouble(),
      reorderQuantity: (json['reorderQuantity'] ?? 0).toDouble(),
      economicOrderQuantity: (json['economicOrderQuantity'] ?? 0).toDouble(),
      storageLocation: StorageLocation.fromJson(json['storageLocation']),
      binLocation: json['binLocation'],
      storageRequirements: List<StorageRequirement>.from(
          (json['storageRequirements'] ?? []).map((x) => StorageRequirement.fromJson(x))),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      averageCost: (json['averageCost'] ?? 0).toDouble(),
      lastPurchasePrice: (json['lastPurchasePrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      preferredSupplier: json['preferredSupplier'] is String
          ? json['preferredSupplier']
          : json['preferredSupplier']?['_id'],
      alternativeSuppliers: List<String>.from(
          (json['alternativeSuppliers'] ?? []).map((supplier) =>
          supplier is String ? supplier : supplier['_id'])),
      leadTime: json['leadTime'] ?? 0,
      usageRate: (json['usageRate'] ?? 0).toDouble(),
      movementClass: json['movementClass'],
      lastMovementDate: json['lastMovementDate'] != null
          ? DateTime.parse(json['lastMovementDate'])
          : null,
      annualUsage: (json['annualUsage'] ?? 0).toDouble(),
      qualityRequirements: List<QualityRequirement>.from(
          (json['qualityRequirements'] ?? []).map((x) => QualityRequirement.fromJson(x))),
      certifications: List<ItemCertification>.from(
          (json['certifications'] ?? []).map((x) => ItemCertification.fromJson(x))),
      expiryManagement: ExpiryManagement.fromJson(json['expiryManagement']),
      status: json['status'],
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] is String ? json['createdBy'] : json['createdBy']['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'itemType': itemType,
      'unitOfMeasure': unitOfMeasure,
      'specifications': specifications.map((x) => x.toJson()).toList(),
      'technicalDetails': technicalDetails.map((x) => x.toJson()).toList(),
      'compatibility': compatibility,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'reorderPoint': reorderPoint,
      'reorderQuantity': reorderQuantity,
      'economicOrderQuantity': economicOrderQuantity,
      'storageLocation': storageLocation.toJson(),
      'binLocation': binLocation,
      'storageRequirements': storageRequirements.map((x) => x.toJson()).toList(),
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'averageCost': averageCost,
      'lastPurchasePrice': lastPurchasePrice,
      'currency': currency,
      'preferredSupplier': preferredSupplier,
      'alternativeSuppliers': alternativeSuppliers,
      'leadTime': leadTime,
      'usageRate': usageRate,
      'movementClass': movementClass,
      'lastMovementDate': lastMovementDate?.toIso8601String(),
      'annualUsage': annualUsage,
      'qualityRequirements': qualityRequirements.map((x) => x.toJson()).toList(),
      'certifications': certifications.map((x) => x.toJson()).toList(),
      'expiryManagement': expiryManagement.toJson(),
      'status': status,
    };
  }

  bool get isLowStock => currentStock <= reorderPoint;
  bool get isCriticalStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock <= 0;
  double get stockValue => currentStock * averageCost;
  double get stockCover => usageRate > 0 ? currentStock / usageRate : 0;

  InventoryItem copyWith({
    String? itemCode,
    String? itemName,
    String? description,
    String? category,
    String? subCategory,
    String? itemType,
    String? unitOfMeasure,
    List<ItemSpecification>? specifications,
    List<TechnicalDetail>? technicalDetails,
    List<String>? compatibility,
    double? currentStock,
    double? minimumStock,
    double? maximumStock,
    double? reorderPoint,
    double? reorderQuantity,
    double? economicOrderQuantity,
    StorageLocation? storageLocation,
    String? binLocation,
    List<StorageRequirement>? storageRequirements,
    double? costPrice,
    double? sellingPrice,
    double? averageCost,
    double? lastPurchasePrice,
    String? currency,
    String? preferredSupplier,
    List<String>? alternativeSuppliers,
    int? leadTime,
    double? usageRate,
    String? movementClass,
    DateTime? lastMovementDate,
    double? annualUsage,
    List<QualityRequirement>? qualityRequirements,
    List<ItemCertification>? certifications,
    ExpiryManagement? expiryManagement,
    String? status,
    bool? isActive,
  }) {
    return InventoryItem(
      id: id,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      itemType: itemType ?? this.itemType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      specifications: specifications ?? this.specifications,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      compatibility: compatibility ?? this.compatibility,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      economicOrderQuantity: economicOrderQuantity ?? this.economicOrderQuantity,
      storageLocation: storageLocation ?? this.storageLocation,
      binLocation: binLocation ?? this.binLocation,
      storageRequirements: storageRequirements ?? this.storageRequirements,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      averageCost: averageCost ?? this.averageCost,
      lastPurchasePrice: lastPurchasePrice ?? this.lastPurchasePrice,
      currency: currency ?? this.currency,
      preferredSupplier: preferredSupplier ?? this.preferredSupplier,
      alternativeSuppliers: alternativeSuppliers ?? this.alternativeSuppliers,
      leadTime: leadTime ?? this.leadTime,
      usageRate: usageRate ?? this.usageRate,
      movementClass: movementClass ?? this.movementClass,
      lastMovementDate: lastMovementDate ?? this.lastMovementDate,
      annualUsage: annualUsage ?? this.annualUsage,
      qualityRequirements: qualityRequirements ?? this.qualityRequirements,
      certifications: certifications ?? this.certifications,
      expiryManagement: expiryManagement ?? this.expiryManagement,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Sub-models
class ItemSpecification {
  final String parameter;
  final String value;
  final String unit;
  final String? tolerance;

  ItemSpecification({
    required this.parameter,
    required this.value,
    required this.unit,
    this.tolerance,
  });

  factory ItemSpecification.fromJson(Map<String, dynamic> json) {
    return ItemSpecification(
      parameter: json['parameter'],
      value: json['value'],
      unit: json['unit'],
      tolerance: json['tolerance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'unit': unit,
      if (tolerance != null) 'tolerance': tolerance,
    };
  }
}

class TechnicalDetail {
  final String aspect;
  final String description;
  final List<String> standards;

  TechnicalDetail({
    required this.aspect,
    required this.description,
    required this.standards,
  });

  factory TechnicalDetail.fromJson(Map<String, dynamic> json) {
    return TechnicalDetail(
      aspect: json['aspect'],
      description: json['description'],
      standards: List<String>.from(json['standards'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'description': description,
      'standards': standards,
    };
  }
}

class StorageLocation {
  final String warehouse;
  final String zone;
  final String rack;
  final String shelf;
  final String position;

  StorageLocation({
    required this.warehouse,
    required this.zone,
    required this.rack,
    required this.shelf,
    required this.position,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    return StorageLocation(
      warehouse: json['warehouse'],
      zone: json['zone'],
      rack: json['rack'],
      shelf: json['shelf'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse': warehouse,
      'zone': zone,
      'rack': rack,
      'shelf': shelf,
      'position': position,
    };
  }

  String get fullLocation => '$warehouse > $zone > $rack > $shelf > $position';
}

class StorageRequirement {
  final String requirement;
  final String value;
  final bool critical;

  StorageRequirement({
    required this.requirement,
    required this.value,
    required this.critical,
  });

  factory StorageRequirement.fromJson(Map<String, dynamic> json) {
    return StorageRequirement(
      requirement: json['requirement'],
      value: json['value'],
      critical: json['critical'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'value': value,
      'critical': critical,
    };
  }
}

class QualityRequirement {
  final String requirement;
  final String standard;
  final String testMethod;
  final String frequency;

  QualityRequirement({
    required this.requirement,
    required this.standard,
    required this.testMethod,
    required this.frequency,
  });

  factory QualityRequirement.fromJson(Map<String, dynamic> json) {
    return QualityRequirement(
      requirement: json['requirement'],
      standard: json['standard'],
      testMethod: json['testMethod'],
      frequency: json['frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'standard': standard,
      'testMethod': testMethod,
      'frequency': frequency,
    };
  }
}

class ItemCertification {
  final String certification;
  final String issuingBody;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String documentUrl;

  ItemCertification({
    required this.certification,
    required this.issuingBody,
    required this.certificateNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.documentUrl,
  });

  factory ItemCertification.fromJson(Map<String, dynamic> json) {
    return ItemCertification(
      certification: json['certification'],
      issuingBody: json['issuingBody'],
      certificateNumber: json['certificateNumber'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      documentUrl: json['documentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certification': certification,
      'issuingBody': issuingBody,
      'certificateNumber': certificateNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'documentUrl': documentUrl,
    };
  }

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon =>
      expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)));
}

class ExpiryManagement {
  final bool hasExpiry;
  final int shelfLife;
  final int alertBefore;
  final String? disposalMethod;

  ExpiryManagement({
    required this.hasExpiry,
    required this.shelfLife,
    required this.alertBefore,
    this.disposalMethod,
  });

  factory ExpiryManagement.fromJson(Map<String, dynamic> json) {
    return ExpiryManagement(
      hasExpiry: json['hasExpiry'] ?? false,
      shelfLife: json['shelfLife'] ?? 0,
      alertBefore: json['alertBefore'] ?? 30,
      disposalMethod: json['disposalMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasExpiry': hasExpiry,
      'shelfLife': shelfLife,
      'alertBefore': alertBefore,
      if (disposalMethod != null) 'disposalMethod': disposalMethod,
    };
  }
}

// Enums
enum InventoryCategoryEnum {
  pipesFittings('pipes_fittings', 'Pipes & Fittings'),
  valves('valves', 'Valves'),
  pumps('pumps', 'Pumps'),
  waterTreatmentChemicals('water_treatment_chemicals', 'Water Treatment Chemicals'),
  meters('meters', 'Meters'),
  toolsEquipment('tools_equipment', 'Tools & Equipment'),
  safetyEquipment('safety_equipment', 'Safety Equipment'),
  electrical('electrical', 'Electrical'),
  constructionMaterials('construction_materials', 'Construction Materials'),
  officeSupplies('office_supplies', 'Office Supplies'),
  vehicleParts('vehicle_parts', 'Vehicle Parts');

  final String value;
  final String displayName;
  const InventoryCategoryEnum(this.value, this.displayName);

  static InventoryCategoryEnum fromString(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => InventoryCategoryEnum.pipesFittings,
    );
  }
}

enum ItemType {
  rawMaterial('raw_material', 'Raw Material'),
  finishedGood('finished_good', 'Finished Good'),
  semiFinished('semi_finished', 'Semi-Finished'),
  consumable('consumable', 'Consumable'),
  sparePart('spare_part', 'Spare Part'),
  tool('tool', 'Tool'),
  equipment('equipment', 'Equipment');

  final String value;
  final String displayName;
  const ItemType(this.value, this.displayName);

  static ItemType fromString(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => ItemType.rawMaterial,
    );
  }
}

enum MovementClass {
  fastMoving('fast_moving', 'Fast Moving'),
  slowMoving('slow_moving', 'Slow Moving'),
  nonMoving('non_moving', 'Non Moving'),
  seasonal('seasonal', 'Seasonal');

  final String value;
  final String displayName;
  const MovementClass(this.value, this.displayName);

  static MovementClass fromString(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => MovementClass.slowMoving,
    );
  }
}

enum ItemStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive'),
  discontinued('discontinued', 'Discontinued'),
  obsolete('obsolete', 'Obsolete');

  final String value;
  final String displayName;
  const ItemStatus(this.value, this.displayName);

  static ItemStatus fromString(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => ItemStatus.active,
    );
  }
}