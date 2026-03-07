import 'package:equatable/equatable.dart';

enum WorkOrderStatus {
  pending('Pending', 'pending'),
  scheduled('Scheduled', 'scheduled'),
  inProgress('In Progress', 'in_progress'),
  onHold('On Hold', 'on_hold'),
  completed('Completed', 'completed'),
  cancelled('Cancelled', 'cancelled'),
  failed('Failed', 'failed');

  final String displayName;
  final String apiValue;

  const WorkOrderStatus(this.displayName, this.apiValue);
}

enum WorkOrderPriority {
  low('Low', 'low'),
  medium('Medium', 'medium'),
  high('High', 'high'),
  urgent('Urgent', 'urgent');

  final String displayName;
  final String apiValue;

  const WorkOrderPriority(this.displayName, this.apiValue);
}

enum WorkOrderType {
  installation('Installation', 'installation'),
  repair('Repair', 'repair'),
  maintenance('Maintenance', 'maintenance'),
  inspection('Inspection', 'inspection'),
  meterReading('Meter Reading', 'meter_reading'),
  networkRepair('Network Repair', 'network_repair'),
  emergency('Emergency', 'emergency');

  final String displayName;
  final String apiValue;

  const WorkOrderType(this.displayName, this.apiValue);
}

enum TaskStatus {
  pending('Pending', 'pending'),
  inProgress('In Progress', 'in_progress'),
  completed('Completed', 'completed'),
  skipped('Skipped', 'skipped');

  final String displayName;
  final String apiValue;

  const TaskStatus(this.displayName, this.apiValue);
}

class LocationDetails extends Equatable {
  final String address;
  final String city;
  final String zone;
  final String? landmark;
  final String? accessInstructions;

  const LocationDetails({
    required this.address,
    required this.city,
    required this.zone,
    this.landmark,
    this.accessInstructions,
  });

  @override
  List<Object?> get props =>
      [address, city, zone, landmark, accessInstructions];

  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'zone': zone,
        'landmark': landmark,
        'accessInstructions': accessInstructions,
      };

  factory LocationDetails.fromJson(Map<String, dynamic> json) =>
      LocationDetails(
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        zone: json['zone'] ?? '',
        landmark: json['landmark'],
        accessInstructions: json['accessInstructions'],
      );
}

class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

class WorkOrderTask extends Equatable {
  final String task;
  final String description;
  final int estimatedTime;
  final int? actualTime;
  final TaskStatus status;
  final String? completedBy;
  final DateTime? completedAt;

