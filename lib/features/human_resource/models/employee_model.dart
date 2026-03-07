import 'package:flutter/foundation.dart';

enum Gender { male, female, other }

enum MaritalStatus { single, married, divorced, widowed }

enum EmploymentType { permanent, contract, temporary, intern, probation }

enum EmploymentStatus { active, on_leave, suspended, terminated, retired }

enum EmploymentCategory {
  management,
  professional,
  technical,
  administrative,
  operational
}

enum ProficiencyLevel { basic, intermediate, advanced, expert, native }

enum QualificationLevel {
  high_school,
  diploma,
  bachelors,
  masters,
  doctorate,
  professional
}

enum DocumentStatus { pending, approved, rejected, expired }

class PersonalDetails {
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final Gender gender;
  final MaritalStatus maritalStatus;
  final String nationality;
  final String nationalId;
  final String? passportNumber;
  final String taxNumber;
  final String socialSecurityNumber;

  PersonalDetails({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
    required this.nationality,
    required this.nationalId,
    this.passportNumber,
    required this.taxNumber,
    required this.socialSecurityNumber,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': describeEnum(gender),
        'maritalStatus': describeEnum(maritalStatus),
        'nationality': nationality,
        'nationalId': nationalId,
        'passportNumber': passportNumber,
        'taxNumber': taxNumber,
        'socialSecurityNumber': socialSecurityNumber,
      };

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      PersonalDetails(
        firstName: json['firstName'],
        lastName: json['lastName'],
        middleName: json['middleName'],
        dateOfBirth: DateTime.parse(json['dateOfBirth']),
        gender:
            Gender.values.firstWhere((e) => describeEnum(e) == json['gender']),
        maritalStatus: MaritalStatus.values
            .firstWhere((e) => describeEnum(e) == json['maritalStatus']),
        nationality: json['nationality'],
        nationalId: json['nationalId'],
        passportNumber: json['passportNumber'],
        taxNumber: json['taxNumber'],
        socialSecurityNumber: json['socialSecurityNumber'],
      );
}

class Employee {
  final String id;
  final String employeeNumber;
  final String userId;

  // Personal Information
  final PersonalDetails personalDetails;

  // Employment Information
  final DateTime hireDate;
  final EmploymentType employmentType;
  final EmploymentStatus employmentStatus;
  final EmploymentCategory employmentCategory;
  final String department;
  final String jobTitle;
  final String jobGrade;

  // Contact Information
  final String personalEmail;
  final String workEmail;
  final String personalPhone;
  final String? workPhone;

  // Compensation
  final double basicSalary;
  final String salaryCurrency;
  final double netSalary;

  // Qualifications & Skills
  final List<Qualification> qualifications;
  final List<Certification> certifications;
  final List<Skill> skills;
  final List<LanguageProficiency> languages;

  // Work Information
  final Map<String, dynamic> workSchedule;
  final Map<String, dynamic> leaveBalance;

  // Status & History
  final List<EmploymentHistory> employmentHistory;
  final List<PromotionHistory> promotionHistory;

  // Documents
  final List<EmployeeDocument> documents;

  // System
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.employeeNumber,
    required this.userId,
    required this.personalDetails,
    required this.hireDate,
    required this.employmentType,
    required this.employmentStatus,
    required this.employmentCategory,
    required this.department,
    required this.jobTitle,
    required this.jobGrade,
    required this.personalEmail,
    required this.workEmail,
    required this.personalPhone,
    this.workPhone,
    required this.basicSalary,
    required this.salaryCurrency,
    required this.netSalary,
    this.qualifications = const [],
    this.certifications = const [],
    this.skills = const [],
    this.languages = const [],
    required this.workSchedule,
    required this.leaveBalance,
    this.employmentHistory = const [],
    this.promotionHistory = const [],
    this.documents = const [],
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName =>
      '${personalDetails.firstName} ${personalDetails.lastName}';

  String get formalName => personalDetails.middleName != null
      ? '${personalDetails.firstName} ${personalDetails.middleName} ${personalDetails.lastName}'
      : fullName;

