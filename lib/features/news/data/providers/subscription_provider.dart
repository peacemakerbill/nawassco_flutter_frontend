import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../core/utils/toast_utils.dart';
import '../../../../core/services/api_service.dart';
import '../models/news_subscription.dart';

class SubscriptionProvider extends StateNotifier<SubscriptionState> {
  final Dio dio;
  final Ref ref;

  SubscriptionProvider(this.dio, this.ref) : super(SubscriptionState.initial());

  Future<void> fetchSubscriptions({SubscriptionQuery? query}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-subscriptions',
        queryParameters: query?.toQueryParams(),
      );

      final data = response.data['data'];
      final subscriptions = (data['subscriptions'] as List).map((item) => NewsSubscription.fromJson(item)).toList();

      state = state.copyWith(
        subscriptions: subscriptions,
        isLoading: false,
        pagination: PaginationInfo(
          page: data['pagination']['page'] ?? 1,
          limit: data['pagination']['limit'] ?? 20,
          total: data['pagination']['total'] ?? 0,
          pages: data['pagination']['screens'] ?? 1,
        ),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch subscriptions',
      );
      ToastUtils.showErrorToast('Failed to load subscriptions');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch subscriptions',
      );
      ToastUtils.showErrorToast('Failed to load subscriptions');
    }
  }

  Future<Map<String, List<NewsSubscription>>> fetchUserSubscriptions({bool isActive = true}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-subscriptions/my-subscriptions',
        queryParameters: {'isActive': isActive.toString()},
      );

      final data = response.data['data']['subscriptions'];

      return {
        'categories': (data['categories'] as List).map((item) => NewsSubscription.fromJson(item)).toList(),
        'authors': (data['authors'] as List).map((item) => NewsSubscription.fromJson(item)).toList(),
        'breaking': (data['breaking'] as List).map((item) => NewsSubscription.fromJson(item)).toList(),
        'all': (data['all'] as List).map((item) => NewsSubscription.fromJson(item)).toList(),
      };
    } catch (e) {
      return {
        'categories': [],
        'authors': [],
        'breaking': [],
        'all': [],
      };
    }
  }

  Future<NewsSubscription?> fetchSubscriptionById(String id) async {
    try {
      final response = await dio.get('/v1/nawassco/news/news-subscriptions/$id');
      final data = response.data['data']['subscription'];
      return NewsSubscription.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch subscription');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch subscription');
      return null;
    }
  }

  Future<bool> checkSubscription({
    required String type,
    String? category,
    String? author,
  }) async {
    try {
      final params = {'type': type};
      if (category != null) params['category'] = category;
      if (author != null) params['author'] = author;

      final response = await dio.get(
        '/v1/nawassco/news/news-subscriptions/check',
        queryParameters: params,
      );

      return response.data['data']['isSubscribed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<NewsSubscription?> createSubscription(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/news/news-subscriptions',
        data: data,
      );

      final subscriptionData = response.data['data']['subscription'];
      final newSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: [...state.subscriptions, newSubscription],
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Subscription created successfully');
      return newSubscription;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to create subscription',
      );
      ToastUtils.showErrorToast('Failed to create subscription');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create subscription',
      );
      ToastUtils.showErrorToast('Failed to create subscription');
      return null;
    }
  }

  Future<NewsSubscription?> updateSubscription(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/news/news-subscriptions/$id',
        data: data,
      );

      final subscriptionData = response.data['data']['subscription'];
      final updatedSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: state.subscriptions.map((s) => s.id == id ? updatedSubscription : s).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Subscription updated successfully');
      return updatedSubscription;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to update subscription',
      );
      ToastUtils.showErrorToast('Failed to update subscription');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update subscription',
      );
      ToastUtils.showErrorToast('Failed to update subscription');
      return null;
    }
  }

  Future<bool> deleteSubscription(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/v1/nawassco/news/news-subscriptions/$id');

      state = state.copyWith(
        subscriptions: state.subscriptions.where((s) => s.id != id).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Subscription deleted successfully');
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to delete subscription',
      );
      ToastUtils.showErrorToast('Failed to delete subscription');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete subscription',
      );
      ToastUtils.showErrorToast('Failed to delete subscription');
      return false;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news-subscriptions/$id/toggle-active');

      final subscriptionData = response.data['data']['subscription'];
      final updatedSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: state.subscriptions.map((s) => s.id == id ? updatedSubscription : s).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
          updatedSubscription.isActive ? 'Subscription activated' : 'Subscription deactivated'
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to toggle subscription',
      );
      ToastUtils.showErrorToast('Failed to toggle subscription');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle subscription',
      );
      ToastUtils.showErrorToast('Failed to toggle subscription');
      return false;
    }
  }

  Future<NewsSubscription?> subscribeToCategory(String categoryId, Map<String, dynamic>? preferences) async {
    try {
      final response = await dio.post(
        '/v1/nawassco/news/news-subscriptions/category/$categoryId',
        data: preferences,
      );

      final subscriptionData = response.data['data']['subscription'];
      final newSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: [...state.subscriptions, newSubscription],
      );

      ToastUtils.showSuccessToast('Subscribed to category');
      return newSubscription;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to subscribe');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to subscribe');
      return null;
    }
  }

  Future<NewsSubscription?> subscribeToAuthor(String authorId, Map<String, dynamic>? preferences) async {
    try {
      final response = await dio.post(
        '/v1/nawassco/news/news-subscriptions/author/$authorId',
        data: preferences,
      );

      final subscriptionData = response.data['data']['subscription'];
      final newSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: [...state.subscriptions, newSubscription],
      );

      ToastUtils.showSuccessToast('Subscribed to author');
      return newSubscription;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to subscribe');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to subscribe');
      return null;
    }
  }

  Future<NewsSubscription?> subscribeToBreakingNews(Map<String, dynamic>? preferences) async {
    try {
      final response = await dio.post(
        '/v1/nawassco/news/news-subscriptions/breaking-news',
        data: preferences,
      );

      final subscriptionData = response.data['data']['subscription'];
      final newSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: [...state.subscriptions, newSubscription],
      );

      ToastUtils.showSuccessToast('Subscribed to breaking news');
      return newSubscription;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to subscribe');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to subscribe');
      return null;
    }
  }

  Future<NewsSubscription?> subscribeToAllNews(Map<String, dynamic>? preferences) async {
    try {
      final response = await dio.post(
        '/v1/nawassco/news/news-subscriptions/all-news',
        data: preferences,
      );

      final subscriptionData = response.data['data']['subscription'];
      final newSubscription = NewsSubscription.fromJson(subscriptionData);

      state = state.copyWith(
        subscriptions: [...state.subscriptions, newSubscription],
      );

      ToastUtils.showSuccessToast('Subscribed to all news');
      return newSubscription;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to subscribe');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to subscribe');
      return null;
    }
  }

  // Filter methods
  List<NewsSubscription> getActiveSubscriptions() {
    return state.subscriptions.where((s) => s.isActive).toList();
  }

  List<NewsSubscription> getCategorySubscriptions() {
    return state.subscriptions.where((s) => s.type == NewsSubscriptionType.category).toList();
  }

  List<NewsSubscription> getAuthorSubscriptions() {
    return state.subscriptions.where((s) => s.type == NewsSubscriptionType.author).toList();
  }

  List<NewsSubscription> getBreakingNewsSubscriptions() {
    return state.subscriptions.where((s) => s.type == NewsSubscriptionType.breakingNews).toList();
  }

  List<NewsSubscription> getAllNewsSubscriptions() {
    return state.subscriptions.where((s) => s.type == NewsSubscriptionType.all).toList();
  }

  bool isSubscribedToCategory(String categoryId) {
    return state.subscriptions.any((s) =>
    s.type == NewsSubscriptionType.category &&
        s.categoryId == categoryId &&
        s.isActive
    );
  }

  bool isSubscribedToAuthor(String authorId) {
    return state.subscriptions.any((s) =>
    s.type == NewsSubscriptionType.author &&
        s.authorId == authorId &&
        s.isActive
    );
  }
}

class SubscriptionState {
  final List<NewsSubscription> subscriptions;
  final bool isLoading;
  final String? error;
  final PaginationInfo? pagination;

  const SubscriptionState({
    this.subscriptions = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  SubscriptionState.initial() : this();

  SubscriptionState copyWith({
    List<NewsSubscription>? subscriptions,
    bool? isLoading,
    String? error,
    PaginationInfo? pagination,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }
}

class SubscriptionQuery {
  final int? page;
  final int? limit;
  final String? user;
  final String? type;
  final String? category;
  final String? author;
  final bool? isActive;

  const SubscriptionQuery({
    this.page,
    this.limit,
    this.user,
    this.type,
    this.category,
    this.author,
    this.isActive,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (user != null) params['user'] = user;
    if (type != null) params['type'] = type;
    if (category != null) params['category'] = category;
    if (author != null) params['author'] = author;
    if (isActive != null) params['isActive'] = isActive;

    return params;
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionProvider, SubscriptionState>((ref) {
  final dio = ref.watch(dioProvider);
  return SubscriptionProvider(dio, ref);
});