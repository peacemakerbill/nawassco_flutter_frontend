import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../widgets/news_card.dart';

class BreakingNewsTab extends ConsumerWidget {
  final List<NewsArticle> breakingNews;
  final VoidCallback onRefresh;

  const BreakingNewsTab({
    super.key,
    required this.breakingNews,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (breakingNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notification_important, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No breaking news',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mark news articles as breaking to appear here',
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
        itemCount: breakingNews.length,
        itemBuilder: (context, index) {
          final article = breakingNews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NewsCard(
              article: article,
              onTap: () {
                // Navigate to detail screen
              },
            ),
          );
        },
      ),
    );
  }
}