import 'package:flutter/material.dart';

enum AreaType {
  urban,
  peri_urban,
  rural,
  commercial,
  industrial;

  String get displayName {
    switch (this) {
      case AreaType.urban:
        return 'Urban';
      case AreaType.peri_urban:
        return 'Peri-Urban';
      case AreaType.rural:
        return 'Rural';
      case AreaType.commercial:
        return 'Commercial';
      case AreaType.industrial:
        return 'Industrial';
    }
  }

  IconData get icon {
    switch (this) {
      case AreaType.urban:
        return Icons.location_city;
      case AreaType.peri_urban:
        return Icons.apartment_outlined;
      case AreaType.rural:
        return Icons.landscape;
      case AreaType.commercial:
        return Icons.business;
      case AreaType.industrial:
        return Icons.factory;
    }
  }

  Color get color {
    switch (this) {
      case AreaType.urban:
        return Colors.blue;
      case AreaType.peri_urban:
        return Colors.green;
      case AreaType.rural:
        return Colors.orange;
      case AreaType.commercial:
        return Colors.purple;
      case AreaType.industrial:
        return Colors.red;
    }
  }
}

enum ServiceStatus {
  active,
  planned,
  under_development,
  suspended,
  decommissioned;

  String get displayName {
    switch (this) {
      case ServiceStatus.active:
        return 'Active';
      case ServiceStatus.planned:
        return 'Planned';
      case ServiceStatus.under_development:
        return 'Under Development';
      case ServiceStatus.suspended:
        return 'Suspended';
      case ServiceStatus.decommissioned:
        return 'Decommissioned';
    }
  }

  Color get color {
    switch (this) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.planned:
        return Colors.blue;
      case ServiceStatus.under_development:
        return Colors.orange;
      case ServiceStatus.suspended:
        return Colors.red;
      case ServiceStatus.decommissioned:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceStatus.active:
        return Icons.check_circle;
      case ServiceStatus.planned:
        return Icons.schedule;
      case ServiceStatus.under_development:
        return Icons.build;
      case ServiceStatus.suspended:
        return Icons.pause_circle;
      case ServiceStatus.decommissioned:
        return Icons.remove_circle;
    }
  }
}

enum ServiceType {
  water_supply,
  sewerage,
  limited_sewerage,
  bulk_water,
  water_quality;

  String get displayName {
    switch (this) {
      case ServiceType.water_supply:
        return 'Water Supply';
      case ServiceType.sewerage:
        return 'Sewerage';
      case ServiceType.limited_sewerage:
        return 'Limited Sewerage';
      case ServiceType.bulk_water:
        return 'Bulk Water';
      case ServiceType.water_quality:
        return 'Water Quality';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.water_supply:
        return Icons.water_drop;
      case ServiceType.sewerage:
        return Icons.plumbing;
      case ServiceType.limited_sewerage:
        return Icons.plumbing_rounded;
      case ServiceType.bulk_water:
        return Icons.local_shipping;
      case ServiceType.water_quality:
        return Icons.science;
    }
  }
}

class CoverageInfo {
  final double totalArea;
  final double waterCoverage;
  final double sewerageCoverage;
  final double connectionRate;
  final DateTime lastUpdated;

  CoverageInfo({
    required this.totalArea,
    required this.waterCoverage,
    required this.sewerageCoverage,
    required this.connectionRate,
    required this.lastUpdated,
  });

