class Adjustment {
  final String itemId;
  final String adjustmentType;
  final double quantity;
  final double value;
  final String reason;
  final String approvedBy;
  final DateTime adjustmentDate;

  Adjustment({
    required this.itemId,
    required this.adjustmentType,
    required this.quantity,
    required this.value,
    required this.reason,
    required this.approvedBy,
    required this.adjustmentDate,
  });

  factory Adjustment.fromJson(Map<String, dynamic> json) {
    return Adjustment(
      itemId: json['item'] is String ? json['item'] : json['item']?['_id'] ?? '',
      adjustmentType: json['adjustmentType'] ?? 'positive',
      quantity: (json['quantity'] ?? 0).toDouble(),
      value: (json['value'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      approvedBy: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'] ?? '',
      adjustmentDate: DateTime.parse(json['adjustmentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'adjustmentType': adjustmentType,
      'quantity': quantity,
      'value': value,
      'reason': reason,
      'approvedBy': approvedBy,
      'adjustmentDate': adjustmentDate.toIso8601String(),
    };
  }
}