  int get age {
    final now = DateTime.now();
    int age = now.year - personalDetails.dateOfBirth.year;
    if (now.month < personalDetails.dateOfBirth.month ||
        (now.month == personalDetails.dateOfBirth.month &&
            now.day < personalDetails.dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    if (now.month < hireDate.month ||
        (now.month == hireDate.month && now.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeNumber': employeeNumber,
        'userId': userId,
        'personalDetails': personalDetails.toJson(),
        'hireDate': hireDate.toIso8601String(),
        'employmentType': describeEnum(employmentType),
        'employmentStatus': describeEnum(employmentStatus),
        'employmentCategory': describeEnum(employmentCategory),
        'department': department,
        'jobTitle': jobTitle,
        'jobGrade': jobGrade,
        'personalEmail': personalEmail,
        'workEmail': workEmail,
        'personalPhone': personalPhone,
        'workPhone': workPhone,
        'basicSalary': basicSalary,
        'salaryCurrency': salaryCurrency,
        'netSalary': netSalary,
        'qualifications': qualifications.map((q) => q.toJson()).toList(),
        'certifications': certifications.map((c) => c.toJson()).toList(),
        'skills': skills.map((s) => s.toJson()).toList(),
        'languages': languages.map((l) => l.toJson()).toList(),
        'workSchedule': workSchedule,
        'leaveBalance': leaveBalance,
        'employmentHistory': employmentHistory.map((h) => h.toJson()).toList(),
        'promotionHistory': promotionHistory.map((p) => p.toJson()).toList(),
        'documents': documents.map((d) => d.toJson()).toList(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['_id'] ?? json['id'],
        employeeNumber: json['employeeNumber'],
        userId: json['user'],
        personalDetails: PersonalDetails.fromJson(json['personalDetails']),
        hireDate: DateTime.parse(json['employmentDetails']['hireDate']),
        employmentType: EmploymentType.values.firstWhere((e) =>
            describeEnum(e) == json['employmentDetails']['employmentType']),
        employmentStatus: EmploymentStatus.values.firstWhere((e) =>
            describeEnum(e) == json['employmentDetails']['employmentStatus']),
        employmentCategory: EmploymentCategory.values.firstWhere((e) =>
            describeEnum(e) == json['employmentDetails']['employmentCategory']),
        department: json['jobInformation']['department'],
        jobTitle: json['jobInformation']['jobTitle'],
        jobGrade: json['jobInformation']['jobGrade'],
        personalEmail: json['contactInformation']['personalEmail'],
        workEmail: json['contactInformation']['workEmail'],
        personalPhone: json['contactInformation']['personalPhone'],
        workPhone: json['contactInformation']['workPhone'],
        basicSalary: json['compensation']['basicSalary']?.toDouble() ?? 0.0,
        salaryCurrency: json['compensation']['salaryCurrency'] ?? 'KES',
        netSalary: json['compensation']['netSalary']?.toDouble() ?? 0.0,
        qualifications: (json['qualifications'] as List? ?? [])
            .map((q) => Qualification.fromJson(q))
            .toList(),
        certifications: (json['certifications'] as List? ?? [])
            .map((c) => Certification.fromJson(c))
            .toList(),
        skills: (json['skills'] as List? ?? [])
            .map((s) => Skill.fromJson(s))
            .toList(),
        languages: (json['languages'] as List? ?? [])
            .map((l) => LanguageProficiency.fromJson(l))
            .toList(),
        workSchedule: Map<String, dynamic>.from(json['workSchedule'] ?? {}),
        leaveBalance: Map<String, dynamic>.from(json['leaveBalance'] ?? {}),
        employmentHistory: (json['employmentHistory'] as List? ?? [])
            .map((h) => EmploymentHistory.fromJson(h))
            .toList(),
        promotionHistory: (json['promotionHistory'] as List? ?? [])
            .map((p) => PromotionHistory.fromJson(p))
            .toList(),
        documents: (json['documents'] as List? ?? [])
            .map((d) => EmployeeDocument.fromJson(d))
            .toList(),
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Employee copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    PersonalDetails? personalDetails,
    DateTime? hireDate,
    EmploymentType? employmentType,
    EmploymentStatus? employmentStatus,
    EmploymentCategory? employmentCategory,
    String? department,
    String? jobTitle,
    String? jobGrade,
    String? personalEmail,
    String? workEmail,
    String? personalPhone,
    String? workPhone,
    double? basicSalary,
    String? salaryCurrency,
    double? netSalary,
    List<Qualification>? qualifications,
    List<Certification>? certifications,
    List<Skill>? skills,
    List<LanguageProficiency>? languages,
    Map<String, dynamic>? workSchedule,
    Map<String, dynamic>? leaveBalance,
    List<EmploymentHistory>? employmentHistory,
    List<PromotionHistory>? promotionHistory,
    List<EmployeeDocument>? documents,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Employee(
        id: id ?? this.id,
        employeeNumber: employeeNumber ?? this.employeeNumber,
        userId: userId ?? this.userId,
        personalDetails: personalDetails ?? this.personalDetails,
        hireDate: hireDate ?? this.hireDate,
        employmentType: employmentType ?? this.employmentType,
        employmentStatus: employmentStatus ?? this.employmentStatus,
        employmentCategory: employmentCategory ?? this.employmentCategory,
        department: department ?? this.department,
        jobTitle: jobTitle ?? this.jobTitle,
        jobGrade: jobGrade ?? this.jobGrade,
        personalEmail: personalEmail ?? this.personalEmail,
        workEmail: workEmail ?? this.workEmail,
        personalPhone: personalPhone ?? this.personalPhone,
        workPhone: workPhone ?? this.workPhone,
        basicSalary: basicSalary ?? this.basicSalary,
        salaryCurrency: salaryCurrency ?? this.salaryCurrency,
        netSalary: netSalary ?? this.netSalary,
        qualifications: qualifications ?? this.qualifications,
        certifications: certifications ?? this.certifications,
        skills: skills ?? this.skills,
        languages: languages ?? this.languages,
        workSchedule: workSchedule ?? this.workSchedule,
        leaveBalance: leaveBalance ?? this.leaveBalance,
        employmentHistory: employmentHistory ?? this.employmentHistory,
        promotionHistory: promotionHistory ?? this.promotionHistory,
        documents: documents ?? this.documents,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class Qualification {
  final QualificationLevel level;
  final String field;
  final String institution;
  final int yearCompleted;
  final String? documentUrl;

  Qualification({
    required this.level,
    required this.field,
    required this.institution,
    required this.yearCompleted,
    this.documentUrl,
  });

  Map<String, dynamic> toJson() => {
        'level': describeEnum(level),
        'field': field,
        'institution': institution,
        'yearCompleted': yearCompleted,
        'documentUrl': documentUrl,
      };

  factory Qualification.fromJson(Map<String, dynamic> json) => Qualification(
        level: QualificationLevel.values
            .firstWhere((e) => describeEnum(e) == json['level']),
        field: json['field'],
        institution: json['institution'],
        yearCompleted: json['yearCompleted'],
        documentUrl: json['documentUrl'],
      );
}

class Certification {
  final String name;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String documentUrl;
  final DocumentStatus status;

  Certification({
    required this.name,
    required this.issuingAuthority,
    required this.issueDate,
    this.expiryDate,
    required this.documentUrl,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuingAuthority': issuingAuthority,
        'issueDate': issueDate.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'documentUrl': documentUrl,
        'status': describeEnum(status),
      };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        name: json['name'],
        issuingAuthority: json['issuingAuthority'],
        issueDate: DateTime.parse(json['issueDate']),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        documentUrl: json['documentUrl'],
        status: DocumentStatus.values
            .firstWhere((e) => describeEnum(e) == json['status']),
      );

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
}

class Skill {
  final String skill;
  final String category;
  final ProficiencyLevel proficiency;
  final int yearsOfExperience;
  final DateTime lastUsed;

  Skill({
    required this.skill,
    required this.category,
    required this.proficiency,
    required this.yearsOfExperience,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'category': category,
        'proficiency': describeEnum(proficiency),
        'yearsOfExperience': yearsOfExperience,
        'lastUsed': lastUsed.toIso8601String(),
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        skill: json['skill'],
        category: json['category'],
        proficiency: ProficiencyLevel.values
            .firstWhere((e) => describeEnum(e) == json['proficiency']),
        yearsOfExperience: json['yearsOfExperience'],
        lastUsed: DateTime.parse(json['lastUsed']),
      );
}

class LanguageProficiency {
  final String language;
  final ProficiencyLevel speaking;
  final ProficiencyLevel reading;
  final ProficiencyLevel writing;

  LanguageProficiency({
    required this.language,
    required this.speaking,
    required this.reading,
    required this.writing,
  });

  Map<String, dynamic> toJson() => {
        'language': language,
        'speaking': describeEnum(speaking),
        'reading': describeEnum(reading),
        'writing': describeEnum(writing),
      };

  factory LanguageProficiency.fromJson(Map<String, dynamic> json) =>
      LanguageProficiency(
        language: json['language'],
        speaking: ProficiencyLevel.values
            .firstWhere((e) => describeEnum(e) == json['speaking']),
        reading: ProficiencyLevel.values
            .firstWhere((e) => describeEnum(e) == json['reading']),
        writing: ProficiencyLevel.values
            .firstWhere((e) => describeEnum(e) == json['writing']),
      );
}

class EmploymentHistory {
  final String company;
  final String jobTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String reasonForLeaving;
  final String? documentUrl;

  EmploymentHistory({
    required this.company,
    required this.jobTitle,
    required this.startDate,
    required this.endDate,
    required this.reasonForLeaving,
    this.documentUrl,
  });

  Map<String, dynamic> toJson() => {
        'company': company,
        'jobTitle': jobTitle,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reasonForLeaving': reasonForLeaving,
        'documentUrl': documentUrl,
      };

  factory EmploymentHistory.fromJson(Map<String, dynamic> json) =>
      EmploymentHistory(
        company: json['company'],
        jobTitle: json['jobTitle'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        reasonForLeaving: json['reasonForLeaving'],
        documentUrl: json['documentUrl'],
      );
}

class PromotionHistory {
  final String previousPosition;
  final String newPosition;
  final DateTime promotionDate;
  final double salaryBefore;
  final double salaryAfter;
  final String reason;
  final String approvedBy;

  PromotionHistory({
    required this.previousPosition,
    required this.newPosition,
    required this.promotionDate,
    required this.salaryBefore,
    required this.salaryAfter,
    required this.reason,
    required this.approvedBy,
  });

  Map<String, dynamic> toJson() => {
        'previousPosition': previousPosition,
        'newPosition': newPosition,
        'promotionDate': promotionDate.toIso8601String(),
        'salaryBefore': salaryBefore,
        'salaryAfter': salaryAfter,
        'reason': reason,
        'approvedBy': approvedBy,
      };

  factory PromotionHistory.fromJson(Map<String, dynamic> json) =>
      PromotionHistory(
        previousPosition: json['previousPosition'],
        newPosition: json['newPosition'],
        promotionDate: DateTime.parse(json['promotionDate']),
        salaryBefore: json['salaryBefore']?.toDouble() ?? 0.0,
        salaryAfter: json['salaryAfter']?.toDouble() ?? 0.0,
        reason: json['reason'],
        approvedBy: json['approvedBy'],
      );
}

class EmployeeDocument {
  final String documentType;
  final String documentName;
  final String documentUrl;
  final DateTime uploadDate;
  final DateTime? expiryDate;
  final DocumentStatus status;

  EmployeeDocument({
    required this.documentType,
    required this.documentName,
    required this.documentUrl,
    required this.uploadDate,
    this.expiryDate,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'documentName': documentName,
        'documentUrl': documentUrl,
        'uploadDate': uploadDate.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'status': describeEnum(status),
      };

  factory EmployeeDocument.fromJson(Map<String, dynamic> json) =>
      EmployeeDocument(
        documentType: json['documentType'],
        documentName: json['documentName'],
        documentUrl: json['documentUrl'],
        uploadDate: DateTime.parse(json['uploadDate']),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        status: DocumentStatus.values
            .firstWhere((e) => describeEnum(e) == json['status']),
      );

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
}
