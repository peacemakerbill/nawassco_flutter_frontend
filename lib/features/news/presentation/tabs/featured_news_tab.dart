import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/providers/news_provider.dart';
import '../widgets/news_card.dart';

class FeaturedNewsTab extends ConsumerWidget {
  final List<NewsArticle> featuredNews;
  final VoidCallback onRefresh;

  const FeaturedNewsTab({
    super.key,
    required this.featuredNews,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (featuredNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No featured news',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Feature news articles to appear here',
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
        itemCount: featuredNews.length,
        itemBuilder: (context, index) {
          final article = featuredNews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NewsCard(
              article: article,
              onTap: () {
                // Navigate to detail screen
              },
              onToggleFeatured: () {
                _toggleFeatured(article.id, ref);
              },
            ),
          );
        },
      ),
    );
  }

  void _toggleFeatured(String id, WidgetRef ref) {
    ref.read(newsProvider.notifier).toggleFeatured(id);
  }
}