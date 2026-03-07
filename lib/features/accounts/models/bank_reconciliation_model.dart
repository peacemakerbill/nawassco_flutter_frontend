import 'package:flutter/material.dart';

enum ReconciliationStatus { draft, in_progress, completed, adjusted }

enum TransactionType { deposit, withdrawal, bank_charge, interest }

enum OutstandingItemType {
  outstanding_deposit,
  outstanding_check,
  bank_error,
  book_error
}

class ClearedTransaction {
  final String? id;
  final DateTime transactionDate;
  final String description;
  final double amount;
  final TransactionType transactionType;
  final String reference;

  ClearedTransaction({
    this.id,
    required this.transactionDate,
    required this.description,
    required this.amount,
    required this.transactionType,
    required this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'transactionType': transactionType.name,
      'reference': reference,
    };
  }

  factory ClearedTransaction.fromJson(Map<String, dynamic> json) {
    return ClearedTransaction(
      id: json['_id']?.toString(),
      transactionDate: DateTime.parse(json['transactionDate']),
      description: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      transactionType: TransactionType.values.firstWhere(
            (e) => e.name == json['transactionType'],
        orElse: () => TransactionType.deposit,
      ),
      reference: json['reference'] ?? '',
    );
  }

  ClearedTransaction copyWith({
    String? id,
    DateTime? transactionDate,
    String? description,
    double? amount,
    TransactionType? transactionType,
    String? reference,
  }) {
    return ClearedTransaction(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      reference: reference ?? this.reference,
    );
  }

  static List<String>? validate(ClearedTransaction transaction) {
    final errors = <String>[];

    if (transaction.description.isEmpty) {
      errors.add('Description is required');
    } else if (transaction.description.length > 200) {
      errors.add('Description must be 200 characters or less');
    }

    if (transaction.amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (transaction.reference.isEmpty) {
      errors.add('Reference is required');
    } else if (transaction.reference.length > 50) {
      errors.add('Reference must be 50 characters or less');
    }

    return errors.isNotEmpty ? errors : null;
  }
}

class OutstandingItem {
  final String? id;
  final DateTime itemDate;
  final String description;
  final double amount;
  final OutstandingItemType itemType;
  final String reference;
  final bool cleared;
  final DateTime? clearedDate;

  OutstandingItem({
    this.id,
    required this.itemDate,
    required this.description,
    required this.amount,
    required this.itemType,
    required this.reference,
    this.cleared = false,
    this.clearedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'itemDate': itemDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'itemType': itemType.name,
      'reference': reference,
      'cleared': cleared,
      if (clearedDate != null) 'clearedDate': clearedDate!.toIso8601String(),
    };
  }

  factory OutstandingItem.fromJson(Map<String, dynamic> json) {
    return OutstandingItem(
      id: json['_id']?.toString(),
      itemDate: DateTime.parse(json['itemDate']),
      description: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      itemType: OutstandingItemType.values.firstWhere(
            (e) => e.name == json['itemType'],
        orElse: () => OutstandingItemType.outstanding_check,
      ),
      reference: json['reference'] ?? '',
      cleared: json['cleared'] ?? false,
      clearedDate: json['clearedDate'] != null
          ? DateTime.parse(json['clearedDate'])
          : null,
    );
  }

  OutstandingItem copyWith({
    String? id,
    DateTime? itemDate,
    String? description,
    double? amount,
    OutstandingItemType? itemType,
    String? reference,
    bool? cleared,
    DateTime? clearedDate,
  }) {
    return OutstandingItem(
      id: id ?? this.id,
      itemDate: itemDate ?? this.itemDate,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      itemType: itemType ?? this.itemType,
      reference: reference ?? this.reference,
      cleared: cleared ?? this.cleared,
      clearedDate: clearedDate ?? this.clearedDate,
    );
  }

