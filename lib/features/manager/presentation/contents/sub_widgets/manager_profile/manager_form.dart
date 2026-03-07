import 'package:flutter/material.dart';
import '../../../../models/manager_model.dart';

class ManagerForm extends StatefulWidget {
  final ManagerModel? manager;
  final bool isEditing;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;

  const ManagerForm({
    super.key,
    this.manager,
    this.isEditing = false,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ManagerForm> createState() => _ManagerFormState();
}

class _ManagerFormState extends State<ManagerForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _managementLevelController = TextEditingController();
  final _managementRoleController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _expenseApprovalController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedManagementLevel;
  String? _selectedManagementRole;
  String? _selectedEmploymentType;
  String? _selectedEmploymentStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.manager != null) {
      _initializeForm();
    } else {
      _setDefaultValues();
    }
  }

  void _initializeForm() {
    final manager = widget.manager!;

    _firstNameController.text = manager.personalDetails.firstName;
    _lastNameController.text = manager.personalDetails.lastName;
    _emailController.text = manager.contactInformation.workEmail;
    _phoneController.text = manager.contactInformation.workPhone;
    _employeeNumberController.text = manager.employeeNumber;
    _jobTitleController.text = manager.jobInformation.jobTitle;
    _departmentController.text = manager.department;
    _managementLevelController.text = manager.managementLevel;
    _managementRoleController.text = manager.managementRole;
    _baseSalaryController.text = manager.compensation.baseSalary.toString();
    _expenseApprovalController.text =
        manager.approvalLimits.financial.expenseApproval.toString();

    _selectedDepartment = manager.department;
    _selectedManagementLevel = manager.managementLevel;
    _selectedManagementRole = manager.managementRole;
    _selectedEmploymentType = manager.employmentDetails.employmentType;
    _selectedEmploymentStatus = manager.employmentDetails.employmentStatus;
  }

  void _setDefaultValues() {
    _selectedDepartment = Department.finance;
    _selectedManagementLevel = ManagementLevel.middleManagement;
    _selectedManagementRole = ManagementRole.manager;
    _selectedEmploymentType = EmploymentType.fullTime;
    _selectedEmploymentStatus = EmploymentStatus.active;

    _expenseApprovalController.text = '10000';
    _baseSalaryController.text = '50000';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeNumberController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _managementLevelController.dispose();
    _managementRoleController.dispose();
    _baseSalaryController.dispose();
    _expenseApprovalController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = _buildFormData();
      widget.onSubmit(formData);
    }
  }

  Map<String, dynamic> _buildFormData() {
    final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0;
    final expenseApproval =
        double.tryParse(_expenseApprovalController.text) ?? 0;

    return {
      'employeeNumber': _employeeNumberController.text,
      'personalDetails': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'dateOfBirth': '1990-01-01',
        'gender': 'Male',
        'nationalId': '12345678',
      },
      'contactInformation': {
        'workEmail': _emailController.text,
        'personalEmail': _emailController.text,
        'workPhone': _phoneController.text,
        'personalPhone': _phoneController.text,
        'officeLocation': 'Head Office',
      },
      'employmentDetails': {
        'hireDate': DateTime.now().toIso8601String(),
        'employmentType': _selectedEmploymentType,
        'employmentStatus': _selectedEmploymentStatus,
        'managementTenure': 0,
      },
      'jobInformation': {
        'jobTitle': _jobTitleController.text,
        'managementRole': _selectedManagementRole,
        'department': _selectedDepartment,
        'division': 'Corporate',
        'location': 'Head Office',
        'costCenter': 'CC001',
        'reportingTo': null,
      },
      'compensation': {
        'baseSalary': baseSalary,
        'managementAllowance': baseSalary * 0.2,
        'performanceBonus': baseSalary * 0.1,
        'benefits': [],
        'compensationReviewDate':
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      },
      'managementRole': _selectedManagementRole,
      'managementLevel': _selectedManagementLevel,
      'department': _selectedDepartment,
      'spanOfControl': {
        'totalEmployees': 0,
        'directReports': 0,
        'indirectReports': 0,
        'teams': 0,
        'departments': 0,
        'budgetSize': 0,
      },
      'approvalLimits': {
        'financial': {
          'expenseApproval': expenseApproval,
          'capitalExpenditure': expenseApproval * 2,
          'budgetAdjustment': expenseApproval * 0.5,
          'contractSigning': expenseApproval * 5,
          'investmentApproval': expenseApproval * 10,
        },
        'operational': {
          'projectApproval': expenseApproval * 2,
          'resourceAllocation': expenseApproval * 0.5,
          'operationalChanges': expenseApproval,
          'qualityStandards': false,
          'safetyWaivers': false,
        },
        'humanResources': {
          'hiring': expenseApproval * 0.1,
          'salaryAdjustment': expenseApproval * 0.05,
          'promotion': expenseApproval * 0.05,
          'termination': false,
          'trainingBudget': expenseApproval * 0.02,
        },
        'procurement': {
          'purchaseOrders': expenseApproval * 2,
          'supplierContracts': expenseApproval * 5,
          'tenderAwards': expenseApproval * 10,
          'emergencyProcurement': expenseApproval,
        },
      },
      'signingAuthority': {
        'canSignContracts': false,
        'contractValueLimit': 0,
        'canSignFinancials': false,
        'canSignLegal': false,
        'canRepresentCompany': false,
      },
      'directReports': [],
      'reportingStructure': {
        'level': 1,
        'reportsTo': null,
        'dottedLineReports': [],
        'committeeReports': [],
        'boardReporting': false,
      },
      'performance': {
        'leadershipScore': 0,
        'strategicContribution': 0,
        'teamPerformance': 0,
        'financialPerformance': 0,
        'operationalPerformance': 0,
        'overallRating': 0,
        'nextReviewDate':
            DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      },
      'objectives': [],
      'decisionAuthority': {
        'operationalDecisions': 'none',
        'financialDecisions': 'none',
        'strategicDecisions': 'none',
        'personnelDecisions': 'none',
      },
      'budgetAuthority': {
        'departmentBudget': 0,
        'projectBudget': 0,
        'capitalBudget': 0,
        'discretionaryBudget': 0,
        'budgetTransferLimit': 0,
      },
      'hiringAuthority': {
        'canHire': false,
        'hiringLevels': [],
        'salaryBandAuthority': 0,
        'canApproveJobRequisitions': false,
        'canTerminate': false,
      },
      'developmentPlan': {
        'developmentAreas': [],
        'trainingPrograms': [],
        'coaching': [],
        'targetRoles': [],
        'timeline': {
          'shortTerm': [],
          'mediumTerm': [],
          'longTerm': [],
        },
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Manager' : 'Create New Manager',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Employment'),
            Tab(text: 'Compensation'),
            Tab(text: 'Authority'),
          ],
        ),
        actions: [
          if (widget.onCancel != null)
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.isEditing ? 'Update' : 'Create'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildEmploymentTab(),
            _buildCompensationTab(),
            _buildAuthorityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _employeeNumberController,
            decoration: const InputDecoration(
              labelText: 'Employee Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Employee number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _jobTitleController,
            decoration: const InputDecoration(
              labelText: 'Job Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Job title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedManagementRole,
            decoration: const InputDecoration(
              labelText: 'Management Role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.star),
            ),
            items: ManagementRole.all.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(ManagementRole.display(role)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedManagementRole = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Management role is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedManagementLevel,
            decoration: const InputDecoration(
              labelText: 'Management Level',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.trending_up),
            ),
            items: ManagementLevel.all.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(ManagementLevel.display(level)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedManagementLevel = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Management level is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            items: Department.all.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(Department.display(dept)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Department is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEmploymentType,
                  decoration: const InputDecoration(
                    labelText: 'Employment Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  items: EmploymentType.all.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(EmploymentType.display(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmploymentType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Employment type is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEmploymentStatus,
                  decoration: const InputDecoration(
                    labelText: 'Employment Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.verified_user),
                  ),
                  items: EmploymentStatus.all.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(EmploymentStatus.display(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmploymentStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Employment status is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompensationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _baseSalaryController,
            decoration: const InputDecoration(
              labelText: 'Base Salary (\$)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Base salary is required';
              }
              if (double.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compensation Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCompensationRow(
                    'Management Allowance',
                    _calculateAllowance(),
                    Colors.blue,
                  ),
                  _buildCompensationRow(
                    'Performance Bonus',
                    _calculateBonus(),
                    Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildCompensationRow(
                    'Total Compensation',
                    _calculateTotalCompensation(),
                    Colors.purple,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _expenseApprovalController,
            decoration: const InputDecoration(
              labelText: 'Expense Approval Limit (\$)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
              helperText: 'Other limits will be calculated based on this',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Expense approval limit is required';
              }
              if (double.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authority Limits',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAuthorityLimitRow(
                    'Capital Expenditure',
                    _calculateCapitalExpenditure(),
                  ),
                  _buildAuthorityLimitRow(
                    'Contract Signing',
                    _calculateContractSigning(),
                  ),
                  _buildAuthorityLimitRow(
                    'Project Approval',
                    _calculateProjectApproval(),
                  ),
                  _buildAuthorityLimitRow(
                    'Hiring Authority',
                    _calculateHiringAuthority(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompensationRow(String label, double amount, Color color,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityLimitRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAllowance() {
    final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0;
    return baseSalary * 0.2;
  }

  double _calculateBonus() {
    final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0;
    return baseSalary * 0.1;
  }

  double _calculateTotalCompensation() {
    final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0;
    return baseSalary + _calculateAllowance() + _calculateBonus();
  }

  double _calculateCapitalExpenditure() {
    final expense = double.tryParse(_expenseApprovalController.text) ?? 0;
    return expense * 2;
  }

  double _calculateContractSigning() {
    final expense = double.tryParse(_expenseApprovalController.text) ?? 0;
    return expense * 5;
  }

  double _calculateProjectApproval() {
    final expense = double.tryParse(_expenseApprovalController.text) ?? 0;
    return expense * 2;
  }

  double _calculateHiringAuthority() {
    final expense = double.tryParse(_expenseApprovalController.text) ?? 0;
    return expense * 0.1;
  }
}
