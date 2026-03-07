import 'dart:ui';

class Adjustment {
  final String type;
  final double amount;
  final String reason;
  final DateTime appliedAt;

  Adjustment({
    required this.type,
    required this.amount,
    required this.reason,
    required this.appliedAt,
  });

  factory Adjustment.fromJson(Map<String, dynamic> json) {
    return Adjustment(
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'],
      appliedAt: DateTime.parse(json['appliedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'reason': reason,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }
}

class WaterBill {
  final String? id;
  final String meterNumber;
  final String customerName;
  final String customerEmail;
  final String serviceRegion;
  final DateTime billingPeriodFrom;
  final DateTime billingPeriodTo;
  final double previousReading;
  final double currentReading;
  final double consumption;
  final DateTime readingDate;
  final double waterCharges;
  final double sewerageCharges;
  final double meterRent;
  final double penalty;
  final double arrears;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final String status;
  final DateTime dueDate;
  final String? billNumber;
  final String billingMonth;
  final String readingType;
  final bool readingVerified;
  final bool isEstimated;
  final bool disputed;
  final String? disputeReason;
  final DateTime? disputeDate;
  final bool? disputeResolved;
  final double discountApplied;
  final String? discountReason;
  final List<Adjustment> adjustments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? averageDailyConsumption;
  final String? consumptionTrend;

  WaterBill({
    this.id,
    required this.meterNumber,
    required this.customerName,
    required this.customerEmail,
    required this.serviceRegion,
    required this.billingPeriodFrom,
    required this.billingPeriodTo,
    required this.previousReading,
    required this.currentReading,
    required this.consumption,
    required this.readingDate,
    required this.waterCharges,
    this.sewerageCharges = 0,
    this.meterRent = 0,
    this.penalty = 0,
    this.arrears = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    this.balance = 0,
    this.status = 'pending',
    required this.dueDate,
    this.billNumber,
    required this.billingMonth,
    this.readingType = 'manual',
    this.readingVerified = false,
    this.isEstimated = false,
    this.disputed = false,
    this.disputeReason,
    this.disputeDate,
    this.disputeResolved,
    this.discountApplied = 0,
    this.discountReason,
    this.adjustments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.averageDailyConsumption,
    this.consumptionTrend,
  });

  factory WaterBill.fromJson(Map<String, dynamic> json) {
    return WaterBill(
      id: json['_id'] ?? json['id'],
      meterNumber: json['meterNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      serviceRegion: json['serviceRegion'] ?? '',
      billingPeriodFrom: json['billingPeriod'] != null
          ? DateTime.parse(json['billingPeriod']['from'])
          : DateTime.now(),
      billingPeriodTo: json['billingPeriod'] != null
          ? DateTime.parse(json['billingPeriod']['to'])
          : DateTime.now(),
      previousReading: (json['previousReading'] as num).toDouble(),
      currentReading: (json['currentReading'] as num).toDouble(),
      consumption: (json['consumption'] as num).toDouble(),
      readingDate: DateTime.parse(json['readingDate']),
      waterCharges: (json['waterCharges'] as num).toDouble(),
      sewerageCharges: (json['sewerageCharges'] as num?)?.toDouble() ?? 0,
      meterRent: (json['meterRent'] as num?)?.toDouble() ?? 0,
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0,
      arrears: (json['arrears'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      dueDate: DateTime.parse(json['dueDate']),
      billNumber: json['billNumber'],
      billingMonth: json['billingMonth'] ?? '',
      readingType: json['readingType'] ?? 'manual',
      readingVerified: json['readingVerified'] ?? false,
      isEstimated: json['isEstimated'] ?? false,
      disputed: json['disputed'] ?? false,
      disputeReason: json['disputeReason'],
      disputeDate: json['disputeDate'] != null
          ? DateTime.parse(json['disputeDate'])
          : null,
      disputeResolved: json['disputeResolved'],
      discountApplied: (json['discountApplied'] as num?)?.toDouble() ?? 0,
      discountReason: json['discountReason'],
      adjustments: json['adjustments'] != null
          ? List<Adjustment>.from(
          json['adjustments'].map((x) => Adjustment.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      averageDailyConsumption: (json['averageDailyConsumption'] as num?)?.toDouble(),
      consumptionTrend: json['consumptionTrend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'meterNumber': meterNumber,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'serviceRegion': serviceRegion,
      'billingPeriod': {
        'from': billingPeriodFrom.toIso8601String(),
        'to': billingPeriodTo.toIso8601String(),
      },
      'previousReading': previousReading,
      'currentReading': currentReading,
      'consumption': consumption,
      'readingDate': readingDate.toIso8601String(),
      'waterCharges': waterCharges,
      'sewerageCharges': sewerageCharges,
      'meterRent': meterRent,
      'penalty': penalty,
      'arrears': arrears,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'balance': balance,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      if (billNumber != null) 'billNumber': billNumber,
      'billingMonth': billingMonth,
      'readingType': readingType,
      'readingVerified': readingVerified,
      'isEstimated': isEstimated,
      'disputed': disputed,
      if (disputeReason != null) 'disputeReason': disputeReason,
      if (disputeDate != null) 'disputeDate': disputeDate!.toIso8601String(),
      if (disputeResolved != null) 'disputeResolved': disputeResolved,
      'discountApplied': discountApplied,
      if (discountReason != null) 'discountReason': discountReason,
      'adjustments': adjustments.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WaterBill copyWith({
    String? id,
    String? meterNumber,
    String? customerName,
    String? customerEmail,
    String? serviceRegion,
    DateTime? billingPeriodFrom,
    DateTime? billingPeriodTo,
    double? previousReading,
    double? currentReading,
    double? consumption,
    DateTime? readingDate,
    double? waterCharges,
    double? sewerageCharges,
    double? meterRent,
    double? penalty,
    double? arrears,
    double? taxAmount,
    double? totalAmount,
    double? paidAmount,
    double? balance,
    String? status,
    DateTime? dueDate,
    String? billNumber,
    String? billingMonth,
    String? readingType,
    bool? readingVerified,
    bool? isEstimated,
    bool? disputed,
    String? disputeReason,
    DateTime? disputeDate,
    bool? disputeResolved,
    double? discountApplied,
    String? discountReason,
    List<Adjustment>? adjustments,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageDailyConsumption,
    String? consumptionTrend,
  }) {
    return WaterBill(
      id: id ?? this.id,
      meterNumber: meterNumber ?? this.meterNumber,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      serviceRegion: serviceRegion ?? this.serviceRegion,
      billingPeriodFrom: billingPeriodFrom ?? this.billingPeriodFrom,
      billingPeriodTo: billingPeriodTo ?? this.billingPeriodTo,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      consumption: consumption ?? this.consumption,
      readingDate: readingDate ?? this.readingDate,
      waterCharges: waterCharges ?? this.waterCharges,
      sewerageCharges: sewerageCharges ?? this.sewerageCharges,
      meterRent: meterRent ?? this.meterRent,
      penalty: penalty ?? this.penalty,
      arrears: arrears ?? this.arrears,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      billNumber: billNumber ?? this.billNumber,
      billingMonth: billingMonth ?? this.billingMonth,
      readingType: readingType ?? this.readingType,
      readingVerified: readingVerified ?? this.readingVerified,
      isEstimated: isEstimated ?? this.isEstimated,
      disputed: disputed ?? this.disputed,
      disputeReason: disputeReason ?? this.disputeReason,
      disputeDate: disputeDate ?? this.disputeDate,
      disputeResolved: disputeResolved ?? this.disputeResolved,
      discountApplied: discountApplied ?? this.discountApplied,
      discountReason: discountReason ?? this.discountReason,
      adjustments: adjustments ?? this.adjustments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageDailyConsumption: averageDailyConsumption ?? this.averageDailyConsumption,
      consumptionTrend: consumptionTrend ?? this.consumptionTrend,
    );
  }

  String get formattedDueDate => '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  String get formattedPeriod => '${billingPeriodFrom.day}/${billingPeriodFrom.month}/${billingPeriodFrom.year} - ${billingPeriodTo.day}/${billingPeriodTo.month}/${billingPeriodTo.year}';

  Color get statusColor {
    switch (status) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'partially_paid':
        return const Color(0xFF8B5CF6);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get statusText {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      case 'partially_paid':
        return 'Partially Paid';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isOverdue => status == 'overdue' || dueDate.isBefore(DateTime.now());
  bool get isPartiallyPaid => status == 'partially_paid';
  bool get isPaid => status == 'paid';
}