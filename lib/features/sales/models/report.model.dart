import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ============================================
// ENUMS (From Backend Report Model)
// ============================================

enum ReportType {
  daily('Daily'),
  weekly('Weekly'),
  biWeekly('Bi-Weekly'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  yearly('Yearly'),
  adHoc('Ad-Hoc'),
  activity('Activity'),
  performance('Performance'),
  market('Market'),
  travel('Travel'),
  expense('Expense'),
  project('Project');

  final String displayName;
  const ReportType(this.displayName);

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
          (e) => e.name == value.toLowerCase().replaceAll(' ', '_'),
      orElse: () => ReportType.daily,
    );
  }
}

enum PeriodType {
  day('Day'),
  week('Week'),
  month('Month'),
  quarter('Quarter'),
  year('Year'),
  custom('Custom');

  final String displayName;
  const PeriodType(this.displayName);
}

enum ActivityType {
  customerVisit('Customer Visit'),
  siteVisit('Site Visit'),
  meeting('Meeting'),
  phoneCall('Phone Call'),
  email('Email'),
  presentation('Presentation'),
  negotiation('Negotiation'),
  followUp('Follow Up'),
  proposalPreparation('Proposal Preparation'),
  quotePreparation('Quote Preparation'),
  research('Research'),
  training('Training'),
  administrative('Administrative'),
  travel('Travel'),
  networking('Networking'),
  other('Other');

  final String displayName;
  const ActivityType(this.displayName);
}

enum ActivityOutcome {
  successful('Successful'),
  partialSuccess('Partial Success'),
  unsuccessful('Unsuccessful'),
  rescheduled('Rescheduled'),
  cancelled('Cancelled'),
  onHold('On Hold');

  final String displayName;
  const ActivityOutcome(this.displayName);
}

enum RelatedEntityType {
  opportunity('Opportunity'),
  customer('Customer'),
  lead('Lead'),
  quote('Quote'),
  proposal('Proposal'),
  project('Project'),
  calendar('Calendar');

  final String displayName;
  const RelatedEntityType(this.displayName);
}

enum ResolutionStatus {
  resolved('Resolved'),
  inProgress('In Progress'),
  pending('Pending'),
  escalated('Escalated'),
  cancelled('Cancelled');

  final String displayName;
  const ResolutionStatus(this.displayName);
}

enum TrendDirection {
  up('Up'),
  down('Down'),
  stable('Stable'),
  fluctuating('Fluctuating');

  final String displayName;
  const TrendDirection(this.displayName);
}

enum PriorityLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String displayName;
  const PriorityLevel(this.displayName);
}

enum ActionItemStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled'),
  onHold('On Hold');

  final String displayName;
  const ActionItemStatus(this.displayName);
}

enum TravelMode {
  car('Car'),
  publicTransport('Public Transport'),
  taxi('Taxi'),
  walk('Walk'),
  bicycle('Bicycle'),
  flight('Flight'),
  train('Train');

  final String displayName;
  const TravelMode(this.displayName);
}

enum ExpenseCategory {
  travel('Travel'),
  accommodation('Accommodation'),
  meals('Meals'),
  transport('Transport'),
  communication('Communication'),
  officeSupplies('Office Supplies'),
  entertainment('Entertainment'),
  training('Training'),
  marketing('Marketing'),
  other('Other');

  final String displayName;
  const ExpenseCategory(this.displayName);
}

enum EfficiencyRating {
  high('High'),
  medium('Medium'),
  low('Low'),
  unknown('Unknown');

  final String displayName;
  const EfficiencyRating(this.displayName);
}

enum FeedbackType {
  positive('Positive'),
  negative('Negative'),
  suggestion('Suggestion'),
  complaint('Complaint'),
  compliment('Compliment');

  final String displayName;
  const FeedbackType(this.displayName);
}

enum SupportType {
  technical('Technical'),
  financial('Financial'),
  humanResources('Human Resources'),
  administrative('Administrative'),
  training('Training'),
  equipment('Equipment'),
  other('Other');

  final String displayName;
  const SupportType(this.displayName);
}

enum UrgencyLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String displayName;
  const UrgencyLevel(this.displayName);
}

enum Likelihood {
  rare('Rare'),
  unlikely('Unlikely'),
  possible('Possible'),
  likely('Likely'),
  almostCertain('Almost Certain');

  final String displayName;
  const Likelihood(this.displayName);
}

enum Impact {
  negligible('Negligible'),
  minor('Minor'),
  moderate('Moderate'),
  major('Major'),
  catastrophic('Catastrophic');

  final String displayName;
  const Impact(this.displayName);
}

enum ReviewStatus {
  pending('Pending'),
  inReview('In Review'),
  reviewed('Reviewed'),
  revisionsRequired('Revisions Required');

  final String displayName;
  const ReviewStatus(this.displayName);
}

enum ApprovalStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  revisionsRequired('Revisions Required');

  final String displayName;
  const ApprovalStatus(this.displayName);
}

enum ReportStatus {
  draft('Draft'),
  submitted('Submitted'),
  reviewed('Reviewed'),
  approved('Approved'),
  archived('Archived');

  final String displayName;
  const ReportStatus(this.displayName);
}

enum ReportVisibility {
  personal('Personal'),
  team('Team'),
  department('Department'),
  manager('Manager'),
  company('Company');

  final String displayName;
  const ReportVisibility(this.displayName);
}

enum PerformanceRating {
  excellent('Excellent'),
  good('Good'),
  satisfactory('Satisfactory'),
  needsImprovement('Needs Improvement'),
  unsatisfactory('Unsatisfactory');

