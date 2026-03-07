class WorkExperienceModel {
  final String? id;
  final String employer;
  final String position;
  final String employmentType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? location;
  final String description;
  final List<String> responsibilities;
  final List<String> achievements;
  final List<String> skillsUsed;
  final ReferenceContact? referenceContact;

  WorkExperienceModel({
    this.id,
    required this.employer,
    required this.position,
    required this.employmentType,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.location,
    required this.description,
    this.responsibilities = const [],
    this.achievements = const [],
    this.skillsUsed = const [],
    this.referenceContact,
  });

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) {
    return WorkExperienceModel(
      id: json['_id'],
      employer: json['employer'],
      position: json['position'],
      employmentType: json['employmentType'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
      location: json['location'],
      description: json['description'],
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      skillsUsed: List<String>.from(json['skillsUsed'] ?? []),
      referenceContact: json['referenceContact'] != null
          ? ReferenceContact.fromJson(json['referenceContact'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'employer': employer,
      'position': position,
      'employmentType': employmentType,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'isCurrent': isCurrent,
      if (location != null) 'location': location,
      'description': description,
      'responsibilities': responsibilities,
      'achievements': achievements,
      'skillsUsed': skillsUsed,
      if (referenceContact != null) 'referenceContact': referenceContact!.toJson(),
    };
  }
}

class ReferenceContact {
  final String name;
  final String position;
  final String company;
  final String email;
  final String? phone;
  final String relationship;
  final bool canContact;

  ReferenceContact({
    required this.name,
    required this.position,
    required this.company,
    required this.email,
    this.phone,
    required this.relationship,
    required this.canContact,
  });

  factory ReferenceContact.fromJson(Map<String, dynamic> json) {
    return ReferenceContact(
      name: json['name'],
      position: json['position'],
      company: json['company'],
      email: json['email'],
      phone: json['phone'],
      relationship: json['relationship'],
      canContact: json['canContact'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'company': company,
      'email': email,
      if (phone != null) 'phone': phone,
      'relationship': relationship,
      'canContact': canContact,
    };
  }
}