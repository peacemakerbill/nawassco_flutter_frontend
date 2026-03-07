enum ServiceCategory {
  waterSupply,
  sewerage,
  laboratory,
  consultancy,
  maintenance
}

enum ServiceType {
  newConnection,
  leakRepair,
  qualityTesting,
  blockageClearance,
  meterReading,
  sewerConnection,
  maintenance
}

enum CustomerType {
  residential,
  commercial,
  industrial,
  government,
  institutional
}

enum PropertyType {
  apartment,
  house,
  commercialBuilding,
  industrialComplex,
  office,
  institution
}

enum PriorityLevel { low, medium, high, urgent, emergency }

enum RequestStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  scheduled,
  inProgress,
  onHold,
  completed,
  cancelled,
  closed
}

enum StageStatus { pending, inProgress, completed, blocked, skipped }

enum NoteType {
  general,
  technical,
  customer,
  internal,
  escalation,
  quality,
  safety
}

enum PaymentStatus {
  pending,
  partiallyPaid,
  paid,
  overdue,
  refunded,
  waived,
  writtenOff
}

enum SLAStatus { withinSLA, atRisk, breached, notApplicable }

class GPSCoordinates {
  final double latitude;
  final double longitude;
  final double? accuracy;

  GPSCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  factory GPSCoordinates.fromJson(Map<String, dynamic> json) {
    return GPSCoordinates(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }
}

class RequestLocation {
  final String address;
  final GPSCoordinates coordinates;
  final String zone;
  final String subzone;
  final String? landmark;
  final String accessibility;
  final List<String> photos;

  RequestLocation({
    required this.address,
    required this.coordinates,
    required this.zone,
    required this.subzone,
    this.landmark,
    required this.accessibility,
    this.photos = const [],
  });

  factory RequestLocation.fromJson(Map<String, dynamic> json) {
    return RequestLocation(
      address: json['address'] ?? '',
      coordinates: GPSCoordinates.fromJson(json['coordinates'] ?? {}),
      zone: json['zone'] ?? '',
      subzone: json['subzone'] ?? '',
      landmark: json['landmark'],
      accessibility: json['accessibility'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates.toJson(),
      'zone': zone,
      'subzone': subzone,
      if (landmark != null) 'landmark': landmark,
      'accessibility': accessibility,
      'photos': photos,
    };
  }
}

class SpecificRequirement {
  final String requirement;
  final String value;
  final bool verified;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  SpecificRequirement({
    required this.requirement,
    required this.value,
    this.verified = false,
    this.verifiedBy,
    this.verifiedAt,
  });

  factory SpecificRequirement.fromJson(Map<String, dynamic> json) {
    return SpecificRequirement(
      requirement: json['requirement'] ?? '',
      value: json['value'] ?? '',
      verified: json['verified'] ?? false,
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'value': value,
      'verified': verified,
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
    };
  }
}

class RequestStage {
  final String stage;
  final StageStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? completedBy;
  final String? notes;
  final List<String> deliverables;

  RequestStage({
    required this.stage,
    this.status = StageStatus.pending,
    this.startDate,
    this.endDate,
    this.completedBy,
    this.notes,
    this.deliverables = const [],
  });

  factory RequestStage.fromJson(Map<String, dynamic> json) {
    return RequestStage(
      stage: json['stage'] ?? '',
      status: StageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StageStatus.pending,
      ),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      completedBy: json['completedBy'],
      notes: json['notes'],
      deliverables: List<String>.from(json['deliverables'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'status': status.name,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (completedBy != null) 'completedBy': completedBy,
      if (notes != null) 'notes': notes,
      'deliverables': deliverables,
    };
  }
}

class RequestNote {
  final String note;
  final String addedBy;
  final String? addedByName;
  final DateTime addedAt;
  final NoteType type;
  final bool isInternal;

  RequestNote({
    required this.note,
    required this.addedBy,
    this.addedByName,
    required this.addedAt,
    required this.type,
    required this.isInternal,
  });

