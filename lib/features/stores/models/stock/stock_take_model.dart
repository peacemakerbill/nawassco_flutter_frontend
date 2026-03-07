import 'adjustment_model.dart';
import 'counted_item_model.dart';
import 'counting_team_model.dart';

class StockTake {
  final String id;
  final String stockTakeNumber;
  final String stockTakeType;
  final DateTime stockTakeDate;
  final String warehouse;
  final List<String> zones;
  final List<CountedItem> countedItems;
  final int totalItems;
  final int countedItemsCount;
  final int varianceItems;
  final double totalExpectedValue;
  final double totalCountedValue;
  final double totalVarianceValue;
  final double variancePercentage;
  final String status;
  final String countingStatus;
  final String approvalStatus;
  final List<CountingTeamMember> countingTeam;
  final String supervisor;
  final String? approvedBy;
  final List<Adjustment> adjustments;
  final bool adjustmentRequired;
  final List<String> documents;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockTake({
    required this.id,
    required this.stockTakeNumber,
    required this.stockTakeType,
    required this.stockTakeDate,
    required this.warehouse,
    required this.zones,
    required this.countedItems,
    required this.totalItems,
    required this.countedItemsCount,
    required this.varianceItems,
    required this.totalExpectedValue,
    required this.totalCountedValue,
    required this.totalVarianceValue,
    required this.variancePercentage,
    required this.status,
    required this.countingStatus,
    required this.approvalStatus,
    required this.countingTeam,
    required this.supervisor,
    this.approvedBy,
    required this.adjustments,
    required this.adjustmentRequired,
    required this.documents,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockTake.fromJson(Map<String, dynamic> json) {
    return StockTake(
      id: json['_id'] ?? '',
      stockTakeNumber: json['stockTakeNumber'] ?? '',
      stockTakeType: json['stockTakeType'] ?? 'cycle_count',
      stockTakeDate: DateTime.parse(json['stockTakeDate']),
      warehouse: json['warehouse'] ?? '',
      zones: json['zones'] != null ? List<String>.from(json['zones']) : [],
      countedItems: json['countedItems'] != null
          ? (json['countedItems'] as List).map((item) => CountedItem.fromJson(item)).toList()
          : [],
      totalItems: json['totalItems'] ?? 0,
      countedItemsCount: json['countedItemsCount'] ?? 0,
      varianceItems: json['varianceItems'] ?? 0,
      totalExpectedValue: (json['totalExpectedValue'] ?? 0).toDouble(),
      totalCountedValue: (json['totalCountedValue'] ?? 0).toDouble(),
      totalVarianceValue: (json['totalVarianceValue'] ?? 0).toDouble(),
      variancePercentage: (json['variancePercentage'] ?? 0).toDouble(),
      status: json['status'] ?? 'planned',
      countingStatus: json['countingStatus'] ?? 'not_started',
      approvalStatus: json['approvalStatus'] ?? 'pending',
      countingTeam: json['countingTeam'] != null
          ? (json['countingTeam'] as List).map((member) => CountingTeamMember.fromJson(member)).toList()
          : [],
      supervisor: json['supervisor'] is String ? json['supervisor'] : json['supervisor']?['_id'] ?? '',
      approvedBy: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'],
      adjustments: json['adjustments'] != null
          ? (json['adjustments'] as List).map((adj) => Adjustment.fromJson(adj)).toList()
          : [],
      adjustmentRequired: json['adjustmentRequired'] ?? false,
      documents: json['documents'] != null ? List<String>.from(json['documents']) : [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockTakeType': stockTakeType,
      'stockTakeDate': stockTakeDate.toIso8601String(),
      'warehouse': warehouse,
      'zones': zones,
      'countingTeam': countingTeam.map((member) => member.toJson()).toList(),
      'notes': notes,
    };
  }

  double get completionPercentage => totalItems > 0 ? (countedItemsCount / totalItems) * 100 : 0;
  bool get isCounted => countingStatus == 'completed';
  bool get canStart => status == 'planned' && countingStatus == 'not_started';
  bool get canCompleteCounting => countingStatus == 'in_progress' && countedItemsCount >= totalItems;
  bool get canApprove => status == 'counting_completed' || status == 'adjusted';
}