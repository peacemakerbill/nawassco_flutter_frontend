class CompetencyAssessment {
  final String? id;
  final String competency;
  final String description;
  final double rating;
  final List<String> examples;

  CompetencyAssessment({
    this.id,
    required this.competency,
    required this.description,
    required this.rating,
    this.examples = const [],
  });

  factory CompetencyAssessment.fromJson(Map<String, dynamic> json) {
    return CompetencyAssessment(
      id: json['_id'],
      competency: json['competency'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      examples: List<String>.from(json['examples'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'competency': competency,
      'description': description,
      'rating': rating,
      'examples': examples,
    };
  }

  CompetencyAssessment copyWith({
    String? id,
    String? competency,
    String? description,
    double? rating,
    List<String>? examples,
  }) {
    return CompetencyAssessment(
      id: id ?? this.id,
      competency: competency ?? this.competency,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      examples: examples ?? this.examples,
    );
  }
}