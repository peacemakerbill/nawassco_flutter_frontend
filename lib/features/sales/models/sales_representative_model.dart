import 'dart:ui';

enum SalesRepStatus { active, on_leave, training, terminated }

enum SalesRole {
  sales_director,
  sales_manager,
  senior_sales_rep,
  sales_representative,
  junior_sales_rep,
  account_manager,
  business_development_manager
}

enum EmploymentType { full_time, part_time, contract, temporary, internship }

enum ProficiencyLevel { beginner, intermediate, advanced, expert }

class PersonalDetails {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String nationalId;

  PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationalId,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      gender: json['gender'] ?? 'other',
      nationalId: json['nationalId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'nationalId': nationalId,
    };
  }

  String get fullName => '$firstName $lastName';
}

class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  String get formattedAddress => '$street, $city, $state $postalCode, $country';
}

class ContactInformation {
  final String workEmail;
  final String personalEmail;
  final String workPhone;
  final String personalPhone;
  final Address address;

  ContactInformation({
    required this.workEmail,
    required this.personalEmail,
    required this.workPhone,
    required this.personalPhone,
    required this.address,
  });

  factory ContactInformation.fromJson(Map<String, dynamic> json) {
    return ContactInformation(
      workEmail: json['workEmail'] ?? '',
      personalEmail: json['personalEmail'] ?? '',
      workPhone: json['workPhone'] ?? '',
      personalPhone: json['personalPhone'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workEmail': workEmail,
      'personalEmail': personalEmail,
      'workPhone': workPhone,
      'personalPhone': personalPhone,
      'address': address.toJson(),
    };
  }
}

class SalesTargets {
  final double monthlyTarget;
  final double quarterlyTarget;
  final double annualTarget;
  final int newCustomersTarget;
  final double revenueTarget;
  final double collectionTarget;

  SalesTargets({
    required this.monthlyTarget,
    required this.quarterlyTarget,
    required this.annualTarget,
    required this.newCustomersTarget,
    required this.revenueTarget,
    required this.collectionTarget,
  });

