import 'package:flutter/material.dart';

// Enums from backend
enum NakuruServiceRegion {
  nakuru_municipality,
  nakuru_west,
  nakuru_east,
  njoro,
  rongai,
  kuresoi_north,
  kuresoi_south,
  subukia,
  gilgil,
  naivasha,
  mau_narok,
  viwanda,
  bahati,
  lanet,
  shaabab,
  kabatini,
  barut,
  london,
  kapkures,
  milimani,
  menengai,
  flamingo,
  bondeni,
  kivumbi,
  free_area,
  kamukunji,
  biashara,
  race_course;

  String get displayName {
    switch (this) {
      case NakuruServiceRegion.nakuru_municipality:
        return 'Nakuru Municipality';
      case NakuruServiceRegion.nakuru_west:
        return 'Nakuru West';
      case NakuruServiceRegion.nakuru_east:
        return 'Nakuru East';
      case NakuruServiceRegion.njoro:
        return 'Njoro';
      case NakuruServiceRegion.rongai:
        return 'Rongai';
      case NakuruServiceRegion.kuresoi_north:
        return 'Kuresoi North';
      case NakuruServiceRegion.kuresoi_south:
        return 'Kuresoi South';
      case NakuruServiceRegion.subukia:
        return 'Subukia';
      case NakuruServiceRegion.gilgil:
        return 'Gilgil';
      case NakuruServiceRegion.naivasha:
        return 'Naivasha';
      case NakuruServiceRegion.mau_narok:
        return 'Mau Narok';
      case NakuruServiceRegion.viwanda:
        return 'Vianda';
      case NakuruServiceRegion.bahati:
        return 'Bahati';
      case NakuruServiceRegion.lanet:
        return 'Lanet';
      case NakuruServiceRegion.shaabab:
        return 'Shaabab';
      case NakuruServiceRegion.kabatini:
        return 'Kabatini';
      case NakuruServiceRegion.barut:
        return 'Barut';
      case NakuruServiceRegion.london:
        return 'London';
      case NakuruServiceRegion.kapkures:
        return 'Kapkures';
      case NakuruServiceRegion.milimani:
        return 'Milimani';
      case NakuruServiceRegion.menengai:
        return 'Menengai';
      case NakuruServiceRegion.flamingo:
        return 'Flamingo';
      case NakuruServiceRegion.bondeni:
        return 'Bondeni';
      case NakuruServiceRegion.kivumbi:
        return 'Kivumbi';
      case NakuruServiceRegion.free_area:
        return 'Free Area';
      case NakuruServiceRegion.kamukunji:
        return 'Kamukunji';
      case NakuruServiceRegion.biashara:
        return 'Biashara';
      case NakuruServiceRegion.race_course:
        return 'Race Course';
    }
  }
}

enum MeterStatus {
  active,
  inactive,
  disconnected,
  faulty,
  under_maintenance,
  decommissioned;

  String get displayName {
    switch (this) {
      case MeterStatus.active:
        return 'Active';
      case MeterStatus.inactive:
        return 'Inactive';
      case MeterStatus.disconnected:
        return 'Disconnected';
      case MeterStatus.faulty:
        return 'Faulty';
      case MeterStatus.under_maintenance:
        return 'Under Maintenance';
      case MeterStatus.decommissioned:
        return 'Decommissioned';
    }
  }

  Color get color {
    switch (this) {
      case MeterStatus.active:
        return Colors.green;
      case MeterStatus.inactive:
        return Colors.grey;
      case MeterStatus.disconnected:
        return Colors.orange;
      case MeterStatus.faulty:
        return Colors.red;
      case MeterStatus.under_maintenance:
        return Colors.blue;
      case MeterStatus.decommissioned:
        return Colors.black;
    }
  }
}

enum MeterType {
  mechanical,
  digital,
  smart,
  ultrasonic,
  electromagnetic;

