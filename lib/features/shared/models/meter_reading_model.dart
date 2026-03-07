import 'package:flutter/foundation.dart';

@immutable
class MeterReading {
  final String id;
  final String meterNumber;
  final double currentReading;
  final double? previousReading;
  final double consumption;
  final DateTime readingDate;
  final String readingMonth;
  final ReadingType readingType;
  final ReadingMethod readingMethod;
  final ReadingStatus readingStatus;
  final String? readerId;
  final String? readerName;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final bool isEstimated;
  final String? estimationReason;
  final bool readingVerified;
  final bool isDisputed;
  final String? disputeReason;
  final bool billGenerated;
  final String? billId;
  final String? billNumber;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeterReading({
    required this.id,
    required this.meterNumber,
    required this.currentReading,
    this.previousReading,
    required this.consumption,
    required this.readingDate,
    required this.readingMonth,
    required this.readingType,
    required this.readingMethod,
    required this.readingStatus,
    this.readerId,
    this.readerName,
    this.verifiedBy,
    this.verifiedAt,
    required this.isEstimated,
    this.estimationReason,
    required this.readingVerified,
    required this.isDisputed,
    this.disputeReason,
    required this.billGenerated,
    this.billId,
    this.billNumber,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
      id: json['_id'] ?? json['id'],
      meterNumber: json['meterNumber'],
      currentReading: (json['currentReading'] as num).toDouble(),
      previousReading: json['previousReading'] != null
          ? (json['previousReading'] as num).toDouble()
          : null,
      consumption: (json['consumption'] as num).toDouble(),
      readingDate: DateTime.parse(json['readingDate']),
      readingMonth: json['readingMonth'],
      readingType: ReadingType.values.firstWhere(
        (e) => e.name == json['readingType'].replaceAll('_', ''),
        orElse: () => ReadingType.manual,
      ),
      readingMethod: ReadingMethod.values.firstWhere(
        (e) => e.name == json['readingMethod'].replaceAll('_', ''),
        orElse: () => ReadingMethod.physical,
      ),
      readingStatus: ReadingStatus.values.firstWhere(
        (e) => e.name == json['readingStatus'],
        orElse: () => ReadingStatus.pending,
      ),
      readerId: json['readerId'],
      readerName: json['readerName'],
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      isEstimated: json['isEstimated'] ?? false,
      estimationReason: json['estimationReason'],
      readingVerified: json['readingVerified'] ?? false,
      isDisputed: json['isDisputed'] ?? false,
      disputeReason: json['disputeReason'],
      billGenerated: json['billGenerated'] ?? false,
      billId: json['billId'],
      billNumber: json['billNumber'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meterNumber': meterNumber,
      'currentReading': currentReading,
      'previousReading': previousReading,
      'readingDate': readingDate.toIso8601String(),
      'readingType': readingType.name,
      'readingMethod': readingMethod.name,
      'isEstimated': isEstimated,
      'estimationReason': estimationReason,
      'readerId': readerId,
      'readerName': readerName,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'currentReading': currentReading,
      'readingStatus': readingStatus.name,
      'readingVerified': readingVerified,
      'isDisputed': isDisputed,
      'disputeReason': disputeReason,
    };
  }

  MeterReading copyWith({
    String? id,
    String? meterNumber,
    double? currentReading,
    double? previousReading,
    double? consumption,
    DateTime? readingDate,
    String? readingMonth,
    ReadingType? readingType,
    ReadingMethod? readingMethod,
    ReadingStatus? readingStatus,
    String? readerId,
    String? readerName,
    String? verifiedBy,
    DateTime? verifiedAt,
    bool? isEstimated,
    String? estimationReason,
    bool? readingVerified,
    bool? isDisputed,
    String? disputeReason,
    bool? billGenerated,
    String? billId,
    String? billNumber,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeterReading(
      id: id ?? this.id,
      meterNumber: meterNumber ?? this.meterNumber,
      currentReading: currentReading ?? this.currentReading,
      previousReading: previousReading ?? this.previousReading,
      consumption: consumption ?? this.consumption,
      readingDate: readingDate ?? this.readingDate,
      readingMonth: readingMonth ?? this.readingMonth,
      readingType: readingType ?? this.readingType,
      readingMethod: readingMethod ?? this.readingMethod,
      readingStatus: readingStatus ?? this.readingStatus,
      readerId: readerId ?? this.readerId,
      readerName: readerName ?? this.readerName,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      isEstimated: isEstimated ?? this.isEstimated,
      estimationReason: estimationReason ?? this.estimationReason,
      readingVerified: readingVerified ?? this.readingVerified,
      isDisputed: isDisputed ?? this.isDisputed,
      disputeReason: disputeReason ?? this.disputeReason,
      billGenerated: billGenerated ?? this.billGenerated,
      billId: billId ?? this.billId,
      billNumber: billNumber ?? this.billNumber,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeterReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Getters for UI convenience
  bool get isPending => readingStatus == ReadingStatus.pending;

  bool get isVerified => readingStatus == ReadingStatus.verified;

  bool get isRejected => readingStatus == ReadingStatus.rejected;

  bool get isProcessed => readingStatus == ReadingStatus.processed;

  bool get canEdit => isPending || isRejected;

  bool get canVerify => isPending && !isEstimated;

  bool get canReject => isPending;

  bool get canProcess => isVerified && !billGenerated;

  bool get canGenerateBill => isVerified && consumption > 0 && !billGenerated;

  bool get hasBill => billGenerated && billId != null;
}

enum ReadingType {
  manual,
  smartMeter,
  estimated,
  customer,
}

enum ReadingMethod {
  physical,
  remote,
  customerSubmitted,
}

enum ReadingStatus {
  pending,
  verified,
  rejected,
  processed,
}
