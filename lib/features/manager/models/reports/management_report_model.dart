import 'package:flutter/material.dart';

enum ReportStatus {
  draft('Draft', Colors.grey, Icons.drafts),
  underReview('Under Review', Colors.orange, Icons.reviews),
  approved('Approved', Colors.green, Icons.verified),
  published('Published', Colors.blue, Icons.public);

  final String displayName;
  final Color color;
  final IconData icon;

  const ReportStatus(this.displayName, this.color, this.icon);
}

enum ReportType {
  financial('Financial', Icons.attach_money),
  operational('Operational', Icons.settings),
  strategic('Strategic', Icons.flag),
  compliance('Compliance', Icons.gavel),
  risk('Risk Assessment', Icons.warning),
  performance('Performance', Icons.trending_up);

  final String displayName;
  final IconData icon;

  const ReportType(this.displayName, this.icon);
}

enum ReportFrequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  annually('Annually');

  final String displayName;

  const ReportFrequency(this.displayName);
}

enum ConfidentialityLevel {
  public('Public', Colors.green),
  internal('Internal', Colors.blue),
  confidential('Confidential', Colors.orange),
  restricted('Restricted', Colors.red);

  final String displayName;
  final Color color;

  const ConfidentialityLevel(this.displayName, this.color);
}

class ReportSection {
  final String title;
  final String content;
  final List<String>? attachments;

  ReportSection({
    required this.title,
    required this.content,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'attachments': attachments,
    };
  }

  factory ReportSection.fromJson(Map<String, dynamic> json) {
    return ReportSection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  ReportSection copyWith({
    String? title,
    String? content,
    List<String>? attachments,
  }) {
    return ReportSection(
      title: title ?? this.title,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ReportDistribution {
  final String userId;
  final String name;
  final String email;
  final String? jobTitle;

  ReportDistribution({
    required this.userId,
    required this.name,
    required this.email,
    this.jobTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'jobTitle': jobTitle,
    };
  }

  factory ReportDistribution.fromJson(Map<String, dynamic> json) {
    return ReportDistribution(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jobTitle: json['jobTitle'],
    );
  }
}

class ManagementReport {
  final String id;
  final String title;
  final ReportType type;
  final ReportStatus status;
  final ReportFrequency frequency;
  final ConfidentialityLevel confidentiality;
  final String? executiveSummary;
  final List<ReportSection> sections;
  final String preparedById;
  final String? preparedByName;
  final String? preparedByTitle;
  final String? reviewedById;
  final String? reviewedByName;
  final String? approvedById;
  final String? approvedByName;
  final List<ReportDistribution> distributionList;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? approvalDate;
  final DateTime? reviewDeadline;
  final List<dynamic> feedback; // Using dynamic for now
  final List<dynamic> actionItems; // Using dynamic for now
  final List<String> attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManagementReport({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.frequency,
    required this.confidentiality,
    this.executiveSummary,
    required this.sections,
    required this.preparedById,
    this.preparedByName,
    this.preparedByTitle,
    this.reviewedById,
    this.reviewedByName,
    this.approvedById,
    this.approvedByName,
    required this.distributionList,
    required this.startDate,
    this.endDate,
    this.approvalDate,
    this.reviewDeadline,
    required this.feedback,
    required this.actionItems,
    required this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEditable => status == ReportStatus.draft;
  bool get isUnderReview => status == ReportStatus.underReview;
  bool get isApproved => status == ReportStatus.approved;
  bool get isPublished => status == ReportStatus.published;

  String get formattedStartDate => _formatDate(startDate);
  String get formattedEndDate => endDate != null ? _formatDate(endDate!) : 'Ongoing';
  String get formattedApprovalDate => approvalDate != null ? _formatDate(approvalDate!) : 'Not approved';
  String get formattedCreatedAt => _formatDateTime(createdAt);

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'status': status.name,
      'frequency': frequency.name,
      'confidentiality': confidentiality.name,
      'executiveSummary': executiveSummary,
      'sections': sections.map((s) => s.toJson()).toList(),
      'preparedById': preparedById,
      'preparedByName': preparedByName,
      'preparedByTitle': preparedByTitle,
      'reviewedById': reviewedById,
      'reviewedByName': reviewedByName,
      'approvedById': approvedById,
      'approvedByName': approvedByName,
      'distributionList': distributionList.map((d) => d.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'reviewDeadline': reviewDeadline?.toIso8601String(),
      'feedback': feedback,
      'actionItems': actionItems,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ManagementReport.fromJson(Map<String, dynamic> json) {
    return ManagementReport(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      type: ReportType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => ReportType.operational,
      ),
      status: ReportStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ReportStatus.draft,
      ),
      frequency: ReportFrequency.values.firstWhere(
            (e) => e.name == json['frequency'],
        orElse: () => ReportFrequency.monthly,
      ),
      confidentiality: ConfidentialityLevel.values.firstWhere(
            (e) => e.name == json['confidentiality'],
        orElse: () => ConfidentialityLevel.internal,
      ),
      executiveSummary: json['executiveSummary'],
      sections: json['sections'] != null
          ? (json['sections'] as List)
          .map((s) => ReportSection.fromJson(s))
          .toList()
          : [],
      preparedById: json['preparedBy']?['_id'] ?? json['preparedById'] ?? '',
      preparedByName: json['preparedBy']?['firstName'] != null
          ? '${json['preparedBy']['firstName']} ${json['preparedBy']['lastName']}'
          : json['preparedByName'],
      preparedByTitle: json['preparedBy']?['jobInformation']?['jobTitle'] ??
          json['preparedByTitle'],
      reviewedById: json['reviewedBy']?['_id'] ?? json['reviewedById'],
      reviewedByName: json['reviewedBy']?['firstName'] != null
          ? '${json['reviewedBy']['firstName']} ${json['reviewedBy']['lastName']}'
          : json['reviewedByName'],
      approvedById: json['approvedBy']?['_id'] ?? json['approvedById'],
      approvedByName: json['approvedBy']?['firstName'] != null
          ? '${json['approvedBy']['firstName']} ${json['approvedBy']['lastName']}'
          : json['approvedByName'],
      distributionList: json['distributionList'] != null
          ? (json['distributionList'] as List)
          .map((d) => ReportDistribution.fromJson(d))
          .toList()
          : [],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      reviewDeadline: json['reviewDeadline'] != null
          ? DateTime.parse(json['reviewDeadline'])
          : null,
      feedback: json['feedback'] ?? [],
      actionItems: json['actionItems'] ?? [],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}