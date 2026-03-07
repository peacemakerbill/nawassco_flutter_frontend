import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MaintenanceTargetType {
  vehicle('Vehicle', Icons.directions_car, Colors.blue),
  tool('Tool', Icons.build, Colors.orange),
  equipment('Equipment', Icons.precision_manufacturing, Colors.green),
  infrastructure('Infrastructure', Icons.architecture, Colors.purple),
  facility('Facility', Icons.business, Colors.teal);

  final String displayName;
  final IconData icon;
  final Color color;

  const MaintenanceTargetType(this.displayName, this.icon, this.color);
}

enum ScheduleType {
  preventive('Preventive', Icons.warning_amber_rounded, Colors.green),
  corrective('Corrective', Icons.handyman_rounded, Colors.orange),
  predictive('Predictive', Icons.analytics, Colors.blue),
  emergency('Emergency', Icons.warning, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const ScheduleType(this.displayName, this.icon, this.color);
}

enum MaintenanceStatus {
  pending('Pending', Icons.pending, Colors.orange),
  scheduled('Scheduled', Icons.schedule, Colors.blue),
  inProgress('In Progress', Icons.build_circle, Colors.deepOrange),
  completed('Completed', Icons.check_circle, Colors.green),
  overdue('Overdue', Icons.warning, Colors.red),
  cancelled('Cancelled', Icons.cancel, Colors.grey);

  final String displayName;
  final IconData icon;
  final Color color;

  const MaintenanceStatus(this.displayName, this.icon, this.color);
}

enum PriorityLevel {
  critical('Critical', Icons.error, Colors.red),
  high('High', Icons.warning, Colors.orange),
  medium('Medium', Icons.info, Colors.blue),
  low('Low', Icons.low_priority, Colors.green);

  final String displayName;
  final IconData icon;
  final Color color;

  const PriorityLevel(this.displayName, this.icon, this.color);
}

enum Frequency {
  daily('Daily', Icons.today, Colors.blue),
  weekly('Weekly', Icons.weekend, Colors.green),
  biWeekly('Bi-Weekly', Icons.calendar_view_week, Colors.orange),
  monthly('Monthly', Icons.calendar_today, Colors.purple),
  quarterly('Quarterly', Icons.event_note, Colors.teal),
  biAnnual('Bi-Annual', Icons.calendar_month, Colors.indigo),
  annual('Annual', Icons.event, Colors.deepOrange),
  custom('Custom', Icons.settings, Colors.grey);

  final String displayName;
  final IconData icon;
  final Color color;

  const Frequency(this.displayName, this.icon, this.color);
}

enum TaskStatus {
  pending('Pending', Icons.pending, Colors.orange),
  inProgress('In Progress', Icons.build_circle, Colors.blue),
  completed('Completed', Icons.check_circle, Colors.green),
  skipped('Skipped', Icons.next_plan, Colors.grey);

  final String displayName;
  final IconData icon;
  final Color color;

  const TaskStatus(this.displayName, this.icon, this.color);
}

class MaintenanceTask extends Equatable {
  final String task;
  final String description;
  final double estimatedTime;
  final double? actualTime;
  final TaskStatus status;
  final String? completedBy;
  final DateTime? completedAt;

