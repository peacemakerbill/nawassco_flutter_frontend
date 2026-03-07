import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/services/api_service.dart';
import '../models/news_comment.dart';

class CommentProvider extends StateNotifier<CommentState> {
  final Dio dio;
  final Ref ref;

  CommentProvider(this.dio, this.ref) : super(CommentState.initial());

  Future<void> fetchComments({CommentQuery? query}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get(
        '/v1/nawassco/news/news-comments',
        queryParameters: query?.toQueryParams(),
      );

      final data = response.data['data'];
      final comments = (data['comments'] as List).map((item) => NewsComment.fromJson(item)).toList();

      state = state.copyWith(
        comments: comments,
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
        error: e.response?.data['message'] ?? e.message ?? 'Failed to fetch comments',
      );
      ToastUtils.showErrorToast('Failed to load comments');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch comments',
      );
      ToastUtils.showErrorToast('Failed to load comments');
    }
  }

  Future<NewsComment?> fetchCommentById(String id) async {
    try {
      final response = await dio.get('/v1/nawassco/news/news-comments/$id');
      final data = response.data['data']['comment'];
      return NewsComment.fromJson(data);
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to fetch comment');
      return null;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to fetch comment');
      return null;
    }
  }

  Future<List<NewsComment>> fetchNewsComments(String newsId, {int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-comments/news/$newsId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data']['comments'] as List;
      return data.map((item) => NewsComment.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<NewsComment>> fetchCommentReplies(String commentId, {int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/v1/nawassco/news/news-comments/$commentId/replies',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data']['comments'] as List;
      return data.map((item) => NewsComment.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<NewsComment?> createComment(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.post(
        '/v1/nawassco/news/news-comments',
        data: data,
      );

      final commentData = response.data['data']['comment'];
      final newComment = NewsComment.fromJson(commentData);

      state = state.copyWith(
        comments: [...state.comments, newComment],
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Comment posted successfully');
      return newComment;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to create comment',
      );
      ToastUtils.showErrorToast('Failed to post comment');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create comment',
      );
      ToastUtils.showErrorToast('Failed to post comment');
      return null;
    }
  }

  Future<NewsComment?> updateComment(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.put(
        '/v1/nawassco/news/news-comments/$id',
        data: data,
      );

      final commentData = response.data['data']['comment'];
      final updatedComment = NewsComment.fromJson(commentData);

      state = state.copyWith(
        comments: state.comments.map((c) => c.id == id ? updatedComment : c).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Comment updated successfully');
      return updatedComment;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to update comment',
      );
      ToastUtils.showErrorToast('Failed to update comment');
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update comment',
      );
      ToastUtils.showErrorToast('Failed to update comment');
      return null;
    }
  }

  Future<bool> deleteComment(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await dio.delete('/v1/nawassco/news/news-comments/$id');

      state = state.copyWith(
        comments: state.comments.where((c) => c.id != id).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast('Comment deleted successfully');
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to delete comment',
      );
      ToastUtils.showErrorToast('Failed to delete comment');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete comment',
      );
      ToastUtils.showErrorToast('Failed to delete comment');
      return false;
    }
  }

  Future<bool> toggleApproval(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news-comments/$id/toggle-approval');

      final commentData = response.data['data']['comment'];
      final updatedComment = NewsComment.fromJson(commentData);

      state = state.copyWith(
        comments: state.comments.map((c) => c.id == id ? updatedComment : c).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
          updatedComment.isApproved ? 'Comment approved' : 'Comment unapproved'
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to toggle approval',
      );
      ToastUtils.showErrorToast('Failed to toggle approval');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle approval',
      );
      ToastUtils.showErrorToast('Failed to toggle approval');
      return false;
    }
  }

  Future<bool> toggleFeatured(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/news/news-comments/$id/toggle-featured');

      final commentData = response.data['data']['comment'];
      final updatedComment = NewsComment.fromJson(commentData);

      state = state.copyWith(
        comments: state.comments.map((c) => c.id == id ? updatedComment : c).toList(),
        isLoading: false,
      );

      ToastUtils.showSuccessToast(
          updatedComment.isFeatured ? 'Comment featured' : 'Comment unfeatured'
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'Failed to toggle featured',
      );
      ToastUtils.showErrorToast('Failed to toggle featured');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle featured',
      );
      ToastUtils.showErrorToast('Failed to toggle featured');
      return false;
    }
  }

  Future<bool> likeComment(String commentId) async {
    try {
      await dio.post('/v1/nawassco/news/news-comments/$commentId/like');

      // Update local state
      final index = state.comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = state.comments[index];
        state = state.copyWith(
          comments: [
            ...state.comments.sublist(0, index),
            comment.copyWith(likes: [...comment.likes, 'current-user-id']), // Replace with actual user ID
            ...state.comments.sublist(index + 1),
          ],
        );
      }

      ToastUtils.showSuccessToast('Comment liked');
      return true;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to like comment');
      return false;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to like comment');
      return false;
    }
  }

  Future<bool> dislikeComment(String commentId) async {
    try {
      await dio.post('/v1/nawassco/news/news-comments/$commentId/dislike');

      // Update local state
      final index = state.comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = state.comments[index];
        state = state.copyWith(
          comments: [
            ...state.comments.sublist(0, index),
            comment.copyWith(dislikes: [...comment.dislikes, 'current-user-id']), // Replace with actual user ID
            ...state.comments.sublist(index + 1),
          ],
        );
      }

      ToastUtils.showSuccessToast('Comment disliked');
      return true;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to dislike comment');
      return false;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to dislike comment');
      return false;
    }
  }

  Future<bool> reportComment(String commentId, String reason, String text) async {
    try {
      await dio.post(
        '/v1/nawassco/news/news-comments/$commentId/report',
        data: {'reason': reason},
      );

      ToastUtils.showSuccessToast('Comment reported');
      return true;
    } on DioException catch (e) {
      ToastUtils.showErrorToast(e.response?.data['message'] ?? 'Failed to report comment');
      return false;
    } catch (e) {
      ToastUtils.showErrorToast('Failed to report comment');
      return false;
    }
  }

  // Filter methods
  List<NewsComment> getApprovedComments() {
    return state.comments.where((c) => c.isApproved).toList();
  }

  List<NewsComment> getPendingComments() {
    return state.comments.where((c) => !c.isApproved).toList();
  }

  List<NewsComment> getFeaturedComments() {
    return state.comments.where((c) => c.isFeatured).toList();
  }

  List<NewsComment> getCommentsByNews(String newsId) {
    return state.comments.where((c) => c.newsId == newsId).toList();
  }

  List<NewsComment> getParentComments() {
    return state.comments.where((c) => c.parentCommentId == null).toList();
  }

  List<NewsComment> getReplies(String commentId) {
    return state.comments.where((c) => c.parentCommentId == commentId).toList();
  }

  void searchComments(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredComments: null);
      return;
    }

    final filtered = state.comments.where((comment) {
      return comment.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(filteredComments: filtered);
  }

  void clearFilters() {
    state = state.copyWith(filteredComments: null);
  }
}

