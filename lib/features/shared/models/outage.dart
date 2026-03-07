import 'dart:convert';

class Outage {
  final String? id;
  final String outageNumber;
  final String title;
  final String description;
  final OutageType type;
  final OutageCategory category;
  final OutageStatus status;
  final PriorityLevel priority;
  final List<AffectedArea> affectedAreas;
  final int estimatedAffectedCustomers;
  final int? actualAffectedCustomers;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int estimatedDuration;
  final int? actualDuration;
  final OutageCause? cause;
  final String? rootCause;
  final String? resolutionDetails;
  final ResolutionMethod? resolutionMethod;
  final List<String> assignedCrew;
  final List<Resource> requiredResources;
  final List<Equipment> equipmentUsed;
  final List<Notification> publicNotifications;
  final List<InternalCommunication> internalCommunications;
  final ImpactAssessment impact;
  final List<CustomerUpdate> customerUpdates;
  final List<OutageDocument> documents;
  final List<String> images;
  final String reportedBy;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  Outage({
    this.id,
    required this.outageNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.status,
    required this.priority,
    required this.affectedAreas,
    required this.estimatedAffectedCustomers,
    this.actualAffectedCustomers,
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.estimatedDuration,
    this.actualDuration,
    this.cause,
    this.rootCause,
    this.resolutionDetails,
    this.resolutionMethod,
    required this.assignedCrew,
    required this.requiredResources,
    required this.equipmentUsed,
    required this.publicNotifications,
    required this.internalCommunications,
    required this.impact,
    required this.customerUpdates,
    required this.documents,
    required this.images,
    required this.reportedBy,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  factory Outage.fromJson(Map<String, dynamic> json) {
    return Outage(
      id: json['_id'],
      outageNumber: json['outageNumber'],
      title: json['title'],
      description: json['description'],
      type: OutageType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'].toUpperCase(),
        orElse: () => OutageType.EMERGENCY,
      ),
      category: OutageCategory.values.firstWhere(
            (e) => e.toString().split('.').last == json['category'].toUpperCase(),
        orElse: () => OutageCategory.DISTRIBUTION,
      ),
      status: OutageStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'].toUpperCase(),
        orElse: () => OutageStatus.REPORTED,
      ),
      priority: PriorityLevel.values.firstWhere(
            (e) => e.toString().split('.').last == json['priority'].toUpperCase(),
        orElse: () => PriorityLevel.MEDIUM,
      ),
      affectedAreas: (json['affectedAreas'] as List<dynamic>?)
          ?.map((area) => AffectedArea.fromJson(area))
          .toList() ??
          [],
      estimatedAffectedCustomers: json['estimatedAffectedCustomers'] ?? 0,
      actualAffectedCustomers: json['actualAffectedCustomers'],
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      scheduledEnd: json['scheduledEnd'] != null
          ? DateTime.parse(json['scheduledEnd'])
          : null,
      actualStart: json['actualStart'] != null
          ? DateTime.parse(json['actualStart'])
          : null,
      actualEnd: json['actualEnd'] != null
          ? DateTime.parse(json['actualEnd'])
          : null,
      estimatedDuration: json['estimatedDuration'] ?? 0,
      actualDuration: json['actualDuration'],
      cause: json['cause'] != null
          ? OutageCause.values.firstWhere(
            (e) => e.toString().split('.').last == json['cause'].toUpperCase(),
        orElse: () => OutageCause.UNKNOWN,
      )
          : null,
      rootCause: json['rootCause'],
      resolutionDetails: json['resolutionDetails'],
      resolutionMethod: json['resolutionMethod'] != null
          ? ResolutionMethod.values.firstWhere(
            (e) => e.toString().split('.').last ==
            json['resolutionMethod'].toUpperCase(),
        orElse: () => ResolutionMethod.REPAIR,
      )
          : null,
      assignedCrew: List<String>.from(json['assignedCrew'] ?? []),
      requiredResources: (json['requiredResources'] as List<dynamic>?)
          ?.map((resource) => Resource.fromJson(resource))
          .toList() ??
          [],
      equipmentUsed: (json['equipmentUsed'] as List<dynamic>?)
          ?.map((equipment) => Equipment.fromJson(equipment))
          .toList() ??
          [],
      publicNotifications: (json['publicNotifications'] as List<dynamic>?)
          ?.map((notification) => Notification.fromJson(notification))
          .toList() ??
          [],
      internalCommunications: (json['internalCommunications'] as List<dynamic>?)
          ?.map((comm) => InternalCommunication.fromJson(comm))
          .toList() ??
          [],
      impact: ImpactAssessment.fromJson(json['impact'] ?? {}),
      customerUpdates: (json['customerUpdates'] as List<dynamic>?)
          ?.map((update) => CustomerUpdate.fromJson(update))
          .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
          ?.map((doc) => OutageDocument.fromJson(doc))
          .toList() ??
          [],
      images: List<String>.from(json['images'] ?? []),
      reportedBy: json['reportedBy'] ?? '',
      approvedBy: json['approvedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'outageNumber': outageNumber,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last.toLowerCase(),
      'category': category.toString().split('.').last.toLowerCase(),
      'status': status.toString().split('.').last.toLowerCase(),
      'priority': priority.toString().split('.').last.toLowerCase(),
      'affectedAreas': affectedAreas.map((area) => area.toJson()).toList(),
      'estimatedAffectedCustomers': estimatedAffectedCustomers,
      if (actualAffectedCustomers != null)
        'actualAffectedCustomers': actualAffectedCustomers,
      if (scheduledStart != null) 'scheduledStart': scheduledStart!.toIso8601String(),
      if (scheduledEnd != null) 'scheduledEnd': scheduledEnd!.toIso8601String(),
      if (actualStart != null) 'actualStart': actualStart!.toIso8601String(),
      if (actualEnd != null) 'actualEnd': actualEnd!.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      if (actualDuration != null) 'actualDuration': actualDuration,
      if (cause != null) 'cause': cause!.toString().split('.').last.toLowerCase(),
      if (rootCause != null) 'rootCause': rootCause,
      if (resolutionDetails != null) 'resolutionDetails': resolutionDetails,
      if (resolutionMethod != null)
        'resolutionMethod': resolutionMethod!.toString().split('.').last.toLowerCase(),
      'assignedCrew': assignedCrew,
      'requiredResources': requiredResources.map((r) => r.toJson()).toList(),
      'equipmentUsed': equipmentUsed.map((e) => e.toJson()).toList(),
      'publicNotifications': publicNotifications.map((n) => n.toJson()).toList(),
      'internalCommunications': internalCommunications.map((c) => c.toJson()).toList(),
      'impact': impact.toJson(),
      'customerUpdates': customerUpdates.map((c) => c.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'images': images,
      'reportedBy': reportedBy,
      if (approvedBy != null) 'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
    };
  }

  Outage copyWith({
    String? id,
    String? outageNumber,
    String? title,
    String? description,
    OutageType? type,
    OutageCategory? category,
    OutageStatus? status,
    PriorityLevel? priority,
    List<AffectedArea>? affectedAreas,
    int? estimatedAffectedCustomers,
    int? actualAffectedCustomers,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    int? estimatedDuration,
    int? actualDuration,
    OutageCause? cause,
    String? rootCause,
    String? resolutionDetails,
    ResolutionMethod? resolutionMethod,
    List<String>? assignedCrew,
    List<Resource>? requiredResources,
    List<Equipment>? equipmentUsed,
    List<Notification>? publicNotifications,
    List<InternalCommunication>? internalCommunications,
    ImpactAssessment? impact,
    List<CustomerUpdate>? customerUpdates,
    List<OutageDocument>? documents,
    List<String>? images,
    String? reportedBy,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) {
    return Outage(
      id: id ?? this.id,
      outageNumber: outageNumber ?? this.outageNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      estimatedAffectedCustomers:
      estimatedAffectedCustomers ?? this.estimatedAffectedCustomers,
      actualAffectedCustomers:
      actualAffectedCustomers ?? this.actualAffectedCustomers,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      cause: cause ?? this.cause,
      rootCause: rootCause ?? this.rootCause,
      resolutionDetails: resolutionDetails ?? this.resolutionDetails,
      resolutionMethod: resolutionMethod ?? this.resolutionMethod,
      assignedCrew: assignedCrew ?? this.assignedCrew,
      requiredResources: requiredResources ?? this.requiredResources,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      publicNotifications: publicNotifications ?? this.publicNotifications,
      internalCommunications:
      internalCommunications ?? this.internalCommunications,
      impact: impact ?? this.impact,
      customerUpdates: customerUpdates ?? this.customerUpdates,
      documents: documents ?? this.documents,
      images: images ?? this.images,
      reportedBy: reportedBy ?? this.reportedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

// Enums matching TypeScript model
enum OutageType {
  PLANNED,
  EMERGENCY,
  REPAIR,
  MAINTENANCE,
  CONSTRUCTION,
  POWER_OUTAGE,
  QUALITY_ISSUE,
}

enum OutageCategory {
  TREATMENT_PLANT,
  DISTRIBUTION,
  STORAGE,
  PUMPING,
  TRANSMISSION,
}

enum OutageStatus {
  REPORTED,
  CONFIRMED,
  IN_PROGRESS,
  ON_HOLD,
  RESOLVED,
  VERIFIED,
  CLOSED,
  CANCELLED,
}

enum PriorityLevel {
  LOW,
  MEDIUM,
  HIGH,
  CRITICAL,
}

enum OutageCause {
  EQUIPMENT_FAILURE,
  POWER_FAILURE,
  MAINTENANCE,
  CONSTRUCTION,
  NATURAL_DISASTER,
  VANDALISM,
  PIPEBURST,
  LEAKAGE,
  QUALITY_CONTAMINATION,
  UNKNOWN,
}

enum ResolutionMethod {
  REPAIR,
  REPLACEMENT,
  BYPASS,
  ISOLATION,
  CLEANING,
  CHEMICAL_TREATMENT,
}

// Helper classes for nested objects
class AffectedArea {
  final String zone;
  final String subzone;
  final List<Coordinate> coordinates;
  final int estimatedCustomers;
  final int waterBowsersDeployed;
  final bool alternativeSupply;

  AffectedArea({
    required this.zone,
    required this.subzone,
    required this.coordinates,
    required this.estimatedCustomers,
    this.waterBowsersDeployed = 0,
    this.alternativeSupply = false,
  });

  factory AffectedArea.fromJson(Map<String, dynamic> json) {
    return AffectedArea(
      zone: json['zone'] ?? '',
      subzone: json['subzone'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((coord) => Coordinate.fromJson(coord))
          .toList() ??
          [],
      estimatedCustomers: json['estimatedCustomers'] ?? 0,
      waterBowsersDeployed: json['waterBowsersDeployed'] ?? 0,
      alternativeSupply: json['alternativeSupply'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'subzone': subzone,
      'coordinates': coordinates.map((c) => c.toJson()).toList(),
      'estimatedCustomers': estimatedCustomers,
      'waterBowsersDeployed': waterBowsersDeployed,
      'alternativeSupply': alternativeSupply,
    };
  }
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({required this.latitude, required this.longitude});

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Resource {
  final ResourceType type;
  final int quantity;
  final String unit;
  final ResourceStatus status;

  Resource({
    required this.type,
    required this.quantity,
    required this.unit,
    required this.status,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      type: ResourceType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'].toUpperCase(),
        orElse: () => ResourceType.PERSONNEL,
      ),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      status: ResourceStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'].toUpperCase(),
        orElse: () => ResourceStatus.REQUESTED,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last.toLowerCase(),
      'quantity': quantity,
      'unit': unit,
      'status': status.toString().split('.').last.toLowerCase(),
    };
  }
}

enum ResourceType {
  PERSONNEL,
  VEHICLE,
  EQUIPMENT,
  MATERIAL,
  WATER_BOWSER,
}

enum ResourceStatus {
  REQUESTED,
  DISPATCHED,
  ON_SITE,
  RETURNED,
}

class Equipment {
  final String name;
  final EquipmentType type;
  final int quantity;
  final EquipmentCondition condition;

  Equipment({
    required this.name,
    required this.type,
    required this.quantity,
    required this.condition,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'] ?? '',
      type: EquipmentType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'].toUpperCase(),
        orElse: () => EquipmentType.EXCAVATOR,
      ),
      quantity: json['quantity'] ?? 0,
      condition: EquipmentCondition.values.firstWhere(
            (e) => e.toString().split('.').last == json['condition'].toUpperCase(),
        orElse: () => EquipmentCondition.GOOD,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last.toLowerCase(),
      'quantity': quantity,
      'condition': condition.toString().split('.').last.toLowerCase(),
    };
  }
}

enum EquipmentType {
  EXCAVATOR,
  PUMP,
  GENERATOR,
  WELDING,
  TESTING,
  SAFETY,
}

enum EquipmentCondition {
  EXCELLENT,
  GOOD,
  FAIR,
  POOR,
}

class Notification {
  final NotificationType type;
  final NotificationChannel channel;
  final String message;
  final DateTime sentAt;
  final int recipients;
  final NotificationStatus status;

  Notification({
    required this.type,
    required this.channel,
    required this.message,
    required this.sentAt,
    required this.recipients,
    required this.status,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      type: NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'].toUpperCase(),
        orElse: () => NotificationType.OUTAGE_ALERT,
      ),
      channel: NotificationChannel.values.firstWhere(
            (e) => e.toString().split('.').last == json['channel'].toUpperCase(),
        orElse: () => NotificationChannel.SMS,
      ),
      message: json['message'] ?? '',
      sentAt: DateTime.parse(json['sentAt']),
      recipients: json['recipients'] ?? 0,
      status: NotificationStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'].toUpperCase(),
        orElse: () => NotificationStatus.SENT,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last.toLowerCase(),
      'channel': channel.toString().split('.').last.toLowerCase(),
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'recipients': recipients,
      'status': status.toString().split('.').last.toLowerCase(),
    };
  }
}

enum NotificationType {
  OUTAGE_ALERT,
  PROGRESS_UPDATE,
  RESOLUTION,
  PREVENTIVE,
  EMERGENCY,
}

enum NotificationChannel {
  SMS,
  EMAIL,
  MOBILE_APP,
  WEBSITE,
  SOCIAL_MEDIA,
  LOCAL_MEDIA,
}

enum NotificationStatus {
  DRAFT,
  SENT,
  FAILED,
  SCHEDULED,
}

class InternalCommunication {
  final String id;
  final String from;
  final List<String> to;
  final String message;
  final PriorityLevel priority;
  final DateTime sentAt;
  final List<String> readBy;

  InternalCommunication({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.priority,
    required this.sentAt,
    required this.readBy,
  });

  factory InternalCommunication.fromJson(Map<String, dynamic> json) {
    return InternalCommunication(
      id: json['_id'] ?? '',
      from: json['from'] ?? '',
      to: List<String>.from(json['to'] ?? []),
      message: json['message'] ?? '',
      priority: PriorityLevel.values.firstWhere(
            (e) => e.toString().split('.').last == json['priority'].toUpperCase(),
        orElse: () => PriorityLevel.MEDIUM,
      ),
      sentAt: DateTime.parse(json['sentAt']),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'priority': priority.toString().split('.').last.toLowerCase(),
      'sentAt': sentAt.toIso8601String(),
      'readBy': readBy,
    };
  }
}

class ImpactAssessment {
  final int residentialCustomers;
  final int commercialCustomers;
  final int industrialCustomers;
  final List<String> criticalFacilities;
  final PressureImpact waterPressureImpact;
  final bool waterQualityIssues;
  final String? qualityIssuesDescription;

  ImpactAssessment({
    required this.residentialCustomers,
    required this.commercialCustomers,
    required this.industrialCustomers,
    required this.criticalFacilities,
    required this.waterPressureImpact,
    this.waterQualityIssues = false,
    this.qualityIssuesDescription,
  });

  factory ImpactAssessment.fromJson(Map<String, dynamic> json) {
    return ImpactAssessment(
      residentialCustomers: json['residentialCustomers'] ?? 0,
      commercialCustomers: json['commercialCustomers'] ?? 0,
      industrialCustomers: json['industrialCustomers'] ?? 0,
      criticalFacilities: List<String>.from(json['criticalFacilities'] ?? []),
      waterPressureImpact: PressureImpact.values.firstWhere(
            (e) => e.toString().split('.').last ==
            json['waterPressureImpact'].toUpperCase(),
        orElse: () => PressureImpact.NONE,
      ),
      waterQualityIssues: json['waterQualityIssues'] ?? false,
      qualityIssuesDescription: json['qualityIssuesDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residentialCustomers': residentialCustomers,
      'commercialCustomers': commercialCustomers,
      'industrialCustomers': industrialCustomers,
      'criticalFacilities': criticalFacilities,
      'waterPressureImpact':
      waterPressureImpact.toString().split('.').last.toLowerCase(),
      'waterQualityIssues': waterQualityIssues,
      if (qualityIssuesDescription != null)
        'qualityIssuesDescription': qualityIssuesDescription,
    };
  }
}

enum PressureImpact {
  NONE,
  LOW,
  MEDIUM,
  HIGH,
  COMPLETE,
}

class CustomerUpdate {
  final String id;
  final DateTime timestamp;
  final String message;
  final String postedBy;
  final UpdateStatus status;

  CustomerUpdate({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.postedBy,
    required this.status,
  });

  factory CustomerUpdate.fromJson(Map<String, dynamic> json) {
    return CustomerUpdate(
      id: json['_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'] ?? '',
      postedBy: json['postedBy'] ?? '',
      status: UpdateStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'].toUpperCase(),
        orElse: () => UpdateStatus.PUBLISHED,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'postedBy': postedBy,
      'status': status.toString().split('.').last.toLowerCase(),
    };
  }
}

enum UpdateStatus {
  DRAFT,
  PUBLISHED,
  ARCHIVED,
}

class OutageDocument {
  final String id;
  final String name;
  final DocumentType type;
  final String url;
  final String uploadedBy;
  final DateTime uploadedAt;

  OutageDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory OutageDocument.fromJson(Map<String, dynamic> json) {
    return OutageDocument(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: DocumentType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'].toUpperCase(),
        orElse: () => DocumentType.REPORT,
      ),
      url: json['url'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last.toLowerCase(),
      'url': url,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

enum DocumentType {
  REPORT,
  PHOTO,
  MAP,
  PERMIT,
  SAFETY,
  OTHER,
}