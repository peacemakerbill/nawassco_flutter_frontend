class LanguageModel {
  final String? id;
  final String language;
  final String proficiency;
  final bool isNative;
  final String? certificate;

  LanguageModel({
    this.id,
    required this.language,
    required this.proficiency,
    this.isNative = false,
    this.certificate,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['_id'],
      language: json['language'],
      proficiency: json['proficiency'],
      isNative: json['isNative'] ?? false,
      certificate: json['certificate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'language': language,
      'proficiency': proficiency,
      'isNative': isNative,
      if (certificate != null) 'certificate': certificate,
    };
  }
}