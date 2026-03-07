class ForumThread {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String categoryId;
  final String categoryName;
  final List<String> tags;
  final String status;
  final bool isSticky;
  final bool isLocked;
  final bool isApproved;
  final bool isFeatured;
  final int views;
  final int replyCount;
  final int likesCount;
  final DateTime? lastReplyAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasPoll;
  final bool hasAttachments;

  ForumThread({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.categoryId,
    required this.categoryName,
    this.tags = const [],
    this.status = 'active',
    this.isSticky = false,
    this.isLocked = false,
    this.isApproved = true,
    this.isFeatured = false,
    this.views = 0,
    this.replyCount = 0,
    this.likesCount = 0,
    this.lastReplyAt,
    required this.createdAt,
    required this.updatedAt,
    this.hasPoll = false,
    this.hasAttachments = false,
  });

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    return ForumThread(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      authorId: json['author']?['_id'] ?? json['authorId'] ?? '',
      authorName: json['author'] != null
          ? '${json['author']['firstName'] ?? ''} ${json['author']['lastName'] ?? ''}'
              .trim()
          : json['authorName'] ?? '',
      authorAvatar: json['author']?['profilePictureUrl'],
      categoryId: json['category']?['_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category']?['name'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? 'active',
      isSticky: json['isSticky'] ?? false,
      isLocked: json['isLocked'] ?? false,
      isApproved: json['isApproved'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      views: json['views'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      likesCount: json['likes'] != null
          ? (json['likes'] as List).length
          : (json['likesCount'] ?? 0),
      lastReplyAt: json['lastReplyAt'] != null
          ? DateTime.tryParse(json['lastReplyAt'].toString())
          : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      hasPoll: json['poll'] != null,
      hasAttachments: (json['attachments'] as List?)?.isNotEmpty ?? false,
    );
  }
}