  const WorkOrderTask({
    required this.task,
    required this.description,
    required this.estimatedTime,
    this.actualTime,
    this.status = TaskStatus.pending,
    this.completedBy,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        task,
        description,
        estimatedTime,
        actualTime,
        status,
        completedBy,
        completedAt,
      ];

  Map<String, dynamic> toJson() => {
        'task': task,
        'description': description,
        'estimatedTime': estimatedTime,
        'actualTime': actualTime,
        'status': status.apiValue,
        'completedBy': completedBy,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory WorkOrderTask.fromJson(Map<String, dynamic> json) => WorkOrderTask(
        task: json['task'] ?? '',
        description: json['description'] ?? '',
        estimatedTime: json['estimatedTime'] ?? 0,
        actualTime: json['actualTime'],
        status: TaskStatus.values.firstWhere(
          (e) => e.apiValue == json['status'],
          orElse: () => TaskStatus.pending,
        ),
        completedBy: json['completedBy'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

class RequiredMaterial extends Equatable {
  final String materialId;
  final String materialName;
  final int quantity;
  final String unit;
  final String? specifications;

  const RequiredMaterial({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.specifications,
  });

  @override
  List<Object?> get props =>
      [materialId, materialName, quantity, unit, specifications];

  Map<String, dynamic> toJson() => {
        'material': materialId,
        'materialName': materialName,
        'quantity': quantity,
        'unit': unit,
        'specifications': specifications,
      };

  factory RequiredMaterial.fromJson(Map<String, dynamic> json) =>
      RequiredMaterial(
        materialId: json['material'] ?? '',
        materialName: json['materialName'] ?? '',
        quantity: json['quantity'] ?? 0,
        unit: json['unit'] ?? '',
        specifications: json['specifications'],
      );
}

class MaterialUsage extends Equatable {
  final String materialId;
  final String materialName;
  final int quantityUsed;
  final String unit;
  final double cost;
  final String? batchNumber;

  const MaterialUsage({
    required this.materialId,
    required this.materialName,
    required this.quantityUsed,
    required this.unit,
    required this.cost,
    this.batchNumber,
  });

  @override
  List<Object?> get props =>
      [materialId, materialName, quantityUsed, unit, cost, batchNumber];

  Map<String, dynamic> toJson() => {
        'material': materialId,
        'materialName': materialName,
        'quantityUsed': quantityUsed,
        'unit': unit,
        'cost': cost,
        'batchNumber': batchNumber,
      };

  factory MaterialUsage.fromJson(Map<String, dynamic> json) => MaterialUsage(
        materialId: json['material'] ?? '',
        materialName: json['materialName'] ?? '',
        quantityUsed: json['quantityUsed'] ?? 0,
        unit: json['unit'] ?? '',
        cost: (json['cost'] as num).toDouble(),
        batchNumber: json['batchNumber'],
      );
}

class WorkOrder extends Equatable {
  final String id;
  final String workOrderNumber;
  final String title;
  final String description;
  final WorkOrderType type;
  final WorkOrderPriority priority;
  final String customerId;
  final String customerName;
  final LocationDetails location;
  final Coordinates coordinates;
  final List<String> assignedTechnicianIds;
  final List<String> assignedTechnicianNames;
  final String? teamLeadId;
  final String? teamLeadName;
  final int estimatedDuration;
  final DateTime scheduledDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final List<WorkOrderTask> tasks;
  final List<RequiredMaterial> requiredMaterials;
  final List<MaterialUsage> materialsUsed;
  final WorkOrderStatus status;
  final int progress;
  final String? completionNotes;
  final double estimatedCost;
  final double actualCost;
  final double laborCost;
  final double materialCost;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.customerId,
    required this.customerName,
    required this.location,
    required this.coordinates,
    this.assignedTechnicianIds = const [],
    this.assignedTechnicianNames = const [],
    this.teamLeadId,
    this.teamLeadName,
    required this.estimatedDuration,
    required this.scheduledDate,
    this.actualStartDate,
    this.actualEndDate,
    this.tasks = const [],
    this.requiredMaterials = const [],
    this.materialsUsed = const [],
    this.status = WorkOrderStatus.pending,
    this.progress = 0,
    this.completionNotes,
    required this.estimatedCost,
    this.actualCost = 0,
    this.laborCost = 0,
    this.materialCost = 0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, workOrderNumber, title, status, updatedAt];

  bool get isOverdue =>
      status != WorkOrderStatus.completed &&
      status != WorkOrderStatus.cancelled &&
      scheduledDate.isBefore(DateTime.now());

  bool get canStart =>
      status == WorkOrderStatus.scheduled || status == WorkOrderStatus.pending;

  bool get canComplete => status == WorkOrderStatus.inProgress;

  bool get isAssigned => assignedTechnicianIds.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'workOrderNumber': workOrderNumber,
        'title': title,
        'description': description,
        'workOrderType': type.apiValue,
        'priority': priority.apiValue,
        'customer': customerId,
        'customerName': customerName,
        'location': location.toJson(),
        'coordinates': coordinates.toJson(),
        'assignedTo': assignedTechnicianIds,
        'assignedTechnicianNames': assignedTechnicianNames,
        'teamLead': teamLeadId,
        'teamLeadName': teamLeadName,
        'estimatedDuration': estimatedDuration,
        'scheduledDate': scheduledDate.toIso8601String(),
        'actualStartDate': actualStartDate?.toIso8601String(),
        'actualEndDate': actualEndDate?.toIso8601String(),
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'requiredMaterials':
            requiredMaterials.map((mat) => mat.toJson()).toList(),
        'materialsUsed': materialsUsed.map((mat) => mat.toJson()).toList(),
        'status': status.apiValue,
        'progress': progress,
        'completionNotes': completionNotes,
        'estimatedCost': estimatedCost,
        'actualCost': actualCost,
        'laborCost': laborCost,
        'materialCost': materialCost,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    final tasks = (json['tasks'] as List? ?? [])
        .map((task) => WorkOrderTask.fromJson(task))
        .toList();

    final requiredMaterials = (json['requiredMaterials'] as List? ?? [])
        .map((mat) => RequiredMaterial.fromJson(mat))
        .toList();

    final materialsUsed = (json['materialsUsed'] as List? ?? [])
        .map((mat) => MaterialUsage.fromJson(mat))
        .toList();

    final assignedTo =
        (json['assignedTo'] as List? ?? []).map((id) => id.toString()).toList();

    final assignedNames = (json['assignedTechnicianNames'] as List? ?? [])
        .map((name) => name.toString())
        .toList();

    return WorkOrder(
      id: json['_id'] ?? json['id'] ?? '',
      workOrderNumber: json['workOrderNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: WorkOrderType.values.firstWhere(
        (e) => e.apiValue == json['workOrderType'],
        orElse: () => WorkOrderType.repair,
      ),
      priority: WorkOrderPriority.values.firstWhere(
        (e) => e.apiValue == json['priority'],
        orElse: () => WorkOrderPriority.medium,
      ),
      customerId: json['customer']?.toString() ?? '',
      customerName: json['customerName'] ??
          (json['customer'] is Map
              ? '${json['customer']['firstName']} ${json['customer']['lastName']}'
              : ''),
      location: LocationDetails.fromJson(json['location'] ?? {}),
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      assignedTechnicianIds: assignedTo,
      assignedTechnicianNames: assignedNames,
      teamLeadId: json['teamLead']?.toString(),
      teamLeadName: json['teamLeadName'] ??
          (json['teamLead'] is Map
              ? '${json['teamLead']['firstName']} ${json['teamLead']['lastName']}'
              : null),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      scheduledDate: DateTime.parse(json['scheduledDate']),
      actualStartDate: json['actualStartDate'] != null
          ? DateTime.parse(json['actualStartDate'])
          : null,
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
      tasks: tasks,
      requiredMaterials: requiredMaterials,
      materialsUsed: materialsUsed,
      status: WorkOrderStatus.values.firstWhere(
        (e) => e.apiValue == json['status'],
        orElse: () => WorkOrderStatus.pending,
      ),
      progress: json['progress'] ?? 0,
      completionNotes: json['completionNotes'],
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      actualCost: (json['actualCost'] as num?)?.toDouble() ?? 0,
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0,
      materialCost: (json['materialCost'] as num?)?.toDouble() ?? 0,
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  WorkOrder copyWith({
    String? id,
    String? workOrderNumber,
    String? title,
    String? description,
    WorkOrderType? type,
    WorkOrderPriority? priority,
    String? customerId,
    String? customerName,
    LocationDetails? location,
    Coordinates? coordinates,
    List<String>? assignedTechnicianIds,
    List<String>? assignedTechnicianNames,
    String? teamLeadId,
    String? teamLeadName,
    int? estimatedDuration,
    DateTime? scheduledDate,
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    List<WorkOrderTask>? tasks,
    List<RequiredMaterial>? requiredMaterials,
    List<MaterialUsage>? materialsUsed,
    WorkOrderStatus? status,
    int? progress,
    String? completionNotes,
    double? estimatedCost,
    double? actualCost,
    double? laborCost,
    double? materialCost,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      assignedTechnicianIds:
          assignedTechnicianIds ?? this.assignedTechnicianIds,
      assignedTechnicianNames:
          assignedTechnicianNames ?? this.assignedTechnicianNames,
      teamLeadId: teamLeadId ?? this.teamLeadId,
      teamLeadName: teamLeadName ?? this.teamLeadName,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      tasks: tasks ?? this.tasks,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      completionNotes: completionNotes ?? this.completionNotes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      laborCost: laborCost ?? this.laborCost,
      materialCost: materialCost ?? this.materialCost,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
