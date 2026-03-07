import 'package:flutter/material.dart';

import '../../../models/supplier_model.dart';

class ProfileEditWidget extends StatefulWidget {
  final Supplier? supplier;
  final bool isUpdating;
  final Function(Map<String, dynamic>) onUpdate;

  const ProfileEditWidget({
    super.key,
    required this.supplier,
    required this.isUpdating,
    required this.onUpdate,
  });

  @override
  State<ProfileEditWidget> createState() => _ProfileEditWidgetState();
}

class _ProfileEditWidgetState extends State<ProfileEditWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _tradingNameController = TextEditingController();
  final TextEditingController _primaryEmailController = TextEditingController();
  final TextEditingController _secondaryEmailController = TextEditingController();
  final TextEditingController _primaryPhoneController = TextEditingController();
  final TextEditingController _secondaryPhoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.supplier != null) {
      _companyNameController.text = widget.supplier!.companyName;
      _tradingNameController.text = widget.supplier!.tradingName ?? '';
      _primaryEmailController.text = widget.supplier!.contactDetails['primaryEmail'] ?? '';
      _secondaryEmailController.text = widget.supplier!.contactDetails['secondaryEmail'] ?? '';
      _primaryPhoneController.text = widget.supplier!.contactDetails['primaryPhone'] ?? '';
      _secondaryPhoneController.text = widget.supplier!.contactDetails['secondaryPhone'] ?? '';
      _websiteController.text = widget.supplier!.contactDetails['website'] ?? '';
      _faxController.text = widget.supplier!.contactDetails['fax'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.supplier == null) {
      return const Center(
        child: Text('No supplier data available for editing'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066A1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _companyNameController,
                      label: 'Company Name *',
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                    _buildTextFormField(
                      controller: _tradingNameController,
                      label: 'Trading Name',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066A1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _primaryEmailController,
                      label: 'Primary Email *',
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
                      controller: _secondaryEmailController,
                      label: 'Secondary Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextFormField(
                      controller: _primaryPhoneController,
                      label: 'Primary Phone *',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                    _buildTextFormField(
                      controller: _secondaryPhoneController,
                      label: 'Secondary Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextFormField(
                      controller: _websiteController,
                      label: 'Website',
                      keyboardType: TextInputType.url,
                    ),
                    _buildTextFormField(
                      controller: _faxController,
                      label: 'Fax',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isUpdating ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: widget.isUpdating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'companyName': _companyNameController.text,
        'tradingName': _tradingNameController.text.isNotEmpty ? _tradingNameController.text : null,
        'contactDetails': {
          'primaryEmail': _primaryEmailController.text,
          'secondaryEmail': _secondaryEmailController.text.isNotEmpty ? _secondaryEmailController.text : null,
          'primaryPhone': _primaryPhoneController.text,
          'secondaryPhone': _secondaryPhoneController.text.isNotEmpty ? _secondaryPhoneController.text : null,
          'website': _websiteController.text.isNotEmpty ? _websiteController.text : null,
          'fax': _faxController.text.isNotEmpty ? _faxController.text : null,
        },
      };

      widget.onUpdate(data);
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _tradingNameController.dispose();
    _primaryEmailController.dispose();
    _secondaryEmailController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _websiteController.dispose();
    _faxController.dispose();
    super.dispose();
  }
}