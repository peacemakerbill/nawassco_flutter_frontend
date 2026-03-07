import 'movement_item_model.dart';
import 'movement_location_model.dart';

class StockMovement {
  final String id;
  final String movementNumber;
  final String movementType;
  final DateTime movementDate;
  final String referenceNumber;
  final String referenceType;
  final List<MovementItem> items;
  final double totalQuantity;
  final double totalValue;
  final MovementLocation fromLocation;
  final MovementLocation toLocation;
  final String initiatedBy;
  final String? approvedBy;
  final String? receivedBy;
  final String status;
  final String approvalStatus;
  final String? notes;
  final List<String> documents;
  final bool systemGenerated;
  final String? batchNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockMovement({
    required this.id,
    required this.movementNumber,
    required this.movementType,
    required this.movementDate,
    required this.referenceNumber,
    required this.referenceType,
    required this.items,
    required this.totalQuantity,
    required this.totalValue,
    required this.fromLocation,
    required this.toLocation,
    required this.initiatedBy,
    this.approvedBy,
    this.receivedBy,
    required this.status,
    required this.approvalStatus,
    this.notes,
    required this.documents,
    required this.systemGenerated,
    this.batchNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['_id'] ?? '',
      movementNumber: json['movementNumber'] ?? '',
      movementType: json['movementType'] ?? '',
      movementDate: DateTime.parse(json['movementDate']),
      referenceNumber: json['referenceNumber'] ?? '',
      referenceType: json['referenceType'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List).map((item) => MovementItem.fromJson(item)).toList()
          : [],
      totalQuantity: (json['totalQuantity'] ?? 0).toDouble(),
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      fromLocation: MovementLocation.fromJson(json['fromLocation'] ?? {}),
      toLocation: MovementLocation.fromJson(json['toLocation'] ?? {}),
      initiatedBy: json['initiatedBy'] is String ? json['initiatedBy'] : json['initiatedBy']?['_id'] ?? '',
      approvedBy: json['approvedBy'] is String ? json['approvedBy'] : json['approvedBy']?['_id'],
      receivedBy: json['receivedBy'] is String ? json['receivedBy'] : json['receivedBy']?['_id'],
      status: json['status'] ?? 'draft',
      approvalStatus: json['approvalStatus'] ?? 'not_required',
      notes: json['notes'],
      documents: json['documents'] != null ? List<String>.from(json['documents']) : [],
      systemGenerated: json['systemGenerated'] ?? false,
      batchNumber: json['batchNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movementType': movementType,
      'movementDate': movementDate.toIso8601String(),
      'referenceNumber': referenceNumber,
      'referenceType': referenceType,
      'items': items.map((item) => item.toJson()).toList(),
      'fromLocation': fromLocation.toJson(),
      'toLocation': toLocation.toJson(),
      'notes': notes,
      'status': status,
    };
  }

  bool get canEdit => status == 'draft' || status == 'pending';
  bool get canApprove => status == 'pending' && approvalStatus == 'pending';
  bool get canComplete => status == 'in_progress' && approvalStatus == 'approved';
}