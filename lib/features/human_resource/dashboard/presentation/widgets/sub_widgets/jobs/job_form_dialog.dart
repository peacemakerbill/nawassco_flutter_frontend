import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/job_model.dart';
import '../../../../../providers/job_providers.dart';
import 'education_requirement_input.dart';
import 'experience_requirement_input.dart';
import 'recruitment_stage_input.dart';
import 'salary_range_input.dart';
import 'skill_input_widget.dart';

class JobFormDialog extends ConsumerStatefulWidget {
  final Job? initialJob;

  const JobFormDialog({super.key, this.initialJob});

  @override
  ConsumerState<JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends ConsumerState<JobFormDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _departmentController;
  late TextEditingController _deadlineController;
  late TextEditingController _startDateController;

  // Lists
  List<String> _requirements = [];
  List<String> _responsibilities = [];
  List<String> _benefits = [];
  List<String> _preferredQualifications = [];
  SalaryRange _salaryRange = const SalaryRange(min: 0, max: 0);
  List<EducationRequirement> _educationRequirements = [];
  ExperienceRequirement _experienceRequirement = ExperienceRequirement(
    years: 0,
    level: ExperienceLevel.ENTRY,
  );
  List<SkillRequirement> _skillRequirements = [];
  List<RecruitmentStage> _recruitmentStages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Initialize controllers
    _titleController = TextEditingController(
      text: widget.initialJob?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialJob?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialJob?.location ?? '',
    );
    _departmentController = TextEditingController(
      text: widget.initialJob?.department ?? '',
    );
    _deadlineController = TextEditingController(
      text: widget.initialJob?.applicationDeadline != null
          ? DateFormat('yyyy-MM-dd')
              .format(widget.initialJob!.applicationDeadline)
          : '',
    );
    _startDateController = TextEditingController(
      text: widget.initialJob?.startDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.initialJob!.startDate)
          : '',
    );

    // Initialize lists from initial job
    if (widget.initialJob != null) {
      _requirements = List.from(widget.initialJob!.requirements);
      _responsibilities = List.from(widget.initialJob!.responsibilities);
      _benefits = List.from(widget.initialJob!.benefits);
      _preferredQualifications =
          List.from(widget.initialJob!.preferredQualifications);
      _salaryRange = widget.initialJob!.salaryRange;
      _educationRequirements = List.from(widget.initialJob!.requiredEducation);
      _experienceRequirement = widget.initialJob!.requiredExperience;
      _skillRequirements = List.from(widget.initialJob!.requiredSkills);
      _recruitmentStages = List.from(widget.initialJob!.recruitmentStages);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _deadlineController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addRequirement() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Requirement'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter job requirement...',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _requirements.add(value.trim());
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _requirements.add(value);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addResponsibility() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Responsibility'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter job responsibility...',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _responsibilities.add(value.trim());
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _responsibilities.add(value);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addBenefit() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Benefit'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter job benefit...',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _benefits.add(value.trim());
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _benefits.add(value);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPreferredQualification() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Preferred Qualification'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter preferred qualification...',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _preferredQualifications.add(value.trim());
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _preferredQualifications.add(value);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Prepare form data
      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirements,
        'responsibilities': _responsibilities,
        'jobType': JobType.FULL_TIME.name,
        // Will be set from dropdown
        'positionType': PositionType.ENTRY_LEVEL.name,
        // Will be set from dropdown
        'department': _departmentController.text.trim(),
        'location': _locationController.text.trim(),
        'workMode': WorkMode.ONSITE.name,
        // Will be set from dropdown
        'salaryRange': _salaryRange.toJson(),
        'benefits': _benefits,
        'additionalCompensation': [],
        'applicationDeadline': _deadlineController.text,
        'startDate': _startDateController.text,
        'duration': null,
        'isRemoteFriendly': false,
        // Will be set from checkbox
        'visaSponsorshipAvailable': false,
        // Will be set from checkbox
        'requiredEducation':
            _educationRequirements.map((e) => e.toJson()).toList(),
        'requiredExperience': _experienceRequirement.toJson(),
        'requiredSkills': _skillRequirements.map((e) => e.toJson()).toList(),
        'preferredQualifications': _preferredQualifications,
        'recruitmentStages': _recruitmentStages.map((e) => e.toJson()).toList(),
        'hiringManager': '',
        // Will be set from dropdown
        'recruiters': [],
        'isPublished': false,
        'numberOfOpenings': 1,
        // Will be set from input
        'isInternship': false,
        // Will be set from job type
        'isAttachment': false,
        // Will be set from job type
        ..._formData,
      };

      // Get job provider using ref
      final jobProviderNotifier =
          ref.read(jobProvider.notifier); // Changed variable name

      if (widget.initialJob != null) {
        jobProviderNotifier.updateJob(widget.initialJob!.id, jobData);
      } else {
        jobProviderNotifier.createJob(jobData);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.initialJob != null ? 'Edit Job' : 'Create New Job',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Basic Info'),
                Tab(text: 'Details'),
                Tab(text: 'Requirements'),
                Tab(text: 'Benefits'),
                Tab(text: 'Recruitment'),
                Tab(text: 'Review'),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildDetailsTab(),
                _buildRequirementsTab(),
                _buildBenefitsTab(),
                _buildRecruitmentTab(),
                _buildReviewTab(),
              ],
            ),
          ),
          persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_tabController.index > 0)
                  OutlinedButton(
                    onPressed: () {
                      _tabController.index--;
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text('Previous'),
                      ],
                    ),
                  )
                else
                  const SizedBox(),
                if (_tabController.index < 5)
                  ElevatedButton(
                    onPressed: () {
                      _tabController.index++;
                    },
                    child: const Row(
                      children: [
                        Text('Next'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: Row(
                      children: [
                        const Icon(Icons.save),
                        const SizedBox(width: 8),
                        Text(widget.initialJob != null
                            ? 'Update Job'
                            : 'Create Job'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Job Title*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a job title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _departmentController,
            decoration: const InputDecoration(
              labelText: 'Department*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a department';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Job Description*',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a job description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Application Deadline*',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () =>
                          _selectDate(context, _deadlineController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a deadline';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date*',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.date_range),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () =>
                          _selectDate(context, _startDateController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Number of Openings*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
            initialValue: widget.initialJob?.numberOfOpenings.toString() ?? '1',
            validator: (value) {
              if (value == null ||
                  int.tryParse(value) == null ||
                  int.parse(value) < 1) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _formData['numberOfOpenings'] = int.parse(value ?? '1');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Type
          const Text(
            'Job Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<JobType>(
            value: widget.initialJob?.jobType ?? JobType.FULL_TIME,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select Job Type',
            ),
            items: JobType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              _formData['jobType'] = value?.name;
              if (value == JobType.INTERNSHIP) {
                _formData['isInternship'] = true;
              } else if (value == JobType.ATTACHMENT) {
                _formData['isAttachment'] = true;
              }
            },
          ),
          const SizedBox(height: 16),

          // Position Type
          const Text(
            'Position Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PositionType>(
            value: widget.initialJob?.positionType ?? PositionType.ENTRY_LEVEL,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select Position Type',
            ),
            items: PositionType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              _formData['positionType'] = value?.name;
            },
          ),
          const SizedBox(height: 16),

          // Work Mode
          const Text(
            'Work Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<WorkMode>(
            value: widget.initialJob?.workMode ?? WorkMode.ONSITE,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select Work Mode',
            ),
            items: WorkMode.values
                .map((mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              _formData['workMode'] = value?.name;
            },
          ),
          const SizedBox(height: 16),

          // Salary Range
          const Text(
            'Salary Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SalaryRangeInput(
            initialRange: _salaryRange,
            onChanged: (range) {
              _salaryRange = range;
            },
          ),
          const SizedBox(height: 16),

          // Checkboxes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: const Text('Remote Friendly'),
                value: widget.initialJob?.isRemoteFriendly ?? false,
                onChanged: (value) {
                  _formData['isRemoteFriendly'] = value;
                },
              ),
              CheckboxListTile(
                title: const Text('Visa Sponsorship Available'),
                value: widget.initialJob?.visaSponsorshipAvailable ?? false,
                onChanged: (value) {
                  _formData['visaSponsorshipAvailable'] = value;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Experience Requirement
          const Text(
            'Experience Requirement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ExperienceRequirementInput(
            initialRequirement: _experienceRequirement,
            onChanged: (requirement) {
              _experienceRequirement = requirement;
            },
          ),
          const SizedBox(height: 24),

          // Education Requirements
          const Text(
            'Education Requirements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          EducationRequirementInput(
            initialRequirements: _educationRequirements,
            onChanged: (requirements) {
              _educationRequirements = requirements;
            },
          ),
          const SizedBox(height: 24),

          // Skill Requirements
          const Text(
            'Skill Requirements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SkillInputWidget(
            initialSkills: _skillRequirements,
            onChanged: (skills) {
              _skillRequirements = skills;
            },
          ),
          const SizedBox(height: 24),

          // Requirements List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Requirements',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _addRequirement,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_requirements.isEmpty)
            const Text(
              'No requirements added. Click the + button to add.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            ..._requirements.asMap().entries.map((entry) {
              final index = entry.key;
              final requirement = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(requirement),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _requirements.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),

          // Responsibilities List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Responsibilities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _addResponsibility,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_responsibilities.isEmpty)
            const Text(
              'No responsibilities added. Click the + button to add.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            ..._responsibilities.asMap().entries.map((entry) {
              final index = entry.key;
              final responsibility = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(responsibility),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _responsibilities.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBenefitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Benefits List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Benefits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _addBenefit,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_benefits.isEmpty)
            const Text(
              'No benefits added. Click the + button to add.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _benefits.asMap().entries.map((entry) {
                final index = entry.key;
                final benefit = entry.value;
                return Chip(
                  label: Text(benefit),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _benefits.removeAt(index);
                    });
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Preferred Qualifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preferred Qualifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _addPreferredQualification,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_preferredQualifications.isEmpty)
            const Text(
              'No preferred qualifications added. Click the + button to add.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _preferredQualifications.asMap().entries.map((entry) {
                final index = entry.key;
                final qualification = entry.value;
                return Chip(
                  label: Text(qualification),
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange.shade200),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _preferredQualifications.removeAt(index);
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recruitment Process Stages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RecruitmentStageInput(
            initialStages: _recruitmentStages,
            onChanged: (stages) {
              _recruitmentStages = stages;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Job Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem('Title', _titleController.text),
                  _buildReviewItem('Department', _departmentController.text),
                  _buildReviewItem('Location', _locationController.text),
                  _buildReviewItem(
                    'Job Type',
                    _formData['jobType'] != null
                        ? JobType.fromString(_formData['jobType']).displayName
                        : widget.initialJob?.jobType.displayName ?? 'Full Time',
                  ),
                  _buildReviewItem(
                    'Salary Range',
                    _salaryRange.displayText,
                  ),
                  _buildReviewItem(
                      'Openings', '${_formData['numberOfOpenings'] ?? 1}'),
                  _buildReviewItem(
                    'Deadline',
                    DateFormat('MMM dd, yyyy').format(
                      DateTime.parse(_deadlineController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Requirements Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requirements Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_requirements.length} requirements'),
                  Text('${_responsibilities.length} responsibilities'),
                  Text('${_skillRequirements.length} required skills'),
                  Text(
                      '${_educationRequirements.length} education requirements'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Benefits Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Benefits Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_benefits.length} benefits'),
                  Text(
                      '${_preferredQualifications.length} preferred qualifications'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recruitment Process Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recruitment Process',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_recruitmentStages.length} stages'),
                  if (_recruitmentStages.isNotEmpty)
                    ..._recruitmentStages.map((stage) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${stage.stageNumber}. ${stage.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
