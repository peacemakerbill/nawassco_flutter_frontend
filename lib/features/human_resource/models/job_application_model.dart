import 'package:flutter/material.dart';

import 'applicant/applicant_model.dart';
import 'job_model.dart';

// Enums for Job Applications
enum ApplicationSource {
  COMPANY_WEBSITE,
  JOB_BOARD,
  LINKEDIN,
  INDEED,
  GLASSDOOR,
  RECRUITMENT_AGENCY,
  EMPLOYEE_REFERRAL,
  SOCIAL_MEDIA,
  CAMPUS_RECRUITMENT,
  CAREER_FAIR,
  DIRECT_APPLICATION,
  UNIVERSITY_PORTAL,
  INTERNAL_TRANSFER
}

enum ApplicationStatus {
  DRAFT,
  APPLIED,
  UNDER_REVIEW,
  SCREENING,
  SHORTLISTED,
  INTERVIEW_SCHEDULED,
  INTERVIEW_IN_PROGRESS,
  INTERVIEW_COMPLETED,
  TECHNICAL_ASSESSMENT,
  BACKGROUND_CHECK,
  REFERENCE_CHECK,
  SELECTED,
  OFFER_PENDING,
  OFFER_EXTENDED,
  OFFER_ACCEPTED,
  OFFER_DECLINED,
  REJECTED,
  WITHDRAWN,
  ON_HOLD,
  ARCHIVED
}

enum InterviewType {
  PHONE_SCREEN,
  VIDEO_INTERVIEW,
  IN_PERSON,
  PANEL,
  TECHNICAL,
  BEHAVIORAL,
  CASE_STUDY,
  ASSESSMENT_CENTER,
  GROUP_INTERVIEW
}

enum Recommendation { STRONG_HIRE, HIRE, NO_HIRE, STRONG_NO_HIRE }

enum ReviewDecision { PROCEED, REJECT, HOLD, FAST_TRACK, NEEDS_MORE_INFO }

enum StageStatus { NOT_STARTED, IN_PROGRESS, COMPLETED, SKIPPED, FAILED }

enum CommunicationType {
  EMAIL,
  PHONE_CALL,
  IN_APP_MESSAGE,
  INTERVIEW_INVITATION,
  OFFER_LETTER,
  STATUS_UPDATE,
  FEEDBACK_REQUEST
}

enum CommunicationStatus { SENT, DELIVERED, READ, FAILED, DRAFT }

// Supporting Models
@immutable
class ApplicantDetails {
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? location;
  final String? address;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? profilePictureUrl;
  final String? currentPosition;
  final String? currentEmployer;
  final double? yearsOfExperience;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? nationality;

  const ApplicantDetails({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.location,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.profilePictureUrl,
    this.currentPosition,
    this.currentEmployer,
    this.yearsOfExperience,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.nationality,
  });

  factory ApplicantDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantDetails(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      location: json['location'],
      address: json['address'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      profilePictureUrl: json['profilePictureUrl'],
      currentPosition: json['currentPosition'],
      currentEmployer: json['currentEmployer'],
      yearsOfExperience: json['yearsOfExperience']?.toDouble(),
      linkedinUrl: json['linkedinUrl'],
      githubUrl: json['githubUrl'],
      portfolioUrl: json['portfolioUrl'],
      nationality: json['nationality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'address': address,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'currentPosition': currentPosition,
      'currentEmployer': currentEmployer,
      'yearsOfExperience': yearsOfExperience,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'portfolioUrl': portfolioUrl,
      'nationality': nationality,
    };
  }
}

@immutable
class ApplicationDocument {
  final String name;
  final String type;
  final String url;
  final DateTime uploadDate;
  final int fileSize;
  final String? description;
  final bool isPrimary;

  const ApplicationDocument({
    required this.name,
    required this.type,
    required this.url,
    required this.uploadDate,
    required this.fileSize,
    this.description,
    this.isPrimary = false,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      name: json['name'],
      type: json['type'],
      url: json['url'],
      uploadDate: DateTime.parse(json['uploadDate']),
      fileSize: json['fileSize'],
      description: json['description'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'uploadDate': uploadDate.toIso8601String(),
      'fileSize': fileSize,
      'description': description,
      'isPrimary': isPrimary,
    };
  }
}

@immutable
class ExpectedSalary {
  final double min;
  final double max;
  final String currency;
  final bool isNegotiable;
  final String payPeriod;

