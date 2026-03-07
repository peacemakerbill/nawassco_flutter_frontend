enum PaymentMethod {
  mpesa,
  airtelMoney,
}

enum PaymentPurpose {
  waterBill,
  sewerageBill,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
}

class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String operatingSystem;
  final String? appVersion;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.operatingSystem,
    this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'operatingSystem': operatingSystem,
      if (appVersion != null) 'appVersion': appVersion,
    };
  }
}

class SecurityInfo {
  final String ipAddress;
  final String userAgent;
  final String deviceFingerprint;
  final bool isSuspicious;
  final int riskScore;

  SecurityInfo({
    required this.ipAddress,
    required this.userAgent,
    required this.deviceFingerprint,
    this.isSuspicious = false,
    this.riskScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'deviceFingerprint': deviceFingerprint,
      'isSuspicious': isSuspicious,
      'riskScore': riskScore,
    };
  }
}

class PaymentCustomer {
  final String? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? meterNumber;
  final String? sewerageServiceNumber;
  final bool isGuest;

  PaymentCustomer({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.meterNumber,
    this.sewerageServiceNumber,
    this.isGuest = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (meterNumber != null) 'meterNumber': meterNumber,
      if (sewerageServiceNumber != null) 'sewerageServiceNumber': sewerageServiceNumber,
      'isGuest': isGuest,
    };
  }

  factory PaymentCustomer.fromAuthUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String? meterNumber,
    String? sewerageServiceNumber,
  }) {
    return PaymentCustomer(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      meterNumber: meterNumber,
      sewerageServiceNumber: sewerageServiceNumber,
      isGuest: false,
    );
  }
}

class PaidBy {
  final String? userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String relationship;
  final bool isGuest;

  PaidBy({
    this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.relationship = 'self',
    this.isGuest = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'relationship': relationship,
      'isGuest': isGuest,
    };
  }
}

class PaymentInitiationData {
  final String? userId;
  final String? guestSessionId;
  final PaymentCustomer customer;
  final PaidBy paidBy;
  final PaymentMethod paymentMethod;
  final PaymentPurpose paymentPurpose;
  final double amount;
  final String accountNumber;
  final String? billId;
  final String? billNumber;
  final String? billType;
  final Map<String, dynamic>? billingPeriod;
  final String? serviceId;
  final String? serviceType;
  final String? serviceDescription;
  final SecurityInfo securityInfo;

  PaymentInitiationData({
    this.userId,
    this.guestSessionId,
    required this.customer,
    required this.paidBy,
    required this.paymentMethod,
    required this.paymentPurpose,
    required this.amount,
    required this.accountNumber,
    this.billId,
    this.billNumber,
    this.billType,
    this.billingPeriod,
    this.serviceId,
    this.serviceType,
    this.serviceDescription,
    required this.securityInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (guestSessionId != null) 'guestSessionId': guestSessionId,
      'customer': customer.toJson(),
      'paidBy': paidBy.toJson(),
      'paymentMethod': _convertPaymentMethod(paymentMethod),
      'paymentPurpose': _convertPaymentPurpose(paymentPurpose),
      'amount': amount,
      'accountNumber': accountNumber,
      if (billId != null) 'billId': billId,
      if (billNumber != null) 'billNumber': billNumber,
      if (billType != null) 'billType': billType,
      if (billingPeriod != null) 'billingPeriod': billingPeriod,
      if (serviceId != null) 'serviceId': serviceId,
      if (serviceType != null) 'serviceType': serviceType,
      if (serviceDescription != null) 'serviceDescription': serviceDescription,
      'ipAddress': securityInfo.ipAddress,
      'userAgent': securityInfo.userAgent,
      'deviceFingerprint': securityInfo.deviceFingerprint,
      'isSuspicious': securityInfo.isSuspicious,
      'riskScore': securityInfo.riskScore,
    };
  }

  String _convertPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return 'mpesa';
      case PaymentMethod.airtelMoney:
        return 'airtel_money';
      default:
        return 'mpesa';
    }
  }

  String _convertPaymentPurpose(PaymentPurpose purpose) {
    switch (purpose) {
      case PaymentPurpose.waterBill:
        return 'water_bill';
      case PaymentPurpose.sewerageBill:
        return 'sewerage_bill';
      default:
        return 'water_bill';
    }
  }
}

class PaymentResponse {
  final bool success;
  final String message;
  final String? paymentId;
  final String? checkoutRequestID;
  final String? transactionId;
  final String? merchantRequestID;
  final String? referenceId;
  final PaymentStatus? status;
  final double? amount;
  final String? accountNumber;
  final DateTime? expiresAt;
  final String? customerMessage;
  final String? responseDescription;

  PaymentResponse({
    required this.success,
    required this.message,
    this.paymentId,
    this.checkoutRequestID,
    this.transactionId,
    this.merchantRequestID,
    this.referenceId,
    this.status,
    this.amount,
    this.accountNumber,
    this.expiresAt,
    this.customerMessage,
    this.responseDescription,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentId: json['data']?['paymentId'] ?? json['data']?['id'],
      checkoutRequestID: json['data']?['checkoutRequestID'],
      transactionId: json['data']?['transactionId'],
      merchantRequestID: json['data']?['merchantRequestID'],
      referenceId: json['data']?['referenceId'],
      status: _parseStatus(json['data']?['status']),
      amount: json['data']?['amount'] != null
          ? double.parse(json['data']['amount'].toString())
          : null,
      accountNumber: json['data']?['accountNumber'],
      expiresAt: json['data']?['expiresAt'] != null
          ? DateTime.parse(json['data']['expiresAt'])
          : null,
      customerMessage: json['data']?['customerMessage'],
      responseDescription: json['data']?['responseDescription'],
    );
  }

  static PaymentStatus? _parseStatus(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentTransaction {
  final String id;
  final PaymentMethod paymentMethod;
  final PaymentPurpose paymentPurpose;
  final double amount;
  final String accountNumber;
  final PaymentStatus status;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? externalReference;
  final String? errorMessage;

  PaymentTransaction({
    required this.id,
    required this.paymentMethod,
    required this.paymentPurpose,
    required this.amount,
    required this.accountNumber,
    required this.status,
    required this.initiatedAt,
    this.completedAt,
    this.failedAt,
    this.externalReference,
    this.errorMessage,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['_id'] ?? json['id'],
      paymentMethod: json['paymentMethod'] == 'airtel_money'
          ? PaymentMethod.airtelMoney
          : PaymentMethod.mpesa,
      paymentPurpose: json['paymentPurpose'] == 'sewerage_bill'
          ? PaymentPurpose.sewerageBill
          : PaymentPurpose.waterBill,
      amount: double.parse(json['amount'].toString()),
      accountNumber: json['meterNumber'] ?? json['sewerageServiceNumber'] ?? '',
      status: _parseStatus(json['status']),
      initiatedAt: DateTime.parse(json['initiatedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      failedAt: json['failedAt'] != null
          ? DateTime.parse(json['failedAt'])
          : null,
      externalReference: json['externalReference'],
      errorMessage: json['errorMessage'],
    );
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}