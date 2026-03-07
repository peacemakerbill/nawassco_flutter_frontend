class PortfolioModel {
  final String? id;
  final String platform;
  final String url;
  final String? username;
  final bool isPrimary;

  PortfolioModel({
    this.id,
    required this.platform,
    required this.url,
    this.username,
    this.isPrimary = false,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['_id'],
      platform: json['platform'],
      url: json['url'],
      username: json['username'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'platform': platform,
      'url': url,
      if (username != null) 'username': username,
      'isPrimary': isPrimary,
    };
  }
}