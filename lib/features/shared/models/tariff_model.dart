enum BillingCycle {
  monthly,
  bi_monthly,
  quarterly,
  annual;

  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.bi_monthly:
        return 'Bi-Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.annual:
        return 'Annual';
    }
  }

  static BillingCycle? fromString(String value) {
    try {
      return BillingCycle.values.firstWhere(
        (e) =>
            e.name == value.toLowerCase() ||
            e.displayName.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

enum NakuruServiceRegion {
  nakuruMunicipality,
  nakuruWest,
  nakuruEast,
  njoro,
  rongai,
  kuresoiNorth,
  kuresoiSouth,
  subukia,
  gilgil,
  naivasha,
  mauNarok,
  viwanda,
  bahati,
  lanet,
  shaabab,
  kabatini,
  barut,
  london,
  kapkures,
  milimani,
  menengai,
  flamingo,
  bondeni,
  kivumbi,
  freeArea,
  kamukunji,
  biashara,
  raceCourse;

  String get displayName {
    final words = name.split(RegExp(r'(?=[A-Z])'));
    return words.map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}').join(' ');
  }

  String get code {
    return name;
  }

  static NakuruServiceRegion? fromString(String value) {
    try {
      return NakuruServiceRegion.values.firstWhere(
            (e) => e.name == value || e.displayName.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<NakuruServiceRegion> get allRegions => NakuruServiceRegion.values;
}

class ConsumptionTier {
  final int tier;
  final double minUnits;
  final double? maxUnits;
  final double rate;
  final String description;
  final bool isProgressive;

  ConsumptionTier({
    required this.tier,
    required this.minUnits,
    this.maxUnits,
    required this.rate,
    required this.description,
    this.isProgressive = true,
  });

  Map<String, dynamic> toJson() => {
    'tier': tier,
    'minUnits': minUnits,
    'maxUnits': maxUnits,
    'rate': rate,
    'description': description,
    'isProgressive': isProgressive,
  };

  static ConsumptionTier fromJson(Map<String, dynamic> json) => ConsumptionTier(
    tier: json['tier']?.toInt() ?? 0,
    minUnits: json['minUnits']?.toDouble() ?? 0.0,
    maxUnits: json['maxUnits']?.toDouble(),
    rate: json['rate']?.toDouble() ?? 0.0,
    description: json['description'] ?? '',
    isProgressive: json['isProgressive'] ?? true,
  );
}

class ServiceCharge {
  final String name;
  final double amount;
  final CalculationType calculationType;
  final String? basis;
  final double? minAmount;
  final double? maxAmount;
  final bool isTaxable;
  final String description;

  ServiceCharge({
    required this.name,
    required this.amount,
    required this.calculationType,
    this.basis,
    this.minAmount,
    this.maxAmount,
    this.isTaxable = true,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'calculationType': calculationType.name,
    'basis': basis,
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'isTaxable': isTaxable,
    'description': description,
  };

  static ServiceCharge fromJson(Map<String, dynamic> json) => ServiceCharge(
    name: json['name'] ?? '',
    amount: json['amount']?.toDouble() ?? 0.0,
    calculationType: CalculationType.fromString(json['calculationType']) ?? CalculationType.fixed,
    basis: json['basis'],
    minAmount: json['minAmount']?.toDouble(),
    maxAmount: json['maxAmount']?.toDouble(),
    isTaxable: json['isTaxable'] ?? true,
    description: json['description'] ?? '',
  );
}

enum CalculationType {
  fixed,
  percentage,
  perUnit;

  String get displayName {
    switch (this) {
      case CalculationType.fixed:
        return 'Fixed Amount';
      case CalculationType.percentage:
        return 'Percentage';
      case CalculationType.perUnit:
        return 'Per Unit';
    }
  }

  static CalculationType? fromString(String value) {
    try {
      return CalculationType.values.firstWhere(
            (e) => e.name == value.toLowerCase().replaceAll('_', ''),
      );
    } catch (_) {
      return null;
    }
  }
}

class TaxLevy {
  final String name;
  final double rate;
  final TaxCalculationType calculationType;
  final List<String> appliesTo;
  final double? minAmount;
  final double? maxAmount;
  final bool isActive;
  final String? legalReference;
  final String description; // ADD THIS FIELD

  TaxLevy({
    required this.name,
    required this.rate,
    required this.calculationType,
    required this.appliesTo,
    this.minAmount,
    this.maxAmount,
    this.isActive = true,
    this.legalReference,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'rate': rate,
    'calculationType': calculationType.name,
    'appliesTo': appliesTo,
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'isActive': isActive,
    'legalReference': legalReference,
    'description': description
  };

  static TaxLevy fromJson(Map<String, dynamic> json) => TaxLevy(
    name: json['name'] ?? '',
    rate: json['rate']?.toDouble() ?? 0.0,
    calculationType: TaxCalculationType.fromString(json['calculationType']) ?? TaxCalculationType.percentage,
    appliesTo: (json['appliesTo'] as List?)?.cast<String>() ?? [],
    minAmount: json['minAmount']?.toDouble(),
    maxAmount: json['maxAmount']?.toDouble(),
    isActive: json['isActive'] ?? true,
    legalReference: json['legalReference'],
    description: json['description']
  );
}

enum TaxCalculationType {
  percentage,
  fixed;

  String get displayName {
    switch (this) {
      case TaxCalculationType.percentage:
        return 'Percentage';
      case TaxCalculationType.fixed:
        return 'Fixed Amount';
    }
  }

  static TaxCalculationType? fromString(String value) {
    try {
      return TaxCalculationType.values.firstWhere(
            (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class PenaltyStructure {
  final String type;
  final double rate;
  final PenaltyCalculationType calculationType;
  final PenaltyFrequency frequency;
  final int gracePeriod;
  final double? maxAmount;
  final double? capAmount;
  final String description;

  PenaltyStructure({
    required this.type,
    required this.rate,
    required this.calculationType,
    required this.frequency,
    required this.gracePeriod,
    this.maxAmount,
    this.capAmount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'rate': rate,
    'calculationType': calculationType.name,
    'frequency': frequency.name,
    'gracePeriod': gracePeriod,
    'maxAmount': maxAmount,
    'capAmount': capAmount,
    'description': description,
  };

  static PenaltyStructure fromJson(Map<String, dynamic> json) => PenaltyStructure(
    type: json['type'] ?? '',
    rate: json['rate']?.toDouble() ?? 0.0,
    calculationType: PenaltyCalculationType.fromString(json['calculationType']) ?? PenaltyCalculationType.percentage,
    frequency: PenaltyFrequency.fromString(json['frequency']) ?? PenaltyFrequency.monthly,
    gracePeriod: json['gracePeriod']?.toInt() ?? 0,
    maxAmount: json['maxAmount']?.toDouble(),
    capAmount: json['capAmount']?.toDouble(),
    description: json['description'] ?? '',
  );
}

enum PenaltyCalculationType {
  percentage,
  fixed;

  String get displayName {
    switch (this) {
      case PenaltyCalculationType.percentage:
        return 'Percentage';
      case PenaltyCalculationType.fixed:
        return 'Fixed Amount';
    }
  }

  static PenaltyCalculationType? fromString(String value) {
    try {
      return PenaltyCalculationType.values.firstWhere(
            (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

enum PenaltyFrequency {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case PenaltyFrequency.daily:
        return 'Daily';
      case PenaltyFrequency.weekly:
        return 'Weekly';
      case PenaltyFrequency.monthly:
        return 'Monthly';
    }
  }

  static PenaltyFrequency? fromString(String value) {
    try {
      return PenaltyFrequency.values.firstWhere(
            (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class Tariff {
  final String? id;
  final String name;
  final String code;
  final String description;
  final BillingCycle billingCycle;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final bool isApproved;
  final List<NakuruServiceRegion> serviceRegions;
  final List<ConsumptionTier> consumptionTiers;
  final double baseRate;
  final double minimumCharge;
  final List<ServiceCharge> serviceCharges;
  final List<ServiceCharge> fixedCharges;
  final List<TaxLevy> taxesLevis;
  final List<PenaltyStructure> penalties;
  final List<Map<String, dynamic>> meterRentalCharges;
  final List<Map<String, dynamic>> connectionCharges;
  final RoundingRule roundingRule;
  final int decimalPlaces;
  final double minimumConsumption;
  final String? createdBy;
  final String? updatedBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final int version;
  final String? previousVersionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? createdByUser;
  final Map<String, dynamic>? updatedByUser;
  final Map<String, dynamic>? approvedByUser;

  Tariff({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.billingCycle,
    required this.effectiveFrom,
    this.effectiveTo,
    this.isActive = true,
    this.isApproved = false,
    required this.serviceRegions,
    this.consumptionTiers = const [],
    this.baseRate = 0.0,
    this.minimumCharge = 0.0,
    this.serviceCharges = const [],
    this.fixedCharges = const [],
    this.taxesLevis = const [],
    this.penalties = const [],
    this.meterRentalCharges = const [],
    this.connectionCharges = const [],
    this.roundingRule = RoundingRule.nearest,
    this.decimalPlaces = 2,
    this.minimumConsumption = 0.0,
    this.createdBy,
    this.updatedBy,
    this.approvedBy,
    this.approvedAt,
    this.version = 1,
    this.previousVersionId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUser,
    this.updatedByUser,
    this.approvedByUser,
  });

  bool get isCurrent {
    final now = DateTime.now();
    return isActive &&
        isApproved &&
        effectiveFrom.isBefore(now) &&
        (effectiveTo == null || effectiveTo!.isAfter(now));
  }

  int get daysUntilEffective {
    final now = DateTime.now();
    final diff = effectiveFrom.difference(now);
    return diff.inDays;
  }

  String get formattedEffectivePeriod {
    final from = "${effectiveFrom.day}/${effectiveFrom.month}/${effectiveFrom.year}";
    final to = effectiveTo != null
        ? "${effectiveTo!.day}/${effectiveTo!.month}/${effectiveTo!.year}"
        : 'Indefinite';
    return '$from to $to';
  }

  List<String> get serviceRegionsDisplay {
    return serviceRegions.map((region) => region.displayName).toList();
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'name': name,
    'code': code,
    'description': description,
    'billingCycle': billingCycle.name,
    'effectiveFrom': effectiveFrom.toIso8601String(),
    if (effectiveTo != null) 'effectiveTo': effectiveTo!.toIso8601String(),
    'isActive': isActive,
    'isApproved': isApproved,
    'serviceRegions': serviceRegions.map((e) => e.code).toList(),
    'consumptionTiers': consumptionTiers.map((e) => e.toJson()).toList(),
    'baseRate': baseRate,
    'minimumCharge': minimumCharge,
    'serviceCharges': serviceCharges.map((e) => e.toJson()).toList(),
    'fixedCharges': fixedCharges.map((e) => e.toJson()).toList(),
    'taxesLevis': taxesLevis.map((e) => e.toJson()).toList(),
    'penalties': penalties.map((e) => e.toJson()).toList(),
    'meterRentalCharges': meterRentalCharges,
    'connectionCharges': connectionCharges,
    'roundingRule': roundingRule.name,
    'decimalPlaces': decimalPlaces,
    'minimumConsumption': minimumConsumption,
    if (createdBy != null) 'createdBy': createdBy,
    if (updatedBy != null) 'updatedBy': updatedBy,
    'version': version,
    if (previousVersionId != null) 'previousVersion': previousVersionId,
  };

  static Tariff fromJson(Map<String, dynamic> json) {
    final effectiveFrom = DateTime.tryParse(json['effectiveFrom'] ?? '') ?? DateTime.now();
    final effectiveTo = json['effectiveTo'] != null ? DateTime.tryParse(json['effectiveTo']) : null;

    return Tariff(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      billingCycle: BillingCycle.fromString(json['billingCycle']) ?? BillingCycle.monthly,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      isActive: json['isActive'] ?? true,
      isApproved: json['isApproved'] ?? false,
      serviceRegions: (json['serviceRegions'] as List?)
          ?.map((e) => NakuruServiceRegion.fromString(e.toString()) ?? NakuruServiceRegion.nakuruMunicipality)
          .whereType<NakuruServiceRegion>()
          .toList() ??
          [],
      consumptionTiers: (json['consumptionTiers'] as List?)
          ?.map((e) => ConsumptionTier.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      baseRate: json['baseRate']?.toDouble() ?? 0.0,
      minimumCharge: json['minimumCharge']?.toDouble() ?? 0.0,
      serviceCharges: (json['serviceCharges'] as List?)
          ?.map((e) => ServiceCharge.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      fixedCharges: (json['fixedCharges'] as List?)
          ?.map((e) => ServiceCharge.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      taxesLevis: (json['taxesLevis'] as List?)
          ?.map((e) => TaxLevy.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      penalties: (json['penalties'] as List?)
          ?.map((e) => PenaltyStructure.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      meterRentalCharges: (json['meterRentalCharges'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      connectionCharges: (json['connectionCharges'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      roundingRule: RoundingRule.fromString(json['roundingRule']) ?? RoundingRule.nearest,
      decimalPlaces: json['decimalPlaces']?.toInt() ?? 2,
      minimumConsumption: json['minimumConsumption']?.toDouble() ?? 0.0,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt']) : null,
      version: json['version']?.toInt() ?? 1,
      previousVersionId: json['previousVersion']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      createdByUser: json['createdBy'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['createdBy']) : null,
      updatedByUser: json['updatedBy'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['updatedBy']) : null,
      approvedByUser: json['approvedBy'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['approvedBy']) : null,
    );
  }

  Tariff copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    BillingCycle? billingCycle,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    bool? isActive,
    bool? isApproved,
    List<NakuruServiceRegion>? serviceRegions,
    List<ConsumptionTier>? consumptionTiers,
    double? baseRate,
    double? minimumCharge,
    List<ServiceCharge>? serviceCharges,
    List<ServiceCharge>? fixedCharges,
    List<TaxLevy>? taxesLevis,
    List<PenaltyStructure>? penalties,
    List<Map<String, dynamic>>? meterRentalCharges,
    List<Map<String, dynamic>>? connectionCharges,
    RoundingRule? roundingRule,
    int? decimalPlaces,
    double? minimumConsumption,
    String? createdBy,
    String? updatedBy,
    String? approvedBy,
    DateTime? approvedAt,
    int? version,
    String? previousVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? createdByUser,
    Map<String, dynamic>? updatedByUser,
    Map<String, dynamic>? approvedByUser,
  }) {
    return Tariff(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      billingCycle: billingCycle ?? this.billingCycle,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      serviceRegions: serviceRegions ?? this.serviceRegions,
      consumptionTiers: consumptionTiers ?? this.consumptionTiers,
      baseRate: baseRate ?? this.baseRate,
      minimumCharge: minimumCharge ?? this.minimumCharge,
      serviceCharges: serviceCharges ?? this.serviceCharges,
      fixedCharges: fixedCharges ?? this.fixedCharges,
      taxesLevis: taxesLevis ?? this.taxesLevis,
      penalties: penalties ?? this.penalties,
      meterRentalCharges: meterRentalCharges ?? this.meterRentalCharges,
      connectionCharges: connectionCharges ?? this.connectionCharges,
      roundingRule: roundingRule ?? this.roundingRule,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      minimumConsumption: minimumConsumption ?? this.minimumConsumption,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      version: version ?? this.version,
      previousVersionId: previousVersionId ?? this.previousVersionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUser: createdByUser ?? this.createdByUser,
      updatedByUser: updatedByUser ?? this.updatedByUser,
      approvedByUser: approvedByUser ?? this.approvedByUser,
    );
  }
}

enum RoundingRule {
  up,
  down,
  nearest;

  String get displayName {
    switch (this) {
      case RoundingRule.up:
        return 'Round Up';
      case RoundingRule.down:
        return 'Round Down';
      case RoundingRule.nearest:
        return 'Round to Nearest';
    }
  }

  static RoundingRule? fromString(String value) {
    try {
      return RoundingRule.values.firstWhere(
            (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class TariffFilter {
  final bool? isActive;
  final bool? isApproved;
  final NakuruServiceRegion? serviceRegion;
  final BillingCycle? billingCycle;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final String? search;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  TariffFilter({
    this.isActive,
    this.isApproved,
    this.serviceRegion,
    this.billingCycle,
    this.effectiveFrom,
    this.effectiveTo,
    this.search,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (isActive != null) params['isActive'] = isActive.toString();
    if (isApproved != null) params['isApproved'] = isApproved.toString();
    if (serviceRegion != null) params['serviceRegion'] = serviceRegion!.code;
    if (billingCycle != null) params['billingCycle'] = billingCycle!.name;
    if (effectiveFrom != null) params['effectiveFrom'] = effectiveFrom!.toIso8601String();
    if (effectiveTo != null) params['effectiveTo'] = effectiveTo!.toIso8601String();
    if (search != null && search!.isNotEmpty) params['search'] = search!;

    return params;
  }

  TariffFilter copyWith({
    bool? isActive,
    bool? isApproved,
    NakuruServiceRegion? serviceRegion,
    BillingCycle? billingCycle,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return TariffFilter(
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      serviceRegion: serviceRegion ?? this.serviceRegion,
      billingCycle: billingCycle ?? this.billingCycle,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class BillCalculationResult {
  final double consumptionCharge;
  final double serviceCharges;
  final double fixedCharges;
  final double taxes;
  final double total;
  final List<Map<String, dynamic>> breakdown;

  BillCalculationResult({
    required this.consumptionCharge,
    required this.serviceCharges,
    required this.fixedCharges,
    required this.taxes,
    required this.total,
    required this.breakdown,
  });

  factory BillCalculationResult.fromJson(Map<String, dynamic> json) {
    return BillCalculationResult(
      consumptionCharge: json['consumptionCharge']?.toDouble() ?? 0.0,
      serviceCharges: json['serviceCharges']?.toDouble() ?? 0.0,
      fixedCharges: json['fixedCharges']?.toDouble() ?? 0.0,
      taxes: json['taxes']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      breakdown: (json['breakdown'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}

class TariffStatistics {
  final int totalTariffs;
  final int activeTariffs;
  final int approvedTariffs;
  final Map<String, int> byBillingCycle;
  final Map<String, int> byRegion;
  final int expiringThisMonth;

  TariffStatistics({
    required this.totalTariffs,
    required this.activeTariffs,
    required this.approvedTariffs,
    required this.byBillingCycle,
    required this.byRegion,
    required this.expiringThisMonth,
  });

  factory TariffStatistics.fromJson(Map<String, dynamic> json) {
    return TariffStatistics(
      totalTariffs: json['totalTariffs']?.toInt() ?? 0,
      activeTariffs: json['activeTariffs']?.toInt() ?? 0,
      approvedTariffs: json['approvedTariffs']?.toInt() ?? 0,
      byBillingCycle: Map<String, int>.from(json['byBillingCycle'] ?? {}),
      byRegion: Map<String, int>.from(json['byRegion'] ?? {}),
      expiringThisMonth: json['expiringThisMonth']?.toInt() ?? 0,
    );
  }
}