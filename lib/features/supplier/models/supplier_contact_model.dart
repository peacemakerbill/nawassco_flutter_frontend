class SupplierContact {
  final String id;
  final String supplierId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String mobile;
  final String? fax;
  final String preferredContactMethod;
  final bool receiveTenderNotifications;
  final bool receiveNewsletters;
  final bool isAuthorizedSignatory;
  final double? signatoryLimit;
  final bool canSubmitBids;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierContact({
    required this.id,
    required this.supplierId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    required this.mobile,
    this.fax,
    required this.preferredContactMethod,
    required this.receiveTenderNotifications,
    required this.receiveNewsletters,
    required this.isAuthorizedSignatory,
    this.signatoryLimit,
    required this.canSubmitBids,
    required this.isPrimary,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierContact.fromJson(Map<String, dynamic> json) {
    return SupplierContact(
      id: json['_id'] ?? json['id'],
      supplierId: json['supplier'],
      salutation: json['salutation'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      position: json['position'],
      department: json['department'],
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      fax: json['fax'],
      preferredContactMethod: json['preferredContactMethod'] ?? 'email',
      receiveTenderNotifications: json['receiveTenderNotifications'] ?? true,
      receiveNewsletters: json['receiveNewsletters'] ?? false,
      isAuthorizedSignatory: json['isAuthorizedSignatory'] ?? false,
      signatoryLimit: json['signatoryLimit']?.toDouble(),
      canSubmitBids: json['canSubmitBids'] ?? true,
      isPrimary: json['isPrimary'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier': supplierId,
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'fax': fax,
      'preferredContactMethod': preferredContactMethod,
      'receiveTenderNotifications': receiveTenderNotifications,
      'receiveNewsletters': receiveNewsletters,
      'isAuthorizedSignatory': isAuthorizedSignatory,
      'signatoryLimit': signatoryLimit,
      'canSubmitBids': canSubmitBids,
      'isPrimary': isPrimary,
      'isActive': isActive,
    };
  }
}