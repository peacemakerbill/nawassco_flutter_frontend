import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';
import '../../../../providers/store_manager_provider.dart';

class ObjectivesSection extends ConsumerStatefulWidget {
  final StoreManager storeManager;

  const ObjectivesSection({super.key, required this.storeManager});

  @override
  ConsumerState<ObjectivesSection> createState() => _ObjectivesSectionState();
}

class _ObjectivesSectionState extends ConsumerState<ObjectivesSection> {
  @override
  Widget build(BuildContext context) {
    final objectives = widget.storeManager.storeObjectives;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Objectives Summary
          _buildObjectivesSummary(objectives),
          const SizedBox(height: 16),

          // Objectives List
          Expanded(
            child: objectives.isEmpty
                ? _buildEmptyObjectives()
                : _buildObjectivesList(objectives),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesSummary(List<StoreObjective> objectives) {
    final completed = objectives.where((o) => o.status == ObjectiveStatus.COMPLETED).length;
    final inProgress = objectives.where((o) => o.status == ObjectiveStatus.IN_PROGRESS).length;
    final notStarted = objectives.where((o) => o.status == ObjectiveStatus.NOT_STARTED).length;
    final atRisk = objectives.where((o) => o.status == ObjectiveStatus.AT_RISK).length;
    final onTrack = objectives.where((o) => o.status == ObjectiveStatus.ON_TRACK).length;

    final totalWeight = objectives.fold(0.0, (sum, obj) => sum + obj.weight);

    // FIXED: Explicitly cast to double
    final double averageProgress = objectives.isEmpty ? 0.0 :
    objectives.fold(0.0, (sum, obj) => sum + obj.progress) / objectives.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader('Objectives Overview', Icons.flag),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildSummaryItem('Total', objectives.length.toString(), Icons.list),
                _buildSummaryItem('Completed', completed.toString(), Icons.check_circle, Colors.green),
                _buildSummaryItem('In Progress', inProgress.toString(), Icons.autorenew, Colors.blue),
                _buildSummaryItem('Not Started', notStarted.toString(), Icons.schedule, Colors.grey),
                _buildSummaryItem('At Risk', atRisk.toString(), Icons.warning, Colors.orange),
                _buildSummaryItem('On Track', onTrack.toString(), Icons.trending_up, Colors.green),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  // FIXED: Now passing double instead of num
                  child: _buildProgressIndicator('Average Progress', averageProgress),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressIndicator('Total Weight', totalWeight, isWeight: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesList(List<StoreObjective> objectives) {
    return ListView.builder(
      itemCount: objectives.length,
      itemBuilder: (context, index) {
        final objective = objectives[index];
        return _buildObjectiveCard(objective);
      },
    );
  }

  Widget _buildObjectiveCard(StoreObjective objective) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    objective.objective,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildStatusChip(objective.status),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${objective.weight.toStringAsFixed(0)}%'),
                      backgroundColor: Colors.blue[50],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            if (objective.description.isNotEmpty)
              Text(
                objective.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),

            const SizedBox(height: 12),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${objective.progress.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: objective.progress / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(objective.status, objective.progress),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Due Date and Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(objective.dueDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (objective.metrics.isNotEmpty)
                  Text(
                    '${objective.metrics.length} metrics',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),

            // Metrics
            if (objective.metrics.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Metrics:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...objective.metrics.map((metric) =>
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            metric.metric,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${metric.current.toStringAsFixed(0)}/${metric.target.toStringAsFixed(0)} ${metric.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: metric.current >= metric.target ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ).toList(),
            ],

            // Progress Update Button
            const SizedBox(height: 12),
            if (objective.status != ObjectiveStatus.COMPLETED)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _updateObjectiveProgress(objective),
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Update Progress'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[700]!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.blue),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color ?? Colors.blue,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // FIXED: Explicitly accepts double parameters
  Widget _buildProgressIndicator(String label, double value, {bool isWeight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: isWeight ? (value / 100).clamp(0.0, 1.0) : (value / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          color: isWeight ?
          (value >= 100 ? Colors.green : Colors.blue) :
          (value >= 80 ? Colors.green : value >= 60 ? Colors.orange : Colors.red),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          isWeight ? '${value.toStringAsFixed(0)}%' : '${value.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ObjectiveStatus status) {
    Color color;
    String text;

    switch (status) {
      case ObjectiveStatus.NOT_STARTED:
        color = Colors.grey;
        text = 'Not Started';
        break;
      case ObjectiveStatus.IN_PROGRESS:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case ObjectiveStatus.ON_TRACK:
        color = Colors.green;
        text = 'On Track';
        break;
      case ObjectiveStatus.AT_RISK:
        color = Colors.orange;
        text = 'At Risk';
        break;
      case ObjectiveStatus.COMPLETED:
        color = Colors.green;
        text = 'Completed';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyObjectives() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Objectives Set',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No store objectives have been defined yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(ObjectiveStatus status, double progress) {
    switch (status) {
      case ObjectiveStatus.COMPLETED:
        return Colors.green;
      case ObjectiveStatus.ON_TRACK:
        return Colors.green;
      case ObjectiveStatus.AT_RISK:
        return Colors.orange;
      case ObjectiveStatus.IN_PROGRESS:
        return progress >= 50 ? Colors.blue : Colors.orange;
      case ObjectiveStatus.NOT_STARTED:
        return Colors.grey;
    }
  }

  void _updateObjectiveProgress(StoreObjective objective) {
    showDialog(
      context: context,
      builder: (context) => ObjectiveProgressDialog(
        objective: objective,
        onUpdate: (progress) {
          ref.read(storeManagerProvider.notifier).updateObjectiveProgress(
            objective.id,
            progress,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ObjectiveProgressDialog extends StatefulWidget {
  final StoreObjective objective;
  final Function(double) onUpdate;

  const ObjectiveProgressDialog({
    super.key,
    required this.objective,
    required this.onUpdate,
  });

  @override
  State<ObjectiveProgressDialog> createState() => _ObjectiveProgressDialogState();
}

class _ObjectiveProgressDialogState extends State<ObjectiveProgressDialog> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _progress = widget.objective.progress;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Objective Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.objective.objective,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          Text(
            'Current Progress: ${_progress.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 100,
            label: _progress.round().toString(),
            onChanged: (value) {
              setState(() => _progress = value);
            },
          ),

          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _progress / 100,
            backgroundColor: Colors.grey[200],
            color: _progress >= 100 ? Colors.green : Colors.blue,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_progress);
            Navigator.pop(context);
          },
          child: const Text('Update Progress'),
        ),
      ],
    );
  }
}