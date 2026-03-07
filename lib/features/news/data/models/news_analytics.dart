import 'package:flutter/material.dart';

class ViewSources {
  final int direct;
  final int social;
  final int search;
  final int referral;

  const ViewSources({
    this.direct = 0,
    this.social = 0,
    this.search = 0,
    this.referral = 0,
  });

  factory ViewSources.fromJson(Map<String, dynamic> json) {
    return ViewSources(
      direct: json['direct'] ?? 0,
      social: json['social'] ?? 0,
      search: json['search'] ?? 0,
      referral: json['referral'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'direct': direct,
        'social': social,
        'search': search,
        'referral': referral,
      };

  int get total => direct + social + search + referral;

  Map<String, double> get percentages {
    final total = this.total.toDouble();
    if (total == 0)
      return {
        'direct': 0.0,
        'social': 0.0,
        'search': 0.0,
        'referral': 0.0,
      };

    return {
      'direct': (direct / total * 100),
      'social': (social / total * 100),
      'search': (search / total * 100),
      'referral': (referral / total * 100),
    };
  }
}

class UserDemographics {
  final Map<String, int> ageGroups;
  final Map<String, int> genders;
  final Map<String, int> locations;

  const UserDemographics({
    this.ageGroups = const {},
    this.genders = const {},
    this.locations = const {},
  });

  factory UserDemographics.fromJson(Map<String, dynamic> json) {
    return UserDemographics(
      ageGroups: Map<String, int>.from(json['ageGroups'] ?? {}),
      genders: Map<String, int>.from(json['genders'] ?? {}),
      locations: Map<String, int>.from(json['locations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'ageGroups': ageGroups,
        'genders': genders,
        'locations': locations,
      };
}

class DeviceAnalytics {
  final int mobile;
  final int desktop;
  final int tablet;

  const DeviceAnalytics({
    this.mobile = 0,
    this.desktop = 0,
    this.tablet = 0,
  });

  factory DeviceAnalytics.fromJson(Map<String, dynamic> json) {
    return DeviceAnalytics(
      mobile: json['mobile'] ?? 0,
      desktop: json['desktop'] ?? 0,
      tablet: json['tablet'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'desktop': desktop,
        'tablet': tablet,
      };

  int get total => mobile + desktop + tablet;

  Map<String, double> get percentages {
    final total = this.total.toDouble();
    if (total == 0)
      return {
        'mobile': 0.0,
        'desktop': 0.0,
        'tablet': 0.0,
      };

    return {
      'mobile': (mobile / total * 100),
      'desktop': (desktop / total * 100),
      'tablet': (tablet / total * 100),
    };
  }
}

class NewsAnalytics {
  final String id;
  final String newsId;
  final DateTime date;
  final int views;
  final int uniqueViews;
  final ViewSources viewSources;
  final int likes;
  final int comments;
  final int shares;
  final int bookmarks;
  final double averageTimeSpent;
  final double bounceRate;
  final UserDemographics userDemographics;
  final DeviceAnalytics devices;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsAnalytics({
    required this.id,
    required this.newsId,
    required this.date,
    this.views = 0,
    this.uniqueViews = 0,
    required this.viewSources,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.bookmarks = 0,
    this.averageTimeSpent = 0,
    this.bounceRate = 0,
    required this.userDemographics,
    required this.devices,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsAnalytics.fromJson(Map<String, dynamic> json) {
    return NewsAnalytics(
      id: json['_id'] ?? json['id'],
      newsId:
          json['news'] is String ? json['news'] : json['news']?['_id'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
      views: json['views'] ?? 0,
      uniqueViews: json['uniqueViews'] ?? 0,
      viewSources: ViewSources.fromJson(json['viewSources'] ?? {}),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      bookmarks: json['bookmarks'] ?? 0,
      averageTimeSpent: (json['averageTimeSpent'] ?? 0).toDouble(),
      bounceRate: (json['bounceRate'] ?? 0).toDouble(),
      userDemographics:
          UserDemographics.fromJson(json['userDemographics'] ?? {}),
      devices: DeviceAnalytics.fromJson(json['devices'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
    );
  }

  double get engagementRate {
    if (views == 0) return 0;
    final engagement = likes + comments + shares;
    return (engagement / views * 100);
  }

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}

class AnalyticsSummary {
  final int totalViews;
  final int totalUniqueViews;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalBookmarks;
  final double averageTimeSpent;
  final double averageBounceRate;
  final double engagementRate;

  const AnalyticsSummary({
    this.totalViews = 0,
    this.totalUniqueViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalShares = 0,
    this.totalBookmarks = 0,
    this.averageTimeSpent = 0,
    this.averageBounceRate = 0,
    this.engagementRate = 0,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalViews: json['totalViews'] ?? 0,
      totalUniqueViews: json['totalUniqueViews'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalBookmarks: json['totalBookmarks'] ?? 0,
      averageTimeSpent: (json['averageTimeSpent'] ?? 0).toDouble(),
      averageBounceRate: (json['averageBounceRate'] ?? 0).toDouble(),
      engagementRate: (json['engagementRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalViews': totalViews,
        'totalUniqueViews': totalUniqueViews,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
        'totalShares': totalShares,
        'totalBookmarks': totalBookmarks,
        'averageTimeSpent': averageTimeSpent,
        'averageBounceRate': averageBounceRate,
        'engagementRate': engagementRate,
      };
}

class TrendData {
  final String date;
  final int views;
  final int uniqueViews;
  final int likes;
  final int comments;
  final int shares;

  const TrendData({
    required this.date,
    required this.views,
    required this.uniqueViews,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: json['date'] ?? '',
      views: json['views'] ?? 0,
      uniqueViews: json['uniqueViews'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'views': views,
        'uniqueViews': uniqueViews,
        'likes': likes,
        'comments': comments,
        'shares': shares,
      };
}
