import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/comment_provider.dart';
import '../../data/models/news_comment.dart';
import '../widgets/comment_card.dart';
import '../../../../core/utils/toast_utils.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabTitles = ['All', 'Pending', 'Approved', 'Featured', 'Reported'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadComments();
  }

  Future<void> _loadComments() async {
    await ref.read(commentProvider.notifier).fetchComments();
  }

  void _onSearch(String query) {
    ref.read(commentProvider.notifier).searchComments(query);
  }

  void _showCommentDetails(NewsComment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentDetailSheet(comment: comment),
    );
  }

  void _showReplyDialog(String? parentCommentId, String newsId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reply'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addComment(
                  content: controller.text,
                  newsId: newsId,
                  parentCommentId: parentCommentId,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment({
    required String content,
    required String newsId,
    String? parentCommentId,
  }) async {
    final data = {
      'content': content,
      'news': newsId,
      if (parentCommentId != null) 'parentComment': parentCommentId,
    };

    await ref.read(commentProvider.notifier).createComment(data);
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentProvider);
    final comments = commentState.displayComments;

    // Filter comments based on selected tab
    final List<NewsComment> filteredComments;
    switch (_tabController.index) {
      case 1: // Pending
        filteredComments = comments.where((c) => !c.isApproved).toList();
        break;
      case 2: // Approved
        filteredComments = comments.where((c) => c.isApproved).toList();
        break;
      case 3: // Featured
        filteredComments = comments.where((c) => c.isFeatured).toList();
        break;
      case 4: // Reported
        filteredComments = comments.where((c) => c.reportCount > 0).toList();
        break;
      default: // All
        filteredComments = comments;
    }

    return Scaffold(
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search comments...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _loadComments,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats summary
                _buildCommentStats(commentState),
              ],
            ),
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),

          // Comments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              child: _buildCommentsList(filteredComments),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentStats(CommentState state) {
    final totalComments = state.comments.length;
    final approvedCount = state.comments.where((c) => c.isApproved).length;
    final pendingCount = totalComments - approvedCount;
    final reportedCount = state.comments.where((c) => c.reportCount > 0).length;
    final featuredCount = state.comments.where((c) => c.isFeatured).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatChip('Total', totalComments.toString(), Icons.comment),
          const SizedBox(width: 12),
          _buildStatChip('Approved', approvedCount.toString(), Icons.check_circle, Colors.green),
          const SizedBox(width: 12),
          _buildStatChip('Pending', pendingCount.toString(), Icons.pending, Colors.orange),
          const SizedBox(width: 12),
          _buildStatChip('Reported', reportedCount.toString(), Icons.flag, Colors.red),
          const SizedBox(width: 12),
          _buildStatChip('Featured', featuredCount.toString(), Icons.star, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<NewsComment> comments) {
    if (comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.comment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No comments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadComments,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CommentCard(
            comment: comment,
            onTap: () => _showCommentDetails(comment),
            onApprove: () => _toggleApproval(comment),
            onFeature: () => _toggleFeatured(comment),
            onReply: () => _showReplyDialog(comment.id, comment.newsId),
            onReport: () => _showReportDialog(comment),
            onDelete: () => _showDeleteDialog(comment),
          ),
        );
      },
    );
  }

  String _getEmptyStateMessage() {
    switch (_tabController.index) {
      case 1:
        return 'No pending comments to review';
      case 2:
        return 'No approved comments yet';
      case 3:
        return 'No featured comments yet';
      case 4:
        return 'No reported comments';
      default:
        return 'No comments found';
    }
  }

  void _toggleApproval(NewsComment comment) {
    ref.read(commentProvider.notifier).toggleApproval(comment.id);
  }

  void _toggleFeatured(NewsComment comment) {
    ref.read(commentProvider.notifier).toggleFeatured(comment.id);
  }

  void _showReportDialog(NewsComment comment) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reporting comment by ${comment.authorName}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Reason for reporting...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(commentProvider.notifier).reportComment(
                  comment.id,
                  'current-user-id', // Replace with actual user ID
                  controller.text,
                );
                Navigator.pop(context);
                ToastUtils.showSuccessToast('Comment reported');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NewsComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment by ${comment.authorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(commentProvider.notifier).deleteComment(comment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class CommentDetailSheet extends ConsumerWidget {
  final NewsComment comment;

  const CommentDetailSheet({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Author avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: comment.authorProfilePicture != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(comment.authorProfilePicture!),
                )
                    : const Icon(Icons.person, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      comment.formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Comment content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStatItem(Icons.thumb_up, comment.likes.length.toString()),
              const SizedBox(width: 16),
              _buildStatItem(Icons.thumb_down, comment.dislikes.length.toString()),
              const SizedBox(width: 16),
              _buildStatItem(Icons.comment, comment.replies.length.toString()),
              const SizedBox(width: 16),
              _buildStatItem(Icons.flag, comment.reportCount.toString(), Colors.red),
              const Spacer(),
              if (comment.sentiment != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: comment.sentimentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: comment.sentimentColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    comment.sentiment!.name.toUpperCase(),
                    style: TextStyle(
                      color: comment.sentimentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Status badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (comment.isEdited)
                _buildStatusChip('Edited', Icons.edit, Colors.blue),
              if (comment.isApproved)
                _buildStatusChip('Approved', Icons.check_circle, Colors.green),
              if (!comment.isApproved)
                _buildStatusChip('Pending', Icons.pending, Colors.orange),
              if (comment.isFeatured)
                _buildStatusChip('Featured', Icons.star, Colors.amber),
              if (comment.reportCount > 0)
                _buildStatusChip('Reported', Icons.flag, Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          // Reports (if any)
          if (comment.reports.isNotEmpty) _buildReportsSection(),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(commentProvider.notifier).likeComment(comment.id);
                  },
                  icon: const Icon(Icons.thumb_up),
                  label: Text('Like (${comment.likes.length})'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(commentProvider.notifier).dislikeComment(comment.id);
                  },
                  icon: const Icon(Icons.thumb_down),
                  label: Text('Dislike (${comment.dislikes.length})'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(commentProvider.notifier).toggleApproval(comment.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    comment.isApproved ? Icons.block : Icons.check_circle,
                    color: comment.isApproved ? Colors.orange : Colors.green,
                  ),
                  label: Text(comment.isApproved ? 'Unapprove' : 'Approve'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(commentProvider.notifier).toggleFeatured(comment.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: comment.isFeatured ? Colors.grey : Colors.amber,
                  ),
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: Text(
                    comment.isFeatured ? 'Unfeature' : 'Feature',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, [Color? color]) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 8),
        ...comment.reports.take(3).map((report) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.reason,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Reported ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )).toList(),

        if (comment.reports.length > 3)
          Text(
            '+ ${comment.reports.length - 3} more reports...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}