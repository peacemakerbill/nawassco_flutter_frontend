class SupplierEvaluation {
  final String id;
  final String evaluationNumber;
  final String supplierId;
  final String evaluatedById;
  final DateTime evaluationDate;
  final Map<String, dynamic> evaluationPeriod;
  final double technicalScore;
  final double financialScore;
  final double deliveryScore;
  final double qualityScore;
  final double complianceScore;
  final double relationshipScore;
  final double totalScore;
  final String grade;
  final Map<String, dynamic> technicalAssessment;
  final Map<String, dynamic> financialAssessment;
  final Map<String, dynamic> deliveryAssessment;
  final Map<String, dynamic> qualityAssessment;
  final Map<String, dynamic> complianceAssessment;
  final Map<String, dynamic> relationshipAssessment;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<String> improvementAreas;
  final String status;
  final DateTime nextEvaluationDate;
  final List<dynamic> followUpActions;
  final String? approvedById;
  final DateTime? approvalDate;
  final String? approvalComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierEvaluation({
    required this.id,
    required this.evaluationNumber,
    required this.supplierId,
    required this.evaluatedById,
    required this.evaluationDate,
    required this.evaluationPeriod,
    required this.technicalScore,
    required this.financialScore,
    required this.deliveryScore,
    required this.qualityScore,
    required this.complianceScore,
    required this.relationshipScore,
    required this.totalScore,
    required this.grade,
    required this.technicalAssessment,
    required this.financialAssessment,
    required this.deliveryAssessment,
    required this.qualityAssessment,
    required this.complianceAssessment,
    required this.relationshipAssessment,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.improvementAreas,
    required this.status,
    required this.nextEvaluationDate,
    required this.followUpActions,
    this.approvedById,
    this.approvalDate,
    this.approvalComments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierEvaluation.fromJson(Map<String, dynamic> json) {
    return SupplierEvaluation(
      id: json['_id'] ?? json['id'],
      evaluationNumber: json['evaluationNumber'],
      supplierId: json['supplier'],
      evaluatedById: json['evaluatedBy'],
      evaluationDate: DateTime.parse(json['evaluationDate']),
      evaluationPeriod: Map<String, dynamic>.from(json['evaluationPeriod'] ?? {}),
      technicalScore: (json['technicalScore'] ?? 0).toDouble(),
      financialScore: (json['financialScore'] ?? 0).toDouble(),
      deliveryScore: (json['deliveryScore'] ?? 0).toDouble(),
      qualityScore: (json['qualityScore'] ?? 0).toDouble(),
      complianceScore: (json['complianceScore'] ?? 0).toDouble(),
      relationshipScore: (json['relationshipScore'] ?? 0).toDouble(),
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      grade: json['grade'],
      technicalAssessment: Map<String, dynamic>.from(json['technicalAssessment'] ?? {}),
      financialAssessment: Map<String, dynamic>.from(json['financialAssessment'] ?? {}),
      deliveryAssessment: Map<String, dynamic>.from(json['deliveryAssessment'] ?? {}),
      qualityAssessment: Map<String, dynamic>.from(json['qualityAssessment'] ?? {}),
      complianceAssessment: Map<String, dynamic>.from(json['complianceAssessment'] ?? {}),
      relationshipAssessment: Map<String, dynamic>.from(json['relationshipAssessment'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      status: json['status'] ?? 'draft',
      nextEvaluationDate: DateTime.parse(json['nextEvaluationDate']),
      followUpActions: List<dynamic>.from(json['followUpActions'] ?? []),
      approvedById: json['approvedBy'],
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
      approvalComments: json['approvalComments'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationNumber': evaluationNumber,
      'supplier': supplierId,
      'evaluatedBy': evaluatedById,
      'evaluationDate': evaluationDate.toIso8601String(),
      'evaluationPeriod': evaluationPeriod,
      'technicalScore': technicalScore,
      'financialScore': financialScore,
      'deliveryScore': deliveryScore,
      'qualityScore': qualityScore,
      'complianceScore': complianceScore,
      'relationshipScore': relationshipScore,
      'totalScore': totalScore,
      'grade': grade,
      'technicalAssessment': technicalAssessment,
      'financialAssessment': financialAssessment,
      'deliveryAssessment': deliveryAssessment,
      'qualityAssessment': qualityAssessment,
      'complianceAssessment': complianceAssessment,
      'relationshipAssessment': relationshipAssessment,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'improvementAreas': improvementAreas,
      'status': status,
      'nextEvaluationDate': nextEvaluationDate.toIso8601String(),
      'followUpActions': followUpActions,
    };
  }
}