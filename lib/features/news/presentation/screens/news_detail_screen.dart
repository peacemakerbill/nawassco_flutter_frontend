import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article.dart';
import '../../data/providers/comment_provider.dart';
import '../../data/providers/news_provider.dart';
import '../../utils/news_formatters.dart';
import '../widgets/comment_card.dart';
import '../../../../core/utils/toast_utils.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final String newsId;

  const NewsDetailScreen(NewsArticle article, {super.key, required this.newsId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  NewsArticle? _article;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadArticle();
    _loadComments();
  }

  Future<void> _loadArticle() async {
    setState(() => _isLoading = true);
    final article = await ref.read(newsProvider.notifier).fetchNewsById(widget.newsId);
    setState(() {
      _article = article;
      _isLoading = false;
    });
  }

  Future<void> _loadComments() async {
    await ref.read(commentProvider.notifier).fetchNewsComments(widget.newsId);
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final data = {
      'content': _commentController.text,
      'news': widget.newsId,
    };

    await ref.read(commentProvider.notifier).createComment(data);
    _commentController.clear();
    ToastUtils.showSuccessToast('Comment added');
  }

  Future<void> _shareArticle() async {
    if (_article == null) return;

    final url = 'https://yourdomain.com/news/${_article!.slug}';
    final text = 'Check out this article: ${_article!.title}';

    // In a real app, use share_plus package
    ToastUtils.showInfoToast('Share: $url');
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;

    try {
      if (!await launchUrl(Uri.parse(url))) {
        ToastUtils.showErrorToast('Could not launch URL');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Invalid URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Article Not Found'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Article not found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final article = _article!;
    final comments = ref.watch(commentProvider).comments
        .where((c) => c.newsId == widget.newsId && c.parentCommentId == null)
        .toList();

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroImage(article),
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                collapseMode: CollapseMode.pin,
              ),
              actions: [
                IconButton(
                  onPressed: _shareArticle,
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                ),
                IconButton(
                  onPressed: () {
                    // Bookmark functionality
                    ToastUtils.showInfoToast('Bookmark article');
                  },
                  icon: const Icon(Icons.bookmark_border),
                  tooltip: 'Bookmark',
                ),
                IconButton(
                  onPressed: () {
                    // More options
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article header
              _buildArticleHeader(article),

              const SizedBox(height: 24),

              // Article content
              _buildArticleContent(article),

              const SizedBox(height: 24),

              // Tags
              if (article.tags.isNotEmpty) _buildTags(article),

              const SizedBox(height: 32),

              // Comments section
              _buildCommentsSection(comments),
            ],
          ),
        ),
      ),

      // Comment input
      bottomSheet: _buildCommentInput(),
    );
  }

  Widget _buildHeroImage(NewsArticle article) {
    if (article.featuredImage != null) {
      return Image.network(
        article.featuredImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      color: Colors.blue[50],
      child: const Center(
        child: Icon(Icons.article, size: 64, color: Colors.blue),
      ),
    );
  }

  Widget _buildArticleHeader(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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

            if (article.isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            if (article.isBreaking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notification_important, size: 12, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'BREAKING',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            if (article.priority != NewsPriority.medium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: article.priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: article.priorityColor.withOpacity(0.3)),
                ),
                child: Text(
                  article.priorityLabel.toUpperCase(),
                  style: TextStyle(
                    color: article.priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Meta information
        Row(
          children: [
            // Author
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: article.author.profilePictureUrl != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(article.author.profilePictureUrl!),
                radius: 15,
              )
                  : Text(
                article.author.firstName[0],
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.author.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${article.formattedPublishedDate} • ${NewsFormatters.formatReadingTime(article.readingTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Stats
        Row(
          children: [
            _buildStatItem(Icons.remove_red_eye, article.views, 'views'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.thumb_up, article.likes.length, 'likes'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.comment, article.commentsCount, 'comments'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.share, article.shares, 'shares'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          NewsFormatters.formatNumber(count),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Text(
          article.summary,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 24),

        // Content
        HtmlContent(html: article.content),

        const SizedBox(height: 24),

        // Image gallery
        if (article.imageGallery.isNotEmpty) _buildImageGallery(article),

        // Attached files
        if (article.attachedFiles.isNotEmpty) _buildAttachedFiles(article),

        // Source attribution
        if (article.source != null) _buildSourceAttribution(article),
      ],
    );
  }

  Widget _buildImageGallery(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallery',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: article.imageGallery.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: EdgeInsets.only(
                  right: index < article.imageGallery.length - 1 ? 12 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageGallery[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttachedFiles(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Attachments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        ...article.attachedFiles.map((file) => ListTile(
          leading: const Icon(Icons.attach_file),
          title: Text(file.split('/').last),
          trailing: IconButton(
            onPressed: () => _launchUrl(file),
            icon: const Icon(Icons.download),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSourceAttribution(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Source',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.source!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (article.sourceUrl != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchUrl(article.sourceUrl),
                    child: Text(
                      article.sourceUrl!,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: article.tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: Colors.grey[100],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(List<dynamic> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),

        if (comments.isEmpty)
          const Center(
            child: Column(
              children: [
                Icon(Icons.comment, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No comments yet',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Be the first to comment',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ...comments.map((comment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CommentCard(
              comment: comment,
              onTap: () {
                // Show comment details
              },
              onReply: () {
                // Reply to comment
              },
              onReport: () {
                // Report comment
              },
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _addComment,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple HTML content widget (in a real app, use flutter_html or similar)
class HtmlContent extends StatelessWidget {
  final String html;

  const HtmlContent({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return Text(
      _stripHtml(html),
      style: const TextStyle(fontSize: 16, height: 1.6),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}