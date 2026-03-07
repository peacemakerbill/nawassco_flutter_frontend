import 'dart:convert';

enum AccountType { asset, liability, equity, revenue, expense }

enum AccountCategory {
  current_assets,
  fixed_assets,
  current_liabilities,
  long_term_liabilities,
  operating_revenue,
  non_operating_revenue,
  operating_expenses,
  administrative_expenses,
  finance_costs
}

enum NormalBalance { debit, credit }

class ChartOfAccount {
  final String id;
  final String accountCode;
  final String accountName;
  final AccountType accountType;
  final AccountCategory accountCategory;
  final String description;
  final String? parentAccountId;
  final ChartOfAccount? parentAccount;
  final int level;
  final NormalBalance normalBalance;
  final bool isSystemAccount;
  final bool isActive;
  final bool budgetAllowed;
  final bool requiresApproval;
  final double? approvalLimit;
  final bool taxApplicable;
  final double? taxRate;
  final bool isBankAccount;
  final String? bankAccountNumber;
  final String? bankName;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChartOfAccount({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.accountCategory,
    required this.description,
    this.parentAccountId,
    this.parentAccount,
    required this.level,
    required this.normalBalance,
    required this.isSystemAccount,
    required this.isActive,
    required this.budgetAllowed,
    required this.requiresApproval,
    this.approvalLimit,
    required this.taxApplicable,
    this.taxRate,
    required this.isBankAccount,
    this.bankAccountNumber,
    this.bankName,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChartOfAccount.fromJson(Map<String, dynamic> json) {
    // Helper function to get createdBy ID
    String getCreatedById() {
      if (json['createdBy'] is String) {
        return json['createdBy'] as String;
      } else if (json['createdBy'] is Map<String, dynamic>) {
        return (json['createdBy'] as Map<String, dynamic>)['_id']?.toString() ?? '';
      }
      return '';
    }

    // Helper to safely parse doubles
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return ChartOfAccount(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      accountCode: json['accountCode']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      accountType: AccountType.values.firstWhere(
            (e) => e.name == (json['accountType']?.toString() ?? 'asset'),
        orElse: () => AccountType.asset,
      ),
      accountCategory: AccountCategory.values.firstWhere(
            (e) => e.name == (json['accountCategory']?.toString() ?? 'current_assets'),
        orElse: () => AccountCategory.current_assets,
      ),
      description: json['description']?.toString() ?? '',
      parentAccountId: json['parentAccount']?.toString(),
      parentAccount: json['parentAccount'] is Map<String, dynamic>
          ? ChartOfAccount.fromJson(json['parentAccount'] as Map<String, dynamic>)
          : null,
      level: (json['level'] is int ? json['level'] as int : 1),
      normalBalance: NormalBalance.values.firstWhere(
            (e) => e.name == (json['normalBalance']?.toString() ?? 'debit'),
        orElse: () => NormalBalance.debit,
      ),
      isSystemAccount: json['isSystemAccount'] == true,
      isActive: json['isActive'] != false,
      budgetAllowed: json['budgetAllowed'] != false,
      requiresApproval: json['requiresApproval'] == true,
      approvalLimit: parseDouble(json['approvalLimit']),
      taxApplicable: json['taxApplicable'] == true,
      taxRate: parseDouble(json['taxRate']),
      isBankAccount: json['isBankAccount'] == true,
      bankAccountNumber: json['bankAccountNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      createdById: getCreatedById(),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'accountCode': accountCode,
      'accountName': accountName,
      'accountType': accountType.name,
      'accountCategory': accountCategory.name,
      'description': description,
      'normalBalance': normalBalance.name,
      'isSystemAccount': isSystemAccount,
      'isActive': isActive,
      'budgetAllowed': budgetAllowed,
      'requiresApproval': requiresApproval,
      'taxApplicable': taxApplicable,
      'isBankAccount': isBankAccount,
    };

    // Add optional fields only if they have values
    if (parentAccountId != null && parentAccountId!.isNotEmpty) {
      json['parentAccount'] = parentAccountId;
    }
    if (approvalLimit != null) {
      json['approvalLimit'] = approvalLimit;
    }
    if (taxRate != null) {
      json['taxRate'] = taxRate;
    }
    if (bankAccountNumber != null && bankAccountNumber!.isNotEmpty) {
      json['bankAccountNumber'] = bankAccountNumber;
    }
    if (bankName != null && bankName!.isNotEmpty) {
      json['bankName'] = bankName;
    }

    return json;
  }

  ChartOfAccount copyWith({
    String? id,
    String? accountCode,
    String? accountName,
    AccountType? accountType,
    AccountCategory? accountCategory,
    String? description,
    String? parentAccountId,
    ChartOfAccount? parentAccount,
    int? level,
    NormalBalance? normalBalance,
    bool? isSystemAccount,
    bool? isActive,
    bool? budgetAllowed,
    bool? requiresApproval,
    double? approvalLimit,
    bool? taxApplicable,
    double? taxRate,
    bool? isBankAccount,
    String? bankAccountNumber,
    String? bankName,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChartOfAccount(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      accountCategory: accountCategory ?? this.accountCategory,
      description: description ?? this.description,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      parentAccount: parentAccount ?? this.parentAccount,
      level: level ?? this.level,
      normalBalance: normalBalance ?? this.normalBalance,
      isSystemAccount: isSystemAccount ?? this.isSystemAccount,
      isActive: isActive ?? this.isActive,
      budgetAllowed: budgetAllowed ?? this.budgetAllowed,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      approvalLimit: approvalLimit ?? this.approvalLimit,
      taxApplicable: taxApplicable ?? this.taxApplicable,
      taxRate: taxRate ?? this.taxRate,
      isBankAccount: isBankAccount ?? this.isBankAccount,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccountHierarchy {
  final String id;
  final String accountCode;
  final String accountName;
  final AccountType accountType;
  final String? parentAccountId;
  final int level;
  final List<AccountHierarchy> children;

  AccountHierarchy({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    this.parentAccountId,
    required this.level,
    required this.children,
  });

  factory AccountHierarchy.fromJson(Map<String, dynamic> json) {
    return AccountHierarchy(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      accountCode: json['accountCode']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      accountType: AccountType.values.firstWhere(
            (e) => e.name == (json['accountType']?.toString() ?? 'asset'),
        orElse: () => AccountType.asset,
      ),
      parentAccountId: json['parentAccount']?.toString(),
      level: (json['level'] is int ? json['level'] as int : 1),
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => AccountHierarchy.fromJson(child as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class AccountsResponse {
  final List<ChartOfAccount> accounts;
  final PaginationInfo pagination;

  AccountsResponse({
    required this.accounts,
    required this.pagination,
  });

  factory AccountsResponse.fromJson(Map<String, dynamic> json) {
    final accountsData = json['accounts'] as List<dynamic>?;
    final paginationData = json['pagination'] as Map<String, dynamic>?;

    return AccountsResponse(
      accounts: accountsData != null
          ? accountsData
          .map((account) => ChartOfAccount.fromJson(account as Map<String, dynamic>))
          .toList()
          : [],
      pagination: paginationData != null
          ? PaginationInfo.fromJson(paginationData)
          : PaginationInfo(page: 1, limit: 10, total: 0, pages: 1),
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
      page: (json['page'] is int ? json['page'] as int : 1),
      limit: (json['limit'] is int ? json['limit'] as int : 10),
      total: (json['total'] is int ? json['total'] as int : 0),
      pages: (json['pages'] is int ? json['pages'] as int : 1),
    );
  }
}