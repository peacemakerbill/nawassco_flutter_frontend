class InventoryReport {
  final String id;
  final String reportType;
  final String title;
  final String description;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
  final ReportFilters filters;
  final String generatedBy;

  InventoryReport({
    required this.id,
    required this.reportType,
    required this.title,
    required this.description,
    required this.generatedAt,
    required this.data,
    required this.filters,
    required this.generatedBy,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) {
    return InventoryReport(
      id: json['_id'] ?? json['id'],
      reportType: json['reportType'],
      title: json['title'],
      description: json['description'],
      generatedAt: DateTime.parse(json['generatedAt']),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      filters: ReportFilters.fromJson(json['filters'] ?? {}),
      generatedBy: json['generatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportType': reportType,
      'title': title,
      'description': description,
      'data': data,
      'filters': filters.toJson(),
    };
  }
}

class ReportFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;
  final String? warehouse;
  final String? itemType;
  final String? movementClass;
  final bool? includeInactive;

  ReportFilters({
    this.startDate,
    this.endDate,
    this.category,
    this.warehouse,
    this.itemType,
    this.movementClass,
    this.includeInactive = false,
  });

  factory ReportFilters.fromJson(Map<String, dynamic> json) {
    return ReportFilters(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      category: json['category'],
      warehouse: json['warehouse'],
      itemType: json['itemType'],
      movementClass: json['movementClass'],
      includeInactive: json['includeInactive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (category != null) 'category': category,
      if (warehouse != null) 'warehouse': warehouse,
      if (itemType != null) 'itemType': itemType,
      if (movementClass != null) 'movementClass': movementClass,
      'includeInactive': includeInactive,
    };
  }

  ReportFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? warehouse,
    String? itemType,
    String? movementClass,
    bool? includeInactive,
  }) {
    return ReportFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      warehouse: warehouse ?? this.warehouse,
      itemType: itemType ?? this.itemType,
      movementClass: movementClass ?? this.movementClass,
      includeInactive: includeInactive ?? this.includeInactive,
    );
  }
}

class ValuationReport {
  final double totalValuation;
  final int totalItems;
  final double averageItemValue;
  final List<CategoryValuation> categoryBreakdown;
  final List<WarehouseValuation> warehouseBreakdown;
  final List<MovementClassValuation> movementClassBreakdown;

  ValuationReport({
    required this.totalValuation,
    required this.totalItems,
    required this.averageItemValue,
    required this.categoryBreakdown,
    required this.warehouseBreakdown,
    required this.movementClassBreakdown,
  });

  factory ValuationReport.fromJson(Map<String, dynamic> json) {
    return ValuationReport(
      totalValuation: (json['totalValuation'] ?? 0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
      averageItemValue: (json['averageItemValue'] ?? 0).toDouble(),
      categoryBreakdown: List<CategoryValuation>.from(
        (json['categoryBreakdown'] ?? []).map((x) => CategoryValuation.fromJson(x)),
      ),
      warehouseBreakdown: List<WarehouseValuation>.from(
        (json['warehouseBreakdown'] ?? []).map((x) => WarehouseValuation.fromJson(x)),
      ),
      movementClassBreakdown: List<MovementClassValuation>.from(
        (json['movementClassBreakdown'] ?? []).map((x) => MovementClassValuation.fromJson(x)),
      ),
    );
  }
}

class CategoryValuation {
  final String category;
  final double totalValue;
  final int itemCount;
  final double percentage;

  CategoryValuation({
    required this.category,
    required this.totalValue,
    required this.itemCount,
    required this.percentage,
  });

