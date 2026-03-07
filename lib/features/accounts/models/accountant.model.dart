class Accountant {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? phone;
  final String? employeeNumber;
  final String? jobTitle;
  final String? department;
  final String? employmentType;
  final String? employmentStatus;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePictureUrl;
  final DateTime? hireDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? supervisorId;
  final Map<String, dynamic>? performance;
  final DateTime? lastEvaluationDate;
  final List<dynamic>? systemAccess;
  final List<dynamic>? accountingQualifications;
  final List<dynamic>? documents;
  final double? salary;
  final String? bankName;
  final String? bankAccountNumber;
  final String? taxNumber;
  final String? socialSecurityNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? nationalId;
  final String? workLocation;
  final String? costCenter;
  final List<dynamic>? softwareProficiencies;
  final List<dynamic>? specializedAreas;
  final Map<String, dynamic>? approvalLimits;
  final Map<String, dynamic>? workSchedule;
  final bool? isAuthorizedSignatory;

  Accountant({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.phone,
    this.employeeNumber,
    this.jobTitle,
    this.department,
    this.employmentType,
    this.employmentStatus,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePictureUrl,
    this.hireDate,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.supervisorId,
    this.performance,
    this.lastEvaluationDate,
    this.systemAccess,
    this.accountingQualifications,
    this.documents,
    this.salary,
    this.bankName,
    this.bankAccountNumber,
    this.taxNumber,
    this.socialSecurityNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.nationalId,
    this.workLocation,
    this.costCenter,
    this.softwareProficiencies,
    this.specializedAreas,
    this.approvalLimits,
    this.workSchedule,
    this.isAuthorizedSignatory = false,
  });

  factory Accountant.fromJson(Map<String, dynamic> json) {
    return Accountant(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      phone: json['phone'],
      employeeNumber: json['employeeNumber'],
      jobTitle: json['jobTitle'],
      department: json['department'] ?? 'Accounts',
      employmentType: json['employmentType'],
      employmentStatus: json['employmentStatus'] ?? 'ACTIVE',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      address: json['address'],
      profilePictureUrl: json['profilePictureUrl'],
      hireDate: json['hireDate'] != null
          ? DateTime.tryParse(json['hireDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      supervisorId: json['supervisor'] is String ? json['supervisor'] : json['supervisor']?['_id'],
      performance: json['performance'] is Map ? Map<String, dynamic>.from(json['performance']) : null,
      lastEvaluationDate: json['lastEvaluationDate'] != null
          ? DateTime.tryParse(json['lastEvaluationDate'])
          : null,
      systemAccess: json['systemAccess'] is List ? List<dynamic>.from(json['systemAccess']) : null,
      accountingQualifications: json['accountingQualifications'] is List ? List<dynamic>.from(json['accountingQualifications']) : null,
      documents: json['documents'] is List ? List<dynamic>.from(json['documents']) : null,
      salary: json['salary'] != null
          ? (json['salary'] is double ? json['salary'] : double.tryParse(json['salary'].toString()))
          : null,
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      taxNumber: json['taxNumber'],
      socialSecurityNumber: json['socialSecurityNumber'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      emergencyContactRelationship: json['emergencyContactRelationship'],
      nationalId: json['nationalId'],
      workLocation: json['workLocation'],
      costCenter: json['costCenter'],
      softwareProficiencies: json['softwareProficiencies'] is List ? List<dynamic>.from(json['softwareProficiencies']) : null,
      specializedAreas: json['specializedAreas'] is List ? List<dynamic>.from(json['specializedAreas']) : null,
      approvalLimits: json['approvalLimits'] is Map ? Map<String, dynamic>.from(json['approvalLimits']) : null,
      workSchedule: json['workSchedule'] is Map ? Map<String, dynamic>.from(json['workSchedule']) : null,
      isAuthorizedSignatory: json['isAuthorizedSignatory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isActive': isActive,
      'employmentStatus': employmentStatus ?? 'active',
      'employmentType': employmentType ?? 'full_time',
      'department': department ?? 'Accounts',
    };

    // Required fields for backend (must be provided)
    if (employeeNumber != null && employeeNumber!.isNotEmpty) {
      data['employeeNumber'] = employeeNumber!;
    } else {
      // Generate a temporary employee number if not provided
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 1000).toString().padLeft(3, '0');
      data['employeeNumber'] = 'ACC-${DateTime.now().year}-$random';
    }

    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    }

    if (nationalId != null && nationalId!.isNotEmpty) {
      data['nationalId'] = nationalId!;
    }

    if (hireDate != null) {
      data['hireDate'] = hireDate!.toIso8601String();
    }

    // Phone field is required in backend
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['phone'] = phoneNumber!;
    } else if (phone != null && phone!.isNotEmpty) {
      data['phone'] = phone!;
    } else {
      data['phone'] = '000-0000000'; // Default value for required field
    }

    // Optional fields
    if (gender != null && gender!.isNotEmpty) {
      data['gender'] = gender!;
    }

    if (address != null && address!.isNotEmpty) {
      data['address'] = address!;
    }

    if (jobTitle != null) {
      data['jobTitle'] = jobTitle!;
    }

    if (workLocation != null && workLocation!.isNotEmpty) {
      data['workLocation'] = workLocation!;
    }

    if (costCenter != null && costCenter!.isNotEmpty) {
      data['costCenter'] = costCenter!;
    }

    // Add other optional fields
    if (specializedAreas != null && specializedAreas!.isNotEmpty) {
      data['specializedAreas'] = specializedAreas!;
    }

    if (softwareProficiencies != null && softwareProficiencies!.isNotEmpty) {
      data['softwareProficiencies'] = softwareProficiencies!;
    }

    if (approvalLimits != null) {
      data['approvalLimits'] = approvalLimits!;
    }

    if (workSchedule != null) {
      data['workSchedule'] = workSchedule!;
    }

    if (isAuthorizedSignatory != null) {
      data['isAuthorizedSignatory'] = isAuthorizedSignatory!;
    }

    // Financial fields
    if (salary != null) {
      data['salary'] = salary!;
    }

    if (bankName != null && bankName!.isNotEmpty) {
      data['bankName'] = bankName!;
    }

    if (bankAccountNumber != null && bankAccountNumber!.isNotEmpty) {
      data['bankAccountNumber'] = bankAccountNumber!;
    }

    if (taxNumber != null && taxNumber!.isNotEmpty) {
      data['taxNumber'] = taxNumber!;
    }

    if (socialSecurityNumber != null && socialSecurityNumber!.isNotEmpty) {
      data['socialSecurityNumber'] = socialSecurityNumber!;
    }

    // Emergency contact fields
    if (emergencyContactName != null && emergencyContactName!.isNotEmpty) {
      data['emergencyContactName'] = emergencyContactName!;
    }

    if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty) {
      data['emergencyContactPhone'] = emergencyContactPhone!;
    }

    if (emergencyContactRelationship != null && emergencyContactRelationship!.isNotEmpty) {
      data['emergencyContactRelationship'] = emergencyContactRelationship!;
    }

    // Debug print
    print('=== Accountant.toJson() ===');
    print('Data: $data');
    print('Date of Birth included: ${data.containsKey('dateOfBirth')}');
    print('Employee Number included: ${data.containsKey('employeeNumber')}');
    print('National ID included: ${data.containsKey('nationalId')}');
    print('Hire Date included: ${data.containsKey('hireDate')}');
    print('Phone included: ${data.containsKey('phone')}');
    print('==========================');

    return data;
  }

  Accountant copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? phone,
    String? employeeNumber,
    String? jobTitle,
    String? department,
    String? employmentType,
    String? employmentStatus,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePictureUrl,
    DateTime? hireDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? supervisorId,
    Map<String, dynamic>? performance,
    DateTime? lastEvaluationDate,
    List<dynamic>? systemAccess,
    List<dynamic>? accountingQualifications,
    List<dynamic>? documents,
    double? salary,
    String? bankName,
    String? bankAccountNumber,
    String? taxNumber,
    String? socialSecurityNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    String? nationalId,
    String? workLocation,
    String? costCenter,
    List<dynamic>? softwareProficiencies,
    List<dynamic>? specializedAreas,
    Map<String, dynamic>? approvalLimits,
    Map<String, dynamic>? workSchedule,
    bool? isAuthorizedSignatory,
  }) {
    return Accountant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phone: phone ?? this.phone,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      employmentType: employmentType ?? this.employmentType,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      supervisorId: supervisorId ?? this.supervisorId,
      performance: performance ?? this.performance,
      lastEvaluationDate: lastEvaluationDate ?? this.lastEvaluationDate,
      systemAccess: systemAccess ?? this.systemAccess,
      accountingQualifications: accountingQualifications ?? this.accountingQualifications,
      documents: documents ?? this.documents,
      salary: salary ?? this.salary,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      taxNumber: taxNumber ?? this.taxNumber,
      socialSecurityNumber: socialSecurityNumber ?? this.socialSecurityNumber,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship: emergencyContactRelationship ?? this.emergencyContactRelationship,
      nationalId: nationalId ?? this.nationalId,
      workLocation: workLocation ?? this.workLocation,
      costCenter: costCenter ?? this.costCenter,
      softwareProficiencies: softwareProficiencies ?? this.softwareProficiencies,
      specializedAreas: specializedAreas ?? this.specializedAreas,
      approvalLimits: approvalLimits ?? this.approvalLimits,
      workSchedule: workSchedule ?? this.workSchedule,
      isAuthorizedSignatory: isAuthorizedSignatory ?? this.isAuthorizedSignatory,
    );
  }

  String get fullName => '$firstName $lastName';

  String get displayInfo => '$fullName - ${employeeNumber ?? "No ID"}';

  bool get isEmployed => employmentStatus != 'TERMINATED' && isActive;

  int get yearsOfService {
    if (hireDate == null) return 0;
    final now = DateTime.now();
    return now.year - hireDate!.year;
  }
}

class AccountantFilters {
  final String? search;
  final String? jobTitle;
  final String? department;
  final String? employmentStatus;
  final bool? isActive;

  AccountantFilters({
    this.search,
    this.jobTitle,
    this.department,
    this.employmentStatus,
    this.isActive,
  });

  AccountantFilters copyWith({
    String? search,
    String? jobTitle,
    String? department,
    String? employmentStatus,
    bool? isActive,
  }) {
    return AccountantFilters(
      search: search ?? this.search,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (jobTitle != null && jobTitle!.isNotEmpty) params['jobTitle'] = jobTitle;
    if (department != null && department!.isNotEmpty) params['department'] = department;
    if (employmentStatus != null && employmentStatus!.isNotEmpty) params['employmentStatus'] = employmentStatus;
    if (isActive != null) params['isActive'] = isActive.toString();
    return params;
  }

  bool get hasFilters => search != null || jobTitle != null || department != null || employmentStatus != null || isActive != null;
}