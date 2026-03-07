import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enums matching backend
enum TrainingType { internal, external, online, workshop, seminar }

enum TrainingCategory {
  technical_skills,
  soft_skills,
  management,
  compliance,
  safety,
  leadership
}

enum TrainingLevel { beginner, intermediate, advanced, expert }

enum DurationUnit { hours, days, weeks, months }

enum TrainingStatus {
  planned,
  open_for_registration,
  confirmed,
  in_progress,
  completed,
  cancelled
}

enum ParticipantStatus { registered, attended, completed, no_show, cancelled }

// Evaluation Criterion
class EvaluationCriterion {
  final String criterion;
  final double weight;
  final double averageScore;

  EvaluationCriterion({
    required this.criterion,
    required this.weight,
    required this.averageScore,
  });

  factory EvaluationCriterion.fromJson(Map<String, dynamic> json) {
    return EvaluationCriterion(
      criterion: json['criterion'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      averageScore: (json['averageScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'weight': weight,
      'averageScore': averageScore,
    };
  }
}

// Participant Model
class TrainingParticipant {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeNumber;
  final String department;
  final DateTime registrationDate;
  ParticipantStatus status;
  double? preTrainingScore;
  double? postTrainingScore;
  double? improvement;
  String? feedback;
  String? certificateUrl;
  final String? jobTitle;

  TrainingParticipant({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeNumber,
    required this.department,
    required this.registrationDate,
    required this.status,
    this.preTrainingScore,
    this.postTrainingScore,
    this.improvement,
    this.feedback,
    this.certificateUrl,
    this.jobTitle,
  });

  factory TrainingParticipant.fromJson(Map<String, dynamic> json) {
    return TrainingParticipant(
      id: json['_id'] ?? json['id'] ?? '',
      employeeId: json['employee']?['_id'] ?? json['employeeId'] ?? '',
      employeeName:
          '${json['employee']?['personalDetails']?['firstName'] ?? ''} ${json['employee']?['personalDetails']?['lastName'] ?? ''}',
      employeeNumber: json['employee']?['employeeNumber'] ?? '',
      department: json['employee']?['jobInformation']?['department'] ?? '',
      registrationDate: DateTime.parse(
          json['registrationDate'] ?? DateTime.now().toIso8601String()),
      status: _parseParticipantStatus(json['status'] ?? 'registered'),
      preTrainingScore: (json['preTrainingScore'] ?? 0).toDouble(),
      postTrainingScore: (json['postTrainingScore'] ?? 0).toDouble(),
      improvement: (json['improvement'] ?? 0).toDouble(),
      feedback: json['feedback'],
      certificateUrl: json['certificateUrl'],
      jobTitle: json['employee']?['jobInformation']?['jobTitle'] ?? '',
    );
  }

  static ParticipantStatus _parseParticipantStatus(String status) {
    switch (status) {
      case 'attended':
        return ParticipantStatus.attended;
      case 'completed':
        return ParticipantStatus.completed;
      case 'no_show':
        return ParticipantStatus.no_show;
      case 'cancelled':
        return ParticipantStatus.cancelled;
      default:
        return ParticipantStatus.registered;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'status': status.name,
      'feedback': feedback,
      'preTrainingScore': preTrainingScore,
      'postTrainingScore': postTrainingScore,
    };
  }

  String get statusText {
    switch (status) {
      case ParticipantStatus.registered:
        return 'Registered';
      case ParticipantStatus.attended:
        return 'Attended';
      case ParticipantStatus.completed:
        return 'Completed';
      case ParticipantStatus.no_show:
        return 'No Show';
      case ParticipantStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case ParticipantStatus.registered:
        return Colors.blue;
      case ParticipantStatus.attended:
        return Colors.orange;
      case ParticipantStatus.completed:
        return Colors.green;
      case ParticipantStatus.no_show:
        return Colors.red;
      case ParticipantStatus.cancelled:
        return Colors.grey;
    }
  }
}

// Training Material
class TrainingMaterial {
  final String id;
  final String name;
  final String url;
  final String fileName;
  final String uploadedBy;
  final DateTime uploadDate;

  TrainingMaterial({
    required this.id,
    required this.name,
    required this.url,
    required this.fileName,
    required this.uploadedBy,
    required this.uploadDate,
  });

  factory TrainingMaterial.fromJson(Map<String, dynamic> json) {
    return TrainingMaterial(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadDate: DateTime.parse(
          json['uploadDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get fileType {
    final ext = fileName.split('.').last.toLowerCase();
    if (['pdf'].contains(ext)) return 'PDF';
    if (['doc', 'docx'].contains(ext)) return 'Word';
    if (['ppt', 'pptx'].contains(ext)) return 'PowerPoint';
    if (['xls', 'xlsx'].contains(ext)) return 'Excel';
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return 'Image';
    if (['mp4', 'avi', 'mov'].contains(ext)) return 'Video';
    return 'File';
  }

  IconData get fileIcon {
    final ext = fileName.split('.').last.toLowerCase();
    if (['pdf'].contains(ext)) return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    if (['ppt', 'pptx'].contains(ext)) return Icons.slideshow;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart;
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return Icons.image;
    if (['mp4', 'avi', 'mov'].contains(ext)) return Icons.video_library;
    return Icons.insert_drive_file;
  }
}

// Main Training Model
class Training {
  final String id;
  final String trainingCode;
  final String trainingTitle;
  final String description;
  final TrainingType trainingType;
  final TrainingCategory category;
  final TrainingLevel level;
  final int duration;
  final DurationUnit durationUnit;
  final String provider;
  final String trainer;
  final double cost;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String venue;
  final int maxParticipants;
  final List<TrainingParticipant> participants;
  final List<String> waitingList;
  final List<EvaluationCriterion> evaluationCriteria;
  final double averageRating;
  final TrainingStatus status;
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TrainingMaterial> materials;
  final int totalParticipants;
  final int availableSlots;
  final bool isRegistered;
  final double? myRating;

  Training({
    required this.id,
    required this.trainingCode,
    required this.trainingTitle,
    required this.description,
    required this.trainingType,
    required this.category,
    required this.level,
    required this.duration,
    required this.durationUnit,
    required this.provider,
    required this.trainer,
    required this.cost,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.venue,
    required this.maxParticipants,
    required this.participants,
    required this.waitingList,
    required this.evaluationCriteria,
    required this.averageRating,
    required this.status,
    required this.createdBy,
    required this.creatorName,
    required this.createdAt,
    required this.updatedAt,
    required this.materials,
    required this.totalParticipants,
    required this.availableSlots,
    required this.isRegistered,
    this.myRating,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List? ?? [])
        .map((p) => TrainingParticipant.fromJson(p))
        .toList();

    final maxParticipants = json['maxParticipants'] ?? 0;
    final totalParticipants = participants.length;

    return Training(
      id: json['_id'] ?? json['id'] ?? '',
      trainingCode: json['trainingCode'] ?? '',
      trainingTitle: json['trainingTitle'] ?? '',
      description: json['description'] ?? '',
      trainingType: _parseTrainingType(json['trainingType'] ?? 'internal'),
      category: _parseTrainingCategory(json['category'] ?? 'technical_skills'),
      level: _parseTrainingLevel(json['level'] ?? 'beginner'),
      duration: json['duration'] ?? 0,
      durationUnit: _parseDurationUnit(json['durationUnit'] ?? 'hours'),
      provider: json['provider'] ?? '',
      trainer: json['trainer'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      registrationDeadline: DateTime.parse(
          json['registrationDeadline'] ?? DateTime.now().toIso8601String()),
      venue: json['venue'] ?? '',
      maxParticipants: maxParticipants,
      participants: participants,
      waitingList: List<String>.from(json['waitingList'] ?? []),
      evaluationCriteria: (json['evaluationCriteria'] as List? ?? [])
          .map((e) => EvaluationCriterion.fromJson(e))
          .toList(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      status: _parseTrainingStatus(json['status'] ?? 'planned'),
      createdBy: json['createdBy']?['_id'] ?? '',
      creatorName:
          '${json['createdBy']?['personalDetails']?['firstName'] ?? ''} ${json['createdBy']?['personalDetails']?['lastName'] ?? ''}',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      materials: (json['materials'] as List? ?? [])
          .map((m) => TrainingMaterial.fromJson(m))
          .toList(),
      totalParticipants: totalParticipants,
      availableSlots: maxParticipants - totalParticipants,
      isRegistered: false,
      myRating: null,
    );
  }

  static TrainingType _parseTrainingType(String type) {
    switch (type) {
      case 'external':
        return TrainingType.external;
      case 'online':
        return TrainingType.online;
      case 'workshop':
        return TrainingType.workshop;
      case 'seminar':
        return TrainingType.seminar;
      default:
        return TrainingType.internal;
    }
  }

  static TrainingCategory _parseTrainingCategory(String category) {
    switch (category) {
      case 'soft_skills':
        return TrainingCategory.soft_skills;
      case 'management':
        return TrainingCategory.management;
      case 'compliance':
        return TrainingCategory.compliance;
      case 'safety':
        return TrainingCategory.safety;
      case 'leadership':
        return TrainingCategory.leadership;
      default:
        return TrainingCategory.technical_skills;
    }
  }

  static TrainingLevel _parseTrainingLevel(String level) {
    switch (level) {
      case 'intermediate':
        return TrainingLevel.intermediate;
      case 'advanced':
        return TrainingLevel.advanced;
      case 'expert':
        return TrainingLevel.expert;
      default:
        return TrainingLevel.beginner;
    }
  }

  static DurationUnit _parseDurationUnit(String unit) {
    switch (unit) {
      case 'days':
        return DurationUnit.days;
      case 'weeks':
        return DurationUnit.weeks;
      case 'months':
        return DurationUnit.months;
      default:
        return DurationUnit.hours;
    }
  }

  static TrainingStatus _parseTrainingStatus(String status) {
    switch (status) {
      case 'open_for_registration':
        return TrainingStatus.open_for_registration;
      case 'confirmed':
        return TrainingStatus.confirmed;
      case 'in_progress':
        return TrainingStatus.in_progress;
      case 'completed':
        return TrainingStatus.completed;
      case 'cancelled':
        return TrainingStatus.cancelled;
      default:
        return TrainingStatus.planned;
    }
  }

  String get formattedDate {
    final dateFormat = DateFormat('dd MMM yyyy');
    return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
  }

  String get durationText => '$duration ${durationUnit.name}';

  String get categoryText {
    final text = category.name;
    return text
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String get typeText {
    final text = trainingType.name;
    return text[0].toUpperCase() + text.substring(1);
  }

  String get levelText {
    final text = level.name;
    return text[0].toUpperCase() + text.substring(1);
  }

  String get statusText {
    final text = status.name;
    return text
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Color get statusColor {
    switch (status) {
      case TrainingStatus.planned:
        return Colors.blue;
      case TrainingStatus.open_for_registration:
        return Colors.green;
      case TrainingStatus.confirmed:
        return Colors.teal;
      case TrainingStatus.in_progress:
        return Colors.orange;
      case TrainingStatus.completed:
        return Colors.purple;
      case TrainingStatus.cancelled:
        return Colors.red;
    }
  }

  bool get isOpenForRegistration {
    return status == TrainingStatus.open_for_registration &&
        DateTime.now().isBefore(registrationDeadline) &&
        availableSlots > 0;
  }

  double get progressPercentage {
    if (maxParticipants == 0) return 0;
    return (totalParticipants / maxParticipants) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'trainingTitle': trainingTitle,
      'description': description,
      'trainingType': trainingType.name,
      'category': category.name,
      'level': level.name,
      'duration': duration,
      'durationUnit': durationUnit.name,
      'provider': provider,
      'trainer': trainer,
      'cost': cost,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'venue': venue,
      'maxParticipants': maxParticipants,
    };
  }

  Training copyWith({
    String? id,
    String? trainingCode,
    String? trainingTitle,
    String? description,
    TrainingType? trainingType,
    TrainingCategory? category,
    TrainingLevel? level,
    int? duration,
    DurationUnit? durationUnit,
    String? provider,
    String? trainer,
    double? cost,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    String? venue,
    int? maxParticipants,
    List<TrainingParticipant>? participants,
    List<String>? waitingList,
    List<EvaluationCriterion>? evaluationCriteria,
    double? averageRating,
    TrainingStatus? status,
    String? createdBy,
    String? creatorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrainingMaterial>? materials,
    int? totalParticipants,
    int? availableSlots,
    bool? isRegistered,
    double? myRating,
  }) {
    return Training(
      id: id ?? this.id,
      trainingCode: trainingCode ?? this.trainingCode,
      trainingTitle: trainingTitle ?? this.trainingTitle,
      description: description ?? this.description,
      trainingType: trainingType ?? this.trainingType,
      category: category ?? this.category,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      durationUnit: durationUnit ?? this.durationUnit,
      provider: provider ?? this.provider,
      trainer: trainer ?? this.trainer,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      venue: venue ?? this.venue,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      waitingList: waitingList ?? this.waitingList,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      averageRating: averageRating ?? this.averageRating,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      materials: materials ?? this.materials,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      availableSlots: availableSlots ?? this.availableSlots,
      isRegistered: isRegistered ?? this.isRegistered,
      myRating: myRating ?? this.myRating,
    );
  }
}

// Training Statistics
class TrainingStatistics {
  final int totalTrainings;
  final int upcomingTrainings;
  final int completedTrainings;
  final List<CategoryStat> categoryStats;
  final List<DepartmentStat> departmentStats;

  TrainingStatistics({
    required this.totalTrainings,
    required this.upcomingTrainings,
    required this.completedTrainings,
    required this.categoryStats,
    required this.departmentStats,
  });

  factory TrainingStatistics.fromJson(Map<String, dynamic> json) {
    return TrainingStatistics(
      totalTrainings: json['totalTrainings'] ?? 0,
      upcomingTrainings: json['upcomingTrainings'] ?? 0,
      completedTrainings: json['completedTrainings'] ?? 0,
      categoryStats: (json['categoryStats'] as List? ?? [])
          .map((c) => CategoryStat.fromJson(c))
          .toList(),
      departmentStats: (json['departmentStats'] as List? ?? [])
          .map((d) => DepartmentStat.fromJson(d))
          .toList(),
    );
  }
}

class CategoryStat {
  final String category;
  final int count;

  CategoryStat({
    required this.category,
    required this.count,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      category: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DepartmentStat {
  final String department;
  final int participantCount;

  DepartmentStat({
    required this.department,
    required this.participantCount,
  });

  factory DepartmentStat.fromJson(Map<String, dynamic> json) {
    return DepartmentStat(
      department: json['_id'] ?? 'Unknown',
      participantCount: json['participantCount'] ?? 0,
    );
  }
}
