import 'package:flutter/material.dart';

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['screens'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'screens': pages,
  };

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

class CommentReport {
  final String reportedById;
  final String reason;
  final DateTime createdAt;

  const CommentReport({
    required this.reportedById,
    required this.reason,
    required this.createdAt,
  });

  factory CommentReport.fromJson(Map<String, dynamic> json) {
    return CommentReport(
      reportedById: json['reportedBy'] is String
          ? json['reportedBy']
          : json['reportedBy']?['_id'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
    'reportedBy': reportedById,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };
}

enum CommentSentiment {
  positive,
  negative,
  neutral,
}

class NewsComment {
  final String id;
  final String content;
  final String authorId;
  final String newsId;
  final String? parentCommentId;
  final List<String> replies;
  final bool isEdited;
  final bool isApproved;
  final bool isFeatured;
  final DateTime? editedAt;
  final String? editReason;
  final List<String> likes;
  final List<String> dislikes;
  final List<CommentReport> reports;
  final int reportCount;
  final List<String> mentionedUsers;
  final CommentSentiment? sentiment;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Expanded fields (loaded separately)
  final Map<String, dynamic>? author;
  final Map<String, dynamic>? news;
  final List<NewsComment>? replyComments;

  const NewsComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.newsId,
    this.parentCommentId,
    this.replies = const [],
    this.isEdited = false,
    this.isApproved = true,
    this.isFeatured = false,
    this.editedAt,
    this.editReason,
    this.likes = const [],
    this.dislikes = const [],
    this.reports = const [],
    this.reportCount = 0,
    this.mentionedUsers = const [],
    this.sentiment,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.news,
    this.replyComments,
  });

  factory NewsComment.fromJson(Map<String, dynamic> json) {
    List<NewsComment>? parseReplyComments(dynamic repliesJson) {
      if (repliesJson is List) {
        return (repliesJson as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(NewsComment.fromJson)
            .toList();
      }
      return null;
    }

    return NewsComment(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author'] is String
          ? json['author']
          : json['author']?['_id'] ?? '',
      newsId: json['news'] is String ? json['news'] : json['news']?['_id'] ?? '',
      parentCommentId: json['parentComment'] is String
          ? json['parentComment']
          : json['parentComment']?['_id'],
      replies: List<String>.from(json['replies'] ?? []),
      isEdited: json['isEdited'] ?? false,
      isApproved: json['isApproved'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt']).toLocal()
          : null,
      editReason: json['editReason'],
      likes: List<String>.from(json['likes'] ?? []),
      dislikes: List<String>.from(json['dislikes'] ?? []),
      reports: (json['reports'] as List<dynamic>?)
          ?.map(
              (report) => CommentReport.fromJson(report as Map<String, dynamic>))
          .toList() ??
          const [],
      reportCount: json['reportCount'] ?? 0,
      mentionedUsers: List<String>.from(json['mentionedUsers'] ?? []),
      sentiment: _parseSentiment(json['sentiment']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      author: json['author'] is Map<String, dynamic> ? json['author'] : null,
      news: json['news'] is Map<String, dynamic> ? json['news'] : null,
      replyComments: parseReplyComments(json['replies']),
    );
  }

  static CommentSentiment? _parseSentiment(dynamic sentiment) {
    if (sentiment == null) return null;

    final sentimentStr = sentiment.toString().toLowerCase();
    switch (sentimentStr) {
      case 'positive':
        return CommentSentiment.positive;
      case 'negative':
        return CommentSentiment.negative;
      case 'neutral':
        return CommentSentiment.neutral;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'news': newsId,
      'parentComment': parentCommentId,
      'mentionedUsers': mentionedUsers,
    };
  }

  NewsComment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? newsId,
    String? parentCommentId,
    List<String>? replies,
    bool? isEdited,
    bool? isApproved,
    bool? isFeatured,
    DateTime? editedAt,
    String? editReason,
    List<String>? likes,
    List<String>? dislikes,
    List<CommentReport>? reports,
    int? reportCount,
    List<String>? mentionedUsers,
    CommentSentiment? sentiment,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? author,
    Map<String, dynamic>? news,
    List<NewsComment>? replyComments,
  }) {
    return NewsComment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      newsId: newsId ?? this.newsId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      isEdited: isEdited ?? this.isEdited,
      isApproved: isApproved ?? this.isApproved,
      isFeatured: isFeatured ?? this.isFeatured,
      editedAt: editedAt ?? this.editedAt,
      editReason: editReason ?? this.editReason,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      reports: reports ?? this.reports,
      reportCount: reportCount ?? this.reportCount,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      sentiment: sentiment ?? this.sentiment,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      news: news ?? this.news,
      replyComments: replyComments ?? this.replyComments,
    );
  }

  int get netScore => likes.length - dislikes.length;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color get sentimentColor {
    switch (sentiment) {
      case CommentSentiment.positive:
        return Colors.green;
      case CommentSentiment.negative:
        return Colors.red;
      case CommentSentiment.neutral:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String get authorName {
    if (author == null) return 'Unknown';
    final firstName = author!['firstName'] ?? '';
    final lastName = author!['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String? get authorProfilePicture {
    return author?['profilePictureUrl'];
  }
}