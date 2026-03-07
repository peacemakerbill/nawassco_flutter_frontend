import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class EvaluationForm extends ConsumerStatefulWidget {
  final Training training;

  const EvaluationForm({super.key, required this.training});

  @override
  ConsumerState<EvaluationForm> createState() => _EvaluationFormState();
}

class _EvaluationFormState extends ConsumerState<EvaluationForm> {
  final List<EvaluationCriterionController> _criteriaControllers = [];
  final TextEditingController _overallFeedbackController = TextEditingController();
  double _overallRating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.training.evaluationCriteria.isNotEmpty) {
      for (final criterion in widget.training.evaluationCriteria) {
        _criteriaControllers.add(
          EvaluationCriterionController.fromCriterion(criterion),
        );
      }
      _overallRating = widget.training.averageRating;
    } else {
      // Add default criteria
      _criteriaControllers.addAll([
        EvaluationCriterionController(
          criterion: 'Content Quality',
          weight: 0.3,
          score: 0,
        ),
        EvaluationCriterionController(
          criterion: 'Trainer Effectiveness',
          weight: 0.3,
          score: 0,
        ),
        EvaluationCriterionController(
          criterion: 'Training Materials',
          weight: 0.2,
          score: 0,
        ),
        EvaluationCriterionController(
          criterion: 'Facilities & Logistics',
          weight: 0.2,
          score: 0,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _overallFeedbackController.dispose();
    for (final controller in _criteriaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = _criteriaControllers.fold<double>(
      0, (sum, controller) => sum + controller.weight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Evaluation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitEvaluation,
            tooltip: 'Save Evaluation',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.training.trainingTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trainer: ${widget.training.trainer}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Date: ${widget.training.formattedDate}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Criteria list
            const Text(
              'Evaluation Criteria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Weight: ${(totalWeight * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: totalWeight == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ..._criteriaControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return _buildCriterionCard(index, controller);
            }).toList(),

            const SizedBox(height: 16),

            // Add criterion button
            ElevatedButton.icon(
              onPressed: _addCriterion,
              icon: const Icon(Icons.add),
              label: const Text('Add Evaluation Criterion'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 32),

            // Overall rating
            const Text(
              'Overall Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          IconButton(
                            icon: Icon(
                              i <= _overallRating ? Icons.star : Icons.star_border,
                              size: 36,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() => _overallRating = i.toDouble());
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_overallRating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _overallFeedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Overall Feedback & Recommendations',
                        border: OutlineInputBorder(),
                        hintText: 'Enter overall feedback and recommendations for future improvements...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton.icon(
              onPressed: _submitEvaluation,
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('Submit Evaluation'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionCard(int index, EvaluationCriterionController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.criterionController,
                    decoration: const InputDecoration(
                      labelText: 'Criterion',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: controller.weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final weight = double.tryParse(value) ?? 0;
                      controller.weight = weight / 100;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Score slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: ${controller.score.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: controller.score,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: controller.score.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => controller.score = value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Poor', style: TextStyle(color: Colors.red)),
                    const Text('Average', style: TextStyle(color: Colors.orange)),
                    const Text('Excellent', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Comments
            TextFormField(
              controller: controller.commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_criteriaControllers.length > 1)
                  ElevatedButton.icon(
                    onPressed: () => _removeCriterion(index),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCriterion() {
    setState(() {
      _criteriaControllers.add(
        EvaluationCriterionController(
          criterion: 'New Criterion',
          weight: 0.1,
          score: 0,
        ),
      );
    });
  }

  void _removeCriterion(int index) {
    setState(() {
      _criteriaControllers.removeAt(index);
    });
  }

  Future<void> _submitEvaluation() async {
    final totalWeight = _criteriaControllers.fold<double>(
      0, (sum, controller) => sum + controller.weight,
    );

    if (totalWeight != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total weight must equal 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final criteria = _criteriaControllers.map((controller) {
      return {
        'criterion': controller.criterionController.text,
        'weight': controller.weight,
        'averageScore': controller.score * 20, // Convert to percentage
      };
    }).toList();

    final success = await ref.read(trainingProvider.notifier).evaluateTraining(
      widget.training.id,
      criteria,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Training evaluation submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class EvaluationCriterionController {
  final TextEditingController criterionController;
  final TextEditingController weightController;
  final TextEditingController commentsController;
  double weight;
  double score;

  EvaluationCriterionController({
    required String criterion,
    required double weight,
    required double score,
    String comments = '',
  })  : criterionController = TextEditingController(text: criterion),
        weightController = TextEditingController(text: (weight * 100).toStringAsFixed(0)),
        commentsController = TextEditingController(text: comments),
        weight = weight,
        score = score;

  factory EvaluationCriterionController.fromCriterion(EvaluationCriterion criterion) {
    return EvaluationCriterionController(
      criterion: criterion.criterion,
      weight: criterion.weight,
      score: criterion.averageScore / 20, // Convert from percentage to 0-5 scale
    );
  }

  void dispose() {
    criterionController.dispose();
    weightController.dispose();
    commentsController.dispose();
  }
}