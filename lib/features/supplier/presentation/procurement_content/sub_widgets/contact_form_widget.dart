import 'package:flutter/material.dart';

import '../../../models/supplier_model.dart';


class ContactFormWidget extends StatefulWidget {
  final List<Supplier> suppliers;
  final String? selectedSupplierId;
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? initialData;

  const ContactFormWidget({
    super.key,
    required this.suppliers,
    this.selectedSupplierId,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<ContactFormWidget> createState() => _ContactFormWidgetState();
}

class _ContactFormWidgetState extends State<ContactFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _salutationController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _signatoryLimitController = TextEditingController();

  String? _selectedSupplierId;
  String _selectedContactMethod = 'email';
  bool _receiveTenderNotifications = true;
  bool _receiveNewsletters = false;
  bool _isAuthorizedSignatory = false;
  bool _canSubmitBids = true;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _selectedSupplierId = widget.selectedSupplierId;

    if (widget.initialData != null) {
      _salutationController.text = widget.initialData!['salutation'] ?? '';
      _firstNameController.text = widget.initialData!['firstName'] ?? '';
      _lastNameController.text = widget.initialData!['lastName'] ?? '';
      _positionController.text = widget.initialData!['position'] ?? '';
      _departmentController.text = widget.initialData!['department'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _mobileController.text = widget.initialData!['mobile'] ?? '';
      _faxController.text = widget.initialData!['fax'] ?? '';
      _signatoryLimitController.text = widget.initialData!['signatoryLimit']?.toString() ?? '';

      _selectedSupplierId = widget.initialData!['supplier'];
      _selectedContactMethod = widget.initialData!['preferredContactMethod'] ?? 'email';
      _receiveTenderNotifications = widget.initialData!['receiveTenderNotifications'] ?? true;
      _receiveNewsletters = widget.initialData!['receiveNewsletters'] ?? false;
      _isAuthorizedSignatory = widget.initialData!['isAuthorizedSignatory'] ?? false;
      _canSubmitBids = widget.initialData!['canSubmitBids'] ?? true;
      _isPrimary = widget.initialData!['isPrimary'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier Selection
            _buildSectionHeader('Supplier Selection'),
            _buildSupplierDropdown(),

            // Personal Information
            _buildSectionHeader('Personal Information'),
            _buildTextFormField(
              controller: _salutationController,
              label: 'Salutation *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _firstNameController,
              label: 'First Name *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _lastNameController,
              label: 'Last Name *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _positionController,
              label: 'Position *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _departmentController,
              label: 'Department *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),

            // Contact Information
            _buildSectionHeader('Contact Information'),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email *',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone *',
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _mobileController,
              label: 'Mobile *',
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _faxController,
              label: 'Fax',
            ),

            // Communication Preferences
            _buildSectionHeader('Communication Preferences'),
            _buildDropdown(
              value: _selectedContactMethod,
              label: 'Preferred Contact Method',
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'phone', child: Text('Phone')),
                DropdownMenuItem(value: 'sms', child: Text('SMS')),
                DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
              ],
              onChanged: (value) => setState(() => _selectedContactMethod = value!),
            ),
            SwitchListTile(
              title: const Text('Receive Tender Notifications'),
              value: _receiveTenderNotifications,
              onChanged: (value) => setState(() => _receiveTenderNotifications = value),
            ),
            SwitchListTile(
              title: const Text('Receive Newsletters'),
              value: _receiveNewsletters,
              onChanged: (value) => setState(() => _receiveNewsletters = value),
            ),

            // Authorization
            _buildSectionHeader('Authorization'),
            SwitchListTile(
              title: const Text('Authorized Signatory'),
              value: _isAuthorizedSignatory,
              onChanged: (value) => setState(() => _isAuthorizedSignatory = value),
            ),
            if (_isAuthorizedSignatory)
              _buildTextFormField(
                controller: _signatoryLimitController,
                label: 'Signatory Limit (KES)',
                keyboardType: TextInputType.number,
              ),
            SwitchListTile(
              title: const Text('Can Submit Bids'),
              value: _canSubmitBids,
              onChanged: (value) => setState(() => _canSubmitBids = value),
            ),

            // Status
            _buildSectionHeader('Status'),
            SwitchListTile(
              title: const Text('Primary Contact'),
              value: _isPrimary,
              onChanged: (value) => setState(() => _isPrimary = value),
            ),

            // Submit Button
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0066A1),
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String?>(
        value: _selectedSupplierId,
        decoration: const InputDecoration(
          labelText: 'Supplier *',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Select a supplier')),
          ...widget.suppliers.map((supplier) => DropdownMenuItem(
            value: supplier.id,
            child: Text(supplier.companyName),
          )),
        ],
        validator: (value) => value == null ? 'Please select a supplier' : null,
        onChanged: (value) => setState(() => _selectedSupplierId = value),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedSupplierId != null) {
      // Prepare data
      final data = {
        'supplier': _selectedSupplierId,
        'salutation': _salutationController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'position': _positionController.text,
        'department': _departmentController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'mobile': _mobileController.text,
        'fax': _faxController.text.isNotEmpty ? _faxController.text : null,
        'preferredContactMethod': _selectedContactMethod,
        'receiveTenderNotifications': _receiveTenderNotifications,
        'receiveNewsletters': _receiveNewsletters,
        'isAuthorizedSignatory': _isAuthorizedSignatory,
        'signatoryLimit': _signatoryLimitController.text.isNotEmpty
            ? double.tryParse(_signatoryLimitController.text)
            : null,
        'canSubmitBids': _canSubmitBids,
        'isPrimary': _isPrimary,
        'isActive': true,
      };

      widget.onSubmit(data);
    } else if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
    }
  }

  @override
  void dispose() {
    _salutationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _faxController.dispose();
    _signatoryLimitController.dispose();
    super.dispose();
  }
}