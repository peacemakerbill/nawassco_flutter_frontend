import 'package:flutter/foundation.dart';

class Warehouse {
  final String id;
  final String warehouseCode;
  final String warehouseName;
  final String description;
  final WarehouseAddress address;
  final WarehouseCoordinates coordinates;
  final WarehouseContact contactInformation;
  final WarehouseCapacity capacity;
  final WarehouseLayout layout;
  final List<WarehouseZone> zones;
  final List<StorageType> storageTypes;
  final OperatingHours operatingHours;
  final List<HandlingEquipment> handlingEquipment;
  final SecurityMeasures security;
  final String warehouseManager;
  final List<WarehouseStaff> staff;
  final WarehousePerformance performance;
  final UtilizationMetrics utilization;
  final List<WarehouseService> services;
  final List<ValueAddedService> valueAddedServices;
  final List<WarehouseCertification> certifications;
  final ComplianceStatus compliance;
  final WarehouseStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warehouse({
    required this.id,
    required this.warehouseCode,
    required this.warehouseName,
    required this.description,
    required this.address,
    required this.coordinates,
    required this.contactInformation,
    required this.capacity,
    required this.layout,
    required this.zones,
    required this.storageTypes,
    required this.operatingHours,
    required this.handlingEquipment,
    required this.security,
    required this.warehouseManager,
    required this.staff,
    required this.performance,
    required this.utilization,
    required this.services,
    required this.valueAddedServices,
    required this.certifications,
    required this.compliance,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['_id'] ?? json['id'] ?? '',
      warehouseCode: json['warehouseCode'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      description: json['description'] ?? '',
      address: WarehouseAddress.fromJson(json['address'] ?? {}),
      coordinates: WarehouseCoordinates.fromJson(json['coordinates'] ?? {}),
      contactInformation: WarehouseContact.fromJson(json['contactInformation'] ?? {}),
      capacity: WarehouseCapacity.fromJson(json['capacity'] ?? {}),
      layout: WarehouseLayout.fromJson(json['layout'] ?? {}),
      zones: List<WarehouseZone>.from(
        (json['zones'] ?? []).map((x) => WarehouseZone.fromJson(x)),
      ),
      storageTypes: List<StorageType>.from(
        (json['storageTypes'] ?? []).map((x) => StorageType.fromJson(x)),
      ),
      operatingHours: OperatingHours.fromJson(json['operatingHours'] ?? {}),
      handlingEquipment: List<HandlingEquipment>.from(
        (json['handlingEquipment'] ?? []).map((x) => HandlingEquipment.fromJson(x)),
      ),
      security: SecurityMeasures.fromJson(json['security'] ?? {}),
      warehouseManager: json['warehouseManager']?['_id'] ?? json['warehouseManager'] ?? '',
      staff: List<WarehouseStaff>.from(
        (json['staff'] ?? []).map((x) => WarehouseStaff.fromJson(x)),
      ),
      performance: WarehousePerformance.fromJson(json['performance'] ?? {}),
      utilization: UtilizationMetrics.fromJson(json['utilization'] ?? {}),
      services: List<WarehouseService>.from(
        (json['services'] ?? []).map((x) => WarehouseService.fromJson(x)),
      ),
      valueAddedServices: List<ValueAddedService>.from(
        (json['valueAddedServices'] ?? []).map((x) => ValueAddedService.fromJson(x)),
      ),
      certifications: List<WarehouseCertification>.from(
        (json['certifications'] ?? []).map((x) => WarehouseCertification.fromJson(x)),
      ),
      compliance: ComplianceStatus.fromJson(json['compliance'] ?? {}),
      status: WarehouseStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'operational'),
        orElse: () => WarehouseStatus.OPERATIONAL,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseCode': warehouseCode,
      'warehouseName': warehouseName,
      'description': description,
      'address': address.toJson(),
      'coordinates': coordinates.toJson(),
      'contactInformation': contactInformation.toJson(),
      'capacity': capacity.toJson(),
      'layout': layout.toJson(),
      'zones': zones.map((x) => x.toJson()).toList(),
      'storageTypes': storageTypes.map((x) => x.toJson()).toList(),
      'operatingHours': operatingHours.toJson(),
      'handlingEquipment': handlingEquipment.map((x) => x.toJson()).toList(),
      'security': security.toJson(),
      'warehouseManager': warehouseManager,
      'staff': staff.map((x) => x.toJson()).toList(),
      'performance': performance.toJson(),
      'utilization': utilization.toJson(),
      'services': services.map((x) => x.toJson()).toList(),
      'valueAddedServices': valueAddedServices.map((x) => x.toJson()).toList(),
      'certifications': certifications.map((x) => x.toJson()).toList(),
      'compliance': compliance.toJson(),
      'status': status.name,
      'isActive': isActive,
    };
  }

