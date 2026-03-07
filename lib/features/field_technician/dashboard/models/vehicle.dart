import 'package:equatable/equatable.dart';

enum VehicleStatus {
  available('Available'),
  inUse('In Use'),
  underMaintenance('Under Maintenance'),
  outOfService('Out of Service');

  const VehicleStatus(this.displayName);
  final String displayName;

  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
          (e) => e.name == value.replaceAll('-', '_'),
      orElse: () => VehicleStatus.available,
    );
  }
}

enum OperationalStatus {
  operational('Operational'),
  needsMaintenance('Needs Maintenance'),
  repairNeeded('Repair Needed'),
  decommissioned('Decommissioned');

  const OperationalStatus(this.displayName);
  final String displayName;

  static OperationalStatus fromString(String value) {
    return OperationalStatus.values.firstWhere(
          (e) => e.name == value.replaceAll('-', '_'),
      orElse: () => OperationalStatus.operational,
    );
  }
}

enum VehicleType {
  pickupTruck('Pickup Truck'),
  van('Van'),
  suv('SUV'),
  motorcycle('Motorcycle'),
  truck('Truck'),
  specialEquipment('Special Equipment');

  const VehicleType(this.displayName);
  final String displayName;

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
          (e) => e.name == value.replaceAll('-', '_'),
      orElse: () => VehicleType.pickupTruck,
    );
  }
}

enum FuelType {
  petrol('Petrol'),
  diesel('Diesel'),
  electric('Electric'),
  hybrid('Hybrid');

  const FuelType(this.displayName);
  final String displayName;

  static FuelType fromString(String value) {
    return FuelType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => FuelType.petrol,
    );
  }
}

class Vehicle extends Equatable {
  final String id;
  final String registrationNumber;
  final String make;
  final String model;
  final int year;
  final String color;
  final VehicleType vehicleType;
  final String? assignedTo;
  final String? assignedToName;
  final VehicleStatus status;
  final OperationalStatus operationalStatus;
  final double currentOdometer;
  final FuelType fuelType;
  final double fuelCapacity;
  final double currentFuelLevel;
  final double purchasePrice;
  final double currentValue;
  final double maintenanceCost;
  final double fuelCost;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.vehicleType,
    this.assignedTo,
    this.assignedToName,
    required this.status,
    required this.operationalStatus,
    required this.currentOdometer,
    required this.fuelType,
    required this.fuelCapacity,
    required this.currentFuelLevel,
    required this.purchasePrice,
    required this.currentValue,
    required this.maintenanceCost,
    required this.fuelCost,
    this.lastServiceDate,
    this.nextServiceDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  double get fuelPercentage => (currentFuelLevel / fuelCapacity) * 100;
  bool get needsService => nextServiceDate?.isBefore(DateTime.now().add(const Duration(days: 7))) ?? false;
  bool get isAssigned => assignedTo != null;

  @override
  List<Object?> get props => [id, registrationNumber];

  Vehicle copyWith({
    String? id,
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    String? color,
    VehicleType? vehicleType,
    String? assignedTo,
    String? assignedToName,
    VehicleStatus? status,
    OperationalStatus? operationalStatus,
    double? currentOdometer,
    FuelType? fuelType,
    double? fuelCapacity,
    double? currentFuelLevel,
    double? purchasePrice,
    double? currentValue,
    double? maintenanceCost,
    double? fuelCost,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      vehicleType: vehicleType ?? this.vehicleType,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      status: status ?? this.status,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      fuelType: fuelType ?? this.fuelType,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      currentFuelLevel: currentFuelLevel ?? this.currentFuelLevel,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      fuelCost: fuelCost ?? this.fuelCost,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to parse from JSON
  static Vehicle fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'],
      registrationNumber: json['registrationNumber'],
      make: json['make'],
      model: json['vehicleModel'] ?? json['model'],
      year: json['year'],
      color: json['color'],
      vehicleType: VehicleType.fromString(json['vehicleType']),
      assignedTo: json['assignedTo']?['_id'],
      assignedToName: json['assignedTo'] != null
          ? '${json['assignedTo']['firstName']} ${json['assignedTo']['lastName']}'
          : null,
      status: VehicleStatus.fromString(json['status']),
      operationalStatus: OperationalStatus.fromString(json['operationalStatus']),
      currentOdometer: (json['currentOdometer'] ?? 0).toDouble(),
      fuelType: FuelType.fromString(json['fuelType']),
      fuelCapacity: (json['fuelCapacity'] ?? 0).toDouble(),
      currentFuelLevel: (json['currentFuelLevel'] ?? 0).toDouble(),
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      maintenanceCost: (json['maintenanceCost'] ?? 0).toDouble(),
      fuelCost: (json['fuelCost'] ?? 0).toDouble(),
      lastServiceDate: json['maintenanceSchedule']?['lastServiceDate'] != null
          ? DateTime.parse(json['maintenanceSchedule']['lastServiceDate'])
          : null,
      nextServiceDate: json['maintenanceSchedule']?['nextServiceDate'] != null
          ? DateTime.parse(json['maintenanceSchedule']['nextServiceDate'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}