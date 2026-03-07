import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../main.dart';
import '../models/news_analytics.dart';

class AnalyticsProvider extends StateNotifier<AnalyticsState> {
  final Dio dio;
  final Ref ref;

  AnalyticsProvider(this.dio, this.ref) : super(AnalyticsState.initial());

  Future<void> fetchNewsAnalytics(String newsId, {String period = '7d'}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-analytics/news/$newsId',
        queryParameters: {'period': period},
      );

      final data = response.data['data'];

      final analytics = (data['analytics'] as List).map((item) => NewsAnalytics.fromJson(item)).toList();
      final summary = AnalyticsSummary.fromJson(data['summary']);
      final trends = (data['trends'] as List).map((item) => TrendData.fromJson(item)).toList();

      state = state.copyWith(
        newsAnalytics: analytics,
        newsSummary: summary,
        newsTrends: trends,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch analytics',
      );
      ToastUtils.showErrorToast('Failed to load analytics');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch analytics',
      );
      ToastUtils.showErrorToast('Failed to load analytics');
    }
  }

  Future<void> fetchOverallAnalytics({
    String period = '30d',
    String? category,
    String? author,
    String groupBy = 'day',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-analytics/overall',
        queryParameters: {
          'period': period,
          'category': category,
          'author': author,
          'groupBy': groupBy,
        },
      );

      final data = response.data['data'];

      final summary = AnalyticsSummary.fromJson(data['summary']);
      final trends = (data['trends'] as List).map((item) => TrendData.fromJson(item)).toList();
      final popularNews = data['popularNews'] as List;
      final categoryPerformance = data['categoryPerformance'] as List;
      final authorPerformance = data['authorPerformance'] as List;

      state = state.copyWith(
        overallSummary: summary,
        overallTrends: trends,
        popularNews: popularNews,
        categoryPerformance: categoryPerformance,
        authorPerformance: authorPerformance,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch overall analytics',
      );
      ToastUtils.showErrorToast('Failed to load overall analytics');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch overall analytics',
      );
      ToastUtils.showErrorToast('Failed to load overall analytics');
    }
  }

  Future<void> fetchAuthorAnalytics({String period = '30d'}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-analytics/author',
        queryParameters: {'period': period},
      );

      final data = response.data['data'];

      final summary = AnalyticsSummary.fromJson(data['summary']);
      final performance = data['performance'] as List;
      final popularArticles = data['popularArticles'] as List;
      final trends = (data['trends'] as List).map((item) => TrendData.fromJson(item)).toList();

      state = state.copyWith(
        authorSummary: summary,
        authorPerformance: performance,
        popularArticles: popularArticles,
        authorTrends: trends,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch author analytics',
      );
      ToastUtils.showErrorToast('Failed to load author analytics');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch author analytics',
      );
      ToastUtils.showErrorToast('Failed to load author analytics');
    }
  }

  Future<void> trackNewsView(
      String newsId, {
        String? userId,
        String? userAgent,
        String? ipAddress,
        String? referrer,
        String? source,
      }) async {
    try {
      await dio.post('/v1/nawassco/news/news-analytics/track-view/$newsId');
    } catch (e) {
      // Silently fail for tracking
    }
  }

  Future<List<dynamic>> fetchTrendingNews({int limit = 10, String period = '7d'}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-analytics/trending',
        queryParameters: {'limit': limit, 'period': period},
      );

      return response.data['data']['trendingNews'] as List;
    } catch (e) {
      return [];
    }
  }

  // Helper methods
  Map<String, double> calculateTrafficSources() {
    if (state.newsAnalytics.isEmpty) return {};

    int totalDirect = 0;
    int totalSocial = 0;
    int totalSearch = 0;
    int totalReferral = 0;

    for (final analytic in state.newsAnalytics) {
      totalDirect += analytic.viewSources.direct;
      totalSocial += analytic.viewSources.social;
      totalSearch += analytic.viewSources.search;
      totalReferral += analytic.viewSources.referral;
    }

    final total = totalDirect + totalSocial + totalSearch + totalReferral;
    if (total == 0) return {};

    return {
      'direct': (totalDirect / total * 100),
      'social': (totalSocial / total * 100),
      'search': (totalSearch / total * 100),
      'referral': (totalReferral / total * 100),
    };
  }

  Map<String, double> calculateDeviceDistribution() {
    if (state.newsAnalytics.isEmpty) return {};

    int totalMobile = 0;
    int totalDesktop = 0;
    int totalTablet = 0;

    for (final analytic in state.newsAnalytics) {
      totalMobile += analytic.devices.mobile;
      totalDesktop += analytic.devices.desktop;
      totalTablet += analytic.devices.tablet;
    }

    final total = totalMobile + totalDesktop + totalTablet;
    if (total == 0) return {};

    return {
      'mobile': (totalMobile / total * 100),
      'desktop': (totalDesktop / total * 100),
      'tablet': (totalTablet / total * 100),
    };
  }

  void clearNewsAnalytics() {
    state = state.copyWith(
      newsAnalytics: [],
      newsSummary: null,
      newsTrends: [],
    );
  }

  void clearOverallAnalytics() {
    state = state.copyWith(
      overallSummary: null,
      overallTrends: [],
      popularNews: [],
      categoryPerformance: [],
      authorPerformance: [],
    );
  }

  void clearAuthorAnalytics() {
    state = state.copyWith(
      authorSummary: null,
      authorPerformance: [],
      popularArticles: [],
      authorTrends: [],
    );
  }
}