  final String displayName;
  const PerformanceRating(this.displayName);
}

// ============================================
// SUB-MODELS
// ============================================

@immutable
class RelatedEntity {
  final RelatedEntityType entityType;
  final String entityId;
  final String entityName;

  const RelatedEntity({
    required this.entityType,
    required this.entityId,
    required this.entityName,
  });

  Map<String, dynamic> toJson() => {
    'entityType': entityType.name,
    'entityId': entityId,
    'entityName': entityName,
  };

  factory RelatedEntity.fromJson(Map<String, dynamic> json) => RelatedEntity(
    entityType: RelatedEntityType.values.firstWhere(
          (e) => e.name == json['entityType'],
      orElse: () => RelatedEntityType.customer,
    ),
    entityId: json['entityId'] as String,
    entityName: json['entityName'] as String,
  );
}

@immutable
class Activity {
  final String activityId;
  final ActivityType type;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final String location;
  final List<String> participantIds;
  final ActivityOutcome outcome;
  final String notes;
  final RelatedEntity? relatedEntity;

  const Activity({
    required this.activityId,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.location,
    this.participantIds = const [],
    required this.outcome,
    this.notes = '',
    this.relatedEntity,
  });

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'type': type.name,
    'description': description,
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
    'duration': duration,
    'location': location,
    'participants': participantIds,
    'outcome': outcome.name,
    'notes': notes,
    if (relatedEntity != null) 'relatedEntity': relatedEntity!.toJson(),
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    activityId: json['activityId'] as String,
    type: ActivityType.values.firstWhere(
          (e) => e.name == json['type'],
      orElse: () => ActivityType.meeting,
    ),
    description: json['description'] as String,
    startTime: DateTime.parse(json['startTime'] as String).toLocal(),
    endTime: DateTime.parse(json['endTime'] as String).toLocal(),
    duration: json['duration'] as int,
    location: json['location'] as String,
    participantIds: (json['participants'] as List<dynamic>).cast<String>(),
    outcome: ActivityOutcome.values.firstWhere(
          (e) => e.name == json['outcome'],
      orElse: () => ActivityOutcome.successful,
    ),
    notes: json['notes'] as String? ?? '',
    relatedEntity: json['relatedEntity'] != null
        ? RelatedEntity.fromJson(json['relatedEntity'])
        : null,
  );
}

@immutable
class Achievement {
  final String description;
  final String impact;
  final List<String> metrics;
  final String? recognition;

  const Achievement({
    required this.description,
    required this.impact,
    this.metrics = const [],
    this.recognition,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'impact': impact,
    'metrics': metrics,
    if (recognition != null) 'recognition': recognition,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    description: json['description'] as String,
    impact: json['impact'] as String,
    metrics: (json['metrics'] as List<dynamic>).cast<String>(),
    recognition: json['recognition'] as String?,
  );
}

@immutable
class Challenge {
  final String description;
  final String cause;
  final String impact;
  final String? solutionAttempted;
  final ResolutionStatus resolutionStatus;
  final bool escalationRequired;

  const Challenge({
    required this.description,
    required this.cause,
    required this.impact,
    this.solutionAttempted,
    this.resolutionStatus = ResolutionStatus.pending,
    this.escalationRequired = false,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'cause': cause,
    'impact': impact,
    if (solutionAttempted != null) 'solutionAttempted': solutionAttempted,
    'resolutionStatus': resolutionStatus.name,
    'escalationRequired': escalationRequired,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    description: json['description'] as String,
    cause: json['cause'] as String,
    impact: json['impact'] as String,
    solutionAttempted: json['solutionAttempted'] as String?,
    resolutionStatus: ResolutionStatus.values.firstWhere(
          (e) => e.name == json['resolutionStatus'],
      orElse: () => ResolutionStatus.pending,
    ),
    escalationRequired: json['escalationRequired'] as bool? ?? false,
  );
}

@immutable
class KeyMetric {
  final String metricName;
  final double target;
  final double actual;
  final String unit;
  final TrendDirection trend;
  final double trendValue;
  final String? notes;

  const KeyMetric({
    required this.metricName,
    required this.target,
    required this.actual,
    required this.unit,
    required this.trend,
    required this.trendValue,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'metricName': metricName,
    'target': target,
    'actual': actual,
    'unit': unit,
    'trend': trend.name,
    'trendValue': trendValue,
    if (notes != null) 'notes': notes,
  };

  factory KeyMetric.fromJson(Map<String, dynamic> json) => KeyMetric(
    metricName: json['metricName'] as String,
    target: (json['target'] as num).toDouble(),
    actual: (json['actual'] as num).toDouble(),
    unit: json['unit'] as String,
    trend: TrendDirection.values.firstWhere(
          (e) => e.name == json['trend'],
      orElse: () => TrendDirection.stable,
    ),
    trendValue: (json['trendValue'] as num).toDouble(),
    notes: json['notes'] as String?,
  );
}

@immutable
class Learning {
  final String topic;
  final String description;
  final String source;
  final String application;
  final String impact;

  const Learning({
    required this.topic,
    required this.description,
    required this.source,
    required this.application,
    required this.impact,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'description': description,
    'source': source,
    'application': application,
    'impact': impact,
  };

  factory Learning.fromJson(Map<String, dynamic> json) => Learning(
    topic: json['topic'] as String,
    description: json['description'] as String,
    source: json['source'] as String,
    application: json['application'] as String,
    impact: json['impact'] as String,
  );
}

@immutable
class Recommendation {
  final String description;
  final String rationale;
  final String expectedBenefit;
  final PriorityLevel priority;
  final String? assignedTo;
  final DateTime? targetDate;

