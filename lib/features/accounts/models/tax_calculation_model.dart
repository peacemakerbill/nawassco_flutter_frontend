import 'package:flutter/material.dart';

enum TaxType {
  vat('VAT', 'Value Added Tax'),
  income_tax('Income Tax', 'Income Tax'),
  withholding_tax('Withholding Tax', 'Withholding Tax'),
  excise_duty('Excise Duty', 'Excise Duty'),
  stamp_duty('Stamp Duty', 'Stamp Duty');

  const TaxType(this.label, this.description);

  final String label;
  final String description;

  // Helper to get enum from string
  static TaxType fromString(String value) {
    return TaxType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TaxType.vat,
    );
  }
}

enum TaxStatus {
  draft('Draft', Colors.grey),
  calculated('Calculated', Colors.orange),
  approved('Approved', Colors.blue),
  filed('Filed', Colors.green);

  const TaxStatus(this.label, this.color);

  final String label;
  final Color color;

  // Helper to get enum from string
  static TaxStatus fromString(String value) {
    return TaxStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TaxStatus.draft,
    );
  }
}

enum TaxPaymentStatus {
  pending('Pending', Colors.grey),
  partially_paid('Partially Paid', Colors.orange),
  paid('Paid', Colors.green),
  overdue('Overdue', Colors.red);

  const TaxPaymentStatus(this.label, this.color);

  final String label;
  final Color color;

  // Helper to get enum from string
  static TaxPaymentStatus fromString(String value) {
    return TaxPaymentStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TaxPaymentStatus.pending,
    );
  }
}

enum TransactionType {
  sales('Sales'),
  purchase('Purchase'),
  expense('Expense'),
  import('Import');

  const TransactionType(this.label);

  final String label;

  // Helper to get enum from string
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TransactionType.sales,
    );
  }
}

class TaxTransaction {
  final String id;
  final DateTime transactionDate;
  final String description;
  final double taxableAmount;
  final double taxAmount;
  final TransactionType transactionType;
  final String reference;

  TaxTransaction({
    required this.transactionDate,
    required this.description,
    required this.taxableAmount,
    required this.taxAmount,
    required this.transactionType,
    required this.reference,
  }) : id = '${DateTime.now().millisecondsSinceEpoch}-${reference.hashCode}';

  Map<String, dynamic> toJson() => {
    'transactionDate': transactionDate.toIso8601String(),
    'description': description,
    'taxableAmount': taxableAmount,
    'taxAmount': taxAmount,
    'transactionType': transactionType.name,
    'reference': reference,
  };

  factory TaxTransaction.fromJson(Map<String, dynamic> json) => TaxTransaction(
    transactionDate: DateTime.parse(json['transactionDate']),
    description: json['description'],
    taxableAmount: (json['taxableAmount'] as num).toDouble(),
    taxAmount: (json['taxAmount'] as num).toDouble(),
    transactionType: TransactionType.fromString(json['transactionType']),
    reference: json['reference'],
  );
}

