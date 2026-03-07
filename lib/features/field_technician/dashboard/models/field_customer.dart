import 'package:flutter/material.dart';

enum CustomerType {
  residential('Residential'),
  commercial('Commercial'),
  industrial('Industrial'),
  institutional('Institutional');

  final String displayName;
  const CustomerType(this.displayName);
}

enum ConnectionType {
  standard('Standard'),
  commercial('Commercial'),
  industrial('Industrial'),
  emergency('Emergency');

  final String displayName;
  const ConnectionType(this.displayName);
}

enum AccountStatus {
  active('Active', Colors.green),
  suspended('Suspended', Colors.orange),
  disconnected('Disconnected', Colors.red),
  pending('Pending', Colors.blue);

  final String displayName;
  final Color color;
  const AccountStatus(this.displayName, this.color);
}

enum PaymentStatus {
  paid('Paid', Colors.green),
  pending('Pending', Colors.orange),
  failed('Failed', Colors.red),
  overdue('Overdue', Colors.deepOrange);

  final String displayName;
  final Color color;
  const PaymentStatus(this.displayName, this.color);
}

class CustomerAddress {
  final String street;
  final String city;
  final String zone;
  final String? landmark;
  final String? postalCode;

  CustomerAddress({
    required this.street,
    required this.city,
    required this.zone,
    this.landmark,
    this.postalCode,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) => CustomerAddress(
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    zone: json['zone'] ?? '',
    landmark: json['landmark'],
    postalCode: json['postalCode'],
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'zone': zone,
    if (landmark != null) 'landmark': landmark,
    if (postalCode != null) 'postalCode': postalCode,
  };

  String get fullAddress => '$street, $city - $zone';
}

class LocationDetails {
  final String zone;
  final String? subzone;
  final String district;
  final String region;
  final String? gpsCoordinates;

  LocationDetails({
    required this.zone,
    this.subzone,
    required this.district,
    required this.region,
    this.gpsCoordinates,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) => LocationDetails(
    zone: json['zone'] ?? '',
    subzone: json['subzone'],
    district: json['district'] ?? '',
    region: json['region'] ?? '',
    gpsCoordinates: json['gpsCoordinates'],
  );

  Map<String, dynamic> toJson() => {
    'zone': zone,
    if (subzone != null) 'subzone': subzone,
    'district': district,
    'region': region,
    if (gpsCoordinates != null) 'gpsCoordinates': gpsCoordinates,
  };
}

class Coordinates {
  final double latitude;
  final double longitude;
  final double? accuracy;

  Coordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (accuracy != null) 'accuracy': accuracy,
  };
}

class BillingInformation {
  final double currentBalance;
  final DateTime? lastPaymentDate;
  final double lastPaymentAmount;
  final double averageMonthlyBill;
  final String billingCycle;

  BillingInformation({
    required this.currentBalance,
    this.lastPaymentDate,
    required this.lastPaymentAmount,
    required this.averageMonthlyBill,
    required this.billingCycle,
  });

  factory BillingInformation.fromJson(Map<String, dynamic> json) => BillingInformation(
    currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
    lastPaymentDate: json['lastPaymentDate'] != null
        ? DateTime.parse(json['lastPaymentDate'])
        : null,
    lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble() ?? 0.0,
    averageMonthlyBill: (json['averageMonthlyBill'] as num?)?.toDouble() ?? 0.0,
    billingCycle: json['billingCycle'] ?? 'monthly',
  );

  Map<String, dynamic> toJson() => {
    'currentBalance': currentBalance,
    if (lastPaymentDate != null) 'lastPaymentDate': lastPaymentDate!.toIso8601String(),
    'lastPaymentAmount': lastPaymentAmount,
    'averageMonthlyBill': averageMonthlyBill,
    'billingCycle': billingCycle,
  };
}

class PaymentRecord {
  final DateTime paymentDate;
  final double amount;
  final String method;
  final String reference;
  final PaymentStatus status;

  PaymentRecord({
    required this.paymentDate,
    required this.amount,
    required this.method,
    required this.reference,
    required this.status,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    paymentDate: DateTime.parse(json['paymentDate']),
    amount: (json['amount'] as num).toDouble(),
    method: json['method'] ?? '',
    reference: json['reference'] ?? '',
    status: PaymentStatus.values.firstWhere(
          (e) => e.displayName.toLowerCase() == json['status'].toLowerCase(),
      orElse: () => PaymentStatus.pending,
    ),
  );

  Map<String, dynamic> toJson() => {
    'paymentDate': paymentDate.toIso8601String(),
    'amount': amount,
    'method': method,
    'reference': reference,
    'status': status.name,
  };
}

class ServiceHistory {
  final DateTime serviceDate;
  final String serviceType;
  final String description;
  final String technicianId;
  final String workOrderId;
  final double? rating;
  final String? feedback;

  ServiceHistory({
    required this.serviceDate,
    required this.serviceType,
    required this.description,
    required this.technicianId,
    required this.workOrderId,
    this.rating,
    this.feedback,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) => ServiceHistory(
    serviceDate: DateTime.parse(json['serviceDate']),
    serviceType: json['serviceType'] ?? '',
    description: json['description'] ?? '',
    technicianId: json['technician'] is Map ? json['technician']['_id'] : json['technician'].toString(),
    workOrderId: json['workOrder'] is Map ? json['workOrder']['_id'] : json['workOrder'].toString(),
    rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    feedback: json['feedback'],
  );
}

class CommunicationPreferences {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool billingReminders;
  final bool serviceUpdates;