  const Recommendation({
    required this.description,
    required this.rationale,
    required this.expectedBenefit,
    this.priority = PriorityLevel.medium,
    this.assignedTo,
    this.targetDate,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'rationale': rationale,
    'expectedBenefit': expectedBenefit,
    'priority': priority.name,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (targetDate != null) 'targetDate': targetDate!.toUtc().toIso8601String(),
  };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    description: json['description'] as String,
    rationale: json['rationale'] as String,
    expectedBenefit: json['expectedBenefit'] as String,
    priority: PriorityLevel.values.firstWhere(
          (e) => e.name == json['priority'],
      orElse: () => PriorityLevel.medium,
    ),
    assignedTo: json['assignedTo'] as String?,
    targetDate: json['targetDate'] != null
        ? DateTime.parse(json['targetDate'] as String).toLocal()
        : null,
  );
}

@immutable
class ActionItem {
  final String description;
  final String assignedTo;
  final DateTime dueDate;
  final ActionItemStatus status;
  final PriorityLevel priority;
  final DateTime? completedAt;
  final String? completionNotes;

  const ActionItem({
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    this.status = ActionItemStatus.pending,
    this.priority = PriorityLevel.medium,
    this.completedAt,
    this.completionNotes,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'assignedTo': assignedTo,
    'dueDate': dueDate.toUtc().toIso8601String(),
    'status': status.name,
    'priority': priority.name,
    if (completedAt != null) 'completedAt': completedAt!.toUtc().toIso8601String(),
    if (completionNotes != null) 'completionNotes': completionNotes,
  };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    description: json['description'] as String,
    assignedTo: json['assignedTo'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String).toLocal(),
    status: ActionItemStatus.values.firstWhere(
          (e) => e.name == json['status'],
      orElse: () => ActionItemStatus.pending,
    ),
    priority: PriorityLevel.values.firstWhere(
          (e) => e.name == json['priority'],
      orElse: () => PriorityLevel.medium,
    ),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String).toLocal()
        : null,
    completionNotes: json['completionNotes'] as String?,
  );
}

@immutable
class CustomerVisit {
  final String customerId;
  final String purpose;
  final String outcome;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final int duration; // in minutes
  final String location;

  const CustomerVisit({
    required this.customerId,
    required this.purpose,
    required this.outcome,
    this.followUpRequired = false,
    this.followUpDate,
    required this.duration,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'customer': customerId,
    'purpose': purpose,
    'outcome': outcome,
    'followUpRequired': followUpRequired,
    if (followUpDate != null) 'followUpDate': followUpDate!.toUtc().toIso8601String(),
    'duration': duration,
    'location': location,
  };

  factory CustomerVisit.fromJson(Map<String, dynamic> json) => CustomerVisit(
    customerId: json['customer'] as String,
    purpose: json['purpose'] as String,
    outcome: json['outcome'] as String,
    followUpRequired: json['followUpRequired'] as bool? ?? false,
    followUpDate: json['followUpDate'] != null
        ? DateTime.parse(json['followUpDate'] as String).toLocal()
        : null,
    duration: json['duration'] as int,
    location: json['location'] as String,
  );
}

@immutable
class TravelDetail {
  final String destination;
  final String purpose;
  final DateTime travelDate;
  final DateTime returnDate;
  final TravelMode mode;
  final double distance; // in kilometers
  final double cost;
  final String? accommodation;

  const TravelDetail({
    required this.destination,
    required this.purpose,
    required this.travelDate,
    required this.returnDate,
    required this.mode,
    required this.distance,
    required this.cost,
    this.accommodation,
  });

  Map<String, dynamic> toJson() => {
    'destination': destination,
    'purpose': purpose,
    'travelDate': travelDate.toUtc().toIso8601String(),
    'returnDate': returnDate.toUtc().toIso8601String(),
    'mode': mode.name,
    'distance': distance,
    'cost': cost,
    if (accommodation != null) 'accommodation': accommodation,
  };

  factory TravelDetail.fromJson(Map<String, dynamic> json) => TravelDetail(
    destination: json['destination'] as String,
    purpose: json['purpose'] as String,
    travelDate: DateTime.parse(json['travelDate'] as String).toLocal(),
    returnDate: DateTime.parse(json['returnDate'] as String).toLocal(),
    mode: TravelMode.values.firstWhere(
          (e) => e.name == json['mode'],
      orElse: () => TravelMode.car,
    ),
    distance: (json['distance'] as num).toDouble(),
    cost: (json['cost'] as num).toDouble(),
    accommodation: json['accommodation'] as String?,
  );
}

@immutable
class Expense {
  final ExpenseCategory category;
  final String description;
  final double amount;
  final String? receiptUrl;
  final DateTime date;
  final bool approved;
  final DateTime? approvalDate;

  const Expense({
    required this.category,
    required this.description,
    required this.amount,
    this.receiptUrl,
    required this.date,
    this.approved = false,
    this.approvalDate,
  });

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'description': description,
    'amount': amount,
    if (receiptUrl != null) 'receiptUrl': receiptUrl,
    'date': date.toUtc().toIso8601String(),
    'approved': approved,
    if (approvalDate != null) 'approvalDate': approvalDate!.toUtc().toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    category: ExpenseCategory.values.firstWhere(
          (e) => e.name == json['category'],
      orElse: () => ExpenseCategory.other,
    ),
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble(),
    receiptUrl: json['receiptUrl'] as String?,
    date: DateTime.parse(json['date'] as String).toLocal(),
    approved: json['approved'] as bool? ?? false,
    approvalDate: json['approvalDate'] != null
        ? DateTime.parse(json['approvalDate'] as String).toLocal()
        : null,
  );
}

@immutable
class Risk {
  final String description;
  final Likelihood likelihood;
  final Impact impact;
  final String mitigationPlan;
  final String? ownerId;

