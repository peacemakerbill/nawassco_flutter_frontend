class InventoryCategory {
  final String id;
  final String categoryCode;
  final String categoryName;
  final String description;
  final String? parentCategory;
  final List<String> characteristics;
  final List<String> storageRequirements;
  final List<String> handlingInstructions;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryCategory({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    required this.description,
    this.parentCategory,
    required this.characteristics,
    required this.storageRequirements,
    required this.handlingInstructions,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['_id'] ?? json['id'],
      categoryCode: json['categoryCode'],
      categoryName: json['categoryName'],
      description: json['description'],
      parentCategory: json['parentCategory'],
      characteristics: List<String>.from(json['characteristics'] ?? []),
      storageRequirements: List<String>.from(json['storageRequirements'] ?? []),
      handlingInstructions: List<String>.from(json['handlingInstructions'] ?? []),
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] is String ? json['createdBy'] : json['createdBy']['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'description': description,
      'parentCategory': parentCategory,
      'characteristics': characteristics,
      'storageRequirements': storageRequirements,
      'handlingInstructions': handlingInstructions,
      'isActive': isActive,
    };
  }

  InventoryCategory copyWith({
    String? categoryCode,
    String? categoryName,
    String? description,
    String? parentCategory,
    List<String>? characteristics,
    List<String>? storageRequirements,
    List<String>? handlingInstructions,
    bool? isActive,
  }) {
    return InventoryCategory(
      id: id,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      parentCategory: parentCategory ?? this.parentCategory,
      characteristics: characteristics ?? this.characteristics,
      storageRequirements: storageRequirements ?? this.storageRequirements,
      handlingInstructions: handlingInstructions ?? this.handlingInstructions,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}