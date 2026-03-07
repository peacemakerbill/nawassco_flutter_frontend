import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/performance/competency_assessment.model.dart';
import '../../models/performance/development_plan.model.dart';
import '../../models/performance/goal_assessment.model.dart';
import '../../models/performance/key_performance_area.model.dart';
import '../../models/performance/performance_appraisal.model.dart';

class AppraisalFormState {
  final PerformanceAppraisal? editingAppraisal;
  final List<KeyPerformanceArea> keyPerformanceAreas;
  final List<CompetencyAssessment> competencies;
  final List<GoalAssessment> goals;
  final List<String> strengths;
  final List<String> developmentAreas;
  final List<DevelopmentPlan> developmentPlans;
  final List<String> trainingRecommendations;
  final bool isLoading;
  final String? error;

  AppraisalFormState({
    this.editingAppraisal,
    this.keyPerformanceAreas = const [],
    this.competencies = const [],
    this.goals = const [],
    this.strengths = const [],
    this.developmentAreas = const [],
    this.developmentPlans = const [],
    this.trainingRecommendations = const [],
    this.isLoading = false,
    this.error,
  });

  AppraisalFormState copyWith({
    PerformanceAppraisal? editingAppraisal,
    List<KeyPerformanceArea>? keyPerformanceAreas,
    List<CompetencyAssessment>? competencies,
    List<GoalAssessment>? goals,
    List<String>? strengths,
    List<String>? developmentAreas,
    List<DevelopmentPlan>? developmentPlans,
    List<String>? trainingRecommendations,
    bool? isLoading,
    String? error,
  }) {
    return AppraisalFormState(
      editingAppraisal: editingAppraisal ?? this.editingAppraisal,
      keyPerformanceAreas: keyPerformanceAreas ?? this.keyPerformanceAreas,
      competencies: competencies ?? this.competencies,
      goals: goals ?? this.goals,
      strengths: strengths ?? this.strengths,
      developmentAreas: developmentAreas ?? this.developmentAreas,
      developmentPlans: developmentPlans ?? this.developmentPlans,
      trainingRecommendations:
          trainingRecommendations ?? this.trainingRecommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AppraisalFormProvider extends StateNotifier<AppraisalFormState> {
  AppraisalFormProvider() : super(AppraisalFormState());

  // Initialize form with existing appraisal
  void initializeWithAppraisal(PerformanceAppraisal appraisal) {
    state = AppraisalFormState(
      editingAppraisal: appraisal,
      keyPerformanceAreas: List.from(appraisal.keyPerformanceAreas),
      competencies: List.from(appraisal.competencies),
      goals: List.from(appraisal.goals),
      strengths: List.from(appraisal.strengths),
      developmentAreas: List.from(appraisal.developmentAreas),
      developmentPlans: List.from(appraisal.developmentPlan),
      trainingRecommendations: List.from(appraisal.trainingRecommendations),
    );
  }

  // Clear form
  void clear() {
    state = AppraisalFormState();
  }

  // Add/Update Key Performance Area
  void addKeyPerformanceArea(KeyPerformanceArea kpa) {
    state = state.copyWith(
      keyPerformanceAreas: [...state.keyPerformanceAreas, kpa],
    );
  }

  void updateKeyPerformanceArea(int index, KeyPerformanceArea kpa) {
    final updated = List<KeyPerformanceArea>.from(state.keyPerformanceAreas);
    if (index >= 0 && index < updated.length) {
      updated[index] = kpa;
      state = state.copyWith(keyPerformanceAreas: updated);
    }
  }

  void removeKeyPerformanceArea(int index) {
    final updated = List<KeyPerformanceArea>.from(state.keyPerformanceAreas);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(keyPerformanceAreas: updated);
    }
  }

  // Add/Update Competency
  void addCompetency(CompetencyAssessment competency) {
    state = state.copyWith(
      competencies: [...state.competencies, competency],
    );
  }

  void updateCompetency(int index, CompetencyAssessment competency) {
    final updated = List<CompetencyAssessment>.from(state.competencies);
    if (index >= 0 && index < updated.length) {
      updated[index] = competency;
      state = state.copyWith(competencies: updated);
    }
  }

  void removeCompetency(int index) {
    final updated = List<CompetencyAssessment>.from(state.competencies);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(competencies: updated);
    }
  }

  // Add/Update Goal
  void addGoal(GoalAssessment goal) {
    state = state.copyWith(
      goals: [...state.goals, goal],
    );
  }

  void updateGoal(int index, GoalAssessment goal) {
    final updated = List<GoalAssessment>.from(state.goals);
    if (index >= 0 && index < updated.length) {
      updated[index] = goal;
      state = state.copyWith(goals: updated);
    }
  }

  void removeGoal(int index) {
    final updated = List<GoalAssessment>.from(state.goals);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(goals: updated);
    }
  }

