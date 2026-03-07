import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/meter_reading_provider.dart';

class MeterReadingForm extends ConsumerStatefulWidget {
  const MeterReadingForm({super.key});

  @override
  ConsumerState<MeterReadingForm> createState() => _MeterReadingFormState();
}

class _MeterReadingFormState extends ConsumerState<MeterReadingForm> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _estimationReasonController = TextEditingController();
  final _readerNameController = TextEditingController();

  DateTime _readingDate = DateTime.now();
  String _readingType = 'manual';
  String _readingMethod = 'physical';
  bool _isEstimated = false;

  @override
  void dispose() {
    _meterNumberController.dispose();
    _currentReadingController.dispose();
    _estimationReasonController.dispose();
    _readerNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(meterReadingProvider.notifier);

    final data = {
      'meterNumber': _meterNumberController.text.trim().toUpperCase(),
      'currentReading': double.parse(_currentReadingController.text),
      'readingDate': _readingDate.toIso8601String(),
      'readingType': _readingType,
      'readingMethod': _readingMethod,
      'isEstimated': _isEstimated,
      if (_isEstimated && _estimationReasonController.text.isNotEmpty)
        'estimationReason': _estimationReasonController.text,
      if (_readerNameController.text.isNotEmpty)
        'readerName': _readerNameController.text,
    };

    await provider.createMeterReading(data);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _readingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _readingDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meterReadingProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Title
              const Text(
                'New Meter Reading',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter meter reading details below',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Meter Number
              TextFormField(
                controller: _meterNumberController,
                decoration: InputDecoration(
                  labelText: 'Meter Number',
                  prefixIcon: const Icon(Icons.speed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter meter number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meter number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Current Reading
              TextFormField(
                controller: _currentReadingController,
                decoration: InputDecoration(
                  labelText: 'Current Reading (m³)',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter current meter reading',
                  suffixText: 'm³',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current reading';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Reading cannot be negative';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Reading Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Reading Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(_readingDate)),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reading Type and Method Row
              Row(
                children: [
                  // Reading Type
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _readingType,
                      decoration: InputDecoration(
                        labelText: 'Reading Type',
                        prefixIcon: const Icon(Icons.type_specimen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'manual',
                          child: Text('Manual'),
                        ),
                        DropdownMenuItem(
                          value: 'smart_meter',
                          child: Text('Smart Meter'),
                        ),
                        DropdownMenuItem(
                          value: 'estimated',
                          child: Text('Estimated'),
                        ),
                        DropdownMenuItem(
                          value: 'customer',
                          child: Text('Customer Submitted'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _readingType = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Reading Method
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _readingMethod,
                      decoration: InputDecoration(
                        labelText: 'Reading Method',
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'physical',
                          child: Text('Physical'),
                        ),
                        DropdownMenuItem(
                          value: 'remote',
                          child: Text('Remote'),
                        ),
                        DropdownMenuItem(
                          value: 'customer_submitted',
                          child: Text('Customer Submitted'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _readingMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estimated Reading Checkbox
              CheckboxListTile(
                title: const Text('This is an estimated reading'),
                subtitle: const Text('Check if actual reading is unavailable'),
                value: _isEstimated,
                onChanged: (value) {
                  setState(() {
                    _isEstimated = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              // Estimation Reason (only show if estimated)
              if (_isEstimated) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _estimationReasonController,
                  decoration: InputDecoration(
                    labelText: 'Estimation Reason',
                    prefixIcon: const Icon(Icons.info),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Why is this an estimated reading?',
                  ),
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 16),

              // Reader Name (optional)
              TextFormField(
                controller: _readerNameController,
                decoration: InputDecoration(
                  labelText: 'Reader Name (Optional)',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter reader name',
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(meterReadingProvider.notifier).closeForms();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 8),
                          Text('Save Reading'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}