import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class Consultancy {
  final String id;
  final String consultancyNumber;
  final String title;
  final String description;
  final ConsultancyCategory category;
  final Scope scope;
  final Timeline timeline;
  final Budget budget;
  final Client client;
  final List<TeamMember> team;
  final ConsultancyStatus status;
  final List<Milestone> milestones;
  final List<Risk> risks;
  final List<Deliverable> deliverables;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const Consultancy({
    required this.id,
    required this.consultancyNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.scope,
    required this.timeline,
    required this.budget,
    required this.client,
    required this.team,
    required this.status,
    required this.milestones,
    required this.risks,
    required this.deliverables,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory Consultancy.fromJson(Map<String, dynamic> json) {
    return Consultancy(
      id: json['_id'] ?? json['id'] ?? '',
      consultancyNumber: json['consultancyNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: ConsultancyCategory.values.firstWhere(
            (e) => e.name == json['category']?.replaceAll('_', ' ').toUpperCase(),
        orElse: () => ConsultancyCategory.TECHNICAL,
      ),
      scope: Scope.fromJson(json['scope'] ?? {}),
      timeline: Timeline.fromJson(json['timeline'] ?? {}),
      budget: Budget.fromJson(json['budget'] ?? {}),
      client: Client.fromJson(json['client'] ?? {}),
      team: (json['team'] as List? ?? []).map((e) => TeamMember.fromJson(e)).toList(),
      status: ConsultancyStatus.values.firstWhere(
            (e) => e.name == json['status']?.toUpperCase(),
        orElse: () => ConsultancyStatus.PROPOSAL,
      ),
      milestones: (json['milestones'] as List? ?? []).map((e) => Milestone.fromJson(e)).toList(),
      risks: (json['risks'] as List? ?? []).map((e) => Risk.fromJson(e)).toList(),
      deliverables: (json['deliverables'] as List? ?? []).map((e) => Deliverable.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy']?['firstName'] ?? 'Unknown',
      updatedBy: json['updatedBy']?['firstName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': describeEnum(category).toLowerCase(),
      'scope': scope.toJson(),
      'timeline': timeline.toJson(),
      'budget': budget.toJson(),
      'client': client.toJson(),
      'status': describeEnum(status).toLowerCase(),
    };
  }

  Consultancy copyWith({
    String? id,
    String? consultancyNumber,
    String? title,
    String? description,
    ConsultancyCategory? category,
    Scope? scope,
    Timeline? timeline,
    Budget? budget,
    Client? client,
    List<TeamMember>? team,
    ConsultancyStatus? status,
    List<Milestone>? milestones,
    List<Risk>? risks,
    List<Deliverable>? deliverables,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Consultancy(
      id: id ?? this.id,
      consultancyNumber: consultancyNumber ?? this.consultancyNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scope: scope ?? this.scope,
      timeline: timeline ?? this.timeline,
      budget: budget ?? this.budget,
      client: client ?? this.client,
      team: team ?? this.team,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      risks: risks ?? this.risks,
      deliverables: deliverables ?? this.deliverables,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);
  String get formattedStartDate => DateFormat('dd MMM yyyy').format(timeline.startDate);
  String get formattedEndDate => DateFormat('dd MMM yyyy').format(timeline.endDate);
  double get progressPercentage {
    final totalDays = timeline.endDate.difference(timeline.startDate).inDays;
    final daysPassed = DateTime.now().difference(timeline.startDate).inDays;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }
}

@immutable
class Scope {
  final List<String> objectives;
  final List<String> deliverables;
  final String methodology;
  final List<String> limitations;
  final List<String> assumptions;

  const Scope({
    required this.objectives,
    required this.deliverables,
    required this.methodology,
    required this.limitations,
    required this.assumptions,
  });

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      objectives: List<String>.from(json['objectives'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
      methodology: json['methodology'] ?? '',
      limitations: List<String>.from(json['limitations'] ?? []),
      assumptions: List<String>.from(json['assumptions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectives': objectives,
      'deliverables': deliverables,
      'methodology': methodology,
      'limitations': limitations,
      'assumptions': assumptions,
    };
  }
}

@immutable
class Timeline {
  final DateTime startDate;
  final DateTime endDate;
  final int duration;

  const Timeline({
    required this.startDate,
    required this.endDate,
    required this.duration,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration,
    };
  }
}

@immutable
class Budget {
  final double totalAmount;
  final String currency;
  final List<BudgetItem> breakdown;
  final List<PaymentSchedule> paymentSchedule;
  final List<Expense> expenses;

  const Budget({
    required this.totalAmount,
    this.currency = 'KES',
    required this.breakdown,
    required this.paymentSchedule,
    required this.expenses,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      breakdown: (json['breakdown'] as List? ?? []).map((e) => BudgetItem.fromJson(e)).toList(),
      paymentSchedule: (json['paymentSchedule'] as List? ?? []).map((e) => PaymentSchedule.fromJson(e)).toList(),
      expenses: (json['expenses'] as List? ?? []).map((e) => Expense.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'currency': currency,
      'breakdown': breakdown.map((e) => e.toJson()).toList(),
      'paymentSchedule': paymentSchedule.map((e) => e.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }
}

extension on Expense {
  toJson() {}
}

@immutable
class Client {
  final String name;
  final ClientType type;
  final ContactPerson contactPerson;
  final String address;
  final String email;
  final String phone;

  const Client({
    required this.name,
    required this.type,
    required this.contactPerson,
    required this.address,
    required this.email,
    required this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] ?? '',
      type: ClientType.values.firstWhere(
            (e) => e.name == json['type']?.toUpperCase(),
        orElse: () => ClientType.PRIVATE,
      ),
      contactPerson: ContactPerson.fromJson(json['contactPerson'] ?? {}),
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': describeEnum(type).toLowerCase(),
      'contactPerson': contactPerson.toJson(),
      'address': address,
      'email': email,
      'phone': phone,
    };
  }
}

@immutable
class ContactPerson {
  final String name;
  final String position;
  final String email;
  final String phone;

  const ContactPerson({
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'email': email,
      'phone': phone,
    };
  }
}

@immutable
class TeamMember {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final TeamRole role;
  final double hoursAllocated;
  final double rate;
  final List<String> responsibilities;

  const TeamMember({
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    required this.role,
    required this.hoursAllocated,
    required this.rate,
    required this.responsibilities,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] ?? {};
    return TeamMember(
      userId: json['User'] ?? json['userId'] ?? '',
      firstName: employee['firstName'] ?? json['firstName'],
      lastName: employee['lastName'] ?? json['lastName'],
      email: employee['email'] ?? json['email'],
      role: TeamRole.values.firstWhere(
            (e) => e.name == json['role']?.toUpperCase().replaceAll(' ', '_'),
        orElse: () => TeamRole.CONSULTANT,
      ),
      hoursAllocated: (json['hoursAllocated'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'User': userId,
      'role': describeEnum(role).toLowerCase(),
      'hoursAllocated': hoursAllocated,
      'rate': rate,
      'responsibilities': responsibilities,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
  double get totalCost => hoursAllocated * rate;
}

@immutable
class Milestone {
  final String name;
  final String description;
  final DateTime dueDate;
  final MilestoneStatus status;
  final DateTime? completionDate;
  final List<String> deliverables;

  const Milestone({
    required this.name,
    required this.description,
    required this.dueDate,
    required this.status,
    this.completionDate,
    required this.deliverables,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      status: MilestoneStatus.values.firstWhere(
            (e) => e.name == json['status']?.toUpperCase().replaceAll(' ', '_'),
        orElse: () => MilestoneStatus.NOT_STARTED,
      ),
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      deliverables: List<String>.from(json['deliverables'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': describeEnum(status).toLowerCase(),
      'completionDate': completionDate?.toIso8601String(),
      'deliverables': deliverables,
    };
  }

  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);
  bool get isOverdue => status != MilestoneStatus.COMPLETED && dueDate.isBefore(DateTime.now());
}

@immutable
class Risk {
  final String description;
  final RiskImpact impact;
  final RiskProbability probability;
  final String mitigationStrategy;
  final String ownerId;
  final String? ownerName;

  const Risk({
    required this.description,
    required this.impact,
    required this.probability,
    required this.mitigationStrategy,
    required this.ownerId,
    this.ownerName,
  });

  factory Risk.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] ?? {};
    return Risk(
      description: json['description'] ?? '',
      impact: RiskImpact.values.firstWhere(
            (e) => e.name == json['impact']?.toUpperCase(),
        orElse: () => RiskImpact.LOW,
      ),
      probability: RiskProbability.values.firstWhere(
            (e) => e.name == json['probability']?.toUpperCase(),
        orElse: () => RiskProbability.LOW,
      ),
      mitigationStrategy: json['mitigationStrategy'] ?? '',
      ownerId: json['owner']?['_id'] ?? json['ownerId'] ?? '',
      ownerName: owner['firstName'] != null ? '${owner['firstName']} ${owner['lastName']}' : json['ownerName'],
    );
  }
}

@immutable
class Deliverable {
  final String name;
  final String description;
  final DateTime dueDate;
  final DeliverableStatus status;
  final String? reviewComments;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvalDate;

  const Deliverable({
    required this.name,
    required this.description,
    required this.dueDate,
    required this.status,
    this.reviewComments,
    this.approvedById,
    this.approvedByName,
    this.approvalDate,
  });

  factory Deliverable.fromJson(Map<String, dynamic> json) {
    final approvedBy = json['approvedBy'] ?? {};
    return Deliverable(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      status: DeliverableStatus.values.firstWhere(
            (e) => e.name == json['status']?.toUpperCase().replaceAll(' ', '_'),
        orElse: () => DeliverableStatus.PENDING,
      ),
      reviewComments: json['reviewComments'],
      approvedById: approvedBy['_id'] ?? json['approvedById'],
      approvedByName: approvedBy['firstName'] != null ? '${approvedBy['firstName']} ${approvedBy['lastName']}' : json['approvedByName'],
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
    );
  }
}

@immutable
class BudgetItem {
  final String item;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;
  final BudgetCategory category;

  const BudgetItem({
    required this.item,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.category,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      item: json['item'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      category: BudgetCategory.values.firstWhere(
            (e) => e.name == json['category']?.toUpperCase(),
        orElse: () => BudgetCategory.OTHER,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'category': describeEnum(category).toLowerCase(),
    };
  }
}

@immutable
class PaymentSchedule {
  final String milestone;
  final DateTime dueDate;
  final double amount;
  final double percentage;
  final PaymentStatus status;
  final DateTime? paidDate;

  const PaymentSchedule({
    required this.milestone,
    required this.dueDate,
    required this.amount,
    required this.percentage,
    required this.status,
    this.paidDate,
  });

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) {
    return PaymentSchedule(
      milestone: json['milestone'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      status: PaymentStatus.values.firstWhere(
            (e) => e.name == json['status']?.toUpperCase(),
        orElse: () => PaymentStatus.PENDING,
      ),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestone': milestone,
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'percentage': percentage,
      'status': describeEnum(status).toLowerCase(),
      'paidDate': paidDate?.toIso8601String(),
    };
  }
}

@immutable
class Expense {
  final DateTime date;
  final String description;
  final double amount;
  final String category;
  final String? receipt;
  final String approvedById;
  final String? approvedByName;

  const Expense({
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.receipt,
    required this.approvedById,
    this.approvedByName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final approvedBy = json['approvedBy'] ?? {};
    return Expense(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      receipt: json['receipt'],
      approvedById: approvedBy['_id'] ?? json['approvedById'] ?? '',
      approvedByName: approvedBy['firstName'] != null ? '${approvedBy['firstName']} ${approvedBy['lastName']}' : json['approvedByName'],
    );
  }
}

enum ConsultancyCategory {
  WATER_TREATMENT,
  INFRASTRUCTURE,
  ENVIRONMENTAL,
  MANAGEMENT,
  TECHNICAL,
  RESEARCH
}

enum ConsultancyStatus {
  PROPOSAL,
  NEGOTIATION,
  APPROVED,
  ACTIVE,
  ON_HOLD,
  COMPLETED,
  TERMINATED,
  CANCELLED
}

enum ClientType {
  GOVERNMENT,
  PRIVATE,
  NGO,
  INTERNATIONAL,
  INDIVIDUAL
}

enum TeamRole {
  PROJECT_MANAGER,
  TECHNICAL_LEAD,
  CONSULTANT,
  ANALYST,
  SUPPORT
}

enum MilestoneStatus {
  NOT_STARTED,
  IN_PROGRESS,
  COMPLETED,
  DELAYED,
  CANCELLED
}

enum RiskImpact {
  LOW,
  MEDIUM,
  HIGH,
  CRITICAL
}

enum RiskProbability {
  LOW,
  MEDIUM,
  HIGH
}

enum DeliverableStatus {
  PENDING,
  SUBMITTED,
  UNDER_REVIEW,
  APPROVED,
  REJECTED,
  REVISED
}

enum BudgetCategory {
  PERSONNEL,
  EQUIPMENT,
  TRAVEL,
  MATERIALS,
  SOFTWARE,
  OTHER
}

enum PaymentStatus {
  PENDING,
  DUE,
  PAID,
  OVERDUE,
  CANCELLED
}

extension EnumExtensions on Enum {
  String get displayName {
    final name = toString().split('.').last;
    return name.replaceAll('_', ' ').replaceAllMapped(
      RegExp(r'^.| .'),
          (match) => match.group(0)!.toUpperCase(),
    );
  }

  Color get statusColor {
    switch (this) {
      case ConsultancyStatus.APPROVED:
      case ConsultancyStatus.COMPLETED:
        return Colors.green;
      case ConsultancyStatus.ACTIVE:
        return Colors.blue;
      case ConsultancyStatus.PROPOSAL:
        return Colors.orange;
      case ConsultancyStatus.NEGOTIATION:
        return Colors.purple;
      case ConsultancyStatus.ON_HOLD:
        return Colors.yellow.shade700;
      case ConsultancyStatus.CANCELLED:
      case ConsultancyStatus.TERMINATED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (this) {
      case ConsultancyStatus.APPROVED:
      case ConsultancyStatus.COMPLETED:
        return Icons.check_circle;
      case ConsultancyStatus.ACTIVE:
        return Icons.play_circle;
      case ConsultancyStatus.PROPOSAL:
        return Icons.description;
      case ConsultancyStatus.NEGOTIATION:
        return Icons.handshake;
      case ConsultancyStatus.ON_HOLD:
        return Icons.pause_circle;
      case ConsultancyStatus.CANCELLED:
      case ConsultancyStatus.TERMINATED:
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }
}