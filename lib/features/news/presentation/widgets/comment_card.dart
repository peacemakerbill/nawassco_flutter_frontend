import 'package:flutter/material.dart';
import '../../data/models/news_comment.dart';
import '../../utils/news_formatters.dart';

class CommentCard extends StatelessWidget {
  final NewsComment comment;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onFeature;
  final VoidCallback? onReply;
  final VoidCallback? onReport;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onTap,
    this.onApprove,
    this.onFeature,
    this.onReply,
    this.onReport,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
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
              // Header
              _buildHeader(),

              const SizedBox(height: 12),

              // Content
              _buildContent(),

              const SizedBox(height: 12),

              // Footer with actions
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
        // Author info
        Expanded(
          child: Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: comment.authorProfilePicture != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(comment.authorProfilePicture!),
                )
                    : const Icon(Icons.person, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    comment.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Status badges
        if (!comment.isApproved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              'PENDING',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        if (comment.isFeatured)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, size: 10, color: Colors.amber),
                SizedBox(width: 2),
                Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Action menu
        if (onApprove != null || onFeature != null || onDelete != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
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
        Text(
          comment.content,
          style: const TextStyle(fontSize: 13),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (comment.replies.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.reply, size: 12, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Stats
        Row(
          children: [
            _buildStatItem(Icons.thumb_up, comment.likes.length),
            const SizedBox(width: 12),
            _buildStatItem(Icons.thumb_down, comment.dislikes.length),
            const SizedBox(width: 12),
            if (comment.reportCount > 0)
              _buildStatItem(Icons.flag, comment.reportCount, Colors.red),
          ],
        ),

        const Spacer(),

        // Quick actions
        if (onReply != null)
          IconButton(
            onPressed: onReply,
            icon: const Icon(Icons.reply, size: 18, color: Colors.grey),
            tooltip: 'Reply',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

        if (onReport != null)
          IconButton(
            onPressed: onReport,
            icon: const Icon(Icons.flag, size: 18, color: Colors.grey),
            tooltip: 'Report',
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count, [Color? color]) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          NewsFormatters.formatNumber(count),
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey,
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    if (onApprove != null) {
      items.add(PopupMenuItem(
        value: 'approve',
        child: Row(
          children: [
            Icon(
              comment.isApproved ? Icons.block : Icons.check_circle,
              size: 16,
              color: comment.isApproved ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(comment.isApproved ? 'Unapprove' : 'Approve'),
          ],
        ),
      ));
    }

    if (onFeature != null) {
      items.add(PopupMenuItem(
        value: 'feature',
        child: Row(
          children: [
            Icon(
              comment.isFeatured ? Icons.star_border : Icons.star,
              size: 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(comment.isFeatured ? 'Unfeature' : 'Feature'),
          ],
        ),
      ));
    }

    if (onReport != null) {
      items.add(const PopupMenuItem(
        value: 'report',
        child: Row(
          children: [
            Icon(Icons.flag, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Report'),
          ],
        ),
      ));
    }

    if (onDelete != null) {
      items.add(const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 16, color: Colors.red),
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
      case 'approve':
        onApprove?.call();
        break;
      case 'feature':
        onFeature?.call();
        break;
      case 'report':
        onReport?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}