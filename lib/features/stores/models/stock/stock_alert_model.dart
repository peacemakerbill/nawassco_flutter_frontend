import 'package:flutter/material.dart';

class StockAlert {
  final String id;
  final String alertType;
  final String priority;
  final String title;
  final String description;
  final String itemId;
  final String warehouseId;
  final double currentValue;
  final double thresholdValue;
  final DateTime alertDate;
  final bool acknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final bool resolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockAlert({
    required this.id,
    required this.alertType,
    required this.priority,
    required this.title,
    required this.description,
    required this.itemId,
    required this.warehouseId,
    required this.currentValue,
    required this.thresholdValue,
    required this.alertDate,
    required this.acknowledged,
    this.acknowledgedBy,
    this.acknowledgedAt,
    required this.resolved,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['_id'] ?? '',
      alertType: json['alertType'] ?? 'low_stock',
      priority: json['priority'] ?? 'medium',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      itemId: json['item'] is String ? json['item'] : json['item']?['_id'] ?? '',
      warehouseId: json['warehouse'] is String ? json['warehouse'] : json['warehouse']?['_id'] ?? '',
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      thresholdValue: (json['thresholdValue'] ?? 0).toDouble(),
      alertDate: DateTime.parse(json['alertDate']),
      acknowledged: json['acknowledged'] ?? false,
      acknowledgedBy: json['acknowledgedBy'] is String ? json['acknowledgedBy'] : json['acknowledgedBy']?['_id'],
      acknowledgedAt: json['acknowledgedAt'] != null ? DateTime.parse(json['acknowledgedAt']) : null,
      resolved: json['resolved'] ?? false,
      resolvedBy: json['resolvedBy'] is String ? json['resolvedBy'] : json['resolvedBy']?['_id'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolutionNotes: json['resolutionNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acknowledged': acknowledged,
      'resolved': resolved,
      'resolutionNotes': resolutionNotes,
    };
  }

  bool get isCritical => priority == 'critical';
  bool get isHighPriority => priority == 'high' || priority == 'critical';
  Color get priorityColor {
    switch (priority) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.yellow;
      case 'low': return Colors.blue;
      default: return Colors.grey;
    }
  }
}