class StockLevel {
  final String id;
  final String itemId;
  final String warehouseId;
  final double currentStock;
  final double committedStock;
  final double availableStock;
  final double minimumStock;
  final double maximumStock;
  final double reorderPoint;
  final DateTime lastMovementDate;
  final DateTime lastStockTakeDate;
  final double stockValue;
  final double averageCost;
  final String movementClass;
  final String stockStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockLevel({
    required this.id,
    required this.itemId,
    required this.warehouseId,
    required this.currentStock,
    required this.committedStock,
    required this.availableStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.lastMovementDate,
    required this.lastStockTakeDate,
    required this.stockValue,
    required this.averageCost,
    required this.movementClass,
    required this.stockStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockLevel.fromJson(Map<String, dynamic> json) {
    return StockLevel(
      id: json['_id'] ?? '',
      itemId: json['item'] is String ? json['item'] : json['item']?['_id'] ?? '',
      warehouseId: json['warehouse'] is String ? json['warehouse'] : json['warehouse']?['_id'] ?? '',
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      committedStock: (json['committedStock'] ?? 0).toDouble(),
      availableStock: (json['availableStock'] ?? 0).toDouble(),
      minimumStock: (json['minimumStock'] ?? 0).toDouble(),
      maximumStock: (json['maximumStock'] ?? 0).toDouble(),
      reorderPoint: (json['reorderPoint'] ?? 0).toDouble(),
      lastMovementDate: json['lastMovementDate'] != null
          ? DateTime.parse(json['lastMovementDate'])
          : DateTime.now(),
      lastStockTakeDate: json['lastStockTakeDate'] != null
          ? DateTime.parse(json['lastStockTakeDate'])
          : DateTime.now(),
      stockValue: (json['stockValue'] ?? 0).toDouble(),
      averageCost: (json['averageCost'] ?? 0).toDouble(),
      movementClass: json['movementClass'] ?? 'slow_moving',
      stockStatus: json['stockStatus'] ?? 'normal',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'warehouse': warehouseId,
      'currentStock': currentStock,
      'committedStock': committedStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'reorderPoint': reorderPoint,
      'lastMovementDate': lastMovementDate.toIso8601String(),
      'lastStockTakeDate': lastStockTakeDate.toIso8601String(),
      'stockValue': stockValue,
      'averageCost': averageCost,
      'movementClass': movementClass,
      'stockStatus': stockStatus,
    };
  }

  bool get isLowStock => availableStock <= reorderPoint * 0.2;
  bool get isCriticalStock => availableStock <= reorderPoint * 0.1;
  bool get isOutOfStock => availableStock == 0;
  bool get isOverstock => availableStock >= maximumStock * 0.9;
}
