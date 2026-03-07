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

class CategoryStats {
  final int newsCount;
  final int publishedCount;
  final int draftCount;
  final int totalViews;

  const CategoryStats({
    required this.newsCount,
    required this.publishedCount,
    required this.draftCount,
    required this.totalViews,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      newsCount: json['newsCount'] ?? 0,
      publishedCount: json['publishedCount'] ?? 0,
      draftCount: json['draftCount'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'newsCount': newsCount,
    'publishedCount': publishedCount,
    'draftCount': draftCount,
    'totalViews': totalViews,
  };
}

class CategoryMetadata {
  final bool allowComments;
  final bool allowGuestView;
  final bool approvalRequired;
  final int maxNewsPerUser;

  const CategoryMetadata({
    this.allowComments = true,
    this.allowGuestView = true,
    this.approvalRequired = false,
    this.maxNewsPerUser = 10,
  });

  factory CategoryMetadata.fromJson(Map<String, dynamic> json) {
    return CategoryMetadata(
      allowComments: json['allowComments'] ?? true,
      allowGuestView: json['allowGuestView'] ?? true,
      approvalRequired: json['approvalRequired'] ?? false,
      maxNewsPerUser: json['maxNewsPerUser'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'allowComments': allowComments,
    'allowGuestView': allowGuestView,
    'approvalRequired': approvalRequired,
    'maxNewsPerUser': maxNewsPerUser,
  };
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
  final String? seoTitle;
  final String? seoDescription;
  final String createdById;
  final int threadCount;
  final String? lastNewsId;
  final DateTime? lastActivityAt;
  final CategoryMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryStats? stats;

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
    this.seoTitle,
    this.seoDescription,
    required this.createdById,
    this.threadCount = 0,
    this.lastNewsId,
    this.lastActivityAt,
    this.metadata = const CategoryMetadata(),
    required this.createdAt,
    required this.updatedAt,
    this.stats,
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
      seoTitle: json['seoTitle'],
      seoDescription: json['seoDescription'],
      createdById: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id'] ?? '',
      threadCount: json['threadCount'] ?? 0,
      lastNewsId: json['lastNews'] is String
          ? json['lastNews']
          : json['lastNews']?['_id'],
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt']).toLocal()
          : null,
      metadata: CategoryMetadata.fromJson(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      stats:
      json['stats'] != null ? CategoryStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'order': order,
      'parentCategory': parentCategoryId,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'metadata': metadata.toJson(),
    };
  }

  NewsCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? slug,
    String? color,
    String? icon,
    bool? isActive,
    bool? isFeatured,
    int? order,
    String? parentCategoryId,
    String? seoTitle,
    String? seoDescription,
    String? createdById,
    int? threadCount,
    String? lastNewsId,
    DateTime? lastActivityAt,
    CategoryMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryStats? stats,
  }) {
    return NewsCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      order: order ?? this.order,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      createdById: createdById ?? this.createdById,
      threadCount: threadCount ?? this.threadCount,
      lastNewsId: lastNewsId ?? this.lastNewsId,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  Color get categoryColor {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF007bff);
    }
  }

  IconData get categoryIcon {
    switch (icon) {
      case 'newspaper':
        return Icons.newspaper;
      case 'business':
        return Icons.business;
      case 'sports':
        return Icons.sports;
      case 'entertainment':
        return Icons.movie;
      case 'technology':
        return Icons.computer;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'politics':
        return Icons.gavel;
      default:
        return Icons.category;
    }
  }
}