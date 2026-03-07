import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../models/job_application_model.dart';
import '../../../../../../providers/applicant_provider.dart';
import '../../../../../../providers/job_application_provider.dart';

class ApplyJobForm extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const ApplyJobForm({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<ApplyJobForm> createState() => _ApplyJobFormState();
}

class _ApplyJobFormState extends ConsumerState<ApplyJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _messageController = TextEditingController();

  ApplicationSource _applicationSource = ApplicationSource.COMPANY_WEBSITE;
  List<ApplicationDocument> _selectedDocuments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadApplicantDocuments();
  }

  void _loadApplicantDocuments() {
    final applicantState = ref.read(applicantProvider);
    final applicant = applicantState.applicant;

    if (applicant != null && applicant.documents.isNotEmpty) {
      // Convert applicant documents to application documents
      _selectedDocuments = applicant.documents
          .where((doc) => doc.type == 'resume' || doc.type == 'cover_letter')
          .map((doc) => ApplicationDocument(
        name: doc.name,
        type: doc.type,
        url: doc.url,
        uploadDate: doc.uploadDate,
        fileSize: doc.fileSize,
        description: doc.description,
        isPrimary: doc.isPrimary,
      ))
          .toList();
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(jobApplicationProvider.notifier).applyForJob(
      jobId: widget.jobId,
      customCoverLetter: _coverLetterController.text.isNotEmpty
          ? _coverLetterController.text
          : null,
      customMessage: _messageController.text.isNotEmpty
          ? _messageController.text
          : null,
      selectedDocuments: _selectedDocuments,
      applicationSource: _applicationSource,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applicantState = ref.watch(applicantProvider);
    final applicant = applicantState.applicant;

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
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Apply for ${widget.jobTitle}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please review your information and submit your application',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Applicant Information Summary
              if (applicant != null) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              theme.colorScheme.primaryContainer,
                              child: Text(
                                applicant.fullName
                                    .split(' ')
                                    .map((n) => n.isNotEmpty ? n[0] : '')
                                    .join()
                                    .toUpperCase()
                                    .substring(0, 2),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    applicant.fullName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    applicant.email,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  if (applicant.currentPosition != null)
                                    Text(
                                      applicant.currentPosition!,
                                      style:
                                      theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Application Source
              Text(
                'How did you hear about this job?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ApplicationSource>(
                value: _applicationSource,
                decoration: InputDecoration(
                  labelText: 'Application Source',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
                items: ApplicationSource.values.map((source) {
                  final sourceName = source.name.toLowerCase();
                  final displayName = sourceName
                      .split('_')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' ');
                  return DropdownMenuItem(
                    value: source,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _applicationSource = value);
                  }
                },
                validator: (value) =>
                value == null ? 'Please select an application source' : null,
              ),

              const SizedBox(height: 24),

              // Custom Cover Letter
              Text(
                'Custom Cover Letter (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coverLetterController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                  'Tell us why you\'re interested in this position...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
              ),

              const SizedBox(height: 24),

              // Custom Message
              Text(
                'Additional Message (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional information you\'d like to share...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                ),
              ),

              const SizedBox(height: 24),

              // Documents Section
              Text(
                'Selected Documents',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedDocuments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No documents selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your resume and other documents from your applicant profile will be used',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _selectedDocuments.map((doc) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.1),
                      child: ListTile(
                        leading: Icon(
                          _getDocumentIcon(doc.type),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          doc.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          '${(doc.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        trailing: doc.isPrimary
                            ? Chip(
                          label: const Text('Primary'),
                          backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        )
                            : null,
                      ),
                    );
                  }).toList(),
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
                      onPressed: _isSubmitting ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text('Submit Application'),
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

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'resume':
        return Icons.description;
      case 'cover_letter':
        return Icons.mail_outline;
      case 'portfolio':
        return Icons.folder_open;
      case 'certificate':
        return Icons.verified;
      case 'transcript':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }
}