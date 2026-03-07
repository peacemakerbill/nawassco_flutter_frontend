import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/sales_representative_model.dart';

class SalesRepFormWidget extends StatefulWidget {
  final SalesRepresentative? existingSalesRep;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;
  final bool isSelfService;

  const SalesRepFormWidget({
    super.key,
    this.existingSalesRep,
    required this.onSubmit,
    this.onCancel,
    this.isSelfService = false,
  });

  @override
  _SalesRepFormWidgetState createState() => _SalesRepFormWidgetState();
}

class _SalesRepFormWidgetState extends State<SalesRepFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _nationalIdController;
  late TextEditingController _workEmailController;
  late TextEditingController _personalEmailController;
  late TextEditingController _workPhoneController;
  late TextEditingController _personalPhoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  // Dropdown values
  String _gender = 'other';
  String _salesRole = 'sales_representative';
  String _status = 'active';
  String _employmentType = 'full_time';

  // Target values
  final TextEditingController _monthlyTargetController =
      TextEditingController();
  final TextEditingController _quarterlyTargetController =
      TextEditingController();
  final TextEditingController _annualTargetController = TextEditingController();
  final TextEditingController _newCustomersTargetController =
      TextEditingController();
  final TextEditingController _revenueTargetController =
      TextEditingController();
  final TextEditingController _collectionTargetController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.existingSalesRep != null) {
      _populateFormData(widget.existingSalesRep!);
    }
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _nationalIdController = TextEditingController();
    _workEmailController = TextEditingController();
    _personalEmailController = TextEditingController();
    _workPhoneController = TextEditingController();
    _personalPhoneController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
  }

  void _populateFormData(SalesRepresentative salesRep) {
    _firstNameController.text = salesRep.personalDetails.firstName;
    _lastNameController.text = salesRep.personalDetails.lastName;
    _dateOfBirthController.text =
        DateFormat('yyyy-MM-dd').format(salesRep.personalDetails.dateOfBirth);
    _nationalIdController.text = salesRep.personalDetails.nationalId;
    _gender = salesRep.personalDetails.gender;

    _workEmailController.text = salesRep.contactInformation.workEmail;
    _personalEmailController.text = salesRep.contactInformation.personalEmail;
    _workPhoneController.text = salesRep.contactInformation.workPhone;
    _personalPhoneController.text = salesRep.contactInformation.personalPhone;

    _streetController.text = salesRep.contactInformation.address.street;
    _cityController.text = salesRep.contactInformation.address.city;
    _stateController.text = salesRep.contactInformation.address.state;
    _postalCodeController.text = salesRep.contactInformation.address.postalCode;
    _countryController.text = salesRep.contactInformation.address.country;

    _salesRole = salesRep.salesRole.toString().split('.').last;
    _status = salesRep.status.toString().split('.').last;

    _monthlyTargetController.text =
        salesRep.salesTargets.monthlyTarget.toString();
    _quarterlyTargetController.text =
        salesRep.salesTargets.quarterlyTarget.toString();
    _annualTargetController.text =
        salesRep.salesTargets.annualTarget.toString();
    _newCustomersTargetController.text =
        salesRep.salesTargets.newCustomersTarget.toString();
    _revenueTargetController.text =
        salesRep.salesTargets.revenueTarget.toString();
    _collectionTargetController.text =
        salesRep.salesTargets.collectionTarget.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _nationalIdController.dispose();
    _workEmailController.dispose();
    _personalEmailController.dispose();
    _workPhoneController.dispose();
    _personalPhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _monthlyTargetController.dispose();
    _quarterlyTargetController.dispose();
    _annualTargetController.dispose();
    _newCustomersTargetController.dispose();
    _revenueTargetController.dispose();
    _collectionTargetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Map<String, dynamic> _buildFormData() {
    return {
      'personalDetails': {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dateOfBirth': _dateOfBirthController.text,
        'gender': _gender,
        'nationalId': _nationalIdController.text.trim(),
      },
      'contactInformation': {
        'workEmail': _workEmailController.text.trim(),
        'personalEmail': _personalEmailController.text.trim(),
        'workPhone': _workPhoneController.text.trim(),
        'personalPhone': _personalPhoneController.text.trim(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
          'country': _countryController.text.trim(),
        },
      },
      'salesRole': _salesRole,
      'status': widget.isSelfService ? 'active' : _status,
      'salesTargets': {
        'monthlyTarget': double.tryParse(_monthlyTargetController.text) ?? 0,
        'quarterlyTarget':
            double.tryParse(_quarterlyTargetController.text) ?? 0,
        'annualTarget': double.tryParse(_annualTargetController.text) ?? 0,
        'newCustomersTarget':
            int.tryParse(_newCustomersTargetController.text) ?? 0,
        'revenueTarget': double.tryParse(_revenueTargetController.text) ?? 0,
        'collectionTarget':
            double.tryParse(_collectionTargetController.text) ?? 0,
      },
      'performance': {
        'totalSales': 0,
        'monthlyAverage': 0,
        'conversionRate': 0,
        'averageDealSize': 0,
        'customerSatisfaction': 0,
        'retentionRate': 0,
        'overallRating': 0,
      },
      'currentQuarter': {
        'quarter': 'Q1 ${DateTime.now().year}',
        'target': double.tryParse(_monthlyTargetController.text) ?? 0,
        'achieved': 0,
        'percentage': 0,
        'newCustomers': 0,
        'revenue': 0,
        'commissions': 0,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Title
              Text(
                widget.existingSalesRep == null
                    ? (widget.isSelfService
                        ? 'Create Your Profile'
                        : 'Add New Sales Representative')
                    : 'Edit Sales Representative',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 20),

              // Personal Details Section
              _buildSectionHeader('Personal Details'),
              const SizedBox(height: 16),
              _buildPersonalDetailsSection(),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              _buildContactDetailsSection(),
              const SizedBox(height: 24),

              // Role and Status Section (only for admin)
              if (!widget.isSelfService) ...[
                _buildSectionHeader('Role & Status'),
                const SizedBox(height: 16),
                _buildRoleStatusSection(),
                const SizedBox(height: 24),
              ],

              // Sales Targets Section
              _buildSectionHeader('Sales Targets'),
              const SizedBox(height: 16),
              _buildTargetsSection(),
              const SizedBox(height: 32),

              // Form Actions
              _buildFormActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                required: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateOfBirthController,
                    label: 'Date of Birth',
                    icon: Icons.calendar_today,
                    required: true,
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                value: _gender,
                label: 'Gender',
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalIdController,
          label: 'National ID',
          icon: Icons.badge,
          required: true,
        ),
      ],
    );
  }

  Widget _buildContactDetailsSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _workEmailController,
          label: 'Work Email',
          icon: Icons.email,
          required: true,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _personalEmailController,
          label: 'Personal Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _workPhoneController,
                label: 'Work Phone',
                icon: Icons.phone,
                required: true,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _personalPhoneController,
                label: 'Personal Phone',
                icon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Address'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _streetController,
          label: 'Street',
          icon: Icons.location_on,
          required: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State/Province',
                icon: Icons.map,
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
                controller: _postalCodeController,
                label: 'Postal Code',
                icon: Icons.local_post_office,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public,
                required: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleStatusSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _salesRole,
                label: 'Sales Role',
                items: SalesRole.values.map((role) {
                  final roleName = role.toString().split('.').last;
                  final displayName =
                      roleName.replaceAll('_', ' ').toUpperCase();
                  return DropdownMenuItem(
                    value: roleName,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _salesRole = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                value: _status,
                label: 'Status',
                items: SalesRepStatus.values.map((status) {
                  final statusName = status.toString().split('.').last;
                  final displayName =
                      statusName.replaceAll('_', ' ').toUpperCase();
                  return DropdownMenuItem(
                    value: statusName,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          value: _employmentType,
          label: 'Employment Type',
          items: EmploymentType.values.map((type) {
            final typeName = type.toString().split('.').last;
            final displayName = typeName.replaceAll('_', ' ').toUpperCase();
            return DropdownMenuItem(
              value: typeName,
              child: Text(displayName),
            );
          }).toList(),
          onChanged: (value) => setState(() => _employmentType = value!),
        ),
      ],
    );
  }

  Widget _buildTargetsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _monthlyTargetController,
                label: 'Monthly Target (KES)',
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _quarterlyTargetController,
                label: 'Quarterly Target (KES)',
                icon: Icons.timeline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _annualTargetController,
                label: 'Annual Target (KES)',
                icon: Icons.assessment,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _newCustomersTargetController,
                label: 'New Customers Target',
                icon: Icons.person_add,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _revenueTargetController,
                label: 'Revenue Target (KES)',
                icon: Icons.attach_money,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _collectionTargetController,
                label: 'Collection Target (KES)',
                icon: Icons.money,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null)
          OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSubmit(_buildFormData());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            widget.existingSalesRep == null ? 'SAVE' : 'UPDATE',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1E3A8A)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1E3A8A)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        final numValue = num.tryParse(value);
        if (numValue == null) {
          return 'Please enter a valid number';
        }
        if (numValue < 0) {
          return 'Value cannot be negative';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1E3A8A)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
