import 'employee_model.dart';

class Department {
  final String id;
  final String departmentCode;
  final String name;
  final String description;
  final String headId;
  final Employee? head;
  final String? parentDepartmentId;
  final Department? parentDepartment;
  final double budget;
  final String location;
  final String contactEmail;
  final String contactPhone;
  final bool isActive;
  final String createdById;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int employeeCount;
  final List<Employee>? employees;

  Department({
    required this.id,
    required this.departmentCode,
    required this.name,
    required this.description,
    required this.headId,
    this.head,
    this.parentDepartmentId,
    this.parentDepartment,
    required this.budget,
    required this.location,
    required this.contactEmail,
    required this.contactPhone,
    required this.isActive,
    required this.createdById,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.employeeCount = 0,
    this.employees,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['_id'] ?? json['id'] ?? '',
      departmentCode: json['departmentCode'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      headId: json['head'] is String ? json['head'] : json['head']?['_id'] ?? '',
      head: json['head'] is Map && json['head'].isNotEmpty
          ? _extractEmployeeFromHead(json['head'])
          : null,
      parentDepartmentId: json['parentDepartment'] is String
          ? json['parentDepartment']
          : json['parentDepartment']?['_id'],
      parentDepartment: json['parentDepartment'] is Map && json['parentDepartment'].isNotEmpty
          ? Department.fromJson(json['parentDepartment'])
          : null,
      budget: (json['budget'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      isActive: json['isActive'] ?? true,
      createdById: json['createdBy'] is String ? json['createdBy'] : json['createdBy']?['_id'] ?? '',
      createdByName: json['createdBy'] is Map && json['createdBy'].isNotEmpty
          ? '${json['createdBy']['firstName'] ?? ''} ${json['createdBy']['lastName'] ?? ''}'.trim()
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      employeeCount: json['employeeCount'] ?? 0,
      employees: json['employees'] != null
          ? (json['employees'] as List).map((e) => Employee.fromJson(e)).toList()
          : null,
    );
  }

  static Employee _extractEmployeeFromHead(Map<String, dynamic> headData) {
    // Create a simplified employee from head data
    final personalDetails = PersonalDetails(
      firstName: headData['firstName'] ?? '',
      lastName: headData['lastName'] ?? '',
      middleName: headData['middleName'],
      dateOfBirth: DateTime.now(), // Placeholder
      gender: Gender.male, // Placeholder
      maritalStatus: MaritalStatus.single, // Placeholder
      nationality: '',
      nationalId: '',
      taxNumber: '',
      socialSecurityNumber: '',
    );

    return Employee(
      id: headData['_id'] ?? '',
      employeeNumber: headData['employeeNumber'] ?? '',
      userId: headData['user'] ?? '',
      personalDetails: personalDetails,
      hireDate: DateTime.now(),
      employmentType: EmploymentType.permanent,
      employmentStatus: EmploymentStatus.active,
      employmentCategory: EmploymentCategory.management,
      department: headData['department'] ?? '',
      jobTitle: headData['jobTitle'] ?? '',
      jobGrade: headData['jobGrade'] ?? '',
      personalEmail: '',
      workEmail: '',
      personalPhone: '',
      basicSalary: 0,
      salaryCurrency: 'KES',
      netSalary: 0,
      workSchedule: {},
      leaveBalance: {},
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentCode': departmentCode,
      'name': name,
      'description': description,
      'head': headId,
      'parentDepartment': parentDepartmentId,
      'budget': budget,
      'location': location,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'isActive': isActive,
    };
  }

  Department copyWith({
    String? id,
    String? departmentCode,
    String? name,
    String? description,
    String? headId,
    Employee? head,
    String? parentDepartmentId,
    Department? parentDepartment,
    double? budget,
    String? location,
    String? contactEmail,
    String? contactPhone,
    bool? isActive,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? employeeCount,
    List<Employee>? employees,
  }) {
    return Department(
      id: id ?? this.id,
      departmentCode: departmentCode ?? this.departmentCode,
      name: name ?? this.name,
      description: description ?? this.description,
      headId: headId ?? this.headId,
      head: head ?? this.head,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      parentDepartment: parentDepartment ?? this.parentDepartment,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      isActive: isActive ?? this.isActive,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      employeeCount: employeeCount ?? this.employeeCount,
      employees: employees ?? this.employees,
    );
  }

  String get headName {
    if (head != null) {
      return head!.fullName;
    }
    return 'Not Assigned';
  }

  String get parentDepartmentName {
    return parentDepartment?.name ?? 'None';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Department &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Department(id: $id, name: $name, code: $departmentCode)';
  }
}

class DepartmentStats {
  final int totalDepartments;
  final int activeDepartments;
  final List<Map<String, dynamic>> departmentEmployeeStats;
  final List<Map<String, dynamic>> departmentBudgetStats;

  DepartmentStats({
    required this.totalDepartments,
    required this.activeDepartments,
    required this.departmentEmployeeStats,
    required this.departmentBudgetStats,
  });

  factory DepartmentStats.fromJson(Map<String, dynamic> json) {
    return DepartmentStats(
      totalDepartments: json['totalDepartments'] ?? 0,
      activeDepartments: json['activeDepartments'] ?? 0,
      departmentEmployeeStats: List<Map<String, dynamic>>.from(
          json['departmentEmployeeStats'] ?? []),
      departmentBudgetStats: List<Map<String, dynamic>>.from(
          json['departmentBudgetStats'] ?? []),
    );
  }
}

class DepartmentHierarchy {
  final String id;
  final String name;
  final String departmentCode;
  final Employee? head;
  final List<DepartmentHierarchy> children;
  final int employeeCount;

  DepartmentHierarchy({
    required this.id,
    required this.name,
    required this.departmentCode,
    this.head,
    this.children = const [],
    this.employeeCount = 0,
  });

  factory DepartmentHierarchy.fromJson(Map<String, dynamic> json) {
    return DepartmentHierarchy(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      departmentCode: json['departmentCode'] ?? '',
      head: json['head'] is Map && json['head'].isNotEmpty
          ? Department._extractEmployeeFromHead(json['head'])
          : null,
      children: (json['children'] as List?)?.map((child) =>
          DepartmentHierarchy.fromJson(child)).toList() ?? [],
      employeeCount: json['employeeCount'] ?? 0,
    );
  }

  String get headName {
    return head?.fullName ?? 'Not Assigned';
  }
}