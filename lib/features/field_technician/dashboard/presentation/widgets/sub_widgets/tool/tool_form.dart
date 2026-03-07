import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/tool_provider.dart';

class ToolFormWidget extends ConsumerStatefulWidget {
  final Tool? tool;
  final VoidCallback onSaved;

  const ToolFormWidget({
    super.key,
    this.tool,
    required this.onSaved,
  });

  @override
  ConsumerState<ToolFormWidget> createState() => _ToolFormWidgetState();
}

class _ToolFormWidgetState extends ConsumerState<ToolFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _toolNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _maintenanceIntervalController = TextEditingController();

  ToolType _selectedType = ToolType.handTool;
  RiskLevel _selectedRiskLevel = RiskLevel.low;
  List<String> _safetyInstructions = [];
  List<ToolSpecification> _specifications = [];
  final _safetyInstructionController = TextEditingController();
  final _specParameterController = TextEditingController();
  final _specValueController = TextEditingController();
  final _specUnitController = TextEditingController();
  bool _requiresTraining = false;

  @override
  void initState() {
    super.initState();
    if (widget.tool != null) {
      _initializeForm();
    } else {
      _initializeEmptyForm();
    }
  }

  void _initializeForm() {
    final tool = widget.tool!;
    _toolNameController.text = tool.toolName;
    _descriptionController.text = tool.description;
    _categoryController.text = tool.category;
    _brandController.text = tool.brand;
    _modelController.text = tool.toolModel;
    _serialNumberController.text = tool.serialNumber;
    _locationController.text = tool.currentLocation;
    _purchasePriceController.text = tool.purchasePrice.toString();
    _currentValueController.text = tool.currentValue.toString();
    _maintenanceIntervalController.text =
        tool.maintenanceSchedule.maintenanceInterval.toString();
    _selectedType = tool.toolType;
    _selectedRiskLevel = tool.riskLevel;
    _safetyInstructions = List.from(tool.safetyInstructions);
    _specifications = List.from(tool.specifications);
    _requiresTraining = tool.requiresTraining;
  }

  void _initializeEmptyForm() {
    _maintenanceIntervalController.text = '30';
  }

  @override
  void dispose() {
    _toolNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _maintenanceIntervalController.dispose();
    _safetyInstructionController.dispose();
    _specParameterController.dispose();
    _specValueController.dispose();
    _specUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.tool != null ? Icons.edit : Icons.add,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.tool != null ? 'Edit Tool' : 'Add New Tool',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionHeader('Basic Information'),
                    _buildTextField(
                      controller: _toolNameController,
                      label: 'Tool Name',
                      icon: Icons.build,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tool name';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    // Tool Type & Category
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<ToolType>(
                            value: _selectedType,
                            items: ToolType.values,
                            label: 'Tool Type',
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _categoryController,
                            label: 'Category',
                            icon: Icons.category,
                          ),
                        ),
                      ],
                    ),

                    // Specifications
                    _buildSectionHeader('Specifications'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _brandController,
                            label: 'Brand',
                            icon: Icons.business,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _modelController,
                            label: 'Model',
                            icon: Icons.model_training,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _serialNumberController,
                      label: 'Serial Number',
                      icon: Icons.confirmation_number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter serial number';
                        }
                        return null;
                      },
                    ),

                    // Custom Specifications
                    _buildSpecificationsSection(),

                    // Location & Status
                    _buildSectionHeader('Location & Status'),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Current Location',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    // Financial Information
                    _buildSectionHeader('Financial Information'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _purchasePriceController,
                            label: 'Purchase Price (KES)',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter purchase price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _currentValueController,
                            label: 'Current Value (KES)',
                            icon: Icons.money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    // Maintenance
                    _buildSectionHeader('Maintenance Schedule'),
                    _buildTextField(
                      controller: _maintenanceIntervalController,
                      label: 'Maintenance Interval (days)',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),

                    // Safety
                    _buildSectionHeader('Safety Information'),
                    _buildDropdown<RiskLevel>(
                      value: _selectedRiskLevel,
                      items: RiskLevel.values,
                      label: 'Risk Level',
                      onChanged: (value) {
                        setState(() {
                          _selectedRiskLevel = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Requires Training'),
                      value: _requiresTraining,
                      onChanged: (value) {
                        setState(() {
                          _requiresTraining = value;
                        });
                      },
                    ),
                    _buildSafetyInstructionsSection(),

                    // Actions
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Tool'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String label,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((T item) {
          final displayName = _getDisplayName(item);
          final color = _getColorForItem(item);
          return DropdownMenuItem<T>(
            value: item,
            child: Row(
              children: [
                if (item is ToolType) Icon(item.icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(displayName),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Specifications',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ..._specifications.asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('${spec.parameter}: ${spec.value} ${spec.unit}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _specifications.removeAt(index);
                  });
                },
              ),
            ),
          );
        }),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _specParameterController,
                decoration: const InputDecoration(
                  labelText: 'Parameter',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _specValueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _specUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: _addSpecification,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Safety Instructions',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ..._safetyInstructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(instruction),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _safetyInstructions.removeAt(index);
                  });
                },
              ),
            ),
          );
        }),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _safetyInstructionController,
                decoration: const InputDecoration(
                  labelText: 'Safety Instruction',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: _addSafetyInstruction,
            ),
          ],
        ),
      ],
    );
  }

  void _addSpecification() {
    final parameter = _specParameterController.text.trim();
    final value = _specValueController.text.trim();
    final unit = _specUnitController.text.trim();

    if (parameter.isNotEmpty && value.isNotEmpty && unit.isNotEmpty) {
      setState(() {
        _specifications.add(ToolSpecification(
          parameter: parameter,
          value: value,
          unit: unit,
        ));
        _specParameterController.clear();
        _specValueController.clear();
        _specUnitController.clear();
      });
    }
  }

  void _addSafetyInstruction() {
    final instruction = _safetyInstructionController.text.trim();
    if (instruction.isNotEmpty) {
      setState(() {
        _safetyInstructions.add(instruction);
        _safetyInstructionController.clear();
      });
    }
  }

  String _getDisplayName(dynamic item) {
    if (item is ToolType) return item.displayName;
    if (item is RiskLevel) return item.displayName;
    return item.toString();
  }

  Color _getColorForItem(dynamic item) {
    if (item is ToolType) return item.color;
    if (item is RiskLevel) return item.color;
    return Colors.black;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final toolData = {
        'toolName': _toolNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'toolType': _selectedType.name,
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'toolModel': _modelController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'specifications': _specifications.map((spec) => spec.toJson()).toList(),
        'currentLocation': _locationController.text.trim(),
        'purchasePrice': double.parse(_purchasePriceController.text),
        'currentValue': double.parse(_currentValueController.text),
        'safetyInstructions': _safetyInstructions,
        'requiresTraining': _requiresTraining,
        'riskLevel': _selectedRiskLevel.name,
        'maintenanceSchedule': {
          'lastMaintenanceDate': DateTime.now().toIso8601String(),
          'nextMaintenanceDate': DateTime.now()
              .add(Duration(
                  days: int.parse(_maintenanceIntervalController.text)))
              .toIso8601String(),
          'maintenanceInterval': int.parse(_maintenanceIntervalController.text),
          'maintenanceTasks': [],
        },
      };

      final toolNotifier = ref.read(toolProvider.notifier);
      final success = widget.tool != null
          ? toolNotifier.updateTool(widget.tool!.id, toolData)
          : toolNotifier.createTool(toolData);

      if (success != null) {
        widget.onSaved();
      }
    }
  }
}
