import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Receipt {
  final String id;
  final String receiptNumber;
  final DateTime receiptDate;
  final ReceiptType receiptType;
  final PayerType payerType;
  final String payerEmail;
  final String payerPhone;
  final String payerName;
  final double amount;
  final String currency;
  final double taxAmount;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? invoiceNumber;
  final String? customerEmail;
  final String? customerName;
  final double allocatedAmount;
  final double unallocatedAmount;
  final ReceiptStatus status;
  final bool reconciled;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReceiptDocument? document;

  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.receiptDate,
    required this.receiptType,
    required this.payerType,
    required this.payerEmail,
    required this.payerPhone,
    required this.payerName,
    required this.amount,
    this.currency = 'KES',
    this.taxAmount = 0.0,
    required this.paymentMethod,
    this.referenceNumber,
    this.invoiceNumber,
    this.customerEmail,
    this.customerName,
    this.allocatedAmount = 0.0,
    this.unallocatedAmount = 0.0,
    this.status = ReceiptStatus.DRAFT,
    this.reconciled = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.document,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['_id'] ?? json['id'],
      receiptNumber: json['receiptNumber'],
      receiptDate: DateTime.parse(json['receiptDate']),
      receiptType: ReceiptType.values.firstWhere(
            (e) => e.name.toLowerCase() == json['receiptType'].toString().toLowerCase().replaceAll('_', ''),
        orElse: () => ReceiptType.CUSTOMER_PAYMENT,
      ),
      payerType: PayerType.values.firstWhere(
            (e) => e.name.toLowerCase() == json['payerType'].toString().toLowerCase().replaceAll('_', ''),
        orElse: () => PayerType.CUSTOMER,
      ),
      payerEmail: json['payerEmail'] ?? '',
      payerPhone: json['payerPhone'] ?? '',
      payerName: json['payerName'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'KES',
      taxAmount: (json['taxAmount'] as num? ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.name.toLowerCase() == json['paymentMethod'].toString().toLowerCase().replaceAll('_', ''),
        orElse: () => PaymentMethod.CASH,
      ),
      referenceNumber: json['referenceNumber'],
      invoiceNumber: json['invoiceNumber'],
      customerEmail: json['customerEmail'],
      customerName: json['customerName'],
      allocatedAmount: (json['allocatedAmount'] as num? ?? 0).toDouble(),
      unallocatedAmount: (json['unallocatedAmount'] as num? ?? 0).toDouble(),
      status: ReceiptStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase().replaceAll('_', ''),
        orElse: () => ReceiptStatus.DRAFT,
      ),
      reconciled: json['reconciled'] ?? false,
      createdBy: json['createdBy'] is String
          ? json['createdBy']
          : json['createdBy']?['_id'] ?? json['createdBy']?['id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      document: json['document'] != null
          ? ReceiptDocument.fromJson(json['document'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiptDate': receiptDate.toIso8601String(),
      'receiptType': receiptType.name.toLowerCase(),
      'payerType': payerType.name.toLowerCase(),
      'payerEmail': payerEmail,
      'payerPhone': payerPhone,
      'payerName': payerName,
      'amount': amount,
      'currency': currency,
      'taxAmount': taxAmount,
      'paymentMethod': paymentMethod.name.toLowerCase(),
      'referenceNumber': referenceNumber,
      'invoiceNumber': invoiceNumber,
      'customerEmail': customerEmail,
      'customerName': customerName,
    };
  }

  Receipt copyWith({
    String? id,
    String? receiptNumber,
    DateTime? receiptDate,
    ReceiptType? receiptType,
    PayerType? payerType,
    String? payerEmail,
    String? payerPhone,
    String? payerName,
    double? amount,
    String? currency,
    double? taxAmount,
    PaymentMethod? paymentMethod,
    String? referenceNumber,
    String? invoiceNumber,
    String? customerEmail,
    String? customerName,
    double? allocatedAmount,
    double? unallocatedAmount,
    ReceiptStatus? status,
    bool? reconciled,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReceiptDocument? document,
  }) {
    return Receipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptDate: receiptDate ?? this.receiptDate,
      receiptType: receiptType ?? this.receiptType,
      payerType: payerType ?? this.payerType,
      payerEmail: payerEmail ?? this.payerEmail,
      payerPhone: payerPhone ?? this.payerPhone,
      payerName: payerName ?? this.payerName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      taxAmount: taxAmount ?? this.taxAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      unallocatedAmount: unallocatedAmount ?? this.unallocatedAmount,
      status: status ?? this.status,
      reconciled: reconciled ?? this.reconciled,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      document: document ?? this.document,
    );
  }

  String get formattedAmount =>
      '${currency == 'KES' ? 'KES ' : '\$'}${amount.toStringAsFixed(2)}';

  String get formattedDate =>
      '${receiptDate.day}/${receiptDate.month}/${receiptDate.year} ${receiptDate.hour.toString().padLeft(2, '0')}:${receiptDate.minute.toString().padLeft(2, '0')}';

  String get formattedDateOnly =>
      '${receiptDate.day}/${receiptDate.month}/${receiptDate.year}';

  bool get isDraft => status == ReceiptStatus.DRAFT;

  bool get isConfirmed => status == ReceiptStatus.CONFIRMED;

  bool get isDeposited => status == ReceiptStatus.DEPOSITED;

  bool get isCancelled => status == ReceiptStatus.CANCELLED;

  double get allocationPercentage =>
      amount > 0 ? (allocatedAmount / amount) * 100 : 0;

  String get payerContactInfo {
    final email = payerEmail.isNotEmpty ? payerEmail : null;
    final phone = payerPhone.isNotEmpty ? payerPhone : null;
    if (email != null && phone != null) {
      return '$email • $phone';
    } else if (email != null) {
      return email;
    } else if (phone != null) {
      return phone;
    }
    return 'No contact info';
  }

  String get customerInfo {
    if (customerName != null && customerName!.isNotEmpty) {
      return customerEmail != null && customerEmail!.isNotEmpty
          ? '$customerName ($customerEmail)'
          : customerName!;
    }
    return customerEmail ?? 'No customer info';
  }
}

