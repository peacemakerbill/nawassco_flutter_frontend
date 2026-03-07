// lib/features/manager/decision_logs/models/decision_log_model.dart

import 'package:flutter/material.dart';

enum UrgencyLevel {
  critical('Critical', Colors.red),
  high('High', Colors.orange),
  medium('Medium', Colors.yellow),
  low('Low', Colors.green);

  final String label;
  final Color color;
  const UrgencyLevel(this.label, this.color);
}

enum ImpactLevel {
  catastrophic('Catastrophic', Colors.red),
  major('Major', Colors.orange),
  moderate('Moderate', Colors.yellow),
  minor('Minor', Colors.green),
  negligible('Negligible', Colors.blue);

  final String label;
  final Color color;
  const ImpactLevel(this.label, this.color);
}

enum DecisionStatus {
  pending('Pending', Icons.pending, Colors.orange),
  underReview('Under Review', Icons.rate_review, Colors.blue),
  approved('Approved', Icons.check_circle, Colors.green),
  implemented('Implemented', Icons.done_all, Colors.teal),
  reviewed('Reviewed', Icons.reviews, Colors.purple),
  cancelled('Cancelled', Icons.cancel, Colors.red);

  final String label;
  final IconData icon;
  final Color color;
  const DecisionStatus(this.label, this.icon, this.color);
}

enum StepStatus {
  notStarted('Not Started', Icons.radio_button_unchecked, Colors.grey),
  inProgress('In Progress', Icons.timelapse, Colors.blue),
  completed('Completed', Icons.check_circle, Colors.green),
  delayed('Delayed', Icons.warning, Colors.orange);

  final String label;
  final IconData icon;
  final Color color;
  const StepStatus(this.label, this.icon, this.color);
}

class DecisionContext {
  final String background;
  final String trigger;
  final String scope;
  final UrgencyLevel urgency;
  final ImpactLevel impact;

  const DecisionContext({
    required this.background,
    required this.trigger,
    required this.scope,
    required this.urgency,
    required this.impact,
  });

  Map<String, dynamic> toJson() => {
    'background': background,
    'trigger': trigger,
    'scope': scope,
    'urgency': urgency.name,
    'impact': impact.name,
  };

  static DecisionContext fromJson(Map<String, dynamic> json) => DecisionContext(
    background: json['background'] ?? '',
    trigger: json['trigger'] ?? '',
    scope: json['scope'] ?? '',
    urgency: UrgencyLevel.values.firstWhere(
          (e) => e.name == json['urgency'],
      orElse: () => UrgencyLevel.medium,
    ),
    impact: ImpactLevel.values.firstWhere(
          (e) => e.name == json['impact'],
      orElse: () => ImpactLevel.moderate,
    ),
  );
}

class DecisionAlternative {
  final String alternative;
  final String description;
  final List<String> pros;
  final List<String> cons;
  final double cost;
  final int timelineDays;
  final List<String> risks;

  const DecisionAlternative({
    required this.alternative,
    required this.description,
    this.pros = const [],
    this.cons = const [],
    required this.cost,
    required this.timelineDays,
    this.risks = const [],
  });

  Map<String, dynamic> toJson() => {
    'alternative': alternative,
    'description': description,
    'pros': pros,
    'cons': cons,
    'cost': cost,
    'timeline': timelineDays,
    'risks': risks,
  };
}

class DecisionCriteria {
  final String criterion;
  final double weight;
  final String description;

  const DecisionCriteria({
    required this.criterion,
    required this.weight,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'criterion': criterion,
    'weight': weight,
    'description': description,
  };
}

class AlternativeScore {
  final String alternative;
  final List<CriterionScore> scores;
  final double totalScore;
  final int rank;

  const AlternativeScore({
    required this.alternative,
    required this.scores,
    required this.totalScore,
    required this.rank,
  });

  Map<String, dynamic> toJson() => {
    'alternative': alternative,
    'scores': scores.map((s) => s.toJson()).toList(),
    'totalScore': totalScore,
    'rank': rank,
  };
}

class CriterionScore {
  final String criterion;
  final double score;
  final String justification;

  const CriterionScore({
    required this.criterion,
    required this.score,
    required this.justification,
  });

  Map<String, dynamic> toJson() => {
    'criterion': criterion,
    'score': score,
    'justification': justification,
  };
}

class DecisionAnalysis {
  final String method;
  final List<AlternativeScore> scores;
  final String recommendation;
  final double confidence;

