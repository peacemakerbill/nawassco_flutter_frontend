import 'package:flutter/material.dart';
import '../../data/models/news_article.dart';
import '../../utils/news_formatters.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFeatured;
  final VoidCallback? onPublish;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFeatured,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and actions
              _buildHeader(),

              const SizedBox(height: 12),

              // Title and summary
              _buildContent(),

              const SizedBox(height: 16),

              // Footer with metadata and actions
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: article.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: article.statusColor.withOpacity(0.3)),
          ),
          child: Text(
            article.statusLabel,
            style: TextStyle(
              color: article.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Spacer(),

        // Priority badge
        if (article.priority != NewsPriority.medium)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: article.priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: article.priorityColor.withOpacity(0.3)),
            ),
            child: Text(
              article.priorityLabel,
              style: TextStyle(
                color: article.priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Featured badge
        if (article.isFeatured)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Breaking badge
        if (article.isBreaking)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notification_important, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Breaking',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Action buttons
        if (onEdit != null || onDelete != null || onToggleFeatured != null || onPublish != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => _buildMenuItems(),
            onSelected: (value) => _handleMenuSelection(value),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Summary
        Text(
          article.summary,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 12),

        // Featured image
        if (article.featuredImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              article.featuredImage!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: article.category.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(article.category.categoryIcon, size: 12, color: article.category.categoryColor),
              const SizedBox(width: 4),
              Text(
                article.category.name,
                style: TextStyle(
                  color: article.category.categoryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Author
        Row(
          children: [
            const Icon(Icons.person_outline, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              article.author.fullName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Stats
        Row(
          children: [
            // Views
            _buildStatItem(Icons.remove_red_eye, article.views),
            const SizedBox(width: 12),

            // Likes
            _buildStatItem(Icons.thumb_up, article.likes.length),
            const SizedBox(width: 12),

            // Comments
            _buildStatItem(Icons.comment, article.commentsCount),
            const SizedBox(width: 12),

            // Published date
            Text(
              article.formattedPublishedDate,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          NewsFormatters.formatNumber(count),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    if (onEdit != null) {
      items.add(const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ));
    }

    if (onToggleFeatured != null) {
      items.add(PopupMenuItem(
        value: 'toggle_featured',
        child: Row(
          children: [
            Icon(article.isFeatured ? Icons.star_border : Icons.star, size: 18),
            const SizedBox(width: 8),
            Text(article.isFeatured ? 'Unfeature' : 'Feature'),
          ],
        ),
      ));
    }

    if (onPublish != null && !article.isPublished) {
      items.add(const PopupMenuItem(
        value: 'publish',
        child: Row(
          children: [
            Icon(Icons.publish, size: 18),
            SizedBox(width: 8),
            Text('Publish'),
          ],
        ),
      ));
    }

    if (onDelete != null) {
      items.add(const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ));
    }

    return items;
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        onEdit?.call();
        break;
      case 'toggle_featured':
        onToggleFeatured?.call();
        break;
      case 'publish':
        onPublish?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}