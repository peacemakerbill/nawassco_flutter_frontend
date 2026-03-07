import 'package:flutter/material.dart';
import 'key_performance_area.model.dart';
import 'competency_assessment.model.dart';
import 'goal_assessment.model.dart';
import 'development_plan.model.dart';

// Enums matching backend
enum PerformanceLevel {
  exceedsExpectations('Exceeds Expectations'),
  meetsExpectations('Meets Expectations'),
  needsImprovement('Needs Improvement'),
  unsatisfactory('Unsatisfactory');

  final String displayName;
  const PerformanceLevel(this.displayName);

  factory PerformanceLevel.fromString(String value) {
    return PerformanceLevel.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => PerformanceLevel.meetsExpectations,
    );
  }
}

enum PotentialLevel {
  highPotential('High Potential'),
  growthPotential('Growth Potential'),
  steadyPerformer('Steady Performer'),
  plateaued('Plateaued');

  final String displayName;
  const PotentialLevel(this.displayName);

  factory PotentialLevel.fromString(String value) {
    return PotentialLevel.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => PotentialLevel.steadyPerformer,
    );
  }
}

enum AppraisalStatus {
  draft('Draft'),
  underReview('Under Review'),
  completed('Completed'),
  acknowledged('Acknowledged'),
  closed('Closed');

  final String displayName;
  const AppraisalStatus(this.displayName);

  factory AppraisalStatus.fromString(String value) {
    return AppraisalStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => AppraisalStatus.draft,
    );
  }

  Color get color {
    return switch (this) {
      AppraisalStatus.draft => Colors.grey,
      AppraisalStatus.underReview => Colors.orange,
      AppraisalStatus.completed => Colors.blue,
      AppraisalStatus.acknowledged => Colors.green,
      AppraisalStatus.closed => Colors.purple,
    };
  }

  IconData get icon {
    return switch (this) {
      AppraisalStatus.draft => Icons.drafts,
      AppraisalStatus.underReview => Icons.reviews,
      AppraisalStatus.completed => Icons.check_circle,
      AppraisalStatus.acknowledged => Icons.verified,
      AppraisalStatus.closed => Icons.archive,
    };
  }
}

