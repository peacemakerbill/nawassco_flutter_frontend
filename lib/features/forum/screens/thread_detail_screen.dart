import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forum_thread.dart';
import '../providers/forum_provider.dart';
import '../widgets/reply_card.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  final String threadSlug;
  final VoidCallback onBack;

  const ThreadDetailScreen({
    super.key,
    required this.threadSlug,
    required this.onBack,
  });

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isSubmittingReply = false;
  bool _showReplyBox = false;
  String? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  Future<void> _loadThread() async {
    final thread = await ref.read(forumProvider.notifier).fetchThreadBySlug(widget.threadSlug);
    if (thread != null) {
      ref.read(forumProvider.notifier).fetchThreadReplies(thread.id);
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSubmittingReply = true);

    final thread = await ref.read(forumProvider.notifier).fetchThreadBySlug(widget.threadSlug);
    if (thread == null) return;

    final replyData = {
      'content': _replyController.text,
      'thread': thread.id,
      if (_replyingTo != null) 'parentReply': _replyingTo,
    };

    final success = await ref.read(forumProvider.notifier).createReply(replyData);

    if (success) {
      _replyController.clear();
      setState(() {
        _showReplyBox = false;
        _replyingTo = null;
        _isSubmittingReply = false;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      setState(() => _isSubmittingReply = false);
    }
  }

  void _scrollToReplyBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(forumProvider.select((state) {
      return state.threads.firstWhere(
            (t) => t.slug == widget.threadSlug,
        orElse: () => state.threads.firstWhere(
              (t) => t.id == state.selectedThreadId,
          orElse: () => ForumThread(
            id: '',
            title: 'Loading...',
            slug: widget.threadSlug,
            content: '',
            excerpt: '',
            authorId: '',
            authorName: '',
            categoryId: '',
            categoryName: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }));

    final replies = ref.watch(forumProvider.select((state) {
      return state.threadReplies[thread.id] ?? [];
    }));

    final isLoading = ref.watch(forumProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: widget.onBack,
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  // Bookmark thread
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  // Share thread
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.8),
                      const Color(0xFF0066FF).withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Thread content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thread header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E293B).withValues(alpha: 0.8),
                          const Color(0xFF0F172A).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0066FF).withValues(alpha: 0.2),
                                    const Color(0xFF00CCFF).withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0066FF).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                thread.categoryName,
                                style: const TextStyle(
                                  color: Color(0xFF00CCFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (thread.isSticky)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.push_pin, size: 12, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sticky',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          thread.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Author info
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF0066FF), Color(0xFF00CCFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: thread.authorAvatar != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(thread.authorAvatar!, fit: BoxFit.cover),
                              )
                                  : const Icon(Icons.person, size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread.authorName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Posted ${_formatTimeAgo(thread.createdAt)}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Stats
                            Row(
                              children: [
                                _buildThreadStat(Icons.remove_red_eye, '${thread.views}'),
                                const SizedBox(width: 16),
                                _buildThreadStat(Icons.chat_bubble_outline, '${thread.replyCount}'),
                                const SizedBox(width: 16),
                                _buildThreadStat(Icons.favorite_border, '${thread.likesCount}'),
                              ],
                            ),
                          ],
                        ),

                        // Tags
                        if (thread.tags.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: thread.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Thread content
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E293B).withValues(alpha: 0.6),
                          const Color(0xFF0F172A).withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: MarkdownBody(
                      data: thread.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        h1: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        h2: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        h3: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        a: const TextStyle(
                          color: Color(0xFF00CCFF),
                          decoration: TextDecoration.underline,
                        ),
                        code: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          fontSize: 14,
                        ),
                        blockquote: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                          backgroundColor: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Thread actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E293B).withValues(alpha: 0.4),
                          const Color(0xFF0F172A).withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildThreadAction(
                          Icons.favorite_border,
                          'Like',
                              () => ref.read(forumProvider.notifier).toggleThreadLike(thread.id),
                        ),
                        _buildThreadAction(
                          Icons.chat_bubble_outline,
                          'Reply',
                              () {
                            setState(() {
                              _showReplyBox = true;
                              _replyingTo = null;
                            });
                            _scrollToReplyBox();
                          },
                        ),
                        _buildThreadAction(
                          Icons.bookmark_border,
                          'Bookmark',
                              () {},
                        ),
                        _buildThreadAction(
                          Icons.share,
                          'Share',
                              () {},
                        ),
                        _buildThreadAction(
                          Icons.flag,
                          'Report',
                              () {},
                        ),
                      ],
                    ),
                  ),

                  // Replies header
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Replies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          '${replies.length} ${replies.length == 1 ? 'Reply' : 'Replies'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Replies list
          if (replies.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final reply = replies[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, index == replies.length - 1 ? 24 : 12),
                    child: ReplyCard(
                      reply: reply,
                      onReply: () {
                        setState(() {
                          _showReplyBox = true;
                          _replyingTo = reply.id;
                        });
                        _scrollToReplyBox();
                      },
                      onLike: () {
                        // Handle like
                      },
                    ),
                  );
                },
                childCount: replies.length,
              ),
            )
          else if (!isLoading)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No replies yet. Be the first to reply!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Reply box
          if (_showReplyBox)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: _buildReplyBox(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThreadStat(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildThreadAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBox() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.8),
            const Color(0xFF0F172A).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.reply, color: Color(0xFF00CCFF), size: 20),
                const SizedBox(width: 8),
                Text(
                  _replyingTo != null ? 'Replying to post' : 'Write a reply',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showReplyBox = false;
                      _replyingTo = null;
                      _replyController.clear();
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _replyingTo != null
                    ? 'Write your reply here...'
                    : 'Share your thoughts on this topic...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00CCFF), width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showReplyBox = false;
                        _replyingTo = null;
                        _replyController.clear();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmittingReply ? null : _submitReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFF0066FF).withValues(alpha: 0.5),
                    ),
                    child: _isSubmittingReply
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Post Reply',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}