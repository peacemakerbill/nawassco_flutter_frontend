import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/vehicle.dart';
import '../../../../providers/vehicle_provider.dart';

class VehicleFormWidget extends ConsumerStatefulWidget {
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const VehicleFormWidget({
    super.key,
    this.isEditing = false,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<VehicleFormWidget> createState() => _VehicleFormWidgetState();
}

class _VehicleFormWidgetState extends ConsumerState<VehicleFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _initializeFormData();
    }
  }

  void _initializeFormData() {
    final vehicle = ref.read(vehicleProvider).selectedVehicle;
    if (vehicle != null) {
      _formData.addAll({
        'registrationNumber': vehicle.registrationNumber,
        'make': vehicle.make,
        'vehicleModel': vehicle.model,
        'year': vehicle.year,
        'color': vehicle.color,
        'vehicleType': vehicle.vehicleType.name,
        'fuelType': vehicle.fuelType.name,
        'fuelCapacity': vehicle.fuelCapacity,
        'currentOdometer': vehicle.currentOdometer,
        'purchasePrice': vehicle.purchasePrice,
        'currentValue': vehicle.currentValue,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRegistrationField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildMakeField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildModelField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildYearField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildColorField()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildVehicleTypeField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFuelTypeField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildFuelCapacityField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildOdometerField()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildPurchasePriceField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCurrentValueField()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationField() {
    return TextFormField(
      initialValue: _formData['registrationNumber']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Registration Number',
        prefixIcon: Icon(Icons.confirmation_number),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter registration number';
        }
        return null;
      },
      onSaved: (value) => _formData['registrationNumber'] = value,
    );
  }

  Widget _buildMakeField() {
    return TextFormField(
      initialValue: _formData['make']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Make',
        prefixIcon: Icon(Icons.branding_watermark),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter vehicle make';
        }
        return null;
      },
      onSaved: (value) => _formData['make'] = value,
    );
  }

  Widget _buildModelField() {
    return TextFormField(
      initialValue: _formData['vehicleModel']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Model',
        prefixIcon: Icon(Icons.directions_car),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter vehicle model';
        }
        return null;
      },
      onSaved: (value) => _formData['vehicleModel'] = value,
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      initialValue: _formData['year']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Year',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter year';
        }
        final year = int.tryParse(value);
        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
          return 'Please enter a valid year';
        }
        return null;
      },
      onSaved: (value) => _formData['year'] = int.parse(value!),
    );
  }

  Widget _buildColorField() {
    return TextFormField(
      initialValue: _formData['color']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Color',
        prefixIcon: Icon(Icons.color_lens),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter color';
        }
        return null;
      },
      onSaved: (value) => _formData['color'] = value,
    );
  }

  Widget _buildVehicleTypeField() {
    final currentValue = _formData['vehicleType']?.toString();

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: const InputDecoration(
        labelText: 'Vehicle Type',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: VehicleType.values.map((type) {
        return DropdownMenuItem(
          value: type.name,
          child: Text(type.displayName),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select vehicle type';
        }
        return null;
      },
      onChanged: (value) => _formData['vehicleType'] = value,
      onSaved: (value) => _formData['vehicleType'] = value,
    );
  }

  Widget _buildFuelTypeField() {
    final currentValue = _formData['fuelType']?.toString();

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: const InputDecoration(
        labelText: 'Fuel Type',
        prefixIcon: Icon(Icons.local_gas_station),
        border: OutlineInputBorder(),
      ),
      items: FuelType.values.map((type) {
        return DropdownMenuItem(
          value: type.name,
          child: Text(type.displayName),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select fuel type';
        }
        return null;
      },
      onChanged: (value) => _formData['fuelType'] = value,
      onSaved: (value) => _formData['fuelType'] = value,
    );
  }

  Widget _buildFuelCapacityField() {
    return TextFormField(
      initialValue: _formData['fuelCapacity']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Fuel Capacity (L)',
        prefixIcon: Icon(Icons.local_gas_station),
        border: OutlineInputBorder(),
        suffixText: 'L',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter fuel capacity';
        }
        final capacity = double.tryParse(value);
        if (capacity == null || capacity <= 0) {
          return 'Please enter valid capacity';
        }
        return null;
      },
      onSaved: (value) => _formData['fuelCapacity'] = double.parse(value!),
    );
  }

  Widget _buildOdometerField() {
    return TextFormField(
      initialValue: _formData['currentOdometer']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Current Odometer',
        prefixIcon: Icon(Icons.speed),
        border: OutlineInputBorder(),
        suffixText: 'km',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter odometer reading';
        }
        final odometer = double.tryParse(value);
        if (odometer == null || odometer < 0) {
          return 'Please enter valid odometer reading';
        }
        return null;
      },
      onSaved: (value) => _formData['currentOdometer'] = double.parse(value!),
    );
  }

  Widget _buildPurchasePriceField() {
    return TextFormField(
      initialValue: _formData['purchasePrice']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Purchase Price',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
        prefixText: 'KES ',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter purchase price';
        }
        final price = double.tryParse(value);
        if (price == null || price <= 0) {
          return 'Please enter valid price';
        }
        return null;
      },
      onSaved: (value) => _formData['purchasePrice'] = double.parse(value!),
    );
  }

  Widget _buildCurrentValueField() {
    return TextFormField(
      initialValue: _formData['currentValue']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Current Value',
        prefixIcon: Icon(Icons.money),
        border: OutlineInputBorder(),
        prefixText: 'KES ',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter current value';
        }
        final valueNum = double.tryParse(value);
        if (valueNum == null || valueNum < 0) {
          return 'Please enter valid value';
        }
        return null;
      },
      onSaved: (value) => _formData['currentValue'] = double.parse(value!),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.isEditing ? 'Update Vehicle' : 'Create Vehicle',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (widget.isEditing) {
          final vehicle = ref.read(vehicleProvider).selectedVehicle;
          await ref
              .read(vehicleProvider.notifier)
              .updateVehicle(vehicle!.id, _formData);
        } else {
          await ref.read(vehicleProvider.notifier).createVehicle(_formData);
        }
        widget.onSave();
      } catch (e) {
        // Error is handled by the provider
      }
    }
  }
}
