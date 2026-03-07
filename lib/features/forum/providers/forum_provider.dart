import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../models/forum_category.dart';
import '../models/forum_notification.dart';
import '../models/forum_reply.dart';
import '../models/forum_thread.dart';

class ForumState {
  final List<ForumCategory> categories;
  final List<ForumThread> threads;
  final List<ForumThread> popularThreads;
  final List<ForumNotification> notifications;
  final Map<String, List<ForumReply>> threadReplies;
  final String? selectedCategoryId;
  final String? selectedThreadId;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final int totalPages;

  ForumState({
    this.categories = const [],
    this.threads = const [],
    this.popularThreads = const [],
    this.notifications = const [],
    this.threadReplies = const {},
    this.selectedCategoryId,
    this.selectedThreadId,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
  });

  ForumState copyWith({
    List<ForumCategory>? categories,
    List<ForumThread>? threads,
    List<ForumThread>? popularThreads,
    List<ForumNotification>? notifications,
    Map<String, List<ForumReply>>? threadReplies,
    String? selectedCategoryId,
    String? selectedThreadId,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
  }) {
    return ForumState(
      categories: categories ?? this.categories,
      threads: threads ?? this.threads,
      popularThreads: popularThreads ?? this.popularThreads,
      notifications: notifications ?? this.notifications,
      threadReplies: threadReplies ?? this.threadReplies,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedThreadId: selectedThreadId ?? this.selectedThreadId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  int get unreadNotificationsCount =>
      notifications.where((n) => n.isUnread).length;
}

class ForumProvider extends StateNotifier<ForumState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  ForumProvider(this.dio, this.scaffoldMessengerKey)
      : super(ForumState());

  // Fetch all categories
  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/forums/forum/categories');

      if (response.data['success'] == true) {
        final categories = (response.data['data']['categories'] as List)
            .map((json) => ForumCategory.fromJson(json))
            .toList();

        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load categories',
      );
      _showError(e);
    }
  }

  // Fetch threads with filters
  Future<void> fetchThreads({
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
    String sort = 'latest',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queryParams = {
        'page': page,
        'limit': limit,
        'sort': sort,
        if (categoryId != null) 'category': categoryId,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      };

      final response = await dio.get('/v1/nawassco/forums/forum/threads', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final threads = (response.data['data']['result']['threads'] as List)
            .map((json) => ForumThread.fromJson(json))
            .toList();

        state = state.copyWith(
          threads: threads,
          selectedCategoryId: categoryId,
          searchQuery: searchQuery ?? '',
          currentPage: page,
          totalPages: response.data['data']['result']['screens'] ?? 1,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load threads',
      );
      _showError(e);
    }
  }

  // Fetch popular threads
  Future<void> fetchPopularThreads() async {
    try {
      final response = await dio.get('/v1/nawassco/forums/forum/threads', queryParameters: {
        'limit': 5,
        'sort': 'popular',
      });

      if (response.data['success'] == true) {
        final threads = (response.data['data']['result']['threads'] as List)
            .map((json) => ForumThread.fromJson(json))
            .toList();

        state = state.copyWith(popularThreads: threads);
      }
    } catch (e) {
      // Silent fail for popular threads
    }
  }

  // Fetch thread details
  Future<ForumThread?> fetchThreadBySlug(String slug) async {
    try {
      final response = await dio.get('/v1/nawassco/forums/forum/threads/$slug');

      if (response.data['success'] == true) {
        return ForumThread.fromJson(response.data['data']['thread']);
      }
    } catch (e) {
      _showError(e);
    }
    return null;
  }

  // Fetch replies for a thread
  Future<void> fetchThreadReplies(String threadId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/forums/forum/replies', queryParameters: {
        'thread': threadId,
        'limit': 50,
      });

      if (response.data['success'] == true) {
        final replies = (response.data['data']['result']['replies'] as List)
            .map((json) => ForumReply.fromJson(json))
            .toList();

        state = state.copyWith(
          threadReplies: {
            ...state.threadReplies,
            threadId: replies,
          },
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load replies',
      );
      _showError(e);
    }
  }

  // Create a new thread
  Future<bool> createThread(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post('/v1/nawassco/forums/forum/threads', data: data);

      if (response.data['success'] == true) {
        final thread = ForumThread.fromJson(response.data['data']['thread']);

        state = state.copyWith(
          threads: [thread, ...state.threads],
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Thread created successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showError(e);
    }
    return false;
  }

  // Create a reply
  Future<bool> createReply(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post('/v1/nawassco/forums/forum/replies', data: data);

      if (response.data['success'] == true) {
        final reply = ForumReply.fromJson(response.data['data']['reply']);
        final threadId = reply.threadId;

        // Update replies for this thread
        final currentReplies = state.threadReplies[threadId] ?? [];
        state = state.copyWith(
          threadReplies: {
            ...state.threadReplies,
            threadId: [reply, ...currentReplies],
          },
          isLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Reply posted successfully!',
          key: scaffoldMessengerKey,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showError(e);
    }
    return false;
  }

  // Like/unlike a thread
  Future<void> toggleThreadLike(String threadId) async {
    try {
      final response = await dio.post('/v1/nawassco/forums/forum/threads/$threadId/like');

      if (response.data['success'] == true) {
        // Update thread in list
        final updatedThread = ForumThread.fromJson(response.data['data']['thread']);
        final updatedThreads = state.threads.map((thread) {
          return thread.id == threadId ? updatedThread : thread;
        }).toList();

        state = state.copyWith(threads: updatedThreads);
      }
    } catch (e) {
      _showError(e);
    }
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    try {
      final response = await dio.get('/v1/nawassco/forums/forum/notifications');

      if (response.data['success'] == true) {
        final notifications = (response.data['data']['notifications'] as List)
            .map((json) => ForumNotification.fromJson(json))
            .toList();

        state = state.copyWith(notifications: notifications);
      }
    } catch (e) {
      // Silent fail for notifications
    }
  }

  // Mark notifications as read
  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    try {
      await dio.post('/v1/nawassco/forums/forum/notifications/mark-read', data: {
        'notificationIds': notificationIds,
      });

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notificationIds.contains(notification.id)) {
          return ForumNotification(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            data: notification.data,
            status: 'read',
            isActionable: notification.isActionable,
            actionUrl: notification.actionUrl,
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      _showError(e);
    }
  }

  // Search forum
  Future<void> searchForum(String query) async {
    if (query.length < 3) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/forums/forum/search', queryParameters: {
        'q': query,
        'page': 1,
        'limit': 20,
      });

      if (response.data['success'] == true) {
        final threads = (response.data['data']['threads'] as List)
            .map((json) => ForumThread.fromJson(json))
            .toList();

        state = state.copyWith(
          threads: threads,
          searchQuery: query,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed',
      );
      _showError(e);
    }
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    fetchThreads();
  }

  // Select category
  void selectCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    fetchThreads(categoryId: categoryId);
  }

  // Select thread
  void selectThread(String threadId) {
    state = state.copyWith(selectedThreadId: threadId);
  }

  // Clear selected thread
  void clearSelectedThread() {
    state = state.copyWith(selectedThreadId: null);
  }

  // Error handler
  void _showError(dynamic error) {
    String message = 'An error occurred';

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'];
      } else if (error.message != null) {
        message = error.message!;
      }
    }

    ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
  }
}

// Provider
final forumProvider = StateNotifierProvider<ForumProvider, ForumState>((ref) {
  final dio = ref.read(dioProvider);
  return ForumProvider(dio, scaffoldMessengerKey);
});