  factory CategoryValuation.fromJson(Map<String, dynamic> json) {
    return CategoryValuation(
      category: json['category'],
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class WarehouseValuation {
  final String warehouse;
  final double totalValue;
  final int itemCount;

  WarehouseValuation({
    required this.warehouse,
    required this.totalValue,
    required this.itemCount,
  });

  factory WarehouseValuation.fromJson(Map<String, dynamic> json) {
    return WarehouseValuation(
      warehouse: json['warehouse'],
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
    );
  }
}

class MovementClassValuation {
  final String movementClass;
  final double totalValue;
  final int itemCount;

  MovementClassValuation({
    required this.movementClass,
    required this.totalValue,
    required this.itemCount,
  });

  factory MovementClassValuation.fromJson(Map<String, dynamic> json) {
    return MovementClassValuation(
      movementClass: json['movementClass'],
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
    );
  }
}

class StockMovementReport {
  final List<FastMovingItem> fastMovingItems;
  final List<SlowMovingItem> slowMovingItems;
  final List<NonMovingItem> nonMovingItems;
  final MovementSummary summary;

  StockMovementReport({
    required this.fastMovingItems,
    required this.slowMovingItems,
    required this.nonMovingItems,
    required this.summary,
  });

  factory StockMovementReport.fromJson(Map<String, dynamic> json) {
    return StockMovementReport(
      fastMovingItems: List<FastMovingItem>.from(
        (json['fastMovingItems'] ?? []).map((x) => FastMovingItem.fromJson(x)),
      ),
      slowMovingItems: List<SlowMovingItem>.from(
        (json['slowMovingItems'] ?? []).map((x) => SlowMovingItem.fromJson(x)),
      ),
      nonMovingItems: List<NonMovingItem>.from(
        (json['nonMovingItems'] ?? []).map((x) => NonMovingItem.fromJson(x)),
      ),
      summary: MovementSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class FastMovingItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double usageRate;
  final double turnoverRatio;
  final int daysSinceLastMovement;

  FastMovingItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.usageRate,
    required this.turnoverRatio,
    required this.daysSinceLastMovement,
  });

  factory FastMovingItem.fromJson(Map<String, dynamic> json) {
    return FastMovingItem(
      itemId: json['itemId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      usageRate: (json['usageRate'] ?? 0).toDouble(),
      turnoverRatio: (json['turnoverRatio'] ?? 0).toDouble(),
      daysSinceLastMovement: json['daysSinceLastMovement'] ?? 0,
    );
  }
}

class SlowMovingItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double usageRate;
  final int daysSinceLastMovement;
  final double currentStockValue;

  SlowMovingItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.usageRate,
    required this.daysSinceLastMovement,
    required this.currentStockValue,
  });

  factory SlowMovingItem.fromJson(Map<String, dynamic> json) {
    return SlowMovingItem(
      itemId: json['itemId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      usageRate: (json['usageRate'] ?? 0).toDouble(),
      daysSinceLastMovement: json['daysSinceLastMovement'] ?? 0,
      currentStockValue: (json['currentStockValue'] ?? 0).toDouble(),
    );
  }
}

class NonMovingItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final int daysSinceLastMovement;
  final double currentStockValue;
  final DateTime lastMovementDate;

  NonMovingItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.daysSinceLastMovement,
    required this.currentStockValue,
    required this.lastMovementDate,
  });

  factory NonMovingItem.fromJson(Map<String, dynamic> json) {
    return NonMovingItem(
      itemId: json['itemId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      daysSinceLastMovement: json['daysSinceLastMovement'] ?? 0,
      currentStockValue: (json['currentStockValue'] ?? 0).toDouble(),
      lastMovementDate: DateTime.parse(json['lastMovementDate']),
    );
  }
}

class MovementSummary {
  final int totalFastMoving;
  final int totalSlowMoving;
  final int totalNonMoving;
  final double fastMovingValue;
  final double slowMovingValue;
  final double nonMovingValue;

  MovementSummary({
    required this.totalFastMoving,
    required this.totalSlowMoving,
    required this.totalNonMoving,
    required this.fastMovingValue,
    required this.slowMovingValue,
    required this.nonMovingValue,
  });

  factory MovementSummary.fromJson(Map<String, dynamic> json) {
    return MovementSummary(
      totalFastMoving: json['totalFastMoving'] ?? 0,
      totalSlowMoving: json['totalSlowMoving'] ?? 0,
      totalNonMoving: json['totalNonMoving'] ?? 0,
      fastMovingValue: (json['fastMovingValue'] ?? 0).toDouble(),
      slowMovingValue: (json['slowMovingValue'] ?? 0).toDouble(),
      nonMovingValue: (json['nonMovingValue'] ?? 0).toDouble(),
    );
  }
}

class LowStockReport {
  final List<LowStockItem> criticalItems;
  final List<LowStockItem> lowStockItems;
  final List<OutOfStockItem> outOfStockItems;
  final LowStockSummary summary;

  LowStockReport({
    required this.criticalItems,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.summary,
  });

