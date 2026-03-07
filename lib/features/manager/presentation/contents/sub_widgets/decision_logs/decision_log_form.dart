import 'package:flutter/material.dart';
import '../../../../models/decision_log_model.dart';

class DecisionLogForm extends StatefulWidget {
  final DecisionLog? decisionLog;
  final bool isEditing;
  final Function(DecisionLog) onSave;
  final VoidCallback onCancel;
  final bool isLoading;

  const DecisionLogForm({
    super.key,
    this.decisionLog,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
    required this.isLoading,
  });

  @override
  State<DecisionLogForm> createState() => _DecisionLogFormState();
}

class _DecisionLogFormState extends State<DecisionLogForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _problemStatementController;
  late TextEditingController _decisionController;
  late TextEditingController _rationaleController;
  late TextEditingController _backgroundController;
  late TextEditingController _triggerController;
  late TextEditingController _scopeController;

  late List<String> _objectives;
  late List<String> _constraints;
  late List<DecisionAlternative> _alternatives;
  late List<DecisionCriteria> _criteria;
  late List<String> _expectedOutcomes;

  late UrgencyLevel _urgency;
  late ImpactLevel _impact;
  late DecisionStatus _status;

  @override
  void initState() {
    super.initState();
    final log = widget.decisionLog;

    _titleController = TextEditingController(text: log?.title ?? '');
    _descriptionController =
        TextEditingController(text: log?.description ?? '');
    _problemStatementController =
        TextEditingController(text: log?.problemStatement ?? '');
    _decisionController = TextEditingController(text: log?.decision ?? '');
    _rationaleController = TextEditingController(text: log?.rationale ?? '');
    _backgroundController =
        TextEditingController(text: log?.context.background ?? '');
    _triggerController =
        TextEditingController(text: log?.context.trigger ?? '');
    _scopeController = TextEditingController(text: log?.context.scope ?? '');

    _objectives = log?.objectives ?? [];
    _constraints = log?.constraints ?? [];
    _alternatives = log?.alternatives ?? [];
    _criteria = log?.criteria ?? [];
    _expectedOutcomes = log?.expectedOutcomes ?? [];

    _urgency = log?.context.urgency ?? UrgencyLevel.medium;
    _impact = log?.context.impact ?? ImpactLevel.moderate;
    _status = log?.status ?? DecisionStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _problemStatementController.dispose();
    _decisionController.dispose();
    _rationaleController.dispose();
    _backgroundController.dispose();
    _triggerController.dispose();
    _scopeController.dispose();
    super.dispose();
  }

  void _addObjective() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Objective'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter objective...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _objectives.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addConstraint() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Constraint'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter constraint...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _constraints.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addAlternative() {
    showDialog(
      context: context,
      builder: (context) {
        final alternativeController = TextEditingController();
        final descriptionController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Alternative'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: alternativeController,
                  decoration: const InputDecoration(
                    labelText: 'Alternative',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (alternativeController.text.trim().isNotEmpty) {
                  setState(() {
                    _alternatives.add(DecisionAlternative(
                      alternative: alternativeController.text.trim(),
                      description: descriptionController.text.trim(),
                      cost: 0,
                      timelineDays: 0,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addCriterion() {
    showDialog(
      context: context,
      builder: (context) {
        final criterionController = TextEditingController();
        final weightController = TextEditingController(text: '1.0');
        return AlertDialog(
          title: const Text('Add Criterion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: criterionController,
                  decoration: const InputDecoration(
                    labelText: 'Criterion',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (1-10)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text) ?? 1.0;
                if (criterionController.text.trim().isNotEmpty) {
                  setState(() {
                    _criteria.add(DecisionCriteria(
                      criterion: criterionController.text.trim(),
                      weight: weight,
                      description: '',
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addExpectedOutcome() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Expected Outcome'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter expected outcome...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _expectedOutcomes.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final log = DecisionLog(
        id: widget.decisionLog?.id,
        decisionId: widget.decisionLog?.decisionId ??
            'DEC-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        context: DecisionContext(
          background: _backgroundController.text.trim(),
          trigger: _triggerController.text.trim(),
          scope: _scopeController.text.trim(),
          urgency: _urgency,
          impact: _impact,
        ),
        problemStatement: _problemStatementController.text.trim(),
        objectives: _objectives,
        constraints: _constraints,
        alternatives: _alternatives,
        criteria: _criteria,
        analysis: DecisionAnalysis(
          method: 'multi_criteria',
          scores: [],
          recommendation: _decisionController.text.trim(),
          confidence: 0,
        ),
        decision: _decisionController.text.trim(),
        rationale: _rationaleController.text.trim(),
        expectedOutcomes: _expectedOutcomes,
        implementationSteps: [],
        status: _status,
        decisionMakerId: 'current_user_id',
        // Replace with actual user ID
        decisionDate: DateTime.now(),
        createdAt: widget.decisionLog?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(log);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: widget.isLoading ? null : widget.onCancel,
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                widget.isEditing ? 'Edit Decision Log' : 'New Decision Log',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            actions: [
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.blue),
                  onPressed: _submitForm,
                  tooltip: 'Save',
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSection(
                        title: 'Basic Information',
                        icon: Icons.info,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Context
                      _buildSection(
                        title: 'Decision Context',
                        icon: Icons.lightbulb,
                        children: [
                          TextFormField(
                            controller: _problemStatementController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Problem Statement *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the problem statement';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _backgroundController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Background *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _triggerController,
                            decoration: const InputDecoration(
                              labelText: 'Trigger *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _scopeController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Scope *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<UrgencyLevel>(
                                  value: _urgency,
                                  decoration: const InputDecoration(
                                    labelText: 'Urgency Level',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: UrgencyLevel.values.map((level) {
                                    return DropdownMenuItem(
                                      value: level,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: level.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(level.label),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _urgency = value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<ImpactLevel>(
                                  value: _impact,
                                  decoration: const InputDecoration(
                                    labelText: 'Impact Level',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ImpactLevel.values.map((level) {
                                    return DropdownMenuItem(
                                      value: level,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: level.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(level.label),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _impact = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Objectives & Constraints
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildSection(
                              title: 'Objectives',
                              icon: Icons.flag,
                              children: [
                                ..._objectives.map((objective) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(objective),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _objectives.remove(objective);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                                OutlinedButton.icon(
                                  onPressed: _addObjective,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Objective'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildSection(
                              title: 'Constraints',
                              icon: Icons.block,
                              children: [
                                ..._constraints.map((constraint) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(constraint),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _constraints.remove(constraint);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                                OutlinedButton.icon(
                                  onPressed: _addConstraint,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Constraint'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Alternatives
                      _buildSection(
                        title: 'Alternatives',
                        icon: Icons.compare_arrows,
                        children: [
                          ..._alternatives.map((alternative) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            alternative.alternative,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          onPressed: () {
                                            // Edit alternative
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _alternatives.remove(alternative);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      alternative.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          OutlinedButton.icon(
                            onPressed: _addAlternative,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Alternative'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Criteria
                      _buildSection(
                        title: 'Decision Criteria',
                        icon: Icons.score,
                        children: [
                          ..._criteria.map((criterion) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(criterion.criterion),
                                subtitle: Text(
                                  'Weight: ${criterion.weight}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () {
                                        // Edit criterion
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          size: 18, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _criteria.remove(criterion);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          OutlinedButton.icon(
                            onPressed: _addCriterion,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Criterion'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Decision Details
                      _buildSection(
                        title: 'Decision Details',
                        icon: Icons.gavel,
                        children: [
                          TextFormField(
                            controller: _decisionController,
                            decoration: const InputDecoration(
                              labelText: 'Decision *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the decision';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _rationaleController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Rationale *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the rationale';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Expected Outcomes
                      _buildSection(
                        title: 'Expected Outcomes',
                        icon: Icons.trending_up,
                        children: [
                          ..._expectedOutcomes.map((outcome) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(outcome),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _expectedOutcomes.remove(outcome);
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                          OutlinedButton.icon(
                            onPressed: _addExpectedOutcome,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Expected Outcome'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status
                      _buildSection(
                        title: 'Status',
                        icon: Icons.work,
                        children: [
                          DropdownButtonFormField<DecisionStatus>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Decision Status',
                              border: OutlineInputBorder(),
                            ),
                            items: DecisionStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(status.icon, color: status.color),
                                    const SizedBox(width: 8),
                                    Text(status.label),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  widget.isLoading ? null : widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: widget.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      widget.isEditing ? 'Update' : 'Create'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
