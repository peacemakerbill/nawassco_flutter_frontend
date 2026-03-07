import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../../providers/employee_provider.dart';

class CreateEmployeeProfileScreen extends ConsumerStatefulWidget {
  const CreateEmployeeProfileScreen({super.key});

  @override
  ConsumerState<CreateEmployeeProfileScreen> createState() =>
      _CreateEmployeeProfileScreenState();
}

class _CreateEmployeeProfileScreenState
    extends ConsumerState<CreateEmployeeProfileScreen> {
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
  DateTime? _dateOfBirth;
  DateTime? _hireDate;
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

  Future<void> _pickDate(BuildContext context, TextEditingController controller,
      Function(DateTime) onDateSelected) async {
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

  Future<void> _createProfile() async {
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
          'employmentStatus': 'active',
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
      final success = await provider.createEmployee(employeeData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee profile created successfully'),
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
                Icon(icon,
                    color: Theme.of(context).colorScheme.primary, size: 20),
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
    bool required = false,
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
          validator: validator ??
              (value) {
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
    final authState = ref.read(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Employee Profile'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Welcome Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete Your Employee Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please fill in your employment details to complete your profile setup.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
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
                          onTap: () => _pickDate(
                              context, _dateOfBirthController, (date) {
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
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          required: true,
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
                          onChanged: (value) =>
                              setState(() => _selectedMaritalStatus = value),
                          required: true,
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
                    onTap: () =>
                        _pickDate(context, _hireDateController, (date) {
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
                          onChanged: (value) =>
                              setState(() => _selectedEmploymentType = value),
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Employment Category',
                          value: _selectedEmploymentCategory,
                          items: _employmentCategories,
                          onChanged: (value) => setState(
                              () => _selectedEmploymentCategory = value),
                          required: true,
                        ),
                      ),
                    ],
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
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
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
                      onPressed: _isLoading ? null : _createProfile,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Profile'),
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