  factory CoverageInfo.fromJson(Map<String, dynamic> json) {
    return CoverageInfo(
      totalArea: (json['totalArea'] as num).toDouble(),
      waterCoverage: (json['waterCoverage'] as num).toDouble(),
      sewerageCoverage: (json['sewerageCoverage'] as num).toDouble(),
      connectionRate: (json['connectionRate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalArea': totalArea,
      'waterCoverage': waterCoverage,
      'sewerageCoverage': sewerageCoverage,
      'connectionRate': connectionRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  CoverageInfo copyWith({
    double? totalArea,
    double? waterCoverage,
    double? sewerageCoverage,
    double? connectionRate,
    DateTime? lastUpdated,
  }) {
    return CoverageInfo(
      totalArea: totalArea ?? this.totalArea,
      waterCoverage: waterCoverage ?? this.waterCoverage,
      sewerageCoverage: sewerageCoverage ?? this.sewerageCoverage,
      connectionRate: connectionRate ?? this.connectionRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class InfrastructureInfo {
  final double waterMains;
  final double sewerMains;
  final int reservoirs;
  final int pumpingStations;
  final int treatmentPlants;
  final DateTime lastRehabilitation;

  InfrastructureInfo({
    required this.waterMains,
    required this.sewerMains,
    required this.reservoirs,
    required this.pumpingStations,
    required this.treatmentPlants,
    required this.lastRehabilitation,
  });

  factory InfrastructureInfo.fromJson(Map<String, dynamic> json) {
    return InfrastructureInfo(
      waterMains: (json['waterMains'] as num).toDouble(),
      sewerMains: (json['sewerMains'] as num).toDouble(),
      reservoirs: json['reservoirs'] as int,
      pumpingStations: json['pumpingStations'] as int,
      treatmentPlants: json['treatmentPlants'] as int,
      lastRehabilitation: DateTime.parse(json['lastRehabilitation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waterMains': waterMains,
      'sewerMains': sewerMains,
      'reservoirs': reservoirs,
      'pumpingStations': pumpingStations,
      'treatmentPlants': treatmentPlants,
      'lastRehabilitation': lastRehabilitation.toIso8601String(),
    };
  }

  InfrastructureInfo copyWith({
    double? waterMains,
    double? sewerMains,
    int? reservoirs,
    int? pumpingStations,
    int? treatmentPlants,
    DateTime? lastRehabilitation,
  }) {
    return InfrastructureInfo(
      waterMains: waterMains ?? this.waterMains,
      sewerMains: sewerMains ?? this.sewerMains,
      reservoirs: reservoirs ?? this.reservoirs,
      pumpingStations: pumpingStations ?? this.pumpingStations,
      treatmentPlants: treatmentPlants ?? this.treatmentPlants,
      lastRehabilitation: lastRehabilitation ?? this.lastRehabilitation,
    );
  }
}

class ContactInfo {
  final String officeAddress;
  final String phone;
  final String email;
  final String manager;
  final String emergencyContact;

  ContactInfo({
    required this.officeAddress,
    required this.phone,
    required this.email,
    required this.manager,
    required this.emergencyContact,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      officeAddress: json['officeAddress'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      manager: json['manager'] as String,
      emergencyContact: json['emergencyContact'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'officeAddress': officeAddress,
      'phone': phone,
      'email': email,
      'manager': manager,
      'emergencyContact': emergencyContact,
    };
  }

  ContactInfo copyWith({
    String? officeAddress,
    String? phone,
    String? email,
    String? manager,
    String? emergencyContact,
  }) {
    return ContactInfo(
      officeAddress: officeAddress ?? this.officeAddress,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}

class ServiceArea {
  final String id;
  final String name;
  final String description;
  final AreaType type;
  final ServiceStatus status;
  final CoverageInfo coverage;
  final List<ServiceType> services;
  final int population;
  final int households;
  final List<String> waterSources;
  final List<String> treatmentPlants;
  final InfrastructureInfo infrastructure;
  final ContactInfo contact;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceArea({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.coverage,
    required this.services,
    required this.population,
    required this.households,
    required this.waterSources,
    required this.treatmentPlants,
    required this.infrastructure,
    required this.contact,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) {
    return ServiceArea(
      id: json['_id'] ?? json['id'],
      name: json['name'] as String,
      description: json['description'] as String,
      type: AreaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AreaType.urban,
      ),
      status: ServiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ServiceStatus.active,
      ),
      coverage: CoverageInfo.fromJson(json['coverage']),
      services: (json['services'] as List)
          .map((e) => ServiceType.values.firstWhere(
                (s) => s.name == e,
                orElse: () => ServiceType.water_supply,
              ))
          .toList(),
      population: json['population'] as int,
      households: json['households'] as int,
      waterSources: (json['waterSources'] as List).cast<String>(),
      treatmentPlants: (json['treatmentPlants'] as List).cast<String>(),
      infrastructure: InfrastructureInfo.fromJson(json['infrastructure']),
      contact: ContactInfo.fromJson(json['contact']),
      createdBy: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'coverage': coverage.toJson(),
      'services': services.map((e) => e.name).toList(),
      'population': population,
      'households': households,
      'waterSources': waterSources,
      'treatmentPlants': treatmentPlants,
      'infrastructure': infrastructure.toJson(),
      'contact': contact.toJson(),
    };
  }

  ServiceArea copyWith({
    String? id,
    String? name,
    String? description,
    AreaType? type,
    ServiceStatus? status,
    CoverageInfo? coverage,
    List<ServiceType>? services,
    int? population,
    int? households,
    List<String>? waterSources,
    List<String>? treatmentPlants,
    InfrastructureInfo? infrastructure,
    ContactInfo? contact,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceArea(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      coverage: coverage ?? this.coverage,
      services: services ?? this.services,
      population: population ?? this.population,
      households: households ?? this.households,
      waterSources: waterSources ?? this.waterSources,
      treatmentPlants: treatmentPlants ?? this.treatmentPlants,
      infrastructure: infrastructure ?? this.infrastructure,
      contact: contact ?? this.contact,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