  factory LowStockReport.fromJson(Map<String, dynamic> json) {
    return LowStockReport(
      criticalItems: List<LowStockItem>.from(
        (json['criticalItems'] ?? []).map((x) => LowStockItem.fromJson(x)),
      ),
      lowStockItems: List<LowStockItem>.from(
        (json['lowStockItems'] ?? []).map((x) => LowStockItem.fromJson(x)),
      ),
      outOfStockItems: List<OutOfStockItem>.from(
        (json['outOfStockItems'] ?? []).map((x) => OutOfStockItem.fromJson(x)),
      ),
      summary: LowStockSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class LowStockItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final String category;
  final double currentStock;
  final double minimumStock;
  final double reorderPoint;
  final double reorderQuantity;
  final int daysOutOfStock;

  LowStockItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.daysOutOfStock,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      itemId: json['itemId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      category: json['category'],
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      minimumStock: (json['minimumStock'] ?? 0).toDouble(),
      reorderPoint: (json['reorderPoint'] ?? 0).toDouble(),
      reorderQuantity: (json['reorderQuantity'] ?? 0).toDouble(),
      daysOutOfStock: json['daysOutOfStock'] ?? 0,
    );
  }

  double get stockCover => currentStock / reorderPoint;
  bool get isCritical => currentStock <= minimumStock;
}

class OutOfStockItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final String category;
  final int daysOutOfStock;
  final double reorderQuantity;
  final String preferredSupplier;

  OutOfStockItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.category,
    required this.daysOutOfStock,
    required this.reorderQuantity,
    required this.preferredSupplier,
  });

  factory OutOfStockItem.fromJson(Map<String, dynamic> json) {
    return OutOfStockItem(
      itemId: json['itemId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      category: json['category'],
      daysOutOfStock: json['daysOutOfStock'] ?? 0,
      reorderQuantity: (json['reorderQuantity'] ?? 0).toDouble(),
      preferredSupplier: json['preferredSupplier'],
    );
  }
}

class LowStockSummary {
  final int totalCritical;
  final int totalLowStock;
  final int totalOutOfStock;
  final double totalReorderValue;
  final int itemsNeedImmediateAttention;

  LowStockSummary({
    required this.totalCritical,
    required this.totalLowStock,
    required this.totalOutOfStock,
    required this.totalReorderValue,
    required this.itemsNeedImmediateAttention,
  });

  factory LowStockSummary.fromJson(Map<String, dynamic> json) {
    return LowStockSummary(
      totalCritical: json['totalCritical'] ?? 0,
      totalLowStock: json['totalLowStock'] ?? 0,
      totalOutOfStock: json['totalOutOfStock'] ?? 0,
      totalReorderValue: (json['totalReorderValue'] ?? 0).toDouble(),
      itemsNeedImmediateAttention: json['itemsNeedImmediateAttention'] ?? 0,
    );
  }
}

class CategoryAnalysisReport {
  final List<CategorySummary> categories;
  final int totalItems;
  final double totalValuation;
  final Map<String, int> itemTypeDistribution;
  final Map<String, int> movementClassDistribution;

  CategoryAnalysisReport({
    required this.categories,
    required this.totalItems,
    required this.totalValuation,
    required this.itemTypeDistribution,
    required this.movementClassDistribution,
  });

  factory CategoryAnalysisReport.fromJson(Map<String, dynamic> json) {
    return CategoryAnalysisReport(
      categories: List<CategorySummary>.from(
        (json['categories'] ?? []).map((x) => CategorySummary.fromJson(x)),
      ),
      totalItems: json['totalItems'] ?? 0,
      totalValuation: (json['totalValuation'] ?? 0).toDouble(),
      itemTypeDistribution: Map<String, int>.from(json['itemTypeDistribution'] ?? {}),
      movementClassDistribution: Map<String, int>.from(json['movementClassDistribution'] ?? {}),
    );
  }
}

class CategorySummary {
  final String categoryName;
  final int itemCount;
  final double totalValue;
  final double percentage;
  final int lowStockItems;
  final int outOfStockItems;

  CategorySummary({
    required this.categoryName,
    required this.itemCount,
    required this.totalValue,
    required this.percentage,
    required this.lowStockItems,
    required this.outOfStockItems,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      categoryName: json['categoryName'],
      itemCount: json['itemCount'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      lowStockItems: json['lowStockItems'] ?? 0,
      outOfStockItems: json['outOfStockItems'] ?? 0,
    );
  }
}