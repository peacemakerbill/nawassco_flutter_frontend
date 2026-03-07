import 'package:flutter/foundation.dart';

// ============================================
// ENUMS (From Backend - Exact Match)
// ============================================

enum CustomerType {
  residential('Residential'),
  commercial('Commercial'),
  industrial('Industrial'),
  institutional('Institutional'),
  government('Government');

  final String displayName;

  const CustomerType(this.displayName);

  static CustomerType fromString(String value) {
    return CustomerType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => CustomerType.residential,
    );
  }
}

enum AddressType {
  billing('Billing'),
  service('Service'),
  mailing('Mailing'),
  physical('Physical');

  final String displayName;

  const AddressType(this.displayName);
}

enum ContactMethod {
  email('Email'),
  phone('Phone'),
  sms('SMS'),
  whatsapp('WhatsApp'),
  in_person('In Person');

  final String displayName;

  const ContactMethod(this.displayName);
}

enum BillingCycle {
  monthly('Monthly'),
  bi_monthly('Bi-Monthly'),
  quarterly('Quarterly');

  final String displayName;

  const BillingCycle(this.displayName);
}

enum InvoiceDelivery {
  email('Email'),
  post('Post'),
  online('Online'),
  both('Both');

  final String displayName;

  const InvoiceDelivery(this.displayName);
}

enum PaymentMethod {
  bank_transfer('Bank Transfer'),
  credit_card('Credit Card'),
  debit_card('Debit Card'),
  mobile_money('Mobile Money'),
  cash('Cash');

  final String displayName;

  const PaymentMethod(this.displayName);
}

enum ServiceType {
  water_supply('Water Supply'),
  sanitation('Sanitation'),
  bulk_water('Bulk Water'),
  metered('Metered'),
  unmetered('Unmetered');

  final String displayName;

  const ServiceType(this.displayName);
}

enum ServiceStatus {
  active('Active'),
  pending('Pending'),
  suspended('Suspended'),
  disconnected('Disconnected'),
  closed('Closed');

  final String displayName;

  const ServiceStatus(this.displayName);
}

enum MeterStatus {
  active('Active'),
  inactive('Inactive'),
  faulty('Faulty'),
  removed('Removed'),
  under_maintenance('Under Maintenance');

  final String displayName;

  const MeterStatus(this.displayName);
}

enum ConnectionType {
  new_connection('New Connection'),
  existing_connection('Existing Connection'),
  temporary_connection('Temporary Connection');

  final String displayName;

  const ConnectionType(this.displayName);
}

enum CustomerSegment {
  premium('Premium'),
  standard('Standard'),
  economy('Economy'),
  corporate('Corporate'),
  government('Government');

  final String displayName;

  const CustomerSegment(this.displayName);
}

enum PriorityLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String displayName;

  const PriorityLevel(this.displayName);
}

enum CustomerStatus {
  prospect('Prospect'),
  active('Active'),
  inactive('Inactive'),
  suspended('Suspended'),
  blacklisted('Blacklisted');

  final String displayName;

  const CustomerStatus(this.displayName);
}

enum SalesSource {
  walk_in('Walk-in'),
  referral('Referral'),
  telemarketing('Telemarketing'),
  online('Online'),
  field_sales('Field Sales'),
  partner('Partner');

  final String displayName;

  const SalesSource(this.displayName);
}

enum DocumentType {
  identification('Identification'),
  contract('Contract'),
  utility_bill('Utility Bill'),
  business_registration('Business Registration'),
  tax_certificate('Tax Certificate');

  final String displayName;

  const DocumentType(this.displayName);
}

enum DocumentStatus {
  pending('Pending'),
  verified('Verified'),
  rejected('Rejected'),
  expired('Expired');

  final String displayName;

  const DocumentStatus(this.displayName);
}

// ============================================
// SUB-MODELS
// ============================================

@immutable
class Coordinates {
  final double? latitude;
  final double? longitude;

  const Coordinates({
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
  );
}

@immutable
class CustomerAddress {
  final String id;
  final AddressType type;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isPrimary;
  final Coordinates? coordinates;

