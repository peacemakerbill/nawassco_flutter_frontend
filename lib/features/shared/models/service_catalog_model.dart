import 'package:flutter/material.dart';

enum ServiceCategory {
  waterServices('Water Services', Icons.water_drop, Colors.blue),
  sewerServices('Sewer Services', Icons.gite, Colors.brown),
  laboratoryServices('Lab Services', Icons.science, Colors.purple),
  connectionServices('Connection', Icons.link, Colors.green),
  maintenanceServices('Maintenance', Icons.build, Colors.orange),
  billingServices('Billing', Icons.receipt, Colors.teal),
  emergencyServices('Emergency', Icons.emergency, Colors.red),
  consultancyServices('Consultancy', Icons.business, Colors.indigo),
  infrastructureServices('Infrastructure', Icons.apartment, Colors.deepOrange),
  environmentalServices('Environmental', Icons.nature, Colors.green),
  customerServices('Customer Service', Icons.support_agent, Colors.pink),
  meterServices('Meter Services', Icons.speed, Colors.cyan),
  qualityServices('Quality Services', Icons.verified, Colors.lime),
  planningServices('Planning', Icons.architecture, Colors.amber),
  educationServices('Education', Icons.school, Colors.deepPurple);

  final String displayName;
  final IconData icon;
  final Color color;

  const ServiceCategory(this.displayName, this.icon, this.color);
}

enum ServiceStatus {
  active('Active', Colors.green),
  inactive('Inactive', Colors.grey),
  underReview('Under Review', Colors.orange),
  suspended('Suspended', Colors.red),
  deprecated('Deprecated', Colors.grey);

  final String displayName;
  final Color color;

  const ServiceStatus(this.displayName, this.color);
}

enum CustomerType {
  residential('Residential', Icons.home),
  commercial('Commercial', Icons.business),
  industrial('Industrial', Icons.factory),
  institutional('Institutional', Icons.school),
  government('Government', Icons.account_balance),
  agricultural('Agricultural', Icons.agriculture),
  all('All', Icons.people);

  final String displayName;
  final IconData icon;

  const CustomerType(this.displayName, this.icon);
}

class ServiceCatalog {
  final String id;
  final String serviceCode;
  final String name;
  final String description;
  final ServiceCategory category;
  final String type;
  final ServiceStatus status;
  final PricingStructure pricing;
  final EligibilityCriteria eligibility;
  final List<String> availableAreas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final int version;
  final List<ServiceRequirement> requirements;
  final ServiceProcess process;
  final ServiceLevelAgreement sla;
  final List<ServiceWindow> serviceWindows;
  final List<TechnicalRequirement> technicalRequirements;
  final int? popularityScore;

  const ServiceCatalog({
    required this.id,
    required this.serviceCode,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.pricing,
    required this.eligibility,
    required this.availableAreas,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.version,
    required this.requirements,
    required this.process,
    required this.sla,
    required this.serviceWindows,
    required this.technicalRequirements,
    this.popularityScore,
  });

