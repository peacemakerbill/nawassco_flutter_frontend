import 'package:flutter/material.dart';

enum JournalStatus { draft, posted, approved, reversed, cancelled }

enum SourceDocument {
  manual,
  invoice,
  payment,
  receipt,
  purchase_order,
  sales_order,
  bank_reconciliation,
  adjustment
}

class JournalTransaction {
  final String id;
  final String accountId;
  final String accountCode;
  final String accountName;
  final String description;
  final double debit;
  final double credit;
  final String? costCenter;
  final String? projectCode;
  final double taxAmount;
  final double? taxRate;

  JournalTransaction({
    required this.id,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.description,
    required this.debit,
    required this.credit,
    this.costCenter,
    this.projectCode,
    this.taxAmount = 0,
    this.taxRate,
  });

  factory JournalTransaction.fromJson(Map<String, dynamic> json) {
    return JournalTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      accountId: json['account'] is String
          ? json['account'] as String
          : json['account']?['_id']?.toString() ?? '',
      accountCode:
      json['account'] is Map ? json['account']['accountCode']?.toString() ?? '' : '',
      accountName:
      json['account'] is Map ? json['account']['accountName']?.toString() ?? '' : '',
      description: json['description']?.toString() ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      costCenter: json['costCenter']?.toString(),
      projectCode: json['projectCode']?.toString(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxRate: json['taxRate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': accountId,
      'description': description,
      'debit': debit,
      'credit': credit,
      if (costCenter != null) 'costCenter': costCenter,
      if (projectCode != null) 'projectCode': projectCode,
      'taxAmount': taxAmount,
      if (taxRate != null) 'taxRate': taxRate,
    };
  }

  JournalTransaction copyWith({
    String? accountId,
    String? accountCode,
    String? accountName,
    String? description,
    double? debit,
    double? credit,
    String? costCenter,
    String? projectCode,
    double? taxAmount,
    double? taxRate,
  }) {
    return JournalTransaction(
      id: id,
      accountId: accountId ?? this.accountId,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      description: description ?? this.description,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      costCenter: costCenter ?? this.costCenter,
      projectCode: projectCode ?? this.projectCode,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

class JournalEntry {
  final String id;
  final String entryNumber;
  final DateTime entryDate;
  final String reference;
  final String description;
  final List<JournalTransaction> transactions;
  final double totalDebit;
  final double totalCredit;
  final String currency;
  final SourceDocument sourceDocument;
  final String? sourceId;
  final JournalStatus status;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvedDate;
  final String? reversalEntryId;
  final String accountingPeriod;
  final String fiscalYear;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.entryDate,
    required this.reference,
    required this.description,
    required this.transactions,
    required this.totalDebit,
    required this.totalCredit,
    this.currency = 'KES',
    required this.sourceDocument,
    this.sourceId,
    required this.status,
    this.approvedById,
    this.approvedByName,
    this.approvedDate,
    this.reversalEntryId,
    required this.accountingPeriod,
    required this.fiscalYear,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      entryNumber: json['entryNumber']?.toString() ?? '',
      entryDate: DateTime.parse(json['entryDate']),
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((t) => JournalTransaction.fromJson(t as Map<String, dynamic>))
          .toList() ??
          [],
      totalDebit: (json['totalDebit'] ?? 0).toDouble(),
      totalCredit: (json['totalCredit'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'KES',
      sourceDocument: SourceDocument.values.firstWhere(
            (e) => e.name == json['sourceDocument'],
        orElse: () => SourceDocument.manual,
      ),
      sourceId: json['sourceId']?.toString(),
      status: JournalStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => JournalStatus.draft,
      ),
      approvedById: json['approvedBy'] is String
          ? json['approvedBy'] as String
          : json['approvedBy']?['_id']?.toString(),
      approvedByName: json['approvedBy'] is Map
          ? '${json['approvedBy']['firstName'] ?? ''} ${json['approvedBy']['lastName'] ?? ''}'
          .trim()
          : null,
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'] as String)
          : null,
      reversalEntryId: json['reversalEntry']?.toString(),
      accountingPeriod: json['accountingPeriod']?.toString() ?? '',
      fiscalYear: json['fiscalYear']?.toString() ?? '',
      createdById: json['createdBy'] is String
          ? json['createdBy'] as String
          : json['createdBy']?['_id']?.toString() ?? '',
      createdByName: json['createdBy'] is Map
          ? '${json['createdBy']['firstName'] ?? ''} ${json['createdBy']['lastName'] ?? ''}'
          .trim()
          : '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entryDate': entryDate.toIso8601String(),
      'reference': reference,
      'description': description,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'sourceDocument': sourceDocument.name,
      if (sourceId != null) 'sourceId': sourceId,
      'accountingPeriod': accountingPeriod,
      'fiscalYear': fiscalYear,
    };
  }

  String get statusText {
    switch (status) {
      case JournalStatus.draft:
        return 'Draft';
      case JournalStatus.posted:
        return 'Posted';
      case JournalStatus.approved:
        return 'Approved';
      case JournalStatus.reversed:
        return 'Reversed';
      case JournalStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case JournalStatus.draft:
        return Colors.orange;
      case JournalStatus.posted:
        return Colors.blue;
      case JournalStatus.approved:
        return Colors.green;
      case JournalStatus.reversed:
        return Colors.red;
      case JournalStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case JournalStatus.draft:
        return Icons.edit;
      case JournalStatus.posted:
        return Icons.send;
      case JournalStatus.approved:
        return Icons.check_circle;
      case JournalStatus.reversed:
        return Icons.replay;
      case JournalStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool get canEdit => status == JournalStatus.draft;

  bool get canApprove => status == JournalStatus.draft;

  bool get canReverse => status == JournalStatus.approved;
}

class JournalEntriesResponse {
  final List<JournalEntry> journalEntries;
  final PaginationInfo pagination;

  JournalEntriesResponse({
    required this.journalEntries,
    required this.pagination,
  });

  factory JournalEntriesResponse.fromJson(Map<String, dynamic> json) {
    return JournalEntriesResponse(
      journalEntries: (json['journalEntries'] as List<dynamic>)
          .map((entry) => JournalEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class TrialBalance {
  final List<TrialBalanceItem> items;
  final double totalDebit;
  final double totalCredit;
  final double difference;
  final String startDate;
  final String endDate;

  TrialBalance({
    required this.items,
    required this.totalDebit,
    required this.totalCredit,
    required this.difference,
    required this.startDate,
    required this.endDate,
  });

  factory TrialBalance.fromJson(Map<String, dynamic> json) {
    final trialBalanceData = json['trialBalance'] as List<dynamic>;
    return TrialBalance(
      items: trialBalanceData
          .map((item) => TrialBalanceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalDebit: (json['totals']['totalDebit'] ?? 0).toDouble(),
      totalCredit: (json['totals']['totalCredit'] ?? 0).toDouble(),
      difference: (json['totals']['difference'] ?? 0).toDouble(),
      startDate: json['period']['startDate']?.toString() ?? '',
      endDate: json['period']['endDate']?.toString() ?? '',
    );
  }
}

class TrialBalanceItem {
  final String accountId;
  final String accountCode;
  final String accountName;
  final String accountType;
  final double debit;
  final double credit;
  final double balance;

  TrialBalanceItem({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory TrialBalanceItem.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>;
    return TrialBalanceItem(
      accountId: account['_id']?.toString() ?? '',
      accountCode: account['accountCode']?.toString() ?? '',
      accountName: account['accountName']?.toString() ?? '',
      accountType: account['accountType']?.toString() ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
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