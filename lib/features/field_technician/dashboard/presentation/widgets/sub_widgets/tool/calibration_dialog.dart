import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/tool_provider.dart';

class CalibrationDialog extends ConsumerStatefulWidget {
  final Tool tool;

  const CalibrationDialog({super.key, required this.tool});

  @override
  ConsumerState<CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends ConsumerState<CalibrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _calibratedByController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  final _accuracyController = TextEditingController();
  final _documentUrlController = TextEditingController();
  DateTime _calibrationDate = DateTime.now();
  DateTime _nextCalibrationDate = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _calibratedByController.dispose();
    _certificateNumberController.dispose();
    _accuracyController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toolNotifier = ref.read(toolProvider.notifier);

    return AlertDialog(
      title: const Text('Record Calibration'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Calibration for: ${widget.tool.toolName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _calibratedByController,
                label: 'Calibrated By',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calibrator name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _certificateNumberController,
                label: 'Certificate Number',
                icon: Icons.confirmation_number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter certificate number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _accuracyController,
                label: 'Accuracy',
                icon: Icons.precision_manufacturing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter accuracy';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _documentUrlController,
                label: 'Document URL',
                icon: Icons.link,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                'Calibration Date',
                _calibrationDate,
                (date) => setState(() => _calibrationDate = date!),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                'Next Calibration Date',
                _nextCalibrationDate,
                (date) => setState(() => _nextCalibrationDate = date!),
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
              final calibrationData = {
                'calibratedBy': _calibratedByController.text.trim(),
                'certificateNumber': _certificateNumberController.text.trim(),
                'accuracy': _accuracyController.text.trim(),
                'documentUrl': _documentUrlController.text.trim(),
                'calibrationDate': _calibrationDate.toIso8601String(),
                'nextCalibrationDate': _nextCalibrationDate.toIso8601String(),
              };

              toolNotifier.recordCalibration(widget.tool.id, calibrationData);
              Navigator.pop(context);
            }
          },
          child: const Text('Record Calibration'),
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
