import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/strategic_plan_model.dart';
import '../../../../providers/strategic_plan_provider.dart';

class StrategicPlanForm extends ConsumerStatefulWidget {
  final StrategicPlan? initialData;

  const StrategicPlanForm({super.key, this.initialData});

  @override
  ConsumerState<StrategicPlanForm> createState() => _StrategicPlanFormState();
}

class _StrategicPlanFormState extends ConsumerState<StrategicPlanForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _visionController;
  late TextEditingController _missionController;
  late TextEditingController _fiscalYearController;
  late TextEditingController _planningCycleController;

  late DateTime _startDate;
  late DateTime _endDate;

  final List<StrategicGoal> _goals = [];
  final List<StrategicInitiative> _initiatives = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _titleController = TextEditingController(text: widget.initialData!.title);
      _descriptionController =
          TextEditingController(text: widget.initialData!.description);
      _visionController =
          TextEditingController(text: widget.initialData!.visionStatement);
      _missionController =
          TextEditingController(text: widget.initialData!.missionStatement);
      _fiscalYearController =
          TextEditingController(text: widget.initialData!.fiscalYear);
      _planningCycleController =
          TextEditingController(text: widget.initialData!.planningCycle);
      _startDate = widget.initialData!.startDate;
      _endDate = widget.initialData!.endDate;
      _goals.addAll(widget.initialData!.strategicGoals);
      _initiatives.addAll(widget.initialData!.strategicInitiatives);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _visionController = TextEditingController();
      _missionController = TextEditingController();
      _fiscalYearController =
          TextEditingController(text: DateTime.now().year.toString());
      _planningCycleController = TextEditingController(text: 'Annual');
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 365));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    _missionController.dispose();
    _fiscalYearController.dispose();
    _planningCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.read(strategicPlanProvider.notifier);
    final state = ref.watch(strategicPlanProvider);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => provider.clearSelection(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.initialData == null
                      ? 'Create Strategic Plan'
                      : 'Edit Strategic Plan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.initialData != null)
                  IconButton(
                    onPressed: () => provider.selectPlan(widget.initialData!),
                    icon: const Icon(Icons.visibility),
                    tooltip: 'View Details',
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Basic Information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Vision & Mission
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _visionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Vision Statement',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _missionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Mission Statement',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Fiscal Year & Planning Cycle
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fiscalYearController,
                            decoration: const InputDecoration(
                              labelText: 'Fiscal Year *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter fiscal year';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _planningCycleController,
                            decoration: const InputDecoration(
                              labelText: 'Planning Cycle',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.autorenew),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              child: Text(_formatDate(_startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              child: Text(_formatDate(_endDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Strategic Goals Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Strategic Goals',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addGoal,
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Goal',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_goals.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.flag, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No goals added yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return _buildGoalCard(goal, index);
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
                  child: OutlinedButton(
                    onPressed: () => provider.clearSelection(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isCreating || state.isUpdating
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isCreating || state.isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.initialData == null
                                ? 'Create Plan'
                                : 'Update Plan',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(StrategicGoal goal, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editGoal(index),
                  icon: const Icon(Icons.edit, size: 18),
                ),
                IconButton(
                  onPressed: () => _removeGoal(index),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              goal.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(goal.category),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Priority ${goal.priority}'),
                  backgroundColor: Colors.orange.shade50,
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                const Spacer(),
                Text(
                  '${goal.progress}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        onSave: (goal) {
          setState(() {
            _goals.add(goal);
          });
        },
      ),
    );
  }

  void _editGoal(int index) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        initialGoal: _goals[index],
        onSave: (goal) {
          setState(() {
            _goals[index] = goal;
          });
        },
      ),
    );
  }

  void _removeGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final plan = StrategicPlan(
      id: widget.initialData?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      visionStatement: _visionController.text,
      missionStatement: _missionController.text,
      fiscalYear: _fiscalYearController.text,
      planningCycle: _planningCycleController.text,
      status: widget.initialData?.status ?? PlanStatus.draft,
      startDate: _startDate,
      endDate: _endDate,
      createdById: widget.initialData?.createdById ?? '',
      createdByName: widget.initialData?.createdByName ?? '',
      approvedById: widget.initialData?.approvedById,
      approvedByName: widget.initialData?.approvedByName,
      approvalDate: widget.initialData?.approvalDate,
      strategicGoals: _goals,
      strategicInitiatives: _initiatives,
      budgetAllocation: widget.initialData?.budgetAllocation ?? [],
      resourceRequirements: widget.initialData?.resourceRequirements ?? [],
      risks: widget.initialData?.risks ?? [],
      mitigationStrategies: widget.initialData?.mitigationStrategies ?? [],
      stakeholders: widget.initialData?.stakeholders ?? [],
      communicationPlan: widget.initialData?.communicationPlan ?? {},
      reviewSchedule: widget.initialData?.reviewSchedule ?? {},
      performance: widget.initialData?.performance ?? {},
      nextReviewDate: widget.initialData?.nextReviewDate ??
          DateTime.now().add(const Duration(days: 90)),
      createdAt: widget.initialData?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = ref.read(strategicPlanProvider.notifier);

    if (widget.initialData == null) {
      await provider.createStrategicPlan(plan);
    } else {
      await provider.updateStrategicPlan(plan.id, plan);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class GoalFormDialog extends StatefulWidget {
  final StrategicGoal? initialGoal;
  final Function(StrategicGoal) onSave;

  const GoalFormDialog({
    super.key,
    this.initialGoal,
    required this.onSave,
  });

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _progressController;

  String _selectedStatus = 'notStarted';

  @override
  void initState() {
    super.initState();

    if (widget.initialGoal != null) {
      _titleController = TextEditingController(text: widget.initialGoal!.title);
      _descriptionController =
          TextEditingController(text: widget.initialGoal!.description);
      _categoryController =
          TextEditingController(text: widget.initialGoal!.category);
      _priorityController =
          TextEditingController(text: widget.initialGoal!.priority.toString());
      _progressController =
          TextEditingController(text: widget.initialGoal!.progress.toString());
      _selectedStatus = widget.initialGoal!.status.toString().split('.').last;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _categoryController = TextEditingController(text: 'General');
      _priorityController = TextEditingController(text: '1');
      _progressController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialGoal == null ? 'Add Goal' : 'Edit Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority (1-10)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter priority';
                        }
                        final priority = int.tryParse(value);
                        if (priority == null || priority < 1 || priority > 10) {
                          return 'Priority must be 1-10';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _progressController,
                      decoration: const InputDecoration(
                        labelText: 'Progress %',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter progress';
                        }
                        final progress = double.tryParse(value);
                        if (progress == null ||
                            progress < 0 ||
                            progress > 100) {
                          return 'Progress must be 0-100';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: GoalStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status.toString().split('.').last,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = StrategicGoal(
      id: widget.initialGoal?.id ?? '',
      goalNumber: widget.initialGoal?.goalNumber ??
          'G${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      priority: int.parse(_priorityController.text),
      progress: double.parse(_progressController.text),
      status: GoalStatus.fromString(_selectedStatus),
      startDate: widget.initialGoal?.startDate ?? DateTime.now(),
      endDate: widget.initialGoal?.endDate ??
          DateTime.now().add(const Duration(days: 180)),
      ownerId: widget.initialGoal?.ownerId ?? '',
      ownerName: widget.initialGoal?.ownerName ?? '',
      dependencies: widget.initialGoal?.dependencies ?? [],
      metrics: widget.initialGoal?.metrics ?? {},
      createdAt: widget.initialGoal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(goal);
    Navigator.pop(context);
  }
}
