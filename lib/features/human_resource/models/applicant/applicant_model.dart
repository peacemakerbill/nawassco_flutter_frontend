import 'certification_model.dart';
import 'document_model.dart';
import 'education_model.dart';
import 'language_model.dart';
import 'portfolio_model.dart';
import 'skill_model.dart';
import 'work_experience_model.dart';

class ApplicantModel {
  final String? id;
  final String? userId;
  final String email;
  final bool isRegisteredUser;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String phoneNumber;
  final String address;
  final String city;
  final String country;
  final String? postalCode;
  final String? profilePhoto;
  final String? headline;
  final String? summary;
  final String? currentPosition;
  final String? currentEmployer;
  final String? industry;
  final double? yearsOfExperience;
  final CurrentSalary? currentSalary;
  final ExpectedSalary? expectedSalary;
  final int? noticePeriod;
  final List<EducationModel> education;
  final List<WorkExperienceModel> workExperience;
  final List<SkillModel> skills;
  final List<CertificationModel> certifications;
  final List<LanguageModel> languages;
  final List<PortfolioModel> portfolioLinks;
  final JobPreferences? jobPreferences;
  final List<DocumentModel> documents;
  final String? defaultResume;
  final List<String> applications;
  final int totalApplications;
  final int activeApplications;
  final double profileCompletion;
  final DateTime lastProfileUpdate;
  final int profileViews;
  final bool emailNotifications;
  final bool jobAlerts;
  final PrivacySettings privacySettings;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? userLinkedAt;
  final DateTime? lastSyncedWithUser;