class AnalyticsState {
  final List<NewsAnalytics> newsAnalytics;
  final AnalyticsSummary? newsSummary;
  final List<TrendData> newsTrends;
  final AnalyticsSummary? overallSummary;
  final List<TrendData> overallTrends;
  final List<dynamic> popularNews;
  final List<dynamic> categoryPerformance;
  final List<dynamic> authorPerformance;
  final AnalyticsSummary? authorSummary;
  final List<dynamic> authorPerformanceData;
  final List<dynamic> popularArticles;
  final List<TrendData> authorTrends;
  final bool isLoading;
  final String? error;

  const AnalyticsState({
    this.newsAnalytics = const [],
    this.newsSummary,
    this.newsTrends = const [],
    this.overallSummary,
    this.overallTrends = const [],
    this.popularNews = const [],
    this.categoryPerformance = const [],
    this.authorPerformance = const [],
    this.authorSummary,
    this.authorPerformanceData = const [],
    this.popularArticles = const [],
    this.authorTrends = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState.initial() : this();

  AnalyticsState copyWith({
    List<NewsAnalytics>? newsAnalytics,
    AnalyticsSummary? newsSummary,
    List<TrendData>? newsTrends,
    AnalyticsSummary? overallSummary,
    List<TrendData>? overallTrends,
    List<dynamic>? popularNews,
    List<dynamic>? categoryPerformance,
    List<dynamic>? authorPerformance,
    AnalyticsSummary? authorSummary,
    List<dynamic>? authorPerformanceData,
    List<dynamic>? popularArticles,
    List<TrendData>? authorTrends,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      newsAnalytics: newsAnalytics ?? this.newsAnalytics,
      newsSummary: newsSummary ?? this.newsSummary,
      newsTrends: newsTrends ?? this.newsTrends,
      overallSummary: overallSummary ?? this.overallSummary,
      overallTrends: overallTrends ?? this.overallTrends,
      popularNews: popularNews ?? this.popularNews,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
      authorPerformance: authorPerformance ?? this.authorPerformance,
      authorSummary: authorSummary ?? this.authorSummary,
      authorPerformanceData: authorPerformanceData ?? this.authorPerformanceData,
      popularArticles: popularArticles ?? this.popularArticles,
      authorTrends: authorTrends ?? this.authorTrends,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsProvider, AnalyticsState>((ref) {
  final dio = ref.read(dioProvider);
  return AnalyticsProvider(dio, scaffoldMessengerKey as Ref<Object?>);
});
