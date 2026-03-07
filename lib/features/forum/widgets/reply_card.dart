import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/forum_reply.dart';

class ReplyCard extends StatelessWidget {
  final ForumReply reply;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final bool isNested;

  const ReplyCard({
    super.key,
    required this.reply,
    required this.onReply,
    required this.onLike,
    this.isNested = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isNested ? 24 : 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B).withValues(alpha: isNested ? 0.4 : 0.6),
            const Color(0xFF0F172A).withValues(alpha: isNested ? 0.4 : 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: isNested
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Answer badge
          if (reply.isAnswer)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.2),
                      Colors.green.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Answer',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFF00CCFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: reply.authorAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(reply.authorAvatar!,
                                  fit: BoxFit.cover),
                            )
                          : const Icon(Icons.person,
                              size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatTimeAgo(reply.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edited indicator
                    if (reply.isEdited)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                size: 10, color: Colors.amber.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Text(
                              'Edited',
                              style: TextStyle(
                                color: Colors.amber.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Reply content
                MarkdownBody(
                  data: reply.content,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    a: const TextStyle(
                      color: Color(0xFF00CCFF),
                      decoration: TextDecoration.underline,
                    ),
                    code: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: onLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              reply.likesCount > 0 ? '${reply.likesCount}' : '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Reply button
                    GestureDetector(
                      onTap: onReply,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // More options
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: Colors.white.withValues(alpha: 0.5), size: 20),
                      onSelected: (value) {
                        // Handle menu selection
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Reply'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Reply'),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Report Reply'),
                        ),
                      ],
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                  ],
                ),

                // Mentioned users
                if (reply.mentionedUsers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    children: [
                      Icon(Icons.alternate_email,
                          size: 12, color: Colors.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        'Mentioned: ${reply.mentionedUsers.join(', ')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365)
      return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}
