enum PlanStatus {
  draft('Draft'),
  underReview('Under Review'),
  approved('Approved'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const PlanStatus(this.label);

  static PlanStatus fromString(String value) {
    return PlanStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => PlanStatus.draft,
    );
  }
}

enum GoalStatus {
  notStarted('Not Started'),
  inProgress('In Progress'),
  atRisk('At Risk'),
  completed('Completed'),
  delayed('Delayed');

  final String label;

  const GoalStatus(this.label);

  static GoalStatus fromString(String value) {
    return GoalStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => GoalStatus.notStarted,
    );
  }
}

enum InitiativeStatus {
  planning('Planning'),
  execution('Execution'),
  monitoring('Monitoring'),
  completed('Completed'),
  delayed('Delayed');

  final String label;

  const InitiativeStatus(this.label);

  static InitiativeStatus fromString(String value) {
    return InitiativeStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => InitiativeStatus.planning,
    );
  }
}

class StrategicGoal {
  final String id;
  final String goalNumber;
  final String title;
  final String description;
  final String category;
  final int priority;
  final double progress;
  final GoalStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final String ownerName;
  final List<String> dependencies;
  final Map<String, dynamic> metrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  StrategicGoal({
    required this.id,
    required this.goalNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.progress,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    required this.ownerName,
    this.dependencies = const [],
    this.metrics = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrategicGoal.fromJson(Map<String, dynamic> json) {
    return StrategicGoal(
      id: json['_id'] ?? json['id'] ?? '',
      goalNumber: json['goalNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priority: (json['priority'] ?? 1).toInt(),
      progress: (json['progress'] ?? 0).toDouble(),
      status: GoalStatus.fromString(json['status'] ?? 'notStarted'),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 365)),
      ownerId:
          json['owner'] is Map ? json['owner']['_id'] : (json['ownerId'] ?? ''),
      ownerName: json['owner'] is Map
          ? '${json['owner']['firstName'] ?? ''} ${json['owner']['lastName'] ?? ''}'
              .trim()
          : (json['ownerName'] ?? ''),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'progress': progress,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'owner': ownerId,
    };
  }

  StrategicGoal copyWith({
    String? id,
    String? goalNumber,
    String? title,
    String? description,
    String? category,
    int? priority,
    double? progress,
    GoalStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? ownerId,
    String? ownerName,
    List<String>? dependencies,
    Map<String, dynamic>? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StrategicGoal(
      id: id ?? this.id,
      goalNumber: goalNumber ?? this.goalNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      dependencies: dependencies ?? this.dependencies,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StrategicInitiative {
  final String id;
  final String initiativeNumber;
  final String title;
  final String description;
  final String goalId;
  final double progress;
  final InitiativeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final String ownerName;
  final double budget;
  final double spent;
  final List<Map<String, dynamic>> phases;
  final List<String> resources;
  final List<Map<String, dynamic>> milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  StrategicInitiative({
    required this.id,
    required this.initiativeNumber,
    required this.title,
    required this.description,
    required this.goalId,
    required this.progress,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    required this.ownerName,
    required this.budget,
    required this.spent,
    this.phases = const [],
    this.resources = const [],
    this.milestones = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrategicInitiative.fromJson(Map<String, dynamic> json) {
    return StrategicInitiative(
      id: json['_id'] ?? json['id'] ?? '',
      initiativeNumber: json['initiativeNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      goalId: json['goalId'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      status: InitiativeStatus.fromString(json['status'] ?? 'planning'),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 180)),
      ownerId:
          json['owner'] is Map ? json['owner']['_id'] : (json['ownerId'] ?? ''),
      ownerName: json['owner'] is Map
          ? '${json['owner']['firstName'] ?? ''} ${json['owner']['lastName'] ?? ''}'
              .trim()
          : (json['ownerName'] ?? ''),
      budget: (json['budget'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      phases: List<Map<String, dynamic>>.from(json['phases'] ?? []),
      resources: List<String>.from(json['resources'] ?? []),
      milestones: List<Map<String, dynamic>>.from(json['milestones'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'goalId': goalId,
      'progress': progress,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'owner': ownerId,
      'budget': budget,
      'spent': spent,
    };
  }

  StrategicInitiative copyWith({
    String? id,
    String? initiativeNumber,
    String? title,
    String? description,
    String? goalId,
    double? progress,
    InitiativeStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? ownerId,
    String? ownerName,
    double? budget,
    double? spent,
    List<Map<String, dynamic>>? phases,
    List<String>? resources,
    List<Map<String, dynamic>>? milestones,
  }) {
    return StrategicInitiative(
      id: id ?? this.id,
      initiativeNumber: initiativeNumber ?? this.initiativeNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      phases: phases ?? this.phases,
      resources: resources ?? this.resources,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class StrategicPlan {
  final String id;
  final String title;
  final String description;
  final String visionStatement;
  final String missionStatement;
  final String fiscalYear;
  final String planningCycle;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String createdById;
  final String createdByName;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvalDate;
  final List<StrategicGoal> strategicGoals;
  final List<StrategicInitiative> strategicInitiatives;
  final List<Map<String, dynamic>> budgetAllocation;
  final List<Map<String, dynamic>> resourceRequirements;
  final List<Map<String, dynamic>> risks;
  final List<Map<String, dynamic>> mitigationStrategies;
  final List<String> stakeholders;
  final Map<String, dynamic> communicationPlan;
  final Map<String, dynamic> reviewSchedule;
  final Map<String, dynamic> performance;
  final DateTime nextReviewDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  StrategicPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.visionStatement,
    required this.missionStatement,
    required this.fiscalYear,
    required this.planningCycle,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdById,
    required this.createdByName,
    this.approvedById,
    this.approvedByName,
    this.approvalDate,
    this.strategicGoals = const [],
    this.strategicInitiatives = const [],
    this.budgetAllocation = const [],
    this.resourceRequirements = const [],
    this.risks = const [],
    this.mitigationStrategies = const [],
    this.stakeholders = const [],
    this.communicationPlan = const {},
    this.reviewSchedule = const {},
    this.performance = const {},
    required this.nextReviewDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrategicPlan.fromJson(Map<String, dynamic> json) {
    return StrategicPlan(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      visionStatement: json['visionStatement'] ?? '',
      missionStatement: json['missionStatement'] ?? '',
      fiscalYear: json['fiscalYear'] ?? DateTime.now().year.toString(),
      planningCycle: json['planningCycle'] ?? 'Annual',
      status: PlanStatus.fromString(json['status'] ?? 'draft'),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 365)),
      createdById: json['createdBy'] is Map
          ? json['createdBy']['_id']
          : (json['createdById'] ?? ''),
      createdByName: json['createdBy'] is Map
          ? '${json['createdBy']['firstName'] ?? ''} ${json['createdBy']['lastName'] ?? ''}'
              .trim()
          : (json['createdByName'] ?? ''),
      approvedById: json['approvedBy'] != null
          ? (json['approvedBy'] is Map
              ? json['approvedBy']['_id']
              : json['approvedById'])
          : null,
      approvedByName: json['approvedBy'] is Map
          ? '${json['approvedBy']['firstName'] ?? ''} ${json['approvedBy']['lastName'] ?? ''}'
              .trim()
          : (json['approvedByName']),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      strategicGoals: (json['strategicGoals'] as List? ?? [])
          .map((goal) => StrategicGoal.fromJson(goal))
          .toList(),
      strategicInitiatives: (json['strategicInitiatives'] as List? ?? [])
          .map((initiative) => StrategicInitiative.fromJson(initiative))
          .toList(),
      budgetAllocation:
          List<Map<String, dynamic>>.from(json['budgetAllocation'] ?? []),
      resourceRequirements:
          List<Map<String, dynamic>>.from(json['resourceRequirements'] ?? []),
      risks: List<Map<String, dynamic>>.from(json['risks'] ?? []),
      mitigationStrategies:
          List<Map<String, dynamic>>.from(json['mitigationStrategies'] ?? []),
      stakeholders: List<String>.from(json['stakeholders'] ?? []),
      communicationPlan:
          Map<String, dynamic>.from(json['communicationPlan'] ?? {}),
      reviewSchedule: Map<String, dynamic>.from(json['reviewSchedule'] ?? {}),
      performance: Map<String, dynamic>.from(json['performance'] ??
          {
            'overallProgress': 0,
            'goalsAchieved': 0,
            'totalGoals': 0,
            'kpiPerformance': 0,
            'budgetUtilization': 0,
            'riskExposure': 0,
          }),
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : DateTime.now().add(const Duration(days: 90)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'visionStatement': visionStatement,
      'missionStatement': missionStatement,
      'fiscalYear': fiscalYear,
      'planningCycle': planningCycle,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'strategicGoals': strategicGoals.map((goal) => goal.toJson()).toList(),
    };
  }

  StrategicPlan copyWith({
    String? id,
    String? title,
    String? description,
    String? visionStatement,
    String? missionStatement,
    String? fiscalYear,
    String? planningCycle,
    PlanStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? createdById,
    String? createdByName,
    String? approvedById,
    String? approvedByName,
    DateTime? approvalDate,
    List<StrategicGoal>? strategicGoals,
    List<StrategicInitiative>? strategicInitiatives,
    List<Map<String, dynamic>>? budgetAllocation,
    List<Map<String, dynamic>>? resourceRequirements,
    List<Map<String, dynamic>>? risks,
    List<Map<String, dynamic>>? mitigationStrategies,
    List<String>? stakeholders,
    Map<String, dynamic>? communicationPlan,
    Map<String, dynamic>? reviewSchedule,
    Map<String, dynamic>? performance,
    DateTime? nextReviewDate,
  }) {
    return StrategicPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      visionStatement: visionStatement ?? this.visionStatement,
      missionStatement: missionStatement ?? this.missionStatement,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      planningCycle: planningCycle ?? this.planningCycle,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      approvalDate: approvalDate ?? this.approvalDate,
      strategicGoals: strategicGoals ?? this.strategicGoals,
      strategicInitiatives: strategicInitiatives ?? this.strategicInitiatives,
      budgetAllocation: budgetAllocation ?? this.budgetAllocation,
      resourceRequirements: resourceRequirements ?? this.resourceRequirements,
      risks: risks ?? this.risks,
      mitigationStrategies: mitigationStrategies ?? this.mitigationStrategies,
      stakeholders: stakeholders ?? this.stakeholders,
      communicationPlan: communicationPlan ?? this.communicationPlan,
      reviewSchedule: reviewSchedule ?? this.reviewSchedule,
      performance: performance ?? this.performance,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  double get overallProgress {
    if (strategicGoals.isEmpty) return 0;
    final total = strategicGoals.fold(0.0, (sum, goal) => sum + goal.progress);
    return total / strategicGoals.length;
  }

  int get completedGoals =>
      strategicGoals.where((g) => g.status == GoalStatus.completed).length;

  int get totalGoals => strategicGoals.length;

  double get budgetUtilization {
    if (budgetAllocation.isEmpty) return 0;
    final totalBudget = budgetAllocation.fold(
        0.0, (sum, item) => sum + (item['allocated'] ?? 0.0));
    final totalSpent =
        budgetAllocation.fold(0.0, (sum, item) => sum + (item['spent'] ?? 0.0));
    return totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;
  }
}