  const Risk({
    required this.description,
    required this.likelihood,
    required this.impact,
    required this.mitigationPlan,
    this.ownerId,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'likelihood': likelihood.name,
    'impact': impact.name,
    'mitigationPlan': mitigationPlan,
    if (ownerId != null) 'owner': ownerId,
  };

  factory Risk.fromJson(Map<String, dynamic> json) => Risk(
    description: json['description'] as String,
    likelihood: Likelihood.values.firstWhere(
          (e) => e.name == json['likelihood'],
      orElse: () => Likelihood.possible,
    ),
    impact: Impact.values.firstWhere(
          (e) => e.name == json['impact'],
      orElse: () => Impact.minor,
    ),
    mitigationPlan: json['mitigationPlan'] as String,
    ownerId: json['owner'] as String?,
  );
}

@immutable
class Comment {
  final String commenterId;
  final String comment;
  final DateTime commentedAt;
  final bool isInternal;

  const Comment({
    required this.commenterId,
    required this.comment,
    required this.commentedAt,
    this.isInternal = false,
  });

  Map<String, dynamic> toJson() => {
    'commenter': commenterId,
    'comment': comment,
    'commentedAt': commentedAt.toUtc().toIso8601String(),
    'isInternal': isInternal,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    commenterId: json['commenter'] as String,
    comment: json['comment'] as String,
    commentedAt: DateTime.parse(json['commentedAt'] as String).toLocal(),
    isInternal: json['isInternal'] as bool? ?? false,
  );
}

// ============================================
// MAIN REPORT MODEL
// ============================================

@immutable
class Report {
  final String id;
  final String reportNumber;
  final String title;
  final ReportType reportType;
  final PeriodType periodType;

  // Period Information
  final DateTime reportDate;
  final DateTime startDate;
  final DateTime endDate;

  // Author Information
  final String authorId;
  final String? authorName;
  final String department;
  final String team;

  // Content Sections
  final String executiveSummary;
  final List<Activity> activities;
  final List<Achievement> achievements;
  final List<Challenge> challenges;
  final List<KeyMetric> keyMetrics;
  final List<Learning> learnings;
  final List<Recommendation> recommendations;
  final List<ActionItem> actionItems;

  // Performance Metrics
  final double salesValue;
  final int leadsGenerated;
  final int opportunitiesCreated;
  final int quotesSent;
  final int proposalsSubmitted;
  final int dealsClosed;
  final int callsMade;
  final int emailsSent;

  // Review & Approval
  final ReviewStatus reviewStatus;
  final ApprovalStatus approvalStatus;
  final ReportStatus status;
  final ReportVisibility visibility;
  final String? reviewedById;
  final String? approvedById;
  final DateTime? reviewDate;
  final DateTime? approvalDate;
  final List<Comment> comments;

  // Attachments & Metadata
  final List<String> tags;
  final bool isSubmitted;
  final DateTime? submittedAt;
  final bool isEditedAfterSubmit;
  final PerformanceRating? performanceRating;
  final double? qualityScore;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.reportNumber,
    required this.title,
    required this.reportType,
    required this.periodType,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    required this.authorId,
    this.authorName,
    required this.department,
    required this.team,
    required this.executiveSummary,
    this.activities = const [],
    this.achievements = const [],
    this.challenges = const [],
    this.keyMetrics = const [],
    this.learnings = const [],
    this.recommendations = const [],
    this.actionItems = const [],
    this.salesValue = 0,
    this.leadsGenerated = 0,
    this.opportunitiesCreated = 0,
    this.quotesSent = 0,
    this.proposalsSubmitted = 0,
    this.dealsClosed = 0,
    this.callsMade = 0,
    this.emailsSent = 0,
    this.reviewStatus = ReviewStatus.pending,
    this.approvalStatus = ApprovalStatus.pending,
    this.status = ReportStatus.draft,
    this.visibility = ReportVisibility.team,
    this.reviewedById,
    this.approvedById,
    this.reviewDate,
    this.approvalDate,
    this.comments = const [],
    this.tags = const [],
    this.isSubmitted = false,
    this.submittedAt,
    this.isEditedAfterSubmit = false,
    this.performanceRating,
    this.qualityScore,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed Properties
  String get fullTitle => '$title - $reportNumber';

  bool get isDraft => status == ReportStatus.draft;
  bool get isSubmittedForReview => status == ReportStatus.submitted;
  bool get isApproved => status == ReportStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;

  double get conversionRate => leadsGenerated > 0
      ? (dealsClosed / leadsGenerated) * 100
      : 0;

  bool get requiresAction => !isSubmitted ||
      reviewStatus == ReviewStatus.revisionsRequired ||
      approvalStatus == ApprovalStatus.revisionsRequired;

  bool get canEdit => !isSubmitted || isEditedAfterSubmit || isDraft;

  String get statusDisplay {
    if (!isSubmitted) return 'Draft';
    if (isApproved) return 'Approved';
    if (isRejected) return 'Rejected';
    if (reviewStatus == ReviewStatus.inReview) return 'In Review';
    if (reviewStatus == ReviewStatus.revisionsRequired) return 'Revisions Required';
    return 'Submitted';
  }

