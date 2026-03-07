import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/water_meter.provider.dart';

class IssueFormWidget extends ConsumerStatefulWidget {
  final String meterId;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const IssueFormWidget({
    super.key,
    required this.meterId,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  ConsumerState<IssueFormWidget> createState() => _IssueFormWidgetState();
}

class _IssueFormWidgetState extends ConsumerState<IssueFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _reportedByController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _resolutionNotesController = TextEditingController();
  final _costIncurredController = TextEditingController();

  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = 'damaged';
    _selectedStatus = 'reported';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportedByController.dispose();
    _assignedToController.dispose();
    _resolutionNotesController.dispose();
    _costIncurredController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final waterMeterNotifier = ref.read(waterMeterProvider.notifier);

    final issueData = {
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'reportedBy': _reportedByController.text.trim(),
      'status': _selectedStatus,
      if (_assignedToController.text.isNotEmpty)
        'assignedTo': _assignedToController.text.trim(),
      if (_resolutionNotesController.text.isNotEmpty)
        'resolutionNotes': _resolutionNotesController.text.trim(),
      if (_costIncurredController.text.isNotEmpty)
        'costIncurred': double.tryParse(_costIncurredController.text),
    };

    await waterMeterNotifier.addIssue(widget.meterId, issueData);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(waterMeterProvider).isAddingIssue;

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
                'Report Issue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              // Issue Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Issue Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.error),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'damaged', child: Text('Damaged Meter')),
                  DropdownMenuItem(
                      value: 'stolen', child: Text('Stolen Meter')),
                  DropdownMenuItem(
                    value: 'faulty_reading',
                    child: Text('Faulty Reading'),
                  ),
                  DropdownMenuItem(
                    value: 'installation_issue',
                    child: Text('Installation Issue'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select issue type' : null,
              ),
              const SizedBox(height: 12),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: const [
                  DropdownMenuItem(value: 'reported', child: Text('Reported')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select status' : null,
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
                    return 'Please enter issue description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Reported By
              TextFormField(
                controller: _reportedByController,
                decoration: const InputDecoration(
                  labelText: 'Reported By *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reporter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Assigned To
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assigned To',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_ind),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _resolutionNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Resolution Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costIncurredController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Incurred (KSH)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
                        backgroundColor: Colors.red,
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
                          : const Text('Report Issue'),
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
