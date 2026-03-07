import 'package:flutter/material.dart';

// ============================================
// ENUMS
// ============================================

enum CalendarEventType {
  meeting,
  call,
  task,
  appointment,
  presentation,
  training,
  follow_up,
  site_visit,
  networking,
  conference,
  workshop,
  vacation,
  sick_leave,
  holiday,
  reminder,
  other;

  String get displayName {
    return switch (this) {
      CalendarEventType.meeting => 'Meeting',
      CalendarEventType.call => 'Phone Call',
      CalendarEventType.task => 'Task',
      CalendarEventType.appointment => 'Appointment',
      CalendarEventType.presentation => 'Presentation',
      CalendarEventType.training => 'Training',
      CalendarEventType.follow_up => 'Follow Up',
      CalendarEventType.site_visit => 'Site Visit',
      CalendarEventType.networking => 'Networking',
      CalendarEventType.conference => 'Conference',
      CalendarEventType.workshop => 'Workshop',
      CalendarEventType.vacation => 'Vacation',
      CalendarEventType.sick_leave => 'Sick Leave',
      CalendarEventType.holiday => 'Holiday',
      CalendarEventType.reminder => 'Reminder',
      CalendarEventType.other => 'Other',
    };
  }

  Color get color {
    return switch (this) {
      CalendarEventType.meeting => const Color(0xFF3B82F6),
      CalendarEventType.call => const Color(0xFF10B981),
      CalendarEventType.task => const Color(0xFF8B5CF6),
      CalendarEventType.appointment => const Color(0xFFEC4899),
      CalendarEventType.presentation => const Color(0xFFF59E0B),
      CalendarEventType.training => const Color(0xFF06B6D4),
      CalendarEventType.follow_up => const Color(0xFF84CC16),
      CalendarEventType.site_visit => const Color(0xFFF97316),
      CalendarEventType.networking => const Color(0xFF8B5CF6),
      CalendarEventType.conference => const Color(0xFF6366F1),
      CalendarEventType.workshop => const Color(0xFF14B8A6),
      CalendarEventType.vacation => const Color(0xFF0EA5E9),
      CalendarEventType.sick_leave => const Color(0xFFEF4444),
      CalendarEventType.holiday => const Color(0xFFF59E0B),
      CalendarEventType.reminder => const Color(0xFF6B7280),
      CalendarEventType.other => const Color(0xFF9CA3AF),
    };
  }

  IconData get icon {
    return switch (this) {
      CalendarEventType.meeting => Icons.people,
      CalendarEventType.call => Icons.phone,
      CalendarEventType.task => Icons.checklist,
      CalendarEventType.appointment => Icons.event,
      CalendarEventType.presentation => Icons.slideshow,
      CalendarEventType.training => Icons.school,
      CalendarEventType.follow_up => Icons.update,
      CalendarEventType.site_visit => Icons.location_on,
      CalendarEventType.networking => Icons.handshake,
      CalendarEventType.conference => Icons.forum,
      CalendarEventType.workshop => Icons.construction,
      CalendarEventType.vacation => Icons.beach_access,
      CalendarEventType.sick_leave => Icons.health_and_safety,
      CalendarEventType.holiday => Icons.celebration,
      CalendarEventType.reminder => Icons.notifications,
      CalendarEventType.other => Icons.event_note,
    };
  }
}

enum EventStatus {
  draft,
  scheduled,
  confirmed,
  in_progress,
  completed,
  cancelled,
  postponed,
  rescheduled;

  String get displayName {
    return switch (this) {
      EventStatus.draft => 'Draft',
      EventStatus.scheduled => 'Scheduled',
      EventStatus.confirmed => 'Confirmed',
      EventStatus.in_progress => 'In Progress',
      EventStatus.completed => 'Completed',
      EventStatus.cancelled => 'Cancelled',
      EventStatus.postponed => 'Postponed',
      EventStatus.rescheduled => 'Rescheduled',
    };
  }

  Color get color {
    return switch (this) {
      EventStatus.draft => const Color(0xFF6B7280),
      EventStatus.scheduled => const Color(0xFF3B82F6),
      EventStatus.confirmed => const Color(0xFF10B981),
      EventStatus.in_progress => const Color(0xFFF59E0B),
      EventStatus.completed => const Color(0xFF059669),
      EventStatus.cancelled => const Color(0xFFEF4444),
      EventStatus.postponed => const Color(0xFF8B5CF6),
      EventStatus.rescheduled => const Color(0xFFEC4899),
    };
  }
}

enum PriorityLevel {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    return switch (this) {
      PriorityLevel.low => 'Low',
      PriorityLevel.medium => 'Medium',
      PriorityLevel.high => 'High',
      PriorityLevel.urgent => 'Urgent',
    };
  }

  Color get color {
    return switch (this) {
      PriorityLevel.low => const Color(0xFF10B981),
      PriorityLevel.medium => const Color(0xFFF59E0B),
      PriorityLevel.high => const Color(0xFFEF4444),
      PriorityLevel.urgent => const Color(0xFFDC2626),
    };
  }
}

// ============================================
// MAIN MODEL
// ============================================

