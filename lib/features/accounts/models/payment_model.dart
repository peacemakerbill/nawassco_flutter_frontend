import 'package:flutter/material.dart';

enum PaymentType {
  supplier_payment,
  customer_refund,
  expense_reimbursement,
  salary_payment,
  tax_payment,
  loan_payment
}

enum PaymentMethod {
  cash,
  check,
  bank_transfer,
  mobile_money,
  credit_card
}

enum PayeeType {
  supplier,
  customer,
  employee,
  government,
  other
}

enum PaymentStatus {
  draft,
  pending_approval,
  approved,
  processed,
  cancelled,
  failed
}

class PaymentDocument {
  final String id;
  final String url;
  final String fileName;
  final String? originalName;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String uploadedById;
  final Map<String, dynamic>? uploadedBy;

  const PaymentDocument({
    required this.id,
    required this.url,
    required this.fileName,
    this.originalName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    required this.uploadedById,
    this.uploadedBy,
  });

  factory PaymentDocument.fromJson(Map<String, dynamic> json) {
    return PaymentDocument(
      id: json['_id'] ?? json['id'],
      url: json['url'],
      fileName: json['fileName'],
      originalName: json['originalName'],
      fileType: json['fileType'] ?? _getFileTypeFromUrl(json['url']),
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? json['createdAt']),
      uploadedById: json['uploadedBy'] is String
          ? json['uploadedBy']
          : json['uploadedBy']?['_id'] ?? '',
      uploadedBy: json['uploadedBy'] is Map
          ? Map<String, dynamic>.from(json['uploadedBy'])
          : null,
    );
  }

  static String _getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    } else if (['pdf'].contains(extension)) {
      return 'pdf';
    } else if (['doc', 'docx'].contains(extension)) {
      return 'word';
    } else if (['xls', 'xlsx'].contains(extension)) {
      return 'excel';
    } else if (['ppt', 'pptx'].contains(extension)) {
      return 'powerpoint';
    } else if (['txt'].contains(extension)) {
      return 'text';
    } else {
      return 'file';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'originalName': originalName,
      'fileType': fileType,
      'fileSize': fileSize,
    };
  }

  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';
  bool get isWord => fileType == 'word';
  bool get isExcel => fileType == 'excel';
  bool get isPowerPoint => fileType == 'powerpoint';
  bool get isText => fileType == 'text';

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1048576) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / 1048576).toStringAsFixed(1)} MB';
    }
  }

  IconData get fileIcon {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.table_chart;
      case 'powerpoint':
        return Icons.slideshow;
      case 'text':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get fileColor {
    switch (fileType) {
      case 'image':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'word':
        return Colors.blue;
      case 'excel':
        return Colors.green;
      case 'powerpoint':
        return Colors.orange;
      case 'text':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

class Payment {
  final String id;
  final String paymentNumber;
  final DateTime paymentDate;
  final PaymentType paymentType;
  final PaymentMethod paymentMethod;
  final PayeeType payeeType;
  final String? payeeName;
  final String? payeeEmail;
  final String? payeePhone;
  final String? payeeBankAccount;
  final String? payeeBankAccountName; // NEW FIELD
  final String? companyBankName;
  final String? companyBankAccount;
  final double amount;
  final String currency;
  final String? invoiceNumber;
  final String? purchaseOrderNumber;
  final String? contractNumber;
  final String? checkNumber;
  final String? transactionReference;
  final PaymentStatus status;
  final String? approvedById;
  final DateTime? approvedDate;
  final double taxAmount;
  final double withholdingTax;
  final double netAmount;
  final String? description;
  final String createdById;
  final String? updatedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final Map<String, dynamic>? createdBy;
  final Map<String, dynamic>? updatedBy;
  final Map<String, dynamic>? approvedBy;
  final List<PaymentDocument> documents;

  const Payment({
    required this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.paymentType,
    required this.paymentMethod,
    required this.payeeType,
    this.payeeName,
    this.payeeEmail,
    this.payeePhone,
    this.payeeBankAccount,
    this.payeeBankAccountName,
    this.companyBankName,
    this.companyBankAccount,
    required this.amount,
    this.currency = 'KES',
    this.invoiceNumber,
    this.purchaseOrderNumber,
    this.contractNumber,
    this.checkNumber,
    this.transactionReference,
    required this.status,
    this.approvedById,
    this.approvedDate,
    this.taxAmount = 0.0,
    this.withholdingTax = 0.0,
    required this.netAmount,
    this.description,
    required this.createdById,
    this.updatedById,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.approvedBy,
    this.documents = const [],
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final documentsJson = json['documents'] as List<dynamic>?;
    final documents = documentsJson?.map((doc) => PaymentDocument.fromJson(doc)).toList() ?? [];

    return Payment(
      id: json['_id'] ?? json['id'],
      paymentNumber: json['paymentNumber'],
      paymentDate: DateTime.parse(json['paymentDate'] ?? json['createdAt']),
      paymentType: PaymentType.values.firstWhere(
            (e) => e.name == json['paymentType'],
        orElse: () => PaymentType.supplier_payment,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.bank_transfer,
      ),
      payeeType: PayeeType.values.firstWhere(
            (e) => e.name == json['payeeType'],
        orElse: () => PayeeType.supplier,
      ),
      payeeName: json['payeeName'],
      payeeEmail: json['payeeEmail'],
      payeePhone: json['payeePhone'],
      payeeBankAccount: json['payeeBankAccount'],
      payeeBankAccountName: json['payeeBankAccountName'], // NEW FIELD
      companyBankName: json['companyBankName'],
      companyBankAccount: json['companyBankAccount'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'KES',
      invoiceNumber: json['invoiceNumber'],
      purchaseOrderNumber: json['purchaseOrderNumber'],
      contractNumber: json['contractNumber'],
      checkNumber: json['checkNumber'],
      transactionReference: json['transactionReference'],
      status: PaymentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => PaymentStatus.draft,
      ),
      approvedById: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'],
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate']) : null,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      withholdingTax: (json['withholdingTax'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? (json['amount'] as num).toDouble(),
      description: json['description'],
      createdById: json['createdBy'] is String ? json['createdBy'] : json['createdBy']?['_id'] ?? '',
      updatedById: json['updatedBy'] is String ? json['updatedBy'] : json['updatedBy']?['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'] is Map ? Map<String, dynamic>.from(json['createdBy']) : null,
      updatedBy: json['updatedBy'] is Map ? Map<String, dynamic>.from(json['updatedBy']) : null,
      approvedBy: json['approvedBy'] is Map ? Map<String, dynamic>.from(json['approvedBy']) : null,
      documents: documents,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'paymentDate': paymentDate.toIso8601String(),
      'paymentType': paymentType.name,
      'paymentMethod': paymentMethod.name,
      'payeeType': payeeType.name,
      'amount': amount,
      'currency': currency,
      'taxAmount': taxAmount,
      'withholdingTax': withholdingTax,
    };

    // Add optional fields only if they have values
    if (payeeName != null && payeeName!.isNotEmpty) json['payeeName'] = payeeName;
    if (payeeEmail != null && payeeEmail!.isNotEmpty) json['payeeEmail'] = payeeEmail;
    if (payeePhone != null && payeePhone!.isNotEmpty) json['payeePhone'] = payeePhone;
    if (payeeBankAccount != null && payeeBankAccount!.isNotEmpty) json['payeeBankAccount'] = payeeBankAccount;
    if (payeeBankAccountName != null && payeeBankAccountName!.isNotEmpty) json['payeeBankAccountName'] = payeeBankAccountName;
    if (companyBankName != null && companyBankName!.isNotEmpty) json['companyBankName'] = companyBankName;
    if (companyBankAccount != null && companyBankAccount!.isNotEmpty) json['companyBankAccount'] = companyBankAccount;
    if (invoiceNumber != null && invoiceNumber!.isNotEmpty) json['invoiceNumber'] = invoiceNumber;
    if (purchaseOrderNumber != null && purchaseOrderNumber!.isNotEmpty) json['purchaseOrderNumber'] = purchaseOrderNumber;
    if (contractNumber != null && contractNumber!.isNotEmpty) json['contractNumber'] = contractNumber;
    if (checkNumber != null && checkNumber!.isNotEmpty) json['checkNumber'] = checkNumber;
    if (transactionReference != null && transactionReference!.isNotEmpty) json['transactionReference'] = transactionReference;
    if (description != null && description!.isNotEmpty) json['description'] = description;

    return json;
  }

  Payment copyWith({
    String? id,
    String? paymentNumber,
    DateTime? paymentDate,
    PaymentType? paymentType,
    PaymentMethod? paymentMethod,
    PayeeType? payeeType,
    String? payeeName,
    String? payeeEmail,
    String? payeePhone,
    String? payeeBankAccount,
    String? payeeBankAccountName,
    String? companyBankName,
    String? companyBankAccount,
    double? amount,
    String? currency,
    String? invoiceNumber,
    String? purchaseOrderNumber,
    String? contractNumber,
    String? checkNumber,
    String? transactionReference,
    PaymentStatus? status,
    String? approvedById,
    DateTime? approvedDate,
    double? taxAmount,
    double? withholdingTax,
    double? netAmount,
    String? description,
    String? createdById,
    String? updatedById,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? createdBy,
    Map<String, dynamic>? updatedBy,
    Map<String, dynamic>? approvedBy,
    List<PaymentDocument>? documents,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentType: paymentType ?? this.paymentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payeeType: payeeType ?? this.payeeType,
      payeeName: payeeName ?? this.payeeName,
      payeeEmail: payeeEmail ?? this.payeeEmail,
      payeePhone: payeePhone ?? this.payeePhone,
      payeeBankAccount: payeeBankAccount ?? this.payeeBankAccount,
      payeeBankAccountName: payeeBankAccountName ?? this.payeeBankAccountName,
      companyBankName: companyBankName ?? this.companyBankName,
      companyBankAccount: companyBankAccount ?? this.companyBankAccount,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      contractNumber: contractNumber ?? this.contractNumber,
      checkNumber: checkNumber ?? this.checkNumber,
      transactionReference: transactionReference ?? this.transactionReference,
      status: status ?? this.status,
      approvedById: approvedById ?? this.approvedById,
      approvedDate: approvedDate ?? this.approvedDate,
      taxAmount: taxAmount ?? this.taxAmount,
      withholdingTax: withholdingTax ?? this.withholdingTax,
      netAmount: netAmount ?? this.netAmount,
      description: description ?? this.description,
      createdById: createdById ?? this.createdById,
      updatedById: updatedById ?? this.updatedById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      documents: documents ?? this.documents,
    );
  }

  String get statusDisplay {
    switch (status) {
      case PaymentStatus.draft:
        return 'Draft';
      case PaymentStatus.pending_approval:
        return 'Pending Approval';
      case PaymentStatus.approved:
        return 'Approved';
      case PaymentStatus.processed:
        return 'Processed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  Color get statusColor {
    switch (status) {
      case PaymentStatus.draft:
        return Colors.grey;
      case PaymentStatus.pending_approval:
        return Colors.orange;
      case PaymentStatus.approved:
        return Colors.blue;
      case PaymentStatus.processed:
        return Colors.green;
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case PaymentStatus.draft:
        return Icons.edit;
      case PaymentStatus.pending_approval:
        return Icons.pending;
      case PaymentStatus.approved:
        return Icons.verified;
      case PaymentStatus.processed:
        return Icons.check_circle;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.failed:
        return Icons.error;
    }
  }

  bool get canEdit => status == PaymentStatus.draft;
  bool get canApprove => status == PaymentStatus.draft || status == PaymentStatus.pending_approval;
  bool get canProcess => status == PaymentStatus.approved;
  bool get canCancel => status != PaymentStatus.processed && status != PaymentStatus.cancelled;

  String get formattedAmount => 'KES ${amount.toStringAsFixed(2)}';
  String get formattedNetAmount => 'KES ${netAmount.toStringAsFixed(2)}';
  String get formattedTaxAmount => 'KES ${taxAmount.toStringAsFixed(2)}';
  String get formattedWithholdingTax => 'KES ${withholdingTax.toStringAsFixed(2)}';
}

class PaymentsResponse {
  final List<Payment> payments;
  final PaginationInfo pagination;

  PaymentsResponse({
    required this.payments,
    required this.pagination,
  });

  factory PaymentsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentsResponse(
      payments: (json['payments'] as List<dynamic>)
          .map((payment) => Payment.fromJson(payment))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaymentSummary {
  final Map<String, dynamic> period;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> byPaymentType;
  final Map<String, dynamic> byPaymentMethod;
  final Map<String, dynamic> byPayeeType;

  PaymentSummary({
    required this.period,
    required this.totals,
    required this.byPaymentType,
    required this.byPaymentMethod,
    required this.byPayeeType,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      period: Map<String, dynamic>.from(json['period']),
      totals: Map<String, dynamic>.from(json['totals']),
      byPaymentType: Map<String, dynamic>.from(json['byPaymentType']),
      byPaymentMethod: Map<String, dynamic>.from(json['byPaymentMethod']),
      byPayeeType: Map<String, dynamic>.from(json['byPayeeType']),
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