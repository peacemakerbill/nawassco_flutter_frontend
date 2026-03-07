import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_customer.dart';
import '../../../../providers/field_customer_provider.dart';

class CreateCustomerForm extends ConsumerStatefulWidget {
  final VoidCallback onCancel;

  const CreateCustomerForm({
    super.key,
    required this.onCancel,
  });

  @override
  ConsumerState<CreateCustomerForm> createState() => _CreateCustomerFormState();
}

class _CreateCustomerFormState extends ConsumerState<CreateCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _regionController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _postalCodeController = TextEditingController();

  CustomerType _selectedCustomerType = CustomerType.residential;
  ConnectionType _selectedConnectionType = ConnectionType.standard;
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _billingReminders = true;
  bool _serviceUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name *',
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
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name *',
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
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email Address *',
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number *',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nationalIdController,
                  label: 'National ID *',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'National ID is required';
                    }
                    return null;
                  },
                ),

                // Address Information
                const SizedBox(height: 32),
                _buildSectionHeader('Address Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _streetController,
                  label: 'Street Address *',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Street address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City *',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _zoneController,
                        label: 'Zone *',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Zone is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _districtController,
                        label: 'District *',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'District is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _regionController,
                        label: 'Region *',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Region is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _landmarkController,
                        label: 'Landmark (Optional)',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code (Optional)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Account Information
                const SizedBox(height: 32),
                _buildSectionHeader('Account Information'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<CustomerType>(
                        value: _selectedCustomerType,
                        items: CustomerType.values,
                        label: 'Customer Type *',
                        onChanged: (value) {
                          setState(() {
                            _selectedCustomerType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown<ConnectionType>(
                        value: _selectedConnectionType,
                        items: ConnectionType.values,
                        label: 'Connection Type *',
                        onChanged: (value) {
                          setState(() {
                            _selectedConnectionType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _meterNumberController,
                  label: 'Meter Number (Optional)',
                ),

                // Coordinates
                const SizedBox(height: 32),
                _buildSectionHeader('GPS Coordinates'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _latitude = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _longitude = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Current'),
                    ),
                  ],
                ),

                // Communication Preferences
                const SizedBox(height: 32),
                _buildSectionHeader('Communication Preferences'),
                const SizedBox(height: 16),
                _buildCheckboxListTile(
                  value: _emailNotifications,
                  title: 'Email Notifications',
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value ?? true;
                    });
                  },
                ),
                _buildCheckboxListTile(
                  value: _smsNotifications,
                  title: 'SMS Notifications',
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value ?? true;
                    });
                  },
                ),
                _buildCheckboxListTile(
                  value: _billingReminders,
                  title: 'Billing Reminders',
                  onChanged: (value) {
                    setState(() {
                      _billingReminders = value ?? true;
                    });
                  },
                ),
                _buildCheckboxListTile(
                  value: _serviceUpdates,
                  title: 'Service Updates',
                  onChanged: (value) {
                    setState(() {
                      _serviceUpdates = value ?? true;
                    });
                  },
                ),

                // Submit Button
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Customer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        color: Colors.blue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((T item) {
        final displayName = item is CustomerType
            ? (item as CustomerType).displayName
            : item is ConnectionType
            ? (item as ConnectionType).displayName
            : item.toString();

        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCheckboxListTile({
    required bool value,
    required String title,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _getCurrentLocation() {
    // Implement location service
    setState(() {
      _latitude = -1.2921; // Example: Nairobi latitude
      _longitude = 36.8219; // Example: Nairobi longitude
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customer = FieldCustomer(
      id: '',
      customerNumber: '',
      accountNumber: '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phoneNumber: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      address: CustomerAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zone: _zoneController.text.trim(),
        landmark: _landmarkController.text.isNotEmpty ? _landmarkController.text.trim() : null,
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text.trim() : null,
      ),
      location: LocationDetails(
        zone: _zoneController.text.trim(),
        district: _districtController.text.trim(),
        region: _regionController.text.trim(),
      ),
      coordinates: Coordinates(
        latitude: _latitude,
        longitude: _longitude,
      ),
      customerType: _selectedCustomerType,
      connectionType: _selectedConnectionType,
      meterNumber: _meterNumberController.text.isNotEmpty ? _meterNumberController.text.trim() : null,
      accountStatus: AccountStatus.active,
      billing: BillingInformation(
        currentBalance: 0,
        lastPaymentAmount: 0,
        averageMonthlyBill: 0,
        billingCycle: 'monthly',
      ),
      paymentHistory: [],
      serviceRequests: [],
      workOrders: [],
      serviceHistory: [],
      preferredLanguage: 'en',
      communicationPreferences: CommunicationPreferences(
        emailNotifications: _emailNotifications,
        smsNotifications: _smsNotifications,
        billingReminders: _billingReminders,
        serviceUpdates: _serviceUpdates,
      ),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ref.read(fieldCustomerProvider.notifier).createFieldCustomer(customer);
    if (success) {
      widget.onCancel();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zoneController.dispose();
    _districtController.dispose();
    _regionController.dispose();
    _meterNumberController.dispose();
    _landmarkController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}