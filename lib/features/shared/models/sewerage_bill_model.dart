import 'package:flutter/material.dart';

class SewerageBill {
  final String? id;
  final String customerName;
  final String customerEmail;
  final String sewageServiceNumber;
  final BillingPeriod billingPeriod;
  final double baseCharge;
  final double usageCharge;
  final double penalty;
  final double arrears;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final double paidAmount;
  final double balance;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SewerageBill({
    this.id,
    required this.customerName,
    required this.customerEmail,
    required this.sewageServiceNumber,
    required this.billingPeriod,
    required this.baseCharge,
    required this.usageCharge,
    required this.penalty,
    required this.arrears,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.paidAmount,
    required this.balance,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SewerageBill.fromJson(Map<String, dynamic> json) {
    return SewerageBill(
      id: json['_id'] ?? json['id'],
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      sewageServiceNumber: json['sewageServiceNumber'] ?? '',
      billingPeriod: BillingPeriod.fromJson(json['billingPeriod']),
      baseCharge: (json['baseCharge'] ?? 0).toDouble(),
      usageCharge: (json['usageCharge'] ?? 0).toDouble(),
      penalty: (json['penalty'] ?? 0).toDouble(),
      arrears: (json['arrears'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate:
          json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'sewageServiceNumber': sewageServiceNumber,
      'billingPeriod': billingPeriod.toJson(),
      'baseCharge': baseCharge,
      'usageCharge': usageCharge,
      'penalty': penalty,
      'arrears': arrears,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'status': status,
      'paidAmount': paidAmount,
      'balance': balance,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  SewerageBill copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? sewageServiceNumber,
    BillingPeriod? billingPeriod,
    double? baseCharge,
    double? usageCharge,
    double? penalty,
    double? arrears,
    double? taxAmount,
    double? totalAmount,
    String? status,
    double? paidAmount,
    double? balance,
    DateTime? dueDate,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SewerageBill(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      sewageServiceNumber: sewageServiceNumber ?? this.sewageServiceNumber,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      baseCharge: baseCharge ?? this.baseCharge,
      usageCharge: usageCharge ?? this.usageCharge,
      penalty: penalty ?? this.penalty,
      arrears: arrears ?? this.arrears,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      balance: balance ?? this.balance,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.warning;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  String get formattedStatus {
    return status[0].toUpperCase() + status.substring(1);
  }

  bool get isOverdue => status == 'overdue' && DateTime.now().isAfter(dueDate);

  bool get isPaid => status == 'paid';

  bool get canPay => status == 'pending' || status == 'overdue';
}

class BillingPeriod {
  final DateTime from;
  final DateTime to;

  BillingPeriod({required this.from, required this.to});

  factory BillingPeriod.fromJson(Map<String, dynamic> json) {
    return BillingPeriod(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    };
  }

  String get formattedPeriod {
    return '${_formatDate(from)} - ${_formatDate(to)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int get daysInPeriod => to.difference(from).inDays;
}

class CreateBillDto {
  final String customerName;
  final String customerEmail;
  final BillingPeriod billingPeriod;
  final double baseCharge;
  final double usageCharge;
  final double penalty;
  final double arrears;
  final double taxAmount;
  final double totalAmount;
  final DateTime dueDate;

  CreateBillDto({
    required this.customerName,
    required this.customerEmail,
    required this.billingPeriod,
    required this.baseCharge,
    this.usageCharge = 0,
    this.penalty = 0,
    this.arrears = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'billingPeriod': billingPeriod.toJson(),
      'baseCharge': baseCharge,
      'usageCharge': usageCharge,
      'penalty': penalty,
      'arrears': arrears,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

class UpdateBillDto {
  final String? customerName;
  final String? customerEmail;
  final BillingPeriod? billingPeriod;
  final double? baseCharge;
  final double? usageCharge;
  final double? arrears;
  final double? taxAmount;
  final double? totalAmount;
  final DateTime? dueDate;
  final String? status;

  UpdateBillDto({
    this.customerName,
    this.customerEmail,
    this.billingPeriod,
    this.baseCharge,
    this.usageCharge,
    this.arrears,
    this.taxAmount,
    this.totalAmount,
    this.dueDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (customerName != null) data['customerName'] = customerName;
    if (customerEmail != null) data['customerEmail'] = customerEmail;
    if (billingPeriod != null) data['billingPeriod'] = billingPeriod!.toJson();
    if (baseCharge != null) data['baseCharge'] = baseCharge;
    if (usageCharge != null) data['usageCharge'] = usageCharge;
    if (arrears != null) data['arrears'] = arrears;
    if (taxAmount != null) data['taxAmount'] = taxAmount;
    if (totalAmount != null) data['totalAmount'] = totalAmount;
    if (dueDate != null) data['dueDate'] = dueDate!.toIso8601String();
    if (status != null) data['status'] = status;
    return data;
  }
}

class PaymentDto {
  final double amount;
  final String? paymentId;
  final DateTime? paidDate;

  PaymentDto({
    required this.amount,
    this.paymentId,
    this.paidDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'amount': amount,
    };
    if (paymentId != null) data['paymentId'] = paymentId;
    if (paidDate != null) data['paidDate'] = paidDate!.toIso8601String();
    return data;
  }
}

class BillingStatistics {
  final int totalBills;
  final double totalRevenue;
  final int pendingBills;
  final int paidBills;
  final int overdueBills;
  final double averageBillAmount;

  BillingStatistics({
    required this.totalBills,
    required this.totalRevenue,
    required this.pendingBills,
    required this.paidBills,
    required this.overdueBills,
    required this.averageBillAmount,
  });

  factory BillingStatistics.fromJson(Map<String, dynamic> json) {
    return BillingStatistics(
      totalBills: json['totalBills'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingBills: json['pendingBills'] ?? 0,
      paidBills: json['paidBills'] ?? 0,
      overdueBills: json['overdueBills'] ?? 0,
      averageBillAmount: (json['averageBillAmount'] ?? 0).toDouble(),
    );
  }
}
