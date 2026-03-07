import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/news_provider.dart';
import '../widgets/news_card.dart';

class MyNewsTab extends ConsumerWidget {
  final String userId;
  final VoidCallback onRefresh;

  const MyNewsTab({
    super.key,
    required this.userId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    final myNews = newsState.newsList.where((article) => article.author.id == userId).toList();

    if (myNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No news articles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first news article',
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
        itemCount: myNews.length,
        itemBuilder: (context, index) {
          final article = myNews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NewsCard(
              article: article,
              onTap: () {
                // Navigate to detail screen
              },
              onEdit: () {
                // Navigate to editor
              },
              onDelete: () {
                _showDeleteDialog(context, article, ref);
              },
              onToggleFeatured: () {
                _toggleFeatured(article.id, ref);
              },
              onPublish: article.isPublished ? null : () {
                _publishArticle(article.id, ref);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic article, WidgetRef ref) {
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
              ref.read(newsProvider.notifier).deleteNews(article.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleFeatured(String id, WidgetRef ref) {
    ref.read(newsProvider.notifier).toggleFeatured(id);
  }

  void _publishArticle(String id, WidgetRef ref) {
    ref.read(newsProvider.notifier).publishNews(id);
  }
}