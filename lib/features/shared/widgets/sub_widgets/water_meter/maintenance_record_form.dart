import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/water_meter.provider.dart';

class MaintenanceRecordFormWidget extends ConsumerStatefulWidget {
  final String meterId;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const MaintenanceRecordFormWidget({
    super.key,
    required this.meterId,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  ConsumerState<MaintenanceRecordFormWidget> createState() =>
      _MaintenanceRecordFormWidgetState();
}

class _MaintenanceRecordFormWidgetState
    extends ConsumerState<MaintenanceRecordFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _technicianController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _maintenanceDate;
  DateTime? _nextScheduledDate;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _maintenanceDate = DateTime.now();
    _selectedType = 'routine';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _technicianController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final waterMeterNotifier = ref.read(waterMeterProvider.notifier);

    final recordData = {
      'date': _maintenanceDate!.toIso8601String(),
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'technician': _technicianController.text.trim(),
      'cost': double.parse(_costController.text),
      if (_nextScheduledDate != null)
        'nextScheduled': _nextScheduledDate!.toIso8601String(),
      if (_notesController.text.isNotEmpty)
        'notes': _notesController.text.trim(),
    };

    await waterMeterNotifier.addMaintenanceRecord(
      widget.meterId,
      recordData,
    );

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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(waterMeterProvider).isAddingMaintenance;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Maintenance Record',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              // Maintenance Date
              InkWell(
                onTap: () => _selectDate(
                  context,
                  (date) => setState(() => _maintenanceDate = date),
                  _maintenanceDate ?? DateTime.now(),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _maintenanceDate != null
                        ? DateFormat('dd MMM yyyy').format(_maintenanceDate!)
                        : 'Select date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Maintenance Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'routine', child: Text('Routine')),
                  DropdownMenuItem(value: 'repair', child: Text('Repair')),
                  DropdownMenuItem(
                      value: 'calibration', child: Text('Calibration')),
                  DropdownMenuItem(
                    value: 'battery_replacement',
                    child: Text('Battery Replacement'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select maintenance type' : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Technician
              TextFormField(
                controller: _technicianController,
                decoration: const InputDecoration(
                  labelText: 'Technician *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter technician name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost (KSH) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cost';
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
                    child: InkWell(
                      onTap: () => _selectDate(
                        context,
                        (date) => setState(() => _nextScheduledDate = date),
                        _nextScheduledDate ??
                            DateTime.now().add(const Duration(days: 30)),
                      ),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Next Scheduled',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _nextScheduledDate != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(_nextScheduledDate!)
                              : 'Select date',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Record'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
