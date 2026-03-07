// lib/features/store_settings/models/store_settings_model.dart
class StoreSettings {
  final String id;
  final String companyName;
  final String currency;
  final String timezone;
  final String dateFormat;
  final String language;
  final InventorySettings inventory;
  final StockMovementSettings stockMovement;
  final PurchaseOrderSettings purchaseOrder;
  final StockTakeSettings stockTake;
  final WarehouseSettings warehouse;
  final ReportingSettings reporting;
  final NotificationSettings notifications;
  final SecuritySettings security;
  final SystemSettings system;
  final bool isActive;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreSettings({
    required this.id,
    required this.companyName,
    required this.currency,
    required this.timezone,
    required this.dateFormat,
    required this.language,
    required this.inventory,
    required this.stockMovement,
    required this.purchaseOrder,
    required this.stockTake,
    required this.warehouse,
    required this.reporting,
    required this.notifications,
    required this.security,
    required this.system,
    required this.isActive,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      id: json['_id'] ?? json['id'] ?? '',
      companyName: json['companyName'] ?? 'Nawassco Stores',
      currency: json['currency'] ?? 'KES',
      timezone: json['timezone'] ?? 'Africa/Nairobi',
      dateFormat: json['dateFormat'] ?? 'DD/MM/YYYY',
      language: json['language'] ?? 'en',
      inventory: InventorySettings.fromJson(json['inventory'] ?? {}),
      stockMovement: StockMovementSettings.fromJson(json['stockMovement'] ?? {}),
      purchaseOrder: PurchaseOrderSettings.fromJson(json['purchaseOrder'] ?? {}),
      stockTake: StockTakeSettings.fromJson(json['stockTake'] ?? {}),
      warehouse: WarehouseSettings.fromJson(json['warehouse'] ?? {}),
      reporting: ReportingSettings.fromJson(json['reporting'] ?? {}),
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
      security: SecuritySettings.fromJson(json['security'] ?? {}),
      system: SystemSettings.fromJson(json['system'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] ?? 'system',
      updatedBy: json['updatedBy'] ?? 'system',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'currency': currency,
      'timezone': timezone,
      'dateFormat': dateFormat,
      'language': language,
      'inventory': inventory.toJson(),
      'stockMovement': stockMovement.toJson(),
      'purchaseOrder': purchaseOrder.toJson(),
      'stockTake': stockTake.toJson(),
      'warehouse': warehouse.toJson(),
      'reporting': reporting.toJson(),
      'notifications': notifications.toJson(),
      'security': security.toJson(),
      'system': system.toJson(),
    };
  }

  StoreSettings copyWith({
    String? companyName,
    String? currency,
    String? timezone,
    String? dateFormat,
    String? language,
    InventorySettings? inventory,
    StockMovementSettings? stockMovement,
    PurchaseOrderSettings? purchaseOrder,
    StockTakeSettings? stockTake,
    WarehouseSettings? warehouse,
    ReportingSettings? reporting,
    NotificationSettings? notifications,
    SecuritySettings? security,
    SystemSettings? system,
  }) {
    return StoreSettings(
      id: id,
      companyName: companyName ?? this.companyName,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      language: language ?? this.language,
      inventory: inventory ?? this.inventory,
      stockMovement: stockMovement ?? this.stockMovement,
      purchaseOrder: purchaseOrder ?? this.purchaseOrder,
      stockTake: stockTake ?? this.stockTake,
      warehouse: warehouse ?? this.warehouse,
      reporting: reporting ?? this.reporting,
      notifications: notifications ?? this.notifications,
      security: security ?? this.security,
      system: system ?? this.system,
      isActive: isActive,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class InventorySettings {
  final bool enableBatchTracking;
  final bool enableSerialNumberTracking;
  final bool enableExpiryManagement;
  final int lowStockThreshold;
  final int criticalStockThreshold;
  final bool autoReorder;
  final int reorderPoint;

  InventorySettings({
    required this.enableBatchTracking,
    required this.enableSerialNumberTracking,
    required this.enableExpiryManagement,
    required this.lowStockThreshold,
    required this.criticalStockThreshold,
    required this.autoReorder,
    required this.reorderPoint,
  });

  factory InventorySettings.fromJson(Map<String, dynamic> json) {
    return InventorySettings(
      enableBatchTracking: json['enableBatchTracking'] ?? false,
      enableSerialNumberTracking: json['enableSerialNumberTracking'] ?? false,
      enableExpiryManagement: json['enableExpiryManagement'] ?? false,
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      criticalStockThreshold: json['criticalStockThreshold'] ?? 5,
      autoReorder: json['autoReorder'] ?? false,
      reorderPoint: json['reorderPoint'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableBatchTracking': enableBatchTracking,
      'enableSerialNumberTracking': enableSerialNumberTracking,
      'enableExpiryManagement': enableExpiryManagement,
      'lowStockThreshold': lowStockThreshold,
      'criticalStockThreshold': criticalStockThreshold,
      'autoReorder': autoReorder,
      'reorderPoint': reorderPoint,
    };
  }

  InventorySettings copyWith({
    bool? enableBatchTracking,
    bool? enableSerialNumberTracking,
    bool? enableExpiryManagement,
    int? lowStockThreshold,
    int? criticalStockThreshold,
    bool? autoReorder,
    int? reorderPoint,
  }) {
    return InventorySettings(
      enableBatchTracking: enableBatchTracking ?? this.enableBatchTracking,
      enableSerialNumberTracking: enableSerialNumberTracking ?? this.enableSerialNumberTracking,
      enableExpiryManagement: enableExpiryManagement ?? this.enableExpiryManagement,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      criticalStockThreshold: criticalStockThreshold ?? this.criticalStockThreshold,
      autoReorder: autoReorder ?? this.autoReorder,
      reorderPoint: reorderPoint ?? this.reorderPoint,
    );
  }
}

class StockMovementSettings {
  final bool requireApproval;
  final bool enableAutoStockTransfer;
  final int approvalThreshold;

  StockMovementSettings({
    required this.requireApproval,
    required this.enableAutoStockTransfer,
    required this.approvalThreshold,
  });

  factory StockMovementSettings.fromJson(Map<String, dynamic> json) {
    return StockMovementSettings(
      requireApproval: json['requireApproval'] ?? false,
      enableAutoStockTransfer: json['enableAutoStockTransfer'] ?? false,
      approvalThreshold: json['approvalThreshold'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requireApproval': requireApproval,
      'enableAutoStockTransfer': enableAutoStockTransfer,
      'approvalThreshold': approvalThreshold,
    };
  }

  StockMovementSettings copyWith({
    bool? requireApproval,
    bool? enableAutoStockTransfer,
    int? approvalThreshold,
  }) {
    return StockMovementSettings(
      requireApproval: requireApproval ?? this.requireApproval,
      enableAutoStockTransfer: enableAutoStockTransfer ?? this.enableAutoStockTransfer,
      approvalThreshold: approvalThreshold ?? this.approvalThreshold,
    );
  }
}

class PurchaseOrderSettings {
  final bool autoGeneratePO;
  final bool requireManagerApproval;
  final double approvalLimit;
  final int defaultLeadTime;

  PurchaseOrderSettings({
    required this.autoGeneratePO,
    required this.requireManagerApproval,
    required this.approvalLimit,
    required this.defaultLeadTime,
  });

  factory PurchaseOrderSettings.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSettings(
      autoGeneratePO: json['autoGeneratePO'] ?? false,
      requireManagerApproval: json['requireManagerApproval'] ?? false,
      approvalLimit: (json['approvalLimit'] ?? 1000).toDouble(),
      defaultLeadTime: json['defaultLeadTime'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoGeneratePO': autoGeneratePO,
      'requireManagerApproval': requireManagerApproval,
      'approvalLimit': approvalLimit,
      'defaultLeadTime': defaultLeadTime,
    };
  }

  PurchaseOrderSettings copyWith({
    bool? autoGeneratePO,
    bool? requireManagerApproval,
    double? approvalLimit,
    int? defaultLeadTime,
  }) {
    return PurchaseOrderSettings(
      autoGeneratePO: autoGeneratePO ?? this.autoGeneratePO,
      requireManagerApproval: requireManagerApproval ?? this.requireManagerApproval,
      approvalLimit: approvalLimit ?? this.approvalLimit,
      defaultLeadTime: defaultLeadTime ?? this.defaultLeadTime,
    );
  }
}

class StockTakeSettings {
  final bool enableCycleCounting;
  final double maxVariancePercentage;
  final int stockTakeFrequency;

  StockTakeSettings({
    required this.enableCycleCounting,
    required this.maxVariancePercentage,
    required this.stockTakeFrequency,
  });

  factory StockTakeSettings.fromJson(Map<String, dynamic> json) {
    return StockTakeSettings(
      enableCycleCounting: json['enableCycleCounting'] ?? false,
      maxVariancePercentage: (json['maxVariancePercentage'] ?? 5.0).toDouble(),
      stockTakeFrequency: json['stockTakeFrequency'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableCycleCounting': enableCycleCounting,
      'maxVariancePercentage': maxVariancePercentage,
      'stockTakeFrequency': stockTakeFrequency,
    };
  }

  StockTakeSettings copyWith({
    bool? enableCycleCounting,
    double? maxVariancePercentage,
    int? stockTakeFrequency,
  }) {
    return StockTakeSettings(
      enableCycleCounting: enableCycleCounting ?? this.enableCycleCounting,
      maxVariancePercentage: maxVariancePercentage ?? this.maxVariancePercentage,
      stockTakeFrequency: stockTakeFrequency ?? this.stockTakeFrequency,
    );
  }
}

class WarehouseSettings {
  final bool enableZoneManagement;
  final bool enableBinLocations;
  final int maxUtilizationPercentage;
  final bool enableTemperatureControl;

  WarehouseSettings({
    required this.enableZoneManagement,
    required this.enableBinLocations,
    required this.maxUtilizationPercentage,
    required this.enableTemperatureControl,
  });

  factory WarehouseSettings.fromJson(Map<String, dynamic> json) {
    return WarehouseSettings(
      enableZoneManagement: json['enableZoneManagement'] ?? false,
      enableBinLocations: json['enableBinLocations'] ?? false,
      maxUtilizationPercentage: json['maxUtilizationPercentage'] ?? 85,
      enableTemperatureControl: json['enableTemperatureControl'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableZoneManagement': enableZoneManagement,
      'enableBinLocations': enableBinLocations,
      'maxUtilizationPercentage': maxUtilizationPercentage,
      'enableTemperatureControl': enableTemperatureControl,
    };
  }

  WarehouseSettings copyWith({
    bool? enableZoneManagement,
    bool? enableBinLocations,
    int? maxUtilizationPercentage,
    bool? enableTemperatureControl,
  }) {
    return WarehouseSettings(
      enableZoneManagement: enableZoneManagement ?? this.enableZoneManagement,
      enableBinLocations: enableBinLocations ?? this.enableBinLocations,
      maxUtilizationPercentage: maxUtilizationPercentage ?? this.maxUtilizationPercentage,
      enableTemperatureControl: enableTemperatureControl ?? this.enableTemperatureControl,
    );
  }
}

class ReportingSettings {
  final bool autoGenerateReports;
  final int reportRetentionDays;
  final List<String> reportRecipients;
  final String defaultReportFormat;

  ReportingSettings({
    required this.autoGenerateReports,
    required this.reportRetentionDays,
    required this.reportRecipients,
    required this.defaultReportFormat,
  });

  factory ReportingSettings.fromJson(Map<String, dynamic> json) {
    return ReportingSettings(
      autoGenerateReports: json['autoGenerateReports'] ?? false,
      reportRetentionDays: json['reportRetentionDays'] ?? 365,
      reportRecipients: List<String>.from(json['reportRecipients'] ?? []),
      defaultReportFormat: json['defaultReportFormat'] ?? 'PDF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoGenerateReports': autoGenerateReports,
      'reportRetentionDays': reportRetentionDays,
      'reportRecipients': reportRecipients,
      'defaultReportFormat': defaultReportFormat,
    };
  }

  ReportingSettings copyWith({
    bool? autoGenerateReports,
    int? reportRetentionDays,
    List<String>? reportRecipients,
    String? defaultReportFormat,
  }) {
    return ReportingSettings(
      autoGenerateReports: autoGenerateReports ?? this.autoGenerateReports,
      reportRetentionDays: reportRetentionDays ?? this.reportRetentionDays,
      reportRecipients: reportRecipients ?? this.reportRecipients,
      defaultReportFormat: defaultReportFormat ?? this.defaultReportFormat,
    );
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool lowStockAlerts;
  final bool expiryAlerts;
  final bool securityAlerts;

  NotificationSettings({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.lowStockAlerts,
    required this.expiryAlerts,
    required this.securityAlerts,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      lowStockAlerts: json['lowStockAlerts'] ?? true,
      expiryAlerts: json['expiryAlerts'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'lowStockAlerts': lowStockAlerts,
      'expiryAlerts': expiryAlerts,
      'securityAlerts': securityAlerts,
    };
  }

  NotificationSettings copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? lowStockAlerts,
    bool? expiryAlerts,
    bool? securityAlerts,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      expiryAlerts: expiryAlerts ?? this.expiryAlerts,
      securityAlerts: securityAlerts ?? this.securityAlerts,
    );
  }
}

class SecuritySettings {
  final bool twoFactorAuth;
  final int sessionTimeout;
  final bool passwordExpiry;
  final int passwordExpiryDays;
  final bool ipWhitelisting;

  SecuritySettings({
    required this.twoFactorAuth,
    required this.sessionTimeout,
    required this.passwordExpiry,
    required this.passwordExpiryDays,
    required this.ipWhitelisting,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      twoFactorAuth: json['twoFactorAuth'] ?? false,
      sessionTimeout: json['sessionTimeout'] ?? 30,
      passwordExpiry: json['passwordExpiry'] ?? false,
      passwordExpiryDays: json['passwordExpiryDays'] ?? 90,
      ipWhitelisting: json['ipWhitelisting'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'twoFactorAuth': twoFactorAuth,
      'sessionTimeout': sessionTimeout,
      'passwordExpiry': passwordExpiry,
      'passwordExpiryDays': passwordExpiryDays,
      'ipWhitelisting': ipWhitelisting,
    };
  }

  SecuritySettings copyWith({
    bool? twoFactorAuth,
    int? sessionTimeout,
    bool? passwordExpiry,
    int? passwordExpiryDays,
    bool? ipWhitelisting,
  }) {
    return SecuritySettings(
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      passwordExpiry: passwordExpiry ?? this.passwordExpiry,
      passwordExpiryDays: passwordExpiryDays ?? this.passwordExpiryDays,
      ipWhitelisting: ipWhitelisting ?? this.ipWhitelisting,
    );
  }
}

class SystemSettings {
  final bool enableAutoBackup;
  final bool enableAuditLog;
  final int backupFrequency;
  final String backupLocation;
  final bool maintenanceMode;

  SystemSettings({
    required this.enableAutoBackup,
    required this.enableAuditLog,
    required this.backupFrequency,
    required this.backupLocation,
    required this.maintenanceMode,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      enableAutoBackup: json['enableAutoBackup'] ?? false,
      enableAuditLog: json['enableAuditLog'] ?? true,
      backupFrequency: json['backupFrequency'] ?? 7,
      backupLocation: json['backupLocation'] ?? 'local',
      maintenanceMode: json['maintenanceMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableAutoBackup': enableAutoBackup,
      'enableAuditLog': enableAuditLog,
      'backupFrequency': backupFrequency,
      'backupLocation': backupLocation,
      'maintenanceMode': maintenanceMode,
    };
  }

  SystemSettings copyWith({
    bool? enableAutoBackup,
    bool? enableAuditLog,
    int? backupFrequency,
    String? backupLocation,
    bool? maintenanceMode,
  }) {
    return SystemSettings(
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      enableAuditLog: enableAuditLog ?? this.enableAuditLog,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupLocation: backupLocation ?? this.backupLocation,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }
}