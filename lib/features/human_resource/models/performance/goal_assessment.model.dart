class GoalAssessment {
  final String? id;
  final String goal;
  final String target;
  final String achievement;
  final double rating;
  final String comments;

  GoalAssessment({
    this.id,
    required this.goal,
    required this.target,
    required this.achievement,
    required this.rating,
    required this.comments,
  });

  factory GoalAssessment.fromJson(Map<String, dynamic> json) {
    return GoalAssessment(
      id: json['_id'],
      goal: json['goal'],
      target: json['target'],
      achievement: json['achievement'],
      rating: (json['rating'] as num).toDouble(),
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'goal': goal,
      'target': target,
      'achievement': achievement,
      'rating': rating,
      'comments': comments,
    };
  }

  GoalAssessment copyWith({
    String? id,
    String? goal,
    String? target,
    String? achievement,
    double? rating,
    String? comments,
  }) {
    return GoalAssessment(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      target: target ?? this.target,
      achievement: achievement ?? this.achievement,
      rating: rating ?? this.rating,
      comments: comments ?? this.comments,
    );
  }
}