  // Add/Update Strength
  void addStrength(String strength) {
    if (strength.trim().isNotEmpty) {
      state = state.copyWith(
        strengths: [...state.strengths, strength.trim()],
      );
    }
  }

  void removeStrength(int index) {
    final updated = List<String>.from(state.strengths);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(strengths: updated);
    }
  }

  // Add/Update Development Area
  void addDevelopmentArea(String area) {
    if (area.trim().isNotEmpty) {
      state = state.copyWith(
        developmentAreas: [...state.developmentAreas, area.trim()],
      );
    }
  }

  void removeDevelopmentArea(int index) {
    final updated = List<String>.from(state.developmentAreas);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(developmentAreas: updated);
    }
  }

  // Add/Update Development Plan
  void addDevelopmentPlan(DevelopmentPlan plan) {
    state = state.copyWith(
      developmentPlans: [...state.developmentPlans, plan],
    );
  }

  void updateDevelopmentPlan(int index, DevelopmentPlan plan) {
    final updated = List<DevelopmentPlan>.from(state.developmentPlans);
    if (index >= 0 && index < updated.length) {
      updated[index] = plan;
      state = state.copyWith(developmentPlans: updated);
    }
  }

  void removeDevelopmentPlan(int index) {
    final updated = List<DevelopmentPlan>.from(state.developmentPlans);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(developmentPlans: updated);
    }
  }

  // Add/Update Training Recommendation
  void addTrainingRecommendation(String recommendation) {
    if (recommendation.trim().isNotEmpty) {
      state = state.copyWith(
        trainingRecommendations: [
          ...state.trainingRecommendations,
          recommendation.trim()
        ],
      );
    }
  }

  void removeTrainingRecommendation(int index) {
    final updated = List<String>.from(state.trainingRecommendations);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(trainingRecommendations: updated);
    }
  }

  // Calculate overall rating
  double calculateOverallRating() {
    if (state.keyPerformanceAreas.isEmpty) return 0.0;

    final totalWeight =
        state.keyPerformanceAreas.fold(0.0, (sum, kpa) => sum + kpa.weight);

    if (totalWeight == 0) return 0.0;

    final weightedScore = state.keyPerformanceAreas
        .fold(0.0, (sum, kpa) => sum + (kpa.rating * kpa.weight));

    return weightedScore / totalWeight;
  }

  // Prepare data for submission
  Map<String, dynamic> prepareSubmissionData({
    required String employeeId,
    required String appraisalPeriod,
    required DateTime appraisalDate,
    required DateTime nextAppraisalDate,
    required String reviewerId,
    required String hrReviewerId,
    String? secondReviewerId,
    String? reviewerComments,
    String? employeeComments,
  }) {
    final overallRating = calculateOverallRating();

    // Determine performance level based on rating
    final performanceLevel = overallRating >= 4.0
        ? 'exceeds_expectations'
        : overallRating >= 3.0
            ? 'meets_expectations'
            : overallRating >= 2.0
                ? 'needs_improvement'
                : 'unsatisfactory';

    // Determine potential level (simplified logic)
    final potentialLevel = overallRating >= 4.5
        ? 'high_potential'
        : overallRating >= 3.5
            ? 'growth_potential'
            : 'steady_performer';

    return {
      'employee': employeeId,
      'appraisalPeriod': appraisalPeriod,
      'appraisalDate': appraisalDate.toIso8601String(),
      'nextAppraisalDate': nextAppraisalDate.toIso8601String(),
      'reviewer': reviewerId,
      if (secondReviewerId != null && secondReviewerId.isNotEmpty)
        'secondReviewer': secondReviewerId,
      'hrReviewer': hrReviewerId,
      'keyPerformanceAreas':
          state.keyPerformanceAreas.map((e) => e.toJson()).toList(),
      'competencies': state.competencies.map((e) => e.toJson()).toList(),
      'goals': state.goals.map((e) => e.toJson()).toList(),
      'overallRating': overallRating,
      'performanceLevel': performanceLevel,
      'potentialLevel': potentialLevel,
      'strengths': state.strengths,
      'developmentAreas': state.developmentAreas,
      'reviewerComments': reviewerComments ?? '',
      'developmentPlan': state.developmentPlans.map((e) => e.toJson()).toList(),
      'trainingRecommendations': state.trainingRecommendations,
    };
  }
}

final appraisalFormProvider =
    StateNotifierProvider<AppraisalFormProvider, AppraisalFormState>(
  (ref) => AppraisalFormProvider(),
);
