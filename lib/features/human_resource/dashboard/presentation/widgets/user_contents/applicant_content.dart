import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/applicant/applicant_model.dart';
import '../../../../providers/applicant_provider.dart';
import '../sub_widgets/applicant/dialogs/confirmation_dialog.dart';
import '../sub_widgets/applicant/documents/documents_list_widget.dart';
import '../sub_widgets/applicant/education/education_list_widget.dart';
import '../sub_widgets/applicant/experience/experience_list_widget.dart';
import '../sub_widgets/applicant/forms/certification_form.dart';
import '../sub_widgets/applicant/forms/education_form.dart';
import '../sub_widgets/applicant/forms/job_preferences_form.dart';
import '../sub_widgets/applicant/forms/language_form.dart';
import '../sub_widgets/applicant/forms/personal_info_form.dart';
import '../sub_widgets/applicant/forms/portfolio_form.dart';
import '../sub_widgets/applicant/forms/skill_form.dart';
import '../sub_widgets/applicant/forms/work_experience_form.dart';
import '../sub_widgets/applicant/preferences/job_preferences_widget.dart';
import '../sub_widgets/applicant/profile/applicant_profile_header.dart';
import '../sub_widgets/applicant/profile/applicant_stats_card.dart';
import '../sub_widgets/applicant/profile/personal_info_widget.dart';
import '../sub_widgets/applicant/profile/profile_completion_widget.dart';
import '../sub_widgets/applicant/skills/skills_grid_widget.dart';

class ApplicantContent extends ConsumerStatefulWidget {
  const ApplicantContent({super.key});

  @override
  ConsumerState<ApplicantContent> createState() => _ApplicantContentState();
}

