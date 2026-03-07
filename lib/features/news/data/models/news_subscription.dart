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

enum NewsSubscriptionType {
  category,
  author,
  breakingNews,
  all,
}

enum DigestFrequency {
  realtime,
  daily,
  weekly,
}

class NotificationPreferences {
  final bool onPublish;
  final bool onBreakingNews;
  final bool onAuthorPost;
  final DigestFrequency digestFrequency;

  const NotificationPreferences({
    this.onPublish = true,
    this.onBreakingNews = true,
    this.onAuthorPost = true,
    this.digestFrequency = DigestFrequency.realtime,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      onPublish: json['onPublish'] ?? true,
      onBreakingNews: json['onBreakingNews'] ?? true,
      onAuthorPost: json['onAuthorPost'] ?? true,
      digestFrequency: _parseDigestFrequency(json['digestFrequency']),
    );
  }

  static DigestFrequency _parseDigestFrequency(String? frequency) {
    switch (frequency) {
      case 'realtime':
        return DigestFrequency.realtime;
      case 'daily':
        return DigestFrequency.daily;
      case 'weekly':
        return DigestFrequency.weekly;
      default:
        return DigestFrequency.realtime;
    }
  }

  Map<String, dynamic> toJson() => {
    'onPublish': onPublish,
    'onBreakingNews': onBreakingNews,
    'onAuthorPost': onAuthorPost,
    'digestFrequency': digestFrequency.name,
  };

  String get digestFrequencyLabel {
    switch (digestFrequency) {
      case DigestFrequency.realtime:
        return 'Realtime';
      case DigestFrequency.daily:
        return 'Daily';
      case DigestFrequency.weekly:
        return 'Weekly';
    }
  }
}

class NewsSubscription {
  final String id;
  final String userId;
  final NewsSubscriptionType type;
  final String? categoryId;
  final String? authorId;
  final NotificationPreferences notificationPreferences;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Expanded fields
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? author;

  const NewsSubscription({
    required this.id,
    required this.userId,
    required this.type,
    this.categoryId,
    this.authorId,
    required this.notificationPreferences,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.author,
  });

  factory NewsSubscription.fromJson(Map<String, dynamic> json) {
    return NewsSubscription(
      id: json['_id'] ?? json['id'],
      userId:
      json['user'] is String ? json['user'] : json['user']?['_id'] ?? '',
      type: _parseSubscriptionType(json['type']),
      categoryId: json['category'] is String
          ? json['category']
          : json['category']?['_id'],
      authorId:
      json['author'] is String ? json['author'] : json['author']?['_id'],
      notificationPreferences: NotificationPreferences.fromJson(
          json['notificationPreferences'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      category: json['category'] is Map ? json['category'] : null,
      author: json['author'] is Map ? json['author'] : null,
    );
  }

  static NewsSubscriptionType _parseSubscriptionType(String type) {
    switch (type) {
      case 'category':
        return NewsSubscriptionType.category;
      case 'author':
        return NewsSubscriptionType.author;
      case 'breaking_news':
        return NewsSubscriptionType.breakingNews;
      case 'all':
        return NewsSubscriptionType.all;
      default:
        return NewsSubscriptionType.all;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(type),
      'category': categoryId,
      'author': authorId,
      'notificationPreferences': notificationPreferences.toJson(),
      'isActive': isActive,
    };
  }

  String _typeToString(NewsSubscriptionType type) {
    switch (type) {
      case NewsSubscriptionType.category:
        return 'category';
      case NewsSubscriptionType.author:
        return 'author';
      case NewsSubscriptionType.breakingNews:
        return 'breaking_news';
      case NewsSubscriptionType.all:
        return 'all';
    }
  }

  NewsSubscription copyWith({
    String? id,
    String? userId,
    NewsSubscriptionType? type,
    String? categoryId,
    String? authorId,
    NotificationPreferences? notificationPreferences,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? category,
    Map<String, dynamic>? author,
  }) {
    return NewsSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      authorId: authorId ?? this.authorId,
      notificationPreferences:
      notificationPreferences ?? this.notificationPreferences,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      author: author ?? this.author,
    );
  }

  String get typeLabel {
    switch (type) {
      case NewsSubscriptionType.category:
        return 'Category';
      case NewsSubscriptionType.author:
        return 'Author';
      case NewsSubscriptionType.breakingNews:
        return 'Breaking News';
      case NewsSubscriptionType.all:
        return 'All News';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NewsSubscriptionType.category:
        return Icons.category;
      case NewsSubscriptionType.author:
        return Icons.person;
      case NewsSubscriptionType.breakingNews:
        return Icons.notification_important;
      case NewsSubscriptionType.all:
        return Icons.newspaper;
    }
  }

  String? get categoryName => category?['name'];

  String? get authorName {
    if (author == null) return null;
    final firstName = author!['firstName'] ?? '';
    final lastName = author!['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }
}