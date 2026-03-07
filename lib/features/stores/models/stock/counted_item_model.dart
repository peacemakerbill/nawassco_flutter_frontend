class CountedItem {
  final String itemId;
  final double expectedQuantity;
  final double countedQuantity;
  final double variance;
  final double varianceValue;
  final String? batchNumber;
  final String condition;
  final String countedBy;
  final DateTime countingTime;
  final String? remarks;

  CountedItem({
    required this.itemId,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.variance,
    required this.varianceValue,
    this.batchNumber,
    this.condition = 'good',
    required this.countedBy,
    required this.countingTime,
    this.remarks,
  });

  factory CountedItem.fromJson(Map<String, dynamic> json) {
    return CountedItem(
      itemId: json['item'] is String ? json['item'] : json['item']?['_id'] ?? '',
      expectedQuantity: (json['expectedQuantity'] ?? 0).toDouble(),
      countedQuantity: (json['countedQuantity'] ?? 0).toDouble(),
      variance: (json['variance'] ?? 0).toDouble(),
      varianceValue: (json['varianceValue'] ?? 0).toDouble(),
      batchNumber: json['batchNumber'],
      condition: json['condition'] ?? 'good',
      countedBy: json['countedBy'] is String ? json['countedBy'] : json['countedBy']?['_id'] ?? '',
      countingTime: DateTime.parse(json['countingTime']),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'expectedQuantity': expectedQuantity,
      'countedQuantity': countedQuantity,
      'batchNumber': batchNumber,
      'condition': condition,
      'countedBy': countedBy,
      'countingTime': countingTime.toIso8601String(),
      'remarks': remarks,
    };
  }
}