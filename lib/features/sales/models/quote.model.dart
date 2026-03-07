import 'package:flutter/material.dart';

// ============================================
// ENUMS (Must match backend exactly)
// ============================================
enum QuoteStatus {
  draft,
  sent,
  accepted,
  rejected,
  expired,
  converted;

  String get displayName {
    return switch (this) {
      QuoteStatus.draft => 'Draft',
      QuoteStatus.sent => 'Sent',
      QuoteStatus.accepted => 'Accepted',
      QuoteStatus.rejected => 'Rejected',
      QuoteStatus.expired => 'Expired',
      QuoteStatus.converted => 'Converted',
    };
  }

  Color get color {
    return switch (this) {
      QuoteStatus.draft => const Color(0xFF6B7280),
      QuoteStatus.sent => const Color(0xFF3B82F6),
      QuoteStatus.accepted => const Color(0xFF10B981),
      QuoteStatus.rejected => const Color(0xFFEF4444),
      QuoteStatus.expired => const Color(0xFFF59E0B),
      QuoteStatus.converted => const Color(0xFF8B5CF6),
    };
  }

  IconData get icon {
    return switch (this) {
      QuoteStatus.draft => Icons.edit,
      QuoteStatus.sent => Icons.send,
      QuoteStatus.accepted => Icons.check_circle,
      QuoteStatus.rejected => Icons.cancel,
      QuoteStatus.expired => Icons.timer_off,
      QuoteStatus.converted => Icons.transform,
    };
  }

  static QuoteStatus fromString(String value) {
    return QuoteStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => QuoteStatus.draft,
    );
  }
}

enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    return switch (this) {
      ApprovalStatus.pending => 'Pending',
      ApprovalStatus.approved => 'Approved',
      ApprovalStatus.rejected => 'Rejected',
    };
  }

  Color get color {
    return switch (this) {
      ApprovalStatus.pending => const Color(0xFFF59E0B),
      ApprovalStatus.approved => const Color(0xFF10B981),
      ApprovalStatus.rejected => const Color(0xFFEF4444),
    };
  }

  IconData get icon {
    return switch (this) {
      ApprovalStatus.pending => Icons.pending,
      ApprovalStatus.approved => Icons.verified,
      ApprovalStatus.rejected => Icons.block,
    };
  }

  static ApprovalStatus fromString(String value) {
    return ApprovalStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ApprovalStatus.pending,
    );
  }
}

// ============================================
// SUB-MODELS
// ============================================
@immutable
class QuoteItem {
  final String? id;
  final String? itemCode;
  final String description;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final double discount;
  final double totalPrice;
  final double taxAmount;

  const QuoteItem({
    this.id,
    this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxRate,
    required this.discount,
    required this.totalPrice,
    required this.taxAmount,
  });

