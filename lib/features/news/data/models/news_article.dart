import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NewsStatus {
  draft,
  pendingReview,
  published,
  scheduled,
  archived,
  rejected,
}

enum NewsPriority {
  low,
  medium,
  high,
  urgent,
}

class NewsAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String? username;
  final String? profilePictureUrl;

  const NewsAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.username,
    this.profilePictureUrl,
  });

  factory NewsAuthor.fromJson(Map<String, dynamic> json) {
    return NewsAuthor(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
    'profilePictureUrl': profilePictureUrl,
  };

  String get fullName => '$firstName $lastName';
}

class NewsCategory {
  final String id;
  final String name;
  final String description;
  final String slug;
  final String color;
  final String icon;
  final bool isActive;
  final bool isFeatured;
  final int order;
  final String? parentCategoryId;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    this.color = '#007bff',
    this.icon = 'newspaper',
    this.isActive = true,
    this.isFeatured = false,
    this.order = 0,
    this.parentCategoryId,
  });

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slug: json['slug'] ?? '',
      color: json['color'] ?? '#007bff',
      icon: json['icon'] ?? 'newspaper',
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      order: json['order'] ?? 0,
      parentCategoryId: json['parentCategory'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'slug': slug,
    'color': color,
    'icon': icon,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'order': order,
    'parentCategoryId': parentCategoryId,
  };

  // Add these getters
  Color get categoryColor {
    return _parseColor(color);
  }

  IconData get categoryIcon {
    return _parseIcon(icon);
  }

  // Helper methods
  static Color _parseColor(String colorString) {
    try {
      // Handle hex color with or without #
      String hex = colorString.startsWith('#') ? colorString : '#$colorString';

      // Ensure the hex string is valid
      hex = hex.replaceAll('#', '');
      if (hex.length == 3) {
        hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
      }
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha value
      }

      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      print('Error parsing color $colorString: $e');
      return Colors.blue; // Default color
    }
  }

  static IconData _parseIcon(String iconName) {
    // Map common icon names to Flutter Icons
    switch (iconName.toLowerCase()) {
      case 'business':
        return Icons.business;
      case 'sports':
        return Icons.sports;
      case 'technology':
        return Icons.computer;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'science':
        return Icons.science;
      case 'politics':
        return Icons.gavel;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'food':
        return Icons.restaurant;
      case 'lifestyle':
        return Icons.spa;
      case 'finance':
        return Icons.attach_money;
      case 'weather':
        return Icons.cloud;
      case 'automotive':
        return Icons.directions_car;
      case 'realestate':
        return Icons.home;
      case 'fashion':
        return Icons.checkroom;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'gaming':
        return Icons.videogame_asset;
      case 'newspaper':
      default:
        return Icons.newspaper;
    }
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String? excerpt;
  final NewsAuthor author;
  final NewsCategory category;
  final List<String> tags;
  final String? featuredImage;
  final List<String> imageGallery;
  final String? videoUrl;
  final String? audioUrl;
  final List<String> attachedFiles;
  final NewsStatus status;
  final NewsPriority priority;
  final bool isFeatured;
  final bool isBreaking;
  final bool isSponsored;
  final bool isExclusive;
  final DateTime? publishedAt;
  final DateTime? scheduledFor;
  final DateTime? expiresAt;
  final int views;
  final int uniqueViews;
  final List<String> likes;
  final List<String> bookmarks;
  final int shares;
  final int commentsCount;
  final String? seoTitle;
  final String? seoDescription;
  final List<String> metaKeywords;
  final String? canonicalUrl;
  final List<String> relatedNews;
  final String? source;
  final String? sourceUrl;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final List<NewsAuthor> coAuthors;
  final String? editor;
  final int readingTime;
  final double engagementRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    this.excerpt,
    required this.author,
    required this.category,
    this.tags = const [],
    this.featuredImage,
    this.imageGallery = const [],
    this.videoUrl,
    this.audioUrl,
    this.attachedFiles = const [],
    this.status = NewsStatus.draft,
    this.priority = NewsPriority.medium,
    this.isFeatured = false,
    this.isBreaking = false,
    this.isSponsored = false,
    this.isExclusive = false,
    this.publishedAt,
    this.scheduledFor,
    this.expiresAt,
    this.views = 0,
    this.uniqueViews = 0,
    this.likes = const [],
    this.bookmarks = const [],
    this.shares = 0,
    this.commentsCount = 0,
    this.seoTitle,
    this.seoDescription,
    this.metaKeywords = const [],
    this.canonicalUrl,
    this.relatedNews = const [],
    this.source,
    this.sourceUrl,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.coAuthors = const [],
    this.editor,
    this.readingTime = 0,
    this.engagementRate = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      author: NewsAuthor.fromJson(json['author'] is String
          ? {'id': json['author']}
          : json['author'] ?? {}),
      category: NewsCategory.fromJson(json['category'] is String
          ? {'id': json['category'], 'name': 'Uncategorized'}
          : json['category'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      featuredImage: json['featuredImage'],
      imageGallery: List<String>.from(json['imageGallery'] ?? []),
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      attachedFiles: List<String>.from(json['attachedFiles'] ?? []),
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      isFeatured: json['isFeatured'] ?? false,
      isBreaking: json['isBreaking'] ?? false,
      isSponsored: json['isSponsored'] ?? false,
      isExclusive: json['isExclusive'] ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt']).toLocal()
          : null,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor']).toLocal()
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt']).toLocal()
          : null,
      views: json['views'] ?? 0,
      uniqueViews: json['uniqueViews'] ?? 0,
      likes: List<String>.from(json['likes'] ?? []),
      bookmarks: List<String>.from(json['bookmarks'] ?? []),
      shares: json['shares'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      seoTitle: json['seoTitle'],
      seoDescription: json['seoDescription'],
      metaKeywords: List<String>.from(json['metaKeywords'] ?? []),
      canonicalUrl: json['canonicalUrl'],
      relatedNews: List<String>.from(json['relatedNews'] ?? []),
      source: json['source'],
      sourceUrl: json['sourceUrl'],
      reviewedBy: json['reviewedBy'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt']).toLocal()
          : null,
      reviewNotes: json['reviewNotes'],
      coAuthors: (json['coAuthors'] as List<dynamic>?)
          ?.map((author) => NewsAuthor.fromJson(author))
          .toList() ??
          const [],
      editor: json['editor'],
      readingTime: json['readingTime'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
    );
  }

  static NewsStatus _parseStatus(String status) {
    return NewsStatus.values.firstWhere(
          (e) => e.name == status.toLowerCase(),
      orElse: () => NewsStatus.draft,
    );
  }

  static NewsPriority _parsePriority(String priority) {
    return NewsPriority.values.firstWhere(
          (e) => e.name == priority.toLowerCase(),
      orElse: () => NewsPriority.medium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'excerpt': excerpt,
      'category': category.id,
      'tags': tags,
      'status': status.name,
      'priority': priority.name,
      'isFeatured': isFeatured,
      'isBreaking': isBreaking,
      'isSponsored': isSponsored,
      'isExclusive': isExclusive,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'metaKeywords': metaKeywords,
      'canonicalUrl': canonicalUrl,
      'source': source,
      'sourceUrl': sourceUrl,
      'coAuthors': coAuthors.map((author) => author.id).toList(),
    };
  }

  NewsArticle copyWith({
    String? id,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? excerpt,
    NewsAuthor? author,
    NewsCategory? category,
    List<String>? tags,
    String? featuredImage,
    List<String>? imageGallery,
    String? videoUrl,
    String? audioUrl,
    List<String>? attachedFiles,
    NewsStatus? status,
    NewsPriority? priority,
    bool? isFeatured,
    bool? isBreaking,
    bool? isSponsored,
    bool? isExclusive,
    DateTime? publishedAt,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    int? views,
    int? uniqueViews,
    List<String>? likes,
    List<String>? bookmarks,
    int? shares,
    int? commentsCount,
    String? seoTitle,
    String? seoDescription,
    List<String>? metaKeywords,
    String? canonicalUrl,
    List<String>? relatedNews,
    String? source,
    String? sourceUrl,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNotes,
    List<NewsAuthor>? coAuthors,
    String? editor,
    int? readingTime,
    double? engagementRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      featuredImage: featuredImage ?? this.featuredImage,
      imageGallery: imageGallery ?? this.imageGallery,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      isFeatured: isFeatured ?? this.isFeatured,
      isBreaking: isBreaking ?? this.isBreaking,
      isSponsored: isSponsored ?? this.isSponsored,
      isExclusive: isExclusive ?? this.isExclusive,
      publishedAt: publishedAt ?? this.publishedAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      expiresAt: expiresAt ?? this.expiresAt,
      views: views ?? this.views,
      uniqueViews: uniqueViews ?? this.uniqueViews,
      likes: likes ?? this.likes,
      bookmarks: bookmarks ?? this.bookmarks,
      shares: shares ?? this.shares,
      commentsCount: commentsCount ?? this.commentsCount,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      metaKeywords: metaKeywords ?? this.metaKeywords,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      relatedNews: relatedNews ?? this.relatedNews,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      coAuthors: coAuthors ?? this.coAuthors,
      editor: editor ?? this.editor,
      readingTime: readingTime ?? this.readingTime,
      engagementRate: engagementRate ?? this.engagementRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPublished => status == NewsStatus.published;

  bool get isDraft => status == NewsStatus.draft;

  bool get isPendingReview => status == NewsStatus.pendingReview;

  bool get isScheduled => status == NewsStatus.scheduled;

  bool get isArchived => status == NewsStatus.archived;

  String get formattedPublishedDate {
    if (publishedAt == null) return 'Not published';
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(publishedAt!);
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

  String get statusLabel {
    switch (status) {
      case NewsStatus.draft:
        return 'Draft';
      case NewsStatus.pendingReview:
        return 'Pending Review';
      case NewsStatus.published:
        return 'Published';
      case NewsStatus.scheduled:
        return 'Scheduled';
      case NewsStatus.archived:
        return 'Archived';
      case NewsStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case NewsStatus.draft:
        return Colors.grey;
      case NewsStatus.pendingReview:
        return Colors.orange;
      case NewsStatus.published:
        return Colors.green;
      case NewsStatus.scheduled:
        return Colors.blue;
      case NewsStatus.archived:
        return Colors.grey.shade700;
      case NewsStatus.rejected:
        return Colors.red;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case NewsPriority.low:
        return 'Low';
      case NewsPriority.medium:
        return 'Medium';
      case NewsPriority.high:
        return 'High';
      case NewsPriority.urgent:
        return 'Urgent';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NewsPriority.low:
        return Colors.green;
      case NewsPriority.medium:
        return Colors.blue;
      case NewsPriority.high:
        return Colors.orange;
      case NewsPriority.urgent:
        return Colors.red;
    }
  }
}