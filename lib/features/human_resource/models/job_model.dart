import 'package:flutter/material.dart';

// Enums
enum JobType {
  FULL_TIME('Full Time'),
  PART_TIME('Part Time'),
  CONTRACT('Contract'),
  INTERNSHIP('Internship'),
  ATTACHMENT('Attachment'),
  TEMPORARY('Temporary');

  final String displayName;

  const JobType(this.displayName);

  static JobType fromString(String value) {
    return JobType.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll(' ', '_'),
      orElse: () => JobType.FULL_TIME,
    );
  }
}

enum PositionType {
  ENTRY_LEVEL('Entry Level'),
  MID_LEVEL('Mid Level'),
  SENIOR('Senior'),
  MANAGERIAL('Managerial'),
  EXECUTIVE('Executive'),
  DIRECTOR('Director');

  final String displayName;

  const PositionType(this.displayName);

  static PositionType fromString(String value) {
    return PositionType.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll(' ', '_'),
      orElse: () => PositionType.ENTRY_LEVEL,
    );
  }
}

enum WorkMode {
  ONSITE('On-site'),
  REMOTE('Remote'),
  HYBRID('Hybrid');

  final String displayName;

  const WorkMode(this.displayName);

  static WorkMode fromString(String value) {
    return WorkMode.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => WorkMode.ONSITE,
    );
  }
}

enum PayPeriod {
  HOURLY('Hourly'),
  DAILY('Daily'),
  WEEKLY('Weekly'),
  BI_WEEKLY('Bi-Weekly'),
  MONTHLY('Monthly'),
  ANNUAL('Annual');

  final String displayName;

  const PayPeriod(this.displayName);

  static PayPeriod fromString(String value) {
    return PayPeriod.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll('-', '_'),
      orElse: () => PayPeriod.MONTHLY,
    );
  }
}

enum JobStatus {
  DRAFT('Draft'),
  PUBLISHED('Published'),
  CLOSED('Closed'),
  CANCELLED('Cancelled');

  final String displayName;

  const JobStatus(this.displayName);

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => JobStatus.DRAFT,
    );
  }
}

enum ExperienceLevel {
  ENTRY('Entry Level (0-2 years)'),
  JUNIOR('Junior (2-4 years)'),
  MID('Mid Level (4-7 years)'),
  SENIOR('Senior (7-10 years)'),
  EXPERT('Expert (10+ years)');

  final String displayName;

  const ExperienceLevel(this.displayName);

  static ExperienceLevel fromString(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll(' ', '_'),
      orElse: () => ExperienceLevel.ENTRY,
    );
  }
}

enum ProficiencyLevel {
  BEGINNER('Beginner'),
  INTERMEDIATE('Intermediate'),
  ADVANCED('Advanced'),
  EXPERT('Expert');

  final String displayName;

  const ProficiencyLevel(this.displayName);

  static ProficiencyLevel fromString(String value) {
    return ProficiencyLevel.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => ProficiencyLevel.BEGINNER,
    );
  }
}

enum InstitutionType {
  UNIVERSITY('University'),
  COLLEGE('College'),
  POLYTECHNIC('Polytechnic'),
  VOCATIONAL('Vocational'),
  ONLINE('Online'),
  ANY('Any');

  final String displayName;

  const InstitutionType(this.displayName);

  static InstitutionType fromString(String value) {
    return InstitutionType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => InstitutionType.ANY,
    );
  }
}

enum InternshipType {
  SUMMER('Summer Internship'),
  WINTER('Winter Internship'),
  SEMESTER('Semester Internship'),
  GRADUATE('Graduate Internship'),
  REMOTE('Remote Internship');

  final String displayName;

  const InternshipType(this.displayName);

  static InternshipType fromString(String value) {
    return InternshipType.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll(' ', '_'),
      orElse: () => InternshipType.SUMMER,
    );
  }
}

enum PaymentFrequency {
  WEEKLY('Weekly'),
  BI_WEEKLY('Bi-Weekly'),
  MONTHLY('Monthly'),
  UPON_COMPLETION('Upon Completion');

  final String displayName;

