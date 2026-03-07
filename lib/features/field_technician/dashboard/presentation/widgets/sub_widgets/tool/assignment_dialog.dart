import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/field_technician_provider.dart';
import '../../../../providers/tool_provider.dart';

class AssignmentDialog extends ConsumerStatefulWidget {
  final Tool tool;

  const AssignmentDialog({super.key, required this.tool});

  @override
  ConsumerState<AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends ConsumerState<AssignmentDialog> {
  String? _selectedTechnicianId;
  String _condition = 'Good';
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load technicians if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldTechnicianProvider.notifier).loadFieldTechnicians();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final technicianState = ref.watch(fieldTechnicianProvider);
    final toolNotifier = ref.read(toolProvider.notifier);

    return AlertDialog(
      title: const Text('Assign Tool'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigning: ${widget.tool.toolName}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Technician Selection
            const Text('Select Technician:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTechnicianId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose a technician',
              ),
              items: technicianState.technicians
                  .where(
                      (tech) => tech.currentStatus.displayName == 'Available')
                  .map((technician) {
                return DropdownMenuItem<String>(
                  value: technician.id,
                  child: Text(technician.fullName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTechnicianId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a technician';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Condition
            const Text('Tool Condition:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Excellent', 'Good', 'Fair', 'Poor'].map((condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _condition = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Notes
            const Text('Notes (Optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Any additional notes...',
              ),
              maxLines: 3,
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
          onPressed: _selectedTechnicianId == null
              ? null
              : () {
                  toolNotifier.assignTool(
                    widget.tool.id,
                    _selectedTechnicianId!,
                    _condition,
                    notes: _notesController.text.trim(),
                  );
                  Navigator.pop(context);
                },
          child: const Text('Assign Tool'),
        ),
      ],
    );
  }
}
