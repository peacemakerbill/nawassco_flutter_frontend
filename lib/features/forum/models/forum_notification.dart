class ForumNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final String status;
  final bool isActionable;
  final String? actionUrl;
  final DateTime createdAt;

  ForumNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data = const {},
    this.status = 'unread',
    this.isActionable = false,
    this.actionUrl,
    required this.createdAt,
  });

  factory ForumNotification.fromJson(Map<String, dynamic> json) {
    return ForumNotification(
      id: json['_id'] ?? json['id'],
      userId: json['user'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      status: json['status'] ?? 'unread',
      isActionable: json['isActionable'] ?? false,
      actionUrl: json['actionUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isUnread => status == 'unread';
}