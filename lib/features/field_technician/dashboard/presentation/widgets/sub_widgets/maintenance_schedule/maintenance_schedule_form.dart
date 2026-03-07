import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/field_technician.dart';
import '../../../../models/maintenance_schedule.dart';
import '../../../../models/tool.dart';
import '../../../../providers/field_technician_provider.dart';
import '../../../../providers/tool_provider.dart';
import '../../../../providers/vehicle_provider.dart';

class MaintenanceScheduleForm extends ConsumerStatefulWidget {
  final MaintenanceSchedule? schedule;
  final Future<bool> Function(Map<String, dynamic>) onSubmit;

  const MaintenanceScheduleForm({
    super.key,
    this.schedule,
    required this.onSubmit,
  });

  @override
  ConsumerState<MaintenanceScheduleForm> createState() =>
      _MaintenanceScheduleFormState();
}

class _MaintenanceScheduleFormState
    extends ConsumerState<MaintenanceScheduleForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  MaintenanceTargetType _selectedTargetType = MaintenanceTargetType.vehicle;
  String? _selectedTargetId;
  String? _selectedTargetName;
  ScheduleType _selectedScheduleType = ScheduleType.preventive;
  Frequency _selectedFrequency = Frequency.monthly;
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedNextDueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _selectedEndDate;

  final List<MaintenanceTask> _tasks = [];
  final List<String> _selectedTools = [];
  final List<String> _selectedTechnicians = [];
  final List<RequiredMaterial> _requiredMaterials = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toolProvider.notifier).loadTools();
      ref.read(vehicleProvider.notifier).loadVehicles();
      ref.read(fieldTechnicianProvider.notifier).loadFieldTechnicians();

      // Pre-fill form if editing
      if (widget.schedule != null) {
        _prefillForm();
      }
    });
  }

  void _prefillForm() {
    final schedule = widget.schedule!;
    _titleController.text = schedule.title;
    _descriptionController.text = schedule.description;
    _estimatedCostController.text = schedule.estimatedCost.toString();
    _estimatedDurationController.text = schedule.estimatedDuration.toString();
    _selectedTargetType = schedule.targetType;
    _selectedTargetId = schedule.targetId;
    _selectedTargetName = schedule.targetName;
    _selectedScheduleType = schedule.scheduleType;
    _selectedFrequency = schedule.frequency;
    _selectedPriority = schedule.priority;
    _selectedStartDate = schedule.startDate;
    _selectedNextDueDate = schedule.nextDueDate;
    _selectedEndDate = schedule.endDate;
    _tasks.addAll(schedule.tasks);
    _selectedTools.addAll(schedule.requiredTools);
    _selectedTechnicians.addAll(schedule.assignedTo);
    _requiredMaterials.addAll(schedule.requiredMaterials);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toolState = ref.watch(toolProvider);
    final vehicleState = ref.watch(vehicleProvider);
    final technicianState = ref.watch(fieldTechnicianProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.schedule == null ? Icons.add_circle : Icons.edit,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.schedule == null
                      ? 'Create Maintenance Schedule'
                      : 'Edit Maintenance Schedule',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Basic Info'),
                Tab(text: 'Tasks'),
                Tab(text: 'Resources'),
                Tab(text: 'Assignment'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildTasksTab(),
                _buildResourcesTab(toolState),
                _buildAssignmentTab(technicianState),
              ],
            ),
          ),
          // Footer Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.schedule == null ? 'Create' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter maintenance schedule title',
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
                hintText: 'Describe the maintenance work',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Target Type and Specific Target
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MaintenanceTargetType>(
                    value: _selectedTargetType,
                    decoration: const InputDecoration(
                      labelText: 'Target Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: MaintenanceTargetType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16, color: type.color),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() {
                        _selectedTargetType = type!;
                        _selectedTargetId = null;
                        _selectedTargetName = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTargetSelector(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Schedule Type and Frequency
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ScheduleType>(
                    value: _selectedScheduleType,
                    decoration: const InputDecoration(
                      labelText: 'Schedule Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: ScheduleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16, color: type.color),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() {
                        _selectedScheduleType = type!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<Frequency>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency *',
                      border: OutlineInputBorder(),
                    ),
                    items: Frequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Row(
                          children: [
                            Icon(frequency.icon,
                                size: 16, color: frequency.color),
                            const SizedBox(width: 8),
                            Text(frequency.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (frequency) {
                      setState(() {
                        _selectedFrequency = frequency!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, (date) {
                      setState(() => _selectedStartDate = date);
                    }, initialDate: _selectedStartDate),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_selectedStartDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, (date) {
                      setState(() => _selectedNextDueDate = date);
                    }, initialDate: _selectedNextDueDate),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Next Due Date *',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_selectedNextDueDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cost and Duration
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Cost *',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter estimated cost';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _estimatedDurationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Duration (hours) *',
                      border: OutlineInputBorder(),
                      suffixText: 'hours',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter estimated duration';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Priority
            DropdownButtonFormField<PriorityLevel>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority *',
                border: OutlineInputBorder(),
              ),
              items: PriorityLevel.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(priority.icon, size: 16, color: priority.color),
                      const SizedBox(width: 8),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (priority) {
                setState(() {
                  _selectedPriority = priority!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    final toolState = ref.watch(toolProvider);
    final vehicleState = ref.watch(vehicleProvider);

    // Handle infrastructure and facility types (text input)
    if (_selectedTargetType == MaintenanceTargetType.infrastructure ||
        _selectedTargetType == MaintenanceTargetType.facility) {
      return TextFormField(
        onChanged: (value) {
          setState(() {
            _selectedTargetId = value;
            _selectedTargetName = value;
          });
        },
        initialValue: _selectedTargetName,
        decoration: InputDecoration(
          labelText: '${_selectedTargetType.displayName} Name *',
          border: const OutlineInputBorder(),
          hintText:
              'Enter ${_selectedTargetType.displayName.toLowerCase()} name',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
      );
    }

    // Handle vehicle, tool, and equipment types (dropdown)
    List<DropdownMenuItem<String>> items = [];

    if (_selectedTargetType == MaintenanceTargetType.vehicle) {
      items = vehicleState.vehicles.map((vehicle) {
        return DropdownMenuItem(
          value: vehicle.id,
          child: Text(
              '${vehicle.registrationNumber} - ${vehicle.make} ${vehicle.model}'),
        );
      }).toList();
    } else if (_selectedTargetType == MaintenanceTargetType.tool ||
        _selectedTargetType == MaintenanceTargetType.equipment) {
      items = toolState.tools.map((tool) {
        return DropdownMenuItem(
          value: tool.id,
          child: Text('${tool.toolCode} - ${tool.toolName}'),
        );
      }).toList();
    }

    return DropdownButtonFormField<String>(
      value: _selectedTargetId,
      decoration: InputDecoration(
        labelText: 'Select ${_selectedTargetType.displayName} *',
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (id) {
        setState(() {
          _selectedTargetId = id;
          // Set the target name based on the selected item
          if (_selectedTargetType == MaintenanceTargetType.vehicle) {
            final vehicle = vehicleState.vehicles.firstWhere((v) => v.id == id);
            _selectedTargetName =
                '${vehicle.registrationNumber} - ${vehicle.make} ${vehicle.model}';
          } else if (_selectedTargetType == MaintenanceTargetType.tool ||
              _selectedTargetType == MaintenanceTargetType.equipment) {
            final tool = toolState.tools.firstWhere((t) => t.id == id);
            _selectedTargetName = '${tool.toolCode} - ${tool.toolName}';
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a ${_selectedTargetType.displayName.toLowerCase()}';
        }
        return null;
      },
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        // Add Task Button
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addNewTask,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ),
        // Tasks List
        Expanded(
          child: _tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Tasks Added',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Add tasks to define the maintenance work',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) =>
                      _buildTaskItem(_tasks[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(MaintenanceTask task, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.task,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editTask(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _removeTask(index),
                ),
              ],
            ),
            Text(
              task.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('${task.estimatedTime}h est.'),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(task.status.displayName),
                  backgroundColor: task.status.color.withOpacity(0.1),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab(ToolState toolState) {
    return Column(
      children: [
        // Required Tools
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Required Tools',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedTools.map((toolId) {
                      final tool = toolState.tools.firstWhere(
                        (t) => t.id == toolId,
                        orElse: () => Tool(
                          id: toolId,
                          toolCode: 'Unknown',
                          toolName: 'Unknown Tool',
                          description: '',
                          toolType: ToolType.handTool,
                          category: '',
                          brand: '',
                          toolModel: '',
                          serialNumber: '',
                          specifications: const [],
                          currentStatus: ToolStatus.available,
                          currentLocation: '',
                          maintenanceSchedule: ToolMaintenance(
                            lastMaintenanceDate: DateTime.now(),
                            nextMaintenanceDate: DateTime.now(),
                            maintenanceInterval: 0,
                            maintenanceTasks: const [],
                          ),
                          serviceHistory: const [],
                          calibrationHistory: const [],
                          totalUsageHours: 0,
                          usageCount: 0,
                          purchasePrice: 0,
                          currentValue: 0,
                          maintenanceCost: 0,
                          safetyInstructions: const [],
                          requiresTraining: false,
                          riskLevel: RiskLevel.low,
                          isActive: true,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      return Chip(
                        label: Text(tool.toolName),
                        onDeleted: () => _removeTool(toolId),
                      );
                    }).toList(),
                    ActionChip(
                      label: const Text('Add Tool'),
                      onPressed: _showToolSelector,
                      avatar: const Icon(Icons.add, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Required Materials
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Required Materials',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addMaterial,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._requiredMaterials
                    .asMap()
                    .entries
                    .map((entry) => _buildMaterialItem(entry.value, entry.key))
                    .toList(),
                if (_requiredMaterials.isEmpty)
                  const Center(
                    child: Text(
                      'No materials added',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialItem(RequiredMaterial material, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        title: Text(material.material),
        subtitle: Text('${material.quantity} ${material.unit}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
          onPressed: () => _removeMaterial(index),
        ),
      ),
    );
  }

  Widget _buildAssignmentTab(FieldTechnicianState technicianState) {
    return Column(
      children: [
        // Assigned Technicians
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned Technicians',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedTechnicians.map((techId) {
                      final tech = technicianState.technicians.firstWhere(
                        (t) => t.id == techId,
                        orElse: () => FieldTechnician(
                          id: techId,
                          employeeNumber: 'Unknown',
                          userId: 'Unknown',
                          firstName: 'Unknown',
                          lastName: 'Technician',
                          email: '',
                          phone: '',
                          nationalId: '',
                          hireDate: DateTime.now(),
                          department: '',
                          jobTitle: FieldTechnicianRole.fieldTechnician,
                          currentStatus: TechnicianStatus.available,
                          workZone: '',
                          assignedRegions: const [],
                          specializedAreas: const [],
                          jobsCompleted: 0,
                          onTimeCompletionRate: 0,
                          customerSatisfaction: 0,
                          firstTimeFixRate: 0,
                          toolsAssigned: const [],
                          isActive: true,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      return Chip(
                        label: Text(tech.fullName),
                        onDeleted: () => _removeTechnician(techId),
                      );
                    }).toList(),
                    ActionChip(
                      label: const Text('Assign Technician'),
                      onPressed: _showTechnicianSelector,
                      avatar: const Icon(Icons.add, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        onSave: (task) {
          setState(() => _tasks.add(task));
        },
      ),
    );
  }

  void _editTask(int index) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: _tasks[index],
        onSave: (updatedTask) {
          setState(() => _tasks[index] = updatedTask);
        },
      ),
    );
  }

  void _removeTask(int index) {
    setState(() => _tasks.removeAt(index));
  }

  void _showToolSelector() {
    final toolState = ref.read(toolProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Tools'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: toolState.tools.length,
            itemBuilder: (context, index) {
              final tool = toolState.tools[index];
              return CheckboxListTile(
                title: Text('${tool.toolCode} - ${tool.toolName}'),
                subtitle: Text(tool.currentStatus.displayName),
                value: _selectedTools.contains(tool.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _selectedTools.add(tool.id);
                    } else {
                      _selectedTools.remove(tool.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _removeTool(String toolId) {
    setState(() => _selectedTools.remove(toolId));
  }

  void _addMaterial() {
    showDialog(
      context: context,
      builder: (context) => MaterialDialog(
        onSave: (material) {
          setState(() => _requiredMaterials.add(material));
        },
      ),
    );
  }

  void _removeMaterial(int index) {
    setState(() => _requiredMaterials.removeAt(index));
  }

  void _showTechnicianSelector() {
    final technicianState = ref.read(fieldTechnicianProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Technicians'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: technicianState.technicians.length,
            itemBuilder: (context, index) {
              final tech = technicianState.technicians[index];
              return CheckboxListTile(
                title: Text(tech.fullName),
                subtitle: Text(tech.jobTitle.displayName),
                value: _selectedTechnicians.contains(tech.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _selectedTechnicians.add(tech.id);
                    } else {
                      _selectedTechnicians.remove(tech.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _removeTechnician(String techId) {
    setState(() => _selectedTechnicians.remove(techId));
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected,
      {DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate additional fields
    if (_selectedTargetId == null &&
        _selectedTargetType != MaintenanceTargetType.infrastructure &&
        _selectedTargetType != MaintenanceTargetType.facility) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select a ${_selectedTargetType.displayName.toLowerCase()}')),
      );
      return;
    }

    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one task')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final formData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'targetType': _selectedTargetType.name,
      'targetId': _selectedTargetId ?? _titleController.text,
      // For infrastructure/facility
      'targetName': _selectedTargetName ?? _titleController.text,
      'scheduleType': _selectedScheduleType.name,
      'frequency': _selectedFrequency.name,
      'startDate': _selectedStartDate.toIso8601String(),
      'nextDueDate': _selectedNextDueDate.toIso8601String(),
      if (_selectedEndDate != null)
        'endDate': _selectedEndDate!.toIso8601String(),
      'tasks': _tasks.map((task) => task.toJson()).toList(),
      'estimatedDuration': double.parse(_estimatedDurationController.text),
      'requiredTools': _selectedTools,
      'requiredMaterials':
          _requiredMaterials.map((material) => material.toJson()).toList(),
      'assignedTo': _selectedTechnicians,
      'estimatedCost': double.parse(_estimatedCostController.text),
      'priority': _selectedPriority.name,
    };

    final success = await widget.onSubmit(formData);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.schedule == null
                ? 'Maintenance schedule created successfully'
                : 'Maintenance schedule updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

// Supporting Dialog Widgets
class TaskDialog extends StatefulWidget {
  final MaintenanceTask? task;
  final Function(MaintenanceTask) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskController.text = widget.task!.task;
      _descriptionController.text = widget.task!.description;
      _estimatedTimeController.text = widget.task!.estimatedTime.toString();
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: 'Task *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _estimatedTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Estimated Time (hours) *',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_taskController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _estimatedTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final task = MaintenanceTask(
      task: _taskController.text,
      description: _descriptionController.text,
      estimatedTime: double.parse(_estimatedTimeController.text),
    );

    widget.onSave(task);
    Navigator.pop(context);
  }
}

class MaterialDialog extends StatefulWidget {
  final Function(RequiredMaterial) onSave;

  const MaterialDialog({super.key, required this.onSave});

  @override
  State<MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<MaterialDialog> {
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _specificationsController = TextEditingController();

  @override
  void dispose() {
    _materialController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _specificationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Material'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _materialController,
            decoration: const InputDecoration(
              labelText: 'Material Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                    border: OutlineInputBorder(),
                    hintText: 'pcs, kg, m, etc.',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _specificationsController,
            decoration: const InputDecoration(
              labelText: 'Specifications',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMaterial,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveMaterial() {
    if (_materialController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _unitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final material = RequiredMaterial(
      material: _materialController.text,
      quantity: double.parse(_quantityController.text),
      unit: _unitController.text,
      specifications: _specificationsController.text.isEmpty
          ? null
          : _specificationsController.text,
    );

    widget.onSave(material);
    Navigator.pop(context);
  }
}
