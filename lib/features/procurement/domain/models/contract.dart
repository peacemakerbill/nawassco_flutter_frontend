class Contract {
  final String id;
  final String contractNumber;
  final String title;
  final String? description;
  final String supplierId;
  final String supplierName;
  final String? procurementOfficerId;
  final String? procurementOfficerName;
  final String? signatoryId;
  final String? signatoryName;
  final double contractValue;
  final String currency;
  final String type;
  final String? category;
  final DateTime startDate;
  final DateTime endDate;
  final bool renewable;
  final int renewalCount;
  final int maxRenewals;
  final String? renewalTerms;
  final String status;
  final String? approvalStatus;
  final DateTime? approvedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExpired;
  final bool renewalAllowed;

  Contract({
    required this.id,
    required this.contractNumber,
    required this.title,
    this.description,
    required this.supplierId,
    required this.supplierName,
    this.procurementOfficerId,
    this.procurementOfficerName,
    this.signatoryId,
    this.signatoryName,
    required this.contractValue,
    this.currency = 'KES',
    required this.type,
    this.category,
    required this.startDate,
    required this.endDate,
    required this.renewable,
    required this.renewalCount,
    required this.maxRenewals,
    this.renewalTerms,
    required this.status,
    this.approvalStatus,
    this.approvedDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isExpired,
    required this.renewalAllowed,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? json['_id'],
      contractNumber: json['contractNumber'],
      title: json['title'],
      description: json['description'],
      supplierId: json['supplier'] is String ? json['supplier'] : json['supplier']?['_id'],
      supplierName: _getSupplierName(json['supplier']),
      procurementOfficerId: json['procurementOfficer'] is String ? json['procurementOfficer'] : json['procurementOfficer']?['_id'],
      procurementOfficerName: _getUserName(json['procurementOfficer']),
      signatoryId: json['signatory'] is String ? json['signatory'] : json['signatory']?['_id'],
      signatoryName: _getUserName(json['signatory']),
      contractValue: (json['contractValue'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      type: json['type'],
      category: json['category'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      renewable: json['renewable'] ?? false,
      renewalCount: json['renewalCount'] ?? 0,
      maxRenewals: json['maxRenewals'] ?? 0,
      renewalTerms: json['renewalTerms'],
      status: json['status'],
      approvalStatus: json['approvalStatus'],
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isExpired: json['isExpired'] ?? false,
      renewalAllowed: json['renewalAllowed'] ?? false,
    );
  }

  static String _getSupplierName(dynamic supplier) {
    if (supplier == null) return 'Unknown Supplier';
    if (supplier is String) return supplier;
    return supplier['companyName'] ?? supplier['tradingName'] ?? 'Unknown Supplier';
  }

  static String? _getUserName(dynamic user) {
    if (user == null) return null;
    if (user is String) return user;
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'contractNumber': contractNumber,
      'title': title,
      'description': description,
      'supplier': supplierId,
      'procurementOfficer': procurementOfficerId,
      'signatory': signatoryId,
      'contractValue': contractValue,
      'currency': currency,
      'type': type,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'renewable': renewable,
      'maxRenewals': maxRenewals,
      'renewalTerms': renewalTerms,
    };
  }
}

class ContractStats {
  final int totalContracts;
  final double totalValue;
  final List<StatusStats> byStatus;
  final String timeframe;

  ContractStats({
    required this.totalContracts,
    required this.totalValue,
    required this.byStatus,
    required this.timeframe,
  });

  factory ContractStats.fromJson(Map<String, dynamic> json) {
    return ContractStats(
      totalContracts: json['totalContracts'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      byStatus: (json['byStatus'] as List? ?? []).map((e) => StatusStats.fromJson(e)).toList(),
      timeframe: json['timeframe'] ?? 'month',
    );
  }
}

class StatusStats {
  final String status;
  final int count;
  final double value;
  final double averageValue;

  StatusStats({
    required this.status,
    required this.count,
    required this.value,
    required this.averageValue,
  });

  factory StatusStats.fromJson(Map<String, dynamic> json) {
    return StatusStats(
      status: json['status'],
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      averageValue: (json['averageValue'] ?? 0).toDouble(),
    );
  }
}