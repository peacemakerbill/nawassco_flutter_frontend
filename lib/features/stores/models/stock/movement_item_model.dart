class MovementItem {
  final String itemId;
  final String? batchNumber;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final List<String>? serialNumbers;
  final DateTime? expiryDate;
  final String condition;

  MovementItem({
    required this.itemId,
    this.batchNumber,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.serialNumbers,
    this.expiryDate,
    this.condition = 'good',
  });

  factory MovementItem.fromJson(Map<String, dynamic> json) {
    return MovementItem(
      itemId: json['item'] is String ? json['item'] : json['item']?['_id'] ?? '',
      batchNumber: json['batchNumber'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitCost: (json['unitCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      serialNumbers: json['serialNumbers'] != null
          ? List<String>.from(json['serialNumbers'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      condition: json['condition'] ?? 'good',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'batchNumber': batchNumber,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'serialNumbers': serialNumbers,
      'expiryDate': expiryDate?.toIso8601String(),
      'condition': condition,
    };
  }
}
