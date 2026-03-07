import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/tool_provider.dart';

class UsageDialog extends ConsumerStatefulWidget {
  final Tool tool;

  const UsageDialog({super.key, required this.tool});

  @override
  ConsumerState<UsageDialog> createState() => _UsageDialogState();
}

class _UsageDialogState extends ConsumerState<UsageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usageHoursController = TextEditingController();

  @override
  void dispose() {
    _usageHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toolNotifier = ref.read(toolProvider.notifier);

    return AlertDialog(
      title: const Text('Update Usage'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update usage for: ${widget.tool.toolName}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              'Current total usage: ${widget.tool.totalUsageHours} hours',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usageHoursController,
              decoration: const InputDecoration(
                labelText: 'Additional Usage Hours',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter usage hours';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Please enter positive number';
                }
                return null;
              },
            ),
          ],
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
              final usageHours = double.parse(_usageHoursController.text);
              toolNotifier.updateUsage(widget.tool.id, usageHours);
              Navigator.pop(context);
            }
          },
          child: const Text('Update Usage'),
        ),
      ],
    );
  }
}