  static List<String>? validate(OutstandingItem item) {
    final errors = <String>[];

    if (item.description.isEmpty) {
      errors.add('Description is required');
    } else if (item.description.length > 200) {
      errors.add('Description must be 200 characters or less');
    }

    if (item.amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (item.reference.isEmpty) {
      errors.add('Reference is required');
    } else if (item.reference.length > 50) {
      errors.add('Reference must be 50 characters or less');
    }

    return errors.isNotEmpty ? errors : null;
  }
}

class BankReconciliation {
  final String? id;
  final String reconciliationNumber;
  final String bankAccountId;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankName;
  final DateTime statementDate;
  final double statementBalance;
  final List<ClearedTransaction> clearedTransactions;
  final List<OutstandingItem> outstandingItems;
  final double bookBalance;
  final double adjustedBalance;
  final double difference;
  final ReconciliationStatus status;
  final String reconciledById;
  final String? reconciledByName;
  final DateTime reconciledAt;
  final DateTime nextReconciliationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankReconciliation({
    this.id,
    required this.reconciliationNumber,
    required this.bankAccountId,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    required this.statementDate,
    required this.statementBalance,
    required this.clearedTransactions,
    required this.outstandingItems,
    required this.bookBalance,
    required this.adjustedBalance,
    required this.difference,
    required this.status,
    required this.reconciledById,
    this.reconciledByName,
    required this.reconciledAt,
    required this.nextReconciliationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'reconciliationNumber': reconciliationNumber,
      'bankAccount': bankAccountId,
      'statementDate': statementDate.toIso8601String(),
      'statementBalance': statementBalance,
      'clearedTransactions':
      clearedTransactions.map((e) => e.toJson()).toList(),
      'outstandingItems': outstandingItems.map((e) => e.toJson()).toList(),
      'bookBalance': bookBalance,
      'adjustedBalance': adjustedBalance,
      'difference': difference,
      'status': status.name,
      'reconciledBy': reconciledById,
      'reconciledAt': reconciledAt.toIso8601String(),
      'nextReconciliationDate': nextReconciliationDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BankReconciliation.fromJson(Map<String, dynamic> json) {
    // Handle bank account data (could be String ID or populated object)
    dynamic bankAccount = json['bankAccount'];
    String bankAccountId = '';
    String? bankAccountName;
    String? bankAccountNumber;
    String? bankName;

    if (bankAccount is String) {
      bankAccountId = bankAccount;
    } else if (bankAccount is Map<String, dynamic>) {
      bankAccountId = bankAccount['_id']?.toString() ?? '';
      bankAccountName = bankAccount['accountName']?.toString();
      bankAccountNumber = bankAccount['bankAccountNumber']?.toString();
      bankName = bankAccount['bankName']?.toString();
    }

    // Handle reconciledBy data
    dynamic reconciledBy = json['reconciledBy'];
    String reconciledById = '';
    String? reconciledByName;

    if (reconciledBy is String) {
      reconciledById = reconciledBy;
    } else if (reconciledBy is Map<String, dynamic>) {
      reconciledById = reconciledBy['_id']?.toString() ?? '';
      final firstName = reconciledBy['firstName']?.toString() ?? '';
      final lastName = reconciledBy['lastName']?.toString() ?? '';
      reconciledByName = '$firstName $lastName'.trim();
    }

    return BankReconciliation(
      id: json['_id']?.toString(),
      reconciliationNumber: json['reconciliationNumber'] ?? '',
      bankAccountId: bankAccountId,
      bankAccountName: bankAccountName,
      bankAccountNumber: bankAccountNumber,
      bankName: bankName,
      statementDate: DateTime.parse(json['statementDate']),
      statementBalance: (json['statementBalance'] as num).toDouble(),
      clearedTransactions: (json['clearedTransactions'] as List<dynamic>?)
          ?.map((e) => ClearedTransaction.fromJson(e))
          .toList() ??
          [],
      outstandingItems: (json['outstandingItems'] as List<dynamic>?)
          ?.map((e) => OutstandingItem.fromJson(e))
          .toList() ??
          [],
      bookBalance: (json['bookBalance'] as num).toDouble(),
      adjustedBalance: (json['adjustedBalance'] as num).toDouble(),
      difference: (json['difference'] as num).toDouble(),
      status: ReconciliationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ReconciliationStatus.draft,
      ),
      reconciledById: reconciledById,
      reconciledByName: reconciledByName,
      reconciledAt: DateTime.parse(json['reconciledAt']),
      nextReconciliationDate: DateTime.parse(json['nextReconciliationDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  BankReconciliation copyWith({
    String? id,
    String? reconciliationNumber,
    String? bankAccountId,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
    DateTime? statementDate,
    double? statementBalance,
    List<ClearedTransaction>? clearedTransactions,
    List<OutstandingItem>? outstandingItems,
    double? bookBalance,
    double? adjustedBalance,
    double? difference,
    ReconciliationStatus? status,
    String? reconciledById,
    String? reconciledByName,
    DateTime? reconciledAt,
    DateTime? nextReconciliationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankReconciliation(
      id: id ?? this.id,
      reconciliationNumber: reconciliationNumber ?? this.reconciliationNumber,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      statementDate: statementDate ?? this.statementDate,
      statementBalance: statementBalance ?? this.statementBalance,
      clearedTransactions: clearedTransactions ?? this.clearedTransactions,
      outstandingItems: outstandingItems ?? this.outstandingItems,
      bookBalance: bookBalance ?? this.bookBalance,
      adjustedBalance: adjustedBalance ?? this.adjustedBalance,
      difference: difference ?? this.difference,
      status: status ?? this.status,
      reconciledById: reconciledById ?? this.reconciledById,
      reconciledByName: reconciledByName ?? this.reconciledByName,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      nextReconciliationDate:
      nextReconciliationDate ?? this.nextReconciliationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusDisplayText {
    switch (status) {
      case ReconciliationStatus.draft:
        return 'Draft';
      case ReconciliationStatus.in_progress:
        return 'In Progress';
      case ReconciliationStatus.completed:
        return 'Completed';
      case ReconciliationStatus.adjusted:
        return 'Adjusted';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReconciliationStatus.draft:
        return Colors.grey;
      case ReconciliationStatus.in_progress:
        return Colors.orange;
      case ReconciliationStatus.completed:
        return Colors.green;
      case ReconciliationStatus.adjusted:
        return Colors.blue;
    }
  }

  bool get canEdit =>
      status == ReconciliationStatus.draft ||
          status == ReconciliationStatus.in_progress;

  bool get canComplete =>
      status != ReconciliationStatus.completed && difference.abs() <= 0.01;

  double get totalOutstandingDeposits => outstandingItems
      .where((item) =>
  item.itemType == OutstandingItemType.outstanding_deposit &&
      !item.cleared)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalOutstandingChecks => outstandingItems
      .where((item) =>
  item.itemType == OutstandingItemType.outstanding_check && !item.cleared)
      .fold(0.0, (sum, item) => sum + item.amount);

  String get displayName =>
      bankAccountName ??
          bankAccountNumber ??
          bankName ??
          'Bank Account $bankAccountId';
}

class CreateReconciliationData {
  final String bankAccount;
  final DateTime statementDate;
  final double statementBalance;
  final double bookBalance;
  final List<ClearedTransaction> clearedTransactions;
  final List<OutstandingItem> outstandingItems;
  final DateTime nextReconciliationDate;

  CreateReconciliationData({
    required this.bankAccount,
    required this.statementDate,
    required this.statementBalance,
    required this.bookBalance,
    this.clearedTransactions = const [],
    this.outstandingItems = const [],
    required this.nextReconciliationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'bankAccount': bankAccount,
      'statementDate': statementDate.toIso8601String(),
      'statementBalance': statementBalance,
      'bookBalance': bookBalance,
      'clearedTransactions':
      clearedTransactions.map((e) => e.toJson()).toList(),
      'outstandingItems': outstandingItems.map((e) => e.toJson()).toList(),
      'nextReconciliationDate': nextReconciliationDate.toIso8601String(),
    };
  }

  static Map<String, List<String>> validate(CreateReconciliationData data) {
    final errors = <String, List<String>>{};

    if (data.bankAccount.isEmpty) {
      errors['bankAccount'] = ['Bank account is required'];
    }

    if (data.statementBalance <= 0) {
      errors['statementBalance'] = ['Statement balance must be greater than 0'];
    }

    if (data.bookBalance <= 0) {
      errors['bookBalance'] = ['Book balance must be greater than 0'];
    }

    if (data.nextReconciliationDate.isBefore(data.statementDate)) {
      errors['nextReconciliationDate'] = [
        'Next reconciliation date must be after statement date'
      ];
    }

    for (int i = 0; i < data.clearedTransactions.length; i++) {
      final transactionErrors =
      ClearedTransaction.validate(data.clearedTransactions[i]);
      if (transactionErrors != null) {
        errors['clearedTransactions.$i'] = transactionErrors;
      }
    }

    for (int i = 0; i < data.outstandingItems.length; i++) {
      final itemErrors = OutstandingItem.validate(data.outstandingItems[i]);
      if (itemErrors != null) {
        errors['outstandingItems.$i'] = itemErrors;
      }
    }

    return errors;
  }
}

class OutstandingItemData {
  final DateTime itemDate;
  final String description;
  final double amount;
  final OutstandingItemType itemType;
  final String reference;

  OutstandingItemData({
    required this.itemDate,
    required this.description,
    required this.amount,
    required this.itemType,
    required this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemDate': itemDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'itemType': itemType.name,
      'reference': reference,
    };
  }

  static Map<String, List<String>> validate(OutstandingItemData data) {
    final errors = <String, List<String>>{};

    if (data.description.isEmpty) {
      errors['description'] = ['Description is required'];
    } else if (data.description.length > 200) {
      errors['description'] = ['Description must be 200 characters or less'];
    }

    if (data.amount <= 0) {
      errors['amount'] = ['Amount must be greater than 0'];
    }

    if (data.reference.isEmpty) {
      errors['reference'] = ['Reference is required'];
    } else if (data.reference.length > 50) {
      errors['reference'] = ['Reference must be 50 characters or less'];
    }

    return errors;
  }
}

class ReconciliationFilters {
  final int page;
  final int limit;
  final String? bankAccount;
  final String? status;
  final String? startDate;
  final String? endDate;

  ReconciliationFilters({
    this.page = 1,
    this.limit = 10,
    this.bankAccount,
    this.status,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      if (bankAccount != null && bankAccount!.isNotEmpty) 'bankAccount': bankAccount,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (startDate != null && startDate!.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate!.isNotEmpty) 'endDate': endDate,
    };
  }

  ReconciliationFilters copyWith({
    int? page,
    int? limit,
    String? bankAccount,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    return ReconciliationFilters(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      bankAccount: bankAccount ?? this.bankAccount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ReconciliationResponse {
  final List<BankReconciliation> reconciliations;
  final PaginationInfo pagination;

  ReconciliationResponse({
    required this.reconciliations,
    required this.pagination,
  });

  factory ReconciliationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['result'] ?? json;
    return ReconciliationResponse(
      reconciliations: (data['reconciliations'] as List<dynamic>)
          .map((rec) => BankReconciliation.fromJson(rec))
          .toList(),
      pagination: PaginationInfo.fromJson(data['pagination']),
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
      page: (json['page'] as int?) ?? 1,
      limit: (json['limit'] as int?) ?? 10,
      total: (json['total'] as int?) ?? 0,
      pages: (json['pages'] as int?) ?? 1,
    );
  }
}