import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../public/auth/providers/auth_provider.dart';
import '../../../../sales/providers/customer_provider.dart';
import '../../../models/water_meter.model.dart';
import '../../../providers/water_meter.provider.dart';

class WaterMeterFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;
  final bool isEditMode;
  final WaterMeter? initialData;

  const WaterMeterFormWidget({
    super.key,
    required this.onCancel,
    required this.onSuccess,
    this.isEditMode = false,
    this.initialData,
  });

  @override
  ConsumerState<WaterMeterFormWidget> createState() =>
      _WaterMeterFormWidgetState();
}

class _WaterMeterFormWidgetState extends ConsumerState<WaterMeterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form Controllers
  final _meterNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _wardController = TextEditingController();
  final _installerNameController = TextEditingController();
  final _installerCompanyController = TextEditingController();
  final _installationCostController = TextEditingController();
  final _installationNotesController = TextEditingController();
  final _sizeController = TextEditingController();
  final _maxFlowRateController = TextEditingController();
  final _accuracyClassController = TextEditingController();
  final _pressureRatingController = TextEditingController();
  final _materialController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _communicationProtocolController = TextEditingController();
  final _simCardNumberController = TextEditingController();
  final _dataTransmissionIntervalController = TextEditingController();
  final _signalThresholdController = TextEditingController();

  // Selected Values
  String? _selectedCustomerId;
  NakuruServiceRegion? _selectedServiceRegion;
  MeterType? _selectedMeterType;
  MeterTechnology? _selectedMeterTechnology;
  String? _selectedAccessibility;
  String? _selectedInstallationType;
  DateTime? _installationDate;
  DateTime? _manufacturingDate;
  DateTime? _warrantyExpiry;
  double? _minTemperature;
  double? _maxTemperature;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.initialData != null) {
      _loadInitialData();
    } else {
      _setDefaultValues();
    }
  }

  void _loadInitialData() {
    final data = widget.initialData!;

    _meterNumberController.text = data.meterNumber;
    _serialNumberController.text = data.serialNumber;
    _selectedCustomerId = data.customerId;
    _customerNameController.text = data.customerName;
    _customerEmailController.text = data.customerEmail;
    _customerPhoneController.text = data.customerPhone ?? '';
    _selectedServiceRegion = data.serviceRegion;
    _wardController.text = data.ward ?? '';

    // Installation
    _installationDate = data.installation.installationDate;
    _installerNameController.text = data.installation.installerName;
    _installerCompanyController.text = data.installation.installerCompany ?? '';
    _installationCostController.text =
        data.installation.installationCost.toString();
    _warrantyExpiry = data.installation.warrantyExpiry;
    _installationNotesController.text =
        data.installation.installationNotes ?? '';

    // Specifications
    _sizeController.text = data.specifications.size;
    _maxFlowRateController.text = data.specifications.maxFlowRate.toString();
    _accuracyClassController.text = data.specifications.accuracyClass;
    _minTemperature = data.specifications.operatingTemperature.min;
    _maxTemperature = data.specifications.operatingTemperature.max;
    _pressureRatingController.text =
        data.specifications.pressureRating.toString();
    _materialController.text = data.specifications.material;
    _manufacturerController.text = data.specifications.manufacturer;
    _modelController.text = data.specifications.model;
    _manufacturingDate = data.specifications.manufacturingDate;

    // Type & Technology
    _selectedMeterType = data.type;
    _selectedMeterTechnology = data.technology;

    // Location
    _addressController.text = data.location.address;
    _landmarkController.text = data.location.landmark ?? '';
    _latitude = data.location.gpsCoordinates?.latitude;
    _longitude = data.location.gpsCoordinates?.longitude;
    _selectedAccessibility = data.location.accessibility;
    _selectedInstallationType = data.location.installationType;

    // Transmission
    _communicationProtocolController.text =
        data.transmission.communicationProtocol;
    _simCardNumberController.text = data.transmission.simCardNumber ?? '';
    _dataTransmissionIntervalController.text =
        data.transmission.dataTransmissionInterval.toString();
    _signalThresholdController.text =
        data.transmission.signalThreshold.toString();
  }

  void _setDefaultValues() {
    final auth = ref.read(authProvider);
    final user = auth.user;

    if (user != null) {
      _installerNameController.text =
          '${user['firstName']} ${user['lastName']}';
    }

    _selectedServiceRegion = NakuruServiceRegion.nakuru_municipality;
    _selectedMeterType = MeterType.smart;
    _selectedMeterTechnology = MeterTechnology.ami;
    _selectedAccessibility = 'easy';
    _selectedInstallationType = 'outdoor';
    _installationDate = DateTime.now();
    _manufacturingDate = DateTime.now().subtract(const Duration(days: 30));
    _warrantyExpiry = DateTime.now().add(const Duration(days: 365));
    _minTemperature = 0.0;
    _maxTemperature = 50.0;
    _dataTransmissionIntervalController.text = '60';
    _signalThresholdController.text = '20';
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _serialNumberController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _wardController.dispose();
    _installerNameController.dispose();
    _installerCompanyController.dispose();
    _installationCostController.dispose();
    _installationNotesController.dispose();
    _sizeController.dispose();
    _maxFlowRateController.dispose();
    _accuracyClassController.dispose();
    _pressureRatingController.dispose();
    _materialController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _communicationProtocolController.dispose();
    _simCardNumberController.dispose();
    _dataTransmissionIntervalController.dispose();
    _signalThresholdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final waterMeterNotifier = ref.read(waterMeterProvider.notifier);
    final auth = ref.read(authProvider);

    // Prepare form data
    final formData = {
      'meterNumber': _meterNumberController.text.trim().toUpperCase(),
      'serialNumber': _serialNumberController.text.trim().toUpperCase(),
      'customer': _selectedCustomerId,
      'customerName': _customerNameController.text.trim(),
      'customerEmail': _customerEmailController.text.trim().toLowerCase(),
      if (_customerPhoneController.text.isNotEmpty)
        'customerPhone': _customerPhoneController.text.trim(),
      'serviceRegion': _selectedServiceRegion!.name,
      if (_wardController.text.isNotEmpty) 'ward': _wardController.text.trim(),
      'installation': {
        'installationDate': _installationDate!.toIso8601String(),
        'installerName': _installerNameController.text.trim(),
        if (_installerCompanyController.text.isNotEmpty)
          'installerCompany': _installerCompanyController.text.trim(),
        'installationCost': double.parse(_installationCostController.text),
        if (_warrantyExpiry != null)
          'warrantyExpiry': _warrantyExpiry!.toIso8601String(),
        if (_installationNotesController.text.isNotEmpty)
          'installationNotes': _installationNotesController.text.trim(),
      },
      'specifications': {
        'size': _sizeController.text.trim(),
        'maxFlowRate': double.parse(_maxFlowRateController.text),
        'accuracyClass': _accuracyClassController.text.trim(),
        'operatingTemperature': {
          'min': _minTemperature!,
          'max': _maxTemperature!,
        },
        'pressureRating': double.parse(_pressureRatingController.text),
        'material': _materialController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'model': _modelController.text.trim(),
        'manufacturingDate': _manufacturingDate!.toIso8601String(),
      },
      'type': _selectedMeterType!.name,
      'technology': _selectedMeterTechnology!.name,
      'location': {
        'address': _addressController.text.trim(),
        if (_landmarkController.text.isNotEmpty)
          'landmark': _landmarkController.text.trim(),
        if (_latitude != null && _longitude != null)
          'gpsCoordinates': {
            'latitude': _latitude!,
            'longitude': _longitude!,
          },
        'accessibility': _selectedAccessibility!,
        'installationType': _selectedInstallationType!,
      },
      'transmission': {
        'communicationProtocol': _communicationProtocolController.text.trim(),
        if (_simCardNumberController.text.isNotEmpty)
          'simCardNumber': _simCardNumberController.text.trim(),
        'dataTransmissionInterval':
            int.parse(_dataTransmissionIntervalController.text),
        'signalThreshold': double.parse(_signalThresholdController.text),
      },
      'tariff': 'default_tariff_id', // This should come from tariff provider
      'installedBy': auth.user?['_id'],
    };

    if (widget.isEditMode && widget.initialData != null) {
      await waterMeterNotifier.updateWaterMeter(
        widget.initialData!.id,
        formData,
      );
    } else {
      await waterMeterNotifier.createWaterMeter(formData);
    }

    widget.onSuccess();
  }

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected,
    DateTime initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime) onChanged,
    DateTime? initialDate,
  }) {
    return InkWell(
      onTap: () => _selectDate(
        context,
        onChanged,
        value ?? initialDate ?? DateTime.now(),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? DateFormat('yyyy-MM-dd').format(value)
              : 'Select date',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayName,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayName(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);
    final waterMeterState = ref.watch(waterMeterProvider);
    final isLoading = widget.isEditMode
        ? waterMeterState.isUpdating
        : waterMeterState.isCreating;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
        title: Text(
          widget.isEditMode ? 'Edit Water Meter' : 'Add New Water Meter',
        ),
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Information
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _meterNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Meter Number *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter meter number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter serial number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Customer Selection
                  _buildSectionHeader('Customer Information'),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Customer *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: customerState.customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.id,
                        child:
                            Text('${customer.firstName} ${customer.lastName}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomerId = value;
                        if (value != null) {
                          final customer = customerState.customers.firstWhere(
                            (c) => c.id == value,
                          );
                          _customerNameController.text =
                              '${customer.firstName} ${customer.lastName}';
                          _customerEmailController.text = customer.email;
                          _customerPhoneController.text = customer.phone;
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a customer' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customerEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Email *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _customerPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Service Region and Ward
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<NakuruServiceRegion>(
                          label: 'Service Region *',
                          value: _selectedServiceRegion,
                          items: NakuruServiceRegion.values,
                          displayName: (region) => region.displayName,
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceRegion = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _wardController,
                          decoration: const InputDecoration(
                            labelText: 'Ward',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Installation Details
                  _buildSectionHeader('Installation Details'),
                  const SizedBox(height: 16),

                  _buildDateField(
                    label: 'Installation Date *',
                    value: _installationDate,
                    onChanged: (date) {
                      setState(() {
                        _installationDate = date;
                      });
                    },
                    initialDate: DateTime.now(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _installerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Installer Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.engineering),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter installer name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _installerCompanyController,
                          decoration: const InputDecoration(
                            labelText: 'Installer Company',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _installationCostController,
                          decoration: const InputDecoration(
                            labelText: 'Installation Cost *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter installation cost';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          label: 'Warranty Expiry',
                          value: _warrantyExpiry,
                          onChanged: (date) {
                            setState(() {
                              _warrantyExpiry = date;
                            });
                          },
                          initialDate:
                              DateTime.now().add(const Duration(days: 365)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _installationNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Installation Notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),

                  // Meter Specifications
                  _buildSectionHeader('Meter Specifications'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<MeterType>(
                          label: 'Meter Type *',
                          value: _selectedMeterType,
                          items: MeterType.values,
                          displayName: (type) => type.displayName,
                          onChanged: (value) {
                            setState(() {
                              _selectedMeterType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<MeterTechnology>(
                          label: 'Meter Technology *',
                          value: _selectedMeterTechnology,
                          items: MeterTechnology.values,
                          displayName: (tech) => tech.displayName,
                          onChanged: (value) {
                            setState(() {
                              _selectedMeterTechnology = value;
                            });
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
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Meter Size *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter meter size';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxFlowRateController,
                          decoration: const InputDecoration(
                            labelText: 'Max Flow Rate (m³/h) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.speed),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter max flow rate';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
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
                          controller: _accuracyClassController,
                          decoration: const InputDecoration(
                            labelText: 'Accuracy Class *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.precision_manufacturing),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter accuracy class';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _pressureRatingController,
                          decoration: const InputDecoration(
                            labelText: 'Pressure Rating (bar) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.compress),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pressure rating';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
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
                          controller: _materialController,
                          decoration: const InputDecoration(
                            labelText: 'Material *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.construction),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter material';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _manufacturerController,
                          decoration: const InputDecoration(
                            labelText: 'Manufacturer *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.factory),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter manufacturer';
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
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.model_training),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter model';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          label: 'Manufacturing Date *',
                          value: _manufacturingDate,
                          onChanged: (date) {
                            setState(() {
                              _manufacturingDate = date;
                            });
                          },
                          initialDate: DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Temperature Range
                  _buildSectionHeader('Operating Temperature Range'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _minTemperature?.toString() ?? '0',
                          decoration: const InputDecoration(
                            labelText: 'Min Temperature (°C) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.thermostat),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minTemperature = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _maxTemperature?.toString() ?? '50',
                          decoration: const InputDecoration(
                            labelText: 'Max Temperature (°C) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.thermostat),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxTemperature = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Location Details
                  _buildSectionHeader('Location Details'),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _landmarkController,
                    decoration: const InputDecoration(
                      labelText: 'Landmark',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<String>(
                          label: 'Accessibility *',
                          value: _selectedAccessibility,
                          items: const ['easy', 'moderate', 'difficult'],
                          displayName: (item) => item.toUpperCase(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccessibility = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<String>(
                          label: 'Installation Type *',
                          value: _selectedInstallationType,
                          items: const ['indoor', 'outdoor', 'underground'],
                          displayName: (item) => item.toUpperCase(),
                          onChanged: (value) {
                            setState(() {
                              _selectedInstallationType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Transmission Settings
                  _buildSectionHeader('Transmission Settings'),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _communicationProtocolController,
                    decoration: const InputDecoration(
                      labelText: 'Communication Protocol *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.settings_input_antenna),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter communication protocol';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _simCardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'SIM Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sim_card),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dataTransmissionIntervalController,
                          decoration: const InputDecoration(
                            labelText: 'Transmission Interval (seconds) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter transmission interval';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _signalThresholdController,
                          decoration: const InputDecoration(
                            labelText: 'Signal Threshold *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.signal_cellular_alt),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter signal threshold';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // Submit Button
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditMode
                                ? 'Update Water Meter'
                                : 'Create Water Meter',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
