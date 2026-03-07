class EducationModel {
  final String? id;
  final String institution;
  final String qualification;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;
  final double? gpa;
  final String? description;
  final bool isCurrent;
  final bool isVerified;

  EducationModel({
    this.id,
    required this.institution,
    required this.qualification,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.grade,
    this.gpa,
    this.description,
    this.isCurrent = false,
    this.isVerified = false,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['_id'],
      institution: json['institution'],
      qualification: json['qualification'],
      fieldOfStudy: json['fieldOfStudy'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      grade: json['grade'],
      gpa: json['gpa']?.toDouble(),
      description: json['description'],
      isCurrent: json['isCurrent'] ?? false,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'institution': institution,
      'qualification': qualification,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (grade != null) 'grade': grade,
      if (gpa != null) 'gpa': gpa,
      if (description != null) 'description': description,
      'isCurrent': isCurrent,
      'isVerified': isVerified,
    };
  }
}