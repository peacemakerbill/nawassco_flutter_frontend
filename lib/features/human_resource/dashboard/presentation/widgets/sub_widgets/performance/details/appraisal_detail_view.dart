import 'package:flutter/material.dart';
import '../../../../../../models/performance/competency_assessment.model.dart';
import '../../../../../../models/performance/development_plan.model.dart';
import '../../../../../../models/performance/goal_assessment.model.dart';
import '../../../../../../models/performance/key_performance_area.model.dart';
import '../../../../../../models/performance/performance_appraisal.model.dart';

class AppraisalDetailView extends StatelessWidget {
  final PerformanceAppraisal appraisal;
  final bool isEmployeeView;
  final VoidCallback onBack;
  final VoidCallback? onReview;
  final VoidCallback? onComplete;
  final VoidCallback? onAcknowledge;

  const AppraisalDetailView({
    super.key,
    required this.appraisal,
    required this.isEmployeeView,
    required this.onBack,
    this.onReview,
    this.onComplete,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('Performance Review - ${appraisal.appraisalNumber}'),
        actions: _buildActions(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Key Performance Areas
            _buildSection(
              title: 'Key Performance Areas',
              child: Column(
                children: appraisal.keyPerformanceAreas.map((kpa) => _buildKPACard(kpa)).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Competencies
            _buildSection(
              title: 'Competency Assessment',
              child: Column(
                children: appraisal.competencies.map((competency) => _buildCompetencyCard(competency)).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Goals
            if (appraisal.goals.isNotEmpty) ...[
              _buildSection(
                title: 'Goals & Objectives',
                child: Column(
                  children: appraisal.goals.map((goal) => _buildGoalCard(goal)).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Feedback
            _buildSection(
              title: 'Feedback',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appraisal.strengths.isNotEmpty) ...[
                    _buildFeedbackList('Strengths', appraisal.strengths, Colors.green),
                    const SizedBox(height: 16),
                  ],
                  if (appraisal.developmentAreas.isNotEmpty) ...[
                    _buildFeedbackList('Areas for Development', appraisal.developmentAreas, Colors.orange),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Development Plan
            if (appraisal.developmentPlan.isNotEmpty) ...[
              _buildSection(
                title: 'Development Plan',
                child: Column(
                  children: appraisal.developmentPlan.map((plan) => _buildDevelopmentPlanCard(plan)).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Comments
            _buildSection(
              title: 'Comments',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appraisal.reviewerComments.isNotEmpty) ...[
                    _buildCommentCard(
                      title: 'Reviewer Comments',
                      comment: appraisal.reviewerComments,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (appraisal.employeeComments != null && appraisal.employeeComments!.isNotEmpty) ...[
                    _buildCommentCard(
                      title: 'Employee Comments',
                      comment: appraisal.employeeComments!,
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (onReview != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.reviews),
          onPressed: onReview,
          tooltip: 'Review',
        ),
      );
    }

    if (onComplete != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.check_circle),
          onPressed: onComplete,
          tooltip: 'Complete',
        ),
      );
    }

    if (onAcknowledge != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.thumb_up),
          onPressed: onAcknowledge,
          tooltip: 'Acknowledge',
        ),
      );
    }

    return actions.isNotEmpty ? actions : null;
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appraisal.employeeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appraisal.appraisalPeriod,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: appraisal.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appraisal.status.color),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(appraisal.status.icon, color: appraisal.status.color),
                      const SizedBox(width: 8),
                      Text(
                        appraisal.status.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appraisal.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ratings Row
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildRatingItem(
                  label: 'Overall Rating',
                  value: appraisal.overallRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: _getRatingColor(appraisal.overallRating),
                ),
                _buildRatingItem(
                  label: 'Performance Level',
                  value: appraisal.performanceLevel.displayName,
                  icon: Icons.trending_up,
                  color: _getPerformanceColor(appraisal.performanceLevel),
                ),
                _buildRatingItem(
                  label: 'Potential Level',
                  value: appraisal.potentialLevel.displayName,
                  icon: Icons.rocket_launch,
                  color: _getPotentialColor(appraisal.potentialLevel),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reviewers
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildReviewerItem(
                  label: 'Reviewer',
                  name: appraisal.reviewerName,
                ),
                if (appraisal.secondReviewerName != null)
                  _buildReviewerItem(
                    label: 'Second Reviewer',
                    name: appraisal.secondReviewerName!,
                  ),
                _buildReviewerItem(
                  label: 'HR Reviewer',
                  name: appraisal.hrReviewerName,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dates
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildDateItem(
                  label: 'Appraisal Date',
                  date: appraisal.appraisalDate,
                ),
                _buildDateItem(
                  label: 'Next Appraisal',
                  date: appraisal.nextAppraisalDate,
                ),
                if (appraisal.acknowledgedDate != null)
                  _buildDateItem(
                    label: 'Acknowledged On',
                    date: appraisal.acknowledgedDate!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildKPACard(KeyPerformanceArea kpa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    kpa.area,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Weight: ${kpa.weight}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRatingColor(kpa.rating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            kpa.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRatingColor(kpa.rating),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Target', kpa.target),
            const SizedBox(height: 8),
            _buildDetailRow('Achievement', kpa.achievement),
            const SizedBox(height: 8),
            if (kpa.comments.isNotEmpty)
              _buildDetailRow('Comments', kpa.comments),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetencyCard(CompetencyAssessment competency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    competency.competency,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(competency.rating).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        competency.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRatingColor(competency.rating),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              competency.description,
              style: const TextStyle(color: Colors.grey),
            ),
            if (competency.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Examples:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...competency.examples.map((example) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $example'),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalAssessment goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.goal,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Target', goal.target),
                      const SizedBox(height: 4),
                      _buildDetailRow('Achievement', goal.achievement),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(goal.rating).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        goal.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRatingColor(goal.rating),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (goal.comments.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Comments', goal.comments),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentPlanCard(DevelopmentPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.developmentArea,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Action Plan', plan.actionPlan),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Resources', plan.resources),
                      const SizedBox(height: 4),
                      _buildDetailRow('Timeline', _formatDate(plan.timeline)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.timeline.isBefore(DateTime.now())
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: plan.timeline.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  child: Text(
                    plan.timeline.isBefore(DateTime.now()) ? 'Overdue' : 'Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: plan.timeline.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildCommentCard({
    required String title,
    required String comment,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewerItem({
    required String label,
    required String name,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem({
    required String label,
    required DateTime date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }

  Color _getPerformanceColor(PerformanceLevel level) {
    return switch (level) {
      PerformanceLevel.exceedsExpectations => Colors.green,
      PerformanceLevel.meetsExpectations => Colors.blue,
      PerformanceLevel.needsImprovement => Colors.orange,
      PerformanceLevel.unsatisfactory => Colors.red,
    };
  }

  Color _getPotentialColor(PotentialLevel level) {
    return switch (level) {
      PotentialLevel.highPotential => Colors.purple,
      PotentialLevel.growthPotential => Colors.blue,
      PotentialLevel.steadyPerformer => Colors.green,
      PotentialLevel.plateaued => Colors.grey,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}