import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/accountant.model.dart';
import '../../../../providers/accountant_providers.dart';

class AccountantFormDialog extends ConsumerStatefulWidget {
  final Accountant? accountant;
  final bool isCreateProfile;

  const AccountantFormDialog({super.key, this.accountant, this.isCreateProfile = false});

  @override
  ConsumerState<AccountantFormDialog> createState() => _AccountantFormDialogState();
}

class _AccountantFormDialogState extends ConsumerState<AccountantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _employeeNumberCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _workLocationCtrl = TextEditingController();
  final _costCenterCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();
  final _socialSecurityCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyRelationCtrl = TextEditingController();

  String? _jobTitle;
  String? _employmentType;
  String? _employmentStatus;
  String? _gender;
  DateTime? _dateOfBirth;
  DateTime? _hireDate;
  double? _salary;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isAuthorizedSignatory = false;

  // Specialized areas
  final List<String> _specializedAreasOptions = [
    'financial_reporting',
    'taxation',
    'auditing',
    'cost_accounting',
    'management_accounting',
    'budgeting',
    'payroll',
    'accounts_payable',
    'accounts_receivable',
    'fixed_assets'
  ];

  final List<String> _specializedAreasDisplay = [
    'Financial Reporting',
    'Taxation',
    'Auditing',
    'Cost Accounting',
    'Management Accounting',
    'Budgeting',
    'Payroll',
    'Accounts Payable',
    'Accounts Receivable',
    'Fixed Assets'
  ];

  final List<String> _softwareProficienciesOptions = [
    'sap',
    'oracle',
    'quickbooks',
    'sage',
    'ms_dynamics',
    'tally',
    'pastel',
    'custom_system'
  ];

  final List<String> _softwareProficienciesDisplay = [
    'SAP',
    'Oracle',
    'QuickBooks',
    'Sage',
    'MS Dynamics',
    'Tally',
    'Pastel',
    'Custom System'
  ];

  List<String> _selectedSpecializedAreas = [];
  List<String> _selectedSoftwareProficiencies = [];

  final List<String> _jobTitleOptions = [
    'chief_accountant',
    'senior_accountant',
    'accountant',
    'junior_accountant',
    'cost_accountant',
    'management_accountant',
    'tax_accountant',
    'payroll_accountant',
    'accounts_payable',
    'accounts_receivable'
  ];

  final List<String> _jobTitleDisplayOptions = [
    'Chief Accountant',
    'Senior Accountant',
    'Accountant',
    'Junior Accountant',
    'Cost Accountant',
    'Management Accountant',
    'Tax Accountant',
    'Payroll Accountant',
    'Accounts Payable',
    'Accounts Receivable'
  ];

  final List<String> _employmentTypeOptions = [
    'full_time',
    'part_time',
    'contract',
    'intern'
  ];

  final List<String> _employmentTypeDisplayOptions = [
    'Full Time',
    'Part Time',
    'Contract',
    'Intern'
  ];

  final List<String> _employmentStatusOptions = [
    'active',
    'on_leave',
    'suspended',
    'terminated'
  ];

  final List<String> _employmentStatusDisplayOptions = [
    'Active',
    'On Leave',
    'Suspended',
    'Terminated'
  ];

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.accountant != null) {
      _initializeForm(widget.accountant!);
    } else {
      // Set defaults for new accountant
      _jobTitle = 'accountant';
      _employmentType = 'full_time';
      _employmentStatus = 'active';
      _departmentCtrl.text = 'Accounts';
      _isActive = true;
      _workLocationCtrl.text = 'Head Office';
      _costCenterCtrl.text = 'FIN-001';
    }
  }

  void _initializeForm(Accountant accountant) {
    _firstNameCtrl.text = accountant.firstName;
    _lastNameCtrl.text = accountant.lastName;
    _emailCtrl.text = accountant.email;
    _phoneCtrl.text = accountant.phoneNumber ?? accountant.phone ?? '';
    _employeeNumberCtrl.text = accountant.employeeNumber ?? '';
    _departmentCtrl.text = accountant.department ?? 'Accounts';
    _addressCtrl.text = accountant.address ?? '';
    _nationalIdCtrl.text = accountant.nationalId ?? '';
    _workLocationCtrl.text = accountant.workLocation ?? 'Head Office';
    _costCenterCtrl.text = accountant.costCenter ?? 'FIN-001';
    _bankNameCtrl.text = accountant.bankName ?? '';
    _bankAccountCtrl.text = accountant.bankAccountNumber ?? '';
    _taxNumberCtrl.text = accountant.taxNumber ?? '';
    _socialSecurityCtrl.text = accountant.socialSecurityNumber ?? '';
    _emergencyNameCtrl.text = accountant.emergencyContactName ?? '';
    _emergencyPhoneCtrl.text = accountant.emergencyContactPhone ?? '';
    _emergencyRelationCtrl.text = accountant.emergencyContactRelationship ?? '';

    _jobTitle = accountant.jobTitle ?? 'accountant';
    _employmentType = accountant.employmentType ?? 'full_time';
    _employmentStatus = accountant.employmentStatus ?? 'active';
    _gender = accountant.gender;
    _dateOfBirth = accountant.dateOfBirth;
    _hireDate = accountant.hireDate;
    _salary = accountant.salary;
    _isActive = accountant.isActive;
    _isAuthorizedSignatory = accountant.isAuthorizedSignatory ?? false;

    // Initialize arrays
    if (accountant.specializedAreas != null) {
      _selectedSpecializedAreas = List<String>.from(accountant.specializedAreas!);
    }

    if (accountant.softwareProficiencies != null) {
      _selectedSoftwareProficiencies = List<String>.from(accountant.softwareProficiencies!);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _employeeNumberCtrl.dispose();
    _departmentCtrl.dispose();
    _addressCtrl.dispose();
    _nationalIdCtrl.dispose();
    _workLocationCtrl.dispose();
    _costCenterCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    _taxNumberCtrl.dispose();
    _socialSecurityCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _emergencyRelationCtrl.dispose();
    super.dispose();
  }

  void _showToastSafely(VoidCallback showToast) {
    try {
      if (mounted) {
        showToast();
      }
    } catch (e) {
      print('Error showing toast: $e');
    }
  }

  Future<void> _saveAccountant() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields that might not be in form validation
    if (_dateOfBirth == null) {
      _showToastSafely(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Date of Birth is required'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      return;
    }

    if (_hireDate == null) {
      _showToastSafely(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hire Date is required'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      return;
    }

    if (_nationalIdCtrl.text.trim().isEmpty) {
      _showToastSafely(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('National ID is required'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      return;
    }

    // Employee number is required by backend schema, so generate one if not provided
    String employeeNumber = _employeeNumberCtrl.text.trim();
    if (employeeNumber.isEmpty) {
      // Generate a temporary employee number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 1000).toString().padLeft(3, '0');
      employeeNumber = 'ACC-${DateTime.now().year}-$random';
      _employeeNumberCtrl.text = employeeNumber; // Update controller for display
    }

    setState(() => _isLoading = true);

    try {
      final accountant = Accountant(
        id: widget.accountant?.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : '000-0000000',
        employeeNumber: employeeNumber,
        jobTitle: _jobTitle ?? 'accountant',
        department: _departmentCtrl.text.trim(),
        employmentType: _employmentType ?? 'full_time',
        employmentStatus: _employmentStatus ?? 'active',
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
        hireDate: _hireDate!,
        isActive: _isActive,
        nationalId: _nationalIdCtrl.text.trim(),
        workLocation: _workLocationCtrl.text.trim(),
        costCenter: _costCenterCtrl.text.trim(),
        bankName: _bankNameCtrl.text.trim().isNotEmpty ? _bankNameCtrl.text.trim() : null,
        bankAccountNumber: _bankAccountCtrl.text.trim().isNotEmpty ? _bankAccountCtrl.text.trim() : null,
        taxNumber: _taxNumberCtrl.text.trim().isNotEmpty ? _taxNumberCtrl.text.trim() : null,
        socialSecurityNumber: _socialSecurityCtrl.text.trim().isNotEmpty ? _socialSecurityCtrl.text.trim() : null,
        emergencyContactName: _emergencyNameCtrl.text.trim().isNotEmpty ? _emergencyNameCtrl.text.trim() : null,
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim().isNotEmpty ? _emergencyPhoneCtrl.text.trim() : null,
        emergencyContactRelationship: _emergencyRelationCtrl.text.trim().isNotEmpty ? _emergencyRelationCtrl.text.trim() : null,
        salary: _salary,
        specializedAreas: _selectedSpecializedAreas.isNotEmpty ? _selectedSpecializedAreas : null,
        softwareProficiencies: _selectedSoftwareProficiencies.isNotEmpty ? _selectedSoftwareProficiencies : null,
        isAuthorizedSignatory: _isAuthorizedSignatory,
      );

      print('=== SAVING ACCOUNTANT DATA ===');
      print('Generated Employee Number: $employeeNumber');
      print('Date of Birth: ${_dateOfBirth}');
      print('Hire Date: ${_hireDate}');
      print('National ID: ${_nationalIdCtrl.text.trim()}');
      print('Full data: ${accountant.toJson()}');

      if (widget.accountant == null) {
        // Creating new accountant
        await ref.read(accountantsManagementProvider.notifier).createAccountant(accountant);

        // If this is a profile creation, also refresh the profile provider
        if (widget.isCreateProfile) {
          // Wait a bit for the backend to process, then refresh profile
          await Future.delayed(const Duration(milliseconds: 1000));
          ref.read(accountantProfileProvider.notifier).refresh();
        }
      } else {
        // Updating existing accountant
        await ref.read(accountantsManagementProvider.notifier).updateAccountant(accountant.id!, accountant);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isCreateProfile ? 'Profile created successfully!' :
            widget.accountant == null ? 'Accountant created successfully!' : 'Accountant updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save accountant: $e'),
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

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? (_dateOfBirth ?? DateTime(1990)) : (_hireDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _hireDate = picked;
        }
      });
    }
  }

  Widget _buildDateField(String label, DateTime? date, bool isBirthDate, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectDate(context, isBirthDate),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: '$label *',
            border: const OutlineInputBorder(),
            filled: true,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Select $label *',
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

  String _getDisplayValue(String? value, List<String> displayOptions, List<String> backendOptions) {
    if (value == null) return 'Select';
    final index = backendOptions.indexOf(value);
    return index != -1 ? displayOptions[index] : value;
  }

  // Build multi-select chips
  Widget _buildMultiSelectChips(
      String label,
      List<String> selectedValues,
      List<String> backendOptions,
      List<String> displayOptions,
      Function(List<String>) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: backendOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final backendValue = entry.value;
              final displayValue = displayOptions[index];
              final isSelected = selectedValues.contains(backendValue);

              return FilterChip(
                label: Text(displayValue),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedValues.add(backendValue);
                    } else {
                      selectedValues.remove(backendValue);
                    }
                    onChanged(selectedValues);
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.accountant != null;
    final isCreateProfile = widget.isCreateProfile;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Form(
          key: _formKey,
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
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isCreateProfile ? 'Create Accountant Profile' :
                      isEditing ? 'Edit Accountant' : 'Add New Accountant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
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
                      // Personal Information
                      _buildSection('Personal Information', Icons.person_rounded, [
                        _buildTextField(_firstNameCtrl, 'First Name', true),
                        _buildTextField(_lastNameCtrl, 'Last Name', true),
                        _buildTextField(_emailCtrl, 'Email', true, TextInputType.emailAddress),
                        _buildTextField(_phoneCtrl, 'Phone Number', true, TextInputType.phone),
                        _buildTextField(_nationalIdCtrl, 'National ID', true),
                        _buildDropdown(
                          'Gender',
                          _gender,
                          _genderOptions,
                              (value) => setState(() => _gender = value),
                          isRequired: true,
                        ),
                        _buildDateField('Date of Birth', _dateOfBirth, true, theme),
                        _buildTextField(_addressCtrl, 'Address (Optional)', false, TextInputType.multiline, 3),
                      ]),

                      const SizedBox(height: 20),

                      // Employment Information
                      _buildSection('Employment Information', Icons.work_rounded, [
                        _buildTextField(_employeeNumberCtrl, 'Employee Number (Auto-generated if empty)', false),
                        _buildTextField(_departmentCtrl, 'Department', true),
                        _buildTextField(_workLocationCtrl, 'Work Location', true),
                        _buildTextField(_costCenterCtrl, 'Cost Center', true),
                        _buildDropdownWithDisplay(
                          'Job Title *',
                          _jobTitle,
                          _jobTitleOptions,
                          _jobTitleDisplayOptions,
                              (value) => setState(() => _jobTitle = value),
                          isRequired: true,
                        ),
                        _buildDropdownWithDisplay(
                          'Employment Type *',
                          _employmentType,
                          _employmentTypeOptions,
                          _employmentTypeDisplayOptions,
                              (value) => setState(() => _employmentType = value),
                          isRequired: true,
                        ),
                        _buildDropdownWithDisplay(
                          'Employment Status *',
                          _employmentStatus,
                          _employmentStatusOptions,
                          _employmentStatusDisplayOptions,
                              (value) => setState(() => _employmentStatus = value),
                          isRequired: true,
                        ),
                        _buildDateField('Hire Date', _hireDate, false, theme),
                      ]),

                      const SizedBox(height: 20),

                      // Financial Information
                      _buildSection('Financial Information', Icons.account_balance_wallet_rounded, [
                        _buildTextField(_bankNameCtrl, 'Bank Name (Optional)', false),
                        _buildTextField(_bankAccountCtrl, 'Bank Account Number (Optional)', false),
                        _buildTextField(_taxNumberCtrl, 'Tax Number (Optional)', false),
                        _buildTextField(_socialSecurityCtrl, 'Social Security Number (Optional)', false),
                      ]),

                      const SizedBox(height: 20),

                      // Emergency Contact
                      _buildSection('Emergency Contact', Icons.emergency_rounded, [
                        _buildTextField(_emergencyNameCtrl, 'Emergency Contact Name (Optional)', false),
                        _buildTextField(_emergencyPhoneCtrl, 'Emergency Contact Phone (Optional)', false, TextInputType.phone),
                        _buildTextField(_emergencyRelationCtrl, 'Emergency Contact Relationship (Optional)', false),
                      ]),

                      const SizedBox(height: 20),

                      // Accounting Specializations
                      _buildSection('Accounting Specializations', Icons.school_rounded, [
                        _buildMultiSelectChips(
                          'Specialized Areas (Optional)',
                          _selectedSpecializedAreas,
                          _specializedAreasOptions,
                          _specializedAreasDisplay,
                              (values) => setState(() => _selectedSpecializedAreas = values),
                        ),
                        _buildMultiSelectChips(
                          'Software Proficiencies (Optional)',
                          _selectedSoftwareProficiencies,
                          _softwareProficienciesOptions,
                          _softwareProficienciesDisplay,
                              (values) => setState(() => _selectedSoftwareProficiencies = values),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Additional Settings
                      _buildSection('Additional Settings', Icons.settings_rounded, [
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('Active Accountant'),
                                value: _isActive,
                                onChanged: (value) => setState(() => _isActive = value),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('Authorized Signatory'),
                                value: _isAuthorizedSignatory,
                                onChanged: (value) => setState(() => _isAuthorizedSignatory = value),
                              ),
                            ),
                          ],
                        ),
                      ]),
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
                        onPressed: _isLoading ? null : _saveAccountant,
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(isCreateProfile ? 'Create Profile' : isEditing ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool required, [TextInputType? keyboardType, int maxLines = 1]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: const OutlineInputBorder(),
          filled: true,
          hintText: !required ? '(Optional)' : null,
        ),
        validator: required
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        }
            : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          border: const OutlineInputBorder(),
          filled: true,
        ),
        items: [
          DropdownMenuItem(value: null, child: Text('Select $label', style: const TextStyle(color: Colors.grey))),
          ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
        ],
        onChanged: onChanged,
        validator: isRequired ? (value) => value == null ? 'Please select $label' : null : null,
      ),
    );
  }

  Widget _buildDropdownWithDisplay(String label, String? value, List<String> backendOptions,
      List<String> displayOptions, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        items: [
          DropdownMenuItem(value: null, child: Text('Select $label', style: const TextStyle(color: Colors.grey))),
          ...backendOptions.asMap().entries.map((entry) =>
              DropdownMenuItem(
                value: entry.value,
                child: Text(displayOptions[entry.key]),
              )
          ),
        ],
        onChanged: onChanged,
        validator: isRequired ? (value) => value == null ? 'Please select $label' : null : null,
      ),
    );
  }
}