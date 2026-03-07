import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class AddressForm extends ConsumerStatefulWidget {
  final String customerId;
  final CustomerAddress? initialAddress;
  final VoidCallback onSuccess;

  const AddressForm({
    super.key,
    required this.customerId,
    this.initialAddress,
    required this.onSuccess,
  });

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  AddressType _type = AddressType.physical;
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool _isPrimary = false;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      final address = widget.initialAddress!;
      _type = address.type;
      _addressLine1Controller.text = address.addressLine1;
      _addressLine2Controller.text = address.addressLine2 ?? '';
      _cityController.text = address.city;
      _stateController.text = address.state;
      _postalCodeController.text = address.postalCode;
      _countryController.text = address.country;
      _isPrimary = address.isPrimary;
      if (address.coordinates != null) {
        _latitudeController.text = address.coordinates!.latitude.toString();
        _longitudeController.text = address.coordinates!.longitude.toString();
      }
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = ref.read(customerProvider.notifier);

      final addressData = {
        'type': _type.name,
        'addressLine1': _addressLine1Controller.text.trim(),
        if (_addressLine2Controller.text.isNotEmpty)
          'addressLine2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'isPrimary': _isPrimary,
        if (_latitudeController.text.isNotEmpty &&
            _longitudeController.text.isNotEmpty)
          'coordinates': {
            'latitude': double.parse(_latitudeController.text),
            'longitude': double.parse(_longitudeController.text),
          },
      };

      // This would be handled via backend API
      // For now, we'll just close the dialog and refresh
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialAddress == null ? 'Add Address' : 'Edit Address',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AddressType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Address Type *',
                  border: OutlineInputBorder(),
                ),
                items: AddressType.values.map((type) {
                  return DropdownMenuItem<AddressType>(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
                validator: (value) {
                  if (value == null) return 'Please select address type';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address line 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter postal code';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Set as Primary Address'),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value ?? false);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