  const PaymentFrequency(this.displayName);

  static PaymentFrequency fromString(String value) {
    return PaymentFrequency.values.firstWhere(
      (e) => e.name == value.toUpperCase().replaceAll(' ', '_'),
      orElse: () => PaymentFrequency.MONTHLY,
    );
  }
}

// Supporting Models
@immutable
class SalaryRange {
  final double min;
  final double max;
  final String currency;
  final bool isNegotiable;
  final PayPeriod payPeriod;

  const SalaryRange({
    required this.min,
    required this.max,
    this.currency = 'USD',
    this.isNegotiable = false,
    this.payPeriod = PayPeriod.MONTHLY,
  });

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      isNegotiable: json['isNegotiable'] ?? false,
      payPeriod: PayPeriod.fromString(json['payPeriod'] ?? 'MONTHLY'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
      'isNegotiable': isNegotiable,
      'payPeriod': payPeriod.name,
    };
  }

  String get displayText {
    if (isNegotiable) {
      return '$currency ${min.toStringAsFixed(0)}+ (Negotiable)';
    }
    return '$currency ${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}';
  }

  SalaryRange copyWith({
    double? min,
    double? max,
    String? currency,
    bool? isNegotiable,
    PayPeriod? payPeriod,
  }) {
    return SalaryRange(
      min: min ?? this.min,
      max: max ?? this.max,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      payPeriod: payPeriod ?? this.payPeriod,
    );
  }
}

@immutable
class EducationRequirement {
  final String degree;
  final String? fieldOfStudy;
  final String? minimumGrade;
  final InstitutionType? institutionType;

  const EducationRequirement({
    required this.degree,
    this.fieldOfStudy,
    this.minimumGrade,
    this.institutionType,
  });

