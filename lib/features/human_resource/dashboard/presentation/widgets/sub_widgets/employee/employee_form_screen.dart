import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../models/employee_model.dart';
import '../../../../../providers/employee_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final Employee? employee;
  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _workEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workPhoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _socialSecurityController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _jobGradeController = TextEditingController();
  final _basicSalaryController = TextEditingController();
  final _salaryCurrencyController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _hireDateController = TextEditingController();

  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEmploymentType;
  String? _selectedEmploymentCategory;
  String? _selectedEmploymentStatus;
  DateTime? _dateOfBirth;
  DateTime? _hireDate;
  XFile? _profileImage;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _genders = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, dynamic>> _maritalStatuses = [
    {'value': 'single', 'label': 'Single'},
    {'value': 'married', 'label': 'Married'},
    {'value': 'divorced', 'label': 'Divorced'},
    {'value': 'widowed', 'label': 'Widowed'},
  ];

  final List<Map<String, dynamic>> _employmentTypes = [
    {'value': 'permanent', 'label': 'Permanent'},
    {'value': 'contract', 'label': 'Contract'},
    {'value': 'temporary', 'label': 'Temporary'},
    {'value': 'intern', 'label': 'Intern'},
    {'value': 'probation', 'label': 'Probation'},
  ];

  final List<Map<String, dynamic>> _employmentCategories = [
    {'value': 'management', 'label': 'Management'},
    {'value': 'professional', 'label': 'Professional'},
    {'value': 'technical', 'label': 'Technical'},
    {'value': 'administrative', 'label': 'Administrative'},
    {'value': 'operational', 'label': 'Operational'},
  ];

  final List<Map<String, dynamic>> _employmentStatuses = [
    {'value': 'active', 'label': 'Active'},
    {'value': 'on_leave', 'label': 'On Leave'},
    {'value': 'suspended', 'label': 'Suspended'},
    {'value': 'terminated', 'label': 'Terminated'},
    {'value': 'retired', 'label': 'Retired'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _loadEmployeeData();
    }
  }

  void _loadEmployeeData() {
    final employee = widget.employee!;
    setState(() {
      _firstNameController.text = employee.personalDetails.firstName;
      _lastNameController.text = employee.personalDetails.lastName;
      _middleNameController.text = employee.personalDetails.middleName ?? '';
      _emailController.text = employee.personalEmail;
      _workEmailController.text = employee.workEmail;
      _phoneController.text = employee.personalPhone;
      _workPhoneController.text = employee.workPhone ?? '';
      _nationalIdController.text = employee.personalDetails.nationalId;
      _passportController.text = employee.personalDetails.passportNumber ?? '';
      _taxNumberController.text = employee.personalDetails.taxNumber;
      _socialSecurityController.text = employee.personalDetails.socialSecurityNumber;
      _nationalityController.text = employee.personalDetails.nationality;
      _departmentController.text = employee.department;
      _jobTitleController.text = employee.jobTitle;
      _jobGradeController.text = employee.jobGrade;
      _basicSalaryController.text = employee.basicSalary.toString();
      _salaryCurrencyController.text = employee.salaryCurrency;

      _selectedGender = employee.personalDetails.gender.toString().split('.').last;
      _selectedMaritalStatus = employee.personalDetails.maritalStatus.toString().split('.').last;
      _selectedEmploymentType = employee.employmentType.toString().split('.').last;
      _selectedEmploymentCategory = employee.employmentCategory.toString().split('.').last;
      _selectedEmploymentStatus = employee.employmentStatus.toString().split('.').last;

      _dateOfBirth = employee.personalDetails.dateOfBirth;
      _hireDate = employee.hireDate;

      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
      _hireDateController.text = DateFormat('yyyy-MM-dd').format(_hireDate!);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = picked);
    }
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller, Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final employeeData = {
        'personalDetails': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'middleName': _middleNameController.text.trim().isNotEmpty
              ? _middleNameController.text.trim()
              : null,
          'dateOfBirth': _dateOfBirth!.toIso8601String(),
          'gender': _selectedGender!,
          'maritalStatus': _selectedMaritalStatus!,
          'nationality': _nationalityController.text.trim(),
          'nationalId': _nationalIdController.text.trim(),
          'passportNumber': _passportController.text.trim().isNotEmpty
              ? _passportController.text.trim()
              : null,
          'taxNumber': _taxNumberController.text.trim(),
          'socialSecurityNumber': _socialSecurityController.text.trim(),
        },
        'contactInformation': {
          'personalEmail': _emailController.text.trim(),
          'workEmail': _workEmailController.text.trim(),
          'personalPhone': _phoneController.text.trim(),
          'workPhone': _workPhoneController.text.trim().isNotEmpty
              ? _workPhoneController.text.trim()
              : null,
        },
        'employmentDetails': {
          'hireDate': _hireDate!.toIso8601String(),
          'employmentType': _selectedEmploymentType!,
          'employmentStatus': _selectedEmploymentStatus!,
          'employmentCategory': _selectedEmploymentCategory!,
        },
        'jobInformation': {
          'department': _departmentController.text.trim(),
          'jobTitle': _jobTitleController.text.trim(),
          'jobGrade': _jobGradeController.text.trim(),
        },
        'compensation': {
          'basicSalary': double.parse(_basicSalaryController.text.trim()),
          'salaryCurrency': _salaryCurrencyController.text.trim(),
        },
      };

      final provider = ref.read(employeeProvider.notifier);
      bool success;

      if (widget.employee == null) {
        success = await provider.createEmployee(employeeData);
      } else {
        success = await provider.updateEmployee(widget.employee!.id, employeeData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.employee == null
                    ? 'Employee created successfully'
                    : 'Employee updated successfully'
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              hint: Text('Select $label'),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${required ? ' *' : ''}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: validator ?? (value) {
            if (required && (value == null || value.isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required DateTime? selectedDate,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Select $label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select $label';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Employee' : 'Add New Employee'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Show delete confirmation
              },
              tooltip: 'Delete Employee',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: _profileImage != null
                            ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(File(_profileImage!.path)),
                        )
                            : CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to add profile photo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              _buildFormSection(
                'Personal Information',
                Icons.person,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'First Name',
                          controller: _firstNameController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Middle Name',
                    controller: _middleNameController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Date of Birth',
                          controller: _dateOfBirthController,
                          selectedDate: _dateOfBirth,
                          onTap: () => _pickDate(context, _dateOfBirthController, (date) {
                            setState(() => _dateOfBirth = date);
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Gender',
                          value: _selectedGender,
                          items: _genders,
                          onChanged: (value) => setState(() => _selectedGender = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Marital Status',
                          value: _selectedMaritalStatus,
                          items: _maritalStatuses,
                          onChanged: (value) => setState(() => _selectedMaritalStatus = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Nationality',
                          controller: _nationalityController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'National ID',
                    controller: _nationalIdController,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Passport Number',
                    controller: _passportController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Tax Number',
                          controller: _taxNumberController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Social Security',
                          controller: _socialSecurityController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contact Information
              _buildFormSection(
                'Contact Information',
                Icons.contact_mail,
                [
                  _buildTextField(
                    label: 'Personal Email',
                    controller: _emailController,
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Work Email',
                    controller: _workEmailController,
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Personal Phone',
                          controller: _phoneController,
                          required: true,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Work Phone',
                          controller: _workPhoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Employment Information
              _buildFormSection(
                'Employment Information',
                Icons.business_center,
                [
                  _buildDateField(
                    label: 'Hire Date',
                    controller: _hireDateController,
                    selectedDate: _hireDate,
                    onTap: () => _pickDate(context, _hireDateController, (date) {
                      setState(() => _hireDate = date);
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Employment Type',
                          value: _selectedEmploymentType,
                          items: _employmentTypes,
                          onChanged: (value) => setState(() => _selectedEmploymentType = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Employment Status',
                          value: _selectedEmploymentStatus,
                          items: _employmentStatuses,
                          onChanged: (value) => setState(() => _selectedEmploymentStatus = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Employment Category',
                    value: _selectedEmploymentCategory,
                    items: _employmentCategories,
                    onChanged: (value) => setState(() => _selectedEmploymentCategory = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Department',
                          controller: _departmentController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Job Title',
                          controller: _jobTitleController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Job Grade',
                    controller: _jobGradeController,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Compensation
              _buildFormSection(
                'Compensation',
                Icons.monetization_on,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Basic Salary',
                          controller: _basicSalaryController,
                          required: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter basic salary';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Currency',
                          controller: _salaryCurrencyController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                      onPressed: _isLoading ? null : _saveEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(isEdit ? 'Update Employee' : 'Create Employee'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _workEmailController.dispose();
    _phoneController.dispose();
    _workPhoneController.dispose();
    _nationalIdController.dispose();
    _passportController.dispose();
    _taxNumberController.dispose();
    _socialSecurityController.dispose();
    _nationalityController.dispose();
    _departmentController.dispose();
    _jobTitleController.dispose();
    _jobGradeController.dispose();
    _basicSalaryController.dispose();
    _salaryCurrencyController.dispose();
    _dateOfBirthController.dispose();
    _hireDateController.dispose();
    super.dispose();
  }
}