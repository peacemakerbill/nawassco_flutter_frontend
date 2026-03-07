import 'package:equatable/equatable.dart';

enum ApprovalStatus {
  pending('Pending', 'pending'),
  approved('Approved', 'approved'),
  rejected('Rejected', 'rejected'),
  revised('Revised', 'revised');

  final String displayName;
  final String apiValue;

  const ApprovalStatus(this.displayName, this.apiValue);
}

enum TaskCompletionStatus {
  completed('Completed', 'completed'),
  partiallyCompleted('Partially Completed', 'partially_completed'),
  notCompleted('Not Completed', 'not_completed');

  final String displayName;
  final String apiValue;

  const TaskCompletionStatus(this.displayName, this.apiValue);
}

enum SeverityLevel {
  low('Low', 'low'),
  medium('Medium', 'medium'),
  high('High', 'high'),
  critical('Critical', 'critical');

  final String displayName;
  final String apiValue;

  const SeverityLevel(this.displayName, this.apiValue);
}

class CompletedTask extends Equatable {
  final String task;
  final String description;
  final int timeTaken;
  final TaskCompletionStatus status;
  final String? notes;

  const CompletedTask({
    required this.task,
    required this.description,
    required this.timeTaken,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [task, description, timeTaken, status, notes];

  Map<String, dynamic> toJson() => {
    'task': task,
    'description': description,
    'timeTaken': timeTaken,
    'status': status.apiValue,
    'notes': notes,
  };

  factory CompletedTask.fromJson(Map<String, dynamic> json) => CompletedTask(
    task: json['task'] ?? '',
    description: json['description'] ?? '',
    timeTaken: json['timeTaken'] ?? 0,
    status: TaskCompletionStatus.values.firstWhere(
          (e) => e.apiValue == json['status'],
      orElse: () => TaskCompletionStatus.notCompleted,
    ),
    notes: json['notes'],
  );
}

class ReportMaterialUsage extends Equatable {
  final String material;
  final String materialName;
  final int quantity;
  final String unit;
  final double cost;

  const ReportMaterialUsage({
    required this.material,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.cost,
  });

  @override
  List<Object?> get props => [material, materialName, quantity, unit, cost];

  Map<String, dynamic> toJson() => {
    'material': material,
    'materialName': materialName,
    'quantity': quantity,
    'unit': unit,
    'cost': cost,
  };

  factory ReportMaterialUsage.fromJson(Map<String, dynamic> json) => ReportMaterialUsage(
    material: json['material'] ?? '',
    materialName: json['materialName'] ?? json['material'] ?? '',
    quantity: json['quantity'] ?? 0,
    unit: json['unit'] ?? '',
    cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
  );
}

class Measurement extends Equatable {
  final String parameter;
  final double value;
  final String unit;
  final double? beforeValue;
  final double? afterValue;

  const Measurement({
    required this.parameter,
    required this.value,
    required this.unit,
    this.beforeValue,
    this.afterValue,
  });

  @override
  List<Object?> get props => [parameter, value, unit, beforeValue, afterValue];

  Map<String, dynamic> toJson() => {
    'parameter': parameter,
    'value': value,
    'unit': unit,
    'beforeValue': beforeValue,
    'afterValue': afterValue,
  };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
    parameter: json['parameter'] ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] ?? '',
    beforeValue: (json['beforeValue'] as num?)?.toDouble(),
    afterValue: (json['afterValue'] as num?)?.toDouble(),
  );
}

class QualityParameter extends Equatable {
  final String parameter;
  final int rating;
  final String comments;

  const QualityParameter({
    required this.parameter,
    required this.rating,
    required this.comments,
  });

  @override
  List<Object?> get props => [parameter, rating, comments];

  Map<String, dynamic> toJson() => {
    'parameter': parameter,
    'rating': rating,
    'comments': comments,
  };

  factory QualityParameter.fromJson(Map<String, dynamic> json) => QualityParameter(
    parameter: json['parameter'] ?? '',
    rating: json['rating'] ?? 0,
    comments: json['comments'] ?? '',
  );
}

class QualityCheck extends Equatable {
  final String checkedById;
  final String checkedByName;
  final String checkedByEmail;
  final DateTime checkDate;
  final List<QualityParameter> parameters;
  final int overallRating;
  final String comments;

  const QualityCheck({
    required this.checkedById,
    required this.checkedByName,
    required this.checkedByEmail,
    required this.checkDate,
    required this.parameters,
    required this.overallRating,
    required this.comments,
  });

  @override
  List<Object?> get props => [
    checkedById, checkedByName, checkedByEmail,
    checkDate, parameters, overallRating, comments
  ];