  factory EducationRequirement.fromJson(Map<String, dynamic> json) {
    return EducationRequirement(
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      minimumGrade: json['minimumGrade'],
      institutionType: json['institutionType'] != null
          ? InstitutionType.fromString(json['institutionType'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'minimumGrade': minimumGrade,
      'institutionType': institutionType?.name,
    };
  }

  EducationRequirement copyWith({
    String? degree,
    String? fieldOfStudy,
    String? minimumGrade,
    InstitutionType? institutionType,
  }) {
    return EducationRequirement(
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      minimumGrade: minimumGrade ?? this.minimumGrade,
      institutionType: institutionType ?? this.institutionType,
    );
  }
}

@immutable
class ExperienceRequirement {
  final int years;
  final ExperienceLevel level;
  final bool industrySpecific;

  const ExperienceRequirement({
    required this.years,
    required this.level,
    this.industrySpecific = false,
  });

  factory ExperienceRequirement.fromJson(Map<String, dynamic> json) {
    return ExperienceRequirement(
      years: json['years'],
      level: ExperienceLevel.fromString(json['level']),
      industrySpecific: json['industrySpecific'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'level': level.name,
      'industrySpecific': industrySpecific,
    };
  }

  ExperienceRequirement copyWith({
    int? years,
    ExperienceLevel? level,
    bool? industrySpecific,
  }) {
    return ExperienceRequirement(
      years: years ?? this.years,
      level: level ?? this.level,
      industrySpecific: industrySpecific ?? this.industrySpecific,
    );
  }
}

@immutable
class SkillRequirement {
  final String skill;
  final ProficiencyLevel proficiency;
  final bool isRequired;

  const SkillRequirement({
    required this.skill,
    required this.proficiency,
    this.isRequired = true,
  });

  factory SkillRequirement.fromJson(Map<String, dynamic> json) {
    return SkillRequirement(
      skill: json['skill'],
      proficiency: ProficiencyLevel.fromString(json['proficiency']),
      isRequired: json['isRequired'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill': skill,
      'proficiency': proficiency.name,
      'isRequired': isRequired,
    };
  }

  SkillRequirement copyWith({
    String? skill,
    ProficiencyLevel? proficiency,
    bool? isRequired,
  }) {
    return SkillRequirement(
      skill: skill ?? this.skill,
      proficiency: proficiency ?? this.proficiency,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}

@immutable
class RecruitmentStage {
  final int stageNumber;
  final String name;
  final String description;
  final int estimatedDuration; // In days
  final bool isMandatory;

  const RecruitmentStage({
    required this.stageNumber,
    required this.name,
    required this.description,
    required this.estimatedDuration,
    this.isMandatory = true,
  });

  factory RecruitmentStage.fromJson(Map<String, dynamic> json) {
    return RecruitmentStage(
      stageNumber: json['stageNumber'],
      name: json['name'],
      description: json['description'],
      estimatedDuration: json['estimatedDuration'],
      isMandatory: json['isMandatory'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageNumber': stageNumber,
      'name': name,
      'description': description,
      'estimatedDuration': estimatedDuration,
      'isMandatory': isMandatory,
    };
  }

  RecruitmentStage copyWith({
    int? stageNumber,
    String? name,
    String? description,
    int? estimatedDuration,
    bool? isMandatory,
  }) {
    return RecruitmentStage(
      stageNumber: stageNumber ?? this.stageNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      isMandatory: isMandatory ?? this.isMandatory,
    );
  }
}

@immutable
class StipendDetails {
  final double amount;
  final String currency;
  final PaymentFrequency paymentFrequency;
  final bool includesAccommodation;
  final bool includesTransport;
  final bool includesMeals;

  const StipendDetails({
    required this.amount,
    this.currency = 'USD',
    required this.paymentFrequency,
    this.includesAccommodation = false,
    this.includesTransport = false,
    this.includesMeals = false,
  });

  factory StipendDetails.fromJson(Map<String, dynamic> json) {
    return StipendDetails(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentFrequency: PaymentFrequency.fromString(json['paymentFrequency']),
      includesAccommodation: json['includesAccommodation'] ?? false,
      includesTransport: json['includesTransport'] ?? false,
      includesMeals: json['includesMeals'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'paymentFrequency': paymentFrequency.name,
      'includesAccommodation': includesAccommodation,
      'includesTransport': includesTransport,
      'includesMeals': includesMeals,
    };
  }

  StipendDetails copyWith({
    double? amount,
    String? currency,
    PaymentFrequency? paymentFrequency,
    bool? includesAccommodation,
    bool? includesTransport,
    bool? includesMeals,
  }) {
    return StipendDetails(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      includesAccommodation:
          includesAccommodation ?? this.includesAccommodation,
      includesTransport: includesTransport ?? this.includesTransport,
      includesMeals: includesMeals ?? this.includesMeals,
    );
  }
}

// Main Job Model
@immutable
class Job {
  final String id;
  final String jobNumber;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final JobType jobType;
  final PositionType positionType;
  final String department;
  final String location;
  final WorkMode workMode;
  final SalaryRange salaryRange;
  final List<String> benefits;
  final List<String>? additionalCompensation;
  final DateTime applicationDeadline;
  final DateTime startDate;
  final int? duration; // In months
  final bool isRemoteFriendly;
  final bool visaSponsorshipAvailable;
  final List<EducationRequirement> requiredEducation;
  final ExperienceRequirement requiredExperience;
  final List<SkillRequirement> requiredSkills;
  final List<String> preferredQualifications;
  final List<RecruitmentStage> recruitmentStages;
  final String hiringManager;
  final List<String> recruiters;
  final JobStatus status;
  final bool isPublished;
  final DateTime? publishDate;
  final int numberOfOpenings;
  final int numberOfApplications;
  final int views;
  final bool isInternship;
  final bool isAttachment;
  final InternshipType? internshipType;
  final int? attachmentDuration;
  final bool academicCreditAvailable;
  final StipendDetails? stipend;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String postedBy;

  const Job({
    required this.id,
    required this.jobNumber,
    required this.title,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.jobType,
    required this.positionType,
    required this.department,
    required this.location,
    required this.workMode,
    required this.salaryRange,
    required this.benefits,
    this.additionalCompensation,
    required this.applicationDeadline,
    required this.startDate,
    this.duration,
    this.isRemoteFriendly = false,
    this.visaSponsorshipAvailable = false,
    required this.requiredEducation,
    required this.requiredExperience,
    required this.requiredSkills,
    required this.preferredQualifications,
    required this.recruitmentStages,
    required this.hiringManager,
    required this.recruiters,
    required this.status,
    this.isPublished = false,
    this.publishDate,
    required this.numberOfOpenings,
    this.numberOfApplications = 0,
    this.views = 0,
    this.isInternship = false,
    this.isAttachment = false,
    this.internshipType,
    this.attachmentDuration,
    this.academicCreditAvailable = false,
    this.stipend,
    required this.createdAt,
    required this.updatedAt,
    required this.postedBy,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? json['id'] ?? '',
      jobNumber: json['jobNumber'],
      title: json['title'],
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      jobType: JobType.fromString(json['jobType']),
      positionType: PositionType.fromString(json['positionType']),
      department: json['department'] is String
          ? json['department']
          : json['department']?['name'] ?? 'Unknown',
      location: json['location'],
      workMode: WorkMode.fromString(json['workMode']),
      salaryRange: SalaryRange.fromJson(json['salaryRange']),
      benefits: List<String>.from(json['benefits'] ?? []),
      additionalCompensation: json['additionalCompensation'] != null
          ? List<String>.from(json['additionalCompensation'])
          : null,
      applicationDeadline: DateTime.parse(json['applicationDeadline']),
      startDate: DateTime.parse(json['startDate']),
      duration: json['duration'],
      isRemoteFriendly: json['isRemoteFriendly'] ?? false,
      visaSponsorshipAvailable: json['visaSponsorshipAvailable'] ?? false,
      requiredEducation: (json['requiredEducation'] as List?)
              ?.map((e) => EducationRequirement.fromJson(e))
              .toList() ??
          [],
      requiredExperience:
          ExperienceRequirement.fromJson(json['requiredExperience']),
      requiredSkills: (json['requiredSkills'] as List?)
              ?.map((e) => SkillRequirement.fromJson(e))
              .toList() ??
          [],
      preferredQualifications:
          List<String>.from(json['preferredQualifications'] ?? []),
      recruitmentStages: (json['recruitmentStages'] as List?)
              ?.map((e) => RecruitmentStage.fromJson(e))
              .toList() ??
          [],
      hiringManager: json['hiringManager'] is String
          ? json['hiringManager']
          : json['hiringManager']?['personalDetails']?['firstName'] ??
              'Unknown',
      recruiters: json['recruiters'] != null
          ? List<String>.from(json['recruiters'].map((r) => r is String
              ? r
              : r['personalDetails']?['firstName'] ?? 'Unknown'))
          : [],
      status: JobStatus.fromString(json['status']),
      isPublished: json['isPublished'] ?? false,
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'])
          : null,
      numberOfOpenings: json['numberOfOpenings'],
      numberOfApplications: json['numberOfApplications'] ?? 0,
      views: json['views'] ?? 0,
      isInternship: json['isInternship'] ?? false,
      isAttachment: json['isAttachment'] ?? false,
      internshipType: json['internshipType'] != null
          ? InternshipType.fromString(json['internshipType'])
          : null,
      attachmentDuration: json['attachmentDuration'],
      academicCreditAvailable: json['academicCreditAvailable'] ?? false,
      stipend: json['stipend'] != null
          ? StipendDetails.fromJson(json['stipend'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      postedBy: json['postedBy'] is String
          ? json['postedBy']
          : json['postedBy']?['personalDetails']?['firstName'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'jobType': jobType.name,
      'positionType': positionType.name,
      'department': department,
      'location': location,
      'workMode': workMode.name,
      'salaryRange': salaryRange.toJson(),
      'benefits': benefits,
      'additionalCompensation': additionalCompensation,
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'duration': duration,
      'isRemoteFriendly': isRemoteFriendly,
      'visaSponsorshipAvailable': visaSponsorshipAvailable,
      'requiredEducation': requiredEducation.map((e) => e.toJson()).toList(),
      'requiredExperience': requiredExperience.toJson(),
      'requiredSkills': requiredSkills.map((e) => e.toJson()).toList(),
      'preferredQualifications': preferredQualifications,
      'recruitmentStages': recruitmentStages.map((e) => e.toJson()).toList(),
      'hiringManager': hiringManager,
      'recruiters': recruiters,
      'isPublished': isPublished,
      'numberOfOpenings': numberOfOpenings,
      'isInternship': isInternship,
      'isAttachment': isAttachment,
      'internshipType': internshipType?.name,
      'attachmentDuration': attachmentDuration,
      'academicCreditAvailable': academicCreditAvailable,
      'stipend': stipend?.toJson(),
    };
  }

  Job copyWith({
    String? id,
    String? jobNumber,
    String? title,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    JobType? jobType,
    PositionType? positionType,
    String? department,
    String? location,
    WorkMode? workMode,
    SalaryRange? salaryRange,
    List<String>? benefits,
    List<String>? additionalCompensation,
    DateTime? applicationDeadline,
    DateTime? startDate,
    int? duration,
    bool? isRemoteFriendly,
    bool? visaSponsorshipAvailable,
    List<EducationRequirement>? requiredEducation,
    ExperienceRequirement? requiredExperience,
    List<SkillRequirement>? requiredSkills,
    List<String>? preferredQualifications,
    List<RecruitmentStage>? recruitmentStages,
    String? hiringManager,
    List<String>? recruiters,
    JobStatus? status,
    bool? isPublished,
    DateTime? publishDate,
    int? numberOfOpenings,
    int? numberOfApplications,
    int? views,
    bool? isInternship,
    bool? isAttachment,
    InternshipType? internshipType,
    int? attachmentDuration,
    bool? academicCreditAvailable,
    StipendDetails? stipend,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? postedBy,
  }) {
    return Job(
      id: id ?? this.id,
      jobNumber: jobNumber ?? this.jobNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      jobType: jobType ?? this.jobType,
      positionType: positionType ?? this.positionType,
      department: department ?? this.department,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      salaryRange: salaryRange ?? this.salaryRange,
      benefits: benefits ?? this.benefits,
      additionalCompensation:
          additionalCompensation ?? this.additionalCompensation,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      isRemoteFriendly: isRemoteFriendly ?? this.isRemoteFriendly,
      visaSponsorshipAvailable:
          visaSponsorshipAvailable ?? this.visaSponsorshipAvailable,
      requiredEducation: requiredEducation ?? this.requiredEducation,
      requiredExperience: requiredExperience ?? this.requiredExperience,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredQualifications:
          preferredQualifications ?? this.preferredQualifications,
      recruitmentStages: recruitmentStages ?? this.recruitmentStages,
      hiringManager: hiringManager ?? this.hiringManager,
      recruiters: recruiters ?? this.recruiters,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      publishDate: publishDate ?? this.publishDate,
      numberOfOpenings: numberOfOpenings ?? this.numberOfOpenings,
      numberOfApplications: numberOfApplications ?? this.numberOfApplications,
      views: views ?? this.views,
      isInternship: isInternship ?? this.isInternship,
      isAttachment: isAttachment ?? this.isAttachment,
      internshipType: internshipType ?? this.internshipType,
      attachmentDuration: attachmentDuration ?? this.attachmentDuration,
      academicCreditAvailable:
          academicCreditAvailable ?? this.academicCreditAvailable,
      stipend: stipend ?? this.stipend,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postedBy: postedBy ?? this.postedBy,
    );
  }

  // Helper methods
  bool get isActive =>
      status == JobStatus.PUBLISHED &&
      applicationDeadline.isAfter(DateTime.now());

  bool get isExpired => applicationDeadline.isBefore(DateTime.now());

  bool get canApply => isActive && !isExpired;

  String get statusDisplay {
    if (isExpired) return 'Expired';
    return status.displayName;
  }

  Color get statusColor {
    switch (status) {
      case JobStatus.PUBLISHED:
        return isExpired ? Colors.orange : Colors.green;
      case JobStatus.DRAFT:
        return Colors.grey;
      case JobStatus.CLOSED:
        return Colors.red;
      case JobStatus.CANCELLED:
        return Colors.black;
    }
  }
}
