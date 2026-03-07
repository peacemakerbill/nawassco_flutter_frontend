import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../models/performance/competency_assessment.model.dart';
import '../../../../../../providers/performance/appraisal_form_provider.dart';
import '../common_widgets/rating_stars.dart';

class CompetencyFormSection extends ConsumerStatefulWidget {
  final CompetencyAssessment? initialCompetency;
  final int? index;
  final bool isEditing;

  const CompetencyFormSection({
    super.key,
    this.initialCompetency,
    this.index,
    this.isEditing = false,
  });

  @override
  ConsumerState<CompetencyFormSection> createState() => _CompetencyFormSectionState();
}

class _CompetencyFormSectionState extends ConsumerState<CompetencyFormSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _competencyController;
  late TextEditingController _descriptionController;
  late double _rating;
  final List<String> _examples = [];
  final TextEditingController _exampleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _competencyController = TextEditingController(text: widget.initialCompetency?.competency ?? '');
    _descriptionController = TextEditingController(text: widget.initialCompetency?.description ?? '');
    _rating = widget.initialCompetency?.rating ?? 0.0;
    _examples.addAll(widget.initialCompetency?.examples ?? []);
  }

  @override
  void dispose() {
    _competencyController.dispose();
    _descriptionController.dispose();
    _exampleController.dispose();
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
                    widget.isEditing ? 'Edit Competency' : 'Add Competency',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteCompetency,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _competencyController,
                decoration: const InputDecoration(
                  labelText: 'Competency Name *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Communication, Leadership, Problem Solving',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter competency name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the competency',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
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
              const SizedBox(height: 16),
              _buildExamplesSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCompetency,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.isEditing ? 'Update Competency' : 'Add Competency'),
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

  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Examples',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_examples.isNotEmpty)
          Column(
            children: _examples.asMap().entries.map((entry) {
              final index = entry.key;
              final example = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(example),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _examples.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Add Example',
                  border: OutlineInputBorder(),
                  hintText: 'Enter an example of this competency',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {
                if (_exampleController.text.trim().isNotEmpty) {
                  setState(() {
                    _examples.add(_exampleController.text.trim());
                    _exampleController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _saveCompetency() {
    if (_formKey.currentState!.validate()) {
      final competency = CompetencyAssessment(
        competency: _competencyController.text.trim(),
        description: _descriptionController.text.trim(),
        rating: _rating,
        examples: List.from(_examples),
      );

      if (widget.isEditing && widget.index != null) {
        ref.read(appraisalFormProvider.notifier).updateCompetency(widget.index!, competency);
      } else {
        ref.read(appraisalFormProvider.notifier).addCompetency(competency);
      }

      _resetForm();

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Competency added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteCompetency() {
    if (widget.isEditing && widget.index != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Competency'),
          content: const Text('Are you sure you want to delete this competency?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(appraisalFormProvider.notifier).removeCompetency(widget.index!);
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
    _competencyController.clear();
    _descriptionController.clear();
    _exampleController.clear();
    setState(() {
      _rating = 0.0;
      _examples.clear();
    });
  }
}