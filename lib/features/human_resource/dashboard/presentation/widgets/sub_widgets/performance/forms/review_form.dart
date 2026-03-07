import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../../core/utils/toast_utils.dart';
import '../../../../../../models/performance/performance_appraisal.model.dart';
import '../../../../../../providers/performance/performance_provider.dart';

class ReviewForm extends ConsumerStatefulWidget {
  final PerformanceAppraisal appraisal;
  final VoidCallback onSubmitted;

  const ReviewForm({
    super.key,
    required this.appraisal,
    required this.onSubmitted,
  });

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _developmentAreasController =
      TextEditingController();
  final TextEditingController _reviewerCommentsController =
      TextEditingController();
  final List<String> _strengths = [];
  final List<String> _developmentAreas = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _strengths.addAll(widget.appraisal.strengths);
    _developmentAreas.addAll(widget.appraisal.developmentAreas);
    _reviewerCommentsController.text = widget.appraisal.reviewerComments;
  }

  @override
  void dispose() {
    _strengthsController.dispose();
    _developmentAreasController.dispose();
    _reviewerCommentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performanceState = ref.watch(performanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review: ${widget.appraisal.employeeName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForReview,
            tooltip: 'Submit for Review',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appraisal Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appraisal Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.appraisal.employeeName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  widget.appraisal.appraisalPeriod,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.appraisal.status.color
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: widget.appraisal.status.color),
                            ),
                            child: Text(
                              widget.appraisal.status.displayName,
                              style: TextStyle(
                                color: widget.appraisal.status.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Strengths
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Strengths',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildListSection(
                        'Add Strength',
                        _strengthsController,
                        _strengths,
                        _addStrength,
                        _removeStrength,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Development Areas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Areas for Development',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildListSection(
                        'Add Development Area',
                        _developmentAreasController,
                        _developmentAreas,
                        _addDevelopmentArea,
                        _removeDevelopmentArea,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reviewer Comments
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviewer Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reviewerCommentsController,
                        decoration: const InputDecoration(
                          hintText:
                              'Enter your overall feedback and comments...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter reviewer comments';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDraft,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: performanceState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Submit for Review'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(
    String label,
    TextEditingController controller,
    List<String> items,
    VoidCallback onAdd,
    Function(int) onRemove, {
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: color.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        color == Colors.green
                            ? Icons.check_circle
                            : Icons.warning,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.grey),
                        onPressed: () => onRemove(index),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: label,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: color),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  void _addStrength() {
    if (_strengthsController.text.trim().isNotEmpty) {
      setState(() {
        _strengths.add(_strengthsController.text.trim());
        _strengthsController.clear();
      });
    }
  }

  void _removeStrength(int index) {
    setState(() {
      _strengths.removeAt(index);
    });
  }

  void _addDevelopmentArea() {
    if (_developmentAreasController.text.trim().isNotEmpty) {
      setState(() {
        _developmentAreas.add(_developmentAreasController.text.trim());
        _developmentAreasController.clear();
      });
    }
  }

  void _removeDevelopmentArea(int index) {
    setState(() {
      _developmentAreas.removeAt(index);
    });
  }

  Future<void> _saveDraft() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'strengths': _strengths,
          'developmentAreas': _developmentAreas,
          'reviewerComments': _reviewerCommentsController.text.trim(),
        };

        await ref.read(performanceProvider.notifier).updateAppraisal(
              widget.appraisal.id,
              data,
            );

        ToastUtils.showSuccessToast('Draft saved successfully');
      } catch (e) {
        ToastUtils.showErrorToast('Failed to save draft: $e');
      }
    }
  }

  Future<void> _submitForReview() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'strengths': _strengths,
          'developmentAreas': _developmentAreas,
          'reviewerComments': _reviewerCommentsController.text.trim(),
        };

        // First update the appraisal
        await ref.read(performanceProvider.notifier).updateAppraisal(
              widget.appraisal.id,
              data,
            );

        // Then submit for review
        await ref
            .read(performanceProvider.notifier)
            .submitForReview(widget.appraisal.id);

        ToastUtils.showSuccessToast('Submitted for review successfully');
        widget.onSubmitted();
      } catch (e) {
        ToastUtils.showErrorToast('Failed to submit for review: $e');
      }
    }
  }
}
