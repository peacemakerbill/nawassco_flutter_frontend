class ForumReply {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String threadId;
  final String? parentReplyId;
  final bool isEdited;
  final bool isApproved;
  final bool isAnswer;
  final int likesCount;
  final List<String> mentionedUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumReply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.threadId,
    this.parentReplyId,
    this.isEdited = false,
    this.isApproved = true,
    this.isAnswer = false,
    this.likesCount = 0,
    this.mentionedUsers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['_id'] ?? json['id'],
      content: json['content'],
      authorId: json['author']['_id'] ?? json['authorId'],
      authorName: '${json['author']['firstName']} ${json['author']['lastName']}',
      authorAvatar: json['author']['profilePictureUrl'],
      threadId: json['thread']['_id'] ?? json['threadId'],
      parentReplyId: json['parentReply'],
      isEdited: json['isEdited'] ?? false,
      isApproved: json['isApproved'] ?? true,
      isAnswer: json['isAnswer'] ?? false,
      likesCount: json['likes'] != null
          ? (json['likes'] as List).length
          : (json['likesCount'] ?? 0),
      mentionedUsers: List<String>.from(json['mentionedUsers'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}