  Map<String, dynamic> toJson() => {
    'checkedBy': checkedById,
    'checkedByName': checkedByName,
    'checkedByEmail': checkedByEmail,
    'checkDate': checkDate.toIso8601String(),
    'parameters': parameters.map((p) => p.toJson()).toList(),
    'overallRating': overallRating,
    'comments': comments,
  };

  factory QualityCheck.fromJson(Map<String, dynamic> json) => QualityCheck(
    checkedById: json['checkedBy']?.toString() ?? '',
    checkedByName: json['checkedByName'] ?? '',
    checkedByEmail: json['checkedByEmail'] ?? '',
    checkDate: DateTime.parse(json['checkDate']),
    parameters: (json['parameters'] as List? ?? [])
        .map((p) => QualityParameter.fromJson(p))
        .toList(),
    overallRating: json['overallRating'] ?? 0,
    comments: json['comments'] ?? '',
  );
}

class IncidentReport extends Equatable {
  final String incidentType;
  final String description;
  final SeverityLevel severity;
  final List<String> actionsTaken;
  final DateTime reportedDate;

  const IncidentReport({
    required this.incidentType,
    required this.description,
    required this.severity,
    required this.actionsTaken,
    required this.reportedDate,
  });

  @override
  List<Object?> get props => [
    incidentType, description, severity,
    actionsTaken, reportedDate
  ];

  Map<String, dynamic> toJson() => {
    'incidentType': incidentType,
    'description': description,
    'severity': severity.apiValue,
    'actionsTaken': actionsTaken,
    'reportedDate': reportedDate.toIso8601String(),
  };

  factory IncidentReport.fromJson(Map<String, dynamic> json) => IncidentReport(
    incidentType: json['incidentType'] ?? '',
    description: json['description'] ?? '',
    severity: SeverityLevel.values.firstWhere(
          (e) => e.apiValue == json['severity'],
      orElse: () => SeverityLevel.low,
    ),
    actionsTaken: (json['actionsTaken'] as List?)?.cast<String>() ?? [],
    reportedDate: DateTime.parse(json['reportedDate']),
  );
}

class FieldServiceReport extends Equatable {
  final String id;
  final String reportNumber;
  final String workOrderId;
  final String workOrderNumber;
  final String workOrderTitle;
  final String technicianId;
  final String technicianName;
  final String technicianEmail;
  final String technicianPhone;

  final DateTime serviceDate;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final int totalTime;

  final String workSummary;
  final List<CompletedTask> tasksCompleted;
  final List<String> issuesFound;
  final List<String> recommendations;

  final List<ReportMaterialUsage> materialsUsed;
  final List<String> toolsUsed;
  final List<Measurement> measurements;

  final List<String> siteImages;
  final List<String> beforePhotos;
  final List<String> afterPhotos;

  final String? customerComments;
  final String customerSignature;
  final int customerSatisfaction;

  final QualityCheck? qualityCheck;
  final int? workQualityRating;

  final List<String> safetyObservations;
  final List<IncidentReport> incidents;

  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvalDate;
  final ApprovalStatus approvalStatus;

  final String createdById;
  final String createdByName;
  final String createdByEmail;
  final String updatedById;
  final String updatedByName;
  final String updatedByEmail;

  final DateTime createdAt;
  final DateTime updatedAt;