  factory SalesTargets.fromJson(Map<String, dynamic> json) {
    return SalesTargets(
      monthlyTarget: (json['monthlyTarget'] ?? 0).toDouble(),
      quarterlyTarget: (json['quarterlyTarget'] ?? 0).toDouble(),
      annualTarget: (json['annualTarget'] ?? 0).toDouble(),
      newCustomersTarget: (json['newCustomersTarget'] ?? 0),
      revenueTarget: (json['revenueTarget'] ?? 0).toDouble(),
      collectionTarget: (json['collectionTarget'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyTarget': monthlyTarget,
      'quarterlyTarget': quarterlyTarget,
      'annualTarget': annualTarget,
      'newCustomersTarget': newCustomersTarget,
      'revenueTarget': revenueTarget,
      'collectionTarget': collectionTarget,
    };
  }
}

class SalesPerformance {
  final double totalSales;
  final double monthlyAverage;
  final double conversionRate;
  final double averageDealSize;
  final double customerSatisfaction;
  final double retentionRate;
  final double overallRating;

  SalesPerformance({
    required this.totalSales,
    required this.monthlyAverage,
    required this.conversionRate,
    required this.averageDealSize,
    required this.customerSatisfaction,
    required this.retentionRate,
    required this.overallRating,
  });

  factory SalesPerformance.fromJson(Map<String, dynamic> json) {
    return SalesPerformance(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      monthlyAverage: (json['monthlyAverage'] ?? 0).toDouble(),
      conversionRate: (json['conversionRate'] ?? 0).toDouble(),
      averageDealSize: (json['averageDealSize'] ?? 0).toDouble(),
      customerSatisfaction: (json['customerSatisfaction'] ?? 0).toDouble(),
      retentionRate: (json['retentionRate'] ?? 0).toDouble(),
      overallRating: (json['overallRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'monthlyAverage': monthlyAverage,
      'conversionRate': conversionRate,
      'averageDealSize': averageDealSize,
      'customerSatisfaction': customerSatisfaction,
      'retentionRate': retentionRate,
      'overallRating': overallRating,
    };
  }
}

class SalesRepresentative {
  final String id;
  final String employeeNumber;
  final String? userId;
  final PersonalDetails personalDetails;
  final ContactInformation contactInformation;
  final SalesRole salesRole;
  final SalesTargets salesTargets;
  final SalesPerformance performance;
  final SalesRepStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? jobInformation;
  final Map<String, dynamic>? salesTerritory;

  SalesRepresentative({
    required this.id,
    required this.employeeNumber,
    this.userId,
    required this.personalDetails,
    required this.contactInformation,
    required this.salesRole,
    required this.salesTargets,
    required this.performance,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.jobInformation,
    this.salesTerritory,
  });

  factory SalesRepresentative.fromJson(Map<String, dynamic> json) {
    return SalesRepresentative(
      id: json['_id'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      userId: json['user'],
      personalDetails: PersonalDetails.fromJson(json['personalDetails'] ?? {}),
      contactInformation:
          ContactInformation.fromJson(json['contactInformation'] ?? {}),
      salesRole: SalesRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['salesRole'],
        orElse: () => SalesRole.sales_representative,
      ),
      salesTargets: SalesTargets.fromJson(json['salesTargets'] ?? {}),
      performance: SalesPerformance.fromJson(json['performance'] ?? {}),
      status: SalesRepStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SalesRepStatus.active,
      ),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      jobInformation: json['jobInformation'],
      salesTerritory: json['salesTerritory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeNumber': employeeNumber,
      'user': userId,
      'personalDetails': personalDetails.toJson(),
      'contactInformation': contactInformation.toJson(),
      'salesRole': salesRole.toString().split('.').last,
      'salesTargets': salesTargets.toJson(),
      'performance': performance.toJson(),
      'status': status.toString().split('.').last,
      'isActive': isActive,
    };
  }

  SalesRepresentative copyWith({
    String? id,
    String? employeeNumber,
    String? userId,
    PersonalDetails? personalDetails,
    ContactInformation? contactInformation,
    SalesRole? salesRole,
    SalesTargets? salesTargets,
    SalesPerformance? performance,
    SalesRepStatus? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? jobInformation,
    Map<String, dynamic>? salesTerritory,
  }) {
    return SalesRepresentative(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      userId: userId ?? this.userId,
      personalDetails: personalDetails ?? this.personalDetails,
      contactInformation: contactInformation ?? this.contactInformation,
      salesRole: salesRole ?? this.salesRole,
      salesTargets: salesTargets ?? this.salesTargets,
      performance: performance ?? this.performance,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobInformation: jobInformation ?? this.jobInformation,
      salesTerritory: salesTerritory ?? this.salesTerritory,
    );
  }

  String get fullName => personalDetails.fullName;

  String get email => contactInformation.workEmail;

  String get phone => contactInformation.workPhone;

  String get formattedRole =>
      salesRole.toString().split('.').last.replaceAll('_', ' ').toUpperCase();

  static String getRoleDisplayName(SalesRole role) {
    return role.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  static String getStatusDisplayName(SalesRepStatus status) {
    return status.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  static Color getStatusColor(SalesRepStatus status) {
    return switch (status) {
      SalesRepStatus.active => const Color(0xFF10B981),
      SalesRepStatus.on_leave => const Color(0xFFF59E0B),
      SalesRepStatus.training => const Color(0xFF3B82F6),
      SalesRepStatus.terminated => const Color(0xFFEF4444),
    };
  }

  static Color getRoleColor(SalesRole role) {
    return switch (role) {
      SalesRole.sales_director => const Color(0xFF8B5CF6),
      SalesRole.sales_manager => const Color(0xFF3B82F6),
      SalesRole.senior_sales_rep => const Color(0xFF10B981),
      SalesRole.sales_representative => const Color(0xFF06B6D4),
      SalesRole.junior_sales_rep => const Color(0xFFF59E0B),
      SalesRole.account_manager => const Color(0xFFEC4899),
      SalesRole.business_development_manager => const Color(0xFF6366F1),
    };
  }

  // Static method to create empty instance
  static SalesRepresentative empty() {
    return SalesRepresentative(
      id: '',
      employeeNumber: '',
      userId: null,
      personalDetails: PersonalDetails(
        firstName: '',
        lastName: '',
        dateOfBirth: DateTime.now(),
        gender: 'other',
        nationalId: '',
      ),
      contactInformation: ContactInformation(
        workEmail: '',
        personalEmail: '',
        workPhone: '',
        personalPhone: '',
        address: Address(
          street: '',
          city: '',
          state: '',
          postalCode: '',
          country: '',
        ),
      ),
      salesRole: SalesRole.sales_representative,
      salesTargets: SalesTargets(
        monthlyTarget: 0,
        quarterlyTarget: 0,
        annualTarget: 0,
        newCustomersTarget: 0,
        revenueTarget: 0,
        collectionTarget: 0,
      ),
      performance: SalesPerformance(
        totalSales: 0,
        monthlyAverage: 0,
        conversionRate: 0,
        averageDealSize: 0,
        customerSatisfaction: 0,
        retentionRate: 0,
        overallRating: 0,
      ),
      status: SalesRepStatus.active,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      jobInformation: null,
      salesTerritory: null,
    );
  }
}