  String get displayName {
    switch (this) {
      case MeterType.mechanical:
        return 'Mechanical';
      case MeterType.digital:
        return 'Digital';
      case MeterType.smart:
        return 'Smart';
      case MeterType.ultrasonic:
        return 'Ultrasonic';
      case MeterType.electromagnetic:
        return 'Electromagnetic';
    }
  }
}

enum MeterTechnology {
  amr,
  ami,
  manual;

  String get displayName {
    switch (this) {
      case MeterTechnology.amr:
        return 'AMR (Automatic Meter Reading)';
      case MeterTechnology.ami:
        return 'AMI (Advanced Metering Infrastructure)';
      case MeterTechnology.manual:
        return 'Manual Reading';
    }
  }
}

enum ConnectivityStatus {
  online,
  offline,
  degraded,
  maintenance;

  String get displayName {
    switch (this) {
      case ConnectivityStatus.online:
        return 'Online';
      case ConnectivityStatus.offline:
        return 'Offline';
      case ConnectivityStatus.degraded:
        return 'Degraded';
      case ConnectivityStatus.maintenance:
        return 'Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case ConnectivityStatus.online:
        return Colors.green;
      case ConnectivityStatus.offline:
        return Colors.red;
      case ConnectivityStatus.degraded:
        return Colors.orange;
      case ConnectivityStatus.maintenance:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case ConnectivityStatus.online:
        return Icons.wifi;
      case ConnectivityStatus.offline:
        return Icons.wifi_off;
      case ConnectivityStatus.degraded:
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      case ConnectivityStatus.maintenance:
        return Icons.engineering;
    }
  }
}

enum AlertType {
  tamper,
  leak,
  low_battery,
  no_communication,
  reverse_flow;

  String get displayName {
    switch (this) {
      case AlertType.tamper:
        return 'Tamper Alert';
      case AlertType.leak:
        return 'Leak Detection';
      case AlertType.low_battery:
        return 'Low Battery';
      case AlertType.no_communication:
        return 'No Communication';
      case AlertType.reverse_flow:
        return 'Reverse Flow';
    }
  }

  Color get color {
    switch (this) {
      case AlertType.tamper:
        return Colors.deepOrange;
      case AlertType.leak:
        return Colors.blue;
      case AlertType.low_battery:
        return Colors.amber;
      case AlertType.no_communication:
        return Colors.red;
      case AlertType.reverse_flow:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.tamper:
        return Icons.security;
      case AlertType.leak:
        return Icons.opacity;
      case AlertType.low_battery:
        return Icons.battery_alert;
      case AlertType.no_communication:
        return Icons.signal_cellular_off;
      case AlertType.reverse_flow:
        return Icons.swap_horiz;
    }
  }
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.amber;
      case AlertSeverity.high:
        return Colors.orange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }
}

// Models
class MeterInstallation {
  final DateTime installationDate;
  final String installerName;
  final String? installerCompany;
  final double installationCost;
  final DateTime? warrantyExpiry;
  final String? installationNotes;

  MeterInstallation({
    required this.installationDate,
    required this.installerName,
    this.installerCompany,
    required this.installationCost,
    this.warrantyExpiry,
    this.installationNotes,
  });

  factory MeterInstallation.fromJson(Map<String, dynamic> json) {
    return MeterInstallation(
      installationDate: DateTime.parse(json['installationDate']),
      installerName: json['installerName'],
      installerCompany: json['installerCompany'],
      installationCost: (json['installationCost'] as num).toDouble(),
      warrantyExpiry: json['warrantyExpiry'] != null
          ? DateTime.parse(json['warrantyExpiry'])
          : null,
      installationNotes: json['installationNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installationDate': installationDate.toIso8601String(),
      'installerName': installerName,
      'installerCompany': installerCompany,
      'installationCost': installationCost,
      'warrantyExpiry': warrantyExpiry?.toIso8601String(),
      'installationNotes': installationNotes,
    };
  }
}

class MeterSpecifications {
  final String size;
  final double maxFlowRate;
  final String accuracyClass;
  final TemperatureRange operatingTemperature;
  final double pressureRating;
  final String material;
  final String manufacturer;
  final String model;
  final DateTime manufacturingDate;

