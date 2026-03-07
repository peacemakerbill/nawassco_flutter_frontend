import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WaterSource extends Equatable {
  final String id;
  final String name;
  final WaterSourceType type;
  final LocationInfo location;
  final CapacityInfo capacity;
  final QualityInfo quality;
  final SourceStatus status;
  final List<String> serviceAreas;
  final SourceInfrastructure infrastructure;
  final MonitoringInfo monitoring;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isFavorite;

  const WaterSource({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.capacity,
    required this.quality,
    required this.status,
    this.serviceAreas = const [],
    required this.infrastructure,
    required this.monitoring,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) {
    return WaterSource(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: WaterSourceType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => WaterSourceType.WELL,
      ),
      location: LocationInfo.fromJson(json['location'] ?? {}),
      capacity: CapacityInfo.fromJson(json['capacity'] ?? {}),
      quality: QualityInfo.fromJson(json['quality'] ?? {}),
      status: SourceStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => SourceStatus.OPERATIONAL,
      ),
      serviceAreas: List<String>.from(json['serviceAreas'] ?? []),
      infrastructure:
          SourceInfrastructure.fromJson(json['infrastructure'] ?? {}),
      monitoring: MonitoringInfo.fromJson(json['monitoring'] ?? {}),
      createdBy: json['createdBy']?['_id'] ?? json['createdBy'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      'location': location.toJson(),
      'capacity': capacity.toJson(),
      'quality': quality.toJson(),
      'status': status.value,
      'serviceAreas': serviceAreas,
      'infrastructure': infrastructure.toJson(),
      'monitoring': monitoring.toJson(),
    };
  }

  WaterSource copyWith({
    String? id,
    String? name,
    WaterSourceType? type,
    LocationInfo? location,
    CapacityInfo? capacity,
    QualityInfo? quality,
    SourceStatus? status,
    List<String>? serviceAreas,
    SourceInfrastructure? infrastructure,
    MonitoringInfo? monitoring,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return WaterSource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      quality: quality ?? this.quality,
      status: status ?? this.status,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      infrastructure: infrastructure ?? this.infrastructure,
      monitoring: monitoring ?? this.monitoring,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        location,
        capacity,
        quality,
        status,
        serviceAreas,
        infrastructure,
        monitoring,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

// Enums
enum WaterSourceType {
  BOREHOLE('borehole'),
  SURFACE_WATER('surface_water'),
  DAM('dam'),
  SPRING('spring'),
  LAKE('lake'),
  RIVER('river'),
  WELL('well');

  final String value;

  const WaterSourceType(this.value);

  String get displayName {
    switch (this) {
      case WaterSourceType.BOREHOLE:
        return 'Borehole';
      case WaterSourceType.SURFACE_WATER:
        return 'Surface Water';
      case WaterSourceType.DAM:
        return 'Dam';
      case WaterSourceType.SPRING:
        return 'Spring';
      case WaterSourceType.LAKE:
        return 'Lake';
      case WaterSourceType.RIVER:
        return 'River';
      case WaterSourceType.WELL:
        return 'Well';
    }
  }

  String get icon {
    switch (this) {
      case WaterSourceType.BOREHOLE:
        return '🕳️';
      case WaterSourceType.SURFACE_WATER:
        return '🌊';
      case WaterSourceType.DAM:
        return '🏗️';
      case WaterSourceType.SPRING:
        return '💧';
      case WaterSourceType.LAKE:
        return '🏞️';
      case WaterSourceType.RIVER:
        return '🌊';
      case WaterSourceType.WELL:
        return '🕳️';
    }
  }
}

enum SourceStatus {
  OPERATIONAL('operational'),
  MAINTENANCE('maintenance'),
  LIMITED('limited'),
  CONTAMINATED('contaminated'),
  DECOMMISSIONED('decommissioned');

  final String value;

  const SourceStatus(this.value);

  String get displayName {
    switch (this) {
      case SourceStatus.OPERATIONAL:
        return 'Operational';
      case SourceStatus.MAINTENANCE:
        return 'Under Maintenance';
      case SourceStatus.LIMITED:
        return 'Limited Service';
      case SourceStatus.CONTAMINATED:
        return 'Contaminated';
      case SourceStatus.DECOMMISSIONED:
        return 'Decommissioned';
    }
  }

  Color get color {
    switch (this) {
      case SourceStatus.OPERATIONAL:
        return Colors.green;
      case SourceStatus.MAINTENANCE:
        return Colors.orange;
      case SourceStatus.LIMITED:
        return Colors.amber;
      case SourceStatus.CONTAMINATED:
        return Colors.red;
      case SourceStatus.DECOMMISSIONED:
        return Colors.grey;
    }
  }
}

enum QualityGrade {
  EXCELLENT('excellent'),
  GOOD('good'),
  FAIR('fair'),
  POOR('poor'),
  UNUSABLE('unusable');

  final String value;

  const QualityGrade(this.value);

  String get displayName {
    switch (this) {
      case QualityGrade.EXCELLENT:
        return 'Excellent';
      case QualityGrade.GOOD:
        return 'Good';
      case QualityGrade.FAIR:
        return 'Fair';
      case QualityGrade.POOR:
        return 'Poor';
      case QualityGrade.UNUSABLE:
        return 'Unusable';
    }
  }

  Color get color {
    switch (this) {
      case QualityGrade.EXCELLENT:
        return Colors.green;
      case QualityGrade.GOOD:
        return Colors.lightGreen;
      case QualityGrade.FAIR:
        return Colors.amber;
      case QualityGrade.POOR:
        return Colors.orange;
      case QualityGrade.UNUSABLE:
        return Colors.red;
    }
  }
}

// Sub-models
class LocationInfo {
  final GPSCoordinates coordinates;
  final String address;
  final String catchmentArea;
  final double elevation;

  const LocationInfo({
    required this.coordinates,
    required this.address,
    required this.catchmentArea,
    required this.elevation,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      coordinates: GPSCoordinates.fromJson(json['coordinates'] ?? {}),
      address: json['address'] ?? '',
      catchmentArea: json['catchmentArea'] ?? '',
      elevation: (json['elevation'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.toJson(),
      'address': address,
      'catchmentArea': catchmentArea,
      'elevation': elevation,
    };
  }
}

class GPSCoordinates {
  final double latitude;
  final double longitude;

  const GPSCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory GPSCoordinates.fromJson(Map<String, dynamic> json) {
    return GPSCoordinates(
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class CapacityInfo {
  final double dailyYield;
  final double safeYield;
  final double currentUsage;
  final double utilizationRate;
  final double droughtReserve;

  const CapacityInfo({
    required this.dailyYield,
    required this.safeYield,
    required this.currentUsage,
    required this.utilizationRate,
    required this.droughtReserve,
  });

  factory CapacityInfo.fromJson(Map<String, dynamic> json) {
    return CapacityInfo(
      dailyYield: (json['dailyYield'] ?? 0).toDouble(),
      safeYield: (json['safeYield'] ?? 0).toDouble(),
      currentUsage: (json['currentUsage'] ?? 0).toDouble(),
      utilizationRate: (json['utilizationRate'] ?? 0).toDouble(),
      droughtReserve: (json['droughtReserve'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyYield': dailyYield,
      'safeYield': safeYield,
      'currentUsage': currentUsage,
      'utilizationRate': utilizationRate,
      'droughtReserve': droughtReserve,
    };
  }

  double get availableCapacity => dailyYield - currentUsage;

  double get efficiency =>
      dailyYield > 0 ? (currentUsage / dailyYield) * 100 : 0;
}

class QualityInfo {
  final QualityGrade qualityGrade;
  final double phLevel;
  final double turbidity;
  final List<String> contaminationRisks;
  final bool treatmentRequired;
  final DateTime lastTestDate;

  const QualityInfo({
    required this.qualityGrade,
    required this.phLevel,
    required this.turbidity,
    required this.contaminationRisks,
    required this.treatmentRequired,
    required this.lastTestDate,
  });

  factory QualityInfo.fromJson(Map<String, dynamic> json) {
    return QualityInfo(
      qualityGrade: QualityGrade.values.firstWhere(
        (e) => e.value == json['qualityGrade'],
        orElse: () => QualityGrade.GOOD,
      ),
      phLevel: (json['phLevel'] ?? 7.0).toDouble(),
      turbidity: (json['turbidity'] ?? 0).toDouble(),
      contaminationRisks: List<String>.from(json['contaminationRisks'] ?? []),
      treatmentRequired: json['treatmentRequired'] ?? false,
      lastTestDate: DateTime.parse(
          json['lastTestDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualityGrade': qualityGrade.value,
      'phLevel': phLevel,
      'turbidity': turbidity,
      'contaminationRisks': contaminationRisks,
      'treatmentRequired': treatmentRequired,
      'lastTestDate': lastTestDate.toIso8601String(),
    };
  }

  String get phStatus {
    if (phLevel < 6.5) return 'Acidic';
    if (phLevel > 8.5) return 'Alkaline';
    return 'Neutral';
  }

  Color get phColor {
    if (phLevel < 6.5) return Colors.red;
    if (phLevel > 8.5) return Colors.orange;
    return Colors.green;
  }
}

class SourceInfrastructure {
  final int pumps;
  final bool treatmentRequired;
  final double storageCapacity;
  final double transmissionLines;
  final String powerSupply;

  const SourceInfrastructure({
    required this.pumps,
    required this.treatmentRequired,
    required this.storageCapacity,
    required this.transmissionLines,
    required this.powerSupply,
  });

  factory SourceInfrastructure.fromJson(Map<String, dynamic> json) {
    return SourceInfrastructure(
      pumps: json['pumps'] ?? 0,
      treatmentRequired: json['treatmentRequired'] ?? false,
      storageCapacity: (json['storageCapacity'] ?? 0).toDouble(),
      transmissionLines: (json['transmissionLines'] ?? 0).toDouble(),
      powerSupply: json['powerSupply'] ?? 'grid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pumps': pumps,
      'treatmentRequired': treatmentRequired,
      'storageCapacity': storageCapacity,
      'transmissionLines': transmissionLines,
      'powerSupply': powerSupply,
    };
  }
}

class MonitoringInfo {
  final String monitoringFrequency;
  final List<String> parameters;
  final DateTime lastInspection;
  final DateTime nextInspection;
  final List<SourceAlert> alerts;

  const MonitoringInfo({
    required this.monitoringFrequency,
    required this.parameters,
    required this.lastInspection,
    required this.nextInspection,
    required this.alerts,
  });

  factory MonitoringInfo.fromJson(Map<String, dynamic> json) {
    return MonitoringInfo(
      monitoringFrequency: json['monitoringFrequency'] ?? 'monthly',
      parameters: List<String>.from(json['parameters'] ?? []),
      lastInspection: DateTime.parse(
          json['lastInspection'] ?? DateTime.now().toIso8601String()),
      nextInspection: DateTime.parse(json['nextInspection'] ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => SourceAlert.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monitoringFrequency': monitoringFrequency,
      'parameters': parameters,
      'lastInspection': lastInspection.toIso8601String(),
      'nextInspection': nextInspection.toIso8601String(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
    };
  }

  List<SourceAlert> get activeAlerts =>
      alerts.where((alert) => !alert.isResolved).toList();
}

class SourceAlert {
  final String type;
  final String severity;
  final String message;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;
  final String? resolution;

  const SourceAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.triggeredAt,
    this.resolvedAt,
    this.resolution,
  });

  factory SourceAlert.fromJson(Map<String, dynamic> json) {
    return SourceAlert(
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'medium',
      message: json['message'] ?? '',
      triggeredAt: DateTime.parse(
          json['triggeredAt'] ?? DateTime.now().toIso8601String()),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'message': message,
      'triggeredAt': triggeredAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolution': resolution,
    };
  }

  bool get isResolved => resolvedAt != null;

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