  const ExpectedSalary({
    required this.min,
    required this.max,
    this.currency = 'USD',
    this.isNegotiable = false,
    required this.payPeriod,
  });

  factory ExpectedSalary.fromJson(Map<String, dynamic> json) {
    return ExpectedSalary(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      isNegotiable: json['isNegotiable'] ?? false,
      payPeriod: json['payPeriod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
      'isNegotiable': isNegotiable,
      'payPeriod': payPeriod,
    };
  }
}

@immutable
class ReviewHistory {
  final String reviewedBy;
  final DateTime reviewDate;
  final int stage;
  final String comments;
  final double rating;
  final ApplicationStatus status;
  final ReviewDecision decision;
  final String? nextSteps;
  final String? internalNotes;

  const ReviewHistory({
    required this.reviewedBy,
    required this.reviewDate,
    required this.stage,
    required this.comments,
    required this.rating,
    required this.status,
    required this.decision,
    this.nextSteps,
    this.internalNotes,
  });

  factory ReviewHistory.fromJson(Map<String, dynamic> json) {
    return ReviewHistory(
      reviewedBy: json['reviewedBy'],
      reviewDate: DateTime.parse(json['reviewDate']),
      stage: json['stage'],
      comments: json['comments'],
      rating: (json['rating'] as num).toDouble(),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'].toUpperCase(),
        orElse: () => ApplicationStatus.DRAFT,
      ),
      decision: ReviewDecision.values.firstWhere(
        (e) => e.name == json['decision'].toUpperCase(),
        orElse: () => ReviewDecision.HOLD,
      ),
      nextSteps: json['nextSteps'],
      internalNotes: json['internalNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewedBy': reviewedBy,
      'reviewDate': reviewDate.toIso8601String(),
      'stage': stage,
      'comments': comments,
      'rating': rating,
      'status': status.name.toLowerCase(),
      'decision': decision.name.toLowerCase(),
      'nextSteps': nextSteps,
      'internalNotes': internalNotes,
    };
  }
}

@immutable
class InterviewDetails {
  final DateTime interviewDate;
  final List<String> interviewers;
  final InterviewType interviewType;
  final int stage;
  final double overallScore;
  final double? technicalScore;
  final double? communicationScore;
  final double? culturalFitScore;
  final double? problemSolvingScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final Recommendation recommendation;
  final String comments;
  final bool feedbackProvidedToCandidate;
  final String? candidateFeedback;

  const InterviewDetails({
    required this.interviewDate,
    required this.interviewers,
    required this.interviewType,
    required this.stage,
    required this.overallScore,
    this.technicalScore,
    this.communicationScore,
    this.culturalFitScore,
    this.problemSolvingScore,
    this.strengths = const [],
    this.weaknesses = const [],
    required this.recommendation,
    required this.comments,
    this.feedbackProvidedToCandidate = false,
    this.candidateFeedback,
  });

  factory InterviewDetails.fromJson(Map<String, dynamic> json) {
    return InterviewDetails(
      interviewDate: DateTime.parse(json['interviewDate']),
      interviewers: List<String>.from(json['interviewers']),
      interviewType: InterviewType.values.firstWhere(
        (e) => e.name == json['interviewType'].toUpperCase(),
        orElse: () => InterviewType.IN_PERSON,
      ),
      stage: json['stage'],
      overallScore: (json['overallScore'] as num).toDouble(),
      technicalScore: json['technicalScore']?.toDouble(),
      communicationScore: json['communicationScore']?.toDouble(),
      culturalFitScore: json['culturalFitScore']?.toDouble(),
      problemSolvingScore: json['problemSolvingScore']?.toDouble(),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendation: Recommendation.values.firstWhere(
        (e) => e.name == json['recommendation'].toUpperCase(),
        orElse: () => Recommendation.HIRE,
      ),
      comments: json['comments'],
      feedbackProvidedToCandidate: json['feedbackProvidedToCandidate'] ?? false,
      candidateFeedback: json['candidateFeedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interviewDate': interviewDate.toIso8601String(),
      'interviewers': interviewers,
      'interviewType': interviewType.name.toLowerCase(),
      'stage': stage,
      'overallScore': overallScore,
      'technicalScore': technicalScore,
      'communicationScore': communicationScore,
      'culturalFitScore': culturalFitScore,
      'problemSolvingScore': problemSolvingScore,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendation': recommendation.name.toLowerCase(),
      'comments': comments,
      'feedbackProvidedToCandidate': feedbackProvidedToCandidate,
      'candidateFeedback': candidateFeedback,
    };
  }
}

@immutable
class ApplicationStageHistory {
  final int stageNumber;
  final String stageName;
  final DateTime enteredDate;
  final DateTime? completedDate;
  final StageStatus status;
  final int? duration;

