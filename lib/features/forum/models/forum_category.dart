class ForumCategory {
  final String id;
  final String name;
  final String description;
  final String slug;
  final String color;
  final String icon;
  final bool isPrivate;
  final int threadCount;
  final int replyCount;
  final DateTime? lastActivityAt;
  final List<String> accessRoles;
  final int order; // Add this field
  final bool isActive; // Add this field

  ForumCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    this.color = '#007bff',
    this.icon = 'chat',
    this.isPrivate = false,
    this.threadCount = 0,
    this.replyCount = 0,
    this.lastActivityAt,
    this.accessRoles = const [],
    this.order = 0, // Default order
    this.isActive = true, // Default active
  });

  factory ForumCategory.fromJson(Map<String, dynamic> json) {
    return ForumCategory(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      color: json['color'] ?? '#007bff',
      icon: json['icon'] ?? 'chat',
      isPrivate: json['isPrivate'] ?? false,
      threadCount: json['threadCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'])
          : null,
      accessRoles: List<String>.from(json['accessRoles'] ?? []),
      order: json['order'] ?? 0, // Parse order
      isActive: json['isActive'] ?? true, // Parse isActive
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'slug': slug,
    'color': color,
    'icon': icon,
    'isPrivate': isPrivate,
    'accessRoles': accessRoles,
    'order': order,
    'isActive': isActive,
  };
}