class ReceiptDocument {
  final String url;
  final String fileName;
  final String originalName;
  final int? fileSize;
  final String? mimeType;
  final DateTime uploadedAt;

  ReceiptDocument({
    required this.url,
    required this.fileName,
    required this.originalName,
    this.fileSize,
    this.mimeType,
    required this.uploadedAt,
  });

  factory ReceiptDocument.fromJson(Map<String, dynamic> json) {
    return ReceiptDocument(
      url: json['url'],
      fileName: json['fileName'],
      originalName: json['originalName'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'originalName': originalName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';
    if (fileSize! < 1024) return '${fileSize!} B';
    if (fileSize! < 1048576)
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / 1048576).toStringAsFixed(1)} MB';
  }
}

enum ReceiptType {
  CUSTOMER_PAYMENT,
  ADVANCE_PAYMENT,
  SECURITY_DEPOSIT,
  OTHER_INCOME
}

extension ReceiptTypeExtension on ReceiptType {
  String get displayName {
    switch (this) {
      case ReceiptType.CUSTOMER_PAYMENT:
        return 'Customer Payment';
      case ReceiptType.ADVANCE_PAYMENT:
        return 'Advance Payment';
      case ReceiptType.SECURITY_DEPOSIT:
        return 'Security Deposit';
      case ReceiptType.OTHER_INCOME:
        return 'Other Income';
    }
  }

  String get apiName {
    switch (this) {
      case ReceiptType.CUSTOMER_PAYMENT:
        return 'customer_payment';
      case ReceiptType.ADVANCE_PAYMENT:
        return 'advance_payment';
      case ReceiptType.SECURITY_DEPOSIT:
        return 'security_deposit';
      case ReceiptType.OTHER_INCOME:
        return 'other_income';
    }
  }

