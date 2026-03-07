class SupplierCategory {
  final String id;
  final String categoryCode;
  final String categoryName;
  final String description;
  final String? parentCategoryId;
  final int level;
  final bool nawasscoSpecific;
  final List<dynamic> minimumRequirements;
  final List<String> mandatoryDocuments;
  final List<dynamic> evaluationCriteria;
  final double averageContractValue;
  final double creditLimitDefault;
  final int paymentTermsDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierCategory({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    required this.description,
    this.parentCategoryId,
    required this.level,
    required this.nawasscoSpecific,
    required this.minimumRequirements,
    required this.mandatoryDocuments,
    required this.evaluationCriteria,
    required this.averageContractValue,
    required this.creditLimitDefault,
    required this.paymentTermsDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierCategory.fromJson(Map<String, dynamic> json) {
    return SupplierCategory(
      id: json['_id'] ?? json['id'],
      categoryCode: json['categoryCode'],
      categoryName: json['categoryName'],
      description: json['description'],
      parentCategoryId: json['parentCategory'],
      level: json['level'],
      nawasscoSpecific: json['nawasscoSpecific'] ?? false,
      minimumRequirements: List<dynamic>.from(json['minimumRequirements'] ?? []),
      mandatoryDocuments: List<String>.from(json['mandatoryDocuments'] ?? []),
      evaluationCriteria: List<dynamic>.from(json['evaluationCriteria'] ?? []),
      averageContractValue: (json['averageContractValue'] ?? 0).toDouble(),
      creditLimitDefault: (json['creditLimitDefault'] ?? 0).toDouble(),
      paymentTermsDefault: json['paymentTermsDefault'] ?? 30,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'description': description,
      'parentCategory': parentCategoryId,
      'level': level,
      'nawasscoSpecific': nawasscoSpecific,
      'minimumRequirements': minimumRequirements,
      'mandatoryDocuments': mandatoryDocuments,
      'evaluationCriteria': evaluationCriteria,
      'averageContractValue': averageContractValue,
      'creditLimitDefault': creditLimitDefault,
      'paymentTermsDefault': paymentTermsDefault,
      'isActive': isActive,
    };
  }
}