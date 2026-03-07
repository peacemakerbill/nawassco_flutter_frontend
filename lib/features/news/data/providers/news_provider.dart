import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/services/api_service.dart';
import '../models/news_article.dart';

class NewsProvider extends StateNotifier<NewsState> {
  final Dio dio;
  final Ref ref;

  NewsProvider(this.dio, this.ref) : super(NewsState.initial());

  Future<void> fetchNews({NewsQuery? query}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news',
        queryParameters: query?.toQueryParams(),
      );

      final data = response.data['data'];
      final news = (data['news'] as List).map((item) => NewsArticle.fromJson(item)).toList();

      state = state.copyWith(
        newsList: news,
        isLoading: false,
        pagination: PaginationInfo(
          page: data['pagination']['page'] ?? 1,
          limit: data['pagination']['limit'] ?? 10,
          total: data['pagination']['total'] ?? 0,
          pages: data['pagination']['screens'] ?? 1,
        ),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch news',
      );
      ToastUtils.showErrorToast('Failed to load news');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch news',
      );
      ToastUtils.showErrorToast('Failed to load news');
    }
  }

  Future<NewsArticle?> fetchNewsById(String id) async {
    try {
      final response = await dio.get('/v1/nawassco/news/news/$id');
      final data = response.data['data']['news'];
      return NewsArticle.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch news');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch news');
      return null;
    }
  }

  Future<NewsArticle?> fetchNewsBySlug(String slug) async {
    try {
      final response = await dio.get('/v1/nawassco/news/news/slug/$slug');
      final data = response.data['data']['news'];
      return NewsArticle.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch news');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch news');
      return null;
    }
  }

  Future<NewsArticle?> createNews(Map<String, dynamic> data, List<MultipartFile>? files) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final formData = FormData.fromMap(data);
      if (files != null) {
        for (final file in files) {
          formData.files.add(MapEntry('files', file));
        }
      }

      final response = await dio.post(
        '/v1/nawassco/news/news',
        data: formData,
      );

      final newsData = response.data['data']['news'];
      final newNews = NewsArticle.fromJson(newsData);

      state = state.copyWith(
        newsList: [...state.newsList, newNews],
        isLoading: false,
      );

      ToastUtils.showSuccessToast('News article created successfully');
      return newNews;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to create news',
      );
      ToastUtils.showErrorToast('Failed to create news');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create news',
      );
      ToastUtils.showErrorToast('Failed to create news');
      return null;
    }
  }

  Future<NewsArticle?> updateNews(String id, Map<String, dynamic> data, List<MultipartFile>? files) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final formData = FormData.fromMap(data);
      if (files != null) {
        for (final file in files) {
          formData.files.add(MapEntry('files', file));
        }
      }

      final response = await dio.put(
        '/v1/nawassco/news/news/$id',
        data: formData,
      );

      final newsData = response.data['data']['news'];
      final updatedNews = NewsArticle.fromJson(newsData);

      state = state.copyWith(
        newsList: state.newsList.map((n) => n.id == id ? updatedNews : n).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('News article updated successfully');
      return updatedNews;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to update news',
      );
      ToastUtils.showErrorToast('Failed to update news');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update news',
      );
      ToastUtils.showErrorToast('Failed to update news');
      return null;
    }
  }

  Future<bool> deleteNews(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/v1/nawassco/news/news/$id');

      state = state.copyWith(
        newsList: state.newsList.where((n) => n.id != id).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('News article deleted successfully');
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to delete news',
      );
      ToastUtils.showErrorToast('Failed to delete news');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete news',
      );
      ToastUtils.showErrorToast('Failed to delete news');
      return false;
    }
  }

  Future<bool> publishNews(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news/$id/publish');

      final newsData = response.data['data']['news'];
      final updatedNews = NewsArticle.fromJson(newsData);

      state = state.copyWith(
        newsList: state.newsList.map((n) => n.id == id ? updatedNews : n).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('News published successfully');
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to publish news',
      );
      ToastUtils.showErrorToast('Failed to publish news');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to publish news',
      );
      ToastUtils.showErrorToast('Failed to publish news');
      return false;
    }
  }

  Future<bool> toggleFeatured(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news/$id/feature');

      final newsData = response.data['data']['news'];
      final updatedNews = NewsArticle.fromJson(newsData);

      state = state.copyWith(
        newsList: state.newsList.map((n) => n.id == id ? updatedNews : n).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
          updatedNews.isFeatured ? 'News featured successfully' : 'News unfeatured successfully'
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to toggle feature',
      );
      ToastUtils.showErrorToast('Failed to toggle feature');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle feature',
      );
      ToastUtils.showErrorToast('Failed to toggle feature');
      return false;
    }
  }

  Future<bool> addReaction(String newsId, String reaction) async {
    try {
      await dio.post(
        '/v1/nawassco/news/news/$newsId/reactions',
        data: {'reaction': reaction},
      );

      // Update local state
      final index = state.newsList.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        final news = state.newsList[index];
        state = state.copyWith(
          newsList: [
            ...state.newsList.sublist(0, index),
            news.copyWith(likes: [...news.likes, 'current-user-id']), // Replace with actual user ID
            ...state.newsList.sublist(index + 1),
          ],
        );
      }

      return true;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to add reaction');
      return false;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to add reaction');
      return false;
    }
  }

  Future<void> fetchFeaturedNews() async {
    try {
      final response = await dio.get('/v1/nawassco/news/news/featured');
      final data = response.data['data']['news'] as List;
      final featuredNews = data.map((item) => NewsArticle.fromJson(item)).toList();

      state = state.copyWith(featuredNews: featuredNews);
    } catch (e) {
      // Silently fail for featured news
    }
  }

  Future<void> fetchBreakingNews() async {
    try {
      final response = await dio.get('/v1/nawassco/news/news/breaking');
      final data = response.data['data']['news'] as List;
      final breakingNews = data.map((item) => NewsArticle.fromJson(item)).toList();

      state = state.copyWith(breakingNews: breakingNews);
    } catch (e) {
      // Silently fail for breaking news
    }
  }

  // Filter methods
  List<NewsArticle> getPublishedNews() {
    return state.newsList.where((news) => news.isPublished).toList();
  }

  List<NewsArticle> getDraftNews() {
    return state.newsList.where((news) => news.isDraft).toList();
  }

  List<NewsArticle> getPendingNews() {
    return state.newsList.where((news) => news.isPendingReview).toList();
  }

  List<NewsArticle> getScheduledNews() {
    return state.newsList.where((news) => news.isScheduled).toList();
  }

  List<NewsArticle> getFeaturedNewsList() {
    return state.newsList.where((news) => news.isFeatured).toList();
  }

  List<NewsArticle> getBreakingNewsList() {
    return state.newsList.where((news) => news.isBreaking).toList();
  }

  void filterByCategory(String categoryId) {
    state = state.copyWith(
      filteredNews: state.newsList.where((news) => news.category.id == categoryId).toList(),
    );
  }

  void filterByTag(String tag) {
    state = state.copyWith(
      filteredNews: state.newsList.where((news) => news.tags.contains(tag)).toList(),
    );
  }

  void searchNews(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredNews: null);
      return;
    }

    final filtered = state.newsList.where((news) {
      return news.title.toLowerCase().contains(query.toLowerCase()) ||
          news.summary.toLowerCase().contains(query.toLowerCase()) ||
          news.content.toLowerCase().contains(query.toLowerCase()) ||
          news.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    state = state.copyWith(filteredNews: filtered);
  }

  void clearFilters() {
    state = state.copyWith(filteredNews: null);
  }
}