  const CustomerAddress({
    required this.id,
    required this.type,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isPrimary = false,
    this.coordinates,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'type': type.name,
    'addressLine1': addressLine1,
    if (addressLine2 != null) 'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'isPrimary': isPrimary,
    if (coordinates != null) 'coordinates': coordinates!.toJson(),
  };

  factory CustomerAddress.fromJson(Map<String, dynamic> json) =>
      CustomerAddress(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        type: AddressType.values.firstWhere(
              (e) => e.name == json['type'],
          orElse: () => AddressType.physical,
        ),
        addressLine1: json['addressLine1'] as String? ?? '',
        addressLine2: json['addressLine2'] as String?,
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        country: json['country'] as String? ?? '',
        isPrimary: json['isPrimary'] as bool? ?? false,
        coordinates: json['coordinates'] != null
            ? Coordinates.fromJson(json['coordinates'])
            : null,
      );

  CustomerAddress copyWith({
    String? id,
    AddressType? type,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isPrimary,
    Coordinates? coordinates,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      type: type ?? this.type,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isPrimary: isPrimary ?? this.isPrimary,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}

@immutable
class ContactPerson {
  final String id;
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final String email;
  final String phone;
  final bool isPrimary;
  final String? department;

  const ContactPerson({
    required this.id,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.email,
    required this.phone,
    this.isPrimary = false,
    this.department,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'salutation': salutation,
    'firstName': firstName,
    'lastName': lastName,
    'position': position,
    'email': email,
    'phone': phone,
    'isPrimary': isPrimary,
    if (department != null) 'department': department,
  };

  factory ContactPerson.fromJson(Map<String, dynamic> json) => ContactPerson(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    salutation: json['salutation'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    position: json['position'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    isPrimary: json['isPrimary'] as bool? ?? false,
    department: json['department'] as String?,
  );

  ContactPerson copyWith({
    String? id,
    String? salutation,
    String? firstName,
    String? lastName,
    String? position,
    String? email,
    String? phone,
    bool? isPrimary,
    String? department,
  }) {
    return ContactPerson(
      id: id ?? this.id,
      salutation: salutation ?? this.salutation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
      department: department ?? this.department,
    );
  }
}

@immutable
class CommunicationPreferences {
  final ContactMethod preferredContactMethod;
  final bool receiveMarketing;
  final bool receiveSMS;
  final bool receiveEmail;
  final String language;

  const CommunicationPreferences({
    this.preferredContactMethod = ContactMethod.email,
    this.receiveMarketing = false,
    this.receiveSMS = true,
    this.receiveEmail = true,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
    'preferredContactMethod': preferredContactMethod.name,
    'receiveMarketing': receiveMarketing,
    'receiveSMS': receiveSMS,
    'receiveEmail': receiveEmail,
    'language': language,
  };

  factory CommunicationPreferences.fromJson(Map<String, dynamic> json) =>
      CommunicationPreferences(
        preferredContactMethod: ContactMethod.values.firstWhere(
              (e) => e.name == json['preferredContactMethod'],
          orElse: () => ContactMethod.email,
        ),
        receiveMarketing: json['receiveMarketing'] as bool? ?? false,
        receiveSMS: json['receiveSMS'] as bool? ?? true,
        receiveEmail: json['receiveEmail'] as bool? ?? true,
        language: json['language'] as String? ?? 'en',
      );
}

@immutable
class BusinessDetails {
  final String? registrationNumber;
  final String? taxId;
  final String? businessType;
  final int? numberOfEmployees;
  final double? annualRevenue;
  final String? industry;

  const BusinessDetails({
    this.registrationNumber,
    this.taxId,
    this.businessType,
    this.numberOfEmployees,
    this.annualRevenue,
    this.industry,
  });

  Map<String, dynamic> toJson() => {
    if (registrationNumber != null) 'registrationNumber': registrationNumber,
    if (taxId != null) 'taxId': taxId,
    if (businessType != null) 'businessType': businessType,
    if (numberOfEmployees != null) 'numberOfEmployees': numberOfEmployees,
    if (annualRevenue != null) 'annualRevenue': annualRevenue,
    if (industry != null) 'industry': industry,
  };

  factory BusinessDetails.fromJson(Map<String, dynamic> json) =>
      BusinessDetails(
        registrationNumber: json['registrationNumber'] as String?,
        taxId: json['taxId'] as String?,
        businessType: json['businessType'] as String?,
        numberOfEmployees: json['numberOfEmployees'] as int?,
        annualRevenue: json['annualRevenue'] != null
            ? (json['annualRevenue'] as num).toDouble()
            : null,
        industry: json['industry'] as String?,
      );
}

@immutable
class BankDetails {
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? branchCode;

  const BankDetails({
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.branchCode,
  });

  Map<String, dynamic> toJson() => {
    if (bankName != null) 'bankName': bankName,
    if (accountName != null) 'accountName': accountName,
    if (accountNumber != null) 'accountNumber': accountNumber,
    if (branchCode != null) 'branchCode': branchCode,
  };

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    bankName: json['bankName'] as String?,
    accountName: json['accountName'] as String?,
    accountNumber: json['accountNumber'] as String?,
    branchCode: json['branchCode'] as String?,
  );
}

@immutable
class PaymentTerms {
  final int netDays;
  final int? discountDays;
  final double? discountPercentage;
  final double latePaymentFee;

  const PaymentTerms({
    this.netDays = 30,
    this.discountDays,
    this.discountPercentage,
    this.latePaymentFee = 0,
  });

  Map<String, dynamic> toJson() => {
    'netDays': netDays,
    if (discountDays != null) 'discountDays': discountDays,
    if (discountPercentage != null)
      'discountPercentage': discountPercentage,
    'latePaymentFee': latePaymentFee,
  };

  factory PaymentTerms.fromJson(Map<String, dynamic> json) => PaymentTerms(
    netDays: json['netDays'] as int? ?? 30,
    discountDays: json['discountDays'] as int?,
    discountPercentage: json['discountPercentage'] != null
        ? (json['discountPercentage'] as num).toDouble()
        : null,
    latePaymentFee: json['latePaymentFee'] != null
        ? (json['latePaymentFee'] as num).toDouble()
        : 0,
  );
}

@immutable
class BillingInformation {
  final BillingCycle billingCycle;
  final InvoiceDelivery invoiceDelivery;
  final PaymentMethod paymentMethod;
  final BankDetails? bankDetails;

  const BillingInformation({
    this.billingCycle = BillingCycle.monthly,
    this.invoiceDelivery = InvoiceDelivery.email,
    required this.paymentMethod,
    this.bankDetails,
  });

  Map<String, dynamic> toJson() => {
    'billingCycle': billingCycle.name,
    'invoiceDelivery': invoiceDelivery.name,
    'paymentMethod': paymentMethod.name,
    if (bankDetails != null) 'bankDetails': bankDetails!.toJson(),
  };

  factory BillingInformation.fromJson(Map<String, dynamic> json) =>
      BillingInformation(
        billingCycle: BillingCycle.values.firstWhere(
              (e) => e.name == json['billingCycle'],
          orElse: () => BillingCycle.monthly,
        ),
        invoiceDelivery: InvoiceDelivery.values.firstWhere(
              (e) => e.name == json['invoiceDelivery'],
          orElse: () => InvoiceDelivery.email,
        ),
        paymentMethod: PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
          orElse: () => PaymentMethod.bank_transfer,
        ),
        bankDetails: json['bankDetails'] != null
            ? BankDetails.fromJson(json['bankDetails'])
            : null,
      );
}

@immutable
class CustomerService {
  final String id;
  final ServiceType serviceType;
  final String serviceNumber;
  final DateTime startDate;
  final ServiceStatus status;
  final String tariff;
  final double monthlyEstimate;
  final double? lastReading;
  final DateTime? lastReadingDate;

  const CustomerService({
    required this.id,
    required this.serviceType,
    required this.serviceNumber,
    required this.startDate,
    this.status = ServiceStatus.active,
    required this.tariff,
    required this.monthlyEstimate,
    this.lastReading,
    this.lastReadingDate,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'serviceType': serviceType.name,
    'serviceNumber': serviceNumber,
    'startDate': startDate.toIso8601String(),
    'status': status.name,
    'tariff': tariff,
    'monthlyEstimate': monthlyEstimate,
    if (lastReading != null) 'lastReading': lastReading,
    if (lastReadingDate != null)
      'lastReadingDate': lastReadingDate!.toIso8601String(),
  };

  factory CustomerService.fromJson(Map<String, dynamic> json) =>
      CustomerService(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        serviceType: ServiceType.values.firstWhere(
              (e) => e.name == json['serviceType'],
          orElse: () => ServiceType.water_supply,
        ),
        serviceNumber: json['serviceNumber'] as String? ?? '',
        startDate: DateTime.parse(json['startDate'] as String),
        status: ServiceStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => ServiceStatus.active,
        ),
        tariff: json['tariff'] as String? ?? '',
        monthlyEstimate: (json['monthlyEstimate'] as num?)?.toDouble() ?? 0.0,
        lastReading: json['lastReading'] != null
            ? (json['lastReading'] as num).toDouble()
            : null,
        lastReadingDate: json['lastReadingDate'] != null
            ? DateTime.parse(json['lastReadingDate'] as String)
            : null,
      );
}

@immutable
class CustomerMeter {
  final String id;
  final String meterNumber;
  final String meterType;
  final DateTime installationDate;
  final String location;
  final double initialReading;
  final double? currentReading;
  final DateTime? lastReadingDate;
  final MeterStatus status;

  const CustomerMeter({
    required this.id,
    required this.meterNumber,
    required this.meterType,
    required this.installationDate,
    required this.location,
    required this.initialReading,
    this.currentReading,
    this.lastReadingDate,
    this.status = MeterStatus.active,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'meterNumber': meterNumber,
    'meterType': meterType,
    'installationDate': installationDate.toIso8601String(),
    'location': location,
    'initialReading': initialReading,
    if (currentReading != null) 'currentReading': currentReading,
    if (lastReadingDate != null)
      'lastReadingDate': lastReadingDate!.toIso8601String(),
    'status': status.name,
  };

  factory CustomerMeter.fromJson(Map<String, dynamic> json) => CustomerMeter(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    meterNumber: json['meterNumber'] as String? ?? '',
    meterType: json['meterType'] as String? ?? '',
    installationDate: DateTime.parse(json['installationDate'] as String),
    location: json['location'] as String? ?? '',
    initialReading: (json['initialReading'] as num?)?.toDouble() ?? 0.0,
    currentReading: json['currentReading'] != null
        ? (json['currentReading'] as num).toDouble()
        : null,
    lastReadingDate: json['lastReadingDate'] != null
        ? DateTime.parse(json['lastReadingDate'] as String)
        : null,
    status: MeterStatus.values.firstWhere(
          (e) => e.name == json['status'],
      orElse: () => MeterStatus.active,
    ),
  );
}

@immutable
class ConnectionDetails {
  final DateTime connectionDate;
  final ConnectionType connectionType;
  final String? pipeSize;
  final String? pressureZone;
  final String? waterSource;
  final String? previousProvider;

  const ConnectionDetails({
    required this.connectionDate,
    required this.connectionType,
    this.pipeSize,
    this.pressureZone,
    this.waterSource,
    this.previousProvider,
  });

  Map<String, dynamic> toJson() => {
    'connectionDate': connectionDate.toIso8601String(),
    'connectionType': connectionType.name,
    if (pipeSize != null) 'pipeSize': pipeSize,
    if (pressureZone != null) 'pressureZone': pressureZone,
    if (waterSource != null) 'waterSource': waterSource,
    if (previousProvider != null) 'previousProvider': previousProvider,
  };

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) =>
      ConnectionDetails(
        connectionDate: DateTime.parse(json['connectionDate'] as String),
        connectionType: ConnectionType.values.firstWhere(
              (e) => e.name == json['connectionType'],
          orElse: () => ConnectionType.new_connection,
        ),
        pipeSize: json['pipeSize'] as String?,
        pressureZone: json['pressureZone'] as String?,
        waterSource: json['waterSource'] as String?,
        previousProvider: json['previousProvider'] as String?,
      );
}

@immutable
class CustomerDocument {
  final String id;
  final DocumentType documentType;
  final String documentName;
  final String documentUrl;
  final DateTime uploadDate;
  final DateTime? expiryDate;
  final DocumentStatus status;

  const CustomerDocument({
    required this.id,
    required this.documentType,
    required this.documentName,
    required this.documentUrl,
    required this.uploadDate,
    this.expiryDate,
    this.status = DocumentStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'documentType': documentType.name,
    'documentName': documentName,
    'documentUrl': documentUrl,
    'uploadDate': uploadDate.toIso8601String(),
    if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
    'status': status.name,
  };

  factory CustomerDocument.fromJson(Map<String, dynamic> json) =>
      CustomerDocument(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        documentType: DocumentType.values.firstWhere(
              (e) => e.name == json['documentType'],
          orElse: () => DocumentType.identification,
        ),
        documentName: json['documentName'] as String? ?? '',
        documentUrl: json['documentUrl'] as String? ?? '',
        uploadDate: DateTime.parse(json['uploadDate'] as String),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        status: DocumentStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => DocumentStatus.pending,
        ),
      );
}

// ============================================
// MAIN CUSTOMER MODEL
// ============================================

@immutable
class Customer {
  final String id;
  final String customerNumber;
  final CustomerType customerType;

  // Basic Information
  final String? companyName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? nationalId;

  // Contact Information
  final List<CustomerAddress> addresses;
  final List<ContactPerson> contactPersons;
  final CommunicationPreferences communicationPreferences;

  // Business Information
  final BusinessDetails? businessDetails;
  final String? industry;
  final DateTime customerSince;

  // Billing & Payment
  final BillingInformation billingInformation;
  final PaymentTerms paymentTerms;
  final double creditLimit;
  final double currentBalance;

  // Service Information
  final List<CustomerService> services;
  final List<CustomerMeter> meters;
  final ConnectionDetails connectionDetails;

  // Classification
  final CustomerSegment customerSegment;
  final PriorityLevel priorityLevel;
  final CustomerStatus status;

  // Sales Information
  final String? accountManagerId;
  final SalesSource salesSource;
  final String? referralSource;

  // Documents
  final List<CustomerDocument> documents;

  // Metadata
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.customerNumber,
    required this.customerType,
    this.companyName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.nationalId,
    this.addresses = const [],
    this.contactPersons = const [],
    required this.communicationPreferences,
    this.businessDetails,
    this.industry,
    required this.customerSince,
    required this.billingInformation,
    required this.paymentTerms,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.services = const [],
    this.meters = const [],
    required this.connectionDetails,
    required this.customerSegment,
    this.priorityLevel = PriorityLevel.medium,
    this.status = CustomerStatus.prospect,
    this.accountManagerId,
    required this.salesSource,
    this.referralSource,
    this.documents = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get displayName => companyName ?? fullName;

  String get formattedBalance => 'KES ${currentBalance.toStringAsFixed(2)}';

  bool get hasOverdueBalance => currentBalance > creditLimit;

  bool get isCommercial => customerType == CustomerType.commercial;

  bool get isGovernment => customerType == CustomerType.government;

  bool get isIndustrial => customerType == CustomerType.industrial;

  bool get isResidential => customerType == CustomerType.residential;

  bool get isInstitutional => customerType == CustomerType.institutional;

  CustomerAddress? get primaryAddress {
    try {
      return addresses.firstWhere((addr) => addr.isPrimary);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  ContactPerson? get primaryContact {
    try {
      return contactPersons.firstWhere((contact) => contact.isPrimary);
    } catch (e) {
      return contactPersons.isNotEmpty ? contactPersons.first : null;
    }
  }

  List<CustomerService> get activeServices =>
      services.where((s) => s.status == ServiceStatus.active).toList();

  List<CustomerMeter> get activeMeters =>
      meters.where((m) => m.status == MeterStatus.active).toList();

  Map<String, dynamic> toJson() => {
    '_id': id,
    'customerNumber': customerNumber,
    'customerType': customerType.name,
    if (companyName != null) 'companyName': companyName,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    if (nationalId != null) 'nationalId': nationalId,
    'addresses': addresses.map((addr) => addr.toJson()).toList(),
    'contactPersons': contactPersons.map((cp) => cp.toJson()).toList(),
    'communicationPreferences': communicationPreferences.toJson(),
    if (businessDetails != null)
      'businessDetails': businessDetails!.toJson(),
    if (industry != null) 'industry': industry,
    'customerSince': customerSince.toIso8601String(),
    'billingInformation': billingInformation.toJson(),
    'paymentTerms': paymentTerms.toJson(),
    'creditLimit': creditLimit,
    'currentBalance': currentBalance,
    'services': services.map((s) => s.toJson()).toList(),
    'meters': meters.map((m) => m.toJson()).toList(),
    'connectionDetails': connectionDetails.toJson(),
    'customerSegment': customerSegment.name,
    'priorityLevel': priorityLevel.name,
    'status': status.name,
    if (accountManagerId != null) 'accountManager': accountManagerId,
    'salesSource': salesSource.name,
    if (referralSource != null) 'referralSource': referralSource,
    'documents': documents.map((doc) => doc.toJson()).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) {
    try {
      return Customer(
        id: json['_id']?.toString() ?? '',
        customerNumber: json['customerNumber'] as String? ?? '',
        customerType: CustomerType.values.firstWhere(
              (e) => e.name == json['customerType'],
          orElse: () => CustomerType.residential,
        ),
        companyName: json['companyName'] as String?,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        nationalId: json['nationalId'] as String?,
        addresses: (json['addresses'] as List<dynamic>?)
            ?.map((addr) => CustomerAddress.fromJson(addr))
            .toList() ??
            const [],
        contactPersons: (json['contactPersons'] as List<dynamic>?)
            ?.map((cp) => ContactPerson.fromJson(cp))
            .toList() ??
            const [],
        communicationPreferences: CommunicationPreferences.fromJson(
            json['communicationPreferences'] as Map<String, dynamic>),
        businessDetails: json['businessDetails'] != null
            ? BusinessDetails.fromJson(
            json['businessDetails'] as Map<String, dynamic>)
            : null,
        industry: json['industry'] as String?,
        customerSince: DateTime.parse(json['customerSince'] as String),
        billingInformation: BillingInformation.fromJson(
            json['billingInformation'] as Map<String, dynamic>),
        paymentTerms:
        PaymentTerms.fromJson(json['paymentTerms'] as Map<String, dynamic>),
        creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0,
        currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
        services: (json['services'] as List<dynamic>?)
            ?.map((s) => CustomerService.fromJson(s))
            .toList() ??
            const [],
        meters: (json['meters'] as List<dynamic>?)
            ?.map((m) => CustomerMeter.fromJson(m))
            .toList() ??
            const [],
        connectionDetails: ConnectionDetails.fromJson(
            json['connectionDetails'] as Map<String, dynamic>),
        customerSegment: CustomerSegment.values.firstWhere(
              (e) => e.name == json['customerSegment'],
          orElse: () => CustomerSegment.standard,
        ),
        priorityLevel: PriorityLevel.values.firstWhere(
              (e) => e.name == json['priorityLevel'],
          orElse: () => PriorityLevel.medium,
        ),
        status: CustomerStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => CustomerStatus.prospect,
        ),
        accountManagerId: json['accountManager'] as String?,
        salesSource: SalesSource.values.firstWhere(
              (e) => e.name == json['salesSource'],
          orElse: () => SalesSource.walk_in,
        ),
        referralSource: json['referralSource'] as String?,
        documents: (json['documents'] as List<dynamic>?)
            ?.map((doc) => CustomerDocument.fromJson(doc))
            .toList() ??
            const [],
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e, stack) {
      print('Error parsing Customer: $e');
      print('Stack: $stack');
      print('JSON: $json');
      rethrow;
    }
  }

  Customer copyWith({
    String? id,
    String? customerNumber,
    CustomerType? customerType,
    String? companyName,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nationalId,
    List<CustomerAddress>? addresses,
    List<ContactPerson>? contactPersons,
    CommunicationPreferences? communicationPreferences,
    BusinessDetails? businessDetails,
    String? industry,
    DateTime? customerSince,
    BillingInformation? billingInformation,
    PaymentTerms? paymentTerms,
    double? creditLimit,
    double? currentBalance,
    List<CustomerService>? services,
    List<CustomerMeter>? meters,
    ConnectionDetails? connectionDetails,
    CustomerSegment? customerSegment,
    PriorityLevel? priorityLevel,
    CustomerStatus? status,
    String? accountManagerId,
    SalesSource? salesSource,
    String? referralSource,
    List<CustomerDocument>? documents,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerNumber: customerNumber ?? this.customerNumber,
      customerType: customerType ?? this.customerType,
      companyName: companyName ?? this.companyName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      addresses: addresses ?? this.addresses,
      contactPersons: contactPersons ?? this.contactPersons,
      communicationPreferences:
      communicationPreferences ?? this.communicationPreferences,
      businessDetails: businessDetails ?? this.businessDetails,
      industry: industry ?? this.industry,
      customerSince: customerSince ?? this.customerSince,
      billingInformation: billingInformation ?? this.billingInformation,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      services: services ?? this.services,
      meters: meters ?? this.meters,
      connectionDetails: connectionDetails ?? this.connectionDetails,
      customerSegment: customerSegment ?? this.customerSegment,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      status: status ?? this.status,
      accountManagerId: accountManagerId ?? this.accountManagerId,
      salesSource: salesSource ?? this.salesSource,
      referralSource: referralSource ?? this.referralSource,
      documents: documents ?? this.documents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Customer &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              customerNumber == other.customerNumber;

  @override
  int get hashCode => id.hashCode ^ customerNumber.hashCode;
}

// ============================================
// UTILITY CLASSES
// ============================================

class CustomerFilters {
  final CustomerStatus? status;
  final CustomerType? customerType;
  final CustomerSegment? customerSegment;
  final String? search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final PriorityLevel? priorityLevel;

  const CustomerFilters({
    this.status,
    this.customerType,
    this.customerSegment,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.priorityLevel,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status!.name;
    if (customerType != null) params['customerType'] = customerType!.name;
    if (customerSegment != null)
      params['customerSegment'] = customerSegment!.name;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (dateFrom != null) params['dateFrom'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo!.toIso8601String();
    if (priorityLevel != null) params['priorityLevel'] = priorityLevel!.name;
    return params;
  }

  CustomerFilters copyWith({
    CustomerStatus? status,
    CustomerType? customerType,
    CustomerSegment? customerSegment,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    PriorityLevel? priorityLevel,
  }) {
    return CustomerFilters(
      status: status ?? this.status,
      customerType: customerType ?? this.customerType,
      customerSegment: customerSegment ?? this.customerSegment,
      search: search ?? this.search,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }
}

class CustomerStats {
  final int total;
  final int active;
  final int newThisMonth;
  final Map<CustomerType, int> byType;
  final Map<CustomerSegment, int> bySegment;

  const CustomerStats({
    required this.total,
    required this.active,
    required this.newThisMonth,
    required this.byType,
    required this.bySegment,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    final byType = <CustomerType, int>{};
    final byTypeList = (json['byType'] as List).cast<Map<String, dynamic>>();
    for (final item in byTypeList) {
      final type = CustomerType.values.firstWhere(
            (e) => e.name == item['type'],
        orElse: () => CustomerType.residential,
      );
      byType[type] = item['count'] as int;
    }

    final bySegment = <CustomerSegment, int>{};
    final bySegmentList =
    (json['bySegment'] as List).cast<Map<String, dynamic>>();
    for (final item in bySegmentList) {
      final segment = CustomerSegment.values.firstWhere(
            (e) => e.name == item['segment'],
        orElse: () => CustomerSegment.standard,
      );
      bySegment[segment] = item['count'] as int;
    }

    return CustomerStats(
      total: json['total'] as int,
      active: json['active'] as int,
      newThisMonth: json['newThisMonth'] as int,
      byType: byType,
      bySegment: bySegment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'newThisMonth': newThisMonth,
      'byType': byType.entries.map((e) => {'type': e.key.name, 'count': e.value}).toList(),
      'bySegment': bySegment.entries.map((e) => {'segment': e.key.name, 'count': e.value}).toList(),
    };
  }
}