@immutable
class CalendarEvent {
  final String id;
  final String eventNumber;
  final String title;
  final String description;
  final CalendarEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool allDay;
  final String? location;
  final String organizerId;
  final String? organizerName;
  final List<String> attendeeIds;
  final List<String> attendeeNames;
  final EventStatus status;
  final PriorityLevel priority;
  final String? opportunityId;
  final String? opportunityNumber;
  final String? customerId;
  final String? customerName;
  final String? leadId;
  final String? leadName;
  final String? quoteId;
  final String? quoteNumber;
  final String? proposalId;
  final String? proposalNumber;
  final String? outcome;
  final String? outcomeNotes;
  final double? rating;
  final String? feedback;
  final bool isCancelled;
  final String? cancellationReason;
  final String createdById;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEvent({
    required this.id,
    required this.eventNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.allDay = false,
    this.location,
    required this.organizerId,
    this.organizerName,
    this.attendeeIds = const [],
    this.attendeeNames = const [],
    this.status = EventStatus.scheduled,
    this.priority = PriorityLevel.medium,
    this.opportunityId,
    this.opportunityNumber,
    this.customerId,
    this.customerName,
    this.leadId,
    this.leadName,
    this.quoteId,
    this.quoteNumber,
    this.proposalId,
    this.proposalNumber,
    this.outcome,
    this.outcomeNotes,
    this.rating,
    this.feedback,
    this.isCancelled = false,
    this.cancellationReason,
    required this.createdById,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    // Parse location - backend returns location as an object
    String? location;
    if (json['location'] != null) {
      if (json['location'] is Map) {
        location = json['location']['name'] as String?;
        if (location == null) {
          location = json['location']['address'] as String?;
        }
      } else if (json['location'] is String) {
        location = json['location'] as String;
      }
    }

    return CalendarEvent(
      id: json['_id']?.toString() ?? '',
      eventNumber: json['eventNumber'] as String? ?? 'N/A',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: CalendarEventType.values.firstWhere(
            (e) => e.name == (json['type'] as String?),
        orElse: () => CalendarEventType.meeting,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      allDay: json['allDay'] as bool? ?? false,
      location: location,
      organizerId: json['organizer'] is String
          ? json['organizer']
          : json['organizer']?['_id']?.toString() ?? '',
      organizerName: json['organizer'] is Map
          ? '${json['organizer']?['firstName'] ?? ''} ${json['organizer']?['lastName'] ?? ''}'.trim()
          : null,
      attendeeIds: (json['attendees'] as List<dynamic>?)
          ?.map((e) => e is String ? e : e['_id']?.toString())
          .whereType<String>()
          .toList() ??
          const [],
      attendeeNames: (json['attendees'] as List<dynamic>?)
          ?.map((e) => e is Map
          ? '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}'.trim()
          : null)
          .whereType<String>()
          .toList() ??
          const [],
      status: EventStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String?),
        orElse: () => EventStatus.scheduled,
      ),
      priority: PriorityLevel.values.firstWhere(
            (e) => e.name == (json['priority'] as String?),
        orElse: () => PriorityLevel.medium,
      ),
      opportunityId: json['opportunity'] is String
          ? json['opportunity']
          : json['opportunity']?['_id']?.toString(),
      opportunityNumber: json['opportunity']?['opportunityNumber'] as String?,
      customerId: json['customer'] is String
          ? json['customer']
          : json['customer']?['_id']?.toString(),
      customerName: json['customer']?['companyName'] as String? ??
          (json['customer'] is Map
              ? '${json['customer']?['firstName'] ?? ''} ${json['customer']?['lastName'] ?? ''}'.trim()
              : null),
      leadId: json['lead'] is String
          ? json['lead']
          : json['lead']?['_id']?.toString(),
      leadName: json['lead']?['leadNumber'] as String?,
      quoteId: json['quote'] is String
          ? json['quote']
          : json['quote']?['_id']?.toString(),
      quoteNumber: json['quote']?['quoteNumber'] as String?,
      proposalId: json['proposal'] is String
          ? json['proposal']
          : json['proposal']?['_id']?.toString(),
      proposalNumber: json['proposal']?['proposalNumber'] as String?,
      outcome: json['outcome'] as String?,
      outcomeNotes: json['outcomeNotes'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
      isCancelled: json['isCancelled'] as bool? ?? false,
      cancellationReason: json['cancellationReason'] as String?,
      createdById: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id']?.toString() ?? '',
      createdByName: json['createdBy'] is Map
          ? '${json['createdBy']?['firstName'] ?? ''} ${json['createdBy']?['lastName'] ?? ''}'.trim()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'allDay': allDay,
      if (location != null) 'location': {'name': location},
      'organizer': organizerId,
      'attendees': attendeeIds,
      'status': status.name,
      'priority': priority.name,
      if (opportunityId != null) 'opportunity': opportunityId,
      if (customerId != null) 'customer': customerId,
      if (leadId != null) 'lead': leadId,
      if (quoteId != null) 'quote': quoteId,
      if (proposalId != null) 'proposal': proposalId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'allDay': allDay,
      'status': status.name,
      'priority': priority.name,
      'attendees': attendeeIds,
      // location should be an object
      if (location != null) 'location': {'name': location},
      if (opportunityId != null) 'opportunity': opportunityId,
      if (customerId != null) 'customer': customerId,
      if (leadId != null) 'lead': leadId,
      if (quoteId != null) 'quote': quoteId,
      if (proposalId != null) 'proposal': proposalId,
      if (outcome != null) 'outcome': outcome,
      if (outcomeNotes != null) 'outcomeNotes': outcomeNotes,
      if (rating != null) 'rating': rating,
      if (feedback != null) 'feedback': feedback,
      if (isCancelled) 'isCancelled': true,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? eventNumber,
    String? title,
    String? description,
    CalendarEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? allDay,
    String? location,
    String? organizerId,
    String? organizerName,
    List<String>? attendeeIds,
    List<String>? attendeeNames,
    EventStatus? status,
    PriorityLevel? priority,
    String? opportunityId,
    String? opportunityNumber,
    String? customerId,
    String? customerName,
    String? leadId,
    String? leadName,
    String? quoteId,
    String? quoteNumber,
    String? proposalId,
    String? proposalNumber,
    String? outcome,
    String? outcomeNotes,
    double? rating,
    String? feedback,
    bool? isCancelled,
    String? cancellationReason,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      eventNumber: eventNumber ?? this.eventNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allDay: allDay ?? this.allDay,
      location: location ?? this.location,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      attendeeNames: attendeeNames ?? this.attendeeNames,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      opportunityId: opportunityId ?? this.opportunityId,
      opportunityNumber: opportunityNumber ?? this.opportunityNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      quoteId: quoteId ?? this.quoteId,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      proposalId: proposalId ?? this.proposalId,
      proposalNumber: proposalNumber ?? this.proposalNumber,
      outcome: outcome ?? this.outcome,
      outcomeNotes: outcomeNotes ?? this.outcomeNotes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      isCancelled: isCancelled ?? this.isCancelled,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get duration {
    final diff = endDate.difference(startDate);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
    } else {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isCurrent => !isUpcoming && !isPast;

  Color get statusColor => status.color;
  Color get typeColor => type.color;
  Color get priorityColor => priority.color;

  // Search helper methods
  bool matchesSearch(String searchTerm) {
    if (searchTerm.isEmpty) return true;

    final lowerSearch = searchTerm.toLowerCase();
    return title.toLowerCase().contains(lowerSearch) ||
        description.toLowerCase().contains(lowerSearch) ||
        eventNumber.toLowerCase().contains(lowerSearch) ||
        (location?.toLowerCase().contains(lowerSearch) ?? false) ||
        (organizerName?.toLowerCase().contains(lowerSearch) ?? false) ||
        (customerName?.toLowerCase().contains(lowerSearch) ?? false);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CalendarEvent &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================
// FILTERS
// ============================================

class CalendarFilters {
  final CalendarEventType? type;
  final EventStatus? status;
  final PriorityLevel? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final String? organizerId;
  final bool? myEventsOnly;
  final bool? upcomingOnly;
  final bool? pastOnly;
  final bool? showCancelled;

  const CalendarFilters({
    this.type,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
    this.search,
    this.organizerId,
    this.myEventsOnly = false,
    this.upcomingOnly = false,
    this.pastOnly = false,
    this.showCancelled = false,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = status!.name;
    if (priority != null) params['priority'] = priority!.name;
    if (startDate != null) params['startDateFrom'] = startDate!.toIso8601String();
    if (endDate != null) params['endDateTo'] = endDate!.toIso8601String();
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (organizerId != null) params['organizer'] = organizerId;
    if (myEventsOnly != null && myEventsOnly!) params['organizer'] = organizerId;
    if (upcomingOnly != null && upcomingOnly!) params['startDateFrom'] = DateTime.now().toIso8601String();
    if (pastOnly != null && pastOnly!) params['endDateTo'] = DateTime.now().toIso8601String();
    if (showCancelled != null && showCancelled!) params['isCancelled'] = true;
    return params;
  }

  CalendarFilters copyWith({
    CalendarEventType? type,
    EventStatus? status,
    PriorityLevel? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    String? organizerId,
    bool? myEventsOnly,
    bool? upcomingOnly,
    bool? pastOnly,
    bool? showCancelled,
  }) {
    return CalendarFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      search: search ?? this.search,
      organizerId: organizerId ?? this.organizerId,
      myEventsOnly: myEventsOnly ?? this.myEventsOnly,
      upcomingOnly: upcomingOnly ?? this.upcomingOnly,
      pastOnly: pastOnly ?? this.pastOnly,
      showCancelled: showCancelled ?? this.showCancelled,
    );
  }

  bool get hasFilters =>
      type != null ||
          status != null ||
          priority != null ||
          startDate != null ||
          endDate != null ||
          (search != null && search!.isNotEmpty) ||
          organizerId != null ||
          (myEventsOnly != null && myEventsOnly!) ||
          (upcomingOnly != null && upcomingOnly!) ||
          (pastOnly != null && pastOnly!) ||
          (showCancelled != null && showCancelled!);
}