  ApplicantModel({
    this.id,
    this.userId,
    required this.email,
    required this.isRegisteredUser,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.country,
    this.postalCode,
    this.profilePhoto,
    this.headline,
    this.summary,
    this.currentPosition,
    this.currentEmployer,
    this.industry,
    this.yearsOfExperience,
    this.currentSalary,
    this.expectedSalary,
    this.noticePeriod,
    required this.education,
    required this.workExperience,
    required this.skills,
    required this.certifications,
    required this.languages,
    required this.portfolioLinks,
    this.jobPreferences,
    required this.documents,
    this.defaultResume,
    required this.applications,
    required this.totalApplications,
    required this.activeApplications,
    required this.profileCompletion,
    required this.lastProfileUpdate,
    required this.profileViews,
    required this.emailNotifications,
    required this.jobAlerts,
    required this.privacySettings,
    required this.isVerified,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.userLinkedAt,
    this.lastSyncedWithUser,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['_id'],
      userId: json['user'],
      email: json['email'],
      isRegisteredUser: json['isRegisteredUser'] ?? false,
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      nationality: json['nationality'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      profilePhoto: json['profilePhoto'],
      headline: json['headline'],
      summary: json['summary'],
      currentPosition: json['currentPosition'],
      currentEmployer: json['currentEmployer'],
      industry: json['industry'],
      yearsOfExperience: json['yearsOfExperience']?.toDouble(),
      currentSalary: json['currentSalary'] != null
          ? CurrentSalary.fromJson(json['currentSalary'])
          : null,
      expectedSalary: json['expectedSalary'] != null
          ? ExpectedSalary.fromJson(json['expectedSalary'])
          : null,
      noticePeriod: json['noticePeriod'],
      education: (json['education'] as List? ?? [])
          .map((e) => EducationModel.fromJson(e))
          .toList(),
      workExperience: (json['workExperience'] as List? ?? [])
          .map((e) => WorkExperienceModel.fromJson(e))
          .toList(),
      skills: (json['skills'] as List? ?? [])
          .map((e) => SkillModel.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
          .map((e) => CertificationModel.fromJson(e))
          .toList(),
      languages: (json['languages'] as List? ?? [])
          .map((e) => LanguageModel.fromJson(e))
          .toList(),
      portfolioLinks: (json['portfolioLinks'] as List? ?? [])
          .map((e) => PortfolioModel.fromJson(e))
          .toList(),
      jobPreferences: json['jobPreferences'] != null
          ? JobPreferences.fromJson(json['jobPreferences'])
          : null,
      documents: (json['documents'] as List? ?? [])
          .map((e) => DocumentModel.fromJson(e))
          .toList(),
      defaultResume: json['defaultResume'],
      applications: List<String>.from(json['applications'] ?? []),
      totalApplications: json['totalApplications'] ?? 0,
      activeApplications: json['activeApplications'] ?? 0,
      profileCompletion: (json['profileCompletion'] ?? 0).toDouble(),
      lastProfileUpdate: DateTime.parse(json['lastProfileUpdate']),
      profileViews: json['profileViews'] ?? 0,
      emailNotifications: json['emailNotifications'] ?? true,
      jobAlerts: json['jobAlerts'] ?? true,
      privacySettings: PrivacySettings.fromJson(json['privacySettings'] ?? {}),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      userLinkedAt: json['userLinkedAt'] != null
          ? DateTime.parse(json['userLinkedAt'])
          : null,
      lastSyncedWithUser: json['lastSyncedWithUser'] != null
          ? DateTime.parse(json['lastSyncedWithUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'user': userId,
      'email': email,
      'isRegisteredUser': isRegisteredUser,
      'firstName': firstName,
      'lastName': lastName,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (nationality != null) 'nationality': nationality,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      if (headline != null) 'headline': headline,
      if (summary != null) 'summary': summary,
      if (currentPosition != null) 'currentPosition': currentPosition,
      if (currentEmployer != null) 'currentEmployer': currentEmployer,
      if (industry != null) 'industry': industry,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      if (currentSalary != null) 'currentSalary': currentSalary!.toJson(),
      if (expectedSalary != null) 'expectedSalary': expectedSalary!.toJson(),
      if (noticePeriod != null) 'noticePeriod': noticePeriod,
      'education': education.map((e) => e.toJson()).toList(),
      'workExperience': workExperience.map((e) => e.toJson()).toList(),
      'skills': skills.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'languages': languages.map((e) => e.toJson()).toList(),
      'portfolioLinks': portfolioLinks.map((e) => e.toJson()).toList(),
      if (jobPreferences != null) 'jobPreferences': jobPreferences!.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
      if (defaultResume != null) 'defaultResume': defaultResume,
      'applications': applications,
      'totalApplications': totalApplications,
      'activeApplications': activeApplications,
      'profileCompletion': profileCompletion,
      'lastProfileUpdate': lastProfileUpdate.toIso8601String(),
      'profileViews': profileViews,
      'emailNotifications': emailNotifications,
      'jobAlerts': jobAlerts,
      'privacySettings': privacySettings.toJson(),
      'isVerified': isVerified,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (userLinkedAt != null) 'userLinkedAt': userLinkedAt!.toIso8601String(),
      if (lastSyncedWithUser != null)
        'lastSyncedWithUser': lastSyncedWithUser!.toIso8601String(),
    };
  }

  ApplicantModel copyWith({
    String? id,
    String? userId,
    String? email,
    bool? isRegisteredUser,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? phoneNumber,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? profilePhoto,
    String? headline,
    String? summary,
    String? currentPosition,
    String? currentEmployer,
    String? industry,
    double? yearsOfExperience,
    CurrentSalary? currentSalary,
    ExpectedSalary? expectedSalary,
    int? noticePeriod,
    List<EducationModel>? education,
    List<WorkExperienceModel>? workExperience,
    List<SkillModel>? skills,
    List<CertificationModel>? certifications,
    List<LanguageModel>? languages,
    List<PortfolioModel>? portfolioLinks,
    JobPreferences? jobPreferences,
    List<DocumentModel>? documents,
    String? defaultResume,
    List<String>? applications,
    int? totalApplications,
    int? activeApplications,
    double? profileCompletion,
    DateTime? lastProfileUpdate,
    int? profileViews,
    bool? emailNotifications,
    bool? jobAlerts,
    PrivacySettings? privacySettings,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? userLinkedAt,
    DateTime? lastSyncedWithUser,
  }) {
    return ApplicantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isRegisteredUser: isRegisteredUser ?? this.isRegisteredUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      currentPosition: currentPosition ?? this.currentPosition,
      currentEmployer: currentEmployer ?? this.currentEmployer,
      industry: industry ?? this.industry,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentSalary: currentSalary ?? this.currentSalary,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      education: education ?? this.education,
      workExperience: workExperience ?? this.workExperience,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      jobPreferences: jobPreferences ?? this.jobPreferences,
      documents: documents ?? this.documents,
      defaultResume: defaultResume ?? this.defaultResume,
      applications: applications ?? this.applications,
      totalApplications: totalApplications ?? this.totalApplications,
      activeApplications: activeApplications ?? this.activeApplications,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      lastProfileUpdate: lastProfileUpdate ?? this.lastProfileUpdate,
      profileViews: profileViews ?? this.profileViews,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      jobAlerts: jobAlerts ?? this.jobAlerts,
      privacySettings: privacySettings ?? this.privacySettings,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      userLinkedAt: userLinkedAt ?? this.userLinkedAt,
      lastSyncedWithUser: lastSyncedWithUser ?? this.lastSyncedWithUser,
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isProfileComplete => profileCompletion >= 80;

  bool get hasDefaultResume =>
      defaultResume != null && defaultResume!.isNotEmpty;
}

class CurrentSalary {
  final double amount;
  final String currency;
  final String payPeriod;

  CurrentSalary({
    required this.amount,
    required this.currency,
    required this.payPeriod,
  });

  factory CurrentSalary.fromJson(Map<String, dynamic> json) {
    return CurrentSalary(
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      payPeriod: json['payPeriod'] ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'payPeriod': payPeriod,
    };
  }
}

class ExpectedSalary {
  final double min;
  final double max;
  final String currency;
  final bool isNegotiable;

  ExpectedSalary({
    required this.min,
    required this.max,
    required this.currency,
    required this.isNegotiable,
  });

  factory ExpectedSalary.fromJson(Map<String, dynamic> json) {
    return ExpectedSalary(
      min: json['min']?.toDouble() ?? 0.0,
      max: json['max']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      isNegotiable: json['isNegotiable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
      'isNegotiable': isNegotiable,
    };
  }
}

class JobPreferences {
  final List<String> preferredJobTypes;
  final List<String> preferredPositionTypes;
  final List<String> preferredWorkModes;
  final List<String> preferredLocations;
  final List<String> preferredIndustries;
  final bool remoteOnly;
  final bool visaSponsorshipRequired;
  final double? minimumSalary;
  final String currency;
  final bool willingToRelocate;
  final List<String>? relocationLocations;
  final int noticePeriod;
  final DateTime? availableFrom;

  JobPreferences({
    this.preferredJobTypes = const [],
    this.preferredPositionTypes = const [],
    this.preferredWorkModes = const [],
    this.preferredLocations = const [],
    this.preferredIndustries = const [],
    this.remoteOnly = false,
    this.visaSponsorshipRequired = false,
    this.minimumSalary,
    this.currency = 'USD',
    this.willingToRelocate = false,
    this.relocationLocations,
    this.noticePeriod = 30,
    this.availableFrom,
  });

  factory JobPreferences.fromJson(Map<String, dynamic> json) {
    return JobPreferences(
      preferredJobTypes: List<String>.from(json['preferredJobTypes'] ?? []),
      preferredPositionTypes:
          List<String>.from(json['preferredPositionTypes'] ?? []),
      preferredWorkModes: List<String>.from(json['preferredWorkModes'] ?? []),
      preferredLocations: List<String>.from(json['preferredLocations'] ?? []),
      preferredIndustries: List<String>.from(json['preferredIndustries'] ?? []),
      remoteOnly: json['remoteOnly'] ?? false,
      visaSponsorshipRequired: json['visaSponsorshipRequired'] ?? false,
      minimumSalary: json['minimumSalary']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      willingToRelocate: json['willingToRelocate'] ?? false,
      relocationLocations: json['relocationLocations'] != null
          ? List<String>.from(json['relocationLocations'])
          : null,
      noticePeriod: json['noticePeriod'] ?? 30,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredJobTypes': preferredJobTypes,
      'preferredPositionTypes': preferredPositionTypes,
      'preferredWorkModes': preferredWorkModes,
      'preferredLocations': preferredLocations,
      'preferredIndustries': preferredIndustries,
      'remoteOnly': remoteOnly,
      'visaSponsorshipRequired': visaSponsorshipRequired,
      if (minimumSalary != null) 'minimumSalary': minimumSalary,
      'currency': currency,
      'willingToRelocate': willingToRelocate,
      if (relocationLocations != null)
        'relocationLocations': relocationLocations,
      'noticePeriod': noticePeriod,
      if (availableFrom != null)
        'availableFrom': availableFrom!.toIso8601String(),
    };
  }
}

class PrivacySettings {
  final String profileVisibility;
  final String resumeVisibility;
  final bool showSalary;
  final bool showContactInfo;
  final bool allowHeadhunters;
  final bool syncWithUserProfile;

  PrivacySettings({
    this.profileVisibility = 'recruiters_only',
    this.resumeVisibility = 'applied_jobs_only',
    this.showSalary = false,
    this.showContactInfo = true,
    this.allowHeadhunters = false,
    this.syncWithUserProfile = true,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profileVisibility'] ?? 'recruiters_only',
      resumeVisibility: json['resumeVisibility'] ?? 'applied_jobs_only',
      showSalary: json['showSalary'] ?? false,
      showContactInfo: json['showContactInfo'] ?? true,
      allowHeadhunters: json['allowHeadhunters'] ?? false,
      syncWithUserProfile: json['syncWithUserProfile'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisibility': profileVisibility,
      'resumeVisibility': resumeVisibility,
      'showSalary': showSalary,
      'showContactInfo': showContactInfo,
      'allowHeadhunters': allowHeadhunters,
      'syncWithUserProfile': syncWithUserProfile,
    };
  }
}
