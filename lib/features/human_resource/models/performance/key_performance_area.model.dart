class KeyPerformanceArea {
  final String? id;
  final String area;
  final double weight;
  final String target;
  final String achievement;
  final double rating;
  final String comments;

  KeyPerformanceArea({
    this.id,
    required this.area,
    required this.weight,
    required this.target,
    required this.achievement,
    required this.rating,
    required this.comments,
  });

  factory KeyPerformanceArea.fromJson(Map<String, dynamic> json) {
    return KeyPerformanceArea(
      id: json['_id'],
      area: json['area'],
      weight: (json['weight'] as num).toDouble(),
      target: json['target'],
      achievement: json['achievement'],
      rating: (json['rating'] as num).toDouble(),
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'area': area,
      'weight': weight,
      'target': target,
      'achievement': achievement,
      'rating': rating,
      'comments': comments,
    };
  }

  KeyPerformanceArea copyWith({
    String? id,
    String? area,
    double? weight,
    String? target,
    String? achievement,
    double? rating,
    String? comments,
  }) {
    return KeyPerformanceArea(
      id: id ?? this.id,
      area: area ?? this.area,
      weight: weight ?? this.weight,
      target: target ?? this.target,
      achievement: achievement ?? this.achievement,
      rating: rating ?? this.rating,
      comments: comments ?? this.comments,
    );
  }
}