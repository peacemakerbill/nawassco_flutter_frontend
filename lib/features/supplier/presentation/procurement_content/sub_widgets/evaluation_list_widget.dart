import 'package:flutter/material.dart';

import '../../../models/supplier_evaluation_model.dart';

class EvaluationListWidget extends StatelessWidget {
  final List<SupplierEvaluation> evaluations;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(SupplierEvaluation) onView;
  final Function(SupplierEvaluation) onSubmit;
  final Function(SupplierEvaluation) onApprove;
  final Function(SupplierEvaluation) onReject;
  final Function(String, String, String) onUpdateAction;

  const EvaluationListWidget({
    super.key,
    required this.evaluations,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onView,
    required this.onSubmit,
    required this.onApprove,
    required this.onReject,
    required this.onUpdateAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No evaluations found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: evaluations.length,
        itemBuilder: (context, index) => _buildEvaluationCard(evaluations[index]),
      ),
    );
  }

  Widget _buildEvaluationCard(SupplierEvaluation evaluation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      const SizedBox(height: 4),
                      Text(
                        'Evaluation Date: ${_formatDate(evaluation.evaluationDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(evaluation.status),
              ],
            ),
            const SizedBox(height: 12),
            // Scores
            _buildScoreRow(evaluation),
            const SizedBox(height: 12),
            // Follow-up actions
            if (evaluation.followUpActions.isNotEmpty)
              _buildFollowUpActions(evaluation),
            const SizedBox(height: 12),
            // Action buttons
            _buildActionButtons(evaluation),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'draft': Colors.grey,
      'under_review': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
    };

    final color = statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildScoreRow(SupplierEvaluation evaluation) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                evaluation.totalScore.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0066A1),
                ),
              ),
              const Text(
                'Total Score',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                evaluation.grade,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Grade',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatDate(evaluation.nextEvaluationDate),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Next Evaluation',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpActions(SupplierEvaluation evaluation) {
    final pendingActions = evaluation.followUpActions.where((action) =>
      action['status'] == 'pending' || action['status'] == 'in_progress'
    ).toList();

    if (pendingActions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Actions:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...pendingActions.take(2).map((action) => _buildActionItem(evaluation.id, action)),
        if (pendingActions.length > 2)
          Text('+${pendingActions.length - 2} more actions...',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildActionItem(String evaluationId, Map<String, dynamic> action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '• ${action['action']}',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 16),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
              const PopupMenuItem(value: 'in_progress', child: Text('Mark In Progress')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
            ],
            onSelected: (status) => onUpdateAction(evaluationId, action['_id'], status),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SupplierEvaluation evaluation) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onView(evaluation),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Details'),
          ),
        ),
        const SizedBox(width: 8),
        if (evaluation.status == 'draft')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onSubmit(evaluation),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066A1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (evaluation.status == 'under_review') ...[
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onApprove(evaluation),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onReject(evaluation),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}