class PerformanceAppraisal {
  final String id;
  final String appraisalNumber;
  final String employeeId;
  final String employeeName;
  final String appraisalPeriod;
  final DateTime appraisalDate;
  final DateTime nextAppraisalDate;
  final String reviewerId;
  final String reviewerName;
  final String? secondReviewerId;
  final String? secondReviewerName;
  final String hrReviewerId;
  final String hrReviewerName;
  final List<KeyPerformanceArea> keyPerformanceAreas;
  final List<CompetencyAssessment> competencies;
  final List<GoalAssessment> goals;
  final double overallRating;
  final PerformanceLevel performanceLevel;
  final PotentialLevel potentialLevel;
  final List<String> strengths;
  final List<String> developmentAreas;
  final String? employeeComments;
  final String reviewerComments;
  final List<DevelopmentPlan> developmentPlan;
  final List<String> trainingRecommendations;
  final AppraisalStatus status;
  final bool employeeAcknowledged;
  final DateTime? acknowledgedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PerformanceAppraisal({
    required this.id,
    required this.appraisalNumber,
    required this.employeeId,
    required this.employeeName,
    required this.appraisalPeriod,
    required this.appraisalDate,
    required this.nextAppraisalDate,
    required this.reviewerId,
    required this.reviewerName,
    this.secondReviewerId,
    this.secondReviewerName,
    required this.hrReviewerId,
    required this.hrReviewerName,
    this.keyPerformanceAreas = const [],
    this.competencies = const [],
    this.goals = const [],
    required this.overallRating,
    required this.performanceLevel,
    required this.potentialLevel,
    this.strengths = const [],
    this.developmentAreas = const [],
    this.employeeComments,
    required this.reviewerComments,
    this.developmentPlan = const [],
    this.trainingRecommendations = const [],
    required this.status,
    required this.employeeAcknowledged,
    this.acknowledgedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PerformanceAppraisal.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] is Map ? json['employee'] : {};
    final reviewer = json['reviewer'] is Map ? json['reviewer'] : {};
    final hrReviewer = json['hrReviewer'] is Map ? json['hrReviewer'] : {};
    final secondReviewer = json['secondReviewer'] is Map ? json['secondReviewer'] : {};

    return PerformanceAppraisal(
      id: json['_id'],
      appraisalNumber: json['appraisalNumber'],
      employeeId: json['employee'] is String ? json['employee'] : employee['_id'] ?? '',
      employeeName: employee['firstName'] != null
          ? '${employee['firstName']} ${employee['lastName']}'
          : 'Unknown Employee',
      appraisalPeriod: json['appraisalPeriod'],
      appraisalDate: DateTime.parse(json['appraisalDate']),
      nextAppraisalDate: DateTime.parse(json['nextAppraisalDate']),
      reviewerId: json['reviewer'] is String ? json['reviewer'] : reviewer['_id'] ?? '',
      reviewerName: reviewer['firstName'] != null
          ? '${reviewer['firstName']} ${reviewer['lastName']}'
          : 'Unknown Reviewer',
      secondReviewerId: secondReviewer.isNotEmpty ? secondReviewer['_id'] : null,
      secondReviewerName: secondReviewer.isNotEmpty && secondReviewer['firstName'] != null
          ? '${secondReviewer['firstName']} ${secondReviewer['lastName']}'
          : null,
      hrReviewerId: json['hrReviewer'] is String ? json['hrReviewer'] : hrReviewer['_id'] ?? '',
      hrReviewerName: hrReviewer['firstName'] != null
          ? '${hrReviewer['firstName']} ${hrReviewer['lastName']}'
          : 'Unknown HR',
      keyPerformanceAreas: (json['keyPerformanceAreas'] as List?)
          ?.map((e) => KeyPerformanceArea.fromJson(e))
          .toList() ?? [],
      competencies: (json['competencies'] as List?)
          ?.map((e) => CompetencyAssessment.fromJson(e))
          .toList() ?? [],
      goals: (json['goals'] as List?)
          ?.map((e) => GoalAssessment.fromJson(e))
          .toList() ?? [],
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      performanceLevel: PerformanceLevel.fromString(json['performanceLevel'] ?? 'meets_expectations'),
      potentialLevel: PotentialLevel.fromString(json['potentialLevel'] ?? 'steady_performer'),
      strengths: List<String>.from(json['strengths'] ?? []),
      developmentAreas: List<String>.from(json['developmentAreas'] ?? []),
      employeeComments: json['employeeComments'],
      reviewerComments: json['reviewerComments'] ?? '',
      developmentPlan: (json['developmentPlan'] as List?)
          ?.map((e) => DevelopmentPlan.fromJson(e))
          .toList() ?? [],
      trainingRecommendations: List<String>.from(json['trainingRecommendations'] ?? []),
      status: AppraisalStatus.fromString(json['status'] ?? 'draft'),
      employeeAcknowledged: json['employeeAcknowledged'] ?? false,
      acknowledgedDate: json['acknowledgedDate'] != null
          ? DateTime.parse(json['acknowledgedDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appraisalNumber': appraisalNumber,
      'employee': employeeId,
      'appraisalPeriod': appraisalPeriod,
      'appraisalDate': appraisalDate.toIso8601String(),
      'nextAppraisalDate': nextAppraisalDate.toIso8601String(),
      'reviewer': reviewerId,
      if (secondReviewerId != null) 'secondReviewer': secondReviewerId,
      'hrReviewer': hrReviewerId,
      'keyPerformanceAreas': keyPerformanceAreas.map((e) => e.toJson()).toList(),
      'competencies': competencies.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'overallRating': overallRating,
      'performanceLevel': performanceLevel.name,
      'potentialLevel': potentialLevel.name,
      'strengths': strengths,
      'developmentAreas': developmentAreas,
      if (employeeComments != null) 'employeeComments': employeeComments,
      'reviewerComments': reviewerComments,
      'developmentPlan': developmentPlan.map((e) => e.toJson()).toList(),
      'trainingRecommendations': trainingRecommendations,
      'status': status.name,
      'employeeAcknowledged': employeeAcknowledged,
      if (acknowledgedDate != null) 'acknowledgedDate': acknowledgedDate!.toIso8601String(),
    };
  }

  // Helper methods
  bool get canEdit => status == AppraisalStatus.draft;
  bool get canSubmit => status == AppraisalStatus.draft;
  bool get canReview => status == AppraisalStatus.underReview;
  bool get canComplete => status == AppraisalStatus.underReview;
  bool get canAcknowledge => status == AppraisalStatus.completed && !employeeAcknowledged;
  bool get isCompleted => status == AppraisalStatus.completed ||
      status == AppraisalStatus.acknowledged ||
      status == AppraisalStatus.closed;
}