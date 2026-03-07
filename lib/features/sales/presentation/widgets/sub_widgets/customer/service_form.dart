import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class ServiceForm extends ConsumerStatefulWidget {
  final String customerId;
  final CustomerService? initialService;
  final VoidCallback onSuccess;

  const ServiceForm({
    super.key,
    required this.customerId,
    this.initialService,
    required this.onSuccess,
  });

  @override
  ConsumerState<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<ServiceForm> {
  final _formKey = GlobalKey<FormState>();

  ServiceType _serviceType = ServiceType.water_supply;
  final TextEditingController _serviceNumberController =
  TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  ServiceStatus _status = ServiceStatus.active;
  final TextEditingController _tariffController = TextEditingController();
  final TextEditingController _monthlyEstimateController =
  TextEditingController();
  final TextEditingController _lastReadingController = TextEditingController();
  final TextEditingController _lastReadingDateController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      final service = widget.initialService!;
      _serviceType = service.serviceType;
      _serviceNumberController.text = service.serviceNumber;
      _startDateController.text =
          DateFormat('yyyy-MM-dd').format(service.startDate);
      _status = service.status;
      _tariffController.text = service.tariff;
      _monthlyEstimateController.text = service.monthlyEstimate.toString();
      _lastReadingController.text = service.lastReading?.toString() ?? '';
      if (service.lastReadingDate != null) {
        _lastReadingDateController.text =
            DateFormat('yyyy-MM-dd').format(service.lastReadingDate!);
      }
    } else {
      _startDateController.text =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      _serviceNumberController.text =
      'SRV-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _serviceNumberController.dispose();
    _startDateController.dispose();
    _tariffController.dispose();
    _monthlyEstimateController.dispose();
    _lastReadingController.dispose();
    _lastReadingDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = ref.read(customerProvider.notifier);

      final serviceData = {
        'serviceType': _serviceType.name,
        'serviceNumber': _serviceNumberController.text.trim(),
        'startDate': _startDateController.text,
        'status': _status.name,
        'tariff': _tariffController.text.trim(),
        'monthlyEstimate': double.parse(_monthlyEstimateController.text),
        if (_lastReadingController.text.isNotEmpty)
          'lastReading': double.parse(_lastReadingController.text),
        if (_lastReadingDateController.text.isNotEmpty)
          'lastReadingDate': _lastReadingDateController.text,
      };

      if (widget.initialService == null) {
        await provider.addService(widget.customerId, serviceData);
      } else {
        await provider.updateService(
          widget.customerId,
          widget.initialService!.id,
          serviceData,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final initialDate = controller.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(controller.text)
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialService == null ? 'Add Service' : 'Edit Service',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ServiceType>(
                value: _serviceType,
                decoration: const InputDecoration(
                  labelText: 'Service Type *',
                  border: OutlineInputBorder(),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem<ServiceType>(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _serviceType = value);
                  }
                },
                validator: (value) {
                  if (value == null) return 'Please select service type';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Service Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _startDateController),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _startDateController),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ServiceStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: ServiceStatus.values.map((status) {
                  return DropdownMenuItem<ServiceStatus>(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
                validator: (value) {
                  if (value == null) return 'Please select status';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tariffController,
                decoration: const InputDecoration(
                  labelText: 'Tariff *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tariff';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _monthlyEstimateController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monthly Estimate (KES) *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly estimate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lastReadingController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Last Reading',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastReadingDateController,
                      decoration: const InputDecoration(
                        labelText: 'Last Reading Date',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _lastReadingDateController),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () =>
                        _selectDate(context, _lastReadingDateController),
                  ),
                ],
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