  const ApplicationStageHistory({
    required this.stageNumber,
    required this.stageName,
    required this.enteredDate,
    this.completedDate,
    this.status = StageStatus.NOT_STARTED,
    this.duration,
  });

  factory ApplicationStageHistory.fromJson(Map<String, dynamic> json) {
    return ApplicationStageHistory(
      stageNumber: json['stageNumber'],
      stageName: json['stageName'],
      enteredDate: DateTime.parse(json['enteredDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      status: StageStatus.values.firstWhere(
        (e) => e.name == json['status'].toUpperCase(),
        orElse: () => StageStatus.NOT_STARTED,
      ),
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageNumber': stageNumber,
      'stageName': stageName,
      'enteredDate': enteredDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status.name.toLowerCase(),
      'duration': duration,
    };
  }
}

@immutable
class CommunicationEntry {
  final CommunicationType type;
  final DateTime date;
  final String initiatedBy;
  final String recipient;
  final String? subject;
  final String content;
  final List<String> attachments;
  final CommunicationStatus status;

  const CommunicationEntry({
    required this.type,
    required this.date,
    required this.initiatedBy,
    required this.recipient,
    this.subject,
    required this.content,
    this.attachments = const [],
    this.status = CommunicationStatus.SENT,
  });

  factory CommunicationEntry.fromJson(Map<String, dynamic> json) {
    return CommunicationEntry(
      type: CommunicationType.values.firstWhere(
        (e) => e.name == json['type'].toUpperCase(),
        orElse: () => CommunicationType.EMAIL,
      ),
      date: DateTime.parse(json['date']),
      initiatedBy: json['initiatedBy'],
      recipient: json['recipient'],
      subject: json['subject'],
      content: json['content'],
      attachments: List<String>.from(json['attachments'] ?? []),
      status: CommunicationStatus.values.firstWhere(
        (e) => e.name == json['status'].toUpperCase(),
        orElse: () => CommunicationStatus.SENT,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name.toLowerCase(),
      'date': date.toIso8601String(),
      'initiatedBy': initiatedBy,
      'recipient': recipient,
      'subject': subject,
      'content': content,
      'attachments': attachments,
      'status': status.name.toLowerCase(),
    };
  }
}

// Main Job Application Model
@immutable
class JobApplication {
  final String id;
  final String applicationNumber;
  final String jobId;
  final String userId;
  final ApplicantDetails applicant;
  final DateTime applicationDate;
  final ApplicationSource applicationSource;
  final String? customCoverLetter;
  final String? customMessage;
  final List<ApplicationDocument> selectedDocuments;
  final ApplicationStatus status;
  final List<ReviewHistory> reviewHistory;
  final InterviewDetails? interviewDetails;
  final double? assessmentScore;
  final double? technicalScore;
  final double? behavioralScore;
  final double? culturalFitScore;
  final double overallRating;
  final int currentStage;
  final List<ApplicationStageHistory> stageHistory;
  final bool isFastTracked;
  final bool isWithdrawn;
  final String? withdrawnReason;
  final DateTime? withdrawnAt;
  final String? referredBy;
  final String? referralComment;
  final List<CommunicationEntry> communicationHistory;
  final DateTime? lastContactDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime lastActivityDate;
  final List<String> viewedByRecruiters;
  final int viewedCount;
  final int timeInStatus;
  final int timeToSubmit;

  // Additional job info (populated from Job model)
  final Job? jobDetails;

  // Additional applicant info (populated from Applicant model)
  final ApplicantModel? applicantDetails;

