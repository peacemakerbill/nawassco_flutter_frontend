import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/procurement_officer.dart';
import '../../../../providers/procurement_officer_provider.dart';

class ProcurementOfficerFormScreen extends ConsumerStatefulWidget {
  final ProcurementOfficer? officer;

  const ProcurementOfficerFormScreen({super.key, this.officer});

  @override
  ConsumerState<ProcurementOfficerFormScreen> createState() => _ProcurementOfficerFormScreenState();
}

class _ProcurementOfficerFormScreenState extends ConsumerState<ProcurementOfficerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeNumberController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _costCenterController = TextEditingController();
  final TextEditingController _workLocationController = TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _hireDate;
  ProcurementRole? _selectedRole;
  EmploymentType? _selectedEmploymentType;
  EmploymentStatus? _selectedEmploymentStatus;
  List<ProcurementCategory> _selectedCategories = [];
  List<String> _assignedRegions = [];

  @override
  void initState() {
    super.initState();
    if (widget.officer != null) {
      _populateForm(widget.officer!);
    }
  }

  void _populateForm(ProcurementOfficer officer) {
    _employeeNumberController.text = officer.employeeNumber;
    _userIdController.text = officer.userId;
    _firstNameController.text = officer.firstName;
    _lastNameController.text = officer.lastName;
    _emailController.text = officer.email;
    _phoneController.text = officer.phone;
    _nationalIdController.text = officer.nationalId;
    _departmentController.text = officer.department;
    _costCenterController.text = officer.costCenter;
    _workLocationController.text = officer.workLocation;
    _dateOfBirth = officer.dateOfBirth;
    _hireDate = officer.hireDate;
    _selectedRole = officer.jobTitle;
    _selectedEmploymentType = officer.employmentType;
    _selectedEmploymentStatus = officer.employmentStatus;
    _selectedCategories = List.from(officer.specializedCategories);
    _assignedRegions = List.from(officer.assignedRegions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.officer == null ? 'Create Procurement Officer' : 'Edit Procurement Officer'),
        actions: [
          if (widget.officer != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteOfficer,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Personal Information
              _buildPersonalInfoSection(),
              const SizedBox(height: 20),

              // Employment Details
              _buildEmploymentSection(),
              const SizedBox(height: 20),

              // Procurement Details
              _buildProcurementSection(),
              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _employeeNumberController,
              decoration: const InputDecoration(
                labelText: 'Employee Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter user ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'National ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter national ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select date',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
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

  Widget _buildEmploymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hire Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _hireDate != null
                          ? '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}'
                          : 'Select date',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter department';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProcurementRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
              items: ProcurementRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_formatRole(role)),
                );
              }).toList(),
              onChanged: (role) {
                setState(() {
                  _selectedRole = role;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select job title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<EmploymentType>(
                    value: _selectedEmploymentType,
                    decoration: const InputDecoration(
                      labelText: 'Employment Type',
                      border: OutlineInputBorder(),
                    ),
                    items: EmploymentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_formatEmploymentType(type)),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() {
                        _selectedEmploymentType = type;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select employment type';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<EmploymentStatus>(
                    value: _selectedEmploymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Employment Status',
                      border: OutlineInputBorder(),
                    ),
                    items: EmploymentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_formatEmploymentStatus(status)),
                      );
                    }).toList(),
                    onChanged: (status) {
                      setState(() {
                        _selectedEmploymentStatus = status;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select employment status';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCenterController,
              decoration: const InputDecoration(
                labelText: 'Cost Center',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cost center';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workLocationController,
              decoration: const InputDecoration(
                labelText: 'Work Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter work location';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcurementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Procurement Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Specialized Categories',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProcurementCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(_formatCategory(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Assigned Regions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Nairobi', 'Coast', 'Central', 'Rift Valley', 'Eastern', 'Western', 'Nyanza'
              ].map((region) {
                final isSelected = _assignedRegions.contains(region);
                return FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _assignedRegions.add(region);
                      } else {
                        _assignedRegions.remove(region);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveOfficer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.officer == null ? 'Create Officer' : 'Update Officer'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _hireDate = picked;
        }
      });
    }
  }

  Future<void> _saveOfficer() async {
    if (!_validateForm()) return;

    final officerData = {
      'employeeNumber': _employeeNumberController.text,
      'user': _userIdController.text,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'dateOfBirth': _dateOfBirth!.toIso8601String(),
      'nationalId': _nationalIdController.text,
      'hireDate': _hireDate!.toIso8601String(),
      'department': _departmentController.text,
      'jobTitle': _selectedRole!.name,
      'employmentType': _selectedEmploymentType!.name,
      'employmentStatus': _selectedEmploymentStatus!.name,
      'specializedCategories': _selectedCategories.map((c) => c.name).toList(),
      'costCenter': _costCenterController.text,
      'workLocation': _workLocationController.text,
      'assignedRegions': _assignedRegions,
      'vendorManagementExperience': 0, // Default value
      'approvalLimits': {
        'purchaseRequisition': 0,
        'purchaseOrder': 0,
        'contract': 0,
        'emergencyProcurement': 0,
        'spotPurchase': 0,
      },
      'tenderAuthority': {
        'canOpenTenders': false,
        'canEvaluateTenders': false,
        'canAwardTenders': false,
        'tenderValueLimit': 0,
        'canApproveBidders': false,
      },
      'negotiationLimits': {
        'priceNegotiation': 0,
        'termsNegotiation': false,
        'contractModification': false,
      },
      'performance': {
        'costSavings': 0,
        'procurementCycleTime': 0,
        'supplierPerformance': 0,
        'complianceRate': 0,
        'contractManagement': 0,
        'overallRating': 0,
      },
      'blacklistAuthority': false,
    };

    final success = widget.officer == null
        ? await ref.read(procurementOfficerProvider.notifier).createProcurementOfficer(officerData)
        : await ref.read(procurementOfficerProvider.notifier).updateProcurementOfficer(
      widget.officer!.id,
      officerData,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteOfficer() async {
    if (widget.officer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Procurement Officer'),
        content: const Text('Are you sure you want to delete this procurement officer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(procurementOfficerProvider.notifier).deleteProcurementOfficer(widget.officer!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return false;
    }

    if (_hireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select hire date')),
      );
      return false;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select job title')),
      );
      return false;
    }

    if (_selectedEmploymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select employment type')),
      );
      return false;
    }

    if (_selectedEmploymentStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select employment status')),
      );
      return false;
    }

    return true;
  }

  String _formatRole(ProcurementRole role) {
    return role.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatEmploymentType(EmploymentType type) {
    return type.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatEmploymentStatus(EmploymentStatus status) {
    return status.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatCategory(ProcurementCategory category) {
    return category.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _userIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _departmentController.dispose();
    _costCenterController.dispose();
    _workLocationController.dispose();
    super.dispose();
  }
}