  const DecisionAnalysis({
    required this.method,
    required this.scores,
    required this.recommendation,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'method': method,
    'scores': scores.map((s) => s.toJson()).toList(),
    'recommendation': recommendation,
    'confidence': confidence,
  };

  static DecisionAnalysis fromJson(Map<String, dynamic> json) => DecisionAnalysis(
    method: json['method'] ?? 'multi_criteria',
    scores: (json['scores'] as List? ?? []).map((s) => AlternativeScore(
      alternative: s['alternative'] ?? '',
      scores: (s['scores'] as List? ?? []).map((cs) => CriterionScore(
        criterion: cs['criterion'] ?? '',
        score: (cs['score'] as num?)?.toDouble() ?? 0,
        justification: cs['justification'] ?? '',
      )).toList(),
      totalScore: (s['totalScore'] as num?)?.toDouble() ?? 0,
      rank: (s['rank'] as num?)?.toInt() ?? 0,
    )).toList(),
    recommendation: json['recommendation'] ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
  );
}

class ImplementationStep {
  final String step;
  final String description;
  final String ownerId;
  final DateTime startDate;
  final DateTime? endDate;
  final StepStatus status;

  const ImplementationStep({
    required this.step,
    required this.description,
    required this.ownerId,
    required this.startDate,
    this.endDate,
    this.status = StepStatus.notStarted,
  });

  Map<String, dynamic> toJson() => {
    'step': step,
    'description': description,
    'owner': ownerId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'status': status.name,
  };
}

class DecisionLog {
  final String? id;
  final String decisionId;
  final String title;
  final String description;
  final DecisionContext context;
  final String problemStatement;
  final List<String> objectives;
  final List<String> constraints;
  final List<DecisionAlternative> alternatives;
  final List<DecisionCriteria> criteria;
  final DecisionAnalysis analysis;
  final String decision;
  final String rationale;
  final List<String> expectedOutcomes;
  final List<ImplementationStep> implementationSteps;
  final DecisionStatus status;
  final String decisionMakerId;
  final DateTime decisionDate;
  final String? approvedById;
  final DateTime? approvalDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>>? stakeholders;
  final List<Map<String, dynamic>>? resources;
  final List<Map<String, dynamic>>? timeline;
  final List<Map<String, dynamic>>? actualOutcomes;
  final List<String>? lessonsLearned;

  const DecisionLog({
    this.id,
    required this.decisionId,
    required this.title,
    required this.description,
    required this.context,
    required this.problemStatement,
    this.objectives = const [],
    this.constraints = const [],
    this.alternatives = const [],
    this.criteria = const [],
    required this.analysis,
    required this.decision,
    required this.rationale,
    this.expectedOutcomes = const [],
    this.implementationSteps = const [],
    this.status = DecisionStatus.pending,
    required this.decisionMakerId,
    required this.decisionDate,
    this.approvedById,
    this.approvalDate,
    required this.createdAt,
    required this.updatedAt,
    this.stakeholders,
    this.resources,
    this.timeline,
    this.actualOutcomes,
    this.lessonsLearned,
  });

