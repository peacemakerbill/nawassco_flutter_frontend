class SkillModel {
  final String? id;
  final String skill;
  final String category;
  final String proficiency;
  final int yearsOfExperience;
  final int? lastUsed;
  final bool isVerified;
  final String? verifiedBy;

  SkillModel({
    this.id,
    required this.skill,
    required this.category,
    required this.proficiency,
    required this.yearsOfExperience,
    this.lastUsed,
    this.isVerified = false,
    this.verifiedBy,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['_id'],
      skill: json['skill'],
      category: json['category'],
      proficiency: json['proficiency'],
      yearsOfExperience: json['yearsOfExperience'],
      lastUsed: json['lastUsed'],
      isVerified: json['isVerified'] ?? false,
      verifiedBy: json['verifiedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'skill': skill,
      'category': category,
      'proficiency': proficiency,
      'yearsOfExperience': yearsOfExperience,
      if (lastUsed != null) 'lastUsed': lastUsed,
      'isVerified': isVerified,
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
    };
  }
}