class NewsState {
  final List<NewsArticle> newsList;
  final List<NewsArticle>? filteredNews;
  final List<NewsArticle> featuredNews;
  final List<NewsArticle> breakingNews;
  final bool isLoading;
  final String? error;
  final PaginationInfo? pagination;

  const NewsState({
    this.newsList = const [],
    this.filteredNews,
    this.featuredNews = const [],
    this.breakingNews = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  NewsState.initial() : this();

  NewsState copyWith({
    List<NewsArticle>? newsList,
    List<NewsArticle>? filteredNews,
    List<NewsArticle>? featuredNews,
    List<NewsArticle>? breakingNews,
    bool? isLoading,
    String? error,
    PaginationInfo? pagination,
  }) {
    return NewsState(
      newsList: newsList ?? this.newsList,
      filteredNews: filteredNews ?? this.filteredNews,
      featuredNews: featuredNews ?? this.featuredNews,
      breakingNews: breakingNews ?? this.breakingNews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }

  List<NewsArticle> get displayNews => filteredNews ?? newsList;
}

class NewsQuery {
  final int? page;
  final int? limit;
  final String? category;
  final String? author;
  final String? status;
  final bool? isFeatured;
  final bool? isBreaking;
  final String? tag;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
  final DateTime? fromDate;
  final DateTime? toDate;

  const NewsQuery({
    this.page,
    this.limit,
    this.category,
    this.author,
    this.status,
    this.isFeatured,
    this.isBreaking,
    this.tag,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (category != null) params['category'] = category;
    if (author != null) params['author'] = author;
    if (status != null) params['status'] = status;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (isBreaking != null) params['isBreaking'] = isBreaking;
    if (tag != null) params['tag'] = tag;
    if (search != null) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (fromDate != null) params['fromDate'] = fromDate!.toIso8601String();
    if (toDate != null) params['toDate'] = toDate!.toIso8601String();

    return params;
  }
}

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

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

// Provider declaration
final newsProvider = StateNotifierProvider<NewsProvider, NewsState>((ref) {
  final dio = ref.read(dioProvider);
  return NewsProvider(dio, ref);
});