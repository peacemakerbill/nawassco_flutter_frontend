import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class TrainingForm extends ConsumerStatefulWidget {
  final Training? training;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final bool isEditing;

  const TrainingForm({
    super.key,
    this.training,
    required this.onSuccess,
    this.onCancel,
    this.isEditing = false,
  });

  @override
  ConsumerState<TrainingForm> createState() => _TrainingFormState();
}

class _TrainingFormState extends ConsumerState<TrainingForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _trainingCodeController;
  late TextEditingController _providerController;
  late TextEditingController _trainerController;
  late TextEditingController _costController;
  late TextEditingController _venueController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _durationController;

  // Form values
  TrainingType _selectedType = TrainingType.internal;
  TrainingCategory _selectedCategory = TrainingCategory.technical_skills;
  TrainingLevel _selectedLevel = TrainingLevel.beginner;
  DurationUnit _selectedDurationUnit = DurationUnit.hours;
  String _currency = 'KES';

  // Dates
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 5));

  // Form sections
  final List<_FormSection> _sections = [];
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _titleController = TextEditingController(text: widget.training?.trainingTitle ?? '');
    _descriptionController = TextEditingController(text: widget.training?.description ?? '');
    _trainingCodeController = TextEditingController(
      text: widget.training?.trainingCode ?? _generateTrainingCode(),
    );
    _providerController = TextEditingController(text: widget.training?.provider ?? '');
    _trainerController = TextEditingController(text: widget.training?.trainer ?? '');
    _costController = TextEditingController(
      text: widget.training?.cost.toString() ?? '0',
    );
    _venueController = TextEditingController(text: widget.training?.venue ?? '');
    _maxParticipantsController = TextEditingController(
      text: widget.training?.maxParticipants.toString() ?? '20',
    );
    _durationController = TextEditingController(
      text: widget.training?.duration.toString() ?? '2',
    );

    // Set form values from existing training
    if (widget.training != null) {
      _selectedType = widget.training!.trainingType;
      _selectedCategory = widget.training!.category;
      _selectedLevel = widget.training!.level;
      _selectedDurationUnit = widget.training!.durationUnit;
      _currency = widget.training!.currency;
      _startDate = widget.training!.startDate;
      _endDate = widget.training!.endDate;
      _registrationDeadline = widget.training!.registrationDeadline;
    }

    // Define form sections
    _sections.addAll([
      const _FormSection(
        title: 'Basic Information',
        icon: Icons.info,
        description: 'Enter basic training details',
      ),
      const _FormSection(
        title: 'Training Details',
        icon: Icons.school,
        description: 'Specify training type, category, and level',
      ),
      const _FormSection(
        title: 'Schedule & Location',
        icon: Icons.calendar_today,
        description: 'Set dates, deadlines, and venue',
      ),
      const _FormSection(
        title: 'Cost & Participants',
        icon: Icons.attach_money,
        description: 'Configure pricing and capacity',
      ),
    ]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trainingCodeController.dispose();
    _providerController.dispose();
    _trainerController.dispose();
    _costController.dispose();
    _venueController.dispose();
    _maxParticipantsController.dispose();
    _durationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _generateTrainingCode() {
    final now = DateTime.now();
    final prefix = 'TR';
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return '$prefix$year$month$day$random';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Training' : 'Create New Training',
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
          tooltip: 'Cancel',
        ),
        actions: [
          if (_currentSection > 0)
            TextButton(
              onPressed: _previousSection,
              child: const Text('Previous'),
            ),
          if (_currentSection < _sections.length - 1)
            TextButton(
              onPressed: _nextSection,
              child: const Text('Next'),
            ),
          if (_currentSection == _sections.length - 1)
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: state.isCreating || state.isUpdating
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Text(widget.isEditing ? 'Update' : 'Create'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentSection + 1) / _sections.length,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
            minHeight: 4,
          ),

          // Section navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;
                final isActive = index == _currentSection;
                final isCompleted = index < _currentSection;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _goToSection(index),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.blue
                                : isCompleted
                                ? Colors.green
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? Colors.blue
                                : isCompleted
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Section content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                      children: [
                        Icon(_sections[_currentSection].icon, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sections[_currentSection].title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Text(
                              _sections[_currentSection].description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Form fields for current section
                    _buildSectionContent(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel ?? () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: state.isCreating || state.isUpdating
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Text(widget.isEditing ? 'Update Training' : 'Create Training'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_currentSection) {
      case 0:
        return _buildBasicInfoSection();
      case 1:
        return _buildTrainingDetailsSection();
      case 2:
        return _buildScheduleSection();
      case 3:
        return _buildCostParticipantsSection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // Training Code (read-only for editing)
        if (widget.isEditing)
          TextFormField(
            controller: _trainingCodeController,
            decoration: const InputDecoration(
              labelText: 'Training Code',
              prefixIcon: Icon(Icons.code),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),

        if (widget.isEditing) const SizedBox(height: 16),

        // Training Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Training Title *',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(),
            hintText: 'Enter training title',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Training title is required';
            }
            if (value.length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
          maxLength: 100,
        ),

        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
            hintText: 'Describe the training program...',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Description is required';
            }
            if (value.length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildTrainingDetailsSection() {
    return Column(
      children: [
        // Training Type
        DropdownButtonFormField<TrainingType>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Training Type *',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: TrainingType.values.map((type) {
            return DropdownMenuItem<TrainingType>(
              value: type,
              child: Text(_getTypeDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedType = value);
            }
          },
          validator: (value) => value == null ? 'Please select training type' : null,
        ),

        const SizedBox(height: 16),

        // Training Category
        DropdownButtonFormField<TrainingCategory>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category *',
            prefixIcon: Icon(Icons.group_work),
            border: OutlineInputBorder(),
          ),
          items: TrainingCategory.values.map((category) {
            return DropdownMenuItem<TrainingCategory>(
              value: category,
              child: Text(_getCategoryDisplayName(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
          validator: (value) => value == null ? 'Please select category' : null,
        ),

        const SizedBox(height: 16),

        // Training Level
        DropdownButtonFormField<TrainingLevel>(
          value: _selectedLevel,
          decoration: const InputDecoration(
            labelText: 'Level *',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(),
          ),
          items: TrainingLevel.values.map((level) {
            return DropdownMenuItem<TrainingLevel>(
              value: level,
              child: Text(_getLevelDisplayName(level)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLevel = value);
            }
          },
          validator: (value) => value == null ? 'Please select level' : null,
        ),

        const SizedBox(height: 16),

        // Duration
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration *',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Duration is required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Enter a valid duration';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<DurationUnit>(
              value: _selectedDurationUnit,
              items: DurationUnit.values.map((unit) {
                return DropdownMenuItem<DurationUnit>(
                  value: unit,
                  child: Text(_getDurationUnitDisplayName(unit)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDurationUnit = value);
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Provider
        TextFormField(
          controller: _providerController,
          decoration: const InputDecoration(
            labelText: 'Training Provider *',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
            hintText: 'e.g., Internal, Microsoft, Coursera',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Provider is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Trainer
        TextFormField(
          controller: _trainerController,
          decoration: const InputDecoration(
            labelText: 'Trainer/Instructor *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
            hintText: 'Enter trainer name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Trainer is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        // Start Date
        InkWell(
          onTap: () => _selectDate(context, isStartDate: true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start Date *',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMM yyyy').format(_startDate)),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // End Date
        InkWell(
          onTap: () => _selectDate(context, isStartDate: false),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'End Date *',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMM yyyy').format(_endDate)),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Training Duration Summary
        if (_startDate != _endDate)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Training duration: ${_calculateDurationDays()} days',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Registration Deadline
        InkWell(
          onTap: _selectRegistrationDeadline,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Registration Deadline *',
              prefixIcon: Icon(Icons.event_busy),
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMM yyyy').format(_registrationDeadline)),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Deadline warning
        if (_registrationDeadline.isAfter(_startDate))
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Registration deadline is after training start date',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Venue
        TextFormField(
          controller: _venueController,
          decoration: const InputDecoration(
            labelText: 'Venue/Location *',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
            hintText: 'e.g., Conference Room A, Online, External Venue',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Venue is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 8),

        if (_venueController.text.isNotEmpty && !_venueController.text.toLowerCase().contains('online'))
          TextButton.icon(
            onPressed: () {
              // Open map
            },
            icon: const Icon(Icons.map, size: 18),
            label: const Text('View on Map'),
          ),
      ],
    );
  }

  Widget _buildCostParticipantsSection() {
    return Column(
      children: [
        // Cost
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost per Participant',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cost = double.tryParse(value);
                    if (cost == null || cost < 0) {
                      return 'Enter a valid cost';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _currency = value,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Maximum Participants
        TextFormField(
          controller: _maxParticipantsController,
          decoration: const InputDecoration(
            labelText: 'Maximum Participants *',
            prefixIcon: Icon(Icons.people),
            border: OutlineInputBorder(),
            hintText: 'Enter maximum number of participants',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Maximum participants is required';
            }
            final num = int.tryParse(value);
            if (num == null || num <= 0) {
              return 'Enter a valid number (minimum 1)';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Pricing summary
        if (_costController.text.isNotEmpty && double.tryParse(_costController.text) != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pricing Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cost per participant:'),
                      Text(
                        '$_currency ${double.parse(_costController.text).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maximum participants:'),
                      Text(
                        _maxParticipantsController.text,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total potential revenue:'),
                      Text(
                        '$_currency ${(double.parse(_costController.text) * int.parse(_maxParticipantsController.text)).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Additional options
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Waiting list option
                SwitchListTile.adaptive(
                  title: const Text('Enable Waiting List'),
                  subtitle: const Text('Allow participants to join waiting list when training is full'),
                  value: true,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),

                // Certificate option
                SwitchListTile.adaptive(
                  title: const Text('Issue Certificates'),
                  subtitle: const Text('Automatically generate certificates for participants who complete training'),
                  value: true,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),

                // Evaluation option
                SwitchListTile.adaptive(
                  title: const Text('Require Evaluation'),
                  subtitle: const Text('Participants must complete evaluation after training'),
                  value: false,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Form validation summary
        if (_formKey.currentState != null && !_formKey.currentState!.validate())
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please fill all required fields marked with *',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ========== SECTION NAVIGATION ==========

  void _nextSection() {
    // Validate current section
    if (!_validateCurrentSection()) return;

    setState(() {
      if (_currentSection < _sections.length - 1) {
        _currentSection++;
      }
    });

    // Scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousSection() {
    setState(() {
      if (_currentSection > 0) {
        _currentSection--;
      }
    });

    // Scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToSection(int index) {
    // Only allow going to completed sections
    if (index > _currentSection) return;

    setState(() {
      _currentSection = index;
    });

    // Scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentSection() {
    switch (_currentSection) {
      case 0: // Basic Info
        if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all required fields'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 1: // Training Details
        return true;
      case 2: // Schedule
        if (_venueController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter venue information'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 3: // Cost & Participants
        final maxParticipants = int.tryParse(_maxParticipantsController.text);
        if (maxParticipants == null || maxParticipants <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid maximum participants'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  // ========== DATE SELECTION ==========

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2)); // 2 years

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(picked) || _endDate.isAtSameMomentAs(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          // Ensure start date is before end date
          if (_startDate.isAfter(picked)) {
            _startDate = picked.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _selectRegistrationDeadline() async {
    final initialDate = _registrationDeadline;
    final firstDate = DateTime.now();
    final lastDate = _startDate.subtract(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate.isBefore(firstDate) ? _startDate : lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
      });
    }
  }

  // ========== FORM SUBMISSION ==========

  Future<void> _submitForm() async {
    // Validate all sections
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix all errors before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate dates
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_registrationDeadline.isAfter(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration deadline must be before training start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare training data
    final trainingData = {
      if (!widget.isEditing) 'trainingCode': _trainingCodeController.text.trim(),
      'trainingTitle': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'trainingType': _selectedType.toString().split('.').last,
      'category': _selectedCategory.toString().split('.').last,
      'level': _selectedLevel.toString().split('.').last,
      'duration': int.parse(_durationController.text),
      'durationUnit': _selectedDurationUnit.toString().split('.').last,
      'provider': _providerController.text.trim(),
      'trainer': _trainerController.text.trim(),
      'cost': double.parse(_costController.text.isEmpty ? '0' : _costController.text),
      'currency': _currency,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'registrationDeadline': _registrationDeadline.toIso8601String(),
      'venue': _venueController.text.trim(),
      'maxParticipants': int.parse(_maxParticipantsController.text),
      'status': 'planned', // Default status
    };

    bool success;
    if (widget.isEditing) {
      success = await ref.read(trainingProvider.notifier).updateTraining(
        widget.training!.id,
        trainingData,
      );
    } else {
      success = await ref.read(trainingProvider.notifier).createTraining(trainingData);
    }

    if (success) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Training updated successfully'
                : 'Training created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ========== HELPER METHODS ==========

  int _calculateDurationDays() {
    return _endDate.difference(_startDate).inDays + 1;
  }

  String _getTypeDisplayName(TrainingType type) {
    switch (type) {
      case TrainingType.internal:
        return 'Internal Training';
      case TrainingType.external:
        return 'External Training';
      case TrainingType.online:
        return 'Online Course';
      case TrainingType.workshop:
        return 'Workshop';
      case TrainingType.seminar:
        return 'Seminar';
    }
  }

  String _getCategoryDisplayName(TrainingCategory category) {
    switch (category) {
      case TrainingCategory.technical_skills:
        return 'Technical Skills';
      case TrainingCategory.soft_skills:
        return 'Soft Skills';
      case TrainingCategory.management:
        return 'Management';
      case TrainingCategory.compliance:
        return 'Compliance';
      case TrainingCategory.safety:
        return 'Safety';
      case TrainingCategory.leadership:
        return 'Leadership';
    }
  }

  String _getLevelDisplayName(TrainingLevel level) {
    switch (level) {
      case TrainingLevel.beginner:
        return 'Beginner';
      case TrainingLevel.intermediate:
        return 'Intermediate';
      case TrainingLevel.advanced:
        return 'Advanced';
      case TrainingLevel.expert:
        return 'Expert';
    }
  }

  String _getDurationUnitDisplayName(DurationUnit unit) {
    switch (unit) {
      case DurationUnit.hours:
        return 'Hours';
      case DurationUnit.days:
        return 'Days';
      case DurationUnit.weeks:
        return 'Weeks';
      case DurationUnit.months:
        return 'Months';
    }
  }
}

class _FormSection {
  final String title;
  final IconData icon;
  final String description;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.description,
  });
}