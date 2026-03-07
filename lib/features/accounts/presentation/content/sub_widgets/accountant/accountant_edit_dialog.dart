import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/accountant.model.dart';
import '../../../../providers/accountant_providers.dart';

class AccountantEditDialog extends ConsumerStatefulWidget {
  final Accountant accountant;
  final String section;

  const AccountantEditDialog({
    super.key,
    required this.accountant,
    required this.section,
  });

  @override
  ConsumerState<AccountantEditDialog> createState() => _AccountantEditDialogState();
}

class _AccountantEditDialogState extends ConsumerState<AccountantEditDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedGender;
  String? _selectedJobTitle;
  String? _selectedDepartment;
  String? _selectedEmploymentType;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedHireDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeDropdowns();
  }

  void _initializeControllers() {
    final accountant = widget.accountant;

    // Personal Information
    _controllers['firstName'] = TextEditingController(text: accountant.firstName);
    _controllers['lastName'] = TextEditingController(text: accountant.lastName);
    _controllers['email'] = TextEditingController(text: accountant.email);
    _controllers['phoneNumber'] = TextEditingController(text: accountant.phoneNumber ?? '');
    _controllers['address'] = TextEditingController(text: accountant.address ?? '');
    _controllers['nationalId'] = TextEditingController(text: accountant.nationalId ?? '');

    // Employment Information
    _controllers['employeeNumber'] = TextEditingController(text: accountant.employeeNumber ?? '');

    // Financial Information
    _controllers['bankName'] = TextEditingController(text: accountant.bankName ?? '');
    _controllers['bankAccountNumber'] = TextEditingController(text: accountant.bankAccountNumber ?? '');
    _controllers['taxNumber'] = TextEditingController(text: accountant.taxNumber ?? '');
    _controllers['socialSecurityNumber'] = TextEditingController(text: accountant.socialSecurityNumber ?? '');

    // Emergency Contact
    _controllers['emergencyContactName'] = TextEditingController(text: accountant.emergencyContactName ?? '');
    _controllers['emergencyContactPhone'] = TextEditingController(text: accountant.emergencyContactPhone ?? '');
    _controllers['emergencyContactRelationship'] = TextEditingController(text: accountant.emergencyContactRelationship ?? '');
  }

  void _initializeDropdowns() {
    final accountant = widget.accountant;
    _selectedGender = accountant.gender;
    _selectedJobTitle = accountant.jobTitle;
    _selectedDepartment = accountant.department;
    _selectedEmploymentType = accountant.employmentType;
    _selectedDateOfBirth = accountant.dateOfBirth;
    _selectedHireDate = accountant.hireDate;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final updateData = <String, dynamic>{};

      switch (widget.section) {
        case 'personal':
          updateData.addAll({
            'firstName': _controllers['firstName']!.text.trim(),
            'lastName': _controllers['lastName']!.text.trim(),
            'email': _controllers['email']!.text.trim(),
            'phoneNumber': _controllers['phoneNumber']!.text.trim(),
            'gender': _selectedGender,
            'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
            'address': _controllers['address']!.text.trim(),
            'nationalId': _controllers['nationalId']!.text.trim(),
          });
          break;

        case 'employment':
          updateData.addAll({
            'employeeNumber': _controllers['employeeNumber']!.text.trim(),
            'jobTitle': _selectedJobTitle,
            'department': _selectedDepartment,
            'employmentType': _selectedEmploymentType,
            'hireDate': _selectedHireDate?.toIso8601String(),
          });
          break;

        case 'financial':
          updateData.addAll({
            'bankName': _controllers['bankName']!.text.trim(),
            'bankAccountNumber': _controllers['bankAccountNumber']!.text.trim(),
            'taxNumber': _controllers['taxNumber']!.text.trim(),
            'socialSecurityNumber': _controllers['socialSecurityNumber']!.text.trim(),
          });
          break;

        case 'emergency':
          updateData.addAll({
            'emergencyContactName': _controllers['emergencyContactName']!.text.trim(),
            'emergencyContactPhone': _controllers['emergencyContactPhone']!.text.trim(),
            'emergencyContactRelationship': _controllers['emergencyContactRelationship']!.text.trim(),
          });
          break;
      }

      // Remove null or empty values
      updateData.removeWhere((key, value) => value == null || value.toString().isEmpty);

      await ref.read(accountantProfileProvider.notifier).updateProfile(updateData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getSectionTitle()} updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ${_getSectionTitle()}: $e'),
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

  String _getSectionTitle() {
    switch (widget.section) {
      case 'personal': return 'Personal Information';
      case 'employment': return 'Employment Information';
      case 'financial': return 'Financial Information';
      case 'emergency': return 'Emergency Contact';
      default: return 'Information';
    }
  }

  IconData _getSectionIcon() {
    switch (widget.section) {
      case 'personal': return Icons.person_rounded;
      case 'employment': return Icons.work_rounded;
      case 'financial': return Icons.account_balance_wallet_rounded;
      case 'emergency': return Icons.emergency_rounded;
      default: return Icons.edit_rounded;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final initialDate = isBirthDate ? _selectedDateOfBirth : _selectedHireDate;
    final firstDate = isBirthDate ? DateTime(1900) : DateTime(2000);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? (isBirthDate ? DateTime(1990) : DateTime.now()),
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedHireDate = picked;
        }
      });
    }
  }

  Widget _buildPersonalSection() {
    return Column(
      children: [
        _buildTextField('firstName', 'First Name', true),
        _buildTextField('lastName', 'Last Name', true),
        _buildTextField('email', 'Email', true, TextInputType.emailAddress),
        _buildTextField('phoneNumber', 'Phone Number', false, TextInputType.phone),
        _buildDropdown(
          'Gender',
          _selectedGender,
          ['Male', 'Female', 'Other'],
              (value) => setState(() => _selectedGender = value),
        ),
        _buildDateField('Date of Birth', _selectedDateOfBirth, true),
        _buildTextField('address', 'Address', false, TextInputType.multiline, 3),
        _buildTextField('nationalId', 'National ID', false),
      ],
    );
  }

  Widget _buildEmploymentSection() {
    return Column(
      children: [
        _buildTextField('employeeNumber', 'Employee Number', false),
        _buildDropdown(
          'Job Title',
          _selectedJobTitle,
          ['Chief Accountant', 'Senior Accountant', 'Accountant', 'Junior Accountant', 'Accounting Clerk'],
              (value) => setState(() => _selectedJobTitle = value),
        ),
        _buildDropdown(
          'Department',
          _selectedDepartment,
          ['Finance', 'Accounting', 'Management', 'HR', 'Operations'],
              (value) => setState(() => _selectedDepartment = value),
        ),
        _buildDropdown(
          'Employment Type',
          _selectedEmploymentType,
          ['Full-Time', 'Part-Time', 'Contract', 'Temporary', 'Intern'],
              (value) => setState(() => _selectedEmploymentType = value),
        ),
        _buildDateField('Hire Date', _selectedHireDate, false),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return Column(
      children: [
        _buildTextField('bankName', 'Bank Name', false),
        _buildTextField('bankAccountNumber', 'Bank Account Number', false),
        _buildTextField('taxNumber', 'Tax Identification Number', false),
        _buildTextField('socialSecurityNumber', 'Social Security Number', false),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      children: [
        _buildTextField('emergencyContactName', 'Contact Name', false),
        _buildTextField('emergencyContactPhone', 'Contact Phone', false, TextInputType.phone),
        _buildTextField('emergencyContactRelationship', 'Relationship', false),
      ],
    );
  }

  Widget _buildTextField(String key, String label, bool required, [TextInputType? keyboardType, int maxLines = 1]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: const OutlineInputBorder(),
          filled: true,
        ),
        validator: required ? (value) => value?.isEmpty ?? true ? 'Please enter $label' : null : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        items: [
          DropdownMenuItem(value: null, child: Text('Select $label', style: const TextStyle(color: Colors.grey))),
          ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isBirthDate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDate(context, isBirthDate),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
            filled: true,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Select $label',
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey,
                ),
              ),
              const Icon(Icons.calendar_today_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(_getSectionIcon(), color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Edit ${_getSectionTitle()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Dynamic Section Content
                    switch (widget.section) {
                      'personal' => _buildPersonalSection(),
                      'employment' => _buildEmploymentSection(),
                      'financial' => _buildFinancialSection(),
                      'emergency' => _buildEmergencySection(),
                      _ => const Text('Unknown section'),
                    },
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}