  factory RequestNote.fromJson(Map<String, dynamic> json) {
    return RequestNote(
      note: json['note'] ?? '',
      addedBy: json['addedBy'] ?? '',
      addedByName: json['addedByName'],
      addedAt:
          DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
      type: NoteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NoteType.general,
      ),
      isInternal: json['isInternal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'addedBy': addedBy,
      if (addedByName != null) 'addedByName': addedByName,
      'addedAt': addedAt.toIso8601String(),
      'type': type.name,
      'isInternal': isInternal,
    };
  }
}

class Attachment {
  final String name;
  final String type;
  final String url;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int size;

  Attachment({
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.size,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedAt: DateTime.parse(
          json['uploadedAt'] ?? DateTime.now().toIso8601String()),
      size: json['size']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
    };
  }
}

class Payment {
  final double amount;
  final DateTime date;
  final String method;
  final String reference;
  final PaymentStatus status;
  final String? receivedBy;

  Payment({
    required this.amount,
    required this.date,
    required this.method,
    required this.reference,
    required this.status,
    this.receivedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      method: json['method'] ?? '',
      reference: json['reference'] ?? '',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      receivedBy: json['receivedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'reference': reference,
      'status': status.name,
      if (receivedBy != null) 'receivedBy': receivedBy,
    };
  }
}

class SLABreach {
  final String type;
  final DateTime breachedAt;
  final String reason;
  final double duration;
  final DateTime? resolvedAt;

  SLABreach({
    required this.type,
    required this.breachedAt,
    required this.reason,
    required this.duration,
    this.resolvedAt,
  });

  factory SLABreach.fromJson(Map<String, dynamic> json) {
    return SLABreach(
      type: json['type'] ?? '',
      breachedAt: DateTime.parse(
          json['breachedAt'] ?? DateTime.now().toIso8601String()),
      reason: json['reason'] ?? '',
      duration: json['duration']?.toDouble() ?? 0.0,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'breachedAt': breachedAt.toIso8601String(),
      'reason': reason,
      'duration': duration,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    };
  }
}

class ServiceRequest {
  final String id;
  final String requestNumber;
  final String service;
  final String serviceCode;
  final String serviceName;
  final ServiceCategory serviceCategory;
  final ServiceType serviceType;

  // Customer Information
  final String customer;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final CustomerType customerType;
  final PropertyType propertyType;

  // Request Details
  final String description;
  final PriorityLevel priority;
  final RequestStatus status;
  final RequestLocation location;
  final List<SpecificRequirement> specificRequirements;

  // Scheduling
  final DateTime requestedDate;
  final DateTime? preferredDate;
  final DateTime? scheduledDate;
  final DateTime? estimatedCompletion;
  final DateTime? actualStart;
  final DateTime? actualCompletion;

  // Assignment
  final String? assignedTo;
  final String? assignedToName;
  final String? assignedTeam;
  final String department;

  // Progress Tracking
  final int progress;
  final String? currentStage;
  final List<RequestStage> stages;
  final List<RequestNote> notes;
  final List<Attachment> attachments;

  // Costing and Billing
  final double estimatedCost;
  final double? actualCost;
  final PaymentStatus paymentStatus;
  final String? invoiceNumber;
  final List<Payment> payments;

  // SLA Tracking
  final SLAStatus slaStatus;
  final double? responseTime;
  final double? resolutionTime;
  final List<SLABreach> slaBreaches;

  // Customer Feedback
  final double? customerRating;
  final String? customerFeedback;
  final DateTime? feedbackDate;

