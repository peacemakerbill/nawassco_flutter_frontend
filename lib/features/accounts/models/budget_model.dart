import 'package:flutter/material.dart';

enum PeriodType { annual, quarterly, monthly }

enum BudgetStatus { draft, under_review, approved, rejected, closed }

class BudgetItem {
  final String? id;
  final String account;
  final double budgetAmount;
  final double committedAmount;
  final double actualSpent;
  final double remainingBalance;
  final String? costCenter;
  final String? projectCode;
  final String? notes;

  // Populated fields from account reference
  final String? accountCode;
  final String? accountName;
  final String? accountType;
  final String? accountCategory;

  BudgetItem({
    this.id,
    required this.account,
    required this.budgetAmount,
    this.committedAmount = 0.0,
    this.actualSpent = 0.0,
    this.remainingBalance = 0.0,
    this.costCenter,
    this.projectCode,
    this.notes,
    this.accountCode,
    this.accountName,
    this.accountType,
    this.accountCategory,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    // Extract account details - handle both string ID and populated account object
    String? accountId;
    String? accountCode;
    String? accountName;
    String? accountType;
    String? accountCategory;

    if (json['account'] is String) {
      accountId = json['account'] as String;
    } else if (json['account'] is Map<String, dynamic>) {
      final accountData = json['account'] as Map<String, dynamic>;
      accountId = accountData['_id']?.toString();
      accountCode = accountData['accountCode']?.toString();
      accountName = accountData['accountName']?.toString();
      accountType = accountData['accountType']?.toString();
      accountCategory = accountData['accountCategory']?.toString();
    }

    return BudgetItem(
      id: json['_id']?.toString(),
      account: accountId ?? '',
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble() ?? 0.0,
      committedAmount: (json['committedAmount'] as num?)?.toDouble() ?? 0.0,
      actualSpent: (json['actualSpent'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      costCenter: json['costCenter']?.toString(),
      projectCode: json['projectCode']?.toString(),
      notes: json['notes']?.toString(),
      accountCode: accountCode,
      accountName: accountName,
      accountType: accountType,
      accountCategory: accountCategory,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'account': account,
      'budgetAmount': budgetAmount,
      'committedAmount': committedAmount,
      'actualSpent': actualSpent,
      'remainingBalance': remainingBalance,
    };

    if (id != null) {
      json['_id'] = id;
    }
    if (costCenter != null) {
      json['costCenter'] = costCenter;
    }
    if (projectCode != null) {
      json['projectCode'] = projectCode;
    }
    if (notes != null) {
      json['notes'] = notes;
    }

    return json;
  }

  BudgetItem copyWith({
    String? id,
    String? account,
    double? budgetAmount,
    double? committedAmount,
    double? actualSpent,
    double? remainingBalance,
    String? costCenter,
    String? projectCode,
    String? notes,
    String? accountCode,
    String? accountName,
    String? accountType,
    String? accountCategory,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      account: account ?? this.account,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      committedAmount: committedAmount ?? this.committedAmount,
      actualSpent: actualSpent ?? this.actualSpent,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      costCenter: costCenter ?? this.costCenter,
      projectCode: projectCode ?? this.projectCode,
      notes: notes ?? this.notes,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      accountCategory: accountCategory ?? this.accountCategory,
    );
  }
}

class Budget {
  final String? id;
  final String budgetNumber;
  final String budgetName;
  final String description;
  final String fiscalYear;
  final PeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double committedAmount;
  final double actualSpent;
  final double remainingBalance;
  final List<BudgetItem> items;
  final BudgetStatus status;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final String? approvedByName;
  final String? createdByName;

  Budget({
    this.id,
    required this.budgetNumber,
    required this.budgetName,
    required this.description,
    required this.fiscalYear,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    this.committedAmount = 0.0,
    this.actualSpent = 0.0,
    this.remainingBalance = 0.0,
    this.items = const [],
    this.status = BudgetStatus.draft,
    this.approvedBy,
    this.approvedDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.approvedByName,
    this.createdByName,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    // Extract approvedBy details
    String? approvedById;
    String? approvedByName;

    if (json['approvedBy'] is String) {
      approvedById = json['approvedBy'] as String;
    } else if (json['approvedBy'] is Map<String, dynamic>) {
      final approvedByData = json['approvedBy'] as Map<String, dynamic>;
      approvedById = approvedByData['_id']?.toString();
      approvedByName = '${approvedByData['firstName'] ?? ''} ${approvedByData['lastName'] ?? ''}'.trim();
    }

    // Extract createdBy details
    String? createdById;
    String? createdByName;

    if (json['createdBy'] is String) {
      createdById = json['createdBy'] as String;
    } else if (json['createdBy'] is Map<String, dynamic>) {
      final createdByData = json['createdBy'] as Map<String, dynamic>;
      createdById = createdByData['_id']?.toString();
      createdByName = '${createdByData['firstName'] ?? ''} ${createdByData['lastName'] ?? ''}'.trim();
    }

    // Parse period type
    PeriodType parsePeriodType(String? type) {
      if (type == null) return PeriodType.annual;
      switch (type.toLowerCase()) {
        case 'quarterly':
          return PeriodType.quarterly;
        case 'monthly':
          return PeriodType.monthly;
        default:
          return PeriodType.annual;
      }
    }

    // Parse budget status
    BudgetStatus parseBudgetStatus(String? status) {
      if (status == null) return BudgetStatus.draft;
      switch (status.toLowerCase()) {
        case 'under_review':
          return BudgetStatus.under_review;
        case 'approved':
          return BudgetStatus.approved;
        case 'rejected':
          return BudgetStatus.rejected;
        case 'closed':
          return BudgetStatus.closed;
        default:
          return BudgetStatus.draft;
      }
    }

    // Parse date safely
    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return Budget(
      id: json['_id']?.toString(),
      budgetNumber: json['budgetNumber']?.toString() ?? '',
      budgetName: json['budgetName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fiscalYear: json['fiscalYear']?.toString() ?? '',
      periodType: parsePeriodType(json['periodType']?.toString()),
      startDate: parseDate(json['startDate']?.toString()) ?? DateTime.now(),
      endDate: parseDate(json['endDate']?.toString()) ?? DateTime.now(),
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      committedAmount: (json['committedAmount'] as num?)?.toDouble() ?? 0.0,
      actualSpent: (json['actualSpent'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BudgetItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      status: parseBudgetStatus(json['status']?.toString()),
      approvedBy: approvedById,
      approvedDate: parseDate(json['approvedDate']?.toString()),
      createdBy: createdById ?? '',
      createdAt: parseDate(json['createdAt']?.toString()) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']?.toString()) ?? DateTime.now(),
      approvedByName: approvedByName,
      createdByName: createdByName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetName': budgetName,
      'description': description,
      'fiscalYear': fiscalYear,
      'periodType': periodType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  Budget copyWith({
    String? id,
    String? budgetNumber,
    String? budgetName,
    String? description,
    String? fiscalYear,
    PeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    double? totalBudget,
    double? committedAmount,
    double? actualSpent,
    double? remainingBalance,
    List<BudgetItem>? items,
    BudgetStatus? status,
    String? approvedBy,
    DateTime? approvedDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedByName,
    String? createdByName,
  }) {
    return Budget(
      id: id ?? this.id,
      budgetNumber: budgetNumber ?? this.budgetNumber,
      budgetName: budgetName ?? this.budgetName,
      description: description ?? this.description,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalBudget: totalBudget ?? this.totalBudget,
      committedAmount: committedAmount ?? this.committedAmount,
      actualSpent: actualSpent ?? this.actualSpent,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      items: items ?? this.items,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedByName: approvedByName ?? this.approvedByName,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  String get statusLabel {
    switch (status) {
      case BudgetStatus.draft:
        return 'Draft';
      case BudgetStatus.under_review:
        return 'Under Review';
      case BudgetStatus.approved:
        return 'Approved';
      case BudgetStatus.rejected:
        return 'Rejected';
      case BudgetStatus.closed:
        return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case BudgetStatus.draft:
        return Colors.blue;
      case BudgetStatus.under_review:
        return Colors.orange;
      case BudgetStatus.approved:
        return Colors.green;
      case BudgetStatus.rejected:
        return Colors.red;
      case BudgetStatus.closed:
        return Colors.grey;
    }
  }

  double get utilizationRate => totalBudget > 0 ? (actualSpent / totalBudget) * 100 : 0.0;
}

class BudgetPerformance {
  final String fiscalYear;
  final String periodType;
  final int totalBudgets;
  final double totalBudgetAmount;
  final double totalCommitted;
  final double totalSpent;
  final double totalRemaining;
  final double utilizationRate;
  final Map<String, dynamic> byAccountType;

  BudgetPerformance({
    required this.fiscalYear,
    required this.periodType,
    required this.totalBudgets,
    required this.totalBudgetAmount,
    required this.totalCommitted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.utilizationRate,
    required this.byAccountType,
  });

  factory BudgetPerformance.fromJson(Map<String, dynamic> json) {
    return BudgetPerformance(
      fiscalYear: json['fiscalYear']?.toString() ?? 'All',
      periodType: json['periodType']?.toString() ?? 'All',
      totalBudgets: (json['totalBudgets'] as num?)?.toInt() ?? 0,
      totalBudgetAmount: (json['totalBudgetAmount'] as num?)?.toDouble() ?? 0.0,
      totalCommitted: (json['totalCommitted'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalRemaining: (json['totalRemaining'] as num?)?.toDouble() ?? 0.0,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0.0,
      byAccountType: json['byAccountType'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['byAccountType'] as Map<String, dynamic>)
          : {},
    );
  }
}

class BudgetsResponse {
  final List<Budget> budgets;
  final PaginationInfo pagination;

  BudgetsResponse({
    required this.budgets,
    required this.pagination,
  });

  factory BudgetsResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    final data = json['result'] ?? json;

    List<Budget> budgetsList = [];
    if (data['budgets'] is List<dynamic>) {
      budgetsList = (data['budgets'] as List<dynamic>)
          .map((budget) => Budget.fromJson(budget as Map<String, dynamic>))
          .toList();
    }

    PaginationInfo paginationInfo;
    if (data['pagination'] is Map<String, dynamic>) {
      paginationInfo = PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>);
    } else {
      paginationInfo = PaginationInfo(
        page: 1,
        limit: 10,
        total: budgetsList.length,
        pages: 1,
      );
    }

    return BudgetsResponse(
      budgets: budgetsList,
      pagination: paginationInfo,
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }
}