  DecisionLog copyWith({
    String? id,
    String? decisionId,
    String? title,
    String? description,
    DecisionContext? context,
    String? problemStatement,
    List<String>? objectives,
    List<String>? constraints,
    List<DecisionAlternative>? alternatives,
    List<DecisionCriteria>? criteria,
    DecisionAnalysis? analysis,
    String? decision,
    String? rationale,
    List<String>? expectedOutcomes,
    List<ImplementationStep>? implementationSteps,
    DecisionStatus? status,
    String? decisionMakerId,
    DateTime? decisionDate,
    String? approvedById,
    DateTime? approvalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? stakeholders,
    List<Map<String, dynamic>>? resources,
    List<Map<String, dynamic>>? timeline,
    List<Map<String, dynamic>>? actualOutcomes,
    List<String>? lessonsLearned,
  }) {
    return DecisionLog(
      id: id ?? this.id,
      decisionId: decisionId ?? this.decisionId,
      title: title ?? this.title,
      description: description ?? this.description,
      context: context ?? this.context,
      problemStatement: problemStatement ?? this.problemStatement,
      objectives: objectives ?? this.objectives,
      constraints: constraints ?? this.constraints,
      alternatives: alternatives ?? this.alternatives,
      criteria: criteria ?? this.criteria,
      analysis: analysis ?? this.analysis,
      decision: decision ?? this.decision,
      rationale: rationale ?? this.rationale,
      expectedOutcomes: expectedOutcomes ?? this.expectedOutcomes,
      implementationSteps: implementationSteps ?? this.implementationSteps,
      status: status ?? this.status,
      decisionMakerId: decisionMakerId ?? this.decisionMakerId,
      decisionDate: decisionDate ?? this.decisionDate,
      approvedById: approvedById ?? this.approvedById,
      approvalDate: approvalDate ?? this.approvalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stakeholders: stakeholders ?? this.stakeholders,
      resources: resources ?? this.resources,
      timeline: timeline ?? this.timeline,
      actualOutcomes: actualOutcomes ?? this.actualOutcomes,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'decisionId': decisionId,
    'title': title,
    'description': description,
    'context': context.toJson(),
    'problemStatement': problemStatement,
    'objectives': objectives,
    'constraints': constraints,
    'alternatives': alternatives.map((a) => a.toJson()).toList(),
    'criteria': criteria.map((c) => c.toJson()).toList(),
    'analysis': analysis.toJson(),
    'decision': decision,
    'rationale': rationale,
    'expectedOutcomes': expectedOutcomes,
    'implementationPlan': {
      'steps': implementationSteps.map((s) => s.toJson()).toList(),
      'dependencies': [],
      'criticalPath': [],
    },
    'status': status.name,
    'decisionMaker': decisionMakerId,
    'decisionDate': decisionDate.toIso8601String(),
    if (approvedById != null) 'approvedBy': approvedById,
    if (approvalDate != null) 'approvalDate': approvalDate!.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (stakeholders != null) 'stakeholders': stakeholders,
    if (resources != null) 'resources': resources,
    if (timeline != null) 'timeline': timeline,
    if (actualOutcomes != null) 'actualOutcomes': actualOutcomes,
    if (lessonsLearned != null) 'lessonsLearned': lessonsLearned,
  };

  static DecisionLog fromJson(Map<String, dynamic> json) {
    final contextData = json['context'] as Map<String, dynamic>? ?? {};
    final implementationPlan = json['implementationPlan'] as Map<String, dynamic>? ?? {};
    final steps = implementationPlan['steps'] as List? ?? [];

    return DecisionLog(
      id: json['_id']?.toString(),
      decisionId: json['decisionId']?.toString() ?? 'DEC-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      context: DecisionContext.fromJson(contextData),
      problemStatement: json['problemStatement']?.toString() ?? '',
      objectives: List<String>.from(json['objectives'] ?? []),
      constraints: List<String>.from(json['constraints'] ?? []),
      alternatives: (json['alternatives'] as List? ?? []).map((a) => DecisionAlternative(
        alternative: a['alternative']?.toString() ?? '',
        description: a['description']?.toString() ?? '',
        pros: List<String>.from(a['pros'] ?? []),
        cons: List<String>.from(a['cons'] ?? []),
        cost: (a['cost'] as num?)?.toDouble() ?? 0,
        timelineDays: (a['timeline'] as num?)?.toInt() ?? 0,
        risks: List<String>.from(a['risks'] ?? []),
      )).toList(),
      criteria: (json['criteria'] as List? ?? []).map((c) => DecisionCriteria(
        criterion: c['criterion']?.toString() ?? '',
        weight: (c['weight'] as num?)?.toDouble() ?? 0,
        description: c['description']?.toString() ?? '',
      )).toList(),
      analysis: DecisionAnalysis.fromJson(json['analysis'] as Map<String, dynamic>? ?? {}),
      decision: json['decision']?.toString() ?? '',
      rationale: json['rationale']?.toString() ?? '',
      expectedOutcomes: List<String>.from(json['expectedOutcomes'] ?? []),
      implementationSteps: steps.map((s) {
        final stepStatus = StepStatus.values.firstWhere(
              (e) => e.name == (s['status'] as String?),
          orElse: () => StepStatus.notStarted,
        );
        return ImplementationStep(
          step: s['step']?.toString() ?? '',
          description: s['description']?.toString() ?? '',
          ownerId: s['owner']?.toString() ?? '',
          startDate: DateTime.parse(s['startDate']?.toString() ?? DateTime.now().toIso8601String()),
          endDate: s['endDate'] != null ? DateTime.parse(s['endDate']!.toString()) : null,
          status: stepStatus,
        );
      }).toList(),
      status: DecisionStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String?),
        orElse: () => DecisionStatus.pending,
      ),
      decisionMakerId: json['decisionMaker']?.toString() ?? '',
      decisionDate: DateTime.parse(json['decisionDate']?.toString() ?? DateTime.now().toIso8601String()),
      approvedById: json['approvedBy']?.toString(),
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']!.toString()) : null,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      stakeholders: json['stakeholders'] != null ? List<Map<String, dynamic>>.from(json['stakeholders']) : null,
      resources: json['resources'] != null ? List<Map<String, dynamic>>.from(json['resources']) : null,
      timeline: json['timeline'] != null ? List<Map<String, dynamic>>.from(json['timeline']) : null,
      actualOutcomes: json['actualOutcomes'] != null ? List<Map<String, dynamic>>.from(json['actualOutcomes']) : null,
      lessonsLearned: json['lessonsLearned'] != null ? List<String>.from(json['lessonsLearned']) : null,
    );
  }
}