class TaxCalculation {
  final String? id;
  final String calculationNumber;
  final String taxPeriod;
  final TaxType taxType;
  final double taxableAmount;
  final double taxRate;
  final double taxAmount;
  final double withholdingTax;
  final double netTaxPayable;
  final List<TaxTransaction> transactions;
  final TaxPaymentStatus paymentStatus;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final bool filed;
  final DateTime? filedDate;
  final String? filingReference;
  final TaxStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxCalculation({
    this.id,
    required this.calculationNumber,
    required this.taxPeriod,
    required this.taxType,
    required this.taxableAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.withholdingTax,
    required this.netTaxPayable,
    required this.transactions,
    required this.paymentStatus,
    required this.paidAmount,
    required this.dueDate,
    this.paymentDate,
    required this.filed,
    this.filedDate,
    this.filingReference,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  TaxCalculation copyWith({
    String? id,
    String? calculationNumber,
    String? taxPeriod,
    TaxType? taxType,
    double? taxableAmount,
    double? taxRate,
    double? taxAmount,
    double? withholdingTax,
    double? netTaxPayable,
    List<TaxTransaction>? transactions,
    TaxPaymentStatus? paymentStatus,
    double? paidAmount,
    DateTime? dueDate,
    DateTime? paymentDate,
    bool? filed,
    DateTime? filedDate,
    String? filingReference,
    TaxStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxCalculation(
      id: id ?? this.id,
      calculationNumber: calculationNumber ?? this.calculationNumber,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      taxType: taxType ?? this.taxType,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      withholdingTax: withholdingTax ?? this.withholdingTax,
      netTaxPayable: netTaxPayable ?? this.netTaxPayable,
      transactions: transactions ?? this.transactions,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      filed: filed ?? this.filed,
      filedDate: filedDate ?? this.filedDate,
      filingReference: filingReference ?? this.filingReference,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'calculationNumber': calculationNumber,
    'taxPeriod': taxPeriod,
    'taxType': taxType.name,
    'taxableAmount': taxableAmount,
    'taxRate': taxRate,
    'taxAmount': taxAmount,
    'withholdingTax': withholdingTax,
    'netTaxPayable': netTaxPayable,
    'transactions': transactions.map((tx) => tx.toJson()).toList(),
    'paymentStatus': paymentStatus.name,
    'paidAmount': paidAmount,
    'dueDate': dueDate.toIso8601String(),
    if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
    'filed': filed,
    if (filedDate != null) 'filedDate': filedDate!.toIso8601String(),
    if (filingReference != null) 'filingReference': filingReference,
    'status': status.name,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TaxCalculation.fromJson(Map<String, dynamic> json) {
    // Handle createdBy field - could be string or object
    String getCreatedBy(Map<String, dynamic> jsonData) {
      if (jsonData['createdBy'] is String) {
        return jsonData['createdBy'];
      } else if (jsonData['createdBy'] is Map<String, dynamic>) {
        final userData = jsonData['createdBy'] as Map<String, dynamic>;
        return userData['_id']?.toString() ?? '';
      }
      return '';
    }

    // Parse transactions
    List<TaxTransaction> parseTransactions(List<dynamic>? transactionsData) {
      if (transactionsData == null) return [];
      return transactionsData
          .map((tx) => TaxTransaction.fromJson(tx as Map<String, dynamic>))
          .toList();
    }

    return TaxCalculation(
      id: json['_id']?.toString(),
      calculationNumber: json['calculationNumber']?.toString() ?? '',
      taxPeriod: json['taxPeriod']?.toString() ?? '',
      taxType: TaxType.fromString(json['taxType']?.toString() ?? 'vat'),
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      withholdingTax: (json['withholdingTax'] as num?)?.toDouble() ?? 0.0,
      netTaxPayable: (json['netTaxPayable'] as num?)?.toDouble() ?? 0.0,
      transactions: parseTransactions(json['transactions'] as List<dynamic>?),
      paymentStatus: TaxPaymentStatus.fromString(
          json['paymentStatus']?.toString() ?? 'pending'),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.parse(json['dueDate']?.toString() ??
          DateTime.now().add(Duration(days: 30)).toIso8601String()),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'].toString())
          : null,
      filed: json['filed'] as bool? ?? false,
      filedDate: json['filedDate'] != null
          ? DateTime.parse(json['filedDate'].toString())
          : null,
      filingReference: json['filingReference']?.toString(),
      status: TaxStatus.fromString(json['status']?.toString() ?? 'draft'),
      createdBy: getCreatedBy(json),
      createdAt: DateTime.parse(json['createdAt']?.toString() ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ??
          DateTime.now().toIso8601String()),
    );
  }

  double get outstandingAmount => netTaxPayable - paidAmount;

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) &&
          paymentStatus != TaxPaymentStatus.paid;

  bool get canEdit => status == TaxStatus.draft;

  bool get canCalculate => status == TaxStatus.draft;

  bool get canApprove => status == TaxStatus.calculated;

  bool get canFile => status == TaxStatus.approved;

  bool get canRecordPayment => filed;
}