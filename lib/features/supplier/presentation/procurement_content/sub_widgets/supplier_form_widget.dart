import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierFormWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? initialData;

  const SupplierFormWidget({
    super.key,
    required this.onSubmit,
    this.initialData,
  });

  @override
  ConsumerState<SupplierFormWidget> createState() => _SupplierFormWidgetState();
}

class _SupplierFormWidgetState extends ConsumerState<SupplierFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _tradingNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _yearEstablishedController = TextEditingController();
  final TextEditingController _primaryEmailController = TextEditingController();
  final TextEditingController _primaryPhoneController = TextEditingController();

  String _selectedBusinessType = 'manufacturer';
  String _selectedOwnershipType = 'private_limited';
  String _selectedCompanyType = 'local';
  final List<String> _selectedCategories = [];
  String _selectedTier = 'tier_3';
  String _selectedRisk = 'medium';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      _companyNameController.text = widget.initialData!['companyName'] ?? '';
      _tradingNameController.text = widget.initialData!['tradingName'] ?? '';
      _registrationNumberController.text = widget.initialData!['registrationNumber'] ?? '';
      _taxIdController.text = widget.initialData!['taxIdentificationNumber'] ?? '';
      _yearEstablishedController.text = widget.initialData!['yearEstablished']?.toString() ?? '';
      _primaryEmailController.text = widget.initialData!['contactDetails']?['primaryEmail'] ?? '';
      _primaryPhoneController.text = widget.initialData!['contactDetails']?['primaryPhone'] ?? '';

      _selectedBusinessType = widget.initialData!['businessType'] ?? 'manufacturer';
      _selectedOwnershipType = widget.initialData!['ownershipType'] ?? 'private_limited';
      _selectedCompanyType = widget.initialData!['companyType'] ?? 'local';
      _selectedTier = widget.initialData!['supplierTier'] ?? 'tier_3';
      _selectedRisk = widget.initialData!['riskRating'] ?? 'medium';

      if (widget.initialData!['nawasscoCategories'] != null) {
        _selectedCategories.addAll(List<String>.from(widget.initialData!['nawasscoCategories']));
      }
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
            // Basic Information
            _buildSectionHeader('Basic Information'),
            _buildTextFormField(
              controller: _companyNameController,
              label: 'Company Name *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _tradingNameController,
              label: 'Trading Name',
            ),
            _buildTextFormField(
              controller: _registrationNumberController,
              label: 'Registration Number *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _taxIdController,
              label: 'Tax Identification Number *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _yearEstablishedController,
              label: 'Year Established *',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                final year = int.tryParse(value!);
                if (year == null || year < 1900 || year > DateTime.now().year) {
                  return 'Invalid year';
                }
                return null;
              },
            ),

            // Business Information
            _buildSectionHeader('Business Information'),
            _buildDropdown(
              value: _selectedBusinessType,
              label: 'Business Type',
              items: const [
                DropdownMenuItem(value: 'manufacturer', child: Text('Manufacturer')),
                DropdownMenuItem(value: 'distributor', child: Text('Distributor')),
                DropdownMenuItem(value: 'service_provider', child: Text('Service Provider')),
                DropdownMenuItem(value: 'consultant', child: Text('Consultant')),
                DropdownMenuItem(value: 'contractor', child: Text('Contractor')),
              ],
              onChanged: (value) => setState(() => _selectedBusinessType = value!),
            ),
            _buildDropdown(
              value: _selectedOwnershipType,
              label: 'Ownership Type',
              items: const [
                DropdownMenuItem(value: 'sole_proprietorship', child: Text('Sole Proprietorship')),
                DropdownMenuItem(value: 'partnership', child: Text('Partnership')),
                DropdownMenuItem(value: 'private_limited', child: Text('Private Limited')),
                DropdownMenuItem(value: 'public_limited', child: Text('Public Limited')),
              ],
              onChanged: (value) => setState(() => _selectedOwnershipType = value!),
            ),
            _buildDropdown(
              value: _selectedCompanyType,
              label: 'Company Type',
              items: const [
                DropdownMenuItem(value: 'local', child: Text('Local')),
                DropdownMenuItem(value: 'international', child: Text('International')),
              ],
              onChanged: (value) => setState(() => _selectedCompanyType = value!),
            ),

            // NAWASSCO Categories
            _buildSectionHeader('NAWASSCO Categories *'),
            _buildCategorySelection(),

            // Contact Information
            _buildSectionHeader('Contact Information'),
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
              controller: _primaryPhoneController,
              label: 'Primary Phone *',
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),

            // Classification
            _buildSectionHeader('Classification'),
            _buildDropdown(
              value: _selectedTier,
              label: 'Supplier Tier',
              items: const [
                DropdownMenuItem(value: 'tier_1', child: Text('Tier 1')),
                DropdownMenuItem(value: 'tier_2', child: Text('Tier 2')),
                DropdownMenuItem(value: 'tier_3', child: Text('Tier 3')),
                DropdownMenuItem(value: 'preferred', child: Text('Preferred')),
                DropdownMenuItem(value: 'strategic', child: Text('Strategic')),
              ],
              onChanged: (value) => setState(() => _selectedTier = value!),
            ),
            _buildDropdown(
              value: _selectedRisk,
              label: 'Risk Rating',
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'very_high', child: Text('Very High')),
              ],
              onChanged: (value) => setState(() => _selectedRisk = value!),
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
                child: const Text('Submit Supplier'),
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
        onSaved: (value) {
          // Store in form data
          final fieldName = _getFieldNameFromLabel(label);
          if (fieldName != null) {
            _formData[fieldName] = value;
          }
        },
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
        onSaved: (value) {
          final fieldName = _getFieldNameFromLabel(label);
          if (fieldName != null) {
            _formData[fieldName] = value;
          }
        },
      ),
    );
  }

  Widget _buildCategorySelection() {
    final categories = [
      'pipes_fittings',
      'water_treatment',
      'pumping_equipment',
      'meters',
      'valves',
      'construction_materials',
      'consultancy_services',
      'construction_services',
      'maintenance_services',
      'it_services',
      'vehicles_equipment',
    ];

    final categoryLabels = {
      'pipes_fittings': 'Pipes & Fittings',
      'water_treatment': 'Water Treatment',
      'pumping_equipment': 'Pumping Equipment',
      'meters': 'Meters',
      'valves': 'Valves',
      'construction_materials': 'Construction Materials',
      'consultancy_services': 'Consultancy Services',
      'construction_services': 'Construction Services',
      'maintenance_services': 'Maintenance Services',
      'it_services': 'IT Services',
      'vehicles_equipment': 'Vehicles & Equipment',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(categoryLabels[category] ?? category),
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
    );
  }

  String? _getFieldNameFromLabel(String label) {
    final mapping = {
      'Company Name': 'companyName',
      'Trading Name': 'tradingName',
      'Registration Number': 'registrationNumber',
      'Tax Identification Number': 'taxIdentificationNumber',
      'Year Established': 'yearEstablished',
      'Primary Email': 'primaryEmail',
      'Primary Phone': 'primaryPhone',
      'Business Type': 'businessType',
      'Ownership Type': 'ownershipType',
      'Company Type': 'companyType',
      'Supplier Tier': 'supplierTier',
      'Risk Rating': 'riskRating',
    };

    return mapping[label.replaceAll(' *', '')];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate categories
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one category')),
        );
        return;
      }

      // Prepare final data
      final data = {
        'companyName': _companyNameController.text,
        'tradingName': _tradingNameController.text.isNotEmpty ? _tradingNameController.text : null,
        'registrationNumber': _registrationNumberController.text,
        'taxIdentificationNumber': _taxIdController.text,
        'yearEstablished': int.parse(_yearEstablishedController.text),
        'businessType': _selectedBusinessType,
        'ownershipType': _selectedOwnershipType,
        'companyType': _selectedCompanyType,
        'nawasscoCategories': _selectedCategories,
        'supplierTier': _selectedTier,
        'riskRating': _selectedRisk,
        'contactDetails': {
          'primaryEmail': _primaryEmailController.text,
          'primaryPhone': _primaryPhoneController.text,
        },
        'addresses': [],
        'contactPersons': [],
        'financialInformation': {
          'annualRevenue': 0,
          'currency': 'KES',
          'lastFiscalYear': DateTime.now().year - 1,
        },
        'isActive': true,
      };

      widget.onSubmit(data);
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _tradingNameController.dispose();
    _registrationNumberController.dispose();
    _taxIdController.dispose();
    _yearEstablishedController.dispose();
    _primaryEmailController.dispose();
    _primaryPhoneController.dispose();
    super.dispose();
  }
}