  Color get color {
    switch (this) {
      case ReceiptType.CUSTOMER_PAYMENT:
        return const Color(0xFF10B981);
      case ReceiptType.ADVANCE_PAYMENT:
        return const Color(0xFFF59E0B);
      case ReceiptType.SECURITY_DEPOSIT:
        return const Color(0xFF3B82F6);
      case ReceiptType.OTHER_INCOME:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData get icon {
    switch (this) {
      case ReceiptType.CUSTOMER_PAYMENT:
        return Icons.payment;
      case ReceiptType.ADVANCE_PAYMENT:
        return Icons.forward;
      case ReceiptType.SECURITY_DEPOSIT:
        return Icons.security;
      case ReceiptType.OTHER_INCOME:
        return Icons.attach_money;
    }
  }
}

enum PayerType { CUSTOMER, SUPPLIER, EMPLOYEE, OTHER }

extension PayerTypeExtension on PayerType {
  String get displayName {
    switch (this) {
      case PayerType.CUSTOMER:
        return 'Customer';
      case PayerType.SUPPLIER:
        return 'Supplier';
      case PayerType.EMPLOYEE:
        return 'Employee';
      case PayerType.OTHER:
        return 'Other';
    }
  }

  String get apiName {
    switch (this) {
      case PayerType.CUSTOMER:
        return 'customer';
      case PayerType.SUPPLIER:
        return 'supplier';
      case PayerType.EMPLOYEE:
        return 'employee';
      case PayerType.OTHER:
        return 'other';
    }
  }
}

enum PaymentMethod {
  CASH,
  CHEQUE,
  BANK_TRANSFER,
  CREDIT_CARD,
  MOBILE_MONEY,
  OTHER
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.CASH:
        return 'Cash';
      case PaymentMethod.CHEQUE:
        return 'Cheque';
      case PaymentMethod.BANK_TRANSFER:
        return 'Bank Transfer';
      case PaymentMethod.CREDIT_CARD:
        return 'Credit Card';
      case PaymentMethod.MOBILE_MONEY:
        return 'Mobile Money';
      case PaymentMethod.OTHER:
        return 'Other';
    }
  }

  String get apiName {
    switch (this) {
      case PaymentMethod.CASH:
        return 'cash';
      case PaymentMethod.CHEQUE:
        return 'cheque';
      case PaymentMethod.BANK_TRANSFER:
        return 'bank_transfer';
      case PaymentMethod.CREDIT_CARD:
        return 'credit_card';
      case PaymentMethod.MOBILE_MONEY:
        return 'mobile_money';
      case PaymentMethod.OTHER:
        return 'other';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.CASH:
        return Icons.attach_money;
      case PaymentMethod.CHEQUE:
        return Icons.description;
      case PaymentMethod.BANK_TRANSFER:
        return Icons.account_balance;
      case PaymentMethod.CREDIT_CARD:
        return Icons.credit_card;
      case PaymentMethod.MOBILE_MONEY:
        return Icons.phone_android;
      case PaymentMethod.OTHER:
        return Icons.payment;
    }
  }
}

enum ReceiptStatus { DRAFT, CONFIRMED, DEPOSITED, CANCELLED }

extension ReceiptStatusExtension on ReceiptStatus {
  String get displayName {
    switch (this) {
      case ReceiptStatus.DRAFT:
        return 'Draft';
      case ReceiptStatus.CONFIRMED:
        return 'Confirmed';
      case ReceiptStatus.DEPOSITED:
        return 'Deposited';
      case ReceiptStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  String get apiName {
    switch (this) {
      case ReceiptStatus.DRAFT:
        return 'draft';
      case ReceiptStatus.CONFIRMED:
        return 'confirmed';
      case ReceiptStatus.DEPOSITED:
        return 'deposited';
      case ReceiptStatus.CANCELLED:
        return 'cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ReceiptStatus.DRAFT:
        return const Color(0xFF6B7280);
      case ReceiptStatus.CONFIRMED:
        return const Color(0xFF10B981);
      case ReceiptStatus.DEPOSITED:
        return const Color(0xFF3B82F6);
      case ReceiptStatus.CANCELLED:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case ReceiptStatus.DRAFT:
        return Icons.edit;
      case ReceiptStatus.CONFIRMED:
        return Icons.check_circle;
      case ReceiptStatus.DEPOSITED:
        return Icons.account_balance;
      case ReceiptStatus.CANCELLED:
        return Icons.cancel;
    }
  }
}