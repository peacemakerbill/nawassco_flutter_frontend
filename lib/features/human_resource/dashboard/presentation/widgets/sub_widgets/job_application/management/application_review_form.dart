import 'package:flutter/material.dart';
import '../../../../../../models/job_application_model.dart';

class ApplicationReviewForm extends StatefulWidget {
  final JobApplication application;
  final Function(ReviewHistory) onSubmit;
  final VoidCallback? onCancel;

  const ApplicationReviewForm({
    super.key,
    required this.application,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ApplicationReviewForm> createState() => _ApplicationReviewFormState();
}

class _ApplicationReviewFormState extends State<ApplicationReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _nextStepsController = TextEditingController();
  final _internalNotesController = TextEditingController();

  double _rating = 3.0;
  ReviewDecision _decision = ReviewDecision.HOLD;
  ApplicationStatus _status = ApplicationStatus.UNDER_REVIEW;

  @override
  void dispose() {
    _commentsController.dispose();
    _nextStepsController.dispose();
    _internalNotesController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (!_formKey.currentState!.validate()) return;

    final review = ReviewHistory(
      reviewedBy: 'HR Manager',
      // TODO: Get from auth
      reviewDate: DateTime.now(),
      stage: widget.application.currentStage,
      comments: _commentsController.text,
      rating: _rating,
      status: _status,
      decision: _decision,
      nextSteps: _nextStepsController.text.isNotEmpty
          ? _nextStepsController.text
          : null,
      internalNotes: _internalNotesController.text.isNotEmpty
          ? _internalNotesController.text
          : null,
    );

    widget.onSubmit(review);
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
                      Icons.rate_review,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Application',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.application.applicationNumber,
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

              // Rating Section
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
                        'Overall Rating',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _rating.toStringAsFixed(1),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < _rating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 36,
                                  color: colorScheme.primary,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() => _rating = value);
                        },
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Decision Section
              Text(
                'Review Decision',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReviewDecision.values.map((decision) {
                  final isSelected = _decision == decision;
                  return ChoiceChip(
                    label: Text(
                      decision.name
                          .split('_')
                          .map((word) =>
                              word[0].toUpperCase() + word.substring(1))
                          .join(' '),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _decision = decision);
                    },
                    selectedColor: _getDecisionColor(decision),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Status Section
              Text(
                'Update Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ApplicationStatus>(
                value: _status,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
                items: ApplicationStatus.values
                    .where((status) =>
                        status != ApplicationStatus.DRAFT &&
                        status != ApplicationStatus.ARCHIVED)
                    .map((status) {
                  final statusName = status.name.toLowerCase();
                  final displayName = statusName
                      .split('_')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' ');
                  return DropdownMenuItem(
                    value: status,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Comments
              Text(
                'Comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your review comments...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter review comments';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Next Steps
              Text(
                'Next Steps (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nextStepsController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'What are the next steps?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
              ),

              const SizedBox(height: 24),

              // Internal Notes
              Text(
                'Internal Notes (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _internalNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Internal notes not visible to applicant...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
              ),

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
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text('Submit Review'),
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

  Color _getDecisionColor(ReviewDecision decision) {
    switch (decision) {
      case ReviewDecision.PROCEED:
      case ReviewDecision.FAST_TRACK:
        return Colors.green;
      case ReviewDecision.REJECT:
        return Colors.red;
      case ReviewDecision.HOLD:
        return Colors.orange;
      case ReviewDecision.NEEDS_MORE_INFO:
        return Colors.blue;
    }
  }
}