  const JobApplication({
    required this.id,
    required this.applicationNumber,
    required this.jobId,
    required this.userId,
    required this.applicant,
    required this.applicationDate,
    required this.applicationSource,
    this.customCoverLetter,
    this.customMessage,
    this.selectedDocuments = const [],
    required this.status,
    this.reviewHistory = const [],
    this.interviewDetails,
    this.assessmentScore,
    this.technicalScore,
    this.behavioralScore,
    this.culturalFitScore,
    this.overallRating = 0.0,
    this.currentStage = 1,
    this.stageHistory = const [],
    this.isFastTracked = false,
    this.isWithdrawn = false,
    this.withdrawnReason,
    this.withdrawnAt,
    this.referredBy,
    this.referralComment,
    this.communicationHistory = const [],
    this.lastContactDate,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    required this.lastActivityDate,
    this.viewedByRecruiters = const [],
    this.viewedCount = 0,
    this.timeInStatus = 0,
    this.timeToSubmit = 0,
    this.jobDetails,
    this.applicantDetails,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['_id'] ?? json['id'] ?? '',
      applicationNumber: json['applicationNumber'],
      jobId: json['job'] is String ? json['job'] : json['job']?['_id'],
      userId: json['user'] is String ? json['user'] : json['user']?['_id'],
      applicant: ApplicantDetails.fromJson(json['applicant']),
      applicationDate: DateTime.parse(json['applicationDate']),
      applicationSource: ApplicationSource.values.firstWhere(
        (e) => e.name == json['applicationSource'].toUpperCase(),
        orElse: () => ApplicationSource.COMPANY_WEBSITE,
      ),
      customCoverLetter: json['customCoverLetter'],
      customMessage: json['customMessage'],
      selectedDocuments: (json['selectedDocuments'] as List?)
              ?.map((doc) => ApplicationDocument.fromJson(doc))
              .toList() ??
          [],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'].toUpperCase(),
        orElse: () => ApplicationStatus.DRAFT,
      ),
      reviewHistory: (json['reviewHistory'] as List?)
              ?.map((review) => ReviewHistory.fromJson(review))
              .toList() ??
          [],
      interviewDetails: json['interviewDetails'] != null
          ? InterviewDetails.fromJson(json['interviewDetails'])
          : null,
      assessmentScore: json['assessmentScore']?.toDouble(),
      technicalScore: json['technicalScore']?.toDouble(),
      behavioralScore: json['behavioralScore']?.toDouble(),
      culturalFitScore: json['culturalFitScore']?.toDouble(),
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      currentStage: json['currentStage'] ?? 1,
      stageHistory: (json['stageHistory'] as List?)
              ?.map((stage) => ApplicationStageHistory.fromJson(stage))
              .toList() ??
          [],
      isFastTracked: json['isFastTracked'] ?? false,
      isWithdrawn: json['isWithdrawn'] ?? false,
      withdrawnReason: json['withdrawnReason'],
      withdrawnAt: json['withdrawnAt'] != null
          ? DateTime.parse(json['withdrawnAt'])
          : null,
      referredBy: json['referredBy'],
      referralComment: json['referralComment'],
      communicationHistory: (json['communicationHistory'] as List?)
              ?.map((comm) => CommunicationEntry.fromJson(comm))
              .toList() ??
          [],
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      lastActivityDate: DateTime.parse(json['lastActivityDate']),
      viewedByRecruiters: List<String>.from(json['viewedByRecruiters'] ?? []),
      viewedCount: json['viewedCount'] ?? 0,
      timeInStatus: json['timeInStatus'] ?? 0,
      timeToSubmit: json['timeToSubmit'] ?? 0,
      jobDetails: json['job'] is Map ? Job.fromJson(json['job']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job': jobId,
      'customCoverLetter': customCoverLetter,
      'customMessage': customMessage,
      'selectedDocuments':
          selectedDocuments.map((doc) => doc.toJson()).toList(),
      'applicationSource': applicationSource.name.toLowerCase(),
    };
  }

