import 'package:flutter/material.dart';

class NewsConstants {
  // API Endpoints
  static const String baseNewsEndpoint = '/news';
  static const String baseCategoryEndpoint = '/news-categories';
  static const String baseCommentEndpoint = '/news-comments';
  static const String baseSubscriptionEndpoint = '/news-subscriptions';
  static const String baseAnalyticsEndpoint = '/news-analytics';

  // Default values
  static const int defaultPageSize = 10;
  static const int defaultCategoryPageSize = 20;
  static const int defaultCommentPageSize = 20;

  // Status colors
  static Map<String, Color> statusColors = {
    'draft': Colors.grey,
    'pending_review': Colors.orange,
    'published': Colors.green,
    'scheduled': Colors.blue,
    'archived': Colors.grey.shade700,
    'rejected': Colors.red,
  };

  // Priority colors
  static Map<String, Color> priorityColors = {
    'low': Colors.green,
    'medium': Colors.blue,
    'high': Colors.orange,
    'urgent': Colors.red,
  };

  // Reaction types
  static const List<String> reactionTypes = [
    'like',
    'love',
    'haha',
    'wow',
    'sad',
    'angry',
  ];

  // Reaction emojis
  static Map<String, String> reactionEmojis = {
    'like': '👍',
    'love': '❤️',
    'haha': '😄',
    'wow': '😲',
    'sad': '😢',
    'angry': '😠',
  };

  // Category icons
  static Map<String, IconData> categoryIcons = {
    'newspaper': Icons.newspaper,
    'business': Icons.business,
    'sports': Icons.sports,
    'entertainment': Icons.movie,
    'technology': Icons.computer,
    'health': Icons.medical_services,
    'education': Icons.school,
    'politics': Icons.gavel,
    'finance': Icons.attach_money,
    'lifestyle': Icons.spa,
  };

  // Analytics periods
  static const List<String> analyticsPeriods = [
    '1d',
    '7d',
    '30d',
    '90d',
  ];

  // Digest frequencies
  static const List<String> digestFrequencies = [
    'realtime',
    'daily',
    'weekly',
  ];

  // Notification types
  static const List<String> notificationTypes = [
    'onPublish',
    'onBreakingNews',
    'onAuthorPost',
  ];
}

class NewsValidation {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    if (value.length > 200) {
      return 'Title must be less than 200 characters';
    }
    return null;
  }

  static String? validateSummary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Summary is required';
    }
    if (value.length < 10) {
      return 'Summary must be at least 10 characters';
    }
    if (value.length > 500) {
      return 'Summary must be less than 500 characters';
    }
    return null;
  }

  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content is required';
    }
    if (value.length < 50) {
      return 'Content must be at least 50 characters';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    return null;
  }
}