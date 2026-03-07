import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';

class InterviewScheduleForm extends StatefulWidget {
  final JobApplication application;
  final Function(InterviewDetails) onSubmit;
  final VoidCallback? onCancel;

  const InterviewScheduleForm({
    super.key,
    required this.application,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<InterviewScheduleForm> createState() => _InterviewScheduleFormState();
}

class _InterviewScheduleFormState extends State<InterviewScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _interviewersController = TextEditingController();
  final _commentsController = TextEditingController();
  final _candidateFeedbackController = TextEditingController();

  DateTime _interviewDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _interviewTime = const TimeOfDay(hour: 10, minute: 0);
  InterviewType _interviewType = InterviewType.VIDEO_INTERVIEW;
  Recommendation _recommendation = Recommendation.HIRE;

  double _overallScore = 70.0;
  double _technicalScore = 70.0;
  double _communicationScore = 70.0;
  double _culturalFitScore = 70.0;
  double _problemSolvingScore = 70.0;

  final List<String> _strengths = [];
  final List<String> _weaknesses = [];
  final _strengthController = TextEditingController();
  final _weaknessController = TextEditingController();

  bool _feedbackProvided = false;

  @override
  void dispose() {
    _interviewersController.dispose();
    _commentsController.dispose();
    _candidateFeedbackController.dispose();
    _strengthController.dispose();
    _weaknessController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _interviewDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _interviewDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _interviewTime,
    );
    if (picked != null) {
      setState(() => _interviewTime = picked);
    }
  }

  void _addStrength() {
    if (_strengthController.text.isNotEmpty) {
      setState(() {
        _strengths.add(_strengthController.text);
        _strengthController.clear();
      });
    }
  }

  void _addWeakness() {
    if (_weaknessController.text.isNotEmpty) {
      setState(() {
        _weaknesses.add(_weaknessController.text);
        _weaknessController.clear();
      });
    }
  }

  void _removeStrength(int index) {
    setState(() => _strengths.removeAt(index));
  }

  void _removeWeakness(int index) {
    setState(() => _weaknesses.removeAt(index));
  }

  void _submitInterview() {
    if (!_formKey.currentState!.validate()) return;

    final interviewDateTime = DateTime(
      _interviewDate.year,
      _interviewDate.month,
      _interviewDate.day,
      _interviewTime.hour,
      _interviewTime.minute,
    );

    final interviewDetails = InterviewDetails(
      interviewDate: interviewDateTime,
      interviewers: _interviewersController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      interviewType: _interviewType,
      stage: widget.application.currentStage + 1,
      overallScore: _overallScore,
      technicalScore: _technicalScore,
      communicationScore: _communicationScore,
      culturalFitScore: _culturalFitScore,
      problemSolvingScore: _problemSolvingScore,
      strengths: _strengths,
      weaknesses: _weaknesses,
      recommendation: _recommendation,
      comments: _commentsController.text,
      feedbackProvidedToCandidate: _feedbackProvided,
      candidateFeedback: _candidateFeedbackController.text.isNotEmpty
          ? _candidateFeedbackController.text
          : null,
    );

    widget.onSubmit(interviewDetails);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.calendar_today,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Interview',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.application.applicant.fullName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Interview Details Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interview Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => _selectDate(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    side: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_interviewDate.day}/${_interviewDate.month}/${_interviewDate.year}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => _selectTime(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    side: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _interviewTime.format(context),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Interview Type
                      Text(
                        'Interview Type',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<InterviewType>(
                        value: _interviewType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant
                              .withValues(alpha: 0.3),
                        ),
                        items: InterviewType.values.map((type) {
                          final typeName = type.name.toLowerCase();
                          final displayName = typeName
                              .split('_')
                              .map((word) =>
                          word[0].toUpperCase() + word.substring(1))
                              .join(' ');
                          return DropdownMenuItem(
                            value: type,
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _interviewType = value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Interviewers
                      Text(
                        'Interviewers (comma separated)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _interviewersController,
                        decoration: InputDecoration(
                          hintText: 'e.g., John Doe, Jane Smith',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant
                              .withValues(alpha: 0.3),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter at least one interviewer';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Assessment Scores
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Scores',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildScoreSlider(
                        'Overall Score',
                        _overallScore,
                            (value) => setState(() => _overallScore = value),
                      ),
                      const SizedBox(height: 12),

                      _buildScoreSlider(
                        'Technical Skills',
                        _technicalScore,
                            (value) => setState(() => _technicalScore = value),
                      ),
                      const SizedBox(height: 12),

                      _buildScoreSlider(
                        'Communication',
                        _communicationScore,
                            (value) => setState(() => _communicationScore = value),
                      ),
                      const SizedBox(height: 12),

                      _buildScoreSlider(
                        'Cultural Fit',
                        _culturalFitScore,
                            (value) => setState(() => _culturalFitScore = value),
                      ),
                      const SizedBox(height: 12),

                      _buildScoreSlider(
                        'Problem Solving',
                        _problemSolvingScore,
                            (value) => setState(() => _problemSolvingScore = value),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Strengths and Weaknesses
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Strengths',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _strengthController,
                          decoration: InputDecoration(
                            hintText: 'Add a strength...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addStrength,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                            colorScheme.surfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _strengths
                              .asMap()
                              .entries
                              .map((entry) => Chip(
                            label: Text(entry.value),
                            deleteIcon: const Icon(Icons.close,
                                size: 16),
                            onDeleted: () =>
                                _removeStrength(entry.key),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weaknesses',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _weaknessController,
                          decoration: InputDecoration(
                            hintText: 'Add an area for improvement...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addWeakness,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                            colorScheme.surfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _weaknesses
                              .asMap()
                              .entries
                              .map((entry) => Chip(
                            label: Text(entry.value),
                            deleteIcon: const Icon(Icons.close,
                                size: 16),
                            onDeleted: () =>
                                _removeWeakness(entry.key),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recommendation
              Text(
                'Recommendation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Recommendation>(
                value: _recommendation,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
                items: Recommendation.values.map((recommendation) {
                  final recName = recommendation.name.toLowerCase();
                  final displayName = recName
                      .split('_')
                      .map((word) =>
                  word[0].toUpperCase() + word.substring(1))
                      .join(' ');
                  return DropdownMenuItem(
                    value: recommendation,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recommendation = value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Comments
              Text(
                'Interview Comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your interview comments...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter interview comments';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Candidate Feedback
              SwitchListTile(
                title: Text(
                  'Provide Feedback to Candidate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _feedbackProvided,
                onChanged: (value) {
                  setState(() => _feedbackProvided = value);
                },
              ),
              if (_feedbackProvided) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _candidateFeedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Feedback for the candidate...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitInterview,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text('Schedule Interview'),
                        ],
                      ),
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

  Widget _buildScoreSlider(
      String label,
      double value,
      Function(double) onChanged,
      ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium,
            ),
            Text(
              '${value.toInt()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${value.toInt()}%',
          onChanged: onChanged,
          activeColor: _getScoreColor(value),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}