  MeterSpecifications({
    required this.size,
    required this.maxFlowRate,
    required this.accuracyClass,
    required this.operatingTemperature,
    required this.pressureRating,
    required this.material,
    required this.manufacturer,
    required this.model,
    required this.manufacturingDate,
  });

  factory MeterSpecifications.fromJson(Map<String, dynamic> json) {
    return MeterSpecifications(
      size: json['size'],
      maxFlowRate: (json['maxFlowRate'] as num).toDouble(),
      accuracyClass: json['accuracyClass'],
      operatingTemperature:
          TemperatureRange.fromJson(json['operatingTemperature']),
      pressureRating: (json['pressureRating'] as num).toDouble(),
      material: json['material'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      manufacturingDate: DateTime.parse(json['manufacturingDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'maxFlowRate': maxFlowRate,
      'accuracyClass': accuracyClass,
      'operatingTemperature': operatingTemperature.toJson(),
      'pressureRating': pressureRating,
      'material': material,
      'manufacturer': manufacturer,
      'model': model,
      'manufacturingDate': manufacturingDate.toIso8601String(),
    };
  }
}

class TemperatureRange {
  final double min;
  final double max;

  TemperatureRange({required this.min, required this.max});

  factory TemperatureRange.fromJson(Map<String, dynamic> json) {
    return TemperatureRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};

  @override
  String toString() => '$min°C - $max°C';
}

class MeterLocation {
  final String address;
  final String? landmark;
  final GpsCoordinates? gpsCoordinates;
  final String accessibility;
  final String installationType;
  final List<String>? photos;

  MeterLocation({
    required this.address,
    this.landmark,
    this.gpsCoordinates,
    required this.accessibility,
    required this.installationType,
    this.photos,
  });

  factory MeterLocation.fromJson(Map<String, dynamic> json) {
    return MeterLocation(
      address: json['address'],
      landmark: json['landmark'],
      gpsCoordinates: json['gpsCoordinates'] != null
          ? GpsCoordinates.fromJson(json['gpsCoordinates'])
          : null,
      accessibility: json['accessibility'],
      installationType: json['installationType'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'landmark': landmark,
      'gpsCoordinates': gpsCoordinates?.toJson(),
      'accessibility': accessibility,
      'installationType': installationType,
      'photos': photos,
    };
  }
}

class GpsCoordinates {
  final double latitude;
  final double longitude;

  GpsCoordinates({required this.latitude, required this.longitude});

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) {
    return GpsCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() =>
      {'latitude': latitude, 'longitude': longitude};

  @override
  String toString() => '$latitude, $longitude';
}

class TransmissionSettings {
  final String communicationProtocol;
  final String? simCardNumber;
  final int dataTransmissionInterval;
  final double signalThreshold;
  final DateTime? lastSync;

  TransmissionSettings({
    required this.communicationProtocol,
    this.simCardNumber,
    required this.dataTransmissionInterval,
    required this.signalThreshold,
    this.lastSync,
  });

  factory TransmissionSettings.fromJson(Map<String, dynamic> json) {
    return TransmissionSettings(
      communicationProtocol: json['communicationProtocol'],
      simCardNumber: json['simCardNumber'],
      dataTransmissionInterval: json['dataTransmissionInterval'],
      signalThreshold: (json['signalThreshold'] as num).toDouble(),
      lastSync:
          json['lastSync'] != null ? DateTime.parse(json['lastSync']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communicationProtocol': communicationProtocol,
      'simCardNumber': simCardNumber,
      'dataTransmissionInterval': dataTransmissionInterval,
      'signalStrength': signalThreshold,
      'lastSync': lastSync?.toIso8601String(),
    };
  }
}

class MaintenanceRecord {
  final DateTime date;
  final String type;
  final String description;
  final String technician;
  final double cost;
  final DateTime? nextScheduled;
  final String? notes;

  MaintenanceRecord({
    required this.date,
    required this.type,
    required this.description,
    required this.technician,
    required this.cost,
    this.nextScheduled,
    this.notes,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      date: DateTime.parse(json['date']),
      type: json['type'],
      description: json['description'],
      technician: json['technician'],
      cost: (json['cost'] as num).toDouble(),
      nextScheduled: json['nextScheduled'] != null
          ? DateTime.parse(json['nextScheduled'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'technician': technician,
      'cost': cost,
      'nextScheduled': nextScheduled?.toIso8601String(),
      'notes': notes,
    };
  }
}

class CalibrationRecord {
  final DateTime date;
  final double previousAccuracy;
  final double newAccuracy;
  final String calibratedBy;
  final String? certificateNumber;
  final DateTime nextCalibrationDue;
  final String? notes;

  CalibrationRecord({
    required this.date,
    required this.previousAccuracy,
    required this.newAccuracy,
    required this.calibratedBy,
    this.certificateNumber,
    required this.nextCalibrationDue,
    this.notes,
  });

  factory CalibrationRecord.fromJson(Map<String, dynamic> json) {
    return CalibrationRecord(
      date: DateTime.parse(json['date']),
      previousAccuracy: (json['previousAccuracy'] as num).toDouble(),
      newAccuracy: (json['newAccuracy'] as num).toDouble(),
      calibratedBy: json['calibratedBy'],
      certificateNumber: json['certificateNumber'],
      nextCalibrationDue: DateTime.parse(json['nextCalibrationDue']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'previousAccuracy': previousAccuracy,
      'newAccuracy': newAccuracy,
      'calibratedBy': calibratedBy,
      'certificateNumber': certificateNumber,
      'nextCalibrationDue': nextCalibrationDue.toIso8601String(),
      'notes': notes,
    };
  }
}

class BatteryInfo {
  final String type;
  final DateTime installedDate;
  final int expectedLife;
  final double voltage;
  final String status;
  final DateTime? lastReplacementDate;

  BatteryInfo({
    required this.type,
    required this.installedDate,
    required this.expectedLife,
    required this.voltage,
    required this.status,
    this.lastReplacementDate,
  });

  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      type: json['type'],
      installedDate: DateTime.parse(json['installedDate']),
      expectedLife: json['expectedLife'],
      voltage: (json['voltage'] as num).toDouble(),
      status: json['status'],
      lastReplacementDate: json['lastReplacementDate'] != null
          ? DateTime.parse(json['lastReplacementDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'installedDate': installedDate.toIso8601String(),
      'expectedLife': expectedLife,
      'voltage': voltage,
      'status': status,
      'lastReplacementDate': lastReplacementDate?.toIso8601String(),
    };
  }
}

class MeterAlert {
  final AlertType type;
  final AlertSeverity severity;
  final DateTime detectedAt;
  final String description;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;

  MeterAlert({
    required this.type,
    required this.severity,
    required this.detectedAt,
    required this.description,
    required this.resolved,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
  });

  factory MeterAlert.fromJson(Map<String, dynamic> json) {
    return MeterAlert(
      type: AlertType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AlertType.tamper,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      detectedAt: DateTime.parse(json['detectedAt']),
      description: json['description'],
      resolved: json['resolved'] ?? false,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      resolvedBy: json['resolvedBy'],
      resolutionNotes: json['resolutionNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'description': description,
      'resolved': resolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
    };
  }
}

class MeterIssue {
  final DateTime reportedDate;
  final String type;
  final String description;
  final String reportedBy;
  final String status;
  final String? assignedTo;
  final DateTime? resolutionDate;
  final String? resolutionNotes;
  final double? costIncurred;

  MeterIssue({
    required this.reportedDate,
    required this.type,
    required this.description,
    required this.reportedBy,
    required this.status,
    this.assignedTo,
    this.resolutionDate,
    this.resolutionNotes,
    this.costIncurred,
  });

  factory MeterIssue.fromJson(Map<String, dynamic> json) {
    return MeterIssue(
      reportedDate: DateTime.parse(json['reportedDate']),
      type: json['type'],
      description: json['description'],
      reportedBy: json['reportedBy'],
      status: json['status'],
      assignedTo: json['assignedTo'],
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.parse(json['resolutionDate'])
          : null,
      resolutionNotes: json['resolutionNotes'],
      costIncurred: json['costIncurred']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportedDate': reportedDate.toIso8601String(),
      'type': type,
      'description': description,
      'reportedBy': reportedBy,
      'status': status,
      'assignedTo': assignedTo,
      'resolutionDate': resolutionDate?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
      'costIncurred': costIncurred,
    };
  }
}

// Main Water Meter Model
class WaterMeter {
  final String id;
  final String meterNumber;
  final String serialNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final NakuruServiceRegion serviceRegion;
  final String? ward;
  final MeterInstallation installation;
  final MeterSpecifications specifications;
  final MeterStatus status;
  final MeterType type;
  final MeterTechnology technology;
  final MeterLocation location;
  final TransmissionSettings transmission;
  final String tariffId;
  final List<MaintenanceRecord> maintenance;
  final List<CalibrationRecord> calibration;
  final BatteryInfo? battery;
  final ConnectivityStatus connectivity;
  final DateTime? lastCommunication;
  final double? signalStrength;
  final List<MeterAlert> activeAlerts;
  final List<MeterIssue> issueHistory;
  final String installedById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deactivatedAt;

  // Helper properties
  bool get isActive => status == MeterStatus.active;

  bool get hasConnectivityIssues =>
      connectivity == ConnectivityStatus.offline ||
      connectivity == ConnectivityStatus.degraded;

  bool get hasActiveAlerts => activeAlerts.isNotEmpty;

  bool get isUnderWarranty {
    if (installation.warrantyExpiry == null) return false;
    return DateTime.now().isBefore(installation.warrantyExpiry!);
  }

  int get meterAgeInDays =>
      DateTime.now().difference(installation.installationDate).inDays;

  WaterMeter({
    required this.id,
    required this.meterNumber,
    required this.serialNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.serviceRegion,
    this.ward,
    required this.installation,
    required this.specifications,
    required this.status,
    required this.type,
    required this.technology,
    required this.location,
    required this.transmission,
    required this.tariffId,
    this.maintenance = const [],
    this.calibration = const [],
    this.battery,
    required this.connectivity,
    this.lastCommunication,
    this.signalStrength,
    this.activeAlerts = const [],
    this.issueHistory = const [],
    required this.installedById,
    required this.createdAt,
    required this.updatedAt,
    this.deactivatedAt,
  });

  factory WaterMeter.fromJson(Map<String, dynamic> json) {
    return WaterMeter(
      id: json['_id'] ?? json['id'],
      meterNumber: json['meterNumber'],
      serialNumber: json['serialNumber'],
      customerId: json['customer']?['_id'] ?? json['customer'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      serviceRegion: NakuruServiceRegion.values.firstWhere(
        (e) => e.toString().split('.').last == json['serviceRegion'],
        orElse: () => NakuruServiceRegion.nakuru_municipality,
      ),
      ward: json['ward'],
      installation: MeterInstallation.fromJson(json['installation']),
      specifications: MeterSpecifications.fromJson(json['specifications']),
      status: MeterStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MeterStatus.active,
      ),
      type: MeterType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MeterType.smart,
      ),
      technology: MeterTechnology.values.firstWhere(
        (e) => e.toString().split('.').last == json['technology'],
        orElse: () => MeterTechnology.ami,
      ),
      location: MeterLocation.fromJson(json['location']),
      transmission: TransmissionSettings.fromJson(json['transmission']),
      tariffId: json['tariff']?['_id'] ?? json['tariff'],
      maintenance: json['maintenance'] != null
          ? (json['maintenance'] as List)
              .map((item) => MaintenanceRecord.fromJson(item))
              .toList()
          : [],
      calibration: json['calibration'] != null
          ? (json['calibration'] as List)
              .map((item) => CalibrationRecord.fromJson(item))
              .toList()
          : [],
      battery: json['battery'] != null
          ? BatteryInfo.fromJson(json['battery'])
          : null,
      connectivity: ConnectivityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['connectivity'],
        orElse: () => ConnectivityStatus.online,
      ),
      lastCommunication: json['lastCommunication'] != null
          ? DateTime.parse(json['lastCommunication'])
          : null,
      signalStrength: json['signalStrength']?.toDouble(),
      activeAlerts: json['activeAlerts'] != null
          ? (json['activeAlerts'] as List)
              .map((item) => MeterAlert.fromJson(item))
              .toList()
          : [],
      issueHistory: json['issueHistory'] != null
          ? (json['issueHistory'] as List)
              .map((item) => MeterIssue.fromJson(item))
              .toList()
          : [],
      installedById: json['installedBy']?['_id'] ?? json['installedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deactivatedAt: json['deactivatedAt'] != null
          ? DateTime.parse(json['deactivatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meterNumber': meterNumber,
      'serialNumber': serialNumber,
      'customer': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'serviceRegion': serviceRegion.name,
      'ward': ward,
      'installation': installation.toJson(),
      'specifications': specifications.toJson(),
      'status': status.name,
      'type': type.name,
      'technology': technology.name,
      'location': location.toJson(),
      'transmission': transmission.toJson(),
      'tariff': tariffId,
      'battery': battery?.toJson(),
      'connectivity': connectivity.name,
      'signalStrength': signalStrength,
      'installedBy': installedById,
    };
  }

  WaterMeter copyWith({
    String? id,
    String? meterNumber,
    String? serialNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    NakuruServiceRegion? serviceRegion,
    String? ward,
    MeterInstallation? installation,
    MeterSpecifications? specifications,
    MeterStatus? status,
    MeterType? type,
    MeterTechnology? technology,
    MeterLocation? location,
    TransmissionSettings? transmission,
    String? tariffId,
    List<MaintenanceRecord>? maintenance,
    List<CalibrationRecord>? calibration,
    BatteryInfo? battery,
    ConnectivityStatus? connectivity,
    DateTime? lastCommunication,
    double? signalStrength,
    List<MeterAlert>? activeAlerts,
    List<MeterIssue>? issueHistory,
    String? installedById,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deactivatedAt,
  }) {
    return WaterMeter(
      id: id ?? this.id,
      meterNumber: meterNumber ?? this.meterNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceRegion: serviceRegion ?? this.serviceRegion,
      ward: ward ?? this.ward,
      installation: installation ?? this.installation,
      specifications: specifications ?? this.specifications,
      status: status ?? this.status,
      type: type ?? this.type,
      technology: technology ?? this.technology,
      location: location ?? this.location,
      transmission: transmission ?? this.transmission,
      tariffId: tariffId ?? this.tariffId,
      maintenance: maintenance ?? this.maintenance,
      calibration: calibration ?? this.calibration,
      battery: battery ?? this.battery,
      connectivity: connectivity ?? this.connectivity,
      lastCommunication: lastCommunication ?? this.lastCommunication,
      signalStrength: signalStrength ?? this.signalStrength,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      issueHistory: issueHistory ?? this.issueHistory,
      installedById: installedById ?? this.installedById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  @override
  String toString() {
    return 'WaterMeter($meterNumber - $customerName - $status)';
  }
}

// Filter and Pagination Models
class WaterMeterFilters {
  final String? meterNumber;
  final String? serialNumber;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final List<NakuruServiceRegion>? serviceRegions;
  final String? ward;
  final List<MeterStatus>? statuses;
  final List<MeterType>? types;
  final List<MeterTechnology>? technologies;
  final List<ConnectivityStatus>? connectivityStatuses;
  final String? tariffId;
  final String? installedById;
  final DateTime? installedFrom;
  final DateTime? installedTo;
  final String? manufacturer;
  final String? model;
  final String? accessibility;
  final String? installationType;

  const WaterMeterFilters({
    this.meterNumber,
    this.serialNumber,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.serviceRegions,
    this.ward,
    this.statuses,
    this.types,
    this.technologies,
    this.connectivityStatuses,
    this.tariffId,
    this.installedById,
    this.installedFrom,
    this.installedTo,
    this.manufacturer,
    this.model,
    this.accessibility,
    this.installationType,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (meterNumber != null && meterNumber!.isNotEmpty) {
      params['meterNumber'] = meterNumber;
    }
    if (serialNumber != null && serialNumber!.isNotEmpty) {
      params['serialNumber'] = serialNumber;
    }
    if (customerId != null && customerId!.isNotEmpty) {
      params['customer'] = customerId;
    }
    if (customerName != null && customerName!.isNotEmpty) {
      params['customerName'] = customerName;
    }
    if (customerEmail != null && customerEmail!.isNotEmpty) {
      params['customerEmail'] = customerEmail;
    }
    if (customerPhone != null && customerPhone!.isNotEmpty) {
      params['customerPhone'] = customerPhone;
    }
    if (serviceRegions != null && serviceRegions!.isNotEmpty) {
      params['serviceRegion'] = serviceRegions!.map((e) => e.name).join(',');
    }
    if (ward != null && ward!.isNotEmpty) {
      params['ward'] = ward;
    }
    if (statuses != null && statuses!.isNotEmpty) {
      params['status'] = statuses!.map((e) => e.name).join(',');
    }
    if (types != null && types!.isNotEmpty) {
      params['type'] = types!.map((e) => e.name).join(',');
    }
    if (technologies != null && technologies!.isNotEmpty) {
      params['technology'] = technologies!.map((e) => e.name).join(',');
    }
    if (connectivityStatuses != null && connectivityStatuses!.isNotEmpty) {
      params['connectivity'] =
          connectivityStatuses!.map((e) => e.name).join(',');
    }
    if (tariffId != null && tariffId!.isNotEmpty) {
      params['tariff'] = tariffId;
    }
    if (installedById != null && installedById!.isNotEmpty) {
      params['installedBy'] = installedById;
    }
    if (installedFrom != null) {
      params['installedFrom'] = installedFrom!.toIso8601String();
    }
    if (installedTo != null) {
      params['installedTo'] = installedTo!.toIso8601String();
    }
    if (manufacturer != null && manufacturer!.isNotEmpty) {
      params['manufacturer'] = manufacturer;
    }
    if (model != null && model!.isNotEmpty) {
      params['model'] = model;
    }
    if (accessibility != null && accessibility!.isNotEmpty) {
      params['accessibility'] = accessibility;
    }
    if (installationType != null && installationType!.isNotEmpty) {
      params['installationType'] = installationType;
    }

    return params;
  }

  WaterMeterFilters copyWith({
    String? meterNumber,
    String? serialNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<NakuruServiceRegion>? serviceRegions,
    String? ward,
    List<MeterStatus>? statuses,
    List<MeterType>? types,
    List<MeterTechnology>? technologies,
    List<ConnectivityStatus>? connectivityStatuses,
    String? tariffId,
    String? installedById,
    DateTime? installedFrom,
    DateTime? installedTo,
    String? manufacturer,
    String? model,
    String? accessibility,
    String? installationType,
  }) {
    return WaterMeterFilters(
      meterNumber: meterNumber ?? this.meterNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceRegions: serviceRegions ?? this.serviceRegions,
      ward: ward ?? this.ward,
      statuses: statuses ?? this.statuses,
      types: types ?? this.types,
      technologies: technologies ?? this.technologies,
      connectivityStatuses: connectivityStatuses ?? this.connectivityStatuses,
      tariffId: tariffId ?? this.tariffId,
      installedById: installedById ?? this.installedById,
      installedFrom: installedFrom ?? this.installedFrom,
      installedTo: installedTo ?? this.installedTo,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      accessibility: accessibility ?? this.accessibility,
      installationType: installationType ?? this.installationType,
    );
  }

  bool get hasFilters {
    return meterNumber != null ||
        serialNumber != null ||
        customerId != null ||
        customerName != null ||
        customerEmail != null ||
        customerPhone != null ||
        (serviceRegions != null && serviceRegions!.isNotEmpty) ||
        ward != null ||
        (statuses != null && statuses!.isNotEmpty) ||
        (types != null && types!.isNotEmpty) ||
        (technologies != null && technologies!.isNotEmpty) ||
        (connectivityStatuses != null && connectivityStatuses!.isNotEmpty) ||
        tariffId != null ||
        installedById != null ||
        installedFrom != null ||
        installedTo != null ||
        manufacturer != null ||
        model != null ||
        accessibility != null ||
        installationType != null;
  }

  void clear() {
    WaterMeterFilters();
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['screens'] ?? 1,
    );
  }
}

class WaterMeterStats {
  final int totalMeters;
  final int activeMeters;
  final int faultyMeters;
  final int disconnectedMeters;
  final int onlineMeters;
  final int offlineMeters;
  final Map<NakuruServiceRegion, int> regionalDistribution;
  final Map<MeterType, int> typeDistribution;
  final Map<MeterTechnology, int> technologyDistribution;

  const WaterMeterStats({
    required this.totalMeters,
    required this.activeMeters,
    required this.faultyMeters,
    required this.disconnectedMeters,
    required this.onlineMeters,
    required this.offlineMeters,
    required this.regionalDistribution,
    required this.typeDistribution,
    required this.technologyDistribution,
  });

  factory WaterMeterStats.fromJson(Map<String, dynamic> json) {
    final regional = <NakuruServiceRegion, int>{};
    final type = <MeterType, int>{};
    final tech = <MeterTechnology, int>{};

    if (json['regionalDistribution'] != null) {
      for (final entry in (json['regionalDistribution'] as Map).entries) {
        final region = NakuruServiceRegion.values.firstWhere(
          (e) => e.name == entry.key,
          orElse: () => NakuruServiceRegion.nakuru_municipality,
        );
        regional[region] = entry.value as int;
      }
    }

    if (json['typeDistribution'] != null) {
      for (final entry in (json['typeDistribution'] as Map).entries) {
        final meterType = MeterType.values.firstWhere(
          (e) => e.name == entry.key,
          orElse: () => MeterType.smart,
        );
        type[meterType] = entry.value as int;
      }
    }

    if (json['technologyDistribution'] != null) {
      for (final entry in (json['technologyDistribution'] as Map).entries) {
        final technology = MeterTechnology.values.firstWhere(
          (e) => e.name == entry.key,
          orElse: () => MeterTechnology.ami,
        );
        tech[technology] = entry.value as int;
      }
    }

    return WaterMeterStats(
      totalMeters: json['totalMeters'] ?? 0,
      activeMeters: json['activeMeters'] ?? 0,
      faultyMeters: json['faultyMeters'] ?? 0,
      disconnectedMeters: json['disconnectedMeters'] ?? 0,
      onlineMeters: json['onlineMeters'] ?? 0,
      offlineMeters: json['offlineMeters'] ?? 0,
      regionalDistribution: regional,
      typeDistribution: type,
      technologyDistribution: tech,
    );
  }
}
