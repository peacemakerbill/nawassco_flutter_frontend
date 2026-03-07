import '../../utils/date_utils.dart' as date_util;

class ReportFeedback {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerTitle;
  final String comment;
  final DateTime date;
  final bool actionRequired;

  ReportFeedback({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerTitle,
    required this.comment,
    required this.date,
    required this.actionRequired,
  });

  String get formattedDate => date_util.DateUtils.formatDateTime(date);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerTitle': reviewerTitle,
      'comment': comment,
      'date': date.toIso8601String(),
      'actionRequired': actionRequired,
    };
  }

  factory ReportFeedback.fromJson(Map<String, dynamic> json) {
    return ReportFeedback(
      id: json['_id'] ?? json['id'] ?? '',
      reviewerId: json['reviewer']?['_id'] ?? json['reviewerId'] ?? '',
      reviewerName: json['reviewer']?['firstName'] != null
          ? '${json['reviewer']['firstName']} ${json['reviewer']['lastName']}'
          : json['reviewerName'] ?? '',
      reviewerTitle: json['reviewer']?['jobInformation']?['jobTitle'] ??
          json['reviewerTitle'],
      comment: json['comment'] ?? '',
      date: DateTime.parse(json['date']),
      actionRequired: json['actionRequired'] ?? false,
    );
  }
}
