import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/tool_provider.dart';

class ServiceDialog extends ConsumerStatefulWidget {
  final Tool tool;

  const ServiceDialog({super.key, required this.tool});

  @override
  ConsumerState<ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends ConsumerState<ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  DateTime _serviceDate = DateTime.now();
  DateTime _nextServiceDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _serviceProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toolNotifier = ref.read(toolProvider.notifier);

    return AlertDialog(
      title: const Text('Record Service'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Service for: ${widget.tool.toolName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _serviceTypeController,
                label: 'Service Type',
                icon: Icons.build_circle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service type';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _costController,
                label: 'Cost (KES)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid cost';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _serviceProviderController,
                label: 'Service Provider',
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                'Service Date',
                _serviceDate,
                (date) => setState(() => _serviceDate = date!),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                'Next Service Date',
                _nextServiceDate,
                (date) => setState(() => _nextServiceDate = date!),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final serviceData = {
                'serviceType': _serviceTypeController.text.trim(),
                'description': _descriptionController.text.trim(),
                'cost': double.parse(_costController.text),
                'serviceProvider': _serviceProviderController.text.trim(),
                'serviceDate': _serviceDate.toIso8601String(),
                'nextServiceDate': _nextServiceDate.toIso8601String(),
              };

              toolNotifier.recordService(widget.tool.id, serviceData);
              Navigator.pop(context);
            }
          },
          child: const Text('Record Service'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime?) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