  factory QuoteItem.create({
    String? id,
    String? itemCode,
    required String description,
    required int quantity,
    required String unit,
    required double unitPrice,
    required double taxRate,
    required double discount,
  }) {
    final discountMultiplier = 1.0 - (discount / 100.0);
    final calculatedTotalPrice = quantity * unitPrice * discountMultiplier;
    final calculatedTaxAmount = calculatedTotalPrice * (taxRate / 100);

    return QuoteItem(
      id: id,
      itemCode: itemCode,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discount: discount,
      totalPrice: calculatedTotalPrice,
      taxAmount: calculatedTaxAmount,
    );
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    try {
      final discount = (json['discount'] as num?)?.toDouble() ?? 0.0;
      final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? 0.0;
      final quantity = (json['quantity'] as num?)?.toInt() ?? 1;
      final taxRate = (json['taxRate'] as num?)?.toDouble() ?? 0.0;

      final discountMultiplier = 1.0 - (discount / 100.0);
      final totalPrice = quantity * unitPrice * discountMultiplier;
      final taxAmount = totalPrice * (taxRate / 100);

      return QuoteItem(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        itemCode: json['itemCode'] as String? ?? '',
        description: json['description'] as String? ?? '',
        quantity: quantity,
        unit: json['unit'] as String? ?? 'pcs',
        unitPrice: unitPrice,
        taxRate: taxRate,
        discount: discount,
        totalPrice: totalPrice,
        taxAmount: taxAmount,
      );
    } catch (e) {
      print('Error parsing QuoteItem: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    if (itemCode != null && itemCode!.isNotEmpty) 'itemCode': itemCode,
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'unitPrice': unitPrice,
    'taxRate': taxRate,
    'discount': discount,
    'totalPrice': totalPrice,
    'taxAmount': taxAmount,
  };

  QuoteItem copyWith({
    String? id,
    String? itemCode,
    String? description,
    int? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? discount,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newDiscount = discount ?? this.discount;
    final newTaxRate = taxRate ?? this.taxRate;

    final discountMultiplier = 1.0 - (newDiscount / 100.0);
    final newTotalPrice = newQuantity * newUnitPrice * discountMultiplier;
    final newTaxAmount = newTotalPrice * (newTaxRate / 100);

    return QuoteItem(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      quantity: newQuantity,
      unit: unit ?? this.unit,
      unitPrice: newUnitPrice,
      taxRate: newTaxRate,
      discount: newDiscount,
      totalPrice: newTotalPrice,
      taxAmount: newTaxAmount,
    );
  }

  double get discountAmount => (quantity * unitPrice) * (discount / 100);
  double get netPrice => totalPrice;
  double get totalWithTax => totalPrice + taxAmount;
}

@immutable
class UserDetails {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? fullName;

  const UserDetails({
    this.firstName,
    this.lastName,
    this.email,
    this.fullName,
  });

  factory UserDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserDetails();

    return UserDetails(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (email != null) 'email': email,
    if (fullName != null) 'fullName': fullName,
  };

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email ?? 'Unknown User';
  }
}

// ============================================
// MAIN QUOTE MODEL
// ============================================
@immutable
class Quote {
  final String id;
  final String quoteNumber;
  final String? opportunityId;
  final Map<String, dynamic>? opportunity;
  final String? opportunityNumber;
  final String customerId;
  final Map<String, dynamic>? customer;
  final String? customerName;
  final String? customerEmail;
  final DateTime quoteDate;
  final DateTime expiryDate;
  final QuoteStatus status;
  final int revision;
  final List<QuoteItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String paymentTerms;
  final int validityPeriod;
  final String deliveryTerms;
  final List<String> specialConditions;
  final String? approvedById;
  final Map<String, dynamic>? approvedBy;
  final String? approvedByName;
  final String? approvedByEmail;
  final DateTime? approvalDate;
  final ApprovalStatus approvalStatus;
  final String? approvalComments;
  final String? convertedToProposal;
  final DateTime? conversionDate;
  final String createdById;
  final Map<String, dynamic>? createdBy;
  final UserDetails? createdByUser;
  final String? updatedById;
  final Map<String, dynamic>? updatedBy;
  final UserDetails? updatedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quote({
    required this.id,
    required this.quoteNumber,
    this.opportunityId,
    this.opportunity,
    this.opportunityNumber,
    required this.customerId,
    this.customer,
    this.customerName,
    this.customerEmail,
    required this.quoteDate,
    required this.expiryDate,
    required this.status,
    this.revision = 1,
    this.items = const [],
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.currency = 'KES',
    required this.paymentTerms,
    required this.validityPeriod,
    required this.deliveryTerms,
    this.specialConditions = const [],
    this.approvedById,
    this.approvedBy,
    this.approvedByName,
    this.approvedByEmail,
    this.approvalDate,
    this.approvalStatus = ApprovalStatus.pending,
    this.approvalComments,
    this.convertedToProposal,
    this.conversionDate,
    required this.createdById,
    this.createdBy,
    this.createdByUser,
    this.updatedById,
    this.updatedBy,
    this.updatedByUser,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => 'Quote $quoteNumber';

  // Enhanced customer name getter
  String get customerDisplayName {
    if (customerName != null && customerName!.isNotEmpty) return customerName!;
    if (customer != null) {
      if (customer!['customerName'] != null && customer!['customerName'].toString().isNotEmpty) {
        return customer!['customerName'].toString();
      }
      if (customer!['companyName'] != null && customer!['companyName'].toString().isNotEmpty) {
        return customer!['companyName'].toString();
      }
      if (customer!['name'] != null && customer!['name'].toString().isNotEmpty) {
        return customer!['name'].toString();
      }
      final firstName = customer!['firstName']?.toString() ?? '';
      final lastName = customer!['lastName']?.toString() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Customer $customerId';
  }

  String get opportunityDisplayName {
    if (opportunityNumber != null && opportunityNumber!.isNotEmpty) {
      return opportunityNumber!;
    }
    if (opportunity != null) {
      return opportunity!['opportunityNumber']?.toString() ??
          opportunity!['name']?.toString() ??
          'Opportunity';
    }
    return opportunityId ?? 'No Opportunity';
  }

  String get formattedTotal => 'KES ${totalAmount.toStringAsFixed(2)}';
  String get formattedSubtotal => 'KES ${subtotal.toStringAsFixed(2)}';
  String get formattedTax => 'KES ${taxAmount.toStringAsFixed(2)}';
  String get formattedDiscount => 'KES ${discountAmount.toStringAsFixed(2)}';

  String get createdByDisplayName {
    if (createdByUser != null) {
      return createdByUser!.displayName;
    }
    if (createdBy != null) {
      final firstName = createdBy!['firstName']?.toString() ?? '';
      final lastName = createdBy!['lastName']?.toString() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      return createdBy!['name']?.toString() ?? 'Unknown User';
    }
    return 'User $createdById';
  }

  String get approvedByDisplayName {
    if (approvedByName != null && approvedByName!.isNotEmpty) {
      return approvedByName!;
    }
    if (approvedBy != null) {
      final firstName = approvedBy!['firstName']?.toString() ?? '';
      final lastName = approvedBy!['lastName']?.toString() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      return approvedBy!['name']?.toString() ?? 'Unknown User';
    }
    return approvedById ?? 'Not approved';
  }

  String get updatedByDisplayName {
    if (updatedByUser != null) {
      return updatedByUser!.displayName;
    }
    if (updatedBy != null) {
      final firstName = updatedBy!['firstName']?.toString() ?? '';
      final lastName = updatedBy!['lastName']?.toString() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      return updatedBy!['name']?.toString() ?? 'Unknown User';
    }
    return updatedById ?? 'Unknown';
  }

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get canBeSent => status == QuoteStatus.draft;
  bool get canBeApproved =>
      status == QuoteStatus.sent && approvalStatus == ApprovalStatus.pending;
  bool get canBeConverted => status == QuoteStatus.accepted;

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  String get expiryStatus {
    if (isExpired) return 'Expired';
    if (daysUntilExpiry <= 7) return 'Expiring Soon';
    return 'Valid';
  }

  Color get expiryColor {
    if (isExpired) return Colors.red;
    if (daysUntilExpiry <= 7) return Colors.orange;
    return Colors.green;
  }

  // Create from backend JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates safely
      DateTime parseDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is DateTime) return date;
        if (date is String) return DateTime.parse(date);
        return DateTime.now();
      }

      // Parse items
      final itemsJson = json['items'] as List<dynamic>? ?? [];
      final items = itemsJson.map<QuoteItem>((item) {
        return QuoteItem.fromJson(item);
      }).toList();

      // Parse status enums
      final status = QuoteStatus.fromString(json['status'] as String? ?? 'draft');
      final approvalStatus = ApprovalStatus.fromString(json['approvalStatus'] as String? ?? 'pending');

      // Calculate totals if not provided
      double subtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
      double taxAmount = (json['taxAmount'] as num?)?.toDouble() ?? 0.0;
      double discountAmount = (json['discountAmount'] as num?)?.toDouble() ?? 0.0;
      double totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;

      // Calculate from items if needed
      if (discountAmount == 0 && items.isNotEmpty) {
        discountAmount = items.fold(0.0, (sum, item) => sum + item.discountAmount);
      }
      if (subtotal == 0 && items.isNotEmpty) {
        subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      }
      if (taxAmount == 0 && items.isNotEmpty) {
        taxAmount = items.fold(0.0, (sum, item) => sum + item.taxAmount);
      }
      if (totalAmount == 0 && items.isNotEmpty) {
        totalAmount = subtotal + taxAmount - discountAmount;
      }

      return Quote(
        id: json['_id']?.toString() ?? '',
        quoteNumber: json['quoteNumber'] as String? ?? '',
        opportunityId: json['opportunity'] is String
            ? json['opportunity']
            : json['opportunity']?['_id']?.toString(),
        opportunity: json['opportunity'] is Map<String, dynamic>
            ? json['opportunity']
            : null,
        opportunityNumber: json['opportunityNumber'] as String?,
        customerId: json['customer'] is String
            ? json['customer']
            : json['customer']?['_id']?.toString() ?? '',
        customer: json['customer'] is Map<String, dynamic>
            ? json['customer']
            : null,
        customerName: json['customerName'] as String?,
        customerEmail: json['customerEmail'] as String?,
        quoteDate: parseDate(json['quoteDate']),
        expiryDate: parseDate(json['expiryDate']),
        status: status,
        revision: (json['revision'] as num?)?.toInt() ?? 1,
        items: items,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        currency: json['currency'] as String? ?? 'KES',
        paymentTerms: json['paymentTerms'] as String? ?? '',
        validityPeriod: (json['validityPeriod'] as num?)?.toInt() ?? 30,
        deliveryTerms: json['deliveryTerms'] as String? ?? '',
        specialConditions: List<String>.from(json['specialConditions'] ?? []),
        approvedById: json['approvedBy'] is String
            ? json['approvedBy']
            : json['approvedBy']?['_id']?.toString(),
        approvedBy: json['approvedBy'] is Map<String, dynamic>
            ? json['approvedBy']
            : null,
        approvedByName: json['approvedByName'] as String?,
        approvedByEmail: json['approvedByEmail'] as String?,
        approvalDate: json['approvalDate'] != null
            ? parseDate(json['approvalDate'])
            : null,
        approvalStatus: approvalStatus,
        approvalComments: json['approvalComments'] as String?,
        convertedToProposal: json['convertedToProposal'] as String?,
        conversionDate: json['conversionDate'] != null
            ? parseDate(json['conversionDate'])
            : null,
        createdById: json['createdBy'] is String
            ? json['createdBy']
            : json['createdBy']?['_id']?.toString() ?? '',
        createdBy: json['createdBy'] is Map<String, dynamic>
            ? json['createdBy']
            : null,
        createdByUser: json['createdByUser'] != null
            ? UserDetails.fromJson(json['createdByUser'] as Map<String, dynamic>)
            : null,
        updatedById: json['updatedBy'] is String
            ? json['updatedBy']
            : json['updatedBy']?['_id']?.toString(),
        updatedBy: json['updatedBy'] is Map<String, dynamic>
            ? json['updatedBy']
            : null,
        updatedByUser: json['updatedByUser'] != null
            ? UserDetails.fromJson(json['updatedByUser'] as Map<String, dynamic>)
            : null,
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt']),
      );
    } catch (e, stack) {
      print('Error parsing Quote: $e');
      print('Stack: $stack');
      print('JSON: $json');
      rethrow;
    }
  }

  // Convert to backend JSON
  Map<String, dynamic> toJson() => {
    'quoteNumber': quoteNumber,
    if (opportunityId != null && opportunityId!.isNotEmpty) 'opportunity': opportunityId,
    if (opportunityNumber != null) 'opportunityNumber': opportunityNumber,
    'customer': customerId,
    if (customerName != null) 'customerName': customerName,
    if (customerEmail != null) 'customerEmail': customerEmail,
    'quoteDate': quoteDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'status': status.name,
    'revision': revision,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
    'totalAmount': totalAmount,
    'currency': currency,
    'paymentTerms': paymentTerms,
    'validityPeriod': validityPeriod,
    'deliveryTerms': deliveryTerms,
    'specialConditions': specialConditions,
    if (approvedById != null) 'approvedBy': approvedById,
    if (approvedByName != null) 'approvedByName': approvedByName,
    if (approvedByEmail != null) 'approvedByEmail': approvedByEmail,
    if (approvalDate != null) 'approvalDate': approvalDate!.toIso8601String(),
    'approvalStatus': approvalStatus.name,
    if (approvalComments != null) 'approvalComments': approvalComments,
    if (convertedToProposal != null) 'convertedToProposal': convertedToProposal,
    if (conversionDate != null) 'conversionDate': conversionDate!.toIso8601String(),
  };

  Quote copyWith({
    String? id,
    String? quoteNumber,
    String? opportunityId,
    Map<String, dynamic>? opportunity,
    String? opportunityNumber,
    String? customerId,
    Map<String, dynamic>? customer,
    String? customerName,
    String? customerEmail,
    DateTime? quoteDate,
    DateTime? expiryDate,
    QuoteStatus? status,
    int? revision,
    List<QuoteItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    String? paymentTerms,
    int? validityPeriod,
    String? deliveryTerms,
    List<String>? specialConditions,
    String? approvedById,
    Map<String, dynamic>? approvedBy,
    String? approvedByName,
    String? approvedByEmail,
    DateTime? approvalDate,
    ApprovalStatus? approvalStatus,
    String? approvalComments,
    String? convertedToProposal,
    DateTime? conversionDate,
    String? createdById,
    Map<String, dynamic>? createdBy,
    UserDetails? createdByUser,
    String? updatedById,
    Map<String, dynamic>? updatedBy,
    UserDetails? updatedByUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quote(
      id: id ?? this.id,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      opportunityId: opportunityId ?? this.opportunityId,
      opportunity: opportunity ?? this.opportunity,
      opportunityNumber: opportunityNumber ?? this.opportunityNumber,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      quoteDate: quoteDate ?? this.quoteDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      validityPeriod: validityPeriod ?? this.validityPeriod,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      specialConditions: specialConditions ?? this.specialConditions,
      approvedById: approvedById ?? this.approvedById,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedByEmail: approvedByEmail ?? this.approvedByEmail,
      approvalDate: approvalDate ?? this.approvalDate,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvalComments: approvalComments ?? this.approvalComments,
      convertedToProposal: convertedToProposal ?? this.convertedToProposal,
      conversionDate: conversionDate ?? this.conversionDate,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdByUser: createdByUser ?? this.createdByUser,
      updatedById: updatedById ?? this.updatedById,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByUser: updatedByUser ?? this.updatedByUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Quote &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              quoteNumber == other.quoteNumber;

  @override
  int get hashCode => id.hashCode ^ quoteNumber.hashCode;
}

// ============================================
// FILTERS AND STATS
// ============================================
class QuoteFilters {
  final QuoteStatus? status;
  final ApprovalStatus? approvalStatus;
  final String? customer;
  final String? customerName;
  final String? customerEmail;
  final String? opportunity;
  final String? opportunityNumber;
  final String? createdBy;
  final String? createdByUserEmail;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;

  const QuoteFilters({
    this.status,
    this.approvalStatus,
    this.customer,
    this.customerName,
    this.customerEmail,
    this.opportunity,
    this.opportunityNumber,
    this.createdBy,
    this.createdByUserEmail,
    this.search,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status!.name;
    if (approvalStatus != null) params['approvalStatus'] = approvalStatus!.name;
    if (customer != null) params['customer'] = customer!;
    if (customerName != null) params['customerName'] = customerName!;
    if (customerEmail != null) params['customerEmail'] = customerEmail!;
    if (opportunity != null) params['opportunity'] = opportunity!;
    if (opportunityNumber != null) params['opportunityNumber'] = opportunityNumber!;
    if (createdBy != null) params['createdBy'] = createdBy!;
    if (createdByUserEmail != null) params['createdByUserEmail'] = createdByUserEmail!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    return params;
  }

  QuoteFilters copyWith({
    QuoteStatus? status,
    ApprovalStatus? approvalStatus,
    String? customer,
    String? customerName,
    String? customerEmail,
    String? opportunity,
    String? opportunityNumber,
    String? createdBy,
    String? createdByUserEmail,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return QuoteFilters(
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      customer: customer ?? this.customer,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      opportunity: opportunity ?? this.opportunity,
      opportunityNumber: opportunityNumber ?? this.opportunityNumber,
      createdBy: createdBy ?? this.createdBy,
      createdByUserEmail: createdByUserEmail ?? this.createdByUserEmail,
      search: search ?? this.search,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get hasFilters =>
      status != null ||
          approvalStatus != null ||
          customer != null ||
          customerName != null ||
          customerEmail != null ||
          opportunity != null ||
          opportunityNumber != null ||
          createdBy != null ||
          createdByUserEmail != null ||
          (search != null && search!.isNotEmpty) ||
          startDate != null ||
          endDate != null;
}

class QuoteStats {
  final int total;
  final Map<QuoteStatus, int> byStatus;
  final Map<ApprovalStatus, int> byApprovalStatus;
  final double totalAmount;
  final double averageAmount;
  final int recentCount;

  const QuoteStats({
    required this.total,
    required this.byStatus,
    required this.byApprovalStatus,
    required this.totalAmount,
    required this.averageAmount,
    required this.recentCount,
  });

  factory QuoteStats.fromJson(Map<String, dynamic> json) {
    // Parse byStatus
    final byStatus = <QuoteStatus, int>{};
    final byStatusList = json['byStatus'] as Map<String, dynamic>? ?? {};

    byStatusList.forEach((key, value) {
      if (value is int) {
        final status = QuoteStatus.fromString(key);
        byStatus[status] = value;
      }
    });

    // Parse byApprovalStatus
    final byApprovalStatus = <ApprovalStatus, int>{};
    final byApprovalList = json['byApprovalStatus'] as Map<String, dynamic>? ?? {};

    byApprovalList.forEach((key, value) {
      if (value is int) {
        final status = ApprovalStatus.fromString(key);
        byApprovalStatus[status] = value;
      }
    });

    return QuoteStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byStatus: byStatus,
      byApprovalStatus: byApprovalStatus,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      averageAmount: (json['averageAmount'] as num?)?.toDouble() ?? 0.0,
      recentCount: (json['recentCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get totalAmountFormatted => 'KES ${totalAmount.toStringAsFixed(2)}';
  String get averageAmountFormatted => 'KES ${averageAmount.toStringAsFixed(2)}';
}