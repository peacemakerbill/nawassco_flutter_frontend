import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../main.dart';
import '../../../../../models/department.dart';
import '../../../../../providers/department_provider.dart';
import '../../../../../utils/department_constants.dart';
import 'package:nawassco/core/utils/toast_utils.dart';

class DepartmentForm extends ConsumerStatefulWidget {
  final Department? department;
  final VoidCallback onSuccess;

  const DepartmentForm({
    super.key,
    this.department,
    required this.onSuccess,
  });

  @override
  ConsumerState<DepartmentForm> createState() => _DepartmentFormState();
}

class _DepartmentFormState extends ConsumerState<DepartmentForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  late List<Map<String, dynamic>> _availableEmployees;
  late List<Map<String, dynamic>> _availableDepartments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formData = {
      'departmentCode': widget.department?.departmentCode ?? '',
      'name': widget.department?.name ?? '',
      'description': widget.department?.description ?? '',
      'head': widget.department?.headId ?? '',
      'parentDepartment': widget.department?.parentDepartmentId ?? '',
      'budget': widget.department?.budget.toString() ?? '0',
      'location': widget.department?.location ?? DepartmentConstants.departmentLocations.first,
      'contactEmail': widget.department?.contactEmail ?? '',
      'contactPhone': widget.department?.contactPhone ?? '',
      'isActive': widget.department?.isActive ?? true,
    };
    _availableEmployees = [];
    _availableDepartments = [];
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);

    try {
      // Load potential department heads
      final provider = ref.read(departmentProvider.notifier);
      final employees = await provider.getPotentialDepartmentHeads();

      // Load available parent departments
      final state = ref.read(departmentProvider);
      final departments = state.departments
          .where((dept) => dept.id != widget.department?.id) // Exclude self if editing
          .map((dept) => {
        'id': dept.id,
        'name': '${dept.name} (${dept.departmentCode})',
        'code': dept.departmentCode,
      })
          .toList();

      setState(() {
        _availableEmployees = employees;
        _availableDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastUtils.showErrorToast('Failed to load dropdown data', key: scaffoldMessengerKey);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final provider = ref.read(departmentProvider.notifier);
      final data = Map<String, dynamic>.from(_formData);

      // Convert budget to double
      data['budget'] = double.tryParse(data['budget'].toString()) ?? 0;

      // Handle parent department - send empty string if null/empty
      if (data['parentDepartment'] == null || data['parentDepartment'].toString().isEmpty) {
        data['parentDepartment'] = '';
      }

      if (widget.department == null) {
        // Create new department
        await provider.createDepartment(data);
      } else {
        // Update existing department
        await provider.updateDepartment(widget.department!.id, data);
      }

      widget.onSuccess();
    } catch (e) {
      // Error is handled by provider
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required String fieldName,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData[fieldName]?.toString(),
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onSaved: (value) => _formData[fieldName] = value,
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildHeadDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData['head']?.isNotEmpty == true ? _formData['head'] : null,
        decoration: InputDecoration(
          labelText: 'Department Head *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.person),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('Select Department Head', style: TextStyle(color: Colors.grey)),
          ),
          ..._availableEmployees.map((employee) => DropdownMenuItem<String>(
            value: employee['id']?.toString(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (employee['jobTitle'] != null && employee['employeeNumber'] != null)
                  Text(
                    '${employee['jobTitle']} • ${employee['employeeNumber']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          )).toList(),
        ],
        onChanged: (value) {
          setState(() {
            _formData['head'] = value ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Department head is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildParentDepartmentDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData['parentDepartment']?.isNotEmpty == true ? _formData['parentDepartment'] : null,
        decoration: InputDecoration(
          labelText: 'Parent Department',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.account_tree),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('No Parent Department', style: TextStyle(color: Colors.grey)),
          ),
          ..._availableDepartments.map((dept) => DropdownMenuItem<String>(
            value: dept['id']?.toString(),
            child: Text(dept['name'] ?? 'Unknown'),
          )).toList(),
        ],
        onChanged: (value) {
          setState(() {
            _formData['parentDepartment'] = value ?? '';
          });
        },
      ),
    );
  }

  Widget _buildBudgetField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData['budget']?.toString(),
        decoration: InputDecoration(
          labelText: 'Budget (KES) *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.attach_money),
          prefixText: 'KES ',
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onSaved: (value) => _formData['budget'] = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Budget is required';
          }
          final amount = double.tryParse(value);
          if (amount == null || amount < 0) {
            return 'Please enter a valid amount';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData['location']?.isNotEmpty == true ? _formData['location'] : DepartmentConstants.departmentLocations.first,
        decoration: InputDecoration(
          labelText: 'Location *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.location_on),
        ),
        items: DepartmentConstants.departmentLocations
            .map((location) => DropdownMenuItem<String>(
          value: location,
          child: Text(location),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _formData['location'] = value ?? DepartmentConstants.departmentLocations.first;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Location is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Templates',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DepartmentConstants.departmentTemplates.map((template) {
            return FilterChip(
              label: Text(template['code']),
              selected: _formData['departmentCode'] == template['code'],
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _formData['departmentCode'] = template['code'];
                    _formData['name'] = template['name'];
                    _formData['description'] = template['description'];
                    _formData['budget'] = template['budget'].toString();

                    // Auto-select appropriate location based on template
                    if (template['code'] == 'HR') {
                      _formData['location'] = 'Nairobi Head Office';
                    } else if (template['code'] == 'IT') {
                      _formData['location'] = 'Nairobi Head Office';
                    }
                  });
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: _formData['departmentCode'] == template['code']
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: _formData['departmentCode'] == template['code']
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(departmentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.department == null ? 'Create Department' : 'Edit Department',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onSuccess(),
        ),
        actions: [
          if (widget.department != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Department'),
                    content: const Text(
                      'Are you sure you want to delete this department? '
                          'This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final provider = ref.read(departmentProvider.notifier);
                          await provider.deleteDepartment(widget.department!.id);
                          widget.onSuccess();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: state.isFormLoading || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick templates (only for creation)
              if (widget.department == null) ...[
                _buildTemplateSelector(),
                const Divider(height: 32, color: Colors.grey),
              ],

              // Department Code
              _buildFormField(
                label: 'Department Code',
                fieldName: 'departmentCode',
                prefixIcon: const Icon(Icons.code),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Department code is required';
                  }
                  if (!RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(value)) {
                    return 'Use uppercase letters/numbers only (2-10 chars)';
                  }
                  return null;
                },
              ),

              // Department Name
              _buildFormField(
                label: 'Department Name',
                fieldName: 'name',
                prefixIcon: const Icon(Icons.business),
              ),

              // Description
              _buildFormField(
                label: 'Description',
                fieldName: 'description',
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),

              // Head Selection
              _buildHeadDropdownField(),

              // Parent Department
              _buildParentDepartmentDropdownField(),

              // Budget
              _buildBudgetField(),

              // Location
              _buildLocationDropdownField(),

              // Contact Email
              _buildFormField(
                label: 'Contact Email',
                fieldName: 'contactEmail',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact email is required';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              // Contact Phone
              _buildFormField(
                label: 'Contact Phone',
                fieldName: 'contactPhone',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact phone is required';
                  }
                  if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              // Status Toggle (only for editing)
              if (widget.department != null)
                Card(
                  child: SwitchListTile(
                    title: const Text('Active Department'),
                    subtitle: const Text('Toggle to activate or deactivate the department'),
                    value: _formData['isActive'] == true,
                    onChanged: (value) {
                      setState(() {
                        _formData['isActive'] = value;
                      });
                    },
                    secondary: Icon(
                      _formData['isActive'] == true
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      color: _formData['isActive'] == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Form Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => widget.onSuccess(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.department == null ? 'Create Department' : 'Update Department',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Validation Summary
              if (state.error != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[400]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}