  Color get statusColor {
    if (!isSubmitted) return Colors.orange;
    if (isApproved) return Colors.green;
    if (isRejected) return Colors.red;
    if (reviewStatus == ReviewStatus.inReview) return Colors.blue;
    if (reviewStatus == ReviewStatus.revisionsRequired) return Colors.amber;
    return Colors.grey;
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'reportNumber': reportNumber,
    'title': title,
    'reportType': reportType.name,
    'periodType': periodType.name,
    'reportDate': reportDate.toUtc().toIso8601String(),
    'startDate': startDate.toUtc().toIso8601String(),
    'endDate': endDate.toUtc().toIso8601String(),
    'author': authorId,
    'department': department,
    'team': team,
    'executiveSummary': executiveSummary,
    'activities': activities.map((a) => a.toJson()).toList(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'challenges': challenges.map((c) => c.toJson()).toList(),
    'keyMetrics': keyMetrics.map((k) => k.toJson()).toList(),
    'learnings': learnings.map((l) => l.toJson()).toList(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'salesValue': salesValue,
    'leadsGenerated': leadsGenerated,
    'opportunitiesCreated': opportunitiesCreated,
    'quotesSent': quotesSent,
    'proposalsSubmitted': proposalsSubmitted,
    'dealsClosed': dealsClosed,
    'callsMade': callsMade,
    'emailsSent': emailsSent,
    'reviewStatus': reviewStatus.name,
    'approvalStatus': approvalStatus.name,
    'status': status.name,
    'visibility': visibility.name,
    if (reviewedById != null) 'reviewedBy': reviewedById,
    if (approvedById != null) 'approvedBy': approvedById,
    if (reviewDate != null) 'reviewDate': reviewDate!.toUtc().toIso8601String(),
    if (approvalDate != null) 'approvalDate': approvalDate!.toUtc().toIso8601String(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'tags': tags,
    'isSubmitted': isSubmitted,
    if (submittedAt != null) 'submittedAt': submittedAt!.toUtc().toIso8601String(),
    'isEditedAfterSubmit': isEditedAfterSubmit,
    if (performanceRating != null) 'performanceRating': performanceRating!.name,
    if (qualityScore != null) 'qualityScore': qualityScore,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      return Report(
        id: json['_id']?.toString() ?? '',
        reportNumber: json['reportNumber'] as String,
        title: json['title'] as String,
        reportType: ReportType.values.firstWhere(
              (e) => e.name == json['reportType'],
          orElse: () => ReportType.daily,
        ),
        periodType: PeriodType.values.firstWhere(
              (e) => e.name == json['periodType'],
          orElse: () => PeriodType.day,
        ),
        reportDate: DateTime.parse(json['reportDate'] as String).toLocal(),
        startDate: DateTime.parse(json['startDate'] as String).toLocal(),
        endDate: DateTime.parse(json['endDate'] as String).toLocal(),
        authorId: json['author']?['_id']?.toString() ?? json['author'] as String? ?? '',
        authorName: json['author']?['firstName'] != null && json['author']?['lastName'] != null
            ? '${json['author']['firstName']} ${json['author']['lastName']}'
            : null,
        department: json['department'] as String,
        team: json['team'] as String,
        executiveSummary: json['executiveSummary'] as String,
        activities: (json['activities'] as List<dynamic>?)
            ?.map((a) => Activity.fromJson(a))
            .toList() ??
            const [],
        achievements: (json['achievements'] as List<dynamic>?)
            ?.map((a) => Achievement.fromJson(a))
            .toList() ??
            const [],
        challenges: (json['challenges'] as List<dynamic>?)
            ?.map((c) => Challenge.fromJson(c))
            .toList() ??
            const [],
        keyMetrics: (json['keyMetrics'] as List<dynamic>?)
            ?.map((k) => KeyMetric.fromJson(k))
            .toList() ??
            const [],
        learnings: (json['learnings'] as List<dynamic>?)
            ?.map((l) => Learning.fromJson(l))
            .toList() ??
            const [],
        recommendations: (json['recommendations'] as List<dynamic>?)
            ?.map((r) => Recommendation.fromJson(r))
            .toList() ??
            const [],
        actionItems: (json['actionItems'] as List<dynamic>?)
            ?.map((a) => ActionItem.fromJson(a))
            .toList() ??
            const [],
        salesValue: (json['salesValue'] as num?)?.toDouble() ?? 0,
        leadsGenerated: json['leadsGenerated'] as int? ?? 0,
        opportunitiesCreated: json['opportunitiesCreated'] as int? ?? 0,
        quotesSent: json['quotesSent'] as int? ?? 0,
        proposalsSubmitted: json['proposalsSubmitted'] as int? ?? 0,
        dealsClosed: json['dealsClosed'] as int? ?? 0,
        callsMade: json['callsMade'] as int? ?? 0,
        emailsSent: json['emailsSent'] as int? ?? 0,
        reviewStatus: ReviewStatus.values.firstWhere(
              (e) => e.name == json['reviewStatus'],
          orElse: () => ReviewStatus.pending,
        ),
        approvalStatus: ApprovalStatus.values.firstWhere(
              (e) => e.name == json['approvalStatus'],
          orElse: () => ApprovalStatus.pending,
        ),
        status: ReportStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => ReportStatus.draft,
        ),
        visibility: ReportVisibility.values.firstWhere(
              (e) => e.name == json['visibility'],
          orElse: () => ReportVisibility.team,
        ),
        reviewedById: json['reviewedBy'] as String?,
        approvedById: json['approvedBy'] as String?,
        reviewDate: json['reviewDate'] != null
            ? DateTime.parse(json['reviewDate'] as String).toLocal()
            : null,
        approvalDate: json['approvalDate'] != null
            ? DateTime.parse(json['approvalDate'] as String).toLocal()
            : null,
        comments: (json['comments'] as List<dynamic>?)
            ?.map((c) => Comment.fromJson(c))
            .toList() ??
            const [],
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
        isSubmitted: json['isSubmitted'] as bool? ?? false,
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'] as String).toLocal()
            : null,
        isEditedAfterSubmit: json['isEditedAfterSubmit'] as bool? ?? false,
        performanceRating: json['performanceRating'] != null
            ? PerformanceRating.values.firstWhere(
              (e) => e.name == json['performanceRating'],
          orElse: () => PerformanceRating.satisfactory,
        )
            : null,
        qualityScore: (json['qualityScore'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );
    } catch (e, stack) {
      print('Error parsing Report: $e');
      print('Stack: $stack');
      print('JSON: $json');
      rethrow;
    }
  }

  Report copyWith({
    String? id,
    String? reportNumber,
    String? title,
    ReportType? reportType,
    PeriodType? periodType,
    DateTime? reportDate,
    DateTime? startDate,
    DateTime? endDate,
    String? authorId,
    String? authorName,
    String? department,
    String? team,
    String? executiveSummary,
    List<Activity>? activities,
    List<Achievement>? achievements,
    List<Challenge>? challenges,
    List<KeyMetric>? keyMetrics,
    List<Learning>? learnings,
    List<Recommendation>? recommendations,
    List<ActionItem>? actionItems,
    double? salesValue,
    int? leadsGenerated,
    int? opportunitiesCreated,
    int? quotesSent,
    int? proposalsSubmitted,
    int? dealsClosed,
    int? callsMade,
    int? emailsSent,
    ReviewStatus? reviewStatus,
    ApprovalStatus? approvalStatus,
    ReportStatus? status,
    ReportVisibility? visibility,
    String? reviewedById,
    String? approvedById,
    DateTime? reviewDate,
    DateTime? approvalDate,
    List<Comment>? comments,
    List<String>? tags,
    bool? isSubmitted,
    DateTime? submittedAt,
    bool? isEditedAfterSubmit,
    PerformanceRating? performanceRating,
    double? qualityScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      periodType: periodType ?? this.periodType,
      reportDate: reportDate ?? this.reportDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      department: department ?? this.department,
      team: team ?? this.team,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      activities: activities ?? this.activities,
      achievements: achievements ?? this.achievements,
      challenges: challenges ?? this.challenges,
      keyMetrics: keyMetrics ?? this.keyMetrics,
      learnings: learnings ?? this.learnings,
      recommendations: recommendations ?? this.recommendations,
      actionItems: actionItems ?? this.actionItems,
      salesValue: salesValue ?? this.salesValue,
      leadsGenerated: leadsGenerated ?? this.leadsGenerated,
      opportunitiesCreated: opportunitiesCreated ?? this.opportunitiesCreated,
      quotesSent: quotesSent ?? this.quotesSent,
      proposalsSubmitted: proposalsSubmitted ?? this.proposalsSubmitted,
      dealsClosed: dealsClosed ?? this.dealsClosed,
      callsMade: callsMade ?? this.callsMade,
      emailsSent: emailsSent ?? this.emailsSent,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      reviewedById: reviewedById ?? this.reviewedById,
      approvedById: approvedById ?? this.approvedById,
      reviewDate: reviewDate ?? this.reviewDate,
      approvalDate: approvalDate ?? this.approvalDate,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submittedAt: submittedAt ?? this.submittedAt,
      isEditedAfterSubmit: isEditedAfterSubmit ?? this.isEditedAfterSubmit,
      performanceRating: performanceRating ?? this.performanceRating,
      qualityScore: qualityScore ?? this.qualityScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ============================================
// REPORT FILTERS
// ============================================

@immutable
class ReportFilters {
  final ReportType? reportType;
  final PeriodType? periodType;
  final ReportStatus? status;
  final ApprovalStatus? approvalStatus;
  final ReviewStatus? reviewStatus;
  final String? department;
  final String? team;
  final String? authorId;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? endDateFrom;
  final DateTime? endDateTo;
  final DateTime? reportDateFrom;
  final DateTime? reportDateTo;
  final String? search;
  final List<String>? tags;
  final double? minSalesValue;
  final double? maxSalesValue;
  final bool? isSubmitted;
  final ReportVisibility? visibility;

  const ReportFilters({
    this.reportType,
    this.periodType,
    this.status,
    this.approvalStatus,
    this.reviewStatus,
    this.department,
    this.team,
    this.authorId,
    this.startDateFrom,
    this.startDateTo,
    this.endDateFrom,
    this.endDateTo,
    this.reportDateFrom,
    this.reportDateTo,
    this.search,
    this.tags,
    this.minSalesValue,
    this.maxSalesValue,
    this.isSubmitted,
    this.visibility,
  });

  // Create a static empty instance
  static const ReportFilters empty = ReportFilters();

  // Create a method that returns a cleared filter (new empty instance)
  ReportFilters clearAll() => ReportFilters.empty;

  // Method to clear specific fields
  ReportFilters clear({
    bool clearReportType = false,
    bool clearPeriodType = false,
    bool clearStatus = false,
    bool clearApprovalStatus = false,
    bool clearReviewStatus = false,
    bool clearDepartment = false,
    bool clearTeam = false,
    bool clearAuthorId = false,
    bool clearStartDateFrom = false,
    bool clearStartDateTo = false,
    bool clearEndDateFrom = false,
    bool clearEndDateTo = false,
    bool clearReportDateFrom = false,
    bool clearReportDateTo = false,
    bool clearSearch = false,
    bool clearTags = false,
    bool clearMinSalesValue = false,
    bool clearMaxSalesValue = false,
    bool clearIsSubmitted = false,
    bool clearVisibility = false,
  }) {
    return copyWith(
      reportType: clearReportType ? null : reportType,
      periodType: clearPeriodType ? null : periodType,
      status: clearStatus ? null : status,
      approvalStatus: clearApprovalStatus ? null : approvalStatus,
      reviewStatus: clearReviewStatus ? null : reviewStatus,
      department: clearDepartment ? null : department,
      team: clearTeam ? null : team,
      authorId: clearAuthorId ? null : authorId,
      startDateFrom: clearStartDateFrom ? null : startDateFrom,
      startDateTo: clearStartDateTo ? null : startDateTo,
      endDateFrom: clearEndDateFrom ? null : endDateFrom,
      endDateTo: clearEndDateTo ? null : endDateTo,
      reportDateFrom: clearReportDateFrom ? null : reportDateFrom,
      reportDateTo: clearReportDateTo ? null : reportDateTo,
      search: clearSearch ? null : search,
      tags: clearTags ? null : tags,
      minSalesValue: clearMinSalesValue ? null : minSalesValue,
      maxSalesValue: clearMaxSalesValue ? null : maxSalesValue,
      isSubmitted: clearIsSubmitted ? null : isSubmitted,
      visibility: clearVisibility ? null : visibility,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (reportType != null) params['reportType'] = reportType!.name;
    if (periodType != null) params['periodType'] = periodType!.name;
    if (status != null) params['status'] = status!.name;
    if (approvalStatus != null) params['approvalStatus'] = approvalStatus!.name;
    if (reviewStatus != null) params['reviewStatus'] = reviewStatus!.name;
    if (department != null && department!.isNotEmpty) params['department'] = department!;
    if (team != null && team!.isNotEmpty) params['team'] = team!;
    if (authorId != null && authorId!.isNotEmpty) params['author'] = authorId!;
    if (startDateFrom != null) params['startDateFrom'] = startDateFrom!.toIso8601String();
    if (startDateTo != null) params['startDateTo'] = startDateTo!.toIso8601String();
    if (endDateFrom != null) params['endDateFrom'] = endDateFrom!.toIso8601String();
    if (endDateTo != null) params['endDateTo'] = endDateTo!.toIso8601String();
    if (reportDateFrom != null) params['reportDateFrom'] = reportDateFrom!.toIso8601String();
    if (reportDateTo != null) params['reportDateTo'] = reportDateTo!.toIso8601String();
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    if (minSalesValue != null) params['minSalesValue'] = minSalesValue!;
    if (maxSalesValue != null) params['maxSalesValue'] = maxSalesValue!;
    if (isSubmitted != null) params['isSubmitted'] = isSubmitted!;
    if (visibility != null) params['visibility'] = visibility!.name;

    return params;
  }

  ReportFilters copyWith({
    ReportType? reportType,
    PeriodType? periodType,
    ReportStatus? status,
    ApprovalStatus? approvalStatus,
    ReviewStatus? reviewStatus,
    String? department,
    String? team,
    String? authorId,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    DateTime? reportDateFrom,
    DateTime? reportDateTo,
    String? search,
    List<String>? tags,
    double? minSalesValue,
    double? maxSalesValue,
    bool? isSubmitted,
    ReportVisibility? visibility,
  }) {
    return ReportFilters(
      reportType: reportType ?? this.reportType,
      periodType: periodType ?? this.periodType,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      department: department ?? this.department,
      team: team ?? this.team,
      authorId: authorId ?? this.authorId,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      endDateFrom: endDateFrom ?? this.endDateFrom,
      endDateTo: endDateTo ?? this.endDateTo,
      reportDateFrom: reportDateFrom ?? this.reportDateFrom,
      reportDateTo: reportDateTo ?? this.reportDateTo,
      search: search ?? this.search,
      tags: tags ?? this.tags,
      minSalesValue: minSalesValue ?? this.minSalesValue,
      maxSalesValue: maxSalesValue ?? this.maxSalesValue,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      visibility: visibility ?? this.visibility,
    );
  }

  bool get hasFilters {
    return reportType != null ||
        periodType != null ||
        status != null ||
        approvalStatus != null ||
        reviewStatus != null ||
        (department != null && department!.isNotEmpty) ||
        (team != null && team!.isNotEmpty) ||
        (authorId != null && authorId!.isNotEmpty) ||
        startDateFrom != null ||
        startDateTo != null ||
        endDateFrom != null ||
        endDateTo != null ||
        reportDateFrom != null ||
        reportDateTo != null ||
        (search != null && search!.isNotEmpty) ||
        (tags != null && tags!.isNotEmpty) ||
        minSalesValue != null ||
        maxSalesValue != null ||
        isSubmitted != null ||
        visibility != null;
  }
}

// ============================================
// REPORT STATISTICS
// ============================================

@immutable
class ReportStats {
  final int total;
  final int draft;
  final int submitted;
  final int approved;
  final int rejected;
  final int pendingReview;
  final double totalSalesValue;
  final Map<ReportType, int> byType;
  final Map<ReportStatus, int> byStatus;
  final Map<String, int> byDepartment;
  final Map<String, int> byTeam;
  final double averageQualityScore;

  const ReportStats({
    required this.total,
    required this.draft,
    required this.submitted,
    required this.approved,
    required this.rejected,
    required this.pendingReview,
    required this.totalSalesValue,
    required this.byType,
    required this.byStatus,
    required this.byDepartment,
    required this.byTeam,
    required this.averageQualityScore,
  });

  factory ReportStats.fromJson(Map<String, dynamic> json) {
    final byType = <ReportType, int>{};
    final byTypeList = (json['byType'] as Map<String, dynamic>);
    byTypeList.forEach((key, value) {
      final type = ReportType.values.firstWhere(
            (e) => e.name == key,
        orElse: () => ReportType.daily,
      );
      byType[type] = value as int;
    });

    final byStatus = <ReportStatus, int>{};
    final byStatusList = (json['byStatus'] as Map<String, dynamic>);
    byStatusList.forEach((key, value) {
      final status = ReportStatus.values.firstWhere(
            (e) => e.name == key,
        orElse: () => ReportStatus.draft,
      );
      byStatus[status] = value as int;
    });

    final byDepartment = <String, int>{};
    final byDeptList = (json['byDepartment'] as List<dynamic>);
    for (final item in byDeptList) {
      final dept = item['department'] as String;
      final count = item['count'] as int;
      byDepartment[dept] = count;
    }

    final byTeam = <String, int>{};
    final byTeamList = (json['byTeam'] as List<dynamic>);
    for (final item in byTeamList) {
      final team = item['team'] as String;
      final count = item['count'] as int;
      byTeam[team] = count;
    }

    return ReportStats(
      total: json['total'] as int,
      draft: json['byStatus']['draft'] as int? ?? 0,
      submitted: json['submittedCount'] as int? ?? 0,
      approved: json['approvedCount'] as int? ?? 0,
      rejected: json['byApprovalStatus']['rejected'] as int? ?? 0,
      pendingReview: json['pendingReviewCount'] as int? ?? 0,
      totalSalesValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
      byType: byType,
      byStatus: byStatus,
      byDepartment: byDepartment,
      byTeam: byTeam,
      averageQualityScore: (json['averageQualityScore'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ============================================
// REPORT DASHBOARD STATS
// ============================================

@immutable
class ReportDashboardStats {
  final ReportStats overview;
  final List<Report> recentReports;
  final List<Report> pendingReviews;
  final List<Map<String, dynamic>> topPerformers;
  final List<Map<String, dynamic>> performanceTrend;
  final List<Map<String, dynamic>> departmentStats;

  const ReportDashboardStats({
    required this.overview,
    required this.recentReports,
    required this.pendingReviews,
    required this.topPerformers,
    required this.performanceTrend,
    required this.departmentStats,
  });

  factory ReportDashboardStats.fromJson(Map<String, dynamic> json) {
    return ReportDashboardStats(
      overview: ReportStats.fromJson(json['overview']),
      recentReports: (json['recentReports'] as List<dynamic>)
          .map((r) => Report.fromJson(r))
          .toList(),
      pendingReviews: (json['pendingReviews'] as List<dynamic>)
          .map((r) => Report.fromJson(r))
          .toList(),
      topPerformers: (json['topPerformers'] as List<dynamic>).cast<Map<String, dynamic>>(),
      performanceTrend: (json['performanceTrend'] as List<dynamic>).cast<Map<String, dynamic>>(),
      departmentStats: (json['departmentStats'] as List<dynamic>).cast<Map<String, dynamic>>(),
    );
  }
}

// ============================================
// CREATE REPORT DATA
// ============================================

class CreateReportData {
  final String title;
  final ReportType reportType;
  final PeriodType periodType;
  final DateTime reportDate;
  final DateTime startDate;
  final DateTime endDate;
  final String department;
  final String team;
  final String executiveSummary;
  final List<Activity> activities;
  final List<Achievement> achievements;
  final List<Challenge> challenges;
  final List<KeyMetric> keyMetrics;
  final List<Learning> learnings;
  final List<Recommendation> recommendations;
  final List<ActionItem> actionItems;
  final double salesValue;
  final int leadsGenerated;
  final int opportunitiesCreated;
  final int quotesSent;
  final int proposalsSubmitted;
  final int dealsClosed;
  final int callsMade;
  final int emailsSent;
  final List<String> tags;
  final ReportVisibility visibility;

  const CreateReportData({
    required this.title,
    required this.reportType,
    required this.periodType,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    required this.department,
    required this.team,
    required this.executiveSummary,
    this.activities = const [],
    this.achievements = const [],
    this.challenges = const [],
    this.keyMetrics = const [],
    this.learnings = const [],
    this.recommendations = const [],
    this.actionItems = const [],
    this.salesValue = 0,
    this.leadsGenerated = 0,
    this.opportunitiesCreated = 0,
    this.quotesSent = 0,
    this.proposalsSubmitted = 0,
    this.dealsClosed = 0,
    this.callsMade = 0,
    this.emailsSent = 0,
    this.tags = const [],
    this.visibility = ReportVisibility.team,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'reportType': reportType.name,
    'periodType': periodType.name,
    'reportDate': reportDate.toUtc().toIso8601String(),
    'startDate': startDate.toUtc().toIso8601String(),
    'endDate': endDate.toUtc().toIso8601String(),
    'department': department,
    'team': team,
    'executiveSummary': executiveSummary,
    'activities': activities.map((a) => a.toJson()).toList(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'challenges': challenges.map((c) => c.toJson()).toList(),
    'keyMetrics': keyMetrics.map((k) => k.toJson()).toList(),
    'learnings': learnings.map((l) => l.toJson()).toList(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'salesValue': salesValue,
    'leadsGenerated': leadsGenerated,
    'opportunitiesCreated': opportunitiesCreated,
    'quotesSent': quotesSent,
    'proposalsSubmitted': proposalsSubmitted,
    'dealsClosed': dealsClosed,
    'callsMade': callsMade,
    'emailsSent': emailsSent,
    'tags': tags,
    'visibility': visibility.name,
    'createdBy': '', // Will be set by provider
  };
}