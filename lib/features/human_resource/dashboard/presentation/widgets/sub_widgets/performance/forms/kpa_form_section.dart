import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../models/performance/key_performance_area.model.dart';
import '../../../../../../providers/performance/appraisal_form_provider.dart';
import '../common_widgets/rating_stars.dart';

class KPAFormSection extends ConsumerStatefulWidget {
  final KeyPerformanceArea? initialKPA;
  final int? index;
  final bool isEditing;

  const KPAFormSection({
    super.key,
    this.initialKPA,
    this.index,
    this.isEditing = false,
  });

  @override
  ConsumerState<KPAFormSection> createState() => _KPAFormSectionState();
}

class _KPAFormSectionState extends ConsumerState<KPAFormSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _areaController;
  late TextEditingController _weightController;
  late TextEditingController _targetController;
  late TextEditingController _achievementController;
  late TextEditingController _commentsController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController(text: widget.initialKPA?.area ?? '');
    _weightController = TextEditingController(text: widget.initialKPA?.weight.toString() ?? '');
    _targetController = TextEditingController(text: widget.initialKPA?.target ?? '');
    _achievementController = TextEditingController(text: widget.initialKPA?.achievement ?? '');
    _commentsController = TextEditingController(text: widget.initialKPA?.comments ?? '');
    _rating = widget.initialKPA?.rating ?? 0.0;
  }

  @override
  void dispose() {
    _areaController.dispose();
    _weightController.dispose();
    _targetController.dispose();
    _achievementController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Edit KPA' : 'Add Key Performance Area',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteKPA,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Performance Area *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Sales Performance, Customer Service',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter performance area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (%) *',
                        border: OutlineInputBorder(),
                        hintText: '0-100',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 0 || weight > 100) {
                          return 'Weight must be between 0-100';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rating',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        EditableRatingStars(
                          initialRating: _rating,
                          onRatingChanged: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                          size: 32,
                          showLabel: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target *',
                  border: OutlineInputBorder(),
                  hintText: 'What was expected to be achieved',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _achievementController,
                decoration: const InputDecoration(
                  labelText: 'Achievement *',
                  border: OutlineInputBorder(),
                  hintText: 'What was actually achieved',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter achievement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: 'Comments',
                  border: OutlineInputBorder(),
                  hintText: 'Additional comments or observations',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveKPA,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.isEditing ? 'Update KPA' : 'Add KPA'),
                    ),
                  ),
                  if (!widget.isEditing) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _resetForm();
                          if (widget.isEditing && widget.index != null) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveKPA() {
    if (_formKey.currentState!.validate()) {
      final weight = double.tryParse(_weightController.text) ?? 0.0;

      final kpa = KeyPerformanceArea(
        area: _areaController.text.trim(),
        weight: weight,
        target: _targetController.text.trim(),
        achievement: _achievementController.text.trim(),
        rating: _rating,
        comments: _commentsController.text.trim(),
      );

      if (widget.isEditing && widget.index != null) {
        ref.read(appraisalFormProvider.notifier).updateKeyPerformanceArea(widget.index!, kpa);
      } else {
        ref.read(appraisalFormProvider.notifier).addKeyPerformanceArea(kpa);
      }

      _resetForm();

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KPA added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteKPA() {
    if (widget.isEditing && widget.index != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete KPA'),
          content: const Text('Are you sure you want to delete this key performance area?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(appraisalFormProvider.notifier).removeKeyPerformanceArea(widget.index!);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _areaController.clear();
    _weightController.clear();
    _targetController.clear();
    _achievementController.clear();
    _commentsController.clear();
    setState(() {
      _rating = 0.0;
    });
  }
}