  Warehouse copyWith({
    String? warehouseCode,
    String? warehouseName,
    String? description,
    WarehouseAddress? address,
    WarehouseCoordinates? coordinates,
    WarehouseContact? contactInformation,
    WarehouseCapacity? capacity,
    WarehouseLayout? layout,
    List<WarehouseZone>? zones,
    List<StorageType>? storageTypes,
    OperatingHours? operatingHours,
    List<HandlingEquipment>? handlingEquipment,
    SecurityMeasures? security,
    String? warehouseManager,
    List<WarehouseStaff>? staff,
    WarehousePerformance? performance,
    UtilizationMetrics? utilization,
    List<WarehouseService>? services,
    List<ValueAddedService>? valueAddedServices,
    List<WarehouseCertification>? certifications,
    ComplianceStatus? compliance,
    WarehouseStatus? status,
    bool? isActive,
  }) {
    return Warehouse(
      id: id,
      warehouseCode: warehouseCode ?? this.warehouseCode,
      warehouseName: warehouseName ?? this.warehouseName,
      description: description ?? this.description,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      contactInformation: contactInformation ?? this.contactInformation,
      capacity: capacity ?? this.capacity,
      layout: layout ?? this.layout,
      zones: zones ?? this.zones,
      storageTypes: storageTypes ?? this.storageTypes,
      operatingHours: operatingHours ?? this.operatingHours,
      handlingEquipment: handlingEquipment ?? this.handlingEquipment,
      security: security ?? this.security,
      warehouseManager: warehouseManager ?? this.warehouseManager,
      staff: staff ?? this.staff,
      performance: performance ?? this.performance,
      utilization: utilization ?? this.utilization,
      services: services ?? this.services,
      valueAddedServices: valueAddedServices ?? this.valueAddedServices,
      certifications: certifications ?? this.certifications,
      compliance: compliance ?? this.compliance,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class WarehouseAddress {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  WarehouseAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory WarehouseAddress.fromJson(Map<String, dynamic> json) {
    return WarehouseAddress(
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class WarehouseCoordinates {
  final double latitude;
  final double longitude;

  WarehouseCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory WarehouseCoordinates.fromJson(Map<String, dynamic> json) {
    return WarehouseCoordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class WarehouseContact {
  final String phone;
  final String email;
  final String? fax;
  final String emergencyContact;

  WarehouseContact({
    required this.phone,
    required this.email,
    this.fax,
    required this.emergencyContact,
  });

  factory WarehouseContact.fromJson(Map<String, dynamic> json) {
    return WarehouseContact(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      fax: json['fax'],
      emergencyContact: json['emergencyContact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      if (fax != null) 'fax': fax,
      'emergencyContact': emergencyContact,
    };
  }
}

class WarehouseCapacity {
  final double totalArea;
  final double usableArea;
  final double storageCapacity;
  final int palletPositions;
  final double currentUtilization;

  WarehouseCapacity({
    required this.totalArea,
    required this.usableArea,
    required this.storageCapacity,
    required this.palletPositions,
    required this.currentUtilization,
  });

  factory WarehouseCapacity.fromJson(Map<String, dynamic> json) {
    return WarehouseCapacity(
      totalArea: (json['totalArea'] ?? 0.0).toDouble(),
      usableArea: (json['usableArea'] ?? 0.0).toDouble(),
      storageCapacity: (json['storageCapacity'] ?? 0.0).toDouble(),
      palletPositions: json['palletPositions'] ?? 0,
      currentUtilization: (json['currentUtilization'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalArea': totalArea,
      'usableArea': usableArea,
      'storageCapacity': storageCapacity,
      'palletPositions': palletPositions,
      'currentUtilization': currentUtilization,
    };
  }
}

class WarehouseLayout {
  final LayoutType layoutType;
  final int aisles;
  final int racks;
  final int loadingBays;
  final String? layoutMap;

  WarehouseLayout({
    required this.layoutType,
    required this.aisles,
    required this.racks,
    required this.loadingBays,
    this.layoutMap,
  });

  factory WarehouseLayout.fromJson(Map<String, dynamic> json) {
    return WarehouseLayout(
      layoutType: LayoutType.values.firstWhere(
            (e) => e.name == (json['layoutType'] ?? 'single_story'),
        orElse: () => LayoutType.SINGLE_STORY,
      ),
      aisles: json['aisles'] ?? 0,
      racks: json['racks'] ?? 0,
      loadingBays: json['loadingBays'] ?? 0,
      layoutMap: json['layoutMap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layoutType': layoutType.name,
      'aisles': aisles,
      'racks': racks,
      'loadingBays': loadingBays,
      if (layoutMap != null) 'layoutMap': layoutMap,
    };
  }
}

class WarehouseZone {
  final String zoneCode;
  final String zoneName;
  final ZoneType zoneType;
  final String? temperatureRange;
  final String? humidityRange;
  final double capacity;
  final double currentUtilization;
  final SecurityLevel securityLevel;

  WarehouseZone({
    required this.zoneCode,
    required this.zoneName,
    required this.zoneType,
    this.temperatureRange,
    this.humidityRange,
    required this.capacity,
    required this.currentUtilization,
    required this.securityLevel,
  });

  factory WarehouseZone.fromJson(Map<String, dynamic> json) {
    return WarehouseZone(
      zoneCode: json['zoneCode'] ?? '',
      zoneName: json['zoneName'] ?? '',
      zoneType: ZoneType.values.firstWhere(
            (e) => e.name == (json['zoneType'] ?? 'bulk_storage'),
        orElse: () => ZoneType.BULK_STORAGE,
      ),
      temperatureRange: json['temperatureRange'],
      humidityRange: json['humidityRange'],
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      currentUtilization: (json['currentUtilization'] ?? 0.0).toDouble(),
      securityLevel: SecurityLevel.values.firstWhere(
            (e) => e.name == (json['securityLevel'] ?? 'medium'),
        orElse: () => SecurityLevel.MEDIUM,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneCode': zoneCode,
      'zoneName': zoneName,
      'zoneType': zoneType.name,
      if (temperatureRange != null) 'temperatureRange': temperatureRange,
      if (humidityRange != null) 'humidityRange': humidityRange,
      'capacity': capacity,
      'currentUtilization': currentUtilization,
      'securityLevel': securityLevel.name,
    };
  }
}

class StorageType {
  final String type;
  final String description;
  final double capacity;
  final double currentUsage;

  StorageType({
    required this.type,
    required this.description,
    required this.capacity,
    required this.currentUsage,
  });

  factory StorageType.fromJson(Map<String, dynamic> json) {
    return StorageType(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      currentUsage: (json['currentUsage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'capacity': capacity,
      'currentUsage': currentUsage,
    };
  }
}

class OperatingHours {
  final TimeSlot monday;
  final TimeSlot tuesday;
  final TimeSlot wednesday;
  final TimeSlot thursday;
  final TimeSlot friday;
  final TimeSlot saturday;
  final TimeSlot sunday;
  final List<String> holidays;

  OperatingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.holidays,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      monday: TimeSlot.fromJson(json['Monday'] ?? {}),
      tuesday: TimeSlot.fromJson(json['Tuesday'] ?? {}),
      wednesday: TimeSlot.fromJson(json['Wednesday'] ?? {}),
      thursday: TimeSlot.fromJson(json['Thursday'] ?? {}),
      friday: TimeSlot.fromJson(json['Friday'] ?? {}),
      saturday: TimeSlot.fromJson(json['Saturday'] ?? {}),
      sunday: TimeSlot.fromJson(json['Sunday'] ?? {}),
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Monday': monday.toJson(),
      'Tuesday': tuesday.toJson(),
      'Wednesday': wednesday.toJson(),
      'Thursday': thursday.toJson(),
      'Friday': friday.toJson(),
      'Saturday': saturday.toJson(),
      'Sunday': sunday.toJson(),
      'holidays': holidays,
    };
  }
}

class TimeSlot {
  final bool open;
  final String? openingTime;
  final String? closingTime;

  TimeSlot({
    required this.open,
    this.openingTime,
    this.closingTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      open: json['open'] ?? true,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      if (openingTime != null) 'openingTime': openingTime,
      if (closingTime != null) 'closingTime': closingTime,
    };
  }
}

class HandlingEquipment {
  final String equipment;
  final EquipmentType type;
  final int quantity;
  final double capacity;
  final EquipmentStatus status;
  final DateTime lastMaintenance;

  HandlingEquipment({
    required this.equipment,
    required this.type,
    required this.quantity,
    required this.capacity,
    required this.status,
    required this.lastMaintenance,
  });

  factory HandlingEquipment.fromJson(Map<String, dynamic> json) {
    return HandlingEquipment(
      equipment: json['equipment'] ?? '',
      type: EquipmentType.values.firstWhere(
            (e) => e.name == (json['type'] ?? 'forklift'),
        orElse: () => EquipmentType.FORKLIFT,
      ),
      quantity: json['quantity'] ?? 0,
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      status: EquipmentStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'operational'),
        orElse: () => EquipmentStatus.OPERATIONAL,
      ),
      lastMaintenance: DateTime.parse(json['lastMaintenance'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'type': type.name,
      'quantity': quantity,
      'capacity': capacity,
      'status': status.name,
      'lastMaintenance': lastMaintenance.toIso8601String(),
    };
  }
}

class SecurityMeasures {
  final List<String> accessControl;
  final List<String> surveillance;
  final List<String> alarmSystems;
  final List<String> fireProtection;
  final int securityPersonnel;

  SecurityMeasures({
    required this.accessControl,
    required this.surveillance,
    required this.alarmSystems,
    required this.fireProtection,
    required this.securityPersonnel,
  });

  factory SecurityMeasures.fromJson(Map<String, dynamic> json) {
    return SecurityMeasures(
      accessControl: List<String>.from(json['accessControl'] ?? []),
      surveillance: List<String>.from(json['surveillance'] ?? []),
      alarmSystems: List<String>.from(json['alarmSystems'] ?? []),
      fireProtection: List<String>.from(json['fireProtection'] ?? []),
      securityPersonnel: json['securityPersonnel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessControl': accessControl,
      'surveillance': surveillance,
      'alarmSystems': alarmSystems,
      'fireProtection': fireProtection,
      'securityPersonnel': securityPersonnel,
    };
  }
}

class WarehouseStaff {
  final String staff;
  final WarehouseRole role;
  final String shift;
  final List<String> skills;

  WarehouseStaff({
    required this.staff,
    required this.role,
    required this.shift,
    required this.skills,
  });

  factory WarehouseStaff.fromJson(Map<String, dynamic> json) {
    return WarehouseStaff(
      staff: json['staff']?['_id'] ?? json['staff'] ?? '',
      role: WarehouseRole.values.firstWhere(
            (e) => e.name == (json['role'] ?? 'operator'),
        orElse: () => WarehouseRole.OPERATOR,
      ),
      shift: json['shift'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff': staff,
      'role': role.name,
      'shift': shift,
      'skills': skills,
    };
  }
}

class WarehousePerformance {
  final double orderAccuracy;
  final double pickingEfficiency;
  final double shippingAccuracy;
  final double damageRate;
  final double turnaroundTime;

  WarehousePerformance({
    required this.orderAccuracy,
    required this.pickingEfficiency,
    required this.shippingAccuracy,
    required this.damageRate,
    required this.turnaroundTime,
  });

  factory WarehousePerformance.fromJson(Map<String, dynamic> json) {
    return WarehousePerformance(
      orderAccuracy: (json['orderAccuracy'] ?? 0.0).toDouble(),
      pickingEfficiency: (json['pickingEfficiency'] ?? 0.0).toDouble(),
      shippingAccuracy: (json['shippingAccuracy'] ?? 0.0).toDouble(),
      damageRate: (json['damageRate'] ?? 0.0).toDouble(),
      turnaroundTime: (json['turnaroundTime'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderAccuracy': orderAccuracy,
      'pickingEfficiency': pickingEfficiency,
      'shippingAccuracy': shippingAccuracy,
      'damageRate': damageRate,
      'turnaroundTime': turnaroundTime,
    };
  }
}

class UtilizationMetrics {
  final double spaceUtilization;
  final double equipmentUtilization;
  final double laborUtilization;
  final double throughput;

  UtilizationMetrics({
    required this.spaceUtilization,
    required this.equipmentUtilization,
    required this.laborUtilization,
    required this.throughput,
  });

  factory UtilizationMetrics.fromJson(Map<String, dynamic> json) {
    return UtilizationMetrics(
      spaceUtilization: (json['spaceUtilization'] ?? 0.0).toDouble(),
      equipmentUtilization: (json['equipmentUtilization'] ?? 0.0).toDouble(),
      laborUtilization: (json['laborUtilization'] ?? 0.0).toDouble(),
      throughput: (json['throughput'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spaceUtilization': spaceUtilization,
      'equipmentUtilization': equipmentUtilization,
      'laborUtilization': laborUtilization,
      'throughput': throughput,
    };
  }
}

class WarehouseService {
  final String service;
  final String description;
  final double capacity;
  final ServiceStatus status;

  WarehouseService({
    required this.service,
    required this.description,
    required this.capacity,
    required this.status,
  });

  factory WarehouseService.fromJson(Map<String, dynamic> json) {
    return WarehouseService(
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      status: ServiceStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'available'),
        orElse: () => ServiceStatus.AVAILABLE,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'description': description,
      'capacity': capacity,
      'status': status.name,
    };
  }
}

class ValueAddedService {
  final String service;
  final String description;
  final double additionalCost;
  final bool availability;

  ValueAddedService({
    required this.service,
    required this.description,
    required this.additionalCost,
    required this.availability,
  });

  factory ValueAddedService.fromJson(Map<String, dynamic> json) {
    return ValueAddedService(
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      additionalCost: (json['additionalCost'] ?? 0.0).toDouble(),
      availability: json['availability'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'description': description,
      'additionalCost': additionalCost,
      'availability': availability,
    };
  }
}

class WarehouseCertification {
  final String certification;
  final String issuingBody;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String documentUrl;
  final CertificationStatus status;

  WarehouseCertification({
    required this.certification,
    required this.issuingBody,
    required this.issueDate,
    required this.expiryDate,
    required this.documentUrl,
    required this.status,
  });

  factory WarehouseCertification.fromJson(Map<String, dynamic> json) {
    return WarehouseCertification(
      certification: json['certification'] ?? '',
      issuingBody: json['issuingBody'] ?? '',
      issueDate: DateTime.parse(json['issueDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
      documentUrl: json['documentUrl'] ?? '',
      status: CertificationStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'valid'),
        orElse: () => CertificationStatus.VALID,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certification': certification,
      'issuingBody': issuingBody,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'documentUrl': documentUrl,
      'status': status.name,
    };
  }
}

class ComplianceStatus {
  final ComplianceLevel safetyCompliance;
  final ComplianceLevel environmentalCompliance;
  final ComplianceLevel qualityCompliance;
  final DateTime lastAuditDate;
  final DateTime nextAuditDate;

  ComplianceStatus({
    required this.safetyCompliance,
    required this.environmentalCompliance,
    required this.qualityCompliance,
    required this.lastAuditDate,
    required this.nextAuditDate,
  });

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) {
    return ComplianceStatus(
      safetyCompliance: ComplianceLevel.values.firstWhere(
            (e) => e.name == (json['safetyCompliance'] ?? 'full_compliance'),
        orElse: () => ComplianceLevel.FULL_COMPLIANCE,
      ),
      environmentalCompliance: ComplianceLevel.values.firstWhere(
            (e) => e.name == (json['environmentalCompliance'] ?? 'full_compliance'),
        orElse: () => ComplianceLevel.FULL_COMPLIANCE,
      ),
      qualityCompliance: ComplianceLevel.values.firstWhere(
            (e) => e.name == (json['qualityCompliance'] ?? 'full_compliance'),
        orElse: () => ComplianceLevel.FULL_COMPLIANCE,
      ),
      lastAuditDate: DateTime.parse(json['lastAuditDate'] ?? DateTime.now().toIso8601String()),
      nextAuditDate: DateTime.parse(json['nextAuditDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyCompliance': safetyCompliance.name,
      'environmentalCompliance': environmentalCompliance.name,
      'qualityCompliance': qualityCompliance.name,
      'lastAuditDate': lastAuditDate.toIso8601String(),
      'nextAuditDate': nextAuditDate.toIso8601String(),
    };
  }
}

enum LayoutType {
  SINGLE_STORY,
  MULTI_STORY,
  RACKED,
  BULK_STORAGE,
  AUTOMATED
}

enum ZoneType {
  BULK_STORAGE,
  RACK_STORAGE,
  COLD_STORAGE,
  HAZARDOUS,
  PICKING,
  RECEIVING,
  DISPATCH,
  QUARANTINE
}

enum SecurityLevel {
  LOW,
  MEDIUM,
  HIGH,
  MAXIMUM
}

enum EquipmentType {
  FORKLIFT,
  PALLET_JACK,
  CONVEYOR,
  CRANE,
  SORTER,
  PICKING_CART
}

enum EquipmentStatus {
  OPERATIONAL,
  UNDER_MAINTENANCE,
  OUT_OF_SERVICE
}

enum WarehouseRole {
  MANAGER,
  SUPERVISOR,
  OPERATOR,
  PICKER,
  PACKER,
  RECEIVING_CLERK,
  SECURITY
}

enum ServiceStatus {
  AVAILABLE,
  LIMITED,
  UNAVAILABLE
}

enum CertificationStatus {
  VALID,
  EXPIRED,
  PENDING_RENEWAL
}

enum ComplianceLevel {
  FULL_COMPLIANCE,
  PARTIAL_COMPLIANCE,
  NON_COMPLIANCE
}

enum WarehouseStatus {
  OPERATIONAL,
  UNDER_MAINTENANCE,
  CLOSED,
  UNDER_CONSTRUCTION
}