  JobApplication copyWith({
    String? id,
    String? applicationNumber,
    String? jobId,
    String? userId,
    ApplicantDetails? applicant,
    DateTime? applicationDate,
    ApplicationSource? applicationSource,
    String? customCoverLetter,
    String? customMessage,
    List<ApplicationDocument>? selectedDocuments,
    ApplicationStatus? status,
    List<ReviewHistory>? reviewHistory,
    InterviewDetails? interviewDetails,
    double? assessmentScore,
    double? technicalScore,
    double? behavioralScore,
    double? culturalFitScore,
    double? overallRating,
    int? currentStage,
    List<ApplicationStageHistory>? stageHistory,
    bool? isFastTracked,
    bool? isWithdrawn,
    String? withdrawnReason,
    DateTime? withdrawnAt,
    String? referredBy,
    String? referralComment,
    List<CommunicationEntry>? communicationHistory,
    DateTime? lastContactDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? lastActivityDate,
    List<String>? viewedByRecruiters,
    int? viewedCount,
    int? timeInStatus,
    int? timeToSubmit,
    Job? jobDetails,
    ApplicantModel? applicantDetails,
  }) {
    return JobApplication(
      id: id ?? this.id,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      applicant: applicant ?? this.applicant,
      applicationDate: applicationDate ?? this.applicationDate,
      applicationSource: applicationSource ?? this.applicationSource,
      customCoverLetter: customCoverLetter ?? this.customCoverLetter,
      customMessage: customMessage ?? this.customMessage,
      selectedDocuments: selectedDocuments ?? this.selectedDocuments,
      status: status ?? this.status,
      reviewHistory: reviewHistory ?? this.reviewHistory,
      interviewDetails: interviewDetails ?? this.interviewDetails,
      assessmentScore: assessmentScore ?? this.assessmentScore,
      technicalScore: technicalScore ?? this.technicalScore,
      behavioralScore: behavioralScore ?? this.behavioralScore,
      culturalFitScore: culturalFitScore ?? this.culturalFitScore,
      overallRating: overallRating ?? this.overallRating,
      currentStage: currentStage ?? this.currentStage,
      stageHistory: stageHistory ?? this.stageHistory,
      isFastTracked: isFastTracked ?? this.isFastTracked,
      isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      withdrawnReason: withdrawnReason ?? this.withdrawnReason,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      referredBy: referredBy ?? this.referredBy,
      referralComment: referralComment ?? this.referralComment,
      communicationHistory: communicationHistory ?? this.communicationHistory,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      viewedByRecruiters: viewedByRecruiters ?? this.viewedByRecruiters,
      viewedCount: viewedCount ?? this.viewedCount,
      timeInStatus: timeInStatus ?? this.timeInStatus,
      timeToSubmit: timeToSubmit ?? this.timeToSubmit,
      jobDetails: jobDetails ?? this.jobDetails,
      applicantDetails: applicantDetails ?? this.applicantDetails,
    );
  }

  // Helper methods
  bool get isActive => !isWithdrawn && status != ApplicationStatus.REJECTED;

  bool get canWithdraw =>
      !isWithdrawn &&
      status.index <= ApplicationStatus.INTERVIEW_COMPLETED.index;

  bool get hasInterviewScheduled =>
      status == ApplicationStatus.INTERVIEW_SCHEDULED ||
      status == ApplicationStatus.INTERVIEW_IN_PROGRESS;

  bool get isSelected => status == ApplicationStatus.SELECTED;

  bool get isHired => status == ApplicationStatus.OFFER_ACCEPTED;

  String get statusDisplay {
    final statusName = status.name.toLowerCase();
    return statusName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.APPLIED:
      case ApplicationStatus.UNDER_REVIEW:
      case ApplicationStatus.SCREENING:
        return Colors.blue;
      case ApplicationStatus.SHORTLISTED:
      case ApplicationStatus.INTERVIEW_SCHEDULED:
      case ApplicationStatus.INTERVIEW_IN_PROGRESS:
        return Colors.orange;
      case ApplicationStatus.INTERVIEW_COMPLETED:
      case ApplicationStatus.TECHNICAL_ASSESSMENT:
      case ApplicationStatus.BACKGROUND_CHECK:
      case ApplicationStatus.REFERENCE_CHECK:
        return Colors.purple;
      case ApplicationStatus.SELECTED:
      case ApplicationStatus.OFFER_PENDING:
      case ApplicationStatus.OFFER_EXTENDED:
        return Colors.green;
      case ApplicationStatus.OFFER_ACCEPTED:
        return Colors.green.shade800;
      case ApplicationStatus.OFFER_DECLINED:
        return Colors.red;
      case ApplicationStatus.REJECTED:
        return Colors.red.shade800;
      case ApplicationStatus.WITHDRAWN:
        return Colors.grey;
      case ApplicationStatus.ON_HOLD:
        return Colors.amber;
      case ApplicationStatus.ARCHIVED:
        return Colors.grey.shade600;
      case ApplicationStatus.DRAFT:
        return Colors.grey.shade400;
    }
  }

  String get timeInCurrentStatus {
    if (timeInStatus < 1) return 'Today';
    if (timeInStatus == 1) return '1 day ago';
    return '$timeInStatus days ago';
  }

  double get progressPercentage {
    const totalStages = 15; // Total possible stages in hiring process
    final currentStageIndex = currentStage.clamp(1, totalStages);
    return (currentStageIndex / totalStages) * 100;
  }
}
