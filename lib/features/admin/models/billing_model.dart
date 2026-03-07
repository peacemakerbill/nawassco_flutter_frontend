class BillingModel {
  final String id;
  final String accountNumber;
  final double amount;
  final DateTime billingDate;
  final DateTime dueDate;
  final String status;
  final double? paidAmount;
  final DateTime? paidDate;

  BillingModel({
    required this.id,
    required this.accountNumber,
    required this.amount,
    required this.billingDate,
    required this.dueDate,
    required this.status,
    this.paidAmount,
    this.paidDate,
  });

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      id: json['_id'] ?? json['id'],
      accountNumber: json['accountNumber'],
      amount: (json['amount'] as num).toDouble(),
      billingDate: DateTime.parse(json['billingDate']),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      paidAmount: json['paidAmount'] != null ? (json['paidAmount'] as num).toDouble() : null,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
    );
  }
}