  // Metadata
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequest({
    required this.id,
    required this.requestNumber,
    required this.service,
    required this.serviceCode,
    required this.serviceName,
    required this.serviceCategory,
    required this.serviceType,
    required this.customer,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerType,
    required this.propertyType,
    required this.description,
    required this.priority,
    required this.status,
    required this.location,
    this.specificRequirements = const [],
    required this.requestedDate,
    this.preferredDate,
    this.scheduledDate,
    this.estimatedCompletion,
    this.actualStart,
    this.actualCompletion,
    this.assignedTo,
    this.assignedToName,
    this.assignedTeam,
    required this.department,
    this.progress = 0,
    this.currentStage,
    this.stages = const [],
    this.notes = const [],
    this.attachments = const [],
    required this.estimatedCost,
    this.actualCost,
    required this.paymentStatus,
    this.invoiceNumber,
    this.payments = const [],
    required this.slaStatus,
    this.responseTime,
    this.resolutionTime,
    this.slaBreaches = const [],
    this.customerRating,
    this.customerFeedback,
    this.feedbackDate,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['_id'] ?? json['id'] ?? '',
      requestNumber: json['requestNumber'] ?? '',
      service: json['service'] ?? '',
      serviceCode: json['serviceCode'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceCategory: ServiceCategory.values.firstWhere(
        (e) => e.name == json['serviceCategory'],
        orElse: () => ServiceCategory.waterSupply,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.newConnection,
      ),
      customer: json['customer'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerType: CustomerType.values.firstWhere(
        (e) => e.name == json['customerType'],
        orElse: () => CustomerType.residential,
      ),
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.house,
      ),
      description: json['description'] ?? '',
      priority: PriorityLevel.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => PriorityLevel.medium,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.submitted,
      ),
      location: RequestLocation.fromJson(json['location'] ?? {}),
      specificRequirements: (json['specificRequirements'] as List?)
              ?.map((item) => SpecificRequirement.fromJson(item))
              .toList() ??
          [],
      requestedDate: DateTime.parse(
          json['requestedDate'] ?? DateTime.now().toIso8601String()),
      preferredDate: json['preferredDate'] != null
          ? DateTime.parse(json['preferredDate'])
          : null,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      estimatedCompletion: json['estimatedCompletion'] != null
          ? DateTime.parse(json['estimatedCompletion'])
          : null,
      actualStart: json['actualStart'] != null
          ? DateTime.parse(json['actualStart'])
          : null,
      actualCompletion: json['actualCompletion'] != null
          ? DateTime.parse(json['actualCompletion'])
          : null,
      assignedTo: json['assignedTo'],
      assignedToName: json['assignedToName'],
      assignedTeam: json['assignedTeam'],
      department: json['department'] ?? '',
      progress: json['progress']?.toInt() ?? 0,
      currentStage: json['currentStage'],
      stages: (json['stages'] as List?)
              ?.map((item) => RequestStage.fromJson(item))
              .toList() ??
          [],
      notes: (json['notes'] as List?)
              ?.map((item) => RequestNote.fromJson(item))
              .toList() ??
          [],
      attachments: (json['attachments'] as List?)
              ?.map((item) => Attachment.fromJson(item))
              .toList() ??
          [],
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      actualCost: json['actualCost']?.toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      invoiceNumber: json['invoiceNumber'],
      payments: (json['payments'] as List?)
              ?.map((item) => Payment.fromJson(item))
              .toList() ??
          [],
      slaStatus: SLAStatus.values.firstWhere(
        (e) => e.name == json['slaStatus'],
        orElse: () => SLAStatus.withinSLA,
      ),
      responseTime: json['responseTime']?.toDouble(),
      resolutionTime: json['resolutionTime']?.toDouble(),
      slaBreaches: (json['slaBreaches'] as List?)
              ?.map((item) => SLABreach.fromJson(item))
              .toList() ??
          [],
      customerRating: json['customerRating']?.toDouble(),
      customerFeedback: json['customerFeedback'],
      feedbackDate: json['feedbackDate'] != null
          ? DateTime.parse(json['feedbackDate'])
          : null,
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestNumber': requestNumber,
      'service': service,
      'serviceCode': serviceCode,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory.name,
      'serviceType': serviceType.name,
      'customer': customer,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerType': customerType.name,
      'propertyType': propertyType.name,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'location': location.toJson(),
      'specificRequirements':
          specificRequirements.map((req) => req.toJson()).toList(),
      'requestedDate': requestedDate.toIso8601String(),
      if (preferredDate != null)
        'preferredDate': preferredDate!.toIso8601String(),
      if (scheduledDate != null)
        'scheduledDate': scheduledDate!.toIso8601String(),
      if (estimatedCompletion != null)
        'estimatedCompletion': estimatedCompletion!.toIso8601String(),
      if (actualStart != null) 'actualStart': actualStart!.toIso8601String(),
      if (actualCompletion != null)
        'actualCompletion': actualCompletion!.toIso8601String(),
      if (assignedTo != null) 'assignedTo': assignedTo,
      'department': department,
      'progress': progress,
      if (currentStage != null) 'currentStage': currentStage,
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'notes': notes.map((note) => note.toJson()).toList(),
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
      'estimatedCost': estimatedCost,
      if (actualCost != null) 'actualCost': actualCost,
      'paymentStatus': paymentStatus.name,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      'payments': payments.map((payment) => payment.toJson()).toList(),
      'slaStatus': slaStatus.name,
      if (responseTime != null) 'responseTime': responseTime,
      if (resolutionTime != null) 'resolutionTime': resolutionTime,
      'slaBreaches': slaBreaches.map((breach) => breach.toJson()).toList(),
      if (customerRating != null) 'customerRating': customerRating,
      if (customerFeedback != null) 'customerFeedback': customerFeedback,
      if (feedbackDate != null) 'feedbackDate': feedbackDate!.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? requestNumber,
    String? service,
    String? serviceCode,
    String? serviceName,
    ServiceCategory? serviceCategory,
    ServiceType? serviceType,
    String? customer,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    CustomerType? customerType,
    PropertyType? propertyType,
    String? description,
    PriorityLevel? priority,
    RequestStatus? status,
    RequestLocation? location,
    List<SpecificRequirement>? specificRequirements,
    DateTime? requestedDate,
    DateTime? preferredDate,
    DateTime? scheduledDate,
    DateTime? estimatedCompletion,
    DateTime? actualStart,
    DateTime? actualCompletion,
    String? assignedTo,
    String? assignedToName,
    String? assignedTeam,
    String? department,
    int? progress,
    String? currentStage,
    List<RequestStage>? stages,
    List<RequestNote>? notes,
    List<Attachment>? attachments,
    double? estimatedCost,
    double? actualCost,
    PaymentStatus? paymentStatus,
    String? invoiceNumber,
    List<Payment>? payments,
    SLAStatus? slaStatus,
    double? responseTime,
    double? resolutionTime,
    List<SLABreach>? slaBreaches,
    double? customerRating,
    String? customerFeedback,
    DateTime? feedbackDate,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      service: service ?? this.service,
      serviceCode: serviceCode ?? this.serviceCode,
      serviceName: serviceName ?? this.serviceName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceType: serviceType ?? this.serviceType,
      customer: customer ?? this.customer,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerType: customerType ?? this.customerType,
      propertyType: propertyType ?? this.propertyType,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      specificRequirements: specificRequirements ?? this.specificRequirements,
      requestedDate: requestedDate ?? this.requestedDate,
      preferredDate: preferredDate ?? this.preferredDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      actualStart: actualStart ?? this.actualStart,
      actualCompletion: actualCompletion ?? this.actualCompletion,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      department: department ?? this.department,
      progress: progress ?? this.progress,
      currentStage: currentStage ?? this.currentStage,
      stages: stages ?? this.stages,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      payments: payments ?? this.payments,
      slaStatus: slaStatus ?? this.slaStatus,
      responseTime: responseTime ?? this.responseTime,
      resolutionTime: resolutionTime ?? this.resolutionTime,
      slaBreaches: slaBreaches ?? this.slaBreaches,
      customerRating: customerRating ?? this.customerRating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      feedbackDate: feedbackDate ?? this.feedbackDate,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