  const FieldServiceReport({
    required this.id,
    required this.reportNumber,
    required this.workOrderId,
    required this.workOrderNumber,
    required this.workOrderTitle,
    required this.technicianId,
    required this.technicianName,
    required this.technicianEmail,
    required this.technicianPhone,

    required this.serviceDate,
    required this.arrivalTime,
    required this.departureTime,
    required this.totalTime,

    required this.workSummary,
    this.tasksCompleted = const [],
    this.issuesFound = const [],
    this.recommendations = const [],

    this.materialsUsed = const [],
    this.toolsUsed = const [],
    this.measurements = const [],

    this.siteImages = const [],
    this.beforePhotos = const [],
    this.afterPhotos = const [],

    this.customerComments,
    required this.customerSignature,
    this.customerSatisfaction = 3,

    this.qualityCheck,
    this.workQualityRating,

    this.safetyObservations = const [],
    this.incidents = const [],

    this.approvedById,
    this.approvedByName,
    this.approvalDate,
    this.approvalStatus = ApprovalStatus.pending,

    required this.createdById,
    required this.createdByName,
    required this.createdByEmail,
    required this.updatedById,
    required this.updatedByName,
    required this.updatedByEmail,

    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, reportNumber, workOrderNumber, updatedAt];

  // Helper getters
  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;
  bool get canSubmit => !isApproved && !isRejected;
  bool get canApprove => isPending;
  bool get hasSignature => customerSignature.isNotEmpty;
  bool get hasSiteImages => siteImages.isNotEmpty;
  bool get hasBeforePhotos => beforePhotos.isNotEmpty;
  bool get hasAfterPhotos => afterPhotos.isNotEmpty;
  bool get hasIncidents => incidents.isNotEmpty;

  double get totalMaterialCost => materialsUsed.fold(0.0,
          (sum, material) => sum + (material.cost * material.quantity));

  int get totalTaskTime => tasksCompleted.fold(0,
          (sum, task) => sum + task.timeTaken);

  int get completedTasksCount =>
      tasksCompleted.where((task) => task.status == TaskCompletionStatus.completed).length;

  double get completionRate => tasksCompleted.isEmpty ? 0.0 :
  (completedTasksCount / tasksCompleted.length) * 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportNumber': reportNumber,
    'workOrder': workOrderId,
    'technician': technicianId,

    'serviceDate': serviceDate.toIso8601String(),
    'arrivalTime': arrivalTime.toIso8601String(),
    'departureTime': departureTime.toIso8601String(),
    'totalTime': totalTime,

    'workSummary': workSummary,
    'tasksCompleted': tasksCompleted.map((task) => task.toJson()).toList(),
    'issuesFound': issuesFound,
    'recommendations': recommendations,

    'materialsUsed': materialsUsed.map((mat) => mat.toJson()).toList(),
    'toolsUsed': toolsUsed,
    'measurements': measurements.map((m) => m.toJson()).toList(),

    'siteImages': siteImages,
    'beforePhotos': beforePhotos,
    'afterPhotos': afterPhotos,

    'customerComments': customerComments,
    'customerSignature': customerSignature,
    'customerSatisfaction': customerSatisfaction,

    'qualityCheck': qualityCheck?.toJson(),
    'workQualityRating': workQualityRating,

    'safetyObservations': safetyObservations,
    'incidents': incidents.map((incident) => incident.toJson()).toList(),

    'approvedBy': approvedById,
    'approvalDate': approvalDate?.toIso8601String(),
    'approvalStatus': approvalStatus.apiValue,

    'createdBy': createdById,
    'createdByName': createdByName,
    'createdByEmail': createdByEmail,
    'updatedBy': updatedById,
    'updatedByName': updatedByName,
    'updatedByEmail': updatedByEmail,

    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FieldServiceReport.fromJson(Map<String, dynamic> json) {
    // Handle nested work order data
    final workOrderData = json['workOrder'];
    final workOrderId = workOrderData is Map
        ? workOrderData['_id']?.toString() ?? json['workOrder'].toString()
        : json['workOrder'].toString();

    final workOrderNumber = workOrderData is Map
        ? workOrderData['workOrderNumber'] ?? ''
        : json['workOrderNumber'] ?? '';

    final workOrderTitle = workOrderData is Map
        ? workOrderData['title'] ?? ''
        : json['workOrderTitle'] ?? '';

    // Handle nested technician data
    final technicianData = json['technician'];
    final technicianId = technicianData is Map
        ? technicianData['_id']?.toString() ?? json['technician'].toString()
        : json['technician'].toString();

    final technicianName = technicianData is Map
        ? '${technicianData['firstName'] ?? ''} ${technicianData['lastName'] ?? ''}'.trim()
        : json['technicianName'] ?? json['technician']?.toString() ?? '';

    final technicianEmail = technicianData is Map
        ? technicianData['email'] ?? ''
        : json['technicianEmail'] ?? '';

    final technicianPhone = technicianData is Map
        ? technicianData['phoneNumber'] ?? ''
        : json['technicianPhone'] ?? '';

    return FieldServiceReport(
      id: json['_id'] ?? json['id'] ?? '',
      reportNumber: json['reportNumber'] ?? '',
      workOrderId: workOrderId,
      workOrderNumber: workOrderNumber,
      workOrderTitle: workOrderTitle,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianEmail: technicianEmail,
      technicianPhone: technicianPhone,

      serviceDate: DateTime.parse(json['serviceDate']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      departureTime: DateTime.parse(json['departureTime']),
      totalTime: json['totalTime'] ?? 0,

      workSummary: json['workSummary'] ?? '',
      tasksCompleted: (json['tasksCompleted'] as List? ?? [])
          .map((task) => CompletedTask.fromJson(task))
          .toList(),
      issuesFound: (json['issuesFound'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],

      materialsUsed: (json['materialsUsed'] as List? ?? [])
          .map((mat) => ReportMaterialUsage.fromJson(mat))
          .toList(),
      toolsUsed: (json['toolsUsed'] as List?)?.cast<String>() ?? [],
      measurements: (json['measurements'] as List? ?? [])
          .map((m) => Measurement.fromJson(m))
          .toList(),

      siteImages: (json['siteImages'] as List?)?.cast<String>() ?? [],
      beforePhotos: (json['beforePhotos'] as List?)?.cast<String>() ?? [],
      afterPhotos: (json['afterPhotos'] as List?)?.cast<String>() ?? [],

      customerComments: json['customerComments'],
      customerSignature: json['customerSignature'] ?? '',
      customerSatisfaction: json['customerSatisfaction'] ?? 3,

      qualityCheck: json['qualityCheck'] != null
          ? QualityCheck.fromJson(json['qualityCheck'])
          : null,
      workQualityRating: json['workQualityRating'],

      safetyObservations: (json['safetyObservations'] as List?)?.cast<String>() ?? [],
      incidents: (json['incidents'] as List? ?? [])
          .map((incident) => IncidentReport.fromJson(incident))
          .toList(),

      approvedById: json['approvedBy']?.toString(),
      approvedByName: json['approvedByName'] ??
          (json['approvedBy'] is Map
              ? '${json['approvedBy']['firstName'] ?? ''} ${json['approvedBy']['lastName'] ?? ''}'.trim()
              : null),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      approvalStatus: ApprovalStatus.values.firstWhere(
            (e) => e.apiValue == json['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),

      createdById: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName'] ?? '',
      createdByEmail: json['createdByEmail'] ?? '',
      updatedById: json['updatedBy']?.toString() ?? '',
      updatedByName: json['updatedByName'] ?? '',
      updatedByEmail: json['updatedByEmail'] ?? '',

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  FieldServiceReport copyWith({
    String? id,
    String? reportNumber,
    String? workOrderId,
    String? workOrderNumber,
    String? workOrderTitle,
    String? technicianId,
    String? technicianName,
    String? technicianEmail,
    String? technicianPhone,

    DateTime? serviceDate,
    DateTime? arrivalTime,
    DateTime? departureTime,
    int? totalTime,

    String? workSummary,
    List<CompletedTask>? tasksCompleted,
    List<String>? issuesFound,
    List<String>? recommendations,

    List<ReportMaterialUsage>? materialsUsed,
    List<String>? toolsUsed,
    List<Measurement>? measurements,

    List<String>? siteImages,
    List<String>? beforePhotos,
    List<String>? afterPhotos,

    String? customerComments,
    String? customerSignature,
    int? customerSatisfaction,

    QualityCheck? qualityCheck,
    int? workQualityRating,

    List<String>? safetyObservations,
    List<IncidentReport>? incidents,

    String? approvedById,
    String? approvedByName,
    DateTime? approvalDate,
    ApprovalStatus? approvalStatus,

    String? createdById,
    String? createdByName,
    String? createdByEmail,
    String? updatedById,
    String? updatedByName,
    String? updatedByEmail,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldServiceReport(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      workOrderId: workOrderId ?? this.workOrderId,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      workOrderTitle: workOrderTitle ?? this.workOrderTitle,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianEmail: technicianEmail ?? this.technicianEmail,
      technicianPhone: technicianPhone ?? this.technicianPhone,

      serviceDate: serviceDate ?? this.serviceDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      totalTime: totalTime ?? this.totalTime,

      workSummary: workSummary ?? this.workSummary,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      issuesFound: issuesFound ?? this.issuesFound,
      recommendations: recommendations ?? this.recommendations,

      materialsUsed: materialsUsed ?? this.materialsUsed,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      measurements: measurements ?? this.measurements,

      siteImages: siteImages ?? this.siteImages,
      beforePhotos: beforePhotos ?? this.beforePhotos,
      afterPhotos: afterPhotos ?? this.afterPhotos,

      customerComments: customerComments ?? this.customerComments,
      customerSignature: customerSignature ?? this.customerSignature,
      customerSatisfaction: customerSatisfaction ?? this.customerSatisfaction,

      qualityCheck: qualityCheck ?? this.qualityCheck,
      workQualityRating: workQualityRating ?? this.workQualityRating,

      safetyObservations: safetyObservations ?? this.safetyObservations,
      incidents: incidents ?? this.incidents,

      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      approvalDate: approvalDate ?? this.approvalDate,
      approvalStatus: approvalStatus ?? this.approvalStatus,

      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      updatedById: updatedById ?? this.updatedById,
      updatedByName: updatedByName ?? this.updatedByName,
      updatedByEmail: updatedByEmail ?? this.updatedByEmail,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// PDF Data Model for frontend generation
class FieldServiceReportPDFData {
  final FieldServiceReport report;
  final Map<String, dynamic> templateData;
  final Map<String, dynamic> options;
  final DateTime generatedAt;

  const FieldServiceReportPDFData({
    required this.report,
    required this.templateData,
    required this.options,
    required this.generatedAt,
  });

  factory FieldServiceReportPDFData.fromJson(Map<String, dynamic> json) {
    return FieldServiceReportPDFData(
      report: FieldServiceReport.fromJson(json['report']),
      templateData: json['template'] ?? {},
      options: json['options'] ?? {},
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}