  CommunicationPreferences({
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.billingReminders = true,
    this.serviceUpdates = true,
  });

  factory CommunicationPreferences.fromJson(Map<String, dynamic> json) => CommunicationPreferences(
    emailNotifications: json['emailNotifications'] ?? true,
    smsNotifications: json['smsNotifications'] ?? true,
    billingReminders: json['billingReminders'] ?? true,
    serviceUpdates: json['serviceUpdates'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'emailNotifications': emailNotifications,
    'smsNotifications': smsNotifications,
    'billingReminders': billingReminders,
    'serviceUpdates': serviceUpdates,
  };
}

class FieldCustomer {
  final String id;
  final String customerNumber;
  final String accountNumber;

  // Personal Information
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String nationalId;

  // Address Information
  final CustomerAddress address;
  final LocationDetails location;
  final Coordinates coordinates;

  // Account Information
  final CustomerType customerType;
  final ConnectionType connectionType;
  final String? meterNumber;
  final AccountStatus accountStatus;

  // Billing Information
  final BillingInformation billing;
  final List<PaymentRecord> paymentHistory;

  // Service Information
  final List<String> serviceRequests;
  final List<String> workOrders;
  final List<ServiceHistory> serviceHistory;

  // Preferences
  final String preferredLanguage;
  final CommunicationPreferences communicationPreferences;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FieldCustomer({
    required this.id,
    required this.customerNumber,
    required this.accountNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.nationalId,
    required this.address,
    required this.location,
    required this.coordinates,
    required this.customerType,
    required this.connectionType,
    this.meterNumber,
    required this.accountStatus,
    required this.billing,
    required this.paymentHistory,
    required this.serviceRequests,
    required this.workOrders,
    required this.serviceHistory,
    required this.preferredLanguage,
    required this.communicationPreferences,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get formattedBalance => 'KSh ${currentBalance.toStringAsFixed(2)}';

  double get currentBalance => billing.currentBalance;

  bool get hasOutstandingBalance => currentBalance > 0;

  factory FieldCustomer.fromJson(Map<String, dynamic> json) {
    return FieldCustomer(
      id: json['_id'] ?? '',
      customerNumber: json['customerNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
      address: CustomerAddress.fromJson(json['address'] ?? {}),
      location: LocationDetails.fromJson(json['location'] ?? {}),
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      customerType: CustomerType.values.firstWhere(
            (e) => e.name == (json['customerType'] ?? 'residential'),
        orElse: () => CustomerType.residential,
      ),
      connectionType: ConnectionType.values.firstWhere(
            (e) => e.name == (json['connectionType'] ?? 'standard'),
        orElse: () => ConnectionType.standard,
      ),
      meterNumber: json['meterNumber'],
      accountStatus: AccountStatus.values.firstWhere(
            (e) => e.name == (json['accountStatus'] ?? 'active'),
        orElse: () => AccountStatus.active,
      ),
      billing: BillingInformation.fromJson(json['controller'] ?? {}),
      paymentHistory: (json['paymentHistory'] as List? ?? [])
          .map((p) => PaymentRecord.fromJson(p))
          .toList(),
      serviceRequests: (json['serviceRequests'] as List? ?? [])
          .map((id) => id.toString())
          .toList(),
      workOrders: (json['workOrders'] as List? ?? [])
          .map((id) => id.toString())
          .toList(),
      serviceHistory: (json['serviceHistory'] as List? ?? [])
          .map((s) => ServiceHistory.fromJson(s))
          .toList(),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      communicationPreferences: CommunicationPreferences.fromJson(
        json['communicationPreferences'] ?? {},
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'nationalId': nationalId,
      'address': address.toJson(),
      'location': location.toJson(),
      'coordinates': coordinates.toJson(),
      'customerType': customerType.name,
      'connectionType': connectionType.name,
      if (meterNumber != null) 'meterNumber': meterNumber,
      'accountStatus': accountStatus.name,
      'controller': billing.toJson(),
      'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
      'preferredLanguage': preferredLanguage,
      'communicationPreferences': communicationPreferences.toJson(),
      'isActive': isActive,
    };
  }

  FieldCustomer copyWith({
    String? id,
    String? customerNumber,
    String? accountNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? nationalId,
    CustomerAddress? address,
    LocationDetails? location,
    Coordinates? coordinates,
    CustomerType? customerType,
    ConnectionType? connectionType,
    String? meterNumber,
    AccountStatus? accountStatus,
    BillingInformation? billing,
    List<PaymentRecord>? paymentHistory,
    List<String>? serviceRequests,
    List<String>? workOrders,
    List<ServiceHistory>? serviceHistory,
    String? preferredLanguage,
    CommunicationPreferences? communicationPreferences,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldCustomer(
      id: id ?? this.id,
      customerNumber: customerNumber ?? this.customerNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      customerType: customerType ?? this.customerType,
      connectionType: connectionType ?? this.connectionType,
      meterNumber: meterNumber ?? this.meterNumber,
      accountStatus: accountStatus ?? this.accountStatus,
      billing: billing ?? this.billing,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      serviceRequests: serviceRequests ?? this.serviceRequests,
      workOrders: workOrders ?? this.workOrders,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      communicationPreferences: communicationPreferences ?? this.communicationPreferences,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}