class CommentState {
  final List<NewsComment> comments;
  final List<NewsComment>? filteredComments;
  final bool isLoading;
  final String? error;
  final PaginationInfo? pagination;

  const CommentState({
    this.comments = const [],
    this.filteredComments,
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  CommentState.initial() : this();

  CommentState copyWith({
    List<NewsComment>? comments,
    List<NewsComment>? filteredComments,
    bool? isLoading,
    String? error,
    PaginationInfo? pagination,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      filteredComments: filteredComments ?? this.filteredComments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }

  List<NewsComment> get displayComments => filteredComments ?? comments;
}

class CommentQuery {
  final int? page;
  final int? limit;
  final String? news;
  final String? author;
  final String? parentComment;
  final bool? isApproved;
  final bool? isFeatured;
  final String? sentiment;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const CommentQuery({
    this.page,
    this.limit,
    this.news,
    this.author,
    this.parentComment,
    this.isApproved,
    this.isFeatured,
    this.sentiment,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (news != null) params['news'] = news;
    if (author != null) params['author'] = author;
    if (parentComment != null) params['parentComment'] = parentComment;
    if (isApproved != null) params['isApproved'] = isApproved;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (sentiment != null) params['sentiment'] = sentiment;
    if (search != null) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;

    return params;
  }
}

final commentProvider = StateNotifierProvider<CommentProvider, CommentState>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentProvider(dio, ref);
});