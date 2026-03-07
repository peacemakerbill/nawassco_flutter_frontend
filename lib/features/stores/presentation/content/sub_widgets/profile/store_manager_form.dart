import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';
import '../../../../providers/store_manager_admin_provider.dart';

class StoreManagerForm extends ConsumerStatefulWidget {
  final String mode; // 'create' or 'edit'
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const StoreManagerForm({
    super.key,
    required this.mode,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<StoreManagerForm> createState() => _StoreManagerFormState();
}

class _StoreManagerFormState extends ConsumerState<StoreManagerForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _employeeNumberController = TextEditingController();
  final _userIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _workEmailController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _workPhoneController = TextEditingController();
  final _personalPhoneController = TextEditingController();
  final _officeLocationController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _locationController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _reportingToController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _storesAllowanceController = TextEditingController();
  final _performanceBonusController = TextEditingController();
  final _inventoryAccuracyBonusController = TextEditingController();

  // Form values
  Gender _selectedGender = Gender.MALE;
  StoreManagerRole _selectedRole = StoreManagerRole.STORES_MANAGER;
  StoreManagementLevel _selectedManagementLevel = StoreManagementLevel.OPERATIONAL_MANAGEMENT;
  EmploymentType _selectedEmploymentType = EmploymentType.FULL_TIME;
  EmploymentStatus _selectedEmploymentStatus = EmploymentStatus.ACTIVE;
  DateTime? _hireDate;
  DateTime? _compensationReviewDate;

  List<String> _assignedWarehouses = [];
  List<String> _storesManaged = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.mode == 'edit') {
      final storeManager = ref.read(storeManagerAdminProvider).selectedStoreManager;
      if (storeManager != null) {
        _populateFormWithData(storeManager);
      }
    } else {
      _hireDate = DateTime.now();
      _compensationReviewDate = DateTime.now().add(const Duration(days: 365));
    }
  }

  void _populateFormWithData(StoreManager storeManager) {
    _employeeNumberController.text = storeManager.employeeNumber;
    _userIdController.text = storeManager.userId;
    _firstNameController.text = storeManager.personalDetails.firstName;
    _lastNameController.text = storeManager.personalDetails.lastName;
    _dateOfBirthController.text = storeManager.personalDetails.dateOfBirth.toIso8601String().split('T')[0];
    _nationalIdController.text = storeManager.personalDetails.nationalId;
    _selectedGender = storeManager.personalDetails.gender;

    _workEmailController.text = storeManager.contactInformation.workEmail;
    _personalEmailController.text = storeManager.contactInformation.personalEmail;
    _workPhoneController.text = storeManager.contactInformation.workPhone;
    _personalPhoneController.text = storeManager.contactInformation.personalPhone;
    _officeLocationController.text = storeManager.contactInformation.officeLocation;

    _jobTitleController.text = storeManager.jobInformation.jobTitle;
    _selectedRole = storeManager.storeManagerRole;
    _departmentController.text = storeManager.department;
    _locationController.text = storeManager.jobInformation.location;
    _costCenterController.text = storeManager.jobInformation.costCenter;
    _reportingToController.text = storeManager.jobInformation.reportingTo;
    _selectedManagementLevel = storeManager.managementLevel;

    _assignedWarehouses = List.from(storeManager.assignedWarehouses);
    _storesManaged = List.from(storeManager.jobInformation.storesManaged);

    _baseSalaryController.text = storeManager.compensation.baseSalary.toString();
    _storesAllowanceController.text = storeManager.compensation.storesAllowance.toString();
    _performanceBonusController.text = storeManager.compensation.performanceBonus.toString();
    _inventoryAccuracyBonusController.text = storeManager.compensation.inventoryAccuracyBonus.toString();

    _hireDate = storeManager.employmentDetails.hireDate;
    _selectedEmploymentType = storeManager.employmentDetails.employmentType;
    _selectedEmploymentStatus = storeManager.employmentDetails.employmentStatus;
    _compensationReviewDate = storeManager.compensation.compensationReviewDate;
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final storeManagerData = _buildStoreManagerData();
      final notifier = ref.read(storeManagerAdminProvider.notifier);

      bool success;
      if (widget.mode == 'create') {
        success = await notifier.createStoreManager(storeManagerData);
      } else {
        final storeManagerId = ref.read(storeManagerAdminProvider).selectedStoreManager!.id;
        success = await notifier.updateStoreManager(storeManagerId, storeManagerData);
      }

      if (success && mounted) {
        widget.onSave();
      }
    }
  }

  Map<String, dynamic> _buildStoreManagerData() {
    return {
      'employeeNumber': _employeeNumberController.text,
      'user': _userIdController.text,
      'personalDetails': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'gender': _selectedGender.name,
        'nationalId': _nationalIdController.text,
      },
      'contactInformation': {
        'workEmail': _workEmailController.text,
        'personalEmail': _personalEmailController.text,
        'workPhone': _workPhoneController.text,
        'personalPhone': _personalPhoneController.text,
        'officeLocation': _officeLocationController.text,
      },
      'employmentDetails': {
        'hireDate': _hireDate?.toIso8601String(),
        'employmentType': _selectedEmploymentType.name,
        'employmentStatus': _selectedEmploymentStatus.name,
      },
      'jobInformation': {
        'jobTitle': _jobTitleController.text,
        'storeManagerRole': _selectedRole.name,
        'department': _departmentController.text,
        'location': _locationController.text,
        'costCenter': _costCenterController.text,
        'reportingTo': _reportingToController.text,
        'storesManaged': _storesManaged,
      },
      'compensation': {
        'baseSalary': double.parse(_baseSalaryController.text),
        'storesAllowance': double.parse(_storesAllowanceController.text),
        'performanceBonus': double.parse(_performanceBonusController.text),
        'inventoryAccuracyBonus': double.parse(_inventoryAccuracyBonusController.text),
        'compensationReviewDate': _compensationReviewDate?.toIso8601String(),
      },
      'storeManagerRole': _selectedRole.name,
      'managementLevel': _selectedManagementLevel.name,
      'assignedWarehouses': _assignedWarehouses,
      'department': _departmentController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    final storeManagerState = ref.watch(storeManagerAdminProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Progress Indicator
          if (storeManagerState.isUpdating)
            const LinearProgressIndicator(),

          // Form Content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Personal Information
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),

                    // Contact Information
                    _buildContactInfoCard(),
                    const SizedBox(height: 16),

                    // Employment Information
                    _buildEmploymentInfoCard(),
                    const SizedBox(height: 16),

                    // Job Information
                    _buildJobInfoCard(),
                    const SizedBox(height: 16),

                    // Compensation
                    _buildCompensationCard(),
                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information', Icons.person),
            const SizedBox(height: 16),

            // Employee Number & User ID
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _employeeNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Employee Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date of Birth & Gender
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateOfBirthController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _dateOfBirthController, isBirthDate: true),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Gender>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(),
                    ),
                    items: Gender.values.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(_formatGender(gender)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGender = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'National ID *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Contact Information', Icons.contact_mail),
            const SizedBox(height: 16),

            TextFormField(
              controller: _workEmailController,
              decoration: const InputDecoration(
                labelText: 'Work Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _personalEmailController,
              decoration: const InputDecoration(
                labelText: 'Personal Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _workPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Work Phone *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _personalPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Personal Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _officeLocationController,
              decoration: const InputDecoration(
                labelText: 'Office Location *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Employment Information', Icons.work),
            const SizedBox(height: 16),

            // Hire Date & Employment Type
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                        text: _hireDate?.toIso8601String().split('T')[0] ?? ''
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Hire Date *',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, null, isHireDate: true),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<EmploymentType>(
                    value: _selectedEmploymentType,
                    decoration: const InputDecoration(
                      labelText: 'Employment Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: EmploymentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_formatEmploymentType(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedEmploymentType = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<EmploymentStatus>(
              value: _selectedEmploymentStatus,
              decoration: const InputDecoration(
                labelText: 'Employment Status *',
                border: OutlineInputBorder(),
              ),
              items: EmploymentStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_formatEmploymentStatus(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedEmploymentStatus = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Job Information', Icons.business_center),
            const SizedBox(height: 16),

            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Role & Management Level
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<StoreManagerRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Store Manager Role *',
                      border: OutlineInputBorder(),
                    ),
                    items: StoreManagerRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<StoreManagementLevel>(
                    value: _selectedManagementLevel,
                    decoration: const InputDecoration(
                      labelText: 'Management Level *',
                      border: OutlineInputBorder(),
                    ),
                    items: StoreManagementLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.name.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedManagementLevel = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Department & Location
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cost Center & Reporting To
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costCenterController,
                    decoration: const InputDecoration(
                      labelText: 'Cost Center *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _reportingToController,
                    decoration: const InputDecoration(
                      labelText: 'Reporting To',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompensationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Compensation', Icons.attach_money),
            const SizedBox(height: 16),

            // Base Salary & Stores Allowance
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Base Salary *',
                      border: OutlineInputBorder(),
                      prefixText: 'KES ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _storesAllowanceController,
                    decoration: const InputDecoration(
                      labelText: 'Stores Allowance *',
                      border: OutlineInputBorder(),
                      prefixText: 'KES ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Performance Bonus & Inventory Accuracy Bonus
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _performanceBonusController,
                    decoration: const InputDecoration(
                      labelText: 'Performance Bonus *',
                      border: OutlineInputBorder(),
                      prefixText: 'KES ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _inventoryAccuracyBonusController,
                    decoration: const InputDecoration(
                      labelText: 'Inventory Accuracy Bonus *',
                      border: OutlineInputBorder(),
                      prefixText: 'KES ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compensation Review Date
            TextFormField(
              controller: TextEditingController(
                  text: _compensationReviewDate?.toIso8601String().split('T')[0] ?? ''
              ),
              decoration: const InputDecoration(
                labelText: 'Compensation Review Date *',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, null, isCompensationDate: true),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final storeManagerState = ref.watch(storeManagerAdminProvider);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: storeManagerState.isUpdating ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: storeManagerState.isUpdating ? null : _saveForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: storeManagerState.isUpdating
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(widget.mode == 'create' ? 'Create' : 'Update'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController? controller, {
        bool isBirthDate = false,
        bool isHireDate = false,
        bool isCompensationDate = false,
      }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isBirthDate ? DateTime(1900) : DateTime.now().subtract(const Duration(days: 365 * 50)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      final dateString = picked.toIso8601String().split('T')[0];

      if (controller != null) {
        controller.text = dateString;
      } else if (isHireDate) {
        setState(() => _hireDate = picked);
      } else if (isCompensationDate) {
        setState(() => _compensationReviewDate = picked);
      }
    }
  }

  String _formatGender(Gender gender) {
    return gender.name[0] + gender.name.substring(1).toLowerCase();
  }

  String _formatEmploymentType(EmploymentType type) {
    return type.name.replaceAll('_', ' ');
  }

  String _formatEmploymentStatus(EmploymentStatus status) {
    return status.name.replaceAll('_', ' ');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _employeeNumberController.dispose();
    _userIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _nationalIdController.dispose();
    _workEmailController.dispose();
    _personalEmailController.dispose();
    _workPhoneController.dispose();
    _personalPhoneController.dispose();
    _officeLocationController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _costCenterController.dispose();
    _reportingToController.dispose();
    _baseSalaryController.dispose();
    _storesAllowanceController.dispose();
    _performanceBonusController.dispose();
    _inventoryAccuracyBonusController.dispose();
    super.dispose();
  }
}