import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/providers/news_provider.dart';
import '../screens/news_detail_screen.dart';
import '../screens/news_editor_screen.dart';
import '../widgets/news_card.dart';

class AllNewsTab extends ConsumerWidget {
  final List<NewsArticle> news;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AllNewsTab({
    super.key,
    required this.news,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && news.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.newspaper, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No news articles found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first news article to get started',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final article = news[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NewsCard(
              article: article,
              onTap: () {
                // Navigate to detail screen
                _navigateToDetail(context, article);
              },
              onEdit: () {
                // Navigate to editor
                _navigateToEditor(context, article);
              },
              onDelete: () {
                // Show delete confirmation
                _showDeleteDialog(context, article, ref);
              },
              onToggleFeatured: () {
                _toggleFeatured(article.id, ref);
              },
              onPublish: () {
                _publishArticle(article.id, ref);
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, NewsArticle article) {
    // Navigate to news detail screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen( article, newsId: '',)));
  }

  void _navigateToEditor(BuildContext context, NewsArticle article) {
    // Navigate to news editor
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEditorScreen(article: article)));
  }

  void _showDeleteDialog(BuildContext context, NewsArticle article, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News Article'),
        content: Text('Are you sure you want to delete "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteArticle(article.id, context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteArticle(String id, BuildContext context, WidgetRef ref) {
    ref.read(newsProvider.notifier).deleteNews(id);
  }

  void _toggleFeatured(String id, WidgetRef ref) {
    ref.read(newsProvider.notifier).toggleFeatured(id);
  }

  void _publishArticle(String id, WidgetRef ref) {
    ref.read(newsProvider.notifier).publishNews(id);
  }
}