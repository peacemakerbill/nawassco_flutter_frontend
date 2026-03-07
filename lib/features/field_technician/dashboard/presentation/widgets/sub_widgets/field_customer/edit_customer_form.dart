import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_customer.dart';
import '../../../../providers/field_customer_provider.dart';

class EditCustomerForm extends ConsumerStatefulWidget {
  final FieldCustomer customer;
  final VoidCallback onCancel;

  const EditCustomerForm({
    super.key,
    required this.customer,
    required this.onCancel,
  });

  @override
  ConsumerState<EditCustomerForm> createState() => _EditCustomerFormState();
}

class _EditCustomerFormState extends ConsumerState<EditCustomerForm> {
  late final _formKey = GlobalKey<FormState>();
  late final _firstNameController =
      TextEditingController(text: widget.customer.firstName);
  late final _lastNameController =
      TextEditingController(text: widget.customer.lastName);
  late final _emailController =
      TextEditingController(text: widget.customer.email);
  late final _phoneController =
      TextEditingController(text: widget.customer.phoneNumber);
  late final _nationalIdController =
      TextEditingController(text: widget.customer.nationalId);
  late final _streetController =
      TextEditingController(text: widget.customer.address.street);
  late final _cityController =
      TextEditingController(text: widget.customer.address.city);
  late final _zoneController =
      TextEditingController(text: widget.customer.address.zone);
  late final _districtController =
      TextEditingController(text: widget.customer.location.district);
  late final _regionController =
      TextEditingController(text: widget.customer.location.region);
  late final _meterNumberController =
      TextEditingController(text: widget.customer.meterNumber ?? '');
  late final _landmarkController =
      TextEditingController(text: widget.customer.address.landmark ?? '');
  late final _postalCodeController =
      TextEditingController(text: widget.customer.address.postalCode ?? '');

  late CustomerType _selectedCustomerType = widget.customer.customerType;
  late ConnectionType _selectedConnectionType = widget.customer.connectionType;
  late AccountStatus _selectedAccountStatus = widget.customer.accountStatus;

  late bool _emailNotifications =
      widget.customer.communicationPreferences.emailNotifications;
  late bool _smsNotifications =
      widget.customer.communicationPreferences.smsNotifications;
  late bool _billingReminders =
      widget.customer.communicationPreferences.billingReminders;
  late bool _serviceUpdates =
      widget.customer.communicationPreferences.serviceUpdates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Customer'),
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
                const SizedBox(height: 16),
                _buildDropdown<AccountStatus>(
                  value: _selectedAccountStatus,
                  items: AccountStatus.values,
                  label: 'Account Status *',
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountStatus = value!;
                    });
                  },
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
                        child: const Text('Update Customer'),
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
                : item is AccountStatus
                    ? (item as AccountStatus).displayName
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updateData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'phoneNumber': _phoneController.text.trim(),
      'nationalId': _nationalIdController.text.trim(),
      'address': {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'zone': _zoneController.text.trim(),
        if (_landmarkController.text.isNotEmpty)
          'landmark': _landmarkController.text.trim(),
        if (_postalCodeController.text.isNotEmpty)
          'postalCode': _postalCodeController.text.trim(),
      },
      'location': {
        'zone': _zoneController.text.trim(),
        'district': _districtController.text.trim(),
        'region': _regionController.text.trim(),
      },
      'customerType': _selectedCustomerType.name,
      'connectionType': _selectedConnectionType.name,
      if (_meterNumberController.text.isNotEmpty)
        'meterNumber': _meterNumberController.text.trim(),
      'accountStatus': _selectedAccountStatus.name,
      'communicationPreferences': {
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'billingReminders': _billingReminders,
        'serviceUpdates': _serviceUpdates,
      },
    };

    final success =
        await ref.read(fieldCustomerProvider.notifier).updateFieldCustomer(
              widget.customer.id,
              updateData,
            );

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