  factory ServiceCatalog.fromJson(Map<String, dynamic> json) {
    return ServiceCatalog(
      id: json['_id'] ?? json['id'],
      serviceCode: json['serviceCode'],
      name: json['name'],
      description: json['description'],
      category: ServiceCategory.values.firstWhere(
            (e) => e.name == (json['category'] as String).toLowerCase().replaceAll(' ', ''),
        orElse: () => ServiceCategory.waterServices,
      ),
      type: json['type'],
      status: ServiceStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String).toLowerCase().replaceAll(' ', ''),
        orElse: () => ServiceStatus.active,
      ),
      pricing: PricingStructure.fromJson(json['pricing'] ?? {}),
      eligibility: EligibilityCriteria.fromJson(json['eligibility'] ?? {}),
      availableAreas: List<String>.from(json['availableAreas'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy']?['name'] ?? json['createdBy'] ?? 'System',
      version: json['version'] ?? 1,
      requirements: List<ServiceRequirement>.from(
        (json['requirements'] ?? []).map((x) => ServiceRequirement.fromJson(x)),
      ),
      process: ServiceProcess.fromJson(json['process'] ?? {}),
      sla: ServiceLevelAgreement.fromJson(json['sla'] ?? {}),
      serviceWindows: List<ServiceWindow>.from(
        (json['serviceWindows'] ?? []).map((x) => ServiceWindow.fromJson(x)),
      ),
      technicalRequirements: List<TechnicalRequirement>.from(
        (json['technicalRequirements'] ?? []).map((x) => TechnicalRequirement.fromJson(x)),
      ),
      popularityScore: json['popularityScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceCode': serviceCode,
      'name': name,
      'description': description,
      'category': category.name,
      'type': type,
      'status': status.name,
      'pricing': pricing.toJson(),
      'eligibility': eligibility.toJson(),
      'availableAreas': availableAreas,
      'requirements': requirements.map((x) => x.toJson()).toList(),
      'process': process.toJson(),
      'sla': sla.toJson(),
      'serviceWindows': serviceWindows.map((x) => x.toJson()).toList(),
      'technicalRequirements': technicalRequirements.map((x) => x.toJson()).toList(),
    };
  }

  ServiceCatalog copyWith({
    String? id,
    String? serviceCode,
    String? name,
    String? description,
    ServiceCategory? category,
    String? type,
    ServiceStatus? status,
    PricingStructure? pricing,
    EligibilityCriteria? eligibility,
    List<String>? availableAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    int? version,
    List<ServiceRequirement>? requirements,
    ServiceProcess? process,
    ServiceLevelAgreement? sla,
    List<ServiceWindow>? serviceWindows,
    List<TechnicalRequirement>? technicalRequirements,
    int? popularityScore,
  }) {
    return ServiceCatalog(
      id: id ?? this.id,
      serviceCode: serviceCode ?? this.serviceCode,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      pricing: pricing ?? this.pricing,
      eligibility: eligibility ?? this.eligibility,
      availableAreas: availableAreas ?? this.availableAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      version: version ?? this.version,
      requirements: requirements ?? this.requirements,
      process: process ?? this.process,
      sla: sla ?? this.sla,
      serviceWindows: serviceWindows ?? this.serviceWindows,
      technicalRequirements: technicalRequirements ?? this.technicalRequirements,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }
}

class PricingStructure {
  final String pricingModel;
  final double basePrice;
  final String currency;
  final List<VariableComponent> variableComponents;
  final List<Tax> taxes;
  final List<Discount> discounts;

  const PricingStructure({
    required this.pricingModel,
    required this.basePrice,
    this.currency = 'KES',
    this.variableComponents = const [],
    this.taxes = const [],
    this.discounts = const [],
  });

  factory PricingStructure.fromJson(Map<String, dynamic> json) {
    return PricingStructure(
      pricingModel: json['pricingModel'] ?? 'fixed',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      variableComponents: List<VariableComponent>.from(
        (json['variableComponents'] ?? []).map((x) => VariableComponent.fromJson(x)),
      ),
      taxes: List<Tax>.from((json['taxes'] ?? []).map((x) => Tax.fromJson(x))),
      discounts: List<Discount>.from((json['discounts'] ?? []).map((x) => Discount.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pricingModel': pricingModel,
      'basePrice': basePrice,
      'currency': currency,
      'variableComponents': variableComponents.map((x) => x.toJson()).toList(),
      'taxes': taxes.map((x) => x.toJson()).toList(),
      'discounts': discounts.map((x) => x.toJson()).toList(),
    };
  }
}

class VariableComponent {
  final String component;
  final String unit;
  final double rate;
  final int? minQuantity;
  final int? maxQuantity;

  const VariableComponent({
    required this.component,
    required this.unit,
    required this.rate,
    this.minQuantity,
    this.maxQuantity,
  });

  factory VariableComponent.fromJson(Map<String, dynamic> json) {
    return VariableComponent(
      component: json['component'],
      unit: json['unit'],
      rate: (json['rate'] ?? 0).toDouble(),
      minQuantity: json['minQuantity'],
      maxQuantity: json['maxQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'component': component,
      'unit': unit,
      'rate': rate,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
    };
  }
}

class Tax {
  final String name;
  final double rate;
  final String description;

  const Tax({
    required this.name,
    required this.rate,
    required this.description,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      name: json['name'],
      rate: (json['rate'] ?? 0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rate': rate,
      'description': description,
    };
  }
}

class Discount {
  final String type;
  final double value;
  final String? condition;
  final DateTime? validUntil;
  final List<String> applicableTo;

  const Discount({
    required this.type,
    required this.value,
    this.condition,
    this.validUntil,
    this.applicableTo = const [],
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      type: json['type'],
      value: (json['value'] ?? 0).toDouble(),
      condition: json['condition'],
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
      applicableTo: List<String>.from(json['applicableTo'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'condition': condition,
      'validUntil': validUntil?.toIso8601String(),
      'applicableTo': applicableTo,
    };
  }
}

class EligibilityCriteria {
  final List<CustomerType> customerTypes;
  final List<String> propertyTypes;
  final List<String> prerequisites;
  final List<String> documentationRequired;

  const EligibilityCriteria({
    this.customerTypes = const [],
    this.propertyTypes = const [],
    this.prerequisites = const [],
    this.documentationRequired = const [],
  });

  factory EligibilityCriteria.fromJson(Map<String, dynamic> json) {
    return EligibilityCriteria(
      customerTypes: List<CustomerType>.from(
        (json['customerTypes'] ?? []).map((x) =>
            CustomerType.values.firstWhere(
                  (e) => e.name == x.toString().toLowerCase(),
              orElse: () => CustomerType.residential,
            ),
        ),
      ),
      propertyTypes: List<String>.from(json['propertyTypes'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      documentationRequired: List<String>.from(json['documentationRequired'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerTypes': customerTypes.map((e) => e.name).toList(),
      'propertyTypes': propertyTypes,
      'prerequisites': prerequisites,
      'documentationRequired': documentationRequired,
    };
  }
}

class ServiceRequirement {
  final String requirement;
  final String type;
  final bool mandatory;
  final String description;

  const ServiceRequirement({
    required this.requirement,
    required this.type,
    required this.mandatory,
    required this.description,
  });

  factory ServiceRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceRequirement(
      requirement: json['requirement'],
      type: json['type'],
      mandatory: json['mandatory'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'type': type,
      'mandatory': mandatory,
      'description': description,
    };
  }
}

class ServiceProcess {
  final List<ProcessStep> steps;
  final int estimatedDuration;
  final bool approvalRequired;
  final String? approvalAuthority;

  const ServiceProcess({
    this.steps = const [],
    required this.estimatedDuration,
    this.approvalRequired = false,
    this.approvalAuthority,
  });

  factory ServiceProcess.fromJson(Map<String, dynamic> json) {
    return ServiceProcess(
      steps: List<ProcessStep>.from(
        (json['steps'] ?? []).map((x) => ProcessStep.fromJson(x)),
      ),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      approvalRequired: json['approvalRequired'] ?? false,
      approvalAuthority: json['approvalAuthority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps.map((x) => x.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'approvalRequired': approvalRequired,
      'approvalAuthority': approvalAuthority,
    };
  }
}

class ProcessStep {
  final int step;
  final String name;
  final String description;
  final String responsible;
  final int estimatedTime;

  const ProcessStep({
    required this.step,
    required this.name,
    required this.description,
    required this.responsible,
    required this.estimatedTime,
  });

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      step: json['step'] ?? 0,
      name: json['name'],
      description: json['description'],
      responsible: json['responsible'],
      estimatedTime: json['estimatedTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'name': name,
      'description': description,
      'responsible': responsible,
      'estimatedTime': estimatedTime,
    };
  }
}

class ServiceLevelAgreement {
  final int responseTime;
  final int resolutionTime;
  final int availability;
  final String supportHours;

  const ServiceLevelAgreement({
    required this.responseTime,
    required this.resolutionTime,
    required this.availability,
    required this.supportHours,
  });

  factory ServiceLevelAgreement.fromJson(Map<String, dynamic> json) {
    return ServiceLevelAgreement(
      responseTime: json['responseTime'] ?? 0,
      resolutionTime: json['resolutionTime'] ?? 0,
      availability: json['availability'] ?? 0,
      supportHours: json['supportHours'] ?? '24/7',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseTime': responseTime,
      'resolutionTime': resolutionTime,
      'availability': availability,
      'supportHours': supportHours,
    };
  }
}

class ServiceWindow {
  final List<String> days;
  final String startTime;
  final String endTime;
  final String type;

  const ServiceWindow({
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory ServiceWindow.fromJson(Map<String, dynamic> json) {
    return ServiceWindow(
      days: List<String>.from(json['days'] ?? []),
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
    };
  }
}

class TechnicalRequirement {
  final String requirement;
  final String specification;
  final String? unit;
  final double? minValue;
  final double? maxValue;

  const TechnicalRequirement({
    required this.requirement,
    required this.specification,
    this.unit,
    this.minValue,
    this.maxValue,
  });

  factory TechnicalRequirement.fromJson(Map<String, dynamic> json) {
    return TechnicalRequirement(
      requirement: json['requirement'],
      specification: json['specification'],
      unit: json['unit'],
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement': requirement,
      'specification': specification,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }
}

class AvailabilityCheck {
  final bool available;
  final List<String> reasons;
  final ServiceCatalog service;

  const AvailabilityCheck({
    required this.available,
    required this.reasons,
    required this.service,
  });
}