class _ApplicantContentState extends ConsumerState<ApplicantContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    // Load applicant profile when content initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(applicantProvider.notifier).loadApplicantProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    await ref.read(applicantProvider.notifier).loadApplicantProfile();
  }

  void _showAddDialog(Widget content, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Note: The form submission is handled within each form widget
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Widget content, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Note: The form submission is handled within each form widget
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument() async {
    // Show dialog to select document type
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Select document type:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'resume'),
            child: const Text('Resume'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'cover_letter'),
            child: const Text('Cover Letter'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'other'),
            child: const Text('Other Document'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Use FilePicker to select file
      final picker = FilePicker.platform;
      final fileResult = await picker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (fileResult != null && fileResult.files.isNotEmpty) {
        final platformFile = fileResult.files.first;
        final file = File(platformFile.path!);

        // Get file size in KB or MB
        final fileSize = await file.length();
        String fileSizeText;
        if (fileSize > 1024 * 1024) {
          fileSizeText = '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
        } else {
          fileSizeText = '${(fileSize / 1024).toStringAsFixed(2)} KB';
        }

        // Show confirmation dialog
        final shouldUpload = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Upload'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: ${platformFile.name}'),
                Text('Size: $fileSizeText'),
                Text('Type: ${platformFile.extension ?? 'Unknown'}'),
                const SizedBox(height: 16),
                const Text('Do you want to upload this document?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Upload'),
              ),
            ],
          ),
        );

        if (shouldUpload == true) {
          // Upload the document
          try {
            // Read file as bytes
            final bytes = await file.readAsBytes();

            // Call provider to upload document
            await ref.read(applicantProvider.notifier).uploadDocument(
              name: platformFile.name,
              fileBytes: bytes,
              fileType: result,
              fileExtension: platformFile.extension ?? '',
            );
          } catch (e) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload document: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildQuickActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, DateTime date, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(_formatActivityDate(date)),
      trailing: Text(
        _getTimeAgo(date),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _formatActivityDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ApplicantState state, ApplicantModel? applicant) {
    if (state.isLoading && applicant == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (applicant == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Profile Found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your applicant profile to start applying for jobs',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(applicantProvider.notifier).loadApplicantProfile();
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Completion
            ProfileCompletionWidget(completion: applicant.profileCompletion),

            const SizedBox(height: 16),

            // Stats Card
            ApplicantStatsCard(applicant: applicant),

            const SizedBox(height: 16),

            // Personal Information Widget
            PersonalInfoWidget(
              applicant: applicant,
              onEdit: () {
                _showEditDialog(
                  PersonalInfoForm(
                    applicant: applicant,
                    onSubmit: (data) {
                      ref.read(applicantProvider.notifier).updatePersonalInfo(
                        firstName: data['firstName']!,
                        lastName: data['lastName']!,
                        dateOfBirth: data['dateOfBirth'],
                        gender: data['gender'],
                        nationality: data['nationality'],
                        phoneNumber: data['phoneNumber']!,
                        address: data['address']!,
                        city: data['city']!,
                        country: data['country']!,
                        postalCode: data['postalCode'],
                        headline: data['headline'],
                        summary: data['summary'],
                      );
                    },
                  ),
                  'Edit Personal Information',
                );
              },
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildQuickActionButton(
                          Icons.school,
                          'Add Education',
                              () {
                            _showAddDialog(
                              EducationForm(
                                onSubmit: (education) {
                                  ref
                                      .read(applicantProvider.notifier)
                                      .addEducation(education);
                                },
                              ),
                              'Add Education',
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          Icons.work,
                          'Add Experience',
                              () {
                            _showAddDialog(
                              WorkExperienceForm(
                                onSubmit: (experience) {
                                  ref
                                      .read(applicantProvider.notifier)
                                      .addWorkExperience(experience);
                                },
                              ),
                              'Add Work Experience',
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          Icons.star,
                          'Add Skill',
                              () {
                            _showAddDialog(
                              SkillForm(
                                onSubmit: (skill) {
                                  ref
                                      .read(applicantProvider.notifier)
                                      .addSkill(skill);
                                },
                              ),
                              'Add Skill',
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          Icons.language,
                          'Add Language',
                              () {
                            _showAddDialog(
                              LanguageForm(
                                onSubmit: (language) {
                                  // Language CRUD would be added to provider
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Language functionality coming soon')),
                                  );
                                },
                              ),
                              'Add Language',
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          Icons.verified,
                          'Add Certification',
                              () {
                            _showAddDialog(
                              CertificationForm(
                                onSubmit: (certification) {
                                  // Certification CRUD would be added to provider
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Certification functionality coming soon')),
                                  );
                                },
                              ),
                              'Add Certification',
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          Icons.link,
                          'Add Portfolio',
                              () {
                            _showAddDialog(
                              PortfolioForm(
                                onSubmit: (portfolio) {
                                  // Portfolio CRUD would be added to provider
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Portfolio functionality coming soon')),
                                  );
                                },
                              ),
                              'Add Portfolio Link',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recent Activity
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityItem(
                      'Profile Updated',
                      applicant.lastProfileUpdate,
                      Icons.update,
                    ),
                    if (applicant.lastLoginAt != null)
                      _buildActivityItem(
                        'Last Login',
                        applicant.lastLoginAt!,
                        Icons.login,
                      ),
                    if (applicant.lastSyncedWithUser != null)
                      _buildActivityItem(
                        'Last Synced',
                        applicant.lastSyncedWithUser!,
                        Icons.sync,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Salary Information
            if (applicant.currentSalary != null ||
                applicant.expectedSalary != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Salary Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      if (applicant.currentSalary != null) ...[
                        _buildInfoRow(
                          'Current Salary',
                          '${applicant.currentSalary!.amount} ${applicant.currentSalary!.currency}/${applicant.currentSalary!.payPeriod}',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (applicant.expectedSalary != null) ...[
                        _buildInfoRow(
                          'Expected Salary',
                          '${applicant.expectedSalary!.min} - ${applicant.expectedSalary!.max} ${applicant.expectedSalary!.currency}',
                        ),
                        if (applicant.expectedSalary!.isNegotiable)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Negotiable',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Notice Period
            if (applicant.noticePeriod != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Availability',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Notice Period',
                        '${applicant.noticePeriod} days',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTab(ApplicantState state, ApplicantModel? applicant) {
    return EducationListWidget(
      education: applicant?.education ?? [],
      isLoading: state.isLoading,
      onAdd: () {
        _showAddDialog(
          EducationForm(
            onSubmit: (education) {
              ref.read(applicantProvider.notifier).addEducation(education);
            },
          ),
          'Add Education',
        );
      },
      onEdit: (education) {
        _showEditDialog(
          EducationForm(
            education: education,
            onSubmit: (updatedEducation) {
              if (education.id != null) {
                ref
                    .read(applicantProvider.notifier)
                    .updateEducation(education.id!, updatedEducation);
              }
            },
          ),
          'Edit Education',
        );
      },
      onDelete: (education) {
        if (education.id != null) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete Education',
              content:
              'Are you sure you want to delete this education entry? This action cannot be undone.',
              onConfirm: () {
                Navigator.pop(context);
                ref
                    .read(applicantProvider.notifier)
                    .deleteEducation(education.id!);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }
      },
    );
  }

  Widget _buildExperienceTab(ApplicantState state, ApplicantModel? applicant) {
    return ExperienceListWidget(
      experiences: applicant?.workExperience ?? [],
      isLoading: state.isLoading,
      onAdd: () {
        _showAddDialog(
          WorkExperienceForm(
            onSubmit: (experience) {
              ref.read(applicantProvider.notifier).addWorkExperience(experience);
            },
          ),
          'Add Work Experience',
        );
      },
      onEdit: (experience) {
        _showEditDialog(
          WorkExperienceForm(
            experience: experience,
            onSubmit: (updatedExperience) {
              if (experience.id != null) {
                ref
                    .read(applicantProvider.notifier)
                    .updateWorkExperience(
                    experience.id!, updatedExperience);
              }
            },
          ),
          'Edit Work Experience',
        );
      },
      onDelete: (experience) {
        if (experience.id != null) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete Work Experience',
              content:
              'Are you sure you want to delete this work experience entry? This action cannot be undone.',
              onConfirm: () {
                Navigator.pop(context);
                ref
                    .read(applicantProvider.notifier)
                    .deleteWorkExperience(experience.id!);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }
      },
    );
  }

  Widget _buildSkillsTab(ApplicantState state, ApplicantModel? applicant) {
    return SkillsGridWidget(
      skills: applicant?.skills ?? [],
      isLoading: state.isLoading,
      onAdd: () {
        _showAddDialog(
          SkillForm(
            onSubmit: (skill) {
              ref.read(applicantProvider.notifier).addSkill(skill);
            },
          ),
          'Add Skill',
        );
      },
      onEdit: (skill) {
        _showEditDialog(
          SkillForm(
            skill: skill,
            onSubmit: (updatedSkill) {
              if (skill.id != null) {
                ref
                    .read(applicantProvider.notifier)
                    .updateSkill(skill.id!, updatedSkill);
              }
            },
          ),
          'Edit Skill',
        );
      },
      onDelete: (skill) {
        if (skill.id != null) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete Skill',
              content:
              'Are you sure you want to delete this skill? This action cannot be undone.',
              onConfirm: () {
                Navigator.pop(context);
                ref.read(applicantProvider.notifier).deleteSkill(skill.id!);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }
      },
    );
  }

  Widget _buildDocumentsTab(ApplicantState state, ApplicantModel? applicant) {
    return DocumentsListWidget(
      documents: applicant?.documents ?? [],
      isLoading: state.isLoading,
      onUpload: _uploadDocument,
      onDelete: (document) {
        if (document.id != null) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete Document',
              content:
              'Are you sure you want to delete this document? This action cannot be undone.',
              onConfirm: () {
                Navigator.pop(context);
                ref.read(applicantProvider.notifier).deleteDocument(document.id!);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }
      },
    );
  }

  Widget _buildPreferencesTab(ApplicantState state, ApplicantModel? applicant) {
    return JobPreferencesWidget(
      preferences: applicant?.jobPreferences,
      isLoading: state.isLoading,
      onEdit: () {
        _showEditDialog(
          JobPreferencesForm(
            preferences: applicant?.jobPreferences,
            onSubmit: (preferences) {
              ref.read(applicantProvider.notifier).updateJobPreferences(preferences);
            },
          ),
          'Edit Job Preferences',
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    final currentIndex = _tabController.index;

    if (currentIndex == 0) {
      // Overview tab - No FAB needed
      return null;
    }

    return FloatingActionButton(
      onPressed: () {
        final applicant = ref.read(applicantProvider).applicant;
        switch (currentIndex) {
          case 1: // Education
            _showAddDialog(
              EducationForm(
                onSubmit: (education) {
                  ref.read(applicantProvider.notifier).addEducation(education);
                },
              ),
              'Add Education',
            );
            break;
          case 2: // Experience
            _showAddDialog(
              WorkExperienceForm(
                onSubmit: (experience) {
                  ref.read(applicantProvider.notifier).addWorkExperience(experience);
                },
              ),
              'Add Work Experience',
            );
            break;
          case 3: // Skills
            _showAddDialog(
              SkillForm(
                onSubmit: (skill) {
                  ref.read(applicantProvider.notifier).addSkill(skill);
                },
              ),
              'Add Skill',
            );
            break;
          case 4: // Documents
            _uploadDocument();
            break;
          case 5: // Preferences
            _showEditDialog(
              JobPreferencesForm(
                preferences: applicant?.jobPreferences,
                onSubmit: (preferences) {
                  ref.read(applicantProvider.notifier).updateJobPreferences(preferences);
                },
              ),
              'Edit Job Preferences',
            );
            break;
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicantState = ref.watch(applicantProvider);
    final applicant = applicantState.applicant;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: applicant != null
                    ? ApplicantProfileHeader(applicant: applicant)
                    : Container(
                  color: Theme.of(context).primaryColor,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
              actions: [
                if (applicant != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshProfile,
                    tooltip: 'Refresh Profile',
                  ),
                if (applicant != null)
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () {
                      ref.read(applicantProvider.notifier).syncWithUser();
                    },
                    tooltip: 'Sync with User Profile',
                  ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                      Tab(text: 'Education', icon: Icon(Icons.school)),
                      Tab(text: 'Experience', icon: Icon(Icons.work)),
                      Tab(text: 'Skills', icon: Icon(Icons.star)),
                      Tab(text: 'Documents', icon: Icon(Icons.folder)),
                      Tab(text: 'Preferences', icon: Icon(Icons.settings)),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            _buildOverviewTab(applicantState, applicant),

            // Education Tab
            _buildEducationTab(applicantState, applicant),

            // Experience Tab
            _buildExperienceTab(applicantState, applicant),

            // Skills Tab
            _buildSkillsTab(applicantState, applicant),

            // Documents Tab
            _buildDocumentsTab(applicantState, applicant),

            // Preferences Tab
            _buildPreferencesTab(applicantState, applicant),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}