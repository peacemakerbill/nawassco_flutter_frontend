import 'package:flutter/material.dart';
import '../../utils/date_utils.dart' as date_util;

enum ActionItemStatus {
  pending('Pending', Colors.grey),
  inProgress('In Progress', Colors.orange),
  completed('Completed', Colors.green),
  cancelled('Cancelled', Colors.red);

  final String displayName;
  final Color color;

  const ActionItemStatus(this.displayName, this.color);
}

enum PriorityLevel {
  low('Low', Colors.green),
  medium('Medium', Colors.orange),
  high('High', Colors.red),
  critical('Critical', Colors.purple);

  final String displayName;
  final Color color;

  const PriorityLevel(this.displayName, this.color);
}

class ReportActionItem {
  final String id;
  final String item;
  final String ownerId;
  final String ownerName;
  final String? ownerTitle;
  final DateTime dueDate;
  final ActionItemStatus status;
  final PriorityLevel priority;

  ReportActionItem({
    required this.id,
    required this.item,
    required this.ownerId,
    required this.ownerName,
    this.ownerTitle,
    required this.dueDate,
    required this.status,
    required this.priority,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != ActionItemStatus.completed;
  bool get isDueSoon => dueDate.difference(DateTime.now()).inDays <= 3 && status != ActionItemStatus.completed;

  String get formattedDueDate => date_util.DateUtils.formatDate(dueDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerTitle': ownerTitle,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
    };
  }

  factory ReportActionItem.fromJson(Map<String, dynamic> json) {
    return ReportActionItem(
      id: json['_id'] ?? json['id'] ?? '',
      item: json['item'] ?? '',
      ownerId: json['owner']?['_id'] ?? json['ownerId'] ?? '',
      ownerName: json['owner']?['firstName'] != null
          ? '${json['owner']['firstName']} ${json['owner']['lastName']}'
          : json['ownerName'] ?? '',
      ownerTitle: json['owner']?['jobInformation']?['jobTitle'] ??
          json['ownerTitle'],
      dueDate: DateTime.parse(json['dueDate']),
      status: ActionItemStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ActionItemStatus.pending,
      ),
      priority: PriorityLevel.values.firstWhere(
            (e) => e.name == json['priority'],
        orElse: () => PriorityLevel.medium,
      ),
    );
  }
}