  const MaintenanceTask({
    required this.task,
    required this.description,
    required this.estimatedTime,
    this.actualTime,
    this.status = TaskStatus.pending,
    this.completedBy,
    this.completedAt,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      task: json['task'],
      description: json['description'],
      estimatedTime: (json['estimatedTime'] as num).toDouble(),
      actualTime: json['actualTime'] != null
          ? (json['actualTime'] as num).toDouble()
          : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      completedBy: json['completedBy'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'description': description,
      'estimatedTime': estimatedTime,
      'actualTime': actualTime,
      'status': status.name,
      'completedBy': completedBy,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  MaintenanceTask copyWith({
    String? task,
    String? description,
    double? estimatedTime,
    double? actualTime,
    TaskStatus? status,
    String? completedBy,
    DateTime? completedAt,
  }) {
    return MaintenanceTask(
      task: task ?? this.task,
      description: description ?? this.description,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
    );
  }

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
}

class RequiredMaterial extends Equatable {
  final String material;
  final double quantity;
  final String unit;
  final String? specifications;

  const RequiredMaterial({
    required this.material,
    required this.quantity,
    required this.unit,
    this.specifications,
  });

  factory RequiredMaterial.fromJson(Map<String, dynamic> json) {
    return RequiredMaterial(
      material: json['material'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      specifications: json['specifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material': material,
      'quantity': quantity,
      'unit': unit,
      'specifications': specifications,
    };
  }

  @override
  List<Object?> get props => [material, quantity, unit, specifications];
}

class MaintenanceHistory extends Equatable {
  final DateTime maintenanceDate;
  final String completedBy;
  final List<String> tasksCompleted;
  final String notes;
  final double cost;
  final DateTime nextDueDate;

  const MaintenanceHistory({
    required this.maintenanceDate,
    required this.completedBy,
    required this.tasksCompleted,
    required this.notes,
    required this.cost,
    required this.nextDueDate,
  });

  factory MaintenanceHistory.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistory(
      maintenanceDate: DateTime.parse(json['maintenanceDate']),
      completedBy: json['completedBy'],
      tasksCompleted: List<String>.from(json['tasksCompleted']),
      notes: json['notes'],
      cost: (json['cost'] as num).toDouble(),
      nextDueDate: DateTime.parse(json['nextDueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenanceDate': maintenanceDate.toIso8601String(),
      'completedBy': completedBy,
      'tasksCompleted': tasksCompleted,
      'notes': notes,
      'cost': cost,
      'nextDueDate': nextDueDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        maintenanceDate,
        completedBy,
        tasksCompleted,
        notes,
        cost,
        nextDueDate,
      ];
}

class MaintenanceSchedule extends Equatable {
  final String id;
  final String scheduleNumber;
  final String title;
  final String description;

  // Maintenance Target
  final MaintenanceTargetType targetType;
  final String targetId;
  final String targetName;

  // Schedule Details
  final ScheduleType scheduleType;
  final Frequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final DateTime? lastCompletedDate;

  // Maintenance Details
  final List<MaintenanceTask> tasks;
  final double estimatedDuration;
  final List<String> requiredTools;
  final List<RequiredMaterial> requiredMaterials;

  // Assignment
  final List<String> assignedTo;
  final String? team;
  final String? supervisor;

  // Status & Tracking
  final MaintenanceStatus status;
  final double completionRate;
  final List<MaintenanceHistory> history;

  // Costs
  final double estimatedCost;
  final double actualCost;

  // Priority
  final PriorityLevel priority;

  // Metadata
  final String createdBy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceSchedule({
    required this.id,
    required this.scheduleNumber,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.scheduleType,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.lastCompletedDate,
    required this.tasks,
    required this.estimatedDuration,
    required this.requiredTools,
    required this.requiredMaterials,
    required this.assignedTo,
    this.team,
    this.supervisor,
    required this.status,
    required this.completionRate,
    required this.history,
    required this.estimatedCost,
    required this.actualCost,
    required this.priority,
    required this.createdBy,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    return MaintenanceSchedule(
      id: json['_id'] ?? json['id'],
      scheduleNumber: json['scheduleNumber'],
      title: json['title'],
      description: json['description'],
      targetType: MaintenanceTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => MaintenanceTargetType.vehicle,
      ),
      targetId: json['targetId'] is String
          ? json['targetId']
          : json['targetId']['_id'],
      targetName: json['targetName'],
      scheduleType: ScheduleType.values.firstWhere(
        (e) => e.name == json['scheduleType'],
        orElse: () => ScheduleType.preventive,
      ),
      frequency: Frequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => Frequency.monthly,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      nextDueDate: DateTime.parse(json['nextDueDate']),
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
      tasks: (json['tasks'] as List?)
              ?.map((task) => MaintenanceTask.fromJson(task))
              .toList() ??
          [],
      estimatedDuration: (json['estimatedDuration'] as num).toDouble(),
      requiredTools: List<String>.from(json['requiredTools']
              ?.map((tool) => tool is String ? tool : tool['_id']) ??
          []),
      requiredMaterials: (json['requiredMaterials'] as List?)
              ?.map((material) => RequiredMaterial.fromJson(material))
              .toList() ??
          [],
      assignedTo: List<String>.from(json['assignedTo']
              ?.map((tech) => tech is String ? tech : tech['_id']) ??
          []),
      team: json['team']?['_id'],
      supervisor: json['supervisor']?['_id'],
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      history: (json['history'] as List?)
              ?.map((history) => MaintenanceHistory.fromJson(history))
              .toList() ??
          [],
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      actualCost: (json['actualCost'] as num?)?.toDouble() ?? 0,
      priority: PriorityLevel.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => PriorityLevel.medium,
      ),
      createdBy: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']['_id'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'targetType': targetType.name,
      'targetId': targetId,
      'targetName': targetName,
      'scheduleType': scheduleType.name,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'requiredTools': requiredTools,
      'requiredMaterials':
          requiredMaterials.map((material) => material.toJson()).toList(),
      'assignedTo': assignedTo,
      'team': team,
      'supervisor': supervisor,
      'estimatedCost': estimatedCost,
      'priority': priority.name,
    };
  }

  MaintenanceSchedule copyWith({
    String? id,
    String? scheduleNumber,
    String? title,
    String? description,
    MaintenanceTargetType? targetType,
    String? targetId,
    String? targetName,
    ScheduleType? scheduleType,
    Frequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    DateTime? lastCompletedDate,
    List<MaintenanceTask>? tasks,
    double? estimatedDuration,
    List<String>? requiredTools,
    List<RequiredMaterial>? requiredMaterials,
    List<String>? assignedTo,
    String? team,
    String? supervisor,
    MaintenanceStatus? status,
    double? completionRate,
    List<MaintenanceHistory>? history,
    double? estimatedCost,
    double? actualCost,
    PriorityLevel? priority,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      scheduleNumber: scheduleNumber ?? this.scheduleNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      scheduleType: scheduleType ?? this.scheduleType,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      tasks: tasks ?? this.tasks,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      requiredTools: requiredTools ?? this.requiredTools,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      assignedTo: assignedTo ?? this.assignedTo,
      team: team ?? this.team,
      supervisor: supervisor ?? this.supervisor,
      status: status ?? this.status,
      completionRate: completionRate ?? this.completionRate,
      history: history ?? this.history,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue =>
      nextDueDate.isBefore(DateTime.now()) &&
      (status == MaintenanceStatus.pending ||
          status == MaintenanceStatus.scheduled);

  bool get needsAttention =>
      isOverdue || status == MaintenanceStatus.inProgress;

  double get costVariance => actualCost - estimatedCost;

  bool get isCostOverBudget => costVariance > 0;

  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;

  String get dueStatus {
    if (isOverdue) return 'Overdue';
    if (daysUntilDue <= 7) return 'Due Soon';
    if (daysUntilDue <= 30) return 'Upcoming';
    return 'Scheduled';
  }

  Color get dueStatusColor {
    switch (dueStatus) {
      case 'Overdue':
        return Colors.red;
      case 'Due Soon':
        return Colors.orange;
      case 'Upcoming':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  List<Object?> get props => [id, scheduleNumber];
}
