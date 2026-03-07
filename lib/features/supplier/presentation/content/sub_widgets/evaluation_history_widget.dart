import 'package:flutter/material.dart';
import '../../../models/supplier_evaluation_model.dart';

class EvaluationHistoryWidget extends StatelessWidget {
  final List<SupplierEvaluation> evaluations;
  final bool isLoading;

  const EvaluationHistoryWidget({
    super.key,
    required this.evaluations,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No evaluations yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Your performance evaluations will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),
          const SizedBox(height: 20),

          // Evaluations List
          ...evaluations.map((evaluation) => _buildEvaluationCard(evaluation)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final latestEvaluation = evaluations.isNotEmpty ? evaluations.first : null;
    final averageScore = evaluations.isNotEmpty
        ? evaluations.map((e) => e.totalScore).reduce((a, b) => a + b) / evaluations.length
        : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066A1),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Evaluations', evaluations.length.toString()),
                _buildSummaryItem('Average Score', averageScore.toStringAsFixed(1)),
                _buildSummaryItem('Latest Grade', latestEvaluation?.grade ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0066A1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationCard(SupplierEvaluation evaluation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evaluation.evaluationNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Evaluated on ${_formatDate(evaluation.evaluationDate)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(evaluation.status),
                _buildScoreCircle(evaluation.totalScore),
              ],
            ),
            const SizedBox(height: 16),

            // Scores Grid
            _buildScoresGrid(evaluation),
            const SizedBox(height: 12),

            // Evaluation Period
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Period: ${_formatDate(evaluation.evaluationPeriod['startDate'])} - ${_formatDate(evaluation.evaluationPeriod['endDate'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Next: ${_formatDate(evaluation.nextEvaluationDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // Strengths & Weaknesses
            if (evaluation.strengths.isNotEmpty || evaluation.weaknesses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (evaluation.strengths.isNotEmpty) ...[
                    Expanded(
                      child: _buildListSection('Strengths', evaluation.strengths, Icons.thumb_up, Colors.green),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (evaluation.weaknesses.isNotEmpty)
                    Expanded(
                      child: _buildListSection('Weaknesses', evaluation.weaknesses, Icons.thumb_down, Colors.orange),
                    ),
                ],
              ),
            ],

            // Recommendations
            if (evaluation.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildListSection('Recommendations', evaluation.recommendations, Icons.lightbulb, Colors.blue),
            ],

            // Follow-up Actions
            if (evaluation.followUpActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildFollowUpActions(evaluation),
            ],

            // Approval Info
            if (evaluation.approvedById != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Approved on ${_formatDate(evaluation.approvalDate!)}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
              if (evaluation.approvalComments != null)
                Text(
                  'Comments: ${evaluation.approvalComments}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'approved': Colors.green,
      'under_review': Colors.orange,
      'rejected': Colors.red,
      'draft': Colors.grey,
    };

    final color = statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double score) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
          ),
        ),
        Text(
          score.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score),
          ),
        ),
      ],
    );
  }

  Widget _buildScoresGrid(SupplierEvaluation evaluation) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildScoreItem('Technical', evaluation.technicalScore),
        _buildScoreItem('Financial', evaluation.financialScore),
        _buildScoreItem('Delivery', evaluation.deliveryScore),
        _buildScoreItem('Quality', evaluation.qualityScore),
        _buildScoreItem('Compliance', evaluation.complianceScore),
        _buildScoreItem('Relationship', evaluation.relationshipScore),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(score),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.take(3).map((item) => Text(
          '• $item',
          style: const TextStyle(fontSize: 11),
        )),
        if (items.length > 3)
          Text(
            '+${items.length - 3} more...',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildFollowUpActions(SupplierEvaluation evaluation) {
    final pendingActions = evaluation.followUpActions.where((action) =>
    action['status'] == 'pending' || action['status'] == 'in_progress'
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        ...pendingActions.map((action) => _buildActionItem(action)),
      ],
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange[100]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.orange[50],
      ),
      child: Row(
        children: [
          Icon(
            _getActionIcon(action['status']),
            size: 16,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action['action'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Due: ${_formatDate(action['deadline'])}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle;
      case 'in_progress': return Icons.hourglass_empty;
      default: return Icons.pending;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (date is String) {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate != null) {
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
    }
    return 'N/A';
  }
}