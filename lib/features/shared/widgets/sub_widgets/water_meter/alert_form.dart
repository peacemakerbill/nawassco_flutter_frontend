import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/water_meter.model.dart';
import '../../../providers/water_meter.provider.dart';

class AlertFormWidget extends ConsumerStatefulWidget {
  final String meterId;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const AlertFormWidget({
    super.key,
    required this.meterId,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  ConsumerState<AlertFormWidget> createState() => _AlertFormWidgetState();
}

class _AlertFormWidgetState extends ConsumerState<AlertFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  AlertType? _selectedType;
  AlertSeverity? _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _selectedSeverity = AlertSeverity.medium;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final waterMeterNotifier = ref.read(waterMeterProvider.notifier);

    final alertData = {
      'type': _selectedType!.name,
      'severity': _selectedSeverity!.name,
      'description': _descriptionController.text.trim(),
    };

    await waterMeterNotifier.addAlert(widget.meterId, alertData);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(waterMeterProvider).isAddingAlert;

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
                'Add Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              // Alert Type
              DropdownButtonFormField<AlertType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Alert Type *',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    _selectedType?.icon ?? Icons.warning,
                    color: _selectedType?.color ?? Colors.grey,
                  ),
                ),
                items: AlertType.values.map((type) {
                  return DropdownMenuItem<AlertType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20, color: type.color),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select alert type' : null,
              ),
              const SizedBox(height: 12),

              // Severity
              DropdownButtonFormField<AlertSeverity>(
                value: _selectedSeverity,
                decoration: InputDecoration(
                  labelText: 'Severity *',
                  border: const OutlineInputBorder(),
                  prefixIcon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedSeverity?.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: 12,
                      color: _selectedSeverity?.color ?? Colors.grey,
                    ),
                  ),
                ),
                items: AlertSeverity.values.map((severity) {
                  return DropdownMenuItem<AlertSeverity>(
                    value: severity,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: severity.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(severity.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select severity' : null,
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
                    return 'Please enter alert description';
                  }
                  return null;
                },
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
                        backgroundColor: Colors